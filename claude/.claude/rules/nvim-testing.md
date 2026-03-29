---
paths:
  - "**/tests/**/*.lua"
  - "**/*_spec.lua"
  - "**/minimal_init.lua"
---

# Neovim Plugin Testing

## Framework

- Use plenary.busted (`require("plenary.busted")`) as the default test framework
- Use mini.test when the plugin is part of the mini.nvim ecosystem or plenary is not a dependency

## Structure

```
tests/
├── minimal_init.lua        -- minimal Neovim config for test isolation
└── plugin-name/
    ├── module_spec.lua     -- one spec file per module
    └── helpers.lua         -- shared test utilities
```

### minimal_init.lua

```lua
vim.cmd([[set runtimepath+=.]])
vim.cmd([[runtime plugin/plenary.vim]])
```

Keep this as small as possible — only load what tests actually need.

## Running Tests

```bash
# All tests
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Single file
nvim --headless -c "PlenaryBustedFile tests/plugin-name/module_spec.lua"
```

## Writing Tests

- Test the public API, not internal helpers — internals can change freely
- One behavior per test, descriptive names: `it("returns nil when buffer is invalid")`
- Create isolated test buffers — never depend on editor state from other tests
- Clean up buffers, windows, and autocommands after each test
- Use `vim.fn.tempname()` for temp files, never hardcoded paths
- Test async operations with `vim.wait(timeout, predicate)`

## Buffer Helpers

```lua
local function create_buf(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(buf)
  return buf
end

local function delete_buf(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end
```

## Anti-Patterns

- Testing without `minimal_init.lua` — full user config contaminates results
- Asserting on mock internals instead of observable behavior
- Not cleaning up state between tests
- Skipping headless runs — tests must pass without a UI
- Mocking so heavily that the test validates mock wiring, not real logic
