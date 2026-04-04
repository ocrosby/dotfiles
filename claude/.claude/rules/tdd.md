---
description: Enforces test-driven development for all code changes
paths:
  - "**/*.py"
  - "**/*.go"
  - "**/*.lua"
  - "**/*.feature"
---

# Test-Driven Development — Mandatory Workflow

**Iron rule: No production code without a failing test first. This is non-negotiable.**

When writing or modifying any production code in Go, Python, Lua, or Gherkin, you MUST complete these steps in order, with observable output at each step.

## Required Steps — Follow In Order

### Step 1 — Write the failing test (RED)

1. Write the test in the corresponding test file BEFORE touching any production file
2. Run the test suite and **show the failure output** to the user
3. Confirm the failure is for the right reason (not a syntax error or missing import)
4. Do NOT edit any production file until this step is complete and verified

### Step 2 — Write minimal implementation (GREEN)

1. Write only the code needed to make the failing test pass — nothing more
2. Run the test suite and **show the passing output** to the user
3. Confirm all existing tests still pass

### Step 3 — Refactor

1. Clean up structure, naming, and duplication while keeping all tests green
2. Run all tests after every refactor step to confirm nothing broke

## What "No production code first" means in practice

- **New feature**: write the test for the first behavior → see it fail → implement → see it pass → repeat for next behavior
- **Bug fix**: reproduce the bug with a failing test → confirm test fails for the right reason → fix the bug → confirm test passes
- **Changing behavior**: update the test to reflect the new expected behavior → see it fail → update the implementation → see it pass

## Verification is mandatory — not optional

Skipping the "watch it fail" step is a TDD violation. A test that was never seen failing proves nothing. Every implementation must be preceded by a visible, confirmed test failure.

## Don't revert this under pressure

When a task feels urgent or a user asks to "just implement it quickly," do not skip TDD. This decision is deliberate — tests written after the fact prove nothing because they're written to match the implementation, not to validate it. Time pressure does not change this.

## Exceptions — narrow and explicit

### `/migrate` — the only true exception

Replacing a deprecated API with its modern equivalent is the only situation where no new test is required. The behavior is identical; only the syntax changes. Run the existing test suite after to verify nothing broke.

### `/refactor` — NOT an exception; a different test-first process

Refactoring does not use the red-green-refactor cycle (no new failing test is written), but it **does** require tests written first. Before touching any code, write characterization tests that document current behavior. These are not new tests for new behavior — they are a safety net that proves the refactor didn't break anything.

The `/refactor` skill handles this automatically. Do not start a refactor without characterization test coverage in place.

### Purely mechanical changes — no logic change whatsoever

Examples: renaming an identifier, moving a file to a different package/module, updating an import path. The definition is strict — if there is any change to logic, control flow, or observable behavior, it is not mechanical and TDD applies.
