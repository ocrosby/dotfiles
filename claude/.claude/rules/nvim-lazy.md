---
paths:
  - "lua/plugins/**/*.lua"
  - "**/lazy/**/*.lua"
---

# lazy.nvim Plugin Manager

## Spec Structure

Every plugin spec lives in `lua/plugins/` as one file per plugin or logical group.
lazy.nvim auto-discovers all files returned by `{ import = 'plugins' }`.

```lua
-- lua/plugins/telescope.lua
return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'find files' },
    { '<leader>fg', '<cmd>Telescope live_grep<cr>',  desc = 'live grep' },
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = { layout_strategy = 'horizontal' },
  },
}
```

## `opts` vs `config`

- **`opts`** — preferred for plugins that expose a `setup(opts)` entry point. lazy.nvim
  calls `require('plugin').setup(opts)` automatically. Keep opts as plain data.
- **`config`** — use when setup requires logic (conditional settings, calling multiple
  functions, wiring autocommands). Receives `(_, opts)` — always pass `opts` through:

```lua
config = function(_, opts)
  require('plugin').setup(opts)
  -- additional wiring here
end,
```

Never use `config = true` and `opts` at the same time — pick one.

## Lazy-Loading Triggers

Order of preference (most to least specific):

| Trigger | Use when |
|---------|----------|
| `cmd`   | Plugin only needed when a user command is invoked |
| `ft`    | Plugin only needed for specific filetypes |
| `keys`  | Plugin only needed when a keymap is pressed |
| `event` | Plugin needed at a lifecycle event |

```lua
-- Good: load only when the command is run
{ 'plugin/name', cmd = { 'PluginCommand' } }

-- Good: load on specific filetypes
{ 'plugin/name', ft = { 'markdown', 'text' } }

-- Good: load on keymap press (key defined here, not in on_attach)
{ 'plugin/name', keys = { { '<leader>x', desc = 'do thing' } } }

-- Acceptable: VeryLazy defers to after UI is ready (not startup critical)
{ 'plugin/name', event = 'VeryLazy' }

-- Avoid unless truly needed at startup
{ 'plugin/name', lazy = false, priority = 1000 }  -- reserved for colorschemes
```

Avoid `InsertEnter` as a lazy trigger for completion plugins — it causes a noticeable
delay on first insert.

## Keys Specs

Key specs in a plugin spec serve dual purpose: they lazy-load the plugin AND define
the keymap. Keep them in the spec so the mapping and the plugin are co-located:

```lua
keys = {
  { '<leader>gs', function() require('plugin').action() end, desc = 'action description' },
  { '<leader>gS', mode = { 'n', 'v' }, '<cmd>PluginCmd<cr>', desc = 'visual action' },
},
```

- Always include `desc` — it surfaces in which-key
- Use function callbacks for mappings that need lazy `require`, not string commands

## `opts` Merging and Overrides

When extending a plugin spec (e.g., from a shared config or distro), use `opts` as a
function to merge rather than replace:

```lua
opts = function(_, defaults)
  return vim.tbl_deep_extend('force', defaults, {
    my_override = true,
  })
end,
```

## Dependencies

- List only direct dependencies — don't repeat transitive ones
- If a dependency is shared, define it as its own spec and let lazy.nvim deduplicate
- `{ 'nvim-lua/plenary.nvim', lazy = true }` for pure library dependencies

## Versioning

- Pin to a `tag` for stability in production configs: `tag = 'v1.2.3'`
- Use `branch = 'main'` only for plugins with no tag releases
- Omit `branch` entirely to track the default branch
- Never pin to a specific commit SHA unless debugging a regression

## Anti-Patterns

- Don't call `require('plugin')` at the top level of a spec file — it defeats lazy-loading
- Don't use `event = 'BufReadPost'` for everything — be as specific as possible
- Don't define keymaps both in `keys` spec and in `config/on_attach` — pick the spec
- Don't set `lazy = false` for anything other than colorschemes and core UI plugins
- Don't put plugin config logic in `init.lua` — it runs before Neovim is ready
