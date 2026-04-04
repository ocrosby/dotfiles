---
description: Automatically documents new Claude configuration learnings in README.md and pushes to main
paths:
  - "**/*.md"
  - "**/*.sh"
  - "**/*.json"
---

# Document Claude Learnings in README.md

When a session produces a new insight about how Claude rules, skills, hooks, or agents work — or reveals a pattern that caused drift, cycles, or inconsistency — update `README.md` in the `.claude/` directory and push it to main.

## When to trigger this

A learning has occurred when any of these happen:

- A rule was changed because it was too soft, too vague, or contradicted another rule
- A hook or skill was found to not enforce what it claimed to enforce
- A contradiction between two files caused Claude to alternate between behaviors
- A new pattern was discovered that makes rules more durable (e.g., "always" vs "suggest")
- A specific configuration decision is made that future sessions might undo without context
- A language-specific practice (Go, Python, Lua) is found to work better than the previous approach

## What to write

Each entry should be placed under the appropriate section heading in `README.md`. Write it as a short, concrete lesson — not a description of what was changed, but what was learned and why it matters for future rule authoring.

Structure:
- **One sentence stating the lesson**
- Optional: a before/after example showing the drift pattern and the fix
- Optional: the specific consequence that prompted the change

Do not pad entries. If the lesson can be stated in one sentence, use one sentence.

## How to update

1. Read the current `README.md`
2. Add the new entry under the appropriate section (or create a new section if none fits)
3. Commit with: `docs(claude): add learning — <one-line summary>`
4. Push to main immediately — do not batch learnings across sessions

## Sections in README.md

- **Rule Authoring** — lessons about writing durable, enforceable rules
- **TDD Enforcement** — lessons about test-driven development consistency
- **Go-Specific** — Go tooling, patterns, and reviewer behavior
- **Python-Specific** — Python tooling, patterns, and reviewer behavior
- **Lua/Neovim-Specific** — Lua plugin conventions and reviewer behavior
- **Complexity** — code quality limits and their rationale
- **Concurrency (Go)** — goroutine, channel, and context patterns
- Add new sections when learnings don't fit existing ones
