# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed
- `README.md` Quick Install commands pointed to a nonexistent GitHub account (`AshfaqSy`) instead of the actual repo owner (`Ashfaqbs`), breaking `git clone` for anyone following the Mac/Linux or Windows install steps.

### Added
- `CONTRIBUTING.md` — component-by-component guide (rules, commands, agents, skills) for submitting new additions, plus a PR checklist.
- `toolkit-manifest.json` — machine-readable index of every rule, command, agent, skill, hook, and MCP server in the toolkit.
- README badges (license, component count, skill count, GitHub stars/forks) and a jump-navigation table of contents.

## [1.0.0] - 2026-02-07

### Added
- Initial release: 9 rules, 8 slash commands, 5 agents, 13 skills, 4 hooks, 4 MCP servers, and 3 CLAUDE.md example templates.
- `install.sh` and `install.ps1` installers for Mac/Linux and Windows.
