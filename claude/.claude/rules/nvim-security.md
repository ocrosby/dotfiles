---
paths:
  - "**/*.lua"
---

# Neovim Plugin Security

## Shell Command Execution

- Never pass user input or buffer content directly to `vim.fn.system()`, `io.popen()`, or `vim.fn.jobstart()` without sanitization
- Use argument lists instead of shell strings when spawning jobs:

```lua
-- Bad: shell injection risk
vim.fn.system("grep " .. user_input .. " " .. filepath)

-- Good: argument list, no shell interpretation
vim.fn.jobstart({ "grep", "--", user_input, filepath }, { ... })
```

- Validate and escape any dynamic values before passing to subprocess commands
- Prefer Neovim API operations (`:nvim_buf_get_lines`, `:nvim_exec_autocmds`) over shelling out

## Dynamic Code Execution

- Never pass user-controlled input to `vim.api.nvim_exec()` or `loadstring()` — these execute arbitrary Vimscript or Lua
- Treat any string sourced from a file, buffer, or user prompt as untrusted
- If executing dynamic expressions is required, use a strict allowlist of permitted values

## File Path Safety

- Validate file paths derived from buffer names or user input before I/O operations:

```lua
local function safe_path(base, user_path)
  local resolved = vim.fn.resolve(vim.fn.fnamemodify(user_path, ":p"))
  if resolved:sub(1, #base) ~= base then
    error("path traversal detected: " .. user_path)
  end
  return resolved
end
```

- Never write files to paths derived directly from untrusted input

## Global Variable Exposure

- Do not store sensitive data (tokens, credentials, session state) in global Vim variables (`vim.g.*`) — they are readable by any other plugin
- Use module-local Lua variables for sensitive state:

```lua
-- Bad: globally accessible
vim.g.myplugin_api_token = token

-- Good: module-local, not reachable by other plugins
local _api_token = token
```

## Network Requests

- If the plugin makes HTTP requests (via `curl` subprocess or Lua HTTP library), validate URLs before use
- Never forward raw buffer content or user input as HTTP request bodies without sanitization
- Treat all HTTP responses as untrusted — validate structure before using
