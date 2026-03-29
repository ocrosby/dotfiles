---
description: Systematically triages and diagnoses bugs in Neovim plugins.
paths:
  - "**/*.lua"
---

# Neovim Bug Triage

## Triage Workflow

### 1. Reproduce

- Get the exact steps to reproduce, starting from `nvim --clean` or a minimal config
- Identify: does it happen with `--clean`? With only this plugin loaded? With other plugins?
- Record the Neovim version (`nvim --version`) and OS

### 2. Isolate

Create a minimal reproduction config:

```lua
-- minimal_repro.lua
vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
  spec = {
    { "plugin-author/plugin-name", opts = {} },
    -- only add dependencies required to reproduce
  },
})

-- Steps to reproduce after this point
```

Run with: `nvim -u minimal_repro.lua`

### 3. Diagnose

#### Common failure modes

| Symptom | Likely Cause |
|---|---|
| `E5108: Error executing lua` | Lua runtime error — read the stack trace |
| Feature works sometimes | Race condition or async callback ordering |
| Works in one buffer, not another | Buffer-local state or filetype condition |
| Works after `:e` / reload | Initialization timing — event fires before plugin loads |
| Broke after Neovim update | Deprecated API removed — check `:h deprecated` |
| Broke after plugin update | Check the plugin's changelog/commits |
| Slow / freezes | Synchronous operation on main loop or `CursorMoved` without debounce |

#### Diagnostic commands

```vim
:checkhealth              " Plugin health checks
:messages                 " Recent error/warning messages
:verbose map <key>        " Where a keymap was defined
:verbose set option?      " Where an option was last set
:au GroupName             " List autocommands in a group
:lua vim.print(value)     " Inspect any Lua value (Neovim 0.9+)
```

#### Inspect state

```lua
-- Buffer info
vim.bo[bufnr].filetype
vim.api.nvim_buf_get_name(bufnr)

-- Active LSP clients for a buffer
vim.lsp.get_clients({ buffer = bufnr })

-- Treesitter parser status
vim.treesitter.get_parser(bufnr):lang()

-- Loaded plugin modules
package.loaded["myplugin"]
```

### 4. Classify

Categorize the bug:

- **Configuration**: user misconfiguration or missing setup — fix docs or validate input
- **API misuse**: incorrect Neovim API usage — fix the call
- **Race condition**: async timing issue — add proper sequencing or guards
- **Deprecation**: removed API — replace with modern equivalent (use `/nvim-migrate-api`)
- **Upstream**: Neovim core or dependency bug — document workaround, file upstream issue
- **Edge case**: valid but unhandled input — add guard and test

### 5. Fix and Verify

- Write a test that reproduces the bug **before** fixing it (red-green-refactor)
- Fix the root cause, not the symptom
- Run the full test suite to confirm no regressions
- Test the fix in the minimal reproduction config

## Log-Based Debugging

When stack traces aren't enough:

```lua
-- Temporary debug logging
vim.notify(vim.inspect(value), vim.log.levels.DEBUG)

-- Write to a log file for async/complex flows
local log = io.open(vim.fn.stdpath("log") .. "/myplugin-debug.log", "a")
log:write(os.date() .. " " .. vim.inspect(value) .. "\n")
log:close()
```

Remove all debug logging before committing the fix.
