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

## Exceptions (no TDD required)

- **`/migrate`**: replacing deprecated API calls with modern equivalents — behavior is identical, only syntax changes. Run the existing test suite after to verify.
- **`/refactor`**: structural reorganization — the `/refactor` skill handles this via characterization tests.
- **Purely mechanical changes**: renaming identifiers, moving files, updating import paths with no logic changes.
