---
description: Guides development of new Neovim plugin features using idiomatic Lua and the Neovim API.
paths:
  - "**/*.lua"
---

# Neovim Plugin Feature Development

## Workflow

### 1. Understand the Feature

- Clarify what the feature does from the user's perspective
- Identify which Neovim APIs are needed (`vim.api`, `vim.fn`, `vim.keymap`, `vim.treesitter`, etc.)
- Determine if the feature needs autocommands, user commands, keymaps, or highlights

### 2. Design the Interface

- Define the public API: functions the user or other modules will call
- Design configuration with sensible defaults using a `setup()` or `config` pattern
- Plan the command and keymap surface area — keep it minimal

### 3. Implement

- Use Neovim's Lua API (`vim.api.nvim_*`) over Vimscript wherever possible
- Prefer `vim.keymap.set` over `vim.api.nvim_set_keymap`
- Use `vim.api.nvim_create_autocmd` and `vim.api.nvim_create_augroup` for autocommands
- Use `vim.api.nvim_create_user_command` for user commands
- Use `vim.notify` for user-facing messages with appropriate log levels
- Namespace all autocommand groups to avoid collisions
- Guard against re-sourcing: make setup idempotent

### 4. Structure

- One module per concern: separate core logic, UI, commands, and config
- Entry point exposes `setup(opts)` that merges user config with defaults via `vim.tbl_deep_extend`
- Keep buffer-local and window-local state management explicit
- Use `vim.validate` for input validation on public functions

### 5. Keymaps

- Always use `vim.keymap.set` with a `desc` field for which-key discoverability
- Plugin keymaps use `<leader>` sub-groups to avoid conflicts with core mappings
- Set keymaps only in the modes where they make sense
- Use `buffer` option for buffer-local keymaps
- Follow Vim grammar: `]` for next, `[` for prev, `g` prefix for variants

### 6. Autocommands

- Every autocommand belongs to a group created with `vim.api.nvim_create_augroup("Name", { clear = true })`
- Always use `callback` (function) instead of `command` (string)
- Always include `desc` for debuggability
- Use `buffer` for buffer-local autocommands, `pattern` for global
- Use `once = true` for one-shot autocommands
- Debounce `CursorMoved`/`CursorMovedI` — prefer `CursorHold` when possible

### 7. Review Checklist

- [ ] No deprecated API calls (check `:h deprecated`)
- [ ] All keymaps use `vim.keymap.set` with `desc`
- [ ] Autocommand groups are namespaced and cleared on re-source
- [ ] User commands have `-nargs`, `-range`, `-complete` set appropriately
- [ ] `setup()` is idempotent
- [ ] No global state pollution — use module-local tables
