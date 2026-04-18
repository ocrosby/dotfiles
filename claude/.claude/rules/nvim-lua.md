---
paths:
  - "**/*.lua"
---

# Lua & Neovim Conventions

## Neovim API

- Use `vim.keymap.set` for all keymaps — never `vim.api.nvim_set_keymap` or `nvim_buf_set_keymap`
- Use `vim.api.nvim_create_autocmd` and `vim.api.nvim_create_augroup` — never `vim.cmd("autocmd ...")`
- Use `vim.api.nvim_create_user_command` — never `vim.cmd("command! ...")`
- Use `vim.api.nvim_set_hl` for highlights — never `vim.cmd("highlight ...")`
- Use `vim.o`, `vim.bo[buf]`, `vim.wo[win]` for options — never `nvim_set_option`, `nvim_buf_set_option`, `nvim_win_set_option`
- Use `vim.lsp.get_clients()` — never `buf_get_clients()`
- Use `vim.fn.fn(args)` — never `vim.api.nvim_call_function`
- Use `vim.notify` with appropriate log levels for user-facing messages
- Use `vim.ui.input` and `vim.ui.select` for async user prompts
- Use `vim.ui.open(url_or_path)` (0.10+) to open URLs/files in the OS default handler
- Use `vim.hl.on_yank()` (0.11+) — never `vim.highlight.on_yank()` (deprecated)

## Keymaps

- Every `vim.keymap.set` must include a `desc` field for which-key discoverability
- Use function references as callbacks, not strings
- Use `{ buffer = bufnr }` for buffer-local keymaps
- Follow Vim grammar: `]` for next, `[` for prev, `g` prefix for variants
- Plugin keymaps use `<leader>` sub-groups; filetype keymaps use `<localleader>`

## Autocommands

- Every autocommand must belong to a group: `nvim_create_augroup("Name", { clear = true })`
- Always use `callback` (function), not `command` (string)
- Always include `desc`
- Use `buffer = bufnr` for buffer-scoped autocommands
- Use `once = true` for one-shot autocommands
- Debounce `CursorMoved` / `CursorMovedI` — prefer `CursorHold` when possible
- `BufEnter` callbacks must guard with early returns (filetype check, buffer validity)

## Idiomatic Lua

- Iterate directly over tables, never `for i = 1, #tbl` unless index arithmetic is needed
- Use `vim.iter()` (0.10+) for functional iteration over lists and tables — prefer it over
  `vim.tbl_map` / `vim.tbl_filter` when chaining operations:

  ```lua
  local names = vim.iter(items):filter(function(x) return x.active end):map(function(x) return x.name end):totable()
  ```
- Use `vim.tbl_deep_extend("force", defaults, opts)` for merging config tables
- Use `vim.tbl_contains` for membership checks
- Use `vim.inspect` for debug output, never string concatenation of tables
- Use `vim.validate` for input validation on public functions
- Prefer local variables — no globals unless explicitly required by Neovim's loader
- Cache `require()` results at module scope for hot paths

## Error Handling

- Wrap fallible external calls in `pcall` / `xpcall`
- Check buffer and window validity before access (`nvim_buf_is_valid`, `nvim_win_is_valid`)
- Use `vim.notify(msg, vim.log.levels.ERROR)` for user-facing errors

## Async Processes (0.10+)

Use `vim.system()` for subprocess calls — it is the modern replacement for
`vim.fn.system()` / `vim.fn.jobstart()`:

```lua
-- Async (preferred)
vim.system({ 'git', 'log', '--oneline' }, { text = true }, function(obj)
  if obj.code == 0 then
    vim.schedule(function() process(obj.stdout) end)
  end
end)

-- Sync (only when result is needed immediately and blocking is acceptable)
local obj = vim.system({ 'git', 'rev-parse', 'HEAD' }, { text = true }):wait()
```

- Always pass an argument list, never a shell string — avoids shell injection
- Use `{ text = true }` to get stdout/stderr as strings instead of byte arrays
- Callbacks run on a non-main thread — wrap any vim API calls in `vim.schedule()`

## libuv

Use `vim.uv` (0.10+, stable alias) — `vim.loop` is deprecated:

```lua
-- Good
vim.uv.fs_stat(path, function(err, stat) ... end)

-- Deprecated
vim.loop.fs_stat(path, function(err, stat) ... end)
```

## Documentation

- Every module, public function, and non-trivial private function gets a `---` LuaLS doc comment describing what it does
- Use `---@param`, `---@return`, and `---@field` annotations for type information

## Code Quality

- Functions ≤ 40 lines, cyclomatic complexity ≤ 7
- Files ≤ 500 lines; split into focused modules when exceeded

## Performance

- Never block the main loop with synchronous I/O or network calls
- Wrap expensive callbacks in `vim.schedule()` or `vim.defer_fn()`
- Avoid unnecessary `require()` in callbacks — resolve at module scope
