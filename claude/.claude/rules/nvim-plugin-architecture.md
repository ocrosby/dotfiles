---
paths:
  - "**/*.lua"
---

# Neovim Plugin Architecture

## Structure

Every plugin follows this layout:

```
plugin-name/
├── lua/plugin-name/
│   ├── init.lua        -- setup(opts), public API
│   ├── config.lua      -- defaults, schema, merge logic
│   ├── commands.lua    -- user command registration
│   ├── keymaps.lua     -- keymap registration
│   ├── autocmds.lua    -- autocommand setup
│   ├── highlights.lua  -- highlight group definitions
│   └── core/           -- domain logic (no vim.api imports)
├── plugin/plugin-name.lua  -- bootstrap user commands
├── doc/plugin-name.txt     -- vimdoc help file
└── tests/
    ├── minimal_init.lua
    └── plugin-name/
```

## Module Responsibilities

- **init.lua**: exposes `setup(opts)` and the public API — delegates everything else
- **config.lua**: defines defaults, merges user options with `vim.tbl_deep_extend`, validates with `vim.validate`
- **commands.lua / keymaps.lua / autocmds.lua**: registration only — call into `init` or `core` for behavior
- **core/**: pure business logic with no `vim.api` imports — testable without a Neovim runtime

## Design Rules

- One module per concern — split when a file exceeds 300 lines
- `setup()` must be idempotent: clear augroups, guard re-registration, merge config cleanly
- No global state — use module-local tables returned by `require`
- Dependency direction flows inward: UI/commands → init → core
- Keep `plugin/` minimal — only bootstrap user commands so lazy-loading works
- Use `vim.validate` on all public function parameters
- Expose configuration schema as the single source of truth for options

## Lifecycle

- `plugin/plugin-name.lua` registers commands that lazy-trigger `require("plugin-name").setup()`
- `setup(opts)` merges config, registers keymaps/autocmds/highlights, and initializes state
- Teardown (if needed) clears the augroup and deletes user commands
