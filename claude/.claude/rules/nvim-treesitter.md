---
paths:
  - "**/*.lua"
  - "**/queries/**/*.scm"
---

# Neovim Treesitter

## Querying Nodes

Parse and execute queries with the `vim.treesitter.query` API:

```lua
local query = vim.treesitter.query.parse('lua', [[
  (function_declaration
    name: (identifier) @func.name
    body: (block) @func.body)
]])

local parser = vim.treesitter.get_parser(bufnr, 'lua')
local tree   = parser:parse()[1]
local root   = tree:root()

for id, node, metadata in query:iter_captures(root, bufnr, 0, -1) do
  local name = query.captures[id]
  local text = vim.treesitter.get_node_text(node, bufnr)
  -- process capture
end
```

- Use `iter_captures` when you need every captured node individually
- Use `iter_matches` when you need all captures from one pattern match together:

```lua
for pattern, match, metadata in query:iter_matches(root, bufnr, 0, -1) do
  local func_name = vim.treesitter.get_node_text(match[1], bufnr)
  local func_body = vim.treesitter.get_node_text(match[2], bufnr)
end
```

## Node Navigation

```lua
local node = vim.treesitter.get_node()         -- node at cursor
local node = vim.treesitter.get_node({ pos = { row, col } })

node:parent()                                   -- parent node
node:child(index)                               -- nth child
node:named_child(index)                         -- nth named child
node:child_count()                              -- total children
node:named_child_count()                        -- named children only
node:type()                                     -- node type string
node:range()                                    -- start_row, start_col, end_row, end_col
node:is_named()                                 -- false for punctuation/keywords
```

Walk ancestors to find a containing node of a specific type:

```lua
local function find_ancestor(node, type_name)
  local current = node
  while current do
    if current:type() == type_name then return current end
    current = current:parent()
  end
end
```

## Custom Query Files

Place query files under `queries/<lang>/` in your config or plugin root.
Neovim auto-discovers them from `runtimepath`:

```
queries/
├── lua/
│   ├── highlights.scm   -- highlight captures
│   ├── injections.scm   -- embedded language injections
│   ├── textobjects.scm  -- custom text objects
│   └── locals.scm       -- scope/reference tracking
```

Extend built-in queries (rather than replace) with `;extends` at the top of the file:

```scheme
; queries/lua/textobjects.scm
; extends

(function_declaration) @function.outer
(function_declaration body: (block) @function.inner)
```

Without `;extends`, your file replaces the built-in query entirely.

## Parser Management

- Use `vim.treesitter.language.add('lang', { path = ... })` to register custom parsers
- Check parser availability before querying: `vim.treesitter.language.get_lang(filetype)`
- Don't call `vim.treesitter.start()` manually unless you are disabling the built-in
  highlighter — it starts automatically for installed parsers

## Getting Node Text

Always use `vim.treesitter.get_node_text(node, source)` — never compute text from
`node:range()` manually, as it handles multi-line nodes and encoding correctly:

```lua
-- Good
local text = vim.treesitter.get_node_text(node, bufnr)

-- Bad: fragile, ignores encoding
local sr, sc, er, ec = node:range()
local line = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, false)[1]
local text = line:sub(sc + 1, ec)
```

## Anti-Patterns

- Don't cache `vim.treesitter.get_node()` across async boundaries — the tree may reparse
- Don't call `parser:parse()` on every keystroke — use `CursorHold` or `vim.schedule`
- Don't write raw `.scm` query strings inline for anything longer than ~5 nodes — use a
  dedicated query file
- Don't use `vim.treesitter.query.get` expecting a fallback — it returns `nil` if the
  query doesn't exist; guard the result
