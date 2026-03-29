---
description: Systematically triages and diagnoses bugs in Go applications.
paths:
  - "**/*.go"
---

# Go Bug Triage

## Triage Workflow

### 1. Reproduce

- Get the exact steps, inputs, and environment to reproduce
- Record Go version (`go version`), OS, and architecture
- Check if it reproduces with `-race` flag

### 2. Isolate

- Write a minimal test case that reproduces the bug
- Use `t.Run` to isolate the specific failing scenario
- Check if the issue is in domain logic, an adapter, or a dependency

### 3. Diagnose

#### Common failure modes

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

#### Diagnostic tools

```bash
# Race detector
go test -race ./...

# CPU/memory profiling
go test -cpuprofile=cpu.prof -memprofile=mem.prof -bench=.
go tool pprof cpu.prof

# Goroutine dump
curl http://localhost:6060/debug/pprof/goroutine?debug=2

# Build with debug info
go build -gcflags="all=-N -l" ./cmd/server
dlv debug ./cmd/server
```

```go
// Inline debugging
fmt.Printf("%+v\n", value)             // struct with field names
runtime.Stack(buf, true)                // goroutine stacks
debug.PrintStack()                      // current goroutine stack
```

### 4. Classify

- **Nil dereference**: unchecked return value — add error check or nil guard
- **Race condition**: concurrent access — add mutex, use channels, or restructure
- **Goroutine leak**: missing cancellation — propagate context, close channels
- **Logic error**: wrong condition or algorithm — fix and add table-driven test
- **Configuration**: wrong env var or flag — fix config parsing, validate at startup
- **Dependency**: bug in library — pin version, add workaround, file upstream issue

### 5. Fix and Verify

- Write a test that reproduces the bug **before** fixing it
- Fix the root cause, not the symptom
- Run `go test -race ./...` to confirm no regressions
- Verify the fix in the same environment where the bug was observed
