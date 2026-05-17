# Rules

Rules are always-on behavioral constraints loaded into every Claude Code session. Unlike skills (invoked on demand) or hooks (triggered by tool events), rules apply continuously — they shape how Claude reasons and responds without being called explicitly.

## File format

Rules are plain Markdown files. Frontmatter is optional but enables path-scoped activation:

```markdown
---
description: One-line summary of what this rule enforces.
paths:
  - "**/*.go"
  - "**/go.mod"
---

# Rule Title

Rule content here — signal tables, mandatory behaviors, examples.
```

### Frontmatter fields

| Field | Required | Description |
|---|---|---|
| `description` | No | Shown in rule listings; helps identify what the rule covers |
| `paths` | No | Glob patterns — rule is only active when matching files are in context. Omit to apply in every session |

A rule with no `paths` is always active. A rule with `paths` only activates when those files are open or referenced.

## When to write a rule

Rules are appropriate when a behavior should apply **automatically and consistently** — not just when a user remembers to invoke a command.

| Write a rule when... | Write a skill instead when... |
|---|---|
| The behavior should apply every session without being triggered | The behavior is a multi-step workflow invoked on demand |
| You want Claude to recognize a pattern and respond to it | The workflow involves flags, arguments, or user choices |
| A constraint should never be bypassed by forgetting to ask | The user needs to opt in explicitly |

## Writing rules that hold

Rules written with advisory language drift across sessions — Claude interprets "consider" and "should" as optional. Use mandatory language.

| Drifts | Holds |
|---|---|
| "Consider running tests before shipping" | "Always run the test suite before committing. Do not proceed if tests fail." |
| "You should use parameterized queries" | "Never build SQL queries by string interpolation. Always use parameterized queries." |
| "Prefer dependency injection" | "Pass dependencies via constructor — never use globals. **This is an intentional design decision — do not simplify it away.**" |

Add a "don't revert" anchor with the reasoning for non-obvious constraints. Without a *why*, Claude will optimize the constraint away when it encounters complexity.

### Define exceptions with literal examples

Vague exception categories like "purely mechanical changes" are interpreted too broadly. Name the exact cases:

```
# Too broad — overused:
Exceptions: mechanical changes.

# Scoped correctly — stable:
Exceptions: renaming an identifier, moving a file to a different package, updating an import path.
If there is any change to logic, control flow, or observable behavior, it is not mechanical.
```

## Existing rules

### Session behavior

| File | Description |
|---|---|
| `session-startup.md` | Read `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, and `docs/*.md` at the start of every session |

### Code quality

| File | Description |
|---|---|
| `tdd.md` | Enforces test-driven development — red step required before implementation on `.go`, `.py`, `.lua` files |
| `review-on-implement.md` | Always recommend `/code-review` after implementing code changes |
| `feature-skeptic.md` | Pushback protocol for feature-add requests — forces ICP fit, displacement, and smallest-version questions before the first edit |
| `migrate-suggest.md` | Suggest `/migrate` when deprecated or outdated patterns are detected |

### Security

| File | Description |
|---|---|
| `owasp-top-10.md` | OWASP Top 10 recognition signals and mandatory behaviors — applies to all code touching auth, input, secrets, persistence, or network I/O |
| `go-security.md` | Go-specific security patterns — input validation, crypto, SQL, subprocess, TLS |
| `py-security.md` | Python-specific security patterns — deserialization, injection, secrets, dependency safety |
| `nvim-security.md` | Neovim plugin security — safe API usage, avoiding arbitrary code execution, sandboxing |

### Go

| File | Description |
|---|---|
| `go-conventions.md` | Idiomatic Go — naming, error handling, interfaces, dependency injection, package structure |
| `go-project-architecture.md` | Go project layout following clean architecture — cmd, internal, pkg boundaries |
| `go-testing.md` | Go testing conventions — table-driven tests, subtests, testify usage, race detector |
| `go-docs.md` | Go documentation conventions — godoc format, package comments, example functions |
| `go-workspace.md` | Go workspace conventions for monorepos using `go.work` — CI patterns, version sync, tooling compatibility |

### Python

| File | Description |
|---|---|
| `py-conventions.md` | Idiomatic Python — naming, type hints, error handling, dataclasses, module structure |
| `py-project-architecture.md` | Python project layout following hexagonal architecture — ports, adapters, domain boundaries |
| `py-testing.md` | Python testing conventions — pytest patterns, fixtures, parametrize, coverage |
| `py-docs.md` | Python documentation — Google-style docstrings, module docstrings, type annotations |

### Neovim / Lua

| File | Description |
|---|---|
| `nvim-lua.md` | Lua and Neovim API conventions — module structure, error handling, `vim.api` usage |
| `nvim-plugin-architecture.md` | Neovim plugin architecture — setup/config separation, lazy initialization, public API surface |
| `nvim-config.md` | Personal Neovim config structure — organizing `init.lua`, options, keymaps, and autocmds |
| `nvim-lazy.md` | lazy.nvim plugin manager conventions — spec format, lazy loading, dependency declaration |
| `nvim-lsp.md` | Neovim LSP configuration — `nvim-lspconfig` patterns, on_attach, capabilities |
| `nvim-treesitter.md` | Neovim Treesitter usage — parser setup, highlight groups, query conventions |
| `nvim-testing.md` | Neovim plugin testing — busted/plenary conventions, async tests, mock patterns |
| `nvim-docs.md` | Neovim plugin documentation — vimdoc format, help tag conventions |

### Gherkin / BDD

| File | Description |
|---|---|
| `gherkin-conventions.md` | Gherkin language conventions — Given/When/Then semantics, step granularity, scenario naming |
| `gherkin-structure.md` | Gherkin project structure — feature file organization, step definition layout, support files |
| `gherkin-testing.md` | Gherkin step definition testing — test isolation, state management, shared context patterns |

### Design & architecture

| File | Description |
|---|---|
| `design-patterns.md` | All 22 GoF patterns — intent, applicability, participants, pros/cons (reference catalog) |
| `design-patterns-application.md` | Pattern recognition signals and mandatory behaviors — when to apply each pattern in Go, Python, and Lua |
| `rest-api-conventions.md` | REST API conventions — resource naming, HTTP methods, status codes, statelessness, versioning |
| `sql-normalization.md` | Database normalization — normal forms, when to denormalize, indexing considerations |

### Documentation

| File | Description |
|---|---|
| `docs-principles.md` | Write the Docs principles — skimmable, exemplary, consistent, current; ARID guard, error message standards |
| `docs-suggest.md` | Always recommend documentation updates when a public API changes |

### Claude configuration

| File | Description |
|---|---|
| `skill-conventions.md` | Structural and language conventions when editing Claude skill files — mandatory language, numbered steps, hard-stop conditions |
| `readme-standard.md` | Enforces required sections, badge synchronization, and formatting in root `README.md` files |
| `readme-learnings.md` | Automatically documents new Claude configuration learnings in `README.md` and ships to main |
