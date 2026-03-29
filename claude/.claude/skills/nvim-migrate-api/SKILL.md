---
description: Identifies and replaces deprecated Neovim API calls with their modern equivalents.
paths:
  - "**/*.lua"
---

# Neovim API Modernizer

## Workflow

1. **Scan** the plugin for deprecated API usage
2. **Identify** the modern replacement for each deprecated call
3. **Replace** with the modern equivalent, preserving behavior
4. **Verify** no regressions by running tests

## Common Deprecations and Replacements

### Keymaps

| Deprecated | Modern |
|---|---|
| `vim.api.nvim_set_keymap(mode, lhs, rhs, opts)` | `vim.keymap.set(mode, lhs, rhs, opts)` |
| `vim.api.nvim_del_keymap(mode, lhs)` | `vim.keymap.del(mode, lhs)` |
| `vim.api.nvim_buf_set_keymap(buf, ...)` | `vim.keymap.set(mode, lhs, rhs, { buffer = buf })` |

### Autocommands

| Deprecated | Modern |
|---|---|
| `vim.cmd("augroup ... autocmd! ... augroup END")` | `vim.api.nvim_create_augroup` + `vim.api.nvim_create_autocmd` |
| `vim.cmd("autocmd Event pattern cmd")` | `vim.api.nvim_create_autocmd(event, { pattern, callback })` |
| `vim.cmd("doautocmd Event")` | `vim.api.nvim_exec_autocmds(event, opts)` |

### Options

| Deprecated | Modern |
|---|---|
| `vim.api.nvim_set_option("opt", val)` | `vim.o.opt = val` (global) |
| `vim.api.nvim_buf_set_option(buf, "opt", val)` | `vim.bo[buf].opt = val` |
| `vim.api.nvim_win_set_option(win, "opt", val)` | `vim.wo[win].opt = val` |
| `vim.api.nvim_get_option("opt")` | `vim.o.opt` |

### Highlights

| Deprecated | Modern |
|---|---|
| `vim.cmd("highlight MyHL guifg=#fff")` | `vim.api.nvim_set_hl(0, "MyHL", { fg = "#fff" })` |
| `vim.cmd("highlight link MyHL Other")` | `vim.api.nvim_set_hl(0, "MyHL", { link = "Other" })` |
| `vim.cmd("highlight clear MyHL")` | `vim.api.nvim_set_hl(0, "MyHL", {})` |

### Treesitter

| Deprecated | Modern |
|---|---|
| `require("nvim-treesitter.ts_utils")` | Use `vim.treesitter` stdlib directly |
| `vim.treesitter.get_node_text(node, 0)` | Pass the actual buffer number, not `0` |

### General

| Deprecated | Modern |
|---|---|
| `vim.cmd("command! Name ...")` | `vim.api.nvim_create_user_command("Name", fn, opts)` |
| `vim.fn.input("prompt")` | `vim.ui.input({ prompt = "prompt" }, callback)` for async |
| `vim.fn.confirm(...)` | `vim.ui.select(items, opts, callback)` for async |
| `vim.api.nvim_call_function("fn", args)` | `vim.fn.fn(args)` |
| `vim.api.nvim_command("cmd")` | `vim.cmd.cmd()` or `vim.cmd("cmd")` |
| `vim.lsp.buf_get_clients(bufnr)` | `vim.lsp.get_clients({ buffer = bufnr })` |

## Scan Commands

Use these patterns to find deprecated calls in a codebase:

- `nvim_set_keymap` / `nvim_buf_set_keymap` → keymap API
- `nvim_set_option` / `nvim_buf_set_option` / `nvim_win_set_option` → option accessors
- `vim.cmd("au` / `vim.cmd("autocmd` → autocommand API
- `vim.cmd("hi` / `vim.cmd("highlight` → highlight API
- `buf_get_clients` → LSP client API

## Notes

- Always check the target Neovim version — some replacements require Neovim 0.7+, 0.8+, or 0.9+
- When replacing `vim.cmd` string commands, ensure special characters are handled (escaping changes between string commands and Lua API)
- Run `:checkhealth` after modernization to catch remaining deprecation warnings
