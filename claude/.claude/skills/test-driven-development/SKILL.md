---
description: Enforces test-driven development when writing, modifying, or fixing code. Auto-invoked for implementation tasks.
---

# Test-Driven Development

**Iron rule: No production code without a failing test first.**

## Red-Green-Refactor Cycle

Every code change follows this cycle strictly:

### 1. RED — Write a failing test

- Write the smallest test that demonstrates the desired behavior
- Run the test and **watch it fail**
- Confirm it fails for the right reason — not a syntax error or import issue
- If the test passes immediately, it tests nothing useful — delete it and write a meaningful one

### 2. GREEN — Make it pass

- Write the simplest production code that makes the test pass
- Do not add code beyond what the failing test requires
- Do not refactor yet — just make it green

### 3. REFACTOR — Clean up

- Improve structure, naming, and duplication while all tests stay green
- Apply design patterns only when complexity warrants it (Rule of Three)
- Run all tests after refactoring to confirm nothing broke

### 4. Repeat

- Pick the next behavior, write the next failing test, continue the cycle

## Verification at Every Step

- **Before implementing**: the new test must fail
- **After implementing**: the new test must pass, all existing tests must still pass
- **After refactoring**: all tests must still pass

## What This Means in Practice

- Adding a feature: write the test for the first behavior, implement, then next behavior
- Fixing a bug: write a test that reproduces the bug first, then fix it
- Refactoring: ensure full test coverage exists before changing structure

## Common Violations to Avoid

- Writing production code then "adding tests after" — tests written after prove nothing
- Writing a test that passes immediately — it doesn't validate behavior
- Mocking so heavily that you're testing mock behavior, not real behavior
- Adding test-only methods to production classes — use test utilities instead
- Skipping the "watch it fail" step — this is what proves the test is meaningful

See `testing-anti-patterns.md` in this skill directory for detailed examples and gate functions.
