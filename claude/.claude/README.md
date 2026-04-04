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
