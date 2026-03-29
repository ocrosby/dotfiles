---
description: Systematically triages and diagnoses failures in Gherkin BDD tests.
paths:
  - "**/*.feature"
---

# Gherkin Bug Triage

## Triage Workflow

### 1. Reproduce

- Run the failing scenario in isolation: single feature file, single scenario by line number or name
- Identify: does it fail consistently? Only when run with other scenarios? Only in CI?
- Record the BDD framework, language, and version

### 2. Isolate

#### Common failure modes

| Symptom | Likely Cause |
|---|---|
| Step undefined | Missing step definition, typo in step text, wrong import |
| Step ambiguous | Multiple step definitions match the same step text |
| Passes alone, fails in suite | Scenario coupling — shared state leaking between scenarios |
| Passes locally, fails in CI | Environment difference — missing service, timing, browser version |
| Timeout | Slow dependency, missing async handling, hardcoded wait too short |
| Wrong assertion | Step definition asserts on stale state, race condition |
| Pending / skipped unexpectedly | Missing step implementation, wrong tag filter |
| Data mismatch in Scenario Outline | Wrong column name, trailing whitespace in Examples table |

### 3. Diagnose

#### Check step matching

- Verify the step text in the feature file matches the regex/pattern in the step definition exactly
- Check for parameter type mismatches (string vs int)
- Check for whitespace or special character differences

#### Check state flow

- Trace the World/context object through Given → When → Then
- Verify each step sets the expected state for the next step
- Check Before/After hooks — are they running? Are they resetting state correctly?

#### Check environment

- Verify external services are running (database, API, browser driver)
- Check configuration: base URLs, credentials, timeouts
- Compare local vs CI environments

### 4. Classify

- **Step matching**: typo or pattern mismatch — fix the step text or regex
- **State leakage**: scenarios polluting each other — reset state in Before hooks
- **Timing**: async operation not awaited — add polling/retry instead of sleep
- **Environment**: missing service or config — fix CI setup or add skip tag
- **Data**: wrong test data or stale fixtures — update fixtures or Given steps
- **Framework**: BDD framework bug or version issue — check changelog, update

### 5. Fix and Verify

- Fix the root cause, not the symptom
- Run the scenario in isolation to confirm the fix
- Run the full suite to confirm no regressions
- Run with `--tags @smoke` to verify critical paths still pass
