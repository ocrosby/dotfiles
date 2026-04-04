---
description: Guides writing new Gherkin feature files and step definitions following BDD best practices.
paths:
  - "**/*.feature"
---

# Gherkin Feature Development

## Workflow

### 1. Understand the Behavior

- Clarify the capability from the user's perspective
- Identify the actors: who triggers the behavior?
- Identify the outcomes: what is observable when it succeeds? When it fails?
- Gather concrete examples from stakeholders — examples become scenarios

> For features that span multiple domain areas or require designing the full feature suite structure, invoke `/architect` first to plan feature organization and step definition boundaries.

### 2. Write the Feature File

- Start with the user story: As a / I want / So that
- Write the happy path scenario first
- Add edge cases and error scenarios
- Use Background for shared preconditions across all scenarios
- Use Scenario Outline for data-driven variations

### 3. Design Steps

- Write declarative steps — describe intent, not mechanics
- Parameterize reusable values in quotes or angle brackets
- Keep to one When step per scenario — one action under test
- Then steps assert observable outcomes only

### 4. Implement Step Definitions

- Create thin step definitions: parse parameters, delegate, assert
- Extract interaction logic into page objects or API client helpers
- Share state between steps via the World/context object
- Reuse existing step definitions — check common steps before writing new ones

### 5. Wire Up Support

- Set up Before/After hooks for scenario isolation (reset state, clean data)
- Configure environment (base URLs, credentials, browser setup)
- Add custom parameter types for domain concepts

### 6. Review Checklist

- [ ] Feature describes behavior, not implementation
- [ ] Each scenario is independent — no ordering dependencies
- [ ] Steps are declarative — no UI mechanics or implementation details
- [ ] One When step per scenario
- [ ] Background contains only Given steps shared by all scenarios
- [ ] Scenario Outlines have meaningful variation in Examples
- [ ] Step definitions are thin — logic delegated to helpers
- [ ] Tags applied for filtering (`@smoke`, `@slow`, domain tags)
- [ ] Feature file ≤ 10 scenarios
