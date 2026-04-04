---
description: Guides structural refactoring of Python code — improving design, layering, and clarity without changing behavior.
triggers:
  - /py-refactor
paths:
  - "**/*.py"
---

# Python Refactor

Use this skill for structural improvements: extracting modules, tightening domain boundaries, replacing concrete dependencies with protocols, and reducing complexity. This is distinct from `/py-migrate` (which replaces deprecated patterns) — refactoring changes design, not API versions.

## Workflow

### 1. Understand Before Changing

Read the target file(s) and answer:
- What is this code responsible for?
- Why was it written this way? (Check git log: `git log --follow -p <file>`)
- What constraints or trade-offs drove the current design?

Do not refactor what you do not yet understand.

### 2. Identify the Problem

Classify the structural issue:

| Smell | Symptom |
|---|---|
| God module/class | One module or class handles too many unrelated concerns |
| Layering violation | Domain code imports FastAPI/SQLAlchemy/requests, or adapters contain business logic |
| Concrete dependency | Code instantiates a class directly instead of accepting a Protocol |
| Circular imports | Two modules import from each other |
| Duplicated logic | Same algorithm in 3+ places (Rule of Three) |
| Mutable shared state | Module-level variables mutated at runtime |
| Shallow wrapper | Class or function adds no value — just delegates with no transformation |
| Fat route handler | FastAPI route does validation + business logic + persistence directly |

### 3. Plan the Refactor

Before changing any code, state the plan:
- What specifically will change
- What will not change (behavior, public API, or both)
- What tests need to be written first to protect the refactor

Get confirmation before proceeding.

### 4. Write Tests First

If the code under refactor isn't covered by tests, write characterization tests before touching anything:

```python
def test_create_user_existing_behavior():
    # captures current behavior — not ideal behavior, current behavior
```

These tests protect against regressions during restructuring.

### 5. Refactor in Small Steps

Apply one change at a time, running `pytest` after each step:

#### Extract a module
- Identify a coherent cluster of functions/classes
- Move them to a new module named after the concept they represent
- Update all import paths
- Verify no circular imports: `python -c "import mypackage"`

#### Replace concrete dependency with Protocol
```python
# Before: concrete dependency
class UserService:
    def __init__(self):
        self.repo = PostgresUserRepository()  # hard dependency

# After: injected Protocol
from typing import Protocol

class UserRepository(Protocol):
    def save(self, user: User) -> None: ...
    def find_by_email(self, email: str) -> User | None: ...

class UserService:
    def __init__(self, repo: UserRepository) -> None:
        self.repo = repo
```

#### Fix a fat route handler
```python
# Before: business logic in the route
@router.post("/users")
async def create_user(body: CreateUserRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter_by(email=body.email).first()
    if existing:
        raise HTTPException(409, "email taken")
    user = User(name=body.name, email=body.email)
    db.add(user)
    db.commit()
    return user

# After: delegate to domain service
@router.post("/users", status_code=201)
async def create_user(
    body: CreateUserRequest,
    service: UserService = Depends(get_user_service),
):
    return service.create_user(name=body.name, email=body.email)
```

#### Fix a layering violation
- Move business logic from adapters (routes, repositories) into domain services
- Domain services should have no FastAPI, SQLAlchemy, or requests imports
- Domain services accept/return domain types, not ORM models or HTTP schemas

#### Extract duplicated logic
- Apply Rule of Three — extract only when the same pattern appears 3+ times
- Extract to the module that owns the concept, not to a generic `utils.py`

### 6. Verify

```bash
pytest                  # no regressions
ruff check .            # no lint issues
ruff format --check .   # no format issues
mypy .                  # no type errors (if mypy is in use)
```

Confirm the public API is unchanged, or explicitly note what changed and why.

## Review Checklist

- [ ] No behavior changes — only structural improvements
- [ ] Tests written before refactoring to protect behavior
- [ ] All tests pass after refactoring
- [ ] Domain layer has no framework or I/O imports
- [ ] Concrete dependencies replaced with Protocol interfaces
- [ ] No new module-level mutable state
- [ ] No circular imports
