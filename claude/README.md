# Claude Code Configuration

This stow package manages global Claude Code configuration files symlinked into `~/.claude/`.

## Installation

```bash
cd ~/dotfiles && stow claude
```

This symlinks `claude/.claude/` into `~/.claude/`, making all rules, skills, and agents available globally.

## When to Use What

### Rules (`rules/`)

Use a rule when you want Claude to **always follow a convention** without being asked.

- Loaded automatically at session start (or when a matching file enters context if `paths:` is set)
- Best for: coding standards, commit formats, naming conventions, style guides
- Think of rules as "background instructions" — they shape behavior passively

### Skills (`skills/`)

Use a skill when you have a **repeatable workflow** you want to invoke on demand with `/skill-name`.

- Each skill is a directory with a `SKILL.md` and optional supporting files
- Best for: code review checklists, deployment workflows, PR templates, scaffolding
- Can accept arguments (e.g., `/deploy staging`)
- Can be restricted to user-only invocation with `disable-model-invocation: true`

### Agents (`agents/`)

Use an agent when a task needs **isolation** — its own context window, restricted tools, or a different model.

- Runs in a separate context window from your main session
- Best for: code review (read-only), security audits, specialized analysis
- Use `tools:` frontmatter to restrict what the agent can do (e.g., read-only access)
- Invoked by Claude automatically based on `description`, or manually with `@agent-name`

### Commands (`commands/`)

Use a command when you want a **simple, single-file prompt** invoked with `/command-name`.

- Same as a skill but without supporting files — just one markdown file
- Best for: lightweight prompts that don't need bundled references
- Prefer skills for anything complex; commands are the simpler alternative

### Output Styles (`output-styles/`)

Use an output style when you want to **change how Claude responds** across an entire session.

- Appended to the system prompt at session start
- Best for: teaching mode, verbose explanations, terse responses, non-coding use cases
- Selected via `outputStyle` in `settings.json`

## Quick Reference

| I want Claude to... | Use a... |
|---|---|
| Always follow a convention | Rule |
| Run a workflow when I ask | Skill |
| Delegate a task with restricted access | Agent |
| Run a simple prompt when I ask | Command |
| Change its response style globally | Output Style |

## Current Configuration

### Rules

| Rule | Scope | Description |
|---|---|---|
| `conventional-commits.md` | `**` | Enforces Conventional Commits with Angular types (`feat`, `fix`, `docs`, etc.) |
| **Python** | | |
| `py-conventions.md` | `**/*.py`, `**/pyproject.toml`, `**/uv.lock` | Core standards: DRY/SOLID/CLEAN, GoF patterns, DI, type hints, pytest, uv, click, hexagonal architecture, FastAPI, FastMCP |
| `py-project-architecture.md` | `**/*.py`, `**/pyproject.toml` | Project structure: hexagonal layout, module responsibilities, design rules |
| `py-docs.md` | `**/*.py`, `**/docs/**/*.md` | Google-style docstrings, README requirements, API documentation |
| `py-testing.md` | `**/tests/**/*.py`, `**/test_*.py`, `**/conftest.py` | pytest conventions: structure, fixtures, FastAPI TestClient, anti-patterns |
| **Go** | | |
| `go-conventions.md` | `**/*.go`, `**/go.mod`, `**/go.sum` | Core standards: error handling, interfaces, naming, concurrency, idiomatic patterns |
| `go-project-architecture.md` | `**/*.go`, `**/go.mod` | Project structure: cmd/internal layout, module responsibilities, design rules |
| `go-docs.md` | `**/*.go` | Godoc conventions: doc comments, README requirements, API documentation |
| `go-testing.md` | `**/*_test.go`, `**/testdata/**` | stdlib testing: table-driven tests, fakes, httptest, anti-patterns |
| **Gherkin** | | |
| `gherkin-conventions.md` | `**/*.feature` | BDD standards: declarative steps, Given/When/Then, Scenario Outlines, tags, anti-patterns |
| `gherkin-structure.md` | `**/*.feature`, `**/steps/**`, `**/step_definitions/**` | Project structure: feature file organization, step definitions, hooks, support layer |
| `gherkin-testing.md` | `**/steps/**`, `**/step_definitions/**`, `**/features/**/*.{py,ts,rb,go}` | Step definition conventions: thin steps, page objects, assertions, anti-patterns |
| **Neovim** | | |
| `nvim-lua.md` | `**/*.lua` | Lua & Neovim API conventions: modern API usage, keymaps, autocommands, idiomatic Lua, error handling, performance |
| `nvim-plugin-architecture.md` | `**/*.lua` | Plugin structure: module layout, `setup()` patterns, dependency direction, lifecycle |
| `nvim-docs.md` | `**/doc/*.txt` | Vimdoc format: sections, tags, references, formatting rules |
| `nvim-testing.md` | `**/tests/**/*.lua`, `**/*_spec.lua`, `**/minimal_init.lua` | Plugin testing with plenary.busted: structure, buffer helpers, anti-patterns |

### Skills

| Skill | Scope | Description |
|---|---|---|
| `test-driven-development/` | Auto-invoked | Enforces red-green-refactor TDD cycle. Bundles `testing-anti-patterns.md` as a reference |
| **Python** | | |
| `py-feature/` | `**/*.py` | Guides feature development — hexagonal architecture, FastAPI, FastMCP |
| `py-migrate/` | `**/*.py` | Replaces outdated Python patterns with modern equivalents |
| `py-debug-checklist/` | `**/*.py` | Systematically triages and diagnoses Python application bugs |
| **Go** | | |
| `go-feature/` | `**/*.go` | Guides feature development — clean architecture, idiomatic Go |
| `go-migrate/` | `**/*.go` | Replaces deprecated Go patterns with modern equivalents |
| `go-debug-checklist/` | `**/*.go` | Systematically triages and diagnoses Go application bugs |
| **Gherkin** | | |
| `gherkin-feature/` | `**/*.feature` | Guides writing feature files and step definitions following BDD best practices |
| `gherkin-migrate/` | `**/*.feature` | Refactors anti-patterns: imperative steps, fat step definitions, scenario coupling |
| `gherkin-debug-checklist/` | `**/*.feature` | Triages and diagnoses BDD test failures |
| **Neovim** | | |
| `nvim-feature/` | `**/*.lua` | Guides Neovim plugin feature development — API usage, structure, keymaps, autocommands |
| `nvim-docs/` | `**/*.lua` | Generates plugin documentation in vimdoc format |
| `nvim-migrate-api/` | `**/*.lua` | Replaces deprecated Neovim API calls with modern equivalents |
| `nvim-debug-checklist/` | `**/*.lua` | Systematically triages and diagnoses Neovim plugin bugs |

### Agents

| Agent | Model | Tools | Description |
|---|---|---|---|
| **Python** | | | |
| `py-architect` | opus | Read, Grep, Glob | Designs application architecture — hexagonal layout, dependency graph, API surface |
| `py-debugger` | sonnet | Read, Grep, Glob, Bash | Diagnoses and fixes bugs — tracebacks, root cause analysis |
| `py-reviewer` | sonnet (plan) | Read, Grep, Glob | Reviews code for architecture, type safety, FastAPI patterns, idiomatic Python |
| **Go** | | | |
| `go-architect` | opus | Read, Grep, Glob | Designs application architecture — cmd/internal layout, dependency graph, API surface |
| `go-debugger` | sonnet | Read, Grep, Glob, Bash | Diagnoses and fixes bugs — panics, race conditions, goroutine leaks |
| `go-reviewer` | sonnet (plan) | Read, Grep, Glob | Reviews code for error handling, concurrency safety, idiomatic Go |
| **Gherkin** | | | |
| `gherkin-architect` | opus | Read, Grep, Glob | Designs BDD test architecture — feature organization, step structure, tag strategy |
| `gherkin-reviewer` | sonnet (plan) | Read, Grep, Glob | Reviews feature files for BDD best practices, declarative steps, maintainability |
| **Neovim** | | | |
| `nvim-architect` | opus | Read, Grep, Glob | Designs plugin architecture — module layout, dependency graph, public API surface |
| `nvim-debugger` | sonnet | Read, Grep, Glob, Bash | Diagnoses and fixes plugin bugs — root cause analysis, stack traces, state inspection |
| `nvim-reviewer` | sonnet (plan) | Read, Grep, Glob | Reviews plugin code for correctness, deprecated APIs, performance, idiomatic patterns |

## Naming Conventions

All language-specific components use a consistent prefix:

| Language | Prefix | Examples |
|---|---|---|
| Python | `py-` | `py-conventions`, `py-feature`, `py-architect` |
| Go | `go-` | `go-conventions`, `go-feature`, `go-architect` |
| Gherkin | `gherkin-` | `gherkin-conventions`, `gherkin-feature`, `gherkin-architect` |
| Neovim | `nvim-` | `nvim-lua`, `nvim-feature`, `nvim-architect` |

Each language follows the same component pattern:

| Component | Rules | Skills | Agents |
|---|---|---|---|
| Core conventions | `{prefix}-conventions` | — | — |
| Project architecture | `{prefix}-project-architecture` | — | `{prefix}-architect` |
| Documentation | `{prefix}-docs` | `{prefix}-docs` (nvim only) | — |
| Testing | `{prefix}-testing` | — | — |
| Feature development | — | `{prefix}-feature` | — |
| Migration/modernization | — | `{prefix}-migrate` / `{prefix}-migrate-api` | — |
| Debugging | — | `{prefix}-debug-checklist` | `{prefix}-debugger` |
| Code review | — | — | `{prefix}-reviewer` |

## References

- [Claude Code Documentation](https://code.claude.com/docs/en/overview) — Official Claude Code docs covering configuration, skills, rules, agents, and more
- [obra/superpowers](https://github.com/obra/superpowers) — Community collection of Claude Code skills, rules, and agents. The TDD skill was adapted from here.
