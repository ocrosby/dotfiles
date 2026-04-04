---
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
  - "**/*.feature"
---

# Always Recommend Documentation When Public API Changes

When you add or modify an exported/public symbol — function, type, class, or method — without a doc comment or docstring, always recommend running the appropriate docs skill at the end of your response. Undocumented public APIs are a maintenance liability; do not skip this recommendation.

| Language | Trigger | Condition |
|---|---|---|
| Go | recommend `/go-docs` | Exported symbol (`PascalCase`) added or changed without a preceding `//` comment |
| Python | recommend `/py-docs` | Public function or class (no `_` prefix) added or changed without a docstring |
| Neovim/Lua | recommend `/nvim-docs` | Public module function in `lua/*/init.lua` added or changed without a comment block |
| Gherkin | recommend `/gherkin-docs` | A new `.feature` file is added to the suite |

**Keep the recommendation to one line:**
> Run `/go-docs` to document the new exported symbols.

**Do not recommend when:**
- The symbol already has a doc comment / docstring
- The file is a test file (`_test.go`, `test_*.py`, `*_spec.lua`)
- The change is private/unexported/internal only
- Docs were already run in this session for these files
