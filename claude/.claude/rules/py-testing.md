---
paths:
  - "**/tests/**/*.py"
  - "**/test_*.py"
  - "**/conftest.py"
---

# Python Testing

## Framework

- pytest for all tests
- pytest-mock for mocking — never use `unittest.mock` directly
- pytest-asyncio for async tests

## Structure

```
tests/
├── conftest.py          -- shared fixtures
├── unit/
│   ├── test_services.py -- one test file per module
│   └── test_models.py
└── integration/
    ├── test_api.py      -- FastAPI TestClient tests
    └── test_db.py       -- real database tests
```

## Writing Tests

- Test the public API, not private internals
- One behavior per test, descriptive names: `test_create_user_raises_on_duplicate_email`
- Use fixtures for setup/teardown — avoid `setUp` / `tearDown` methods
- Prefer fakes and in-memory implementations over mocks when practical
- Mock at boundaries (external APIs, databases) not within domain logic
- Use `pytest.raises` for expected exceptions with `match=` for message validation
- Use `pytest.mark.parametrize` for data-driven tests

## Fixtures

```python
@pytest.fixture
def user_service(fake_repo: FakeUserRepo) -> UserService:
    return UserService(repo=fake_repo)
```

- Fixtures return ready-to-use objects with all dependencies injected
- Use `conftest.py` for shared fixtures, local fixtures for test-specific setup
- Scope fixtures appropriately: `function` (default), `module`, `session`

## FastAPI Testing

```python
from fastapi.testclient import TestClient

@pytest.fixture
def client(app: FastAPI) -> TestClient:
    return TestClient(app)

def test_create_user_returns_201(client: TestClient):
    response = client.post("/users", json={"name": "Alice", "email": "a@b.com"})
    assert response.status_code == 201
```

- Use `TestClient` for synchronous tests, `httpx.AsyncClient` for async
- Override dependencies with `app.dependency_overrides` for isolation

## Anti-Patterns

- Testing mock wiring instead of real behavior
- Mocking so heavily that tests validate mock setup, not logic
- Using `unittest.TestCase` — use plain functions with pytest
- Missing `conftest.py` — duplicated fixture code across files
- Testing implementation details that break on refactor
