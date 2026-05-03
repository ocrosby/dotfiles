---
description: Write, run, and analyze Neovim plugin benchmarks. Use when benchmarking Lua plugin code, investigating startup regressions, comparing before/after, or profiling autocmd and handler latency.
triggers:
  - /nvim-bench
paths:
  - "**/*.lua"
---

# Neovim Plugin Benchmarking

## When to use this skill

- You suspect a plugin function is slow and want to measure it
- You made a performance change and want to verify improvement
- The `/code-review` skill flagged missing benchmarks on a hot path
- You want to profile startup time or autocmd callback latency

## Workflow

### 1. Identify what to benchmark

Target one of these categories:

- **Startup cost** — does the plugin slow Neovim launch? (use `--startuptime`)
- **Hot-path callbacks** — autocmds, keymaps, LSP handlers called on every keypress or event
- **Expensive operations** — treesitter queries, file reads, API batching loops
- **Comparison** — measuring two implementations against each other

Benchmark at the right granularity — one timed block per distinct operation.

### 2. Write the benchmark

#### Inline timing with `vim.loop.hrtime()` (nanosecond resolution)

```lua
local function bench(label, fn, iterations)
  iterations = iterations or 1000
  local start = vim.loop.hrtime()
  for _ = 1, iterations do
    fn()
  end
  local elapsed_ns = vim.loop.hrtime() - start
  local per_call_us = (elapsed_ns / iterations) / 1000
  vim.notify(string.format("%s: %.2f µs/call (%d iterations)", label, per_call_us, iterations))
end

-- Usage
bench("my_module.process", function()
  require("my_module").process(sample_input)
end)
```

#### CPU time with `os.clock()` (excludes I/O wait)

```lua
local function bench_cpu(label, fn, iterations)
  iterations = iterations or 1000
  local start = os.clock()
  for _ = 1, iterations do
    fn()
  end
  local elapsed_s = os.clock() - start
  local per_call_ms = (elapsed_s / iterations) * 1000
  vim.notify(string.format("%s: %.3f ms/call (cpu)", label, per_call_ms))
end
```

Always use `vim.loop.hrtime()` for wall-clock latency — this is the user-visible number. Use `os.clock()` only when isolating pure compute cost from scheduler noise (it excludes I/O wait).

#### Startup time profiling

```bash
# Run with startup time log (one entry per sourced file / plugin event)
nvim --startuptime /tmp/startup.log +q

# Show top 20 slowest entries
sort -k2 -n /tmp/startup.log | tail -20
```

Compare before and after a change by capturing two runs:

```bash
nvim --startuptime /tmp/before.log +q
# make your change
nvim --startuptime /tmp/after.log +q
diff <(sort -k2 -n /tmp/before.log) <(sort -k2 -n /tmp/after.log)
```

#### lazy.nvim profile (if using lazy.nvim)

Run `:Lazy profile` inside Neovim to see per-plugin load time in a UI panel.

### 3. Run the benchmark

Place the bench block in a scratch buffer or a dedicated `bench/` directory, then source it:

```vim
:source bench/my_bench.lua
" or in the scratch buffer:
:luafile %
```

For startup benchmarks, always use a clean Neovim invocation (not an already-running instance) to avoid cached state.

### 4. Compare before and after

For function-level benchmarks, capture output manually and compare:

```lua
-- Save both runs to a table, then diff
local results = {}
bench("before", before_fn, 10000)
-- apply change in-session via reload:
package.loaded["my_module"] = nil
bench("after", require("my_module").process, 10000)
```

For startup benchmarks use the `diff` approach from Step 2.

### 5. Interpret results

| Measurement | Typical concern |
|---|---|
| `> 1 ms/call` on a keymap or autocmd handler | Noticeable input lag above 5–10 calls/sec |
| `> 50 ms` added to startup | Perceptible delay; investigate with `--startuptime` |
| High variance across runs | Benchmark has noise — ensure the module is pre-loaded before timing; exclude `require()` from the hot loop unless that's what you're measuring |

**Red flags:**
- `require()` inside the timed loop — module loading is cached after the first call, giving misleading sub-microsecond results on subsequent iterations
- Repeated `vim.api.*` calls that can be batched with `vim.api.nvim_buf_call` or `vim.schedule`
- Table construction inside tight loops — allocates GC pressure
- High variance across runs with no obvious cause — background plugin state (LSP server polling, autocmds firing) can interfere. Run benchmarks in a minimal `nvim --clean` session with `--noplugin` if results are inconsistent

### 6. Common optimizations to investigate

- **Cache `require()` results**: `local M = require("my_module")` at the top of the file, not inside callbacks
- **`vim.schedule` for deferred work**: move non-urgent updates out of synchronous autocmd handlers
- **Batch API calls**: replace N `nvim_buf_set_lines` calls with one call covering the range
- **Avoid repeated table construction**: pre-allocate option tables used in tight loops
- **Lazy-load plugin submodules**: return a module table with `__index` that loads on first field access
- **`vim.tbl_deep_extend` is slow on large tables**: prefer manual merging in hot paths

## Rules

- Never optimize without a measurement showing the problem — measure first
- Exclude `require()` from the timed loop unless module load time is what you're measuring
- For startup benchmarks, always use a fresh process — never `:source` timing code in a session that already loaded the plugin
- Never use `:source` to re-run a benchmark in an already-running Neovim session — the Lua module cache persists across `:source` calls, giving misleading sub-microsecond results on repeat runs. Always use a fresh `nvim` invocation for startup benchmarks; always call `package.loaded["my_module"] = nil` before re-requiring in function-level benchmarks
- Do not commit benchmark scripts to `lua/` — place them in `bench/` or a scratch file and `.gitignore` the directory
