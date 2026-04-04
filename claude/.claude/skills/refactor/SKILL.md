---
description: Guides structural refactoring of Go, Python, or Neovim code — improving design, layering, and clarity without changing behavior.
triggers:
  - /refactor
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
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

#### Neovim/Lua smells

| Smell | Symptom |
|---|---|
| God init.lua | Single file handles config, commands, keymaps, autocmds, and business logic |
| Global state pollution | Module-level tables exported and mutated by callers |
| Vimscript leakage | `vim.cmd` string commands where Lua API exists |
| Missing idempotency | `setup()` crashes or duplicates state on second call |
| Unchecked API calls | No `pcall` around fallible nvim API calls |
| Hardcoded buffer numbers | `0` passed where `bufnr` should be parameterized |
| Hot-path `require()` | Module loaded inside a frequently-called callback |

### 3. Plan the Refactor

Before changing any code, state the plan:
- What specifically will change
- What will not change (behavior, public API, or both)
- What tests need to be written first to protect the refactor

Get confirmation before proceeding.

### 4. Write Characterization Tests First (mandatory)

**Do not touch any production code until characterization tests are in place.** This is non-negotiable — without them, you have no way to know if the refactor broke anything.

If the code is already covered by tests that verify its behavior, proceed. If not, write characterization tests first — they capture current behavior, not ideal behavior:

```go
// Go
func TestUserService_CreateUser_existingBehavior(t *testing.T) { ... }
```

```python
# Python
def test_create_user_existing_behavior(): ...
```

```lua
-- Neovim (plenary)
describe("plugin.core", function()
  it("existing behavior: setup is idempotent", function() ... end)
end)
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

#### Neovim/Lua: Split a god init.lua

```
-- Before: everything in lua/plugin-name/init.lua
-- After: split into focused modules:
lua/plugin-name/
  init.lua       -- setup(opts), public API surface only
  config.lua     -- defaults + vim.tbl_deep_extend merge
  commands.lua   -- nvim_create_user_command registrations
  keymaps.lua    -- vim.keymap.set registrations
  autocmds.lua   -- nvim_create_autocmd registrations
  core.lua       -- business logic, no vim.api imports
```

Each module is required lazily from `init.lua`; `core.lua` has no Neovim API imports.

#### Neovim/Lua: Fix global state

```lua
-- Before: exported mutable state
local M = {}
M.config = {}   -- callers can mutate this directly

-- After: module-local state, exposed via accessors
local M = {}
local _config = {}

function M.setup(opts)
  _config = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.get_config()
  return vim.deepcopy(_config)  -- return a copy, not the reference
end
```

#### Neovim/Lua: Make setup() idempotent

```lua
-- Before: crashes or duplicates on second call
function M.setup(opts)
  vim.api.nvim_create_augroup("MyPlugin", {})  -- not cleared on re-source
  vim.api.nvim_create_autocmd("BufEnter", { ... })
end

-- After: safe to call multiple times
local _initialized = false

function M.setup(opts)
  _config = vim.tbl_deep_extend("force", defaults, opts or {})
  if _initialized then return end
  _initialized = true
  vim.api.nvim_create_augroup("MyPlugin", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", { group = "MyPlugin", ... })
end
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

**Neovim/Lua:**
```bash
# Run plugin test suite
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Check for deprecated API usage
stylua --check lua/
luacheck lua/    # if luacheck is configured
```

Confirm the public API is unchanged, or explicitly note what changed and why.

## Review Checklist

- [ ] No behavior changes — only structural improvements
- [ ] Tests written before refactoring to protect behavior
- [ ] All tests pass after refactoring
- [ ] **Go**: layer boundaries respected, interfaces at consumer side
- [ ] **Python**: domain has no framework/I/O imports, Protocols used
- [ ] **Neovim**: `setup()` is idempotent, no global state exported
- [ ] No circular imports / circular requires
- [ ] No new mutable module-level state
