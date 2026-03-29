---
description: Identifies and refactors anti-patterns in Gherkin feature files and step definitions.
paths:
  - "**/*.feature"
---

# Gherkin Migration Guide

## Workflow

1. **Scan** feature files and step definitions for anti-patterns
2. **Identify** the improvement for each issue
3. **Refactor** preserving behavior
4. **Verify** all scenarios still pass

## Common Refactors

### Imperative to declarative steps

| Before | After |
|---|---|
| `When I click "Name" field` / `And I type "Alice"` / `And I click "Submit"` | `When I register with name "Alice"` |
| `When I navigate to "/settings"` / `And I click "Delete Account"` / `And I confirm` | `When I delete my account` |
| `Given I open the browser` / `And I go to the login page` | `Given I am on the login page` |

### Fat steps to thin steps

| Before | After |
|---|---|
| HTTP call + JSON parsing + assertion in one step | Step delegates to API client, asserts on response |
| Direct database query in step definition | Step delegates to repository helper |
| Browser automation inline in step | Step delegates to page object |

### Scenario coupling to independent scenarios

| Before | After |
|---|---|
| Scenario 2 depends on user created in Scenario 1 | Each scenario creates its own preconditions via Given |
| Shared module-level state between scenarios | State managed via World/context, reset in Before hook |

### God features to focused features

| Before | After |
|---|---|
| `login.feature` with 25 scenarios | Split into `login_success.feature`, `login_failure.feature`, `login_lockout.feature` |
| Mixed concerns in one feature | One feature per capability |

### Inconsistent step wording

| Before | After |
|---|---|
| `Given a user exists` / `Given there is a user` / `Given user was created` | Pick one: `Given a user exists with email "{email}"` |
| `Then I see error` / `Then error is shown` / `Then I should get an error` | Pick one: `Then I should see an error "{message}"` |

### Missing Scenario Outlines

| Before | After |
|---|---|
| 5 identical scenarios with different input data | One Scenario Outline with Examples table |

## Scan Patterns

Search for these to find anti-patterns:

- Steps containing "click", "type", "navigate", "field", "button" — imperative UI steps
- More than 10 scenarios in a `.feature` file — god feature
- When appearing more than once in a scenario — multiple actions
- Step definitions longer than 10 lines — fat steps
- `sleep`, `wait`, `time.sleep` in step definitions — hardcoded waits
- Global/module-level variables in step files — shared mutable state
