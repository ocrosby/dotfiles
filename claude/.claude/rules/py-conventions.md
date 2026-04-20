---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/uv.lock"
---

# Python Conventions

## Principles

- DRY, SOLID, and Clean Code principles at all times
- Apply the Rule of Three: tolerate duplication until the third occurrence, then abstract
- Composition over inheritance
- Dependency injection consistently — pass dependencies in, never hardcode them
- Push side effects to the edges; keep core logic pure
- Hexagonal architecture (ports and adapters) for all server applications

**These principles are intentional design decisions — do not simplify them away.** When code grows complex (many injected dependencies, verbose constructors, deep port/adapter layering), the correct response is to split and simplify the design, not to revert to module-level singletons, hardcoded dependencies, or flat structure. Complexity is a signal to refactor, not to abandon the principle.

## Design Patterns

Use Gang of Four patterns where they reduce complexity:

- Strategy for variant behavior (prefer callables or Protocol classes)
- Adapter to wrap external clients and SDKs
- Facade to simplify multi-step workflows
- Factory for object creation with complex setup
- Observer/Pub-Sub for event-driven decoupling
- Decorator for cross-cutting concerns (logging, caching, retry)
- Command for encapsulating operations

Do not force a pattern where a simple function will do.

## Architecture (Server Applications)

Use hexagonal architecture (ports and adapters) for all servers:

- **Domain**: Pure business logic with no framework or infrastructure imports
- **Ports**: Abstract interfaces (Protocol classes) defining how the domain interacts with the outside world — both driving (inbound) and driven (outbound)
- **Adapters**: Concrete implementations of ports — HTTP controllers, database repositories, API clients, message queue consumers
- **Application**: Use cases that orchestrate domain logic through ports

Keep the dependency direction inward: adapters depend on ports, ports depend on domain, domain depends on nothing.

## REST APIs

- Use FastAPI for all RESTful APIs
- Define request/response models with Pydantic `BaseModel`
- Use dependency injection via `Depends()` for shared logic (auth, DB sessions, config)
- Organize routes with `APIRouter` — one router per domain area
- Use `lifespan` context manager for startup/shutdown lifecycle, not `on_event`
- Return appropriate HTTP status codes explicitly (`status_code=201` for creation, etc.)

## MCP Servers

- Use FastMCP for all MCP (Model Context Protocol) servers
- Declare tools with `@mcp.tool()`, resources with `@mcp.resource()`
- Use type hints and docstrings on tool functions — FastMCP derives the schema from them
- Keep tool functions thin: validate input, delegate to domain logic, return results
- Use `Context` for logging and progress reporting within tools

## CLI Applications

- Use click for all command-line interfaces
- Group related commands with `@click.group()`
- Use click's built-in type validation and help generation

## Type Hints

- Type hints on all function signatures (parameters and return types)
- Type hints on class attributes and instance variables
- Use `Protocol` for structural subtyping over ABC where possible
- Prefer `X | Y` over `Union[X, Y]` and `X | None` over `Optional[X]` (3.10+)
- Use `Self` from `typing` for methods that return `self` or a new instance of the same class (3.11+)
- Mark overriding methods with `@override` from `typing` so type checkers catch mismatches (3.12+)
- Use `type Alias = ...` for type aliases instead of `TypeAlias` annotation (3.12+)
- Use `TypeVar`, generics, and `ParamSpec` where they improve clarity

## Testing

- pytest for all tests
- pytest-mock for all mocking — never use unittest.mock directly
- Aim for the highest possible unit test coverage
- Isolate side effects; use fixtures for boundary dependencies
- Prefer fakes and in-memory implementations over mocks when practical
- One behavior per test, descriptive test names

## Package Management

- Use uv as the package manager everywhere
- `uv init`, `uv add`, `uv run`, `uv sync` — never pip directly
- After any change to `pyproject.toml` (dependencies, version, metadata), run `uv lock` immediately. Do not skip this step — an out-of-sync `uv.lock` does not fail the current CI run; it fails the *next* one, making the cause invisible.

**This is non-negotiable — do not defer it.** The failure is always delayed by one merge, which makes it look like the next PR broke CI when it didn't.

In semantic-release `build_command`, `uv lock` must run *before* any `uv run` step. If `uv run` is called first against a freshly bumped `pyproject.toml`, it may fail on the stale lockfile and — due to `&&` short-circuit — `uv lock` never runs. The stale lockfile gets committed and breaks `uv sync --locked` on the next CI trigger.

## Idiomatic Python

- Iterate directly over collections, never `range(len(...))`
- Use `enumerate()` for index + value, `zip()` for parallel iteration
- Use `reversed()` instead of manual reverse indexing
- Prefer `', '.join(list)` over string concatenation with `+=`
- Unpack sequences directly: `a, b, c = tuple`
- Use keyword arguments for clarity at call sites
- Use named tuples or dataclasses for multi-value returns
- Prefer list comprehensions and generator expressions over manual loops
- Use `defaultdict` and `Counter` from collections instead of manual counting/grouping
- Use `with` statements for all resource management
- Use `deque` when appending/removing from both ends of a sequence
- Factor cross-cutting administrative logic into decorators
- Use truth value testing (`if items:`) instead of explicit length checks; use `is None` when specifically checking for `None`
- Use `in` for multiple value checks: `if x in ("a", "b", "c")` instead of chained `or`
- Use `or` for default values: `name = value or "default"`
- Prefer compound assignment operators (`+=`, `-=`, etc.)
- Use `match`/`case` (structural pattern matching) for complex dispatch on type or structure instead of `if/elif` chains (3.10+)
- Use `zip(..., strict=True)` when both iterables must be the same length (3.10+)
- Use `asyncio.TaskGroup` instead of `asyncio.gather()` for concurrent tasks — better error propagation and cancellation (3.11+)
- Use `asyncio.timeout()` context manager instead of `asyncio.wait_for()` for timeout control (3.11+)
- Use `except*` and `ExceptionGroup` when handling errors from concurrent tasks (3.11+)
- Add `slots=True` to `@dataclass` for memory-critical domain entities (3.10+)
- Use `itertools.batched(iterable, n)` to chunk a sequence into fixed-size groups (3.12+)

## Code Quality

- ruff for linting, import sorting, and formatting (`ruff check` + `ruff format`) — replaces black
- Functions ≤ 30 lines, cyclomatic complexity ≤ 7
- Files ≤ 300 lines; split when exceeded

