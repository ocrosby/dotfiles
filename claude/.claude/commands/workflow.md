# Development Workflow

Complete reference for the development workflow and when to use each skill, agent, and hook.

## Standard Feature Workflow

```
/architect → /*-feature (TDD) → /code-review → /ship → /main
```

### 1. `/architect` — design before implementing
Invoke for anything beyond a trivial change: new packages, significant new abstractions, cross-cutting concerns. Routes to `go-architect`, `py-architect`, `nvim-architect`, or `gherkin-architect` based on language. Output: module map, dependency graph, public API surface, trade-offs. Capture decisions in `ARCHITECTURE.md`.

### 2. `/*-feature` — implement with TDD
Use `/go-feature`, `/py-feature`, `/nvim-feature`, or `/gherkin-feature`. The `tdd` rule auto-invokes `/tdd` (red-green-refactor). The lint hook runs automatically after every file save.

### 3. `/code-review` — catch issues before shipping
Delegates to `go-reviewer`, `py-reviewer`, `nvim-reviewer`, or `gherkin-reviewer` agents for deep, criteria-driven review. Also routes to `rest-reviewer` when HTTP handler patterns are detected. The `review-on-implement` rule suggests this after significant implementation.

### 4. `/ship` — branch, commit, push, open PR
Pre-flight runs lint + tests. Validates conventional commit format. Never commits directly to main (hook enforced). Returns the PR URL.

### 5. `/main` — after PR merges
Checkout main, pull latest, delete merged branches.

---

## Branch Management

| Situation | Command |
|---|---|
| Feature branch needs to catch up with main | `/sync` — rebase onto main, handle conflicts |
| PR merged, ready for next task | `/main` — checkout + pull + clean |

---

## Maintenance

| Task | Command | When |
|---|---|---|
| Deprecated API calls | `/migrate` | Suggested by `migrate-suggest` rule when old patterns detected |
| Structural design issues | `/refactor` | Go, Python, and Neovim supported |
| Missing documentation | `/go-docs` / `/py-docs` / `/nvim-docs` / `/gherkin-docs` | Suggested by `docs-suggest` rule when public API added without docs |
| Post-review code quality | `/simplify` | After `/code-review` to apply fixes for reuse, quality, and efficiency (team plugin — not in dotfiles) |
| Go performance analysis | `/go-bench` | When benchmarking Go code or investigating allocations and throughput |
| Python performance analysis | `/py-bench` | When benchmarking Python code or investigating performance bottlenecks |
| Design pattern decisions | `/patterns` | When designing architecture or reviewing structural code decisions |
| Documentation review | `/doc-review` | After writing or updating public-facing docs |
| Author or improve skills | `/skill-author` | When adding or modifying a Claude skill |

---

## Debugging

| Situation | Tool |
|---|---|
| Test failure or bug | `/debug` — triage then escalates to language specialist |
| Need deep root cause | Invoke `go-debugger`, `py-debugger`, `nvim-debugger`, or `gherkin-debugger` directly |

---

## Running Tests

Use `/test-runner` to run the test suite and get a structured failure report without flooding the conversation with verbose output. Detects pytest, jest, vitest, and make automatically.

```
/test-runner          # run tests in the current project
/bdd <feature-file>   # run a Gherkin BDD feature file with the correct environment and region
```

Or run directly when you need the raw output:

| Language | Command |
|---|---|
| Go | `go test -race ./...` |
| Python | `pytest` |
| Neovim/Lua | `nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"` |

---

## Automated Quality Gates

These run without being asked:

| Trigger | What runs | Effect |
|---|---|---|
| Every file edit (Edit/Write) | `lint.sh` — ruff / go vet / stylua+luacheck | Shows lint errors for Claude to fix |
| Before every `git commit` | `protect-main.sh` — checks current branch | Blocks commits directly to main/master |
| After every `git commit` | `commit-msg.sh` — validates conventional commits | Warns Claude to amend if format is wrong |

---

## Rules That Fire Automatically

| Rule | Fires when | Suggests |
|---|---|---|
| `tdd` | Implementing new features or bug fixes | `/tdd` skill |
| `review-on-implement` | After significant implementation | `/code-review` |
| `docs-suggest` | Public API added without documentation | `/go-docs`, `/py-docs`, or `/nvim-docs` |
| `migrate-suggest` | Deprecated patterns detected in edited files | `/migrate` |

---

## Utilities

| Tool | Command | Description |
|---|---|---|
| Daily task journal | `/work` | Add, list, complete, and note tasks in a date-structured work log at `~/work/` |
| Research and publish | `/here-now` | Research any topic via live web sources and publish a self-contained report to here.now — returns a live URL |
