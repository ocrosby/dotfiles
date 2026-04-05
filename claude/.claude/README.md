# Claude Configuration Learnings

This file documents lessons learned about what makes Claude rules, skills, hooks, and agents work reliably. It is updated automatically as new insights are discovered during working sessions.

---

## Rule Authoring

### Use mandatory language, not advisory language

Rules using "suggest", "consider", or "prefer" drift across sessions. Claude interprets soft language as optional and skips it without consequence. Use "always", "must", "never", and "do not" for behaviors you want to be consistent.

**Pattern that drifts:**
> Consider running `/review` before shipping.

**Pattern that holds:**
> Always recommend `/review` before shipping. Do not skip this recommendation.

---

### Add a "don't revert" anchor with the reasoning

Rules that say what to do but not why it's non-negotiable get quietly reversed when Claude encounters complexity or time pressure. A single sentence explaining the intent prevents this.

**Without anchor (reverts):**
> Dependency injection via constructor functions — pass dependencies in, never use globals.

**With anchor (holds):**
> Dependency injection via constructor functions — pass dependencies in, never use globals.
> **This is an intentional design decision — do not simplify it away.** When code grows complex, the correct response is to refactor, not to revert to globals or singletons.

---

### Define exceptions explicitly with examples, not categories

Vague exception categories like "purely mechanical changes" are interpreted too broadly across sessions. Exceptions should be defined with literal examples so there is no room for interpretation drift.

**Too broad (overused):**
> Exceptions: purely mechanical changes.

**Scoped correctly (stable):**
> Exceptions: renaming an identifier, moving a file to a different package, updating an import path. If there is any change to logic, control flow, or observable behavior, it is not mechanical.

---

### Resolve contradictions between rules and skills

When a rule and a skill cover the same behavior but say different things, Claude alternates between them depending on which file is loaded first. Every contradiction creates a cycle.

**Known example (now resolved):** `rules/tdd.md` said `/refactor` was a TDD exception; `skills/refactor/SKILL.md` required characterization tests first. These said opposite things. Fix: align them to one answer — refactor requires characterization tests, which is a different test-first process, not an exception.

---

### Align rule scope with skill scope

If a rule suggests a skill for a narrow task (e.g., a single deprecated pattern in the current file) but the skill is written to scan the entire codebase, the mismatch creates confusion. Either give the skill a scoped mode or make the rule match the skill's actual behavior.

**Example (now resolved):** `rules/migrate-suggest.md` suggested `/migrate` for individual deprecated patterns mid-task, but `skills/migrate/SKILL.md` opened a full codebase scan. Fix: added file-level vs codebase-level modes to the skill.

---

## TDD Enforcement

### "Invoke the skill" is not the same as "follow the cycle"

A rule that says "invoke `/test-driven-development`" only loads the instructions. Claude can acknowledge the skill and still skip the RED step. The rule must mandate specific observable outputs: write the test, run it, show the failure output, then implement.

---

### The hook reminds; it does not block

The `tdd-remind.sh` PreToolUse hook fires before editing production files and outputs a warning. It exits 0 (allows the edit), so it cannot enforce TDD on its own. Its value is in the language weight of the message — "STOP / do not proceed" carries more force than "confirm". The hook and the rule together create the behavior; neither alone is sufficient.

---

### Refactor is not a TDD exception — it is a different test-first process

The red-green-refactor cycle (new failing test → minimal implementation) does not apply to refactoring. But tests are still required first. Characterization tests that document current behavior must exist before touching any code. Calling refactor a "TDD exception" without this nuance causes Claude to skip tests entirely when refactoring.

---

## Go-Specific

### Go workspace repos require per-module command iteration

In a Go workspace (`go.work` present), `go test ./...` and `golangci-lint run ./...` from the repository root fail with "directory prefix . does not contain modules listed in go.work". Every toolchain command must iterate over `go.mod` files using `find . -name "go.mod" | while read f; do (cd "$(dirname "$f")" && <cmd>) || exit 1; done`. If the project has a Taskfile, prefer `task lint` / `task test` — they already encode the correct pattern.

---

### golangci-lint major version must match the module's Go version

golangci-lint is compiled with a specific Go version. If a module declares `go 1.26` but golangci-lint was built with Go 1.24 (v1.x), it fails with "file requires newer Go version go1.26 (application built with go1.24)". Use `golangci-lint v2.x` for modules declaring `go 1.26`. In GitHub Actions, `golangci-lint-action@v9` resolves to v2.x; `golangci-lint-action@v6` caps at v1.64.8 (Go 1.24) and will fail.

---

### golangci-lint v2 requires `version: "2"` in `.golangci.yml`

golangci-lint v2 rejects v1 config files silently or with "unsupported version of the configuration". The v2 format requires `version: "2"` at the top, moves formatter config to a top-level `formatters` section, moves linter settings to `linters.settings`, and moves exclusion rules to `linters.exclusions.rules`. `gosimple` is merged into `staticcheck` in v2 — listing it separately causes an error.

---

### All `go.mod` files in a workspace must declare the same Go version

When Go stdlib files gain build constraints (e.g., `//go:build go1.26` on FIPS files), modules that declare an older version exclude those files at compile time, causing `undefined` errors at runtime. After upgrading `go.work` to a new Go version, update every `go.mod` in the workspace to match, then run `go work sync`.

---

### Falling back to `go vet` on golangci-lint version mismatch creates false security

When golangci-lint can't run due to a Go version mismatch, falling back to `go vet` feels safe but isn't. `go vet` only catches compilation-level issues; it misses godot (missing periods), goimports (import grouping), gocyclo (complexity), and every style linter. The result is that lint looks "clean" locally while CI fails. The correct response to a version mismatch is a **hard error** with a clear fix: `go install golangci-lint/v2/... @latest` or `task deps`. Do not silently downgrade.

---

### Pre-push hooks prevent CI-only lint failures

A `.githooks/pre-push` script that runs `golangci-lint run ./...` per module blocks the push before it reaches CI. Without this, any lint issue — regardless of how obvious — must wait for a CI run to be discovered. Add `task hooks` to configure it in one step, and document in the README.

---

### `fail-fast: true` on matrix lint jobs cascades into false failures

In a GitHub Actions matrix job for per-module linting, the default `fail-fast: true` cancels all remaining jobs when one fails. This hides failures in other modules and makes CI output misleading. Set `fail-fast: false` on lint matrix jobs so every module's result is always reported independently.

---

### `go test -race` belongs in the review linter step, not just the checklist

The `go-reviewer` agent checklist had "Race detector passing: `go test -race`" as an item to check, but nothing actually ran it. Adding it to the review skill's linter step (`go vet ./... && go test -race ./...`) makes it a blocking Must Fix finding rather than an advisory note.

---

### Benchmarks should be flagged as missing, not run automatically

Running `go test -bench=./...` on every review is too slow and only measures what has already been benchmarked. The right behavior is: flag missing benchmarks as a Suggestion-level finding when code is on a hot path, processes large inputs, or is latency-sensitive. Use `/go-bench` explicitly when you want to measure.

---

## Complexity

### Cyclomatic complexity limit should be ≤ 7 globally

A limit of 10 is too permissive — functions with complexity 8–10 are measurably harder to test and reason about. The limit of 7 applies to Go, Python, and Lua. Gherkin is declarative and does not have cyclomatic complexity.

---

## Concurrency (Go)

### Key patterns that prevent goroutine leaks

- Every generator must have a done/quit signal — a producer blocked on send with no consumer leaks forever
- Scatter-gather channels must be buffered to the number of senders — unbuffered channels leak abandoned goroutines when a timeout fires
- `close()` on a channel while goroutines are still sending to it panics — signal them to stop first
- `time.After` called inside a loop creates a new timer each iteration; a global deadline never triggers — call it once outside the loop

---
