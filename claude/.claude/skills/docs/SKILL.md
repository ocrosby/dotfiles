---
description: Generates and audits documentation for the current project by routing to the appropriate language-specialist docs skill.
triggers:
  - /docs
---

# Docs

## When to use this skill

- You want to generate documentation for public symbols in the current project
- You want to audit whether all public symbols have documentation
- You changed code and need to update affected documentation

Use this skill to detect the language from context and route to the appropriate language-specialist skill.

## Usage

```
/docs                   # detect language from context; document all undocumented public symbols
/docs <file-or-glob>    # document specific files
/docs --all             # document all public symbols in the project, not just undocumented ones
/docs go                # force Go docs
/docs py                # force Python docs
/docs nvim              # force Neovim/Lua docs
/docs gherkin           # force Gherkin docs
```

## Workflow

### 1. Detect the Language

If no language argument is given, infer from:
- File extensions in the changed files (`git diff --name-only HEAD`)
- Project markers at the root: `go.mod` → Go, `pyproject.toml` → Python, `*.rockspec` or `init.lua` in `lua/` → Neovim, `*.feature` → Gherkin
- If multiple language markers exist (polyglot project), ask the user which language to document unless an explicit language argument was passed
- Ask if still ambiguous after checking markers and changed files

### 2. Determine the Scope

| Argument | Scope |
|---|---|
| none | Files changed since last commit (`git diff --name-only HEAD`) |
| `<file-or-glob>` | The specified files only |
| `--all` | All source files in the project matching the language extension |

### 3. Route to the Docs Skill

| Language | Skill |
|---|---|
| Go (`.go`) | `/go-docs` |
| Python (`.py`) | `/py-docs` |
| Neovim / Lua (`.lua`) | `/nvim-docs` |
| Gherkin (`.feature`) | `/gherkin-docs` |

Pass the resolved scope to the language-specific skill.

### 4. Multi-Language Projects

If changed files span multiple languages, run each language's docs skill in turn. Report findings grouped by language.

## Rules

- When no files are in scope and no argument is provided, report that nothing is scoped. Always suggest `--all` as the next step.
- When a language argument conflicts with the detected file types, use the explicit argument and note the override
- Never modify documentation for unexported or private symbols. Each language-specific skill enforces its own public/private boundary — Go skips lowercase-starting symbols; Python skips `_` prefixed symbols. Never override those boundaries.
