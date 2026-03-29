---
paths:
  - "**/steps/**"
  - "**/step_definitions/**"
  - "**/features/**/*.py"
  - "**/features/**/*.ts"
  - "**/features/**/*.rb"
  - "**/features/**/*.go"
---

# Gherkin Step Definition Testing

## Principles

- Step definitions are **glue** — they translate Gherkin into application interactions
- Keep step definitions thin: parse, delegate, assert
- No business logic in steps — delegate to page objects, API clients, or domain helpers
- State shared via the World/context object, reset between scenarios

## Step Definition Patterns

### Thin steps

```python
# GOOD: thin step — delegates to helper
@when('I register with name "{name}" and email "{email}"')
def step_register(context, name, email):
    context.response = context.api.register_user(name=name, email=email)

# BAD: fat step — business logic inline
@when('I register with name "{name}" and email "{email}"')
def step_register(context, name, email):
    payload = {"name": name, "email": email}
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {context.token}"}
    response = requests.post(f"{context.base_url}/users", json=payload, headers=headers)
    context.response = response
```

### Page objects / API clients

Extract interaction logic into reusable helper classes:

```python
class UserAPI:
    def __init__(self, base_url: str, token: str):
        self.base_url = base_url
        self.token = token

    def register_user(self, name: str, email: str) -> Response:
        return requests.post(
            f"{self.base_url}/users",
            json={"name": name, "email": email},
            headers={"Authorization": f"Bearer {self.token}"},
        )
```

### Assertions

```python
# GOOD: clear assertion with context
@then('my account should be created')
def step_account_created(context):
    assert context.response.status_code == 201
    assert "id" in context.response.json()

# GOOD: parameterized error assertion
@then('I should see an error "{message}"')
def step_see_error(context, message):
    assert context.response.status_code == 422
    assert context.response.json()["detail"] == message
```

## Running BDD Tests

```bash
# Python (behave)
behave features/
behave features/auth/login.feature
behave --tags=@smoke

# Python (pytest-bdd)
pytest --bdd features/

# JavaScript/TypeScript (cucumber-js)
npx cucumber-js features/
npx cucumber-js --tags "@smoke"

# Go (godog)
godog run features/
```

## Anti-Patterns

- **Fat steps**: HTTP calls, database queries, and assertions all in one step
- **Shared mutable state**: leaking state between scenarios via module-level variables
- **Hardcoded waits**: `sleep(5)` instead of polling or event-driven assertions
- **Duplicate steps**: same regex in multiple step files — extract to common
- **Implementation coupling**: steps that reference CSS selectors, DB tables, or API paths directly
- **Missing cleanup**: scenarios that leave test data behind, breaking other scenarios
