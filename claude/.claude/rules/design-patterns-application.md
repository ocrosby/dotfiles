# Design Patterns Application

> **Reference catalog**: `rules/design-patterns.md` — all 22 GoF patterns with intent, applicability, structure, and trade-offs.

Patterns are language-agnostic structural solutions. Apply them in Go, Python, Lua, TypeScript, and any other language. When a pattern applies, use it completely and name it explicitly.

## Pattern Recognition Signals

### Creational — when object creation is the problem

| Signal | Pattern |
|---|---|
| Constructor with 5+ parameters, especially optional ones | **Builder** |
| `new ConcreteType()` calls scattered across callers | **Factory Method** |
| Creating families of related objects that must be compatible | **Abstract Factory** |
| Complex object copied with minor variations; template instances | **Prototype** |
| One globally-shared resource (config, connection pool, registry) | **Singleton** |

### Structural — when composition is the problem

| Signal | Pattern |
|---|---|
| Third-party or legacy interface does not match your domain contract | **Adapter** |
| Class hierarchy growing in two independent dimensions | **Bridge** |
| Recursive tree where leaf and container must be treated identically | **Composite** |
| Optional behaviors that combine in many permutations | **Decorator** |
| Complex subsystem requiring multi-step initialization to use | **Facade** |
| Thousands of similar objects exhausting memory | **Flyweight** |
| Cross-cutting concerns (caching, auth, logging, lazy init) around an object | **Proxy** |

### Behavioral — when communication or control flow is the problem

| Signal | Pattern |
|---|---|
| Sequential pipeline of handlers; order or set changes at runtime | **Chain of Responsibility** |
| UI action decoupled from business logic; undo/redo needed | **Command** |
| Collection traversal abstracted from the underlying data structure | **Iterator** |
| Many components with direct circular dependencies on each other | **Mediator** |
| Object state snapshot needed for undo/rollback without exposing internals | **Memento** |
| Multiple listeners to a single event source; dynamic subscription | **Observer** |
| Large `switch`/`if` on an internal state field driving behavior | **State** |
| Large `switch`/`if` selecting an algorithm variant | **Strategy** |
| Multiple classes sharing the same algorithm skeleton with minor variation | **Template Method** |
| New operations needed on a fixed class hierarchy without modifying it | **Visitor** |

## Mandatory Behaviors

**When designing or architecting**: scan for the signals above before finalizing structure. If a signal exists, apply the matching pattern.

**When implementing**: apply the pattern completely. A half-implemented Builder without the Director when one is needed, or a Decorator that does not implement the full Component interface, is worse than no pattern at all.

**Name patterns explicitly**. Use the pattern name in:
- Class/struct/module names: `PaymentAdapter`, `CacheProxy`, `LoggingDecorator`, `NotifierObserver`
- Architecture documentation: "uses Strategy to select the routing algorithm"
- Commit messages: `refactor(routing): extract Strategy pattern for algorithm selection`

**When reviewing code**: flag these as findings:
- **Should Fix**: a recognized signal (telescoping constructor, large type-switch, scattered cross-cutting logic) was not addressed with the appropriate pattern
- **Must Fix**: pattern name is used but the implementation violates the pattern's contract (e.g., a "Factory" that creates concrete types directly without an abstraction)
- **Consider**: a pattern is applied where none was needed (no signal existed)

## Over-Engineering Guard

Do not apply a pattern without a concrete signal. Three stable lines that will never vary do not need a Strategy. An object created in one place does not need a Factory. Apply patterns when the problem they solve is present, not in anticipation of a future problem that may never arrive.

## Language-Specific Notes

### Go
- Component interfaces must be small and defined at the consumer (existing `go-conventions.md` rule)
- Builder: use a `Config` struct or functional options — both are idiomatic Builder variants
- Factory Method: constructor functions (`NewX`) returning interfaces
- Singleton: `sync.Once` for thread-safe lazy initialization
- Observer: channels are first-class — prefer channel-based pub/sub over callback registries
- Decorator: embed the interface, override specific methods, delegate the rest

### Python
- Strategy, Command, Observer: first-class functions and `Protocol` make these lightweight — a callable often suffices instead of a full class hierarchy
- Decorator: Python's `@decorator` syntax maps directly — use it for cross-cutting concerns
- Singleton: module-level instances are effectively singletons; prefer dependency injection over class-level enforcement
- Builder: dataclasses with `__post_init__` validation, or a dedicated builder class for complex construction

### Lua / Neovim
- Factory Method: module-level constructor functions (`M.new(opts)`) returning tables with methods
- Singleton: module-local tables with lazy initialization via `if not M._state then ... end`
- Observer: `nvim_create_autocmd` groups are Neovim's built-in Observer — prefer autocmds over manual callback registries for editor events
- Strategy: function tables (`local strategies = { lsp = ..., treesitter = ... }`) with a dispatch key
- State: a `state` field in the module table with a dispatch table keyed by state name
- Decorator: wrap a module function, calling the original and adding before/after behavior
