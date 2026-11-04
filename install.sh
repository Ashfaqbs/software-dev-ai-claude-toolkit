#!/usr/bin/env bash
set -euo pipefail

# software-dev-ai-claude-toolkit installer (Mac/Linux)
# Copies rules, commands, agents, skills, hooks, and MCP config to ~/.claude/
#
# By default installs everything. Pass --stacks=<group,group,...> to install
# only "general" (cross-stack) components plus the stacks you name, e.g.:
#   ./install.sh --stacks=python-fastapi,ai-ml
# Run ./install.sh --list to see available groups. Requires Node.js for
# filtering; without Node, --stacks is ignored and everything is installed.

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STACKS_ARG=""
LIST_ONLY=false

# On git-bash/MSYS (common on Windows), $PWD-derived paths look like
# /c/tmp/... which Node's require()/fs on native Windows cannot resolve.
# Convert to a Windows path with forward slashes (cygpath -m) for anything
# handed to `node -e` when cygpath is available — forward slashes avoid
# backslash-escape corruption (e.g. \t) when the path is embedded in a JS
# string literal; elsewhere this is a no-op.
to_native_path() {
    if command -v cygpath &>/dev/null; then
        cygpath -m "$1"
    else
        echo "$1"
    fi
}
NODE_SCRIPT_DIR="$(to_native_path "$SCRIPT_DIR")"

for arg in "$@"; do
    case "$arg" in
        --stacks=*)
            STACKS_ARG="${arg#--stacks=}"
            ;;
        --list)
            LIST_ONLY=true
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

if [ "$LIST_ONLY" = true ]; then
    if command -v node &>/dev/null; then
        node -e "
const m = require('$NODE_SCRIPT_DIR/toolkit-manifest.json');
console.log('Available install groups:');
for (const [g, desc] of Object.entries(m.installGroups)) {
    console.log('  ' + g + ' - ' + desc);
}
"
    else
        echo "Node.js is required for --list. Available groups: general, java-springboot, python-fastapi, javascript-react, ai-ml"
    fi
    exit 0
fi

echo "=== Software Dev AI Claude Toolkit - Installer ==="
echo ""
echo "This will install Claude Code configurations to: $CLAUDE_DIR"
if [ -n "$STACKS_ARG" ]; then
    echo "Stack filter: general + $STACKS_ARG"
fi
echo ""

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Creating $CLAUDE_DIR..."
    mkdir -p "$CLAUDE_DIR"
fi

HAVE_NODE=false
if command -v node &>/dev/null; then
    HAVE_NODE=true
fi

if [ -n "$STACKS_ARG" ] && [ "$HAVE_NODE" = false ]; then
    echo "  WARN: --stacks requires Node.js, which was not found. Installing everything instead."
    STACKS_ARG=""
fi

# Given a component type (rules|skills) and a manifest, print the ids that
# belong to "general" or one of the requested stacks, one per line.
filtered_ids() {
    local type="$1"
    node -e "
const m = require('$NODE_SCRIPT_DIR/toolkit-manifest.json');
const wanted = new Set(['general', ...'$STACKS_ARG'.split(',').map(s => s.trim()).filter(Boolean)]);
for (const entry of m['$type']) {
    if (wanted.has(entry.group)) console.log(entry.id);
}
"
}

# Function to copy a directory with backup, optionally restricted to a set of
# top-level file/dir names (one per line on stdin via $4, empty = copy all)
copy_dir() {
    local src="$1"
    local dest="$2"
    local name="$3"
    local only_ids="$4" # newline-separated ids, or empty for "copy everything"

    if [ ! -d "$src" ]; then
        echo "  SKIP: $name (source not found)"
        return
    fi

    if [ -d "$dest" ]; then
        echo "  MERGE: $name (directory exists, merging files)"
    else
        mkdir -p "$dest"
    fi

    if [ -z "$only_ids" ]; then
        cp -r "$src"/* "$dest"/ 2>/dev/null || true
        echo "  OK: $name"
        return
    fi

    local copied=0
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        if [ -f "$src/$id.md" ]; then
            cp "$src/$id.md" "$dest/"
            copied=$((copied + 1))
        elif [ -d "$src/$id" ]; then
            mkdir -p "$dest/$id"
            cp -r "$src/$id"/* "$dest/$id"/ 2>/dev/null || true
            copied=$((copied + 1))
        fi
    done <<< "$only_ids"
    echo "  OK: $name ($copied installed for selected stacks)"
}

# Function to copy a file with backup
copy_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ ! -f "$src" ]; then
        echo "  SKIP: $name (source not found)"
        return
    fi

    if [ -f "$dest" ]; then
        local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$dest" "$backup"
        echo "  BACKUP: $name -> $(basename "$backup")"
    fi

    cp "$src" "$dest"
    echo "  OK: $name"
}

echo "Installing components..."
echo ""

RULES_IDS=""
SKILLS_IDS=""
if [ -n "$STACKS_ARG" ]; then
    RULES_IDS="$(filtered_ids rules)"
    SKILLS_IDS="$(filtered_ids skills)"
fi

# Rules
copy_dir "$SCRIPT_DIR/rules" "$CLAUDE_DIR/rules" "rules (9 files)" "$RULES_IDS"

# Commands (always installed — not stack-specific)
copy_dir "$SCRIPT_DIR/commands" "$CLAUDE_DIR/commands" "commands (8 slash commands)" ""

# Agents (always installed — not stack-specific)
copy_dir "$SCRIPT_DIR/agents" "$CLAUDE_DIR/agents" "agents (5 agents)" ""

# Skills
copy_dir "$SCRIPT_DIR/skills" "$CLAUDE_DIR/skills" "skills (14 skill packs)" "$SKILLS_IDS"

# Hooks — merge into existing settings.json
if [ -f "$SCRIPT_DIR/hooks/settings.json" ]; then
    if [ "$HAVE_NODE" = true ]; then
        NODE_CLAUDE_DIR="$(to_native_path "$CLAUDE_DIR")"
        node -e "
const fs = require('fs');
const src = JSON.parse(fs.readFileSync('$NODE_SCRIPT_DIR/hooks/settings.json', 'utf8'));
const destPath = '$NODE_CLAUDE_DIR/settings.json';
let dest = {};
if (fs.existsSync(destPath)) {
    dest = JSON.parse(fs.readFileSync(destPath, 'utf8'));
    fs.copyFileSync(destPath, destPath + '.backup.' + Date.now());
}
dest.hooks = src.hooks;
fs.writeFileSync(destPath, JSON.stringify(dest, null, 2));
"
        echo "  OK: hooks (merged into settings.json)"
    else
        echo "  WARN: Node.js not found. Copying hooks/settings.json manually."
        copy_file "$SCRIPT_DIR/hooks/settings.json" "$CLAUDE_DIR/settings.json" "settings.json"
    fi
fi

# MCP servers
if [ -f "$SCRIPT_DIR/mcp/mcp-servers.json" ]; then
    mkdir -p "$CLAUDE_DIR"
    if [ -f "$CLAUDE_DIR/.mcp.json" ]; then
        cp "$CLAUDE_DIR/.mcp.json" "$CLAUDE_DIR/.mcp.json.backup.$(date +%Y%m%d%H%M%S)"
        echo "  BACKUP: .mcp.json"
    fi
    cp "$SCRIPT_DIR/mcp/mcp-servers.json" "$CLAUDE_DIR/.mcp.json"
    echo "  OK: MCP servers (4 servers configured)"
    echo ""
    echo "  NOTE: Edit ~/.claude/.mcp.json and replace <YOUR_GITHUB_TOKEN>"
    echo "        with your GitHub personal access token."
fi

# CLAUDE.md — only install if not present
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    if [ -f "$SCRIPT_DIR/examples/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/examples/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
        echo "  OK: CLAUDE.md (installed example — customize it!)"
    fi
else
    echo "  SKIP: CLAUDE.md (already exists, not overwriting)"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "What was installed:"
if [ -n "$STACKS_ARG" ]; then
    echo "  - general rules/skills + stacks: $STACKS_ARG"
    echo "  - 8 slash commands, 5 agents (always installed, stack-neutral)"
else
    echo "  - 9 coding rules (coding style, Java, Python, JS, DBs, infra, git, testing, security)"
    echo "  - 8 slash commands (/plan, /code-review, /tdd, /build-fix, /api-design, /docker-setup, /system-design, /db-schema)"
    echo "  - 5 specialized agents (planner, code-reviewer, security-reviewer, architect, tdd-guide)"
    echo "  - 14 skill packs (Spring Boot, Python, React, PostgreSQL, JPA, Kafka, security, and more)"
fi
echo "  - 4 code quality hooks (block dangerous commands, warn on print/console.log/System.out)"
echo "  - 4 MCP servers (context7, memory, sequential-thinking, github)"
echo ""
echo "Next steps:"
echo "  1. Customize ~/.claude/CLAUDE.md with your personal preferences"
echo "  2. Add your GitHub token to ~/.claude/.mcp.json"
echo "  3. Start Claude Code in any project and enjoy!"
