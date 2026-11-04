# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `--local`/`-Local`: install project-scoped (`./.claude/`, `./CLAUDE.md` from the blank project template, `./.mcp.json` at the repo root) instead of globally to `~/.claude`. Default (no flag) is still global, unchanged.
- `--ai=copilot`/`-Ai copilot`: flattens the selected rules (general + `--stacks`) into `.github/copilot-instructions.md` at the repo root for GitHub Copilot users, since Copilot has no equivalent to commands/agents/skills/hooks/MCP config in this toolkit's shape — those are explicitly skipped and reported, not silently dropped. Default remains `claude` (full install). `toolkit-manifest.json` documents both new dimensions under `installScopes` and `aiTargets`.
- Selective install: `toolkit-manifest.json` now tags every rule and skill with an `installGroup` (`general`, `java-springboot`, `python-fastapi`, `javascript-react`, `ai-ml`). `install.sh --stacks=<groups>` / `install.ps1 -Stacks <groups>` install only `general` plus the named groups, so a dev on a stack this toolkit doesn't ship rules for (Go, Rust, .NET, ...) can install just the stack-neutral core (commands, agents, general rules) and layer their own stack's rules/skills on top instead of inheriting Java/Python/JS-specific content. `--list` / `-ListGroups` shows available groups. Default (no flag) is unchanged — installs everything, exactly as before.
- `install.sh` path handling: converts script/install paths via `cygpath -m` before handing them to `node -e` when available, fixing a pre-existing crash when the installer is run under git-bash/MSYS on Windows (Node on native Windows can't resolve `/c/...`-style POSIX paths, and a raw `cygpath -w` backslash path corrupts when embedded in a JS string literal, e.g. `\t`).

### Fixed
- `mcp/mcp-servers.json` pointed `memory`, `sequential-thinking`, and `github` at nonexistent npm packages (`@anthropic/claude-memory-mcp`, `@anthropic/sequential-thinking-mcp`, `@anthropic/github-mcp`) — `npx` would 404 on all three. Switched to the real published packages under `@modelcontextprotocol/*`.
- `install.sh` / `install.ps1` still said "13 skill packs" after `kafka-patterns` was added, undercounting the actual 14 skills already reflected in `README.md` and `toolkit-manifest.json`.
- `README.md` Quick Install commands pointed to a nonexistent GitHub account (`AshfaqSy`) instead of the actual repo owner (`Ashfaqbs`), breaking `git clone` for anyone following the Mac/Linux or Windows install steps.
- `skills/postgres-patterns/SKILL.md` linked to a `database-reviewer` agent and a `clickhouse-io` skill that don't exist anywhere in this toolkit.

### Added
- `CONTRIBUTING.md` — component-by-component guide (rules, commands, agents, skills) for submitting new additions, plus a PR checklist.
- `toolkit-manifest.json` — machine-readable index of every rule, command, agent, skill, hook, and MCP server in the toolkit.
- README badges (license, component count, skill count, GitHub stars/forks) and a jump-navigation table of contents.
- `skills/kafka-patterns/SKILL.md` — Spring Kafka producer/consumer patterns, manual offset commits, idempotent consumers, and dead letter topics, deepening the Kafka conventions already in `rules/infra.md`.

## [1.0.0] - 2026-02-07

### Added
- Initial release: 9 rules, 8 slash commands, 5 agents, 13 skills, 4 hooks, 4 MCP servers, and 3 CLAUDE.md example templates.
- `install.sh` and `install.ps1` installers for Mac/Linux and Windows.
