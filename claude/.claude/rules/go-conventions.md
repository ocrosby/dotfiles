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

**These principles are intentional design decisions — do not simplify them away.** When code grows complex (many injected dependencies, verbose constructors, large interfaces), the correct response is to split and simplify the design, not to revert to globals, singletons, or package-level state. Complexity is a signal to refactor, not to abandon the principle.

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

### Typed-nil interface hazard

A typed nil (`(*T)(nil)`) assigned to an interface variable produces a **non-nil interface**. Any function that accepts an `error` (or other interface) and stores it may silently preserve this hazard, causing unexpected non-nil checks and broken `Error()` output downstream.

**Rule**: functions that accept an `error` parameter and store it must guard against typed nils at the point of storage — do not leave the detection to callers or documentation.

```go
// Bad — silently stores a typed nil; downstream error checks behave unexpectedly
func Wrap(code ErrorCode, msg string, cause error) *AppError {
    return &AppError{code: code, message: msg, err: cause}
}

// Good — normalise typed nils to untyped nil at the boundary
func Wrap(code ErrorCode, msg string, cause error) *AppError {
    if cause != nil && reflect.ValueOf(cause).IsNil() {
        cause = nil
    }
    return &AppError{code: code, message: msg, err: cause}
}
```

The guard applies whenever:
- A function accepts an `error` parameter and stores it in a struct field, slice, or map
- The function is part of a library or shared package where callers are not fully controlled

A doc comment saying "don't pass a typed nil" is **not** a substitute for the guard — documentation is ignored; runtime guards are not.

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

### Principles

- Do not communicate by sharing memory; share memory by communicating
- Distinguish concurrency (structuring as independent components) from parallelism (multi-CPU execution)
- Always pass `context.Context` as the first parameter on any function that does I/O or blocks
- Use `errgroup` for concurrent work with error propagation
- Channels should have a clear owner — one goroutine creates, one closes; close in the sender, never the receiver
- Prevent goroutine leaks: every goroutine must have a termination path (quit channel, `done` channel, or context)
- Start goroutines when you have concurrent work to do; exit them as soon as the work is done

### Generator pattern

- Return `<-chan T` (receive-only) from a function that launches a goroutine internally — callers iterate with `for v := range ch`
- The goroutine that creates the channel owns it and is responsible for `close(ch)` when done
- Pair every generator with a quit/done signal so callers can stop it early without leaking the producer goroutine

```go
func generate(done <-chan struct{}, values ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, v := range values {
            select {
            case out <- v:
            case <-done:
                return
            }
        }
    }()
    return out
}
```

### Fan-in (multiplexer)

- Merge multiple input channels into one output channel by spawning one forwarding goroutine per input
- Use `sync.WaitGroup` to close the output channel only after all forwarders finish

```go
func merge(done <-chan struct{}, cs ...<-chan int) <-chan int {
    var wg sync.WaitGroup
    out := make(chan int)
    forward := func(c <-chan int) {
        defer wg.Done()
        for v := range c {
            select {
            case out <- v:
            case <-done:
                return
            }
        }
    }
    wg.Add(len(cs))
    for _, c := range cs { go forward(c) }
    go func() { wg.Wait(); close(out) }()
    return out
}
```

### Select patterns

- Enable/disable a `select` case by toggling the channel variable: set to `nil` to disable, set to the real channel to re-enable
- Use this to suppress sends when there is nothing pending, preventing spurious blocking

```go
var out chan Item   // nil — send case is disabled
if len(pending) > 0 {
    out = realOut  // enable the send case
}
select {
case out <- pending[0]:
    pending = pending[1:]
case item := <-in:
    pending = append(pending, item)
}
```

- For a **whole-operation timeout**, call `time.After` once outside the loop; calling it inside the loop creates a new timer each iteration and the deadline never triggers
- For a **per-message timeout**, call `time.After` inside the loop

```go
// global deadline — call ONCE outside the loop
timeout := time.After(5 * time.Second)
for {
    select {
    case msg := <-c:
        // handle
    case <-timeout:
        return
    }
}
```

- Use `select` with `default` for non-blocking channel operations (try-send / try-receive)

### Quit signal with cleanup

- Pass a `quit` channel to a goroutine; include a `select` case on it alongside normal work
- For confirmed shutdown with cleanup: use the same channel bidirectionally — caller sends stop signal, goroutine sends acknowledgement after cleanup

```go
select {
case c <- value:
case <-quit:
    cleanup()
    quit <- struct{}{} // ack
    return
}
```

### Scatter-gather and replicated requests

- Run concurrent operations by launching one goroutine per task; collect results with a channel
- Always use a **buffered channel** sized to the number of senders so abandoned goroutines (timed out) can send and exit without leaking

```go
c := make(chan Result, len(replicas)) // buffered — not unbuffered
for _, r := range replicas {
    go func(r Search) { c <- r(query) }(r)
}
return <-c // take first; others send into buffer and exit cleanly
```

### Worker pool

- Cap concurrency with a fixed pool of N workers reading from a shared `jobs` channel
- `close(jobs)` signals all workers to exit after draining (`for j := range jobs` terminates on close)
- Use `sync.WaitGroup` + a closing goroutine to close the `results` channel only after all workers finish

```go
func worker(jobs <-chan int, results chan<- int, wg *sync.WaitGroup) {
    defer wg.Done()
    for j := range jobs { results <- process(j) }
}

jobs := make(chan int, 100)
results := make(chan int, 100)
var wg sync.WaitGroup
for i := 0; i < numWorkers; i++ { wg.Add(1); go worker(jobs, results, &wg) }
go func() { wg.Wait(); close(results) }()
```

### Bounded parallelism with cancellation

- Use a `done <-chan struct{}` to propagate cancellation to both a feeder (walker) and all workers
- Workers check `done` in their `select` to exit early on cancellation
- The feeder uses a buffered error channel (`errc := make(chan error, 1)`) so it never blocks on error send

### Context

- Use `context.Context` (not a raw `done` channel) for cancellation in HTTP handlers and any code that crosses service/API boundaries
- Always `defer cancel()` immediately after `context.WithCancel` / `WithTimeout` / `WithDeadline` — failing to call `cancel` leaks the context's internal goroutine
- Never store a context in a struct field; pass it as a function parameter
- Check `ctx.Err()` to distinguish `context.Canceled` from `context.DeadlineExceeded`

### Ring buffer (lossy bounded queue)

- Use a buffered channel with a non-blocking `select` to implement a ring buffer that drops oldest items when full

```go
select {
case out <- v:
default:
    <-out  // evict oldest
    out <- v
}
```

- This is appropriate for real-time telemetry or logging where stale data has less value than new data; never use it where dropping items silently is unacceptable

### Anti-patterns

- **Goroutine leak from abandoned producer**: a goroutine blocked on send to a channel no one is reading leaks forever — always provide a quit/done path
- **Unbuffered channel in scatter-gather**: if the consumer times out and stops receiving, senders block indefinitely — size the channel to the number of senders
- **`close()` on a channel while goroutines are still sending to it**: causes a panic — signal goroutines to stop (via quit or done) and wait for them to exit before closing
- **Blocking work inside a `select` loop**: a slow operation in a `select` case blocks all other cases (sends, closes) for its duration — run it in a sub-goroutine and deliver the result via a channel
- **`time.After` inside a loop for a global deadline**: creates a new timer on every iteration; the deadline never triggers — call it once outside the loop
- **Not calling `cancel()`**: leaks the context and its associated goroutine/resources until the parent context is cancelled

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
- `gofmt` and `goimports` for formatting
- `golangci-lint` as the meta-linter
- Functions ≤ 40 lines, cyclomatic complexity ≤ 7
- Files ≤ 500 lines; split when exceeded
