---
description: Identifies and replaces deprecated or outdated patterns across Go, Python, Neovim, and Gherkin.
triggers:
  - /migrate
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
  - "**/*.feature"
---

# Migrate

Use this skill to replace deprecated APIs, outdated idioms, and anti-patterns with current equivalents. This is distinct from `/refactor` (which improves design) — migration replaces specific known-bad patterns with known-good replacements. Behavior must be identical before and after.

## Scope

`/migrate` operates in two modes depending on context:

**File-level** — when invoked mid-task after spotting a deprecated pattern in a specific file:
1. Replace the deprecated pattern(s) in that file only
2. Verify with the appropriate test command
3. Do not expand to the rest of the codebase unless explicitly asked

**Codebase-level** — when invoked standalone to modernize an entire project:
1. Scan the full codebase for outdated patterns (use the scan patterns below)
2. Identify the modern replacement for each hit
3. Replace preserving behavior exactly
4. Verify with the appropriate test command

If invoked without a specific file context, default to codebase-level. If invoked while already working on a file, default to file-level and ask before expanding scope.

## Workflow (codebase-level)

1. **Scan** the codebase for outdated patterns (use the scan patterns below)
2. **Identify** the modern replacement for each hit
3. **Replace** preserving behavior exactly
4. **Verify** with the appropriate test command

---

## Go

### Error Handling

| Outdated | Modern |
|---|---|
| `fmt.Errorf("...: %s", err)` | `fmt.Errorf("...: %w", err)` (wrapping) |
| Manual error type switches | `errors.Is` / `errors.As` (Go 1.13+) |

### Generics & Slices (Go 1.18–1.21+)

| Outdated | Modern |
|---|---|
| `interface{}` everywhere | `any` alias or type parameters where they reduce duplication |
| `sort.Slice` with less func | `slices.SortFunc` (Go 1.21+) |
| Manual `Contains` loop | `slices.Contains` (Go 1.21+) |
| Manual map key collection | `maps.Keys` (Go 1.21+) |

### Stdlib

| Outdated | Modern |
|---|---|
| `log.Printf` / `log.Println` | `log/slog` structured logging (Go 1.21+) |
| `ioutil.ReadAll` | `io.ReadAll` (Go 1.16+) |
| `ioutil.ReadFile` | `os.ReadFile` (Go 1.16+) |
| `ioutil.TempDir` | `os.MkdirTemp` (Go 1.16+) |
| `ioutil.TempFile` | `os.CreateTemp` (Go 1.16+) |
| `ioutil.WriteFile` | `os.WriteFile` (Go 1.16+) |
| `ioutil.ReadDir` | `os.ReadDir` (Go 1.16+) |
| Manual HTTP mux routing | `http.NewServeMux` with method+path patterns (Go 1.22+) |

### Testing

| Outdated | Modern |
|---|---|
| Manual temp directories | `t.TempDir()` |
| No subtests | `t.Run("name", ...)` table-driven tests |
| Missing `t.Helper()` in helpers | Always call `t.Helper()` |
| `t.Errorf` + `return` | `t.Fatalf` for fatal failures |

### Context

| Outdated | Modern |
|---|---|
| Functions without context | `context.Context` as first param on all I/O methods |
| `context.Background()` deep in call stack | Pass context from the caller |
| `context.TODO()` in production | Replace with proper context propagation |

**Scan patterns:** `ioutil\.`, `interface\{\}`, `log\.Printf`, `context\.TODO()`, `sort\.Slice`

**Verify:** `go test ./... -race`

---

## Python

### Testing

| Outdated | Modern |
|---|---|
| `unittest.TestCase` | Plain pytest functions |
| `unittest.mock.patch` | `pytest-mock` (`mocker.patch`) |
| `setUp` / `tearDown` | pytest fixtures |
| `self.assertEqual(a, b)` | `assert a == b` |
| `self.assertRaises(E)` | `pytest.raises(E)` |

### Type Hints (Python 3.10+)

| Outdated | Modern |
|---|---|
| `typing.List[int]` | `list[int]` |
| `typing.Dict[str, int]` | `dict[str, int]` |
| `typing.Optional[str]` | `str \| None` |
| `typing.Union[str, int]` | `str \| int` |
| `ABC` / `abstractmethod` | `Protocol` for structural subtyping |

### Package Management

| Outdated | Modern |
|---|---|
| `pip install` | `uv add` |
| `requirements.txt` | `pyproject.toml` + `uv.lock` |
| `setup.py` / `setup.cfg` | `pyproject.toml` |
| `virtualenv` / `venv` manual | `uv sync` |

### FastAPI

| Outdated | Modern |
|---|---|
| `@app.on_event("startup")` | `lifespan` context manager |
| `@app.on_event("shutdown")` | `lifespan` context manager |
| Returning `dict` from routes | Pydantic `response_model` |

### General

| Outdated | Modern |
|---|---|
| `os.path.join` | `pathlib.Path` |
| `"Hello %s" % name` | `f"Hello {name}"` |
| `"Hello {}".format(name)` | `f"Hello {name}"` |
| `type(x) == SomeType` | `isinstance(x, SomeType)` |

**Scan patterns:** `from typing import List, Dict, Optional, Union`, `unittest.TestCase`, `setup.py`, `@app.on_event`, `os.path.join`, `\.format(`

**Verify:** `pytest && ruff check .`

---

## Neovim (Lua)

### Keymaps

| Deprecated | Modern |
|---|---|
| `vim.api.nvim_set_keymap(mode, lhs, rhs, opts)` | `vim.keymap.set(mode, lhs, rhs, opts)` |
| `vim.api.nvim_del_keymap(mode, lhs)` | `vim.keymap.del(mode, lhs)` |
| `vim.api.nvim_buf_set_keymap(buf, ...)` | `vim.keymap.set(mode, lhs, rhs, { buffer = buf })` |

### Autocommands

| Deprecated | Modern |
|---|---|
| `vim.cmd("augroup ... autocmd! ... augroup END")` | `vim.api.nvim_create_augroup` + `vim.api.nvim_create_autocmd` |
| `vim.cmd("autocmd Event pattern cmd")` | `vim.api.nvim_create_autocmd(event, { pattern, callback })` |

### Options

| Deprecated | Modern |
|---|---|
| `vim.api.nvim_set_option("opt", val)` | `vim.o.opt = val` |
| `vim.api.nvim_buf_set_option(buf, "opt", val)` | `vim.bo[buf].opt = val` |
| `vim.api.nvim_win_set_option(win, "opt", val)` | `vim.wo[win].opt = val` |

### Highlights

| Deprecated | Modern |
|---|---|
| `vim.cmd("highlight MyHL guifg=#fff")` | `vim.api.nvim_set_hl(0, "MyHL", { fg = "#fff" })` |
| `vim.cmd("highlight link MyHL Other")` | `vim.api.nvim_set_hl(0, "MyHL", { link = "Other" })` |

### General

| Deprecated | Modern |
|---|---|
| `vim.cmd("command! Name ...")` | `vim.api.nvim_create_user_command("Name", fn, opts)` |
| `vim.api.nvim_command("cmd")` | `vim.cmd.cmd()` or `vim.cmd("cmd")` |
| `vim.lsp.buf_get_clients(bufnr)` | `vim.lsp.get_clients({ buffer = bufnr })` |
| `require("nvim-treesitter.ts_utils")` | `vim.treesitter` stdlib directly |

**Scan patterns:** `nvim_set_keymap`, `nvim_buf_set_keymap`, `nvim_set_option`, `vim.cmd("au`, `vim.cmd("hi`, `buf_get_clients`

**Verify:** Run `:checkhealth` after migration to catch remaining deprecation warnings. Always check the target Neovim version — some replacements require 0.7+, 0.8+, or 0.9+.

---

## Gherkin

### Imperative → Declarative Steps

| Before | After |
|---|---|
| `When I click "Name" field` / `And I type "Alice"` / `And I click "Submit"` | `When I register with name "Alice"` |
| `When I navigate to "/settings"` / `And I click "Delete Account"` / `And I confirm` | `When I delete my account` |
| `Given I open the browser` / `And I go to the login page` | `Given I am on the login page` |

### Scenario Coupling → Independent Scenarios

| Before | After |
|---|---|
| Scenario 2 depends on state created in Scenario 1 | Each scenario creates its own preconditions via Given |
| Shared module-level state between scenarios | State managed via World/context, reset in Before hook |

### Repetition → Scenario Outlines

| Before | After |
|---|---|
| 5 identical scenarios with different input values | One Scenario Outline with an Examples table |

### God Feature → Focused Features

| Before | After |
|---|---|
| `login.feature` with 25 scenarios | Split into `login_success.feature`, `login_failure.feature`, `login_lockout.feature` |

### Inconsistent Wording → Canonical Steps

| Before | After |
|---|---|
| `Given a user exists` / `Given there is a user` / `Given user was created` | Pick one canonical form |

**Scan patterns:** steps containing `click`, `type`, `navigate`, `field`, `button`; features with >10 scenarios; `sleep`/`wait` in step definitions; `When` appearing more than once in a scenario

**Verify:** Run all scenarios in isolation, then the full suite
