---
paths:
  - "**/*.feature"
  - "**/steps/**"
  - "**/step_definitions/**"
---

# Gherkin Project Structure

## Layout

```
features/
├── auth/
│   ├── login.feature
│   ├── registration.feature
│   └── password_reset.feature
├── billing/
│   ├── subscription.feature
│   └── invoicing.feature
├── steps/                     -- step definitions (language-specific)
│   ├── auth_steps.py          -- or .rb, .ts, .go
│   ├── billing_steps.py
│   └── common_steps.py        -- shared steps (navigation, assertions)
├── support/
│   ├── env.py                 -- environment setup, hooks
│   ├── world.py               -- shared context/state
│   └── helpers.py             -- test utilities
└── fixtures/
    └── test_data.json         -- shared test data
```

## Organization Rules

- **One behavior per feature file** — a feature file covers one capability
- **Group by domain**, not by type — `auth/login.feature` not `login/feature.feature`
- **One step file per domain area** — mirrors the feature directory structure
- **Shared steps** in a `common_steps` file — generic assertions, navigation, time manipulation
- **Feature files ≤ 10 scenarios** — split into sub-features when exceeded

## Step Definitions

### Naming

- Step definitions match the domain language used in feature files
- One step definition file per feature area
- Common/reusable steps in a dedicated shared file
- Never duplicate step definitions — extract shared patterns

### Design

- Steps are thin: parse parameters, delegate to page objects or domain helpers, assert outcomes
- No business logic in step definitions — they are glue between Gherkin and application
- Use the World/context object for sharing state between steps within a scenario
- Reset state between scenarios — no leakage

### Parameter Types

```gherkin
# Define custom parameter types for domain concepts
# Instead of raw strings:
Given a user with email "alice@example.com"

# Use typed parameters where the framework supports it:
Given a {user} with email {email}
```

## Hooks

- `Before` / `After` for scenario-level setup/teardown
- `BeforeAll` / `AfterAll` for suite-level setup (database, servers)
- Tag-filtered hooks for conditional setup: `@browser` triggers browser launch
- Keep hooks minimal — heavy setup belongs in Given steps or fixtures

## Feature File Conventions

- Feature name matches the filename: `registration.feature` → `Feature: Registration`
- Scenarios ordered from happy path to edge cases to error cases
- Use the user story format in the feature description: As a / I want / So that
- One blank line between scenarios, two blank lines between sections
