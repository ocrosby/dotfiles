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

Move related types/functions into a new package, then run `go test ./... && go vet ./...` to verify no regressions and no import cycles.

#### Go: Narrow an interface

Split wide interfaces by consumer — each interface exposes only the methods that specific consumer needs (e.g., `UserStore`, `SessionStore` instead of one `Store` with 5+ methods).

#### Go: Fix a layering violation

Move business logic from adapters into the domain service. Replace concrete type references with interfaces. Inject dependencies via constructors.

---

#### Python: Extract a module

Move a coherent cluster of functions/classes into a new module, then run `python -c "import mypackage"` to verify no circular imports, followed by `pytest`.

#### Python: Replace concrete dependency with Protocol

Define a `Protocol` interface for the dependency, update `__init__` to accept the Protocol type, and delete the direct instantiation. The concrete implementation satisfies the Protocol without inheriting from it.

#### Python: Fix a fat route handler

Route handlers must only parse the request and delegate to a domain service. Move validation, business logic, and persistence into the service layer. The handler's body should be ≤5 lines.

---

#### Neovim/Lua: Split a god init.lua

```
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

Use module-local state (`local _config = {}`). Expose read access via an accessor that returns `vim.deepcopy(_config)` — never export the table reference directly.

#### Neovim/Lua: Make setup() idempotent

Guard with a `local _initialized = false` flag. Pass `{ clear = true }` to `nvim_create_augroup` so re-sourcing doesn't duplicate autocmds.

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
