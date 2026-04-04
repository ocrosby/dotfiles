---
paths:
  - "lua/config/**/*.lua"
  - "init.lua"
---

# Neovim Personal Config Structure

## Directory Layout

```
~/.config/nvim/
├── init.lua                  -- bootstrap only: lazy.nvim setup + imports
├── lua/
│   ├── config/
│   │   ├── options.lua       -- vim.o / vim.opt settings
│   │   ├── keymaps.lua       -- non-plugin keymaps
│   │   ├── autocmds.lua      -- non-plugin autocommands
│   │   └── lazy.lua          -- lazy.nvim bootstrap and plugin loader
│   └── plugins/              -- one file per plugin or logical group
│       ├── colorscheme.lua
│       ├── lsp.lua
│       └── ...
├── lsp/                      -- native LSP server configs (0.11+)
│   ├── lua_ls.lua
│   └── ...
└── after/
    └── ftplugin/             -- filetype-specific overrides
        └── lua.lua
```

## init.lua

Keep `init.lua` as a bootstrap-only file — no options, no keymaps:

```lua
require('config.lazy')   -- sets up lazy.nvim and loads plugins
require('config.options')
require('config.keymaps')
require('config.autocmds')
```

## Options

Set options in `lua/config/options.lua` using `vim.opt` (returns a settable object,
supports `+=`, `-=` for list/set options) or `vim.o` for simple scalar options:

```lua
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = 'yes'
vim.opt.clipboard      = 'unnamedplus'
vim.opt.undofile       = true
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.completeopt    = { 'menu', 'menuone', 'noselect' }
```

- Use `vim.opt` (not `vim.o`) for list/set options so `+=` / `-=` work correctly
- Group by category with comments: appearance, search, editing, files, UI
- Never set options inside plugin `config` functions unless they are plugin-specific

## Keymaps

Non-plugin keymaps live in `lua/config/keymaps.lua`. Plugin keymaps belong in the
plugin spec (`keys = { ... }` in lazy.nvim) or in the `LspAttach` autocmd.

```lua
local map = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { silent = true }, opts or {}))
end

-- Navigation
map('n', '<C-h>', '<C-w>h', { desc = 'move to left window' })
map('n', '<C-l>', '<C-w>l', { desc = 'move to right window' })

-- Quality of life
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'diagnostic quickfix list' })
```

Always include `desc`. Never use `noremap` — `vim.keymap.set` uses `noremap` by default.

## Autocommands

Non-plugin autocommands live in `lua/config/autocmds.lua`. Every augroup must have a
unique name and `{ clear = true }` to prevent duplication on re-source:

```lua
local function augroup(name)
  return vim.api.nvim_create_augroup('my_' .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function() vim.hl.on_yank() end,
  desc = 'highlight yanked text',
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('restore_cursor'),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
  desc = 'restore cursor position',
})
```

## after/ftplugin

Use `after/ftplugin/<ft>.lua` for filetype-specific settings that override defaults.
Keep these minimal — only settings that genuinely differ per filetype:

```lua
-- after/ftplugin/go.lua
vim.opt_local.tabstop     = 4
vim.opt_local.shiftwidth  = 4
vim.opt_local.expandtab   = false
```

Avoid putting keymaps or autocommands in ftplugin files — use `LspAttach` or a
`FileType` autocmd with a guard instead.

## Anti-Patterns

- Don't use `vim.cmd` for setting options — use `vim.opt` / `vim.o`
- Don't require plugins in `options.lua` or `keymaps.lua` — they may not be loaded yet
- Don't define the same augroup in multiple files — consolidate or namespace carefully
- Don't use `vim.cmd("source ...")` to re-source config — restart or `:Lazy reload`
- Don't put plugin setup calls in `init.lua` — they belong in the plugin spec
