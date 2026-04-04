---
description: Systematically triages and diagnoses bugs across Go, Python, Neovim, and Gherkin.
triggers:
  - /debug
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
  - "**/*.feature"
---

# Bug Triage

## Workflow

### 1. Reproduce

- Get the exact steps, inputs, and environment to reproduce
- Identify: does it happen in tests? Locally? Only in production? Only in CI?
- Record runtime version, OS, and relevant dependency versions
- **Go:** check if it reproduces with `-race` flag
- **Neovim:** check if it reproduces with `nvim --clean` or a minimal config

### 2. Isolate

Write a minimal test case that reproduces the bug. Strip away unrelated code until the failure is isolated to one function, module, or scenario.

**Neovim — minimal reproduction config:**

```lua
-- minimal_repro.lua
vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro({
  spec = { { "plugin-author/plugin-name", opts = {} } },
})
```

Run with: `nvim -u minimal_repro.lua`

### 3. Escalate to Language Specialist

Once the failure is isolated, invoke the appropriate debugger agent for root cause analysis:

| Language | Agent |
|---|---|
| Go | `go-debugger` |
| Python | `py-debugger` |
| Neovim / Lua | `nvim-debugger` |
| Gherkin | `gherkin-debugger` |

The agent will identify the root cause, gather evidence, and propose a fix. Provide it the isolated reproduction case from step 2.

> **Quick reference** — use these tables for initial orientation before invoking the agent:

#### Go

| Symptom | Likely Cause |
|---|---|
| `nil pointer dereference` | Unchecked error return, nil receiver, uninitialized field |
| `data race detected` | Concurrent access without synchronization |
| `deadlock` | Goroutines waiting on each other, unbuffered channel with no reader |
| `context deadline exceeded` | Slow dependency, missing timeout propagation |
| Goroutine leak | Missing context cancellation, channel never closed |

#### Python

| Symptom | Likely Cause |
|---|---|
| `TypeError` / `AttributeError` | Wrong type passed, missing attribute, None propagation |
| Works locally, fails in CI | Environment difference — missing env var, Python version |
| 422 from FastAPI | Pydantic validation failure — check request body against model |
| 500 from FastAPI | Unhandled exception in route — check logs for traceback |

#### Neovim (Lua)

| Symptom | Likely Cause |
|---|---|
| `E5108: Error executing lua` | Lua runtime error — read the stack trace |
| Broke after Neovim update | Deprecated API removed — check `:h deprecated` |
| Slow / freezes | Synchronous operation on main loop or unthrottled `CursorMoved` |

#### Gherkin

| Symptom | Likely Cause |
|---|---|
| Step undefined | Missing step definition, typo in step text, wrong import |
| Passes alone, fails in suite | Scenario coupling — shared state leaking between scenarios |
| Passes locally, fails in CI | Environment difference — missing service, timing, browser version |

### 4. Verify the Fix

After the agent proposes a fix:

- Write a test that reproduces the bug **before** applying the fix
- Apply the fix and confirm the test passes
- Run the full test suite to confirm no regressions:
  - **Go:** `go test -race ./...`
  - **Python:** `pytest`
  - **Neovim:** full test suite + minimal repro config
  - **Gherkin:** scenario in isolation, then full suite
- Remove any debug logging added during diagnosis
