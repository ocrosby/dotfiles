---
description: Write, run, and analyze Python benchmarks. Use when benchmarking Python code, investigating performance regressions, comparing before/after, or profiling allocations and throughput.
paths:
  - "**/*.py"
---

# Python Benchmarking

## When to use this skill

- You suspect a function is slow and want to measure it
- You made a performance change and want to verify improvement
- The `/code-review` skill flagged missing benchmarks on a hot path
- You want to compare two implementations

## Workflow

### 1. Identify what to benchmark

- Target functions called frequently, processing large inputs, or on latency-sensitive paths
- Benchmark at the right granularity — one benchmark function per distinct operation or input class
- If no benchmarks exist yet, write them before making any optimization (measure first, optimize second)

### 2. Write the benchmark

**With pytest-benchmark** (preferred for project code):

```python
def test_foo_benchmark(benchmark):
    input_data = prepare_input()
    result = benchmark(foo, input_data)
    assert result is not None  # always assert something to prevent dead-code elimination
```

Parameterize for input size variations:

```python
import pytest

@pytest.mark.parametrize("n", [10, 100, 1000, 10_000])
def test_foo_benchmark(benchmark, n):
    input_data = make_input(n)
    benchmark(foo, input_data)
```

**With timeit** (quick one-off measurements):

```python
import timeit

result = timeit.timeit(
    stmt="foo(input_data)",
    setup="from mymodule import foo; input_data = prepare_input()",
    number=10_000,
)
print(f"{result / 10_000 * 1e6:.2f} µs per call")
```

### 3. Run the benchmark

```bash
# Run all benchmarks
pytest --benchmark-only

# Run a specific benchmark
pytest --benchmark-only tests/test_foo.py::test_foo_benchmark

# Save results for comparison
pytest --benchmark-only --benchmark-save=baseline

# Compare against saved baseline
pytest --benchmark-only --benchmark-compare=baseline

# Show histogram
pytest --benchmark-only --benchmark-histogram
```

Install if needed: `uv add --dev pytest-benchmark`

### 4. Profile for root cause

When a benchmark shows a problem, use profiling to find the hot spot.

**cProfile** (function-level call counts and times):

```bash
python -m cProfile -s cumtime -m pytest tests/test_foo.py::test_foo_benchmark
```

Or from code:

```python
import cProfile
import pstats
import io

pr = cProfile.Profile()
pr.enable()
foo(input_data)
pr.disable()

s = io.StringIO()
ps = pstats.Stats(pr, stream=s).sort_stats("cumulative")
ps.print_stats(20)
print(s.getvalue())
```

**py-spy** (sampling profiler, no code changes required):

```bash
# Profile a running process
py-spy top --pid <PID>

# Generate a flamegraph
py-spy record -o profile.svg -- python -m pytest tests/test_foo.py

# Install
uv tool install py-spy
```

### 5. Interpret pytest-benchmark results

```
Name (time in µs)         Min       Max      Mean    StdDev   Rounds
test_foo_benchmark      123.4     145.2     128.3      6.1     1000
```

| Column | Meaning |
|---|---|
| `Min` | Best-case time — most representative for CPU-bound code |
| `Mean` | Average — watch for high variance (>10% StdDev/Mean) |
| `Rounds` | How many times pytest-benchmark ran the function |

**Red flags:**
- High StdDev relative to Mean — benchmark setup has noise; move I/O and allocation out of the measured call
- Linear growth in time as input size grows when O(1) or O(log n) is expected
- Unexpected regressions in `--benchmark-compare` output

### 6. Common optimizations to investigate

- **List comprehensions over loops**: `[f(x) for x in xs]` is faster than manual `append`
- **Local variable binding**: `_foo = self.foo` before a tight loop avoids repeated attribute lookup
- **`__slots__`**: reduces per-instance memory when creating many small objects
- **`functools.lru_cache` / `cache`**: memoize pure functions with repeated identical inputs
- **NumPy vectorization**: replace Python loops over numeric arrays with NumPy ufuncs
- **`io.BytesIO` / `io.StringIO`**: in-memory buffers instead of repeated string concatenation
- **Avoid repeated `len()` calls**: bind to a local if called in a loop

## Rules

- Never optimize without a benchmark showing the problem — measure first
- A benchmark that passes instantly may be testing nothing; verify the function is actually called with `--benchmark-verbose`
- Do not commit benchmarks that require network access or large fixtures without a `pytest.mark.slow` guard
- Always assert a result in pytest-benchmark tests — the optimizer can eliminate calls with no observable effect
