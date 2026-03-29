---
description: Identifies and replaces deprecated or outdated Go patterns with modern equivalents.
paths:
  - "**/*.go"
---

# Go Migration Guide

## Workflow

1. **Scan** the codebase for outdated patterns
2. **Identify** the modern replacement
3. **Replace** preserving behavior
4. **Verify** with `go test ./... -race`

## Common Migrations

### Error Handling

| Outdated | Modern |
|---|---|
| `errors.New` + type assertion | `errors.Is` / `errors.As` (Go 1.13+) |
| `fmt.Errorf("...: %s", err)` | `fmt.Errorf("...: %w", err)` (wrapping) |
| Manual error type switches | `errors.As(err, &target)` |

### Generics (Go 1.18+)

| Outdated | Modern |
|---|---|
| `interface{}` / `any` everywhere | Type parameters where they reduce duplication |
| `sort.Slice` with less func | `slices.SortFunc` (Go 1.21+) |
| Manual `Contains` loop | `slices.Contains` (Go 1.21+) |
| Manual map key collection | `maps.Keys` (Go 1.21+) |

### Stdlib Improvements

| Outdated | Modern |
|---|---|
| `log.Printf` | `log/slog` structured logging (Go 1.21+) |
| `ioutil.ReadAll` | `io.ReadAll` (Go 1.16+) |
| `ioutil.ReadFile` | `os.ReadFile` (Go 1.16+) |
| `ioutil.TempDir` | `os.MkdirTemp` (Go 1.16+) |
| `ioutil.TempFile` | `os.CreateTemp` (Go 1.16+) |
| `ioutil.WriteFile` | `os.WriteFile` (Go 1.16+) |
| `ioutil.ReadDir` | `os.ReadDir` (Go 1.16+) |
| `os.MkdirAll` + manual cleanup | `t.TempDir()` in tests |
| Manual HTTP mux routing | `http.NewServeMux` with patterns (Go 1.22+) |
| Third-party router for basic paths | `http.NewServeMux` method + path patterns (Go 1.22+) |

### Testing

| Outdated | Modern |
|---|---|
| `setUp/tearDown` functions | `t.Cleanup()` |
| Manual temp directories | `t.TempDir()` |
| No subtests | `t.Run("name", ...)` table-driven tests |
| Missing `t.Helper()` in helpers | Always call `t.Helper()` |
| `t.Errorf` + `return` | `t.Fatalf` for fatal failures |

### Context

| Outdated | Modern |
|---|---|
| Functions without context | `context.Context` as first param on I/O |
| `context.Background()` deep in code | Pass context from caller |
| `context.TODO()` left in production | Replace with proper context propagation |

### Module Management

| Outdated | Modern |
|---|---|
| `GOPATH` workspace | Go modules (`go.mod`) |
| `dep` / `glide` / `govendor` | `go mod tidy` |
| `go get` for building | `go install` for binaries (Go 1.16+) |

## Scan Patterns

Search for these to find outdated code:

- `ioutil.` — all functions deprecated since Go 1.16
- `interface{}` — consider `any` alias or generics
- `log.Printf`, `log.Println` — consider `slog`
- `context.TODO()` — should not be in production code
- `sort.Slice` — consider `slices.SortFunc`
