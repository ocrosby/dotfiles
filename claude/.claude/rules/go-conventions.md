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
- Design types so the zero value is useful without initialization (like `sync.Mutex`, `bytes.Buffer`)
- Do not communicate by sharing memory; share memory by communicating

## Error Handling

- Always check returned errors — never `_ = doSomething()`
- Wrap errors with context: `fmt.Errorf("creating user: %w", err)`
- Use sentinel errors (`var ErrNotFound = errors.New(...)`) for expected conditions
- Use custom error types when the caller needs to inspect error details
- Return early on error — avoid deep nesting
- Error strings should identify their origin with a prefix: `"image: unknown format"`
- Use `errors.As` / type assertions to inspect error details for recoverable failures
- `panic` only for truly unrecoverable situations (e.g., failed critical initialization)
- Real library functions should avoid `panic` — if it can be worked around, return an error
- Use `recover` only inside deferred functions to convert panics to errors at package boundaries

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
- Getters omit `Get`: `Owner()` not `GetOwner()`, setters use `Set`: `SetOwner()`
- Don't reuse canonical method names (`Read`, `Write`, `Close`, `String`) unless the signature and meaning match
- When the package exports a single primary type, name the constructor `New` (e.g., `ring.New`), otherwise `NewTypeName`
- MixedCaps or mixedCaps for multi-word names — never underscores

## Concurrency

- Use goroutines and channels, not shared memory with mutexes (unless performance requires it)
- Always pass `context.Context` as the first parameter
- Use `errgroup` for concurrent work with error propagation
- Channels should have a clear owner — one goroutine creates, one closes
- Prevent goroutine leaks: ensure every goroutine has a termination path
- Prefer a fixed worker pool reading from a channel over unbounded goroutine creation
- Use buffered channels as semaphores to limit concurrent work
- Use `struct{}` channels for pure signaling, channels of channels for request-response patterns
- Distinguish concurrency (structuring as independent components) from parallelism (multi-CPU execution)

## Allocation and Data

- Understand `new` vs `make`: `new(T)` returns `*T` zeroed; `make` initializes slices, maps, and channels
- Prefer composite literals with named fields: `&File{fd: fd, name: name}` over field-by-field assignment
- Prefer slices over arrays — arrays are values (copied on assignment/pass), slices are references
- Always reassign the result of `append`: `s = append(s, x)` — the underlying array may change
- Use the comma-ok idiom to distinguish missing map keys from zero values: `v, ok := m[key]`
- Use maps with `bool` values for sets: `seen[item] = true`

## Control Flow

- Return early on error — eliminate `else` when the `if` body ends in `return`, `break`, or `continue`
- Use expression-less `switch` for cleaner `if-else` chains
- Use type switches for interface value inspection: `switch v := x.(type)`
- Use labeled `break`/`continue` to escape an outer loop from inside a `switch` or inner loop
- No automatic fall-through in `switch` — use comma-separated cases: `case ' ', '?', '&':`
- Use `defer` for cleanup (close files, unlock mutexes) — place it right after the resource is acquired
- Deferred calls execute LIFO; arguments are evaluated at the `defer` statement, not at execution

## Methods and Receivers

- Value receivers for read-only methods; pointer receivers when the method mutates the receiver or the struct is large
- Value methods can be invoked on both pointers and values; pointer methods only on pointers (or addressable values)
- If any method has a pointer receiver, all methods on that type should use pointer receivers for consistency

## Embedding

- Embed types for method promotion — avoids manual forwarding methods
- Embedded type's methods receive the inner type as receiver, not the outer type (not subclassing)
- An outer field or method shadows an embedded one with the same name
- Use embedding to satisfy interfaces (e.g., embed `io.Reader` in a struct to implement `io.Reader`)
- Initialize embedded fields in constructors: `&Job{command, log.New(os.Stderr, "Job: ", log.Ldate)}`

## Blank Identifier

- Never discard errors: `fi, _ := os.Stat(path)` is a bug waiting to happen
- Use blank import for side effects only: `import _ "net/http/pprof"`
- Use compile-time interface checks: `var _ json.Marshaler = (*MyType)(nil)`
- Only add interface compliance checks when there are no static conversions already in the code

## Idiomatic Go

- Use `context.Context` for cancellation, deadlines, and request-scoped values
- Use `table-driven tests` for data variations
- Use `t.Helper()` in test helper functions
- Prefer `strings.Builder` for string concatenation
- Use `slices` and `maps` packages (Go 1.21+) over manual loops where they simplify
- Use structured logging (`log/slog`) over `log.Printf`
- Export interfaces, not types, when a type exists only to implement an interface — return the interface from constructors
- Use the `HandlerFunc` adapter pattern to convert functions into interface implementations

## Code Quality

- `go vet` and `staticcheck` for linting
- `gofumpt` for formatting
- `golangci-lint` as the meta-linter
- Functions ≤ 40 lines, cyclomatic complexity ≤ 10
- Files ≤ 500 lines; split when exceeded
