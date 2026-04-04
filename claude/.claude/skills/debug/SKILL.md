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

### 3. Diagnose

Route to the appropriate failure mode table based on the language/context:

---

#### Go

| Symptom | Likely Cause |
|---|---|
| `nil pointer dereference` | Unchecked error return, nil receiver, uninitialized field |
| `data race detected` | Concurrent access without synchronization |
| `deadlock` | Goroutines waiting on each other, unbuffered channel with no reader |
| `context deadline exceeded` | Slow dependency, missing timeout propagation |
| `connection refused` | Service down, wrong address, port conflict |
| Intermittent test failures | Race condition, test pollution, time-dependent logic |
| Goroutine leak | Missing context cancellation, channel never closed |
| OOM / high memory | Unbounded slice growth, unclosed readers, leaked goroutines |

```bash
go test -race ./...
go test -cpuprofile=cpu.prof -memprofile=mem.prof -bench=.
go tool pprof cpu.prof
curl http://localhost:6060/debug/pprof/goroutine?debug=2
```

```go
fmt.Printf("%+v\n", value)
runtime.Stack(buf, true)
debug.PrintStack()
```

---

#### Python

| Symptom | Likely Cause |
|---|---|
| `TypeError` / `AttributeError` | Wrong type passed, missing attribute, None propagation |
| `KeyError` / `IndexError` | Missing dict key, off-by-one, empty collection |
| `ImportError` / `ModuleNotFoundError` | Missing dependency, circular import, wrong package name |
| Works locally, fails in CI | Environment difference — missing env var, Python version, system dep |
| Intermittent failures | Race condition, shared mutable state, test pollution |
| Slow / hangs | Blocking I/O on async loop, missing `await`, N+1 queries |
| 422 from FastAPI | Pydantic validation failure — check request body against model |
| 500 from FastAPI | Unhandled exception in route — check logs for traceback |

```python
breakpoint()                          # drops into pdb
print(repr(value))                    # exact representation
type(value), dir(value)               # type and attributes
import traceback; traceback.print_stack()
```

---

#### Neovim (Lua)

| Symptom | Likely Cause |
|---|---|
| `E5108: Error executing lua` | Lua runtime error — read the stack trace |
| Feature works sometimes | Race condition or async callback ordering |
| Works in one buffer, not another | Buffer-local state or filetype condition |
| Works after `:e` / reload | Initialization timing — event fires before plugin loads |
| Broke after Neovim update | Deprecated API removed — check `:h deprecated` |
| Broke after plugin update | Check the plugin's changelog/commits |
| Slow / freezes | Synchronous operation on main loop or `CursorMoved` without debounce |

```vim
:checkhealth
:messages
:verbose map <key>
:verbose set option?
:au GroupName
:lua vim.print(value)
```

```lua
vim.notify(vim.inspect(value), vim.log.levels.DEBUG)
local log = io.open(vim.fn.stdpath("log") .. "/debug.log", "a")
log:write(os.date() .. " " .. vim.inspect(value) .. "\n")
log:close()
```

---

#### Gherkin

| Symptom | Likely Cause |
|---|---|
| Step undefined | Missing step definition, typo in step text, wrong import |
| Step ambiguous | Multiple step definitions match the same step text |
| Passes alone, fails in suite | Scenario coupling — shared state leaking between scenarios |
| Passes locally, fails in CI | Environment difference — missing service, timing, browser version |
| Timeout | Slow dependency, missing async handling, hardcoded wait too short |
| Wrong assertion | Step asserts on stale state, race condition |
| Data mismatch in Scenario Outline | Wrong column name, trailing whitespace in Examples table |

Check step matching:
- Verify the step text matches the regex/pattern in the step definition exactly
- Check parameter type mismatches (string vs int)
- Trace the World/context object through Given → When → Then
- Verify Before/After hooks are resetting state correctly

---

### 4. Classify

| Language | Category | Fix |
|---|---|---|
| Go | Nil dereference | Add error check or nil guard |
| Go | Race condition | Add mutex, use channels, or restructure |
| Go | Goroutine leak | Propagate context, close channels |
| Go | Logic error | Fix condition/algorithm, add table-driven test |
| Python | Type error | Add validation or fix the caller |
| Python | Logic error | Fix condition/algorithm, add regression test |
| Python | Configuration | Fix config, validate at startup |
| Python | Concurrency | Fix async/await usage |
| Neovim | API misuse | Fix the incorrect API call |
| Neovim | Race condition | Add proper sequencing or guards |
| Neovim | Deprecation | Replace with modern equivalent (use `/migrate`) |
| Gherkin | Step matching | Fix step text or regex |
| Gherkin | State leakage | Reset state in Before hooks |
| Gherkin | Timing | Add polling/retry instead of sleep |
| Any | Configuration | Fix config, validate at startup |
| Any | Dependency | Pin version, add workaround, file upstream issue |

### 5. Fix and Verify

- Write a test that reproduces the bug **before** fixing it
- Fix the root cause, not the symptom
- **Go:** run `go test -race ./...` to confirm no regressions
- **Python:** run `pytest` to confirm no regressions
- **Neovim:** run the full test suite and test in the minimal repro config
- **Gherkin:** run the scenario in isolation, then run the full suite
- Remove any debug logging added during diagnosis
