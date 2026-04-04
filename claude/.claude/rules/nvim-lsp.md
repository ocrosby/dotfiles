---
paths:
  - "**/*.lua"
---

# Neovim LSP Configuration

## Native LSP Config (0.11+)

Neovim 0.11+ provides `vim.lsp.config` and `vim.lsp.enable` as the native alternative
to the `nvim-lspconfig` plugin. Prefer native config for new setups.

```lua
-- Global settings shared by all servers
vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Per-server overrides
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { checkThirdParty = false },
    },
  },
})

-- Enable a server (triggers when matching filetype is opened)
vim.lsp.enable('lua_ls')
```

Config files live in `lsp/<server-name>.lua` relative to the config root and are
auto-sourced — keep them declarative (no `vim.lsp.enable` calls inside them).

## Capabilities

Always merge editor capabilities with completion plugin capabilities:

```lua
local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('blink.cmp').get_lsp_capabilities()  -- or nvim-cmp equivalent
)
```

Pass via `vim.lsp.config('*', { capabilities = capabilities })`.

## LspAttach Autocmd

Prefer `LspAttach` autocmd over `on_attach` for buffer-local setup — it composess
better across multiple plugins and config files:

```lua
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('MyLspAttach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    -- Buffer-local keymaps
    local map = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    map('gd', vim.lsp.buf.definition, 'go to definition')
    map('K',  vim.lsp.buf.hover,      'hover documentation')

    -- Format on save (only if server supports it)
    if client and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
        end,
      })
    end
  end,
})
```

## Diagnostics

Configure diagnostics globally once, before any servers start:

```lua
vim.diagnostic.config({
  virtual_text    = { spacing = 4, prefix = '●' },
  signs           = { text = { ERROR = '', WARN = '', INFO = '', HINT = '' } },
  underline       = true,
  update_in_insert = false,
  severity_sort   = true,
  float           = { border = 'rounded', source = true },
})
```

- `update_in_insert = false` prevents diagnostic flicker while typing
- `severity_sort = true` ensures errors float to the top of location lists
- Never set `virtual_text` to a boolean when you need a prefix/spacing — use a table

## Format

- Use `vim.lsp.buf.format({ bufnr = bufnr, id = client.id })` — pin to a specific client
  when multiple servers attach to avoid ambiguous format calls
- Use `async = false` for format-on-save (ensures write happens after format completes)
- Provide a `filter` function when you want one server to format and others not to:

```lua
vim.lsp.buf.format({
  filter = function(c) return c.name == 'null-ls' end,
  bufnr = bufnr,
})
```

## Anti-Patterns

- Don't call `vim.lsp.enable` inside a lazy.nvim `config` function — let the file-based
  config in `lsp/` drive server setup
- Don't set `on_attach` in per-server config if you're already using `LspAttach` — pick one
- Don't call `vim.lsp.buf.*` without first checking the client supports the method:
  `client:supports_method('textDocument/hover')`
- Don't configure `vim.diagnostic.config` per-buffer — it is global; set it once in init
