---
description: Generates Neovim plugin documentation in vimdoc format.
triggers:
  - /nvim-docs
paths:
  - "**/*.lua"
---

# Neovim Documentation Writer

## Vimdoc Format

All Neovim plugin documentation uses vimdoc format (`:help writing-help`). Documentation lives in `doc/plugin-name.txt` and is indexed by `:helptags`.

## Structure

Every help file follows this skeleton:

```vimdoc
*plugin-name.txt*  Short one-line description

Author: Name
License: MIT

==============================================================================
CONTENTS                                              *plugin-name-contents*

  1. Introduction .......................... |plugin-name-introduction|
  2. Setup ................................ |plugin-name-setup|
  3. Configuration ........................ |plugin-name-configuration|
  4. Commands ............................. |plugin-name-commands|
  5. Keymaps .............................. |plugin-name-keymaps|
  6. API .................................. |plugin-name-api|
  7. Highlights ........................... |plugin-name-highlights|

==============================================================================
INTRODUCTION                                      *plugin-name-introduction*

Description of what the plugin does and why.

==============================================================================
SETUP                                                    *plugin-name-setup*

>lua
  require("plugin-name").setup({
    -- default configuration shown here
  })
<

 vim:tw=78:ts=8:ft=help:norl:
```

## Rules

### Tags and references

- **Tags**: `*tag-name*` — defines a jump target (right-aligned or inline)
- **References**: `|tag-name|` — creates a clickable link to a tag
- Every section, command, function, and option must have a tag
- Tag naming: `plugin-name-section` (lowercase, hyphenated)

### Formatting

- Section headers: ALL CAPS, preceded by a separator line of `=` (78 chars)
- Subsection headers: Title Case, preceded by a separator line of `-` (78 chars)
- Code blocks: indent with `>lua` / `>vim` and close with `<` on its own line
- Column alignment: tags right-aligned to column 78
- Line width: 78 characters max
- Last line: ` vim:tw=78:ts=8:ft=help:norl:` (modeline)

### Content guidelines

- Document every public function with signature, parameters, return type, and example
- Document every user command with syntax, arguments, and behavior
- Document every configuration option with type, default value, and description
- Show a complete `setup()` call with all defaults so users can copy-paste and modify
- Include a highlights section if the plugin defines highlight groups

## Workflow

1. Read the plugin's public API, commands, keymaps, and config options
2. Generate the help file following the skeleton above
3. Include only sections that apply — omit empty sections
4. Run `:helptags doc/` to regenerate tags after writing
5. Verify all tags resolve: `:h plugin-name` should jump correctly
