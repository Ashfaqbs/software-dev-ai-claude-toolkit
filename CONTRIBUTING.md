# Contributing

This toolkit grows by adding more rules, commands, agents, and skills — for stacks and workflows it doesn't cover yet. Contributions are welcome.

## Before You Start

- Check open issues and existing files first — avoid duplicating a rule/skill/command that already exists under a different name.
- One component per PR (one new rule, one new skill, etc.). Keep PRs focused and reviewable.
- Match the tone and structure of the existing files in the same directory — skim two or three neighbors before writing a new one.

## Adding a Rule

Rules go in `rules/*.md` and are always-on instructions Claude follows every response.

- Keep it to one technology/domain per file (see `rules/java-springboot.md` for scope).
- Use short, imperative bullet points, not prose paragraphs.
- Prefer concrete conventions ("Use constructor injection") over vague advice ("Write clean code").
- Update `README.md`'s Rules table and `toolkit-manifest.json` to list the new file.

## Adding a Slash Command

Commands go in `commands/*.md` and are on-demand workflows invoked as `/command-name`.

- Name the file after the command: `commands/my-command.md` becomes `/my-command`.
- Describe the exact steps Claude should take when invoked, in order.
- Include a short example of expected input/output, matching the style under "Example: Using `/plan`" in the README.
- Update `README.md`'s Slash Commands table and `toolkit-manifest.json`.

## Adding an Agent

Agents go in `agents/*.md` and define a specialized persona with its own scope and reasoning depth.

- State clearly what the agent does and does NOT do (e.g., `planner` never writes code).
- Note the recommended model (Sonnet for most, Opus for deeper analysis like security/architecture review) if relevant.
- Update `README.md`'s Agents table and `toolkit-manifest.json`.

## Adding a Skill

Skills go in `skills/<skill-name>/` as a domain knowledge pack that loads contextually.

- Pick a name that describes the domain, not the technology alone (`springboot-security`, not `spring2`).
- Cover concrete patterns and examples, not a restatement of official docs.
- Update `README.md`'s Skills table and `toolkit-manifest.json`.

## Testing Your Change

Before opening a PR:
1. Run `./install.sh` (or `.\install.ps1` on Windows) against a scratch `~/.claude/` directory (or a temp `HOME`) to confirm the installer still copies your new file without errors.
2. Open a fresh Claude Code session and confirm the new rule/command/agent/skill actually loads and behaves as described.

## Pull Request Checklist

- [ ] One logical component added or changed
- [ ] README tables updated (component list + count)
- [ ] `toolkit-manifest.json` updated
- [ ] Installer tested locally
- [ ] No unrelated file changes
