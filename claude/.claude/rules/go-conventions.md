---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go Conventions

## Principles

- Simplicity over cleverness — write boring, obvious code
- Accept interfaces, return structs
- Composition over inheritance — embed structs, don't simulate class hierarchies
- Dependency injection via constructor functions — pass dependencies in, never use globals
- Push side effects to the edges; keep core logic pure and testable
- Errors are values — handle them explicitly, never ignore

## Error Handling

- Always check returned errors — never `_ = doSomething()`
- Wrap errors with context: `fmt.Errorf("creating user: %w", err)`
- Use sentinel errors (`var ErrNotFound = errors.New(...)`) for expected conditions
- Use custom error types when the caller needs to inspect error details
- Return early on error — avoid deep nesting

## Interfaces

- Keep interfaces small — one or two methods
- Define interfaces where they are consumed, not where they are implemented
- Use `io.Reader`, `io.Writer`, `fmt.Stringer` and other stdlib interfaces where they fit
- Name single-method interfaces with the `-er` suffix: `Reader`, `Validator`, `Notifier`

## Naming

- Short, descriptive variable names — `r` for reader, `ctx` for context, `cfg` for config
- Avoid stuttering: `user.Name` not `user.UserName`
- Exported names are PascalCase, unexported are camelCase
- Package names are lowercase, single word — no underscores or mixedCaps
- Test helpers start with `test` or `new` in test files

## Concurrency

- Use goroutines and channels, not shared memory with mutexes (unless performance requires it)
- Always pass `context.Context` as the first parameter
- Use `errgroup` for concurrent work with error propagation
- Channels should have a clear owner — one goroutine creates, one closes
- Prevent goroutine leaks: ensure every goroutine has a termination path

## Idiomatic Go

- Use `struct{}` for signal-only channels
- Use `context.Context` for cancellation, deadlines, and request-scoped values
- Use `table-driven tests` for data variations
- Use `t.Helper()` in test helper functions
- Prefer `strings.Builder` for string concatenation
- Use `slices` and `maps` packages (Go 1.21+) over manual loops where they simplify
- Use structured logging (`log/slog`) over `log.Printf`

## Code Quality

- `go vet` and `staticcheck` for linting
- `gofumpt` for formatting
- `golangci-lint` as the meta-linter
- Functions ≤ 40 lines, cyclomatic complexity ≤ 10
- Files ≤ 500 lines; split when exceeded
