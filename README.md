# Software Dev AI Claude Toolkit
<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/362fbec4-a3f8-463e-aa98-11e50b895815" />

<div align="center">

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Components](https://img.shields.io/badge/components-46-brightgreen.svg)](#whats-inside)
[![Skills](https://img.shields.io/badge/skills-13-blueviolet.svg)](#skills-13-skill-packs)
[![Stars](https://img.shields.io/github/stars/Ashfaqbs/software-dev-ai-claude-toolkit?style=social)](https://github.com/Ashfaqbs/software-dev-ai-claude-toolkit)
[![Forks](https://img.shields.io/github/forks/Ashfaqbs/software-dev-ai-claude-toolkit?style=social)](https://github.com/Ashfaqbs/software-dev-ai-claude-toolkit/network/members)

[Quick Install](#quick-install) &bull; [What's Inside](#whats-inside) &bull; [Rules](#rules-9-files) &bull; [Commands](#slash-commands-8-commands) &bull; [Agents](#agents-5-agents) &bull; [Skills](#skills-13-skill-packs) &bull; [Contributing](CONTRIBUTING.md)

</div>

A production-ready Claude Code configuration for backend-heavy full-stack developers. Pre-configured rules, slash commands, agents, skills, hooks, and MCP servers — covering Java 17 + Spring Boot 3, Python 3.12 + FastAPI, JavaScript (Express.js + React), PostgreSQL, MongoDB, Redis, Kafka, Flink, Docker, Kubernetes, and AI/ML workflows.

Drop it in, run the installer, and Claude Code immediately understands your stack, enforces your standards, and works the way you work.

## Who This Is For

- Backend developers working with Java/Spring Boot, Python/FastAPI, or Node.js/Express
- Full-stack developers who also touch React frontends
- Engineers working with PostgreSQL, MongoDB, Redis, Kafka, or Flink
- Anyone building AI/ML pipelines (RAG, agents, MCP servers, vector databases)
- Developers who want Claude Code to follow real engineering standards, not generic defaults

## What's Inside

| Component | Count | What It Does |
|-----------|-------|--------------|
| **Rules** | 9 | Coding standards Claude follows on every response |
| **Slash Commands** | 8 | One-command workflows (`/plan`, `/tdd`, `/code-review`, etc.) |
| **Agents** | 5 | Specialized AI personas for planning, review, security, architecture, TDD |
| **Skills** | 13 | Deep domain knowledge packs (Spring Boot, Python, React, PostgreSQL, etc.) |
| **Hooks** | 4 | Automated guardrails that run before/after tool use |
| **MCP Servers** | 4 | External tool integrations (docs lookup, memory, reasoning, GitHub) |
| **Examples** | 3 | Ready-to-use CLAUDE.md templates for your projects |

**Total: 46 components** working together to make Claude Code act like a senior engineer on your team.

## Before vs After

### Before (vanilla Claude Code)
```
You: "Add a user registration endpoint"

Claude: *generates a basic endpoint with no validation, no error handling,
        uses field injection, no tests, hardcoded values, no consideration
        for your existing project patterns*
```

### After (with this toolkit)
```
You: "Add a user registration endpoint"

Claude: *reads your project's CLAUDE.md, follows your naming conventions,
        uses constructor injection, adds @Valid with proper DTOs, writes
        Flyway migration, includes unit + integration tests with Testcontainers,
        uses your custom exception hierarchy, follows your git commit format,
        and warns you about the missing rate limiter*
```

The difference is not magic — it's context. This toolkit gives Claude Code the same context you'd give a new developer joining your team.

---

## Quick Install

### Mac / Linux
```bash
git clone https://github.com/Ashfaqbs/software-dev-ai-claude-toolkit.git
cd software-dev-ai-claude-toolkit
chmod +x install.sh
./install.sh
```

### Windows (PowerShell)
```powershell
git clone https://github.com/Ashfaqbs/software-dev-ai-claude-toolkit.git
cd software-dev-ai-claude-toolkit
.\install.ps1
```

The installer:
- Copies all components to `~/.claude/`
- Backs up existing files before overwriting
- Merges hooks into your existing `settings.json`
- Skips `CLAUDE.md` if you already have one (won't overwrite your personal config)

### Manual Install

If you prefer to cherry-pick, copy individual folders to `~/.claude/`:

```
~/.claude/
  rules/        <- copy rules/*.md
  commands/     <- copy commands/*.md
  agents/       <- copy agents/*.md
  skills/       <- copy skills/*/
  settings.json <- merge hooks from hooks/settings.json
  .mcp.json     <- copy mcp/mcp-servers.json
  CLAUDE.md     <- copy examples/CLAUDE.md (customize it)
```

---

## Rules (9 files)

Rules are always-on instructions that Claude Code follows in every response. They live in `~/.claude/rules/` and are automatically loaded.

| File | Covers |
|------|--------|
| `coding-style.md` | Immutability, naming conventions, file organization, function design, error handling |
| `java-springboot.md` | Java 17 features, Spring Boot 3 standards, project structure, REST conventions, Redis, Kafka |
| `python-backend-ai.md` | FastAPI, Pydantic, SQLAlchemy 2.0, RAG pipelines, MCP/ADK agents, ML best practices |
| `javascript.md` | Express.js API patterns, React conventions, hooks, project structure |
| `databases.md` | PostgreSQL (migrations, indexes, UUIDs), MongoDB (embedding vs referencing), Redis (data structures, TTL, key naming) |
| `infra.md` | Docker (multi-stage builds), Kubernetes (probes, HPA, PDB), Kafka (topics, consumers, idempotency), Flink (state, checkpoints) |
| `git-workflow.md` | Conventional commits, branch strategy, PR process, what not to commit |
| `testing.md` | TDD workflow, 80% coverage target, JUnit/pytest/Jest patterns, test naming |
| `security.md` | Auth, secrets management, API security, data protection, container security |

### Example: What the Java Rule Does

When you ask Claude to write a Spring Boot service, it automatically:
- Uses Java 17 records for DTOs
- Applies constructor injection (no `@Autowired`)
- Uses `@ConfigurationProperties` with records (no `@Value`)
- Follows the correct package structure (`domain/`, `service/`, `controller/`, `dto/`)
- Adds `@Valid` on controller inputs
- Uses `@Transactional` on service methods
- Writes Flyway migrations instead of `ddl-auto`

No prompting needed. It just knows.

---

## Slash Commands (8 commands)

Slash commands are on-demand workflows you invoke with `/command-name` in Claude Code.

| Command | What It Does |
|---------|--------------|
| `/plan` | Creates a step-by-step implementation plan before writing code. Identifies affected files, risks, and complexity. |
| `/code-review` | Reviews uncommitted changes for security issues, code quality, and testing gaps. |
| `/tdd` | Drives test-driven development: RED (failing test) -> GREEN (minimal code) -> IMPROVE (refactor). |
| `/build-fix` | Incrementally fixes build errors one at a time until the build succeeds. |
| `/api-design` | Designs REST API endpoints with request/response schemas, error formats, and data models. |
| `/docker-setup` | Generates Dockerfile, docker-compose.yml, and .dockerignore by detecting your project stack. |
| `/system-design` | Walks through system design: requirements, architecture, data design, APIs, scaling, reliability. |
| `/db-schema` | Designs database schemas: identifies entities, picks the right DB, defines tables/collections, plans migrations. |

### Example: Using `/plan`

```
You: /plan Add order cancellation with inventory rollback

Claude:
## Implementation Plan: Order Cancellation

### Phase 1: Domain Changes
- Add `CANCELLED` to OrderStatus enum
- Add CancellationReason value object
- New Flyway migration V6__add_cancellation_fields.sql

### Phase 2: Service Layer
- OrderCancellationService with rollback logic
- InventoryService.rollback(orderId) method
- Kafka event: orders.order.cancelled

### Phase 3: API
- POST /api/v1/orders/{id}/cancel
- CancelOrderRequest record with reason field

### Phase 4: Tests
- Unit: cancellation service, inventory rollback
- Integration: full cancel flow with Testcontainers
- Edge cases: already cancelled, already shipped

### Risks
- Race condition: order shipped while cancellation in progress
- Partial rollback if inventory service fails mid-operation

### Estimated Complexity: Medium
Files affected: 8 | New files: 3 | Migration: Yes
```

---

## Agents (5 agents)

Agents are specialized AI personas with their own system prompts, tools, and reasoning models. They handle deeper analysis than slash commands.

| Agent | Model | What It Does |
|-------|-------|--------------|
| `planner` | Sonnet | Analyzes requirements, reads existing patterns, identifies files to change, produces phased implementation plans. Never writes code. |
| `code-reviewer` | Sonnet | Scans recent changes for bugs, logic errors, style violations, and stack-specific anti-patterns. Categorizes by severity. |
| `security-reviewer` | Opus | Checks code for hardcoded secrets, SQL injection, missing auth checks, XSS, CSRF, and stack-specific vulnerabilities. |
| `architect` | Opus | System design and architecture decisions. Analyzes options, explains trade-offs, recommends patterns for services and technology choices. |
| `tdd-guide` | Sonnet | TDD coach that ensures test-first development. Guides through RED/GREEN/IMPROVE cycles. Blocks implementation before tests exist. |

### How Agents Differ from Commands

Commands are scripts — they follow a fixed workflow. Agents are thinkers — they analyze your specific situation, adapt their approach, and provide nuanced feedback. Use commands for routine tasks, agents for decisions that need judgment.

---

## Skills (13 skill packs)

Skills are deep domain knowledge packs that activate contextually. When Claude detects you're working on a Spring Boot project, the relevant skills auto-load to provide patterns, examples, and best practices.

| Skill | Domain | What It Provides |
|-------|--------|-----------------|
| `springboot-patterns` | Java/Spring | REST API design, layered architecture, caching, async processing, logging patterns |
| `springboot-security` | Java/Spring | Auth/authz, validation, CSRF, secrets, security headers, rate limiting |
| `springboot-tdd` | Java/Spring | JUnit 5, Mockito, MockMvc, Testcontainers, JaCoCo coverage patterns |
| `java-coding-standards` | Java | Java 17 idioms, records, sealed classes, pattern matching, Optional usage |
| `jpa-patterns` | Java/DB | Entity design, relationships, query optimization, transactions, auditing, pagination |
| `postgres-patterns` | Database | Query optimization, schema design, indexing strategies, security best practices |
| `python-patterns` | Python | Pythonic idioms, PEP 8, type hints, dataclasses, best practices |
| `python-testing` | Python | pytest, TDD methodology, fixtures, mocking, parametrization, coverage |
| `frontend-patterns` | React/JS | React patterns, state management, performance optimization, UI best practices |
| `backend-patterns` | Node.js | API design, database optimization, server-side patterns for Express/Next.js |
| `iterative-retrieval` | AI/Agents | Progressive context retrieval for solving the subagent context problem in RAG systems |
| `eval-harness` | AI/Dev | Eval-driven development (EDD) framework — define success criteria before implementation |
| `security-review` | Security | Comprehensive security checklist: secrets, input validation, SQLi, XSS, CSRF, auth |

---

## Hooks (4 hooks)

Hooks are automated guardrails that run before or after Claude uses a tool. They catch mistakes in real-time without you having to remember to check.

### Pre-Tool Hooks (run before execution)

| Hook | Trigger | Action |
|------|---------|--------|
| Block dangerous commands | `git push --force`, `git reset --hard`, `rm -rf` | **Blocks execution** with error message |
| Git push reminder | Any `git push` | Warns to review changes first |

### Post-Tool Hooks (run after file edits)

| Hook | Trigger | Action |
|------|---------|--------|
| Java: System.out.println | Editing `.java` files | Warns and suggests SLF4J logger |
| Java: @Autowired | Editing `.java` files | Warns and suggests constructor injection |
| Python: print() | Editing `.py` files | Warns and suggests logging module |
| JS/TS: console.log | Editing `.js/.jsx/.ts/.tsx` files | Warns and suggests removing before commit |

These hooks run automatically. You don't invoke them — they protect you silently.

---

## MCP Servers (4 servers)

MCP (Model Context Protocol) servers extend Claude Code with external tool capabilities.

| Server | What It Does | Cost |
|--------|-------------|------|
| `context7` | Looks up library documentation. Resolves to latest docs instead of stale training data. | Free |
| `memory` | Persistent memory across sessions. Remembers project decisions, preferences, and context. | Free |
| `sequential-thinking` | Step-by-step reasoning for complex problems. System design, debugging, architecture decisions. | Free |
| `github` | GitHub integration — PRs, issues, repos, code search. | Free (needs token) |

### Setup

After installing, edit `~/.claude/.mcp.json` and replace `<YOUR_GITHUB_TOKEN>` with a [GitHub personal access token](https://github.com/settings/tokens) (if you want GitHub integration).

The other 3 servers work out of the box with no configuration.

---

## Examples (3 templates)

| File | What It Is |
|------|-----------|
| `examples/CLAUDE.md` | Global user-level config. Defines your preferences, tech stack, and links to rules. Install to `~/.claude/CLAUDE.md`. |
| `examples/CLAUDE-TEMPLATE.md` | Blank project-level template. Copy to your project root as `CLAUDE.md` and fill in the blanks. |
| `examples/sample-springboot-CLAUDE.md` | Filled-in example for a Spring Boot order management service. Shows what a good project CLAUDE.md looks like. |

### The CLAUDE.md System

Claude Code reads `CLAUDE.md` files at two levels:

1. **Global** (`~/.claude/CLAUDE.md`) — Your personal preferences, tech stack, coding style. Loaded for every project.
2. **Project** (`./CLAUDE.md` in project root) — Project-specific context: how to run, structure, key decisions, environment variables, what not to touch.

The global config tells Claude who you are. The project config tells Claude what you're working on. Together, they give Claude the full picture.

---

## How to Customize

### Add your own rules
Create a new `.md` file in `~/.claude/rules/`:
```markdown
# My Custom Rule

## Always
- Use tabs, not spaces
- Prefer composition over inheritance
```

### Add your own slash commands
Create a new `.md` file in `~/.claude/commands/`:
```markdown
# My Custom Command

When I invoke this command:
1. Do step one
2. Do step two
3. Return the result in this format
```

### Modify existing components
Every file is plain Markdown. Open it, edit it, save it. Changes take effect on the next Claude Code session.

### Remove components you don't need
Delete the file. If you don't use Python, remove `python-backend-ai.md` from rules and `python-patterns/` and `python-testing/` from skills.

---

## Repository Structure

```
software-dev-ai-claude-toolkit/
├── README.md
├── LICENSE                            # MIT
├── .gitignore
│
├── rules/                             # 9 always-on coding standards
│   ├── coding-style.md
│   ├── java-springboot.md
│   ├── python-backend-ai.md
│   ├── javascript.md
│   ├── databases.md
│   ├── infra.md
│   ├── git-workflow.md
│   ├── testing.md
│   └── security.md
│
├── commands/                          # 8 slash commands
│   ├── plan.md
│   ├── code-review.md
│   ├── tdd.md
│   ├── build-fix.md
│   ├── api-design.md
│   ├── docker-setup.md
│   ├── system-design.md
│   └── db-schema.md
│
├── agents/                            # 5 specialized AI agents
│   ├── planner.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── architect.md
│   └── tdd-guide.md
│
├── hooks/                             # Automated guardrails
│   └── settings.json
│
├── mcp/                               # MCP server configs
│   └── mcp-servers.json
│
├── skills/                            # 13 domain knowledge packs
│   ├── springboot-patterns/
│   ├── springboot-security/
│   ├── springboot-tdd/
│   ├── java-coding-standards/
│   ├── jpa-patterns/
│   ├── postgres-patterns/
│   ├── python-patterns/
│   ├── python-testing/
│   ├── frontend-patterns/
│   ├── backend-patterns/
│   ├── iterative-retrieval/
│   ├── eval-harness/
│   └── security-review/
│
├── examples/                          # Templates and examples
│   ├── CLAUDE.md
│   ├── CLAUDE-TEMPLATE.md
│   └── sample-springboot-CLAUDE.md
│
├── install.sh                         # Mac/Linux installer
└── install.ps1                        # Windows installer
```

---

## Contributing

New rules, commands, agents, or skills are welcome — especially for stacks not covered yet (Go, Rust, .NET, other frontend frameworks). See [CONTRIBUTING.md](CONTRIBUTING.md) for the format each component type follows and how to submit one.

## Credits

Built on patterns from:
- [everything-claude-code](https://github.com/anthropics/everything-claude-code) — Anthropic's official collection of Claude Code configurations, skills, and community patterns
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code) — Official docs for rules, commands, agents, hooks, MCP, and skills

## License

MIT — use it, fork it, modify it, share it.
