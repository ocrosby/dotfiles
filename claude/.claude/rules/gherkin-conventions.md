---
paths:
  - "**/*.feature"
---

# Gherkin Conventions

## Principles

- Features describe **behavior from the user's perspective**, not implementation details
- Each scenario is a single, independent example — no coupling between scenarios
- Write declarative steps (what), not imperative steps (how)
- Feature files are living documentation — readable by non-technical stakeholders

## Structure

```gherkin
Feature: User registration
  As a new visitor
  I want to create an account
  So that I can access the platform

  Background:
    Given the registration page is open

  Scenario: Successful registration with valid details
    When I register with name "Alice" and email "alice@example.com"
    Then my account should be created
    And I should receive a welcome email

  Scenario: Registration fails with duplicate email
    Given a user exists with email "alice@example.com"
    When I register with name "Bob" and email "alice@example.com"
    Then I should see an error "Email already registered"
    And no new account should be created
```

## Given / When / Then

- **Given**: establish preconditions — the system state before the action
- **When**: the action the user performs — exactly one action per scenario
- **Then**: the observable outcome — what the user can verify
- **And / But**: continue the previous step type — never start a scenario with And/But
- Keep each step on a single line where possible

## Writing Good Steps

### Declarative over imperative

```gherkin
# GOOD: declarative — what, not how
When I register with name "Alice" and email "alice@example.com"

# BAD: imperative — UI mechanics
When I click the "Name" field
And I type "Alice"
And I click the "Email" field
And I type "alice@example.com"
And I click "Submit"
```

### Consistent voice and tense

- Given: past tense or present state — "a user exists", "the page is open"
- When: present tense — "I register", "I submit the form"
- Then: present tense with "should" — "I should see", "the account should be created"

### Parameterize for reuse

```gherkin
# GOOD: parameterized — step definition reusable
Then I should see an error "<message>"

# BAD: hardcoded — new step definition per message
Then I should see the duplicate email error
```

## Scenario Outlines

Use for data-driven scenarios with multiple examples:

```gherkin
Scenario Outline: Password validation
  When I register with password "<password>"
  Then I should see "<result>"

  Examples:
    | password   | result                        |
    | ab         | Password must be 8+ characters |
    | abcdefgh   | Account created                |
    | abcDE12!@  | Account created                |
```

Use only when scenarios share identical steps and differ only in data.

## Tags

- `@wip` — work in progress, not yet automated
- `@smoke` — critical path tests for quick validation
- `@slow` — long-running scenarios, exclude from fast feedback loops
- Domain tags: `@auth`, `@billing`, `@onboarding` — group by feature area
- Never use tags to control step behavior — tags are for filtering and organization

## Background

- Use for preconditions shared by **every** scenario in the feature
- Keep it short — if Background exceeds 3 steps, the scenarios may belong in separate features
- Never put When or Then in Background — only Given steps

## Anti-Patterns

- **Scenario coupling**: scenarios that depend on state from previous scenarios
- **Imperative steps**: clicking buttons and filling fields instead of describing intent
- **Incidental details**: including data that doesn't affect the outcome
- **God feature**: one feature file with 20+ scenarios — split by behavior
- **Testing implementation**: steps that reference database tables, API endpoints, or CSS selectors
- **Conjunctive steps**: "Given A and B and C" — split into separate Given lines
- **Missing examples**: Scenario Outline without meaningful variation in the Examples table
