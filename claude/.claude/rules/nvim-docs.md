---
paths:
  - "**/doc/*.txt"
---

# Neovim Plugin Documentation

## Format

All plugin documentation uses vimdoc format. Files live in `doc/plugin-name.txt`.

## Required Sections

1. **Header** — `*plugin-name.txt*` with a one-line description
2. **Contents** — table of contents with `|tag|` references
3. **Introduction** — what the plugin does and why
4. **Setup** — complete `setup()` call with all defaults
5. **Configuration** — every option with type, default, and description
6. **Commands** — every user command with syntax and behavior
7. **API** — every public function with signature, parameters, return type, and example

Include Keymaps and Highlights sections only if the plugin defines them.

## Formatting Rules

- Section headers: ALL CAPS, preceded by `=` separator (78 chars wide)
- Subsection headers: Title Case, preceded by `-` separator (78 chars wide)
- Tags: `*plugin-name-section*` — right-aligned to column 78
- References: `|plugin-name-section|` — clickable links to tags
- Code blocks: `>lua` / `>vim` to open, `<` on its own line to close
- Line width: 78 characters max
- Last line: ` vim:tw=78:ts=8:ft=help:norl:` (modeline)

## Content Rules

- Every tag must be unique and follow `plugin-name-section` naming
- Every public function, command, and option must have its own tag
- Show real examples, not just signatures
- Run `:helptags doc/` after writing to regenerate the tags file
