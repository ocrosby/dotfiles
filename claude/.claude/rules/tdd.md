---
description: Enforces test-driven development for all code changes
paths:
  - "**/*.py"
  - "**/*.go"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.lua"
  - "**/*.rb"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.kt"
  - "**/*.swift"
  - "**/*.c"
  - "**/*.cpp"
  - "**/*.cs"
---

# Test-Driven Development — Mandatory

When implementing any new feature, bug fix, or behavior change, you MUST invoke the `/test-driven-development` skill and follow its red-green-refactor cycle. No production code without a failing test first.

## Exceptions

Do **not** invoke TDD for these tasks — they have their own processes:

- **`/migrate`**: replacing deprecated API calls with modern equivalents. Behavior is identical; only syntax changes. Run the existing test suite after to verify nothing broke — no new failing test is needed.
- **`/refactor`**: structural reorganization of code. The `/refactor` skill handles this via characterization tests (documenting current behavior before restructuring) — a different process from red-green-refactor.
- **Purely mechanical changes**: renaming identifiers, moving files between modules, updating import paths with no logic changes.
