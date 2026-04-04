---
description: Guides structural refactoring of Go or Python code — improving design, layering, and clarity without changing behavior.
triggers:
  - /refactor
paths:
  - "**/*.go"
  - "**/*.py"
---

# Refactor

Use this skill for structural improvements: extracting modules/packages, fixing layering violations, tightening interfaces, and reducing complexity. This is distinct from `/migrate` (which replaces deprecated patterns) — refactoring changes design, not API versions.

## Workflow

### 1. Understand Before Changing

Read the target file(s) and answer:
- What is this code responsible for?
- Why was it written this way? (Check git log: `git log --follow -p <file>`)
- What constraints or trade-offs drove the current design?

Do not refactor what you do not yet understand.

### 2. Identify the Problem

#### Go smells

| Smell | Symptom |
|---|---|
| God struct/package | One type or package does too many unrelated things |
| Layering violation | Domain code imports HTTP/DB packages, or adapters contain business logic |
| Interface too wide | Interface has >5 methods; callers only use 2-3 of them |
| Concrete dependency | Code depends on a struct rather than an interface |
| Implicit coupling | Two packages share mutable state or call each other circularly |
| Duplicated logic | Same algorithm copied across 3+ places (Rule of Three) |
| Shallow abstraction | Wrapper adds no value — just passes through to one method |

#### Python smells

| Smell | Symptom |
|---|---|
| God module/class | One module or class handles too many unrelated concerns |
| Layering violation | Domain code imports FastAPI/SQLAlchemy/requests, or adapters contain business logic |
| Concrete dependency | Code instantiates a class directly instead of accepting a Protocol |
| Circular imports | Two modules import from each other |
| Duplicated logic | Same algorithm in 3+ places (Rule of Three) |
| Mutable shared state | Module-level variables mutated at runtime |
| Fat route handler | FastAPI route does validation + business logic + persistence directly |

### 3. Plan the Refactor

Before changing any code, state the plan:
- What specifically will change
- What will not change (behavior, public API, or both)
- What tests need to be written first to protect the refactor

Get confirmation before proceeding.

### 4. Write Tests First

If the code under refactor isn't covered by tests, write characterization tests before touching anything — they capture current behavior, not ideal behavior:

```go
// Go
func TestUserService_CreateUser_existingBehavior(t *testing.T) { ... }
```

```python
# Python
def test_create_user_existing_behavior(): ...
```

### 5. Refactor in Small Steps

Apply one change at a time, running tests after each step.

---

#### Go: Extract a package

```bash
# Move related types/functions into a new package, then:
go test ./...    # verify no regressions
go vet ./...     # verify no import cycles
```

#### Go: Narrow an interface

```go
// Before: wide interface used differently by different consumers
type Store interface {
    CreateUser(...) error
    GetUser(...) (*User, error)
    DeleteUser(...) error
    CreateSession(...) error   // unrelated to user concerns
    DeleteSession(...) error
}

// After: split by consumer
type UserStore interface {
    CreateUser(...) error
    GetUser(...) (*User, error)
    DeleteUser(...) error
}

type SessionStore interface {
    CreateSession(...) error
    DeleteSession(...) error
}
```

#### Go: Fix a layering violation

- Move business logic from adapters into the domain service
- Replace concrete type references with interface references
- Inject the dependency via the constructor

---

#### Python: Extract a module

```bash
# Move coherent cluster of functions/classes to a new module, then:
python -c "import mypackage"    # verify no circular imports
pytest                           # verify no regressions
```

#### Python: Replace concrete dependency with Protocol

```python
# Before
class UserService:
    def __init__(self):
        self.repo = PostgresUserRepository()  # hard dependency

# After
from typing import Protocol

class UserRepository(Protocol):
    def save(self, user: User) -> None: ...
    def find_by_email(self, email: str) -> User | None: ...

class UserService:
    def __init__(self, repo: UserRepository) -> None:
        self.repo = repo
```

#### Python: Fix a fat route handler

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

---

### 6. Verify

**Go:**
```bash
go test ./... -race
go vet ./...
golangci-lint run
```

**Python:**
```bash
pytest
ruff check .
ruff format --check .
mypy .    # if mypy is in use
```

Confirm the public API is unchanged, or explicitly note what changed and why.

## Review Checklist

- [ ] No behavior changes — only structural improvements
- [ ] Tests written before refactoring to protect behavior
- [ ] All tests pass after refactoring
- [ ] Layer boundaries respected (domain has no external/framework imports)
- [ ] No new global or module-level mutable state
- [ ] Go: interfaces defined at the consumer side
- [ ] Python: concrete dependencies replaced with Protocol interfaces
- [ ] No circular imports
