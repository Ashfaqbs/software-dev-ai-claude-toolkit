#!/usr/bin/env bash
set -euo pipefail

# ai-coding-agent-toolkit installer (Mac/Linux)
# Copies rules, commands, agents, skills, hooks, and MCP config to ~/.claude/
# by default.
#
# Flags:
#   --stacks=<group,group,...>  Install only "general" (cross-stack) components
#                                plus the stacks you name, e.g.:
#                                  ./install.sh --stacks=python-fastapi,ai-ml
#                                Requires Node.js; without it, --stacks is
#                                ignored and everything is installed.
#   --local                     Install into ./.claude in the current directory
#                                (project-scoped) instead of ~/.claude (global,
#                                the default). Also installs ./CLAUDE.md (blank
#                                project template) and ./.mcp.json here instead
#                                of under ~/.claude.
#   --ai=<target>                Target AI tool. Default: claude (full install).
#                                Other targets export the selected rules into
#                                that tool's own format at the project root and
#                                skip commands/agents/skills/hooks/MCP (no
#                                equivalent there yet, except opencode which
#                                also maps commands/agents). See --list.
#   --list                      Print available --stacks groups and --ai
#                                targets, and exit.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STACKS_ARG=""
LIST_ONLY=false
LOCAL_INSTALL=false
AI_TARGET="claude"

for arg in "$@"; do
    case "$arg" in
        --stacks=*)
            STACKS_ARG="${arg#--stacks=}"
            ;;
        --local)
            LOCAL_INSTALL=true
            ;;
        --ai=*)
            AI_TARGET="${arg#--ai=}"
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

case "$AI_TARGET" in
    claude|copilot|cursor|windsurf|opencode|agentsmd) ;;
    *)
        echo "Unknown --ai target: $AI_TARGET (expected one of: claude, copilot, cursor, windsurf, opencode, agentsmd)" >&2
        exit 1
        ;;
esac

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

if [ "$LIST_ONLY" = true ]; then
    if command -v node &>/dev/null; then
        node -e "
const m = require('$NODE_SCRIPT_DIR/toolkit-manifest.json');
console.log('Available --stacks groups:');
for (const [g, desc] of Object.entries(m.installGroups)) {
    console.log('  ' + g + ' - ' + desc);
}
console.log('');
console.log('Available --ai targets:');
for (const [t, desc] of Object.entries(m.aiTargets)) {
    console.log('  ' + t + ' - ' + desc);
}
console.log('');
console.log(m.aiTargetsNote);
"
    else
        echo "Node.js is required for --list. Groups: general, java-springboot, python-fastapi, javascript-react, ai-ml. AI targets: claude, copilot, cursor, windsurf, opencode, agentsmd."
    fi
    exit 0
fi

PROJECT_ROOT="$(pwd)"
if [ "$LOCAL_INSTALL" = true ]; then
    CLAUDE_DIR="$PROJECT_ROOT/.claude"
else
    CLAUDE_DIR="$HOME/.claude"
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

# === Non-claude export paths: flatten/translate the selected rules into the
# target tool's own format, skip the rest (no equivalent there yet, except
# opencode which also maps commands/agents), and exit. All of these always
# write to the current directory regardless of --local, since none of them
# have a global/user-level config the way Claude Code does.
if [ "$AI_TARGET" != "claude" ]; then
    echo "=== AI Coding Agent Toolkit - Installer ($AI_TARGET target) ==="
    echo ""
    if [ "$HAVE_NODE" = false ]; then
        echo "ERROR: --ai=$AI_TARGET requires Node.js to filter/flatten rules." >&2
        exit 1
    fi

    RULE_IDS="$(filtered_ids rules)"

    # Flatten $RULE_IDS into one markdown file at $1, with a generator comment
    # naming the tool in $2.
    flatten_rules_to_file() {
        local dest="$1"
        local tool_label="$2"
        mkdir -p "$(dirname "$dest")"
        if [ -f "$dest" ]; then
            cp "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"
            echo "  BACKUP: $(basename "$dest")"
        fi
        {
            echo "<!-- Generated by ai-coding-agent-toolkit $tool_label -->"
            echo "<!-- Source rules flattened below; edit freely, this is a one-time export -->"
            echo ""
            while IFS= read -r id; do
                [ -z "$id" ] && continue
                if [ -f "$SCRIPT_DIR/rules/$id.md" ]; then
                    echo "## Rule: $id"
                    echo ""
                    cat "$SCRIPT_DIR/rules/$id.md"
                    echo ""
                    echo "---"
                    echo ""
                fi
            done <<< "$RULE_IDS"
        } > "$dest"
    }

    case "$AI_TARGET" in
        copilot)
            flatten_rules_to_file "$PROJECT_ROOT/.github/copilot-instructions.md" "install.sh --ai=copilot"
            echo "  OK: .github/copilot-instructions.md (flattened from rules)"
            echo "  SKIPPED (no Copilot equivalent in v1): commands, agents, skills, hooks, MCP config"
            ;;
        agentsmd)
            flatten_rules_to_file "$PROJECT_ROOT/AGENTS.md" "install.sh --ai=agentsmd"
            echo "  OK: AGENTS.md (the open AGENTS.md standard — read by Codex, OpenCode, Jules,"
            echo "      Zed, Warp, Aider, goose, Amp, and as a fallback by Cursor/Windsurf/Copilot)"
            echo "  SKIPPED (no shared equivalent in v1): commands, agents, skills, hooks, MCP config"
            ;;
        cursor)
            mkdir -p "$PROJECT_ROOT/.cursor/rules"
            n=0
            while IFS= read -r id; do
                [ -z "$id" ] && continue
                [ -f "$SCRIPT_DIR/rules/$id.md" ] || continue
                dest="$PROJECT_ROOT/.cursor/rules/$id.mdc"
                {
                    echo "---"
                    echo "description: $id (from ai-coding-agent-toolkit)"
                    echo "alwaysApply: true"
                    echo "---"
                    echo ""
                    cat "$SCRIPT_DIR/rules/$id.md"
                } > "$dest"
                n=$((n + 1))
            done <<< "$RULE_IDS"
            echo "  OK: .cursor/rules/*.mdc ($n files, alwaysApply: true)"
            echo "  SKIPPED (no Cursor equivalent in v1): commands, agents, skills, hooks, MCP config"
            ;;
        windsurf)
            mkdir -p "$PROJECT_ROOT/.windsurf/rules"
            n=0
            while IFS= read -r id; do
                [ -z "$id" ] && continue
                [ -f "$SCRIPT_DIR/rules/$id.md" ] || continue
                dest="$PROJECT_ROOT/.windsurf/rules/$id.md"
                cp "$SCRIPT_DIR/rules/$id.md" "$dest"
                chars=$(wc -c < "$dest" | tr -d ' ')
                if [ "$chars" -gt 6000 ]; then
                    echo "  WARN: $id.md is $chars chars — over Windsurf's ~6000-char-per-file guidance, it may be truncated"
                fi
                n=$((n + 1))
            done <<< "$RULE_IDS"
            echo "  OK: .windsurf/rules/*.md ($n files)"
            echo "  SKIPPED (no Windsurf equivalent in v1): commands, agents, skills, hooks, MCP config"
            ;;
        opencode)
            flatten_rules_to_file "$PROJECT_ROOT/AGENTS.md" "install.sh --ai=opencode"
            echo "  OK: AGENTS.md"

            mkdir -p "$PROJECT_ROOT/.opencode/command"
            cp "$SCRIPT_DIR"/commands/*.md "$PROJECT_ROOT/.opencode/command/" 2>/dev/null || true
            cmd_count=$(ls "$SCRIPT_DIR"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
            echo "  OK: .opencode/command/*.md ($cmd_count commands, copied as-is — same \$ARGUMENTS convention)"

            mkdir -p "$PROJECT_ROOT/.opencode/agent"
            agent_count=0
            for f in "$SCRIPT_DIR"/agents/*.md; do
                [ -f "$f" ] || continue
                id="$(basename "$f" .md)"
                node -e "
const fs = require('fs');
const raw = fs.readFileSync('$(to_native_path "$f")', 'utf8');
const m = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
const body = m ? m[2] : raw;
let desc = '';
if (m) {
    const dm = m[1].match(/^description:\s*(.*)$/m);
    if (dm) desc = dm[1].trim().replace(/\r$/, '');
}
const out = '---\ndescription: ' + desc + '\nmode: subagent\n---\n' + body;
fs.writeFileSync('$(to_native_path "$PROJECT_ROOT/.opencode/agent/$id.md")', out);
"
                agent_count=$((agent_count + 1))
            done
            echo "  OK: .opencode/agent/*.md ($agent_count agents, mode: subagent — model/tools fields dropped,"
            echo "      OpenCode's model ids differ from Claude's; set manually if you need a specific model"
            echo "  SKIPPED (no OpenCode equivalent in v1): skills, hooks, MCP config"
            ;;
    esac

    echo ""
    echo "=== Installation Complete ==="
    exit 0
fi

# === Claude path (default) ===

echo "=== AI Coding Agent Toolkit - Installer ==="
echo ""
if [ "$LOCAL_INSTALL" = true ]; then
    echo "This will install Claude Code configurations to: $CLAUDE_DIR (project-local)"
else
    echo "This will install Claude Code configurations to: $CLAUDE_DIR (global)"
fi
if [ -n "$STACKS_ARG" ]; then
    echo "Stack filter: general + $STACKS_ARG"
fi
echo ""

if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Creating $CLAUDE_DIR..."
    mkdir -p "$CLAUDE_DIR"
fi

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

# Hooks — merge into existing settings.json (same relative position for both scopes)
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

# MCP servers — global: ~/.claude/.mcp.json; local: ./.mcp.json at project root
if [ "$LOCAL_INSTALL" = true ]; then
    MCP_DEST="$PROJECT_ROOT/.mcp.json"
else
    MCP_DEST="$CLAUDE_DIR/.mcp.json"
fi
if [ -f "$SCRIPT_DIR/mcp/mcp-servers.json" ]; then
    if [ -f "$MCP_DEST" ]; then
        cp "$MCP_DEST" "$MCP_DEST.backup.$(date +%Y%m%d%H%M%S)"
        echo "  BACKUP: $(basename "$MCP_DEST")"
    fi
    cp "$SCRIPT_DIR/mcp/mcp-servers.json" "$MCP_DEST"
    echo "  OK: MCP servers (4 servers configured)"
    echo ""
    echo "  NOTE: Edit $MCP_DEST and replace <YOUR_GITHUB_TOKEN>"
    echo "        with your GitHub personal access token."
fi

# CLAUDE.md — global: ~/.claude/CLAUDE.md from the personal template;
# local: ./CLAUDE.md at project root from the blank project template.
# Only install if not present either way.
if [ "$LOCAL_INSTALL" = true ]; then
    CLAUDE_MD_DEST="$PROJECT_ROOT/CLAUDE.md"
    CLAUDE_MD_SRC="$SCRIPT_DIR/examples/CLAUDE-TEMPLATE.md"
else
    CLAUDE_MD_DEST="$CLAUDE_DIR/CLAUDE.md"
    CLAUDE_MD_SRC="$SCRIPT_DIR/examples/CLAUDE.md"
fi
if [ ! -f "$CLAUDE_MD_DEST" ]; then
    if [ -f "$CLAUDE_MD_SRC" ]; then
        cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
        echo "  OK: CLAUDE.md (installed $(basename "$CLAUDE_MD_SRC") — customize it!)"
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
if [ "$LOCAL_INSTALL" = true ]; then
    echo "Installed project-locally in: $PROJECT_ROOT"
else
    echo "Installed globally in: $CLAUDE_DIR"
fi
echo ""
echo "Next steps:"
echo "  1. Customize $CLAUDE_MD_DEST with your preferences"
echo "  2. Add your GitHub token to $MCP_DEST"
echo "  3. Start Claude Code in any project and enjoy!"
