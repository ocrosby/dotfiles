# Skills

Skills are named workflows invoked by typing `/command` in a Claude Code session. Each skill is a Markdown file that defines a multi-step process Claude must follow — they enforce consistent, repeatable behavior for recurring tasks.

## File format

Each skill lives in its own subdirectory and is always named `SKILL.md`:

```
skills/
  ship/
    SKILL.md
  code-review/
    SKILL.md
```

```markdown
---
description: One-line summary of what this skill does.
triggers:
  - /skill-name
paths:
  - "**/*.go"
---

# Skill Title

Prose and workflow steps here.
```

### Frontmatter fields

| Field | Required | Description |
|---|---|---|
| `description` | Yes | Shown in skill listings; used by Claude to decide which skill fits a task |
| `triggers` | Conditional | Slash commands that invoke this skill (e.g. `/ship`) |
| `paths` | Conditional | Glob patterns — skill fires automatically when matching files are in context |

At least one of `triggers` or `paths` must be present. A skill with neither is unreachable.

## When to use a skill vs. a rule vs. a hook

| Mechanism | Best for |
|---|---|
| **Skill** | Multi-step workflows invoked on demand (`/ship`, `/code-review`, `/refactor`) |
| **Rule** | Always-on behavioral constraints that apply every session without being called |
| **Hook** | Guaranteed enforcement at specific tool lifecycle events (before/after edit, commit, push) |

Skills are appropriate when a workflow has distinct steps that benefit from being made explicit, when the steps vary by context (language, flags), or when you want a named command users can invoke intentionally. They remind and guide — they do not block like hooks, and they are not always-on like rules.

## Writing a skill

Use `/skill-author` to create a new skill interactively — it walks through purpose definition, frontmatter, workflow authoring, and consistency checks.

### Language that holds

Use mandatory language in every workflow step. Advisory language drifts across sessions.

| Avoid | Use instead |
|---|---|
| "consider running tests" | "run the test suite" |
| "you may want to lint" | "run the linter — if it fails, stop and do not proceed" |
| "should be a conventional commit" | "commit message must follow Conventional Commits format" |

### Structure that works

- Number every step — order matters
- Each step is a concrete action, not a principle
- Include a verification step near the end
- Define hard-stop conditions explicitly: "if tests fail, stop and report — do not proceed"
- Define exceptions with literal examples, not vague category names

## Existing skills

### Development workflow

| Command | Skill | Description |
|---|---|---|
| `/ship` | `ship` | Creates a branch, commits, pushes, and opens a PR. Supports `-m` (direct to main) and `-p` (patch release) |
| `/sync` | `sync` | Rebases the current feature branch onto the latest main |
| `/main` | `main` | Checks out main and pulls the latest from remote |
| `/release-notes` | `release-notes` | Generates a changelog from conventional commits since the last tag |

### Code quality

| Command | Skill | Description |
|---|---|---|
| `/code-review` | `code-review` | Structured review delegating to language-specialist agents. Supports `-f` (fix) and `-fc` (fix + loop until clean) |
| `/refactor` | `refactor` | Structural refactoring of Go, Python, or Neovim code without changing behavior |
| `/debug` | `debug` | Systematic bug triage across Go, Python, Neovim, and Gherkin |
| `/migrate` | `migrate` | Identifies and replaces deprecated patterns across supported languages |
| `/patterns` | `patterns` | Recommends applicable GoF design patterns with implementation sketches |

### Architecture & design

| Command | Skill | Description |
|---|---|---|
| `/architect` | `architect` | Delegates to the appropriate language-specialist architect agent |
| `/rest-review` | `rest-review` | Reviews HTTP handlers for REST convention compliance |
| `/tdd` | `test-driven-development` | Full TDD reference — red-green-refactor cycle, tooling, and anti-patterns |

### Language-specific features

| Command | Skill | Description |
|---|---|---|
| `/go-feature` | `go-feature` | Guides new Go feature development following clean architecture patterns |
| `/py-feature` | `py-feature` | Guides new Python feature development following hexagonal architecture |
| `/nvim-feature` | `nvim-feature` | Guides new Neovim plugin feature development using idiomatic Lua |
| `/rest-feature` | `rest-feature` | Guides new REST endpoint development following OpenAPI-first design |
| `/gherkin-feature` | `gherkin-feature` | Guides writing new Gherkin feature files following BDD best practices |

### Documentation

| Command | Skill | Description |
|---|---|---|
| `/docs` | `docs` | Generates and audits documentation, routing to the appropriate language specialist |
| `/go-docs` | `go-docs` | Generates and audits Go package documentation following godoc conventions |
| `/py-docs` | `py-docs` | Generates and audits Python documentation following Google-style docstring conventions |
| `/nvim-docs` | `nvim-docs` | Generates Neovim plugin documentation in vimdoc format |
| `/gherkin-docs` | `gherkin-docs` | Generates living documentation from Gherkin feature files |
| `/doc-review` | `doc-review` | Reviews documentation against Write the Docs principles |

### Benchmarking

| Command | Skill | Description |
|---|---|---|
| `/bench` | `bench` | Routes to the appropriate language-specialist bench skill |
| `/go-bench` | `go-bench` | Writes, runs, and analyzes Go benchmarks |
| `/py-bench` | `py-bench` | Writes, runs, and analyzes Python benchmarks |
| `/nvim-bench` | `nvim-bench` | Writes, runs, and analyzes Neovim plugin benchmarks |

### Claude configuration

| Command | Skill | Description |
|---|---|---|
| `/audit` | `audit` | Audits the Claude workflow system and reports issues by category and impact |
| `/skill-author` | `skill-author` | Guides creation of a new skill from scratch |
| `/skill-audit` | `skill-audit` | Audits all skill files for quality, durability, and consistency |
| `/skill-gaps` | `skill-gaps` | Analyzes session history to find repeating tasks with no skill coverage |

### Utilities

| Command | Skill | Description |
|---|---|---|
| `/dir` | `dir` | Reports the current working directory with project context and git status |
| `/here-now` | `here-now` | Researches a topic using live sources and publishes a structured report |
