---
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
---

# Suggest Documentation When Public API Changes

When you add or modify an exported/public symbol — function, type, class, or method — without a doc comment or docstring, suggest running the appropriate docs skill at the end of your response.

| Language | Trigger | Condition |
|---|---|---|
| Go | suggest `/go-docs` | Exported symbol (`PascalCase`) added or changed without a preceding `//` comment |
| Python | suggest `/py-docs` | Public function or class (no `_` prefix) added or changed without a docstring |
| Neovim/Lua | suggest `/nvim-docs` | Public module function in `lua/*/init.lua` added or changed without a comment block |

**Keep the suggestion to one line:**
> Consider running `/go-docs` to document the new exported symbols.

**Do not suggest when:**
- The symbol already has a doc comment / docstring
- The file is a test file (`_test.go`, `test_*.py`, `*_spec.lua`)
- The change is private/unexported/internal only
- Docs were already run in this session for these files
