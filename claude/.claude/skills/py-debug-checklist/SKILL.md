---
description: Systematically triages and diagnoses bugs in Python applications.
paths:
  - "**/*.py"
---

# Python Bug Triage

## Triage Workflow

### 1. Reproduce

- Get the exact steps, inputs, and environment to reproduce
- Identify: does it happen in tests? Locally? Only in production?
- Record Python version, OS, and relevant dependency versions

### 2. Isolate

- Write a minimal test case that reproduces the bug
- Strip away unrelated code until the failure is isolated to one function or module
- Check if the issue is in domain logic, an adapter, or a dependency

### 3. Diagnose

#### Common failure modes

| Symptom | Likely Cause |
|---|---|
| `TypeError` / `AttributeError` | Wrong type passed, missing attribute, None propagation |
| `KeyError` / `IndexError` | Missing dict key, off-by-one, empty collection |
| `ImportError` / `ModuleNotFoundError` | Missing dependency, circular import, wrong package name |
| Works locally, fails in CI | Environment difference — missing env var, different Python version, missing system dep |
| Intermittent failures | Race condition, shared mutable state, test pollution |
| Slow / hangs | Blocking I/O on async loop, missing `await`, unbounded iteration, N+1 queries |
| 422 from FastAPI | Pydantic validation failure — check request body against the model |
| 500 from FastAPI | Unhandled exception in route — check logs for traceback |

#### Diagnostic tools

```python
# Quick inspection
breakpoint()                          # drops into pdb/debugger
print(repr(value))                    # exact representation
type(value), dir(value)               # type and available attributes

# Structured logging
import logging
logger = logging.getLogger(__name__)
logger.debug("state: %s", vars(obj))

# Stack trace from running process
import traceback
traceback.print_stack()
```

### 4. Classify

- **Type error**: wrong type at a boundary — add validation or fix the caller
- **Logic error**: incorrect condition or algorithm — fix and add regression test
- **Configuration**: missing env var or wrong setting — fix config, validate at startup
- **Dependency**: bug in a library — pin version, add workaround, file upstream issue
- **Concurrency**: race condition or deadlock — add locks, fix async/await usage
- **Integration**: external service mismatch — update adapter, add contract test

### 5. Fix and Verify

- Write a test that reproduces the bug **before** fixing it
- Fix the root cause, not the symptom
- Run the full test suite to confirm no regressions
- Verify the fix in the same environment where the bug was observed
