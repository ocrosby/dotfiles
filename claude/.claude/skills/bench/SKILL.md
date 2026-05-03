---
description: Benchmarks code in the current project by routing to the appropriate language-specialist bench skill.
triggers:
  - /bench
---

# Bench

Use this skill when you want to write, run, or analyze benchmarks for the current project. It detects the language from context and routes to the appropriate language-specialist skill.

## Usage

```
/bench              # detect language from context and invoke appropriate skill
/bench go           # force Go benchmarking
/bench py           # force Python benchmarking
/bench nvim         # force Neovim/Lua benchmarking
```

## Workflow

### 1. Detect the Language

If no language argument is given, infer from:
- File extensions in the working directory or changed files (`git diff --name-only HEAD`)
- Project markers: `go.mod` → Go, `pyproject.toml` → Python, `*.rockspec` or `init.lua` in `lua/` → Neovim
- Ask if ambiguous

### 2. Route to the Bench Skill

| Language | Skill |
|---|---|
| Go (`.go`) | `/go-bench` |
| Python (`.py`) | `/py-bench` |
| Neovim / Lua (`.lua`) | `/nvim-bench` |

Pass any user-supplied context (which function to benchmark, what regression to investigate, what comparison to make) to the language-specific skill.

### 3. Verify Results

After the language-specific skill completes:
- Confirm benchmarks ran successfully and results are reported
- If results seem implausibly fast (sub-nanosecond), the function may be getting optimized away — verify with language-specific dead-code elimination guards
- If results show high variance, re-run with more iterations or in a quieter environment

## Rules

- Always measure before optimizing. If the user describes a performance problem from profiling or production metrics, still create a targeted benchmark that reproduces the exact problem — never optimize from intuition alone.
- If the language cannot be determined and no argument is given, ask rather than assuming
