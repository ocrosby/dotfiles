---
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
  - "**/*.feature"
---

# Suggest Migration When Deprecated Patterns Are Detected

When reading or writing code that contains deprecated or outdated patterns — as defined in the `/migrate` skill — always recommend running `/migrate` once at the end of your response. This targets the specific file being worked on (file-level mode), not the full codebase. The user can expand scope by running `/migrate` standalone.

## Triggers by language

**Go** — suggest `/migrate` when you see:
- `ioutil.` (any function — deprecated since Go 1.16)
- `interface{}` (use `any`)
- `log.Printf` / `log.Println` in a context where `slog` would be appropriate
- `context.TODO()` in production code (not test files)
- `sort.Slice` where `slices.SortFunc` applies

**Python** — suggest `/migrate` when you see:
- `from typing import List, Dict, Tuple, Optional, Union`
- `unittest.TestCase` or `unittest.mock`
- `@app.on_event("startup")` / `@app.on_event("shutdown")`
- `os.path.join` (use `pathlib.Path`)
- `setup.py` or bare `requirements.txt`

**Neovim/Lua** — suggest `/migrate` when you see:
- `nvim_set_keymap` or `nvim_buf_set_keymap`
- `nvim_set_option` / `nvim_buf_set_option` / `nvim_win_set_option`
- `vim.cmd("au` / `vim.cmd("autocmd`
- `vim.cmd("hi` / `vim.cmd("highlight`
- `buf_get_clients`

**Gherkin** — suggest `/migrate` when you see:
- Steps containing "click", "type", "navigate", "field", "button"
- Feature files with more than 10 scenarios
- `sleep` or `time.sleep` in step definitions
- Multiple `When` steps in a single scenario

**Keep the recommendation to one line:**
> This file contains deprecated patterns — run `/migrate` to modernize them.

**Do not recommend** when the file is already being migrated in the current session.
