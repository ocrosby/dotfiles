---
description: Write, run, and analyze Go benchmarks. Use when benchmarking Go code, investigating performance regressions, comparing before/after, or analyzing allocations and throughput.
triggers:
  - /go-bench
paths:
  - "**/*.go"
---

# Go Benchmarking

## When to use this skill

- You suspect a function is slow and want to measure it
- You made a performance change and want to verify improvement
- The `/review` skill flagged missing benchmarks on a hot path
- You want to compare two implementations

## Workflow

### 1. Identify what to benchmark

- Target functions that are called frequently, process large inputs, or are on latency-sensitive paths
- Benchmark at the right granularity — one `Benchmark*` per distinct operation or input class
- If no benchmarks exist yet, write them before making any optimization (measure first, optimize second)

### 2. Write the benchmark

Place benchmark functions in the `_test.go` file alongside the code being measured.

```go
func BenchmarkFoo(b *testing.B) {
    // setup outside the loop — not measured
    input := prepareInput()

    b.ResetTimer() // exclude setup from measurement
    for b.Loop() { // preferred over i := 0; i < b.N; i++ in Go 1.24+
        Foo(input)
    }
}
```

**Allocation benchmarks** — use `b.ReportAllocs()` or run with `-benchmem`:

```go
func BenchmarkFoo(b *testing.B) {
    b.ReportAllocs()
    for b.Loop() {
        Foo(input)
    }
}
```

**Sub-benchmarks** for input size variations:

```go
func BenchmarkFoo(b *testing.B) {
    sizes := []int{10, 100, 1000, 10000}
    for _, n := range sizes {
        b.Run(fmt.Sprintf("n=%d", n), func(b *testing.B) {
            input := makeInput(n)
            b.ResetTimer()
            for b.Loop() {
                Foo(input)
            }
        })
    }
}
```

### 3. Run the benchmark

```bash
# Run all benchmarks in a package
go test -bench=. -benchmem ./...

# Run a specific benchmark
go test -bench=BenchmarkFoo -benchmem ./internal/domain/...

# Run multiple times for stability (default b.N auto-scales; -count for repeated runs)
go test -bench=BenchmarkFoo -benchmem -count=5 ./...

# With CPU profiling
go test -bench=BenchmarkFoo -cpuprofile=cpu.prof ./...
pprof -http=:8080 cpu.prof

# With memory profiling
go test -bench=BenchmarkFoo -memprofile=mem.prof -benchmem ./...
```

### 4. Compare before and after (regression check)

Use `benchstat` to compare two runs statistically:

```bash
# Capture baseline
go test -bench=. -benchmem -count=10 ./... > before.txt

# Make your change, then capture new results
go test -bench=. -benchmem -count=10 ./... > after.txt

# Compare
benchstat before.txt after.txt
```

Install if needed: `go install golang.org/x/perf/cmd/benchstat@latest`

### 5. Interpret results

```
BenchmarkFoo-8   1000000   1023 ns/op   256 B/op   4 allocs/op
```

| Column | Meaning |
|---|---|
| `-8` | GOMAXPROCS (CPU count) |
| `1000000` | iterations run |
| `1023 ns/op` | nanoseconds per operation |
| `256 B/op` | bytes allocated per operation |
| `4 allocs/op` | heap allocations per operation |

**Red flags:**
- Allocs per op growing linearly with input size when they shouldn't
- Unexpected heap allocations on a hot path (interface boxing, closure captures, string conversions)
- High variance across runs — indicates the benchmark setup has noise (move allocations out of the loop)

### 6. Common optimizations to investigate

- **Preallocate slices**: `make([]T, 0, knownCap)` eliminates append-driven reallocations
- **`strings.Builder`**: replaces `+` concatenation in loops
- **Avoid interface boxing on hot paths**: concrete types in tight loops
- **`sync.Pool`**: reuse short-lived allocations (parsers, buffers)
- **`bytes.Buffer` vs `[]byte`**: prefer `[]byte` for byte manipulation without the `Buffer` overhead
- **Inlining**: small functions inlined by the compiler — check with `go build -gcflags='-m'`

## Rules

- Never optimize without a benchmark showing the problem — measure first
- A benchmark that passes immediately (trivially fast) may be testing nothing; verify with `-gcflags='-N -l'` to disable optimizations
- Do not commit benchmarks that require external services or large fixtures without a `testing.Short()` guard
- `b.Loop()` (Go 1.24+) is preferred over the manual `b.N` loop — it handles timer resets and loop overhead automatically; fall back to `for i := 0; i < b.N; i++` for older Go versions
