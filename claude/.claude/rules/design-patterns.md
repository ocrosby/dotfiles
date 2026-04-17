# Design Patterns Reference

All 22 Gang-of-Four patterns. Source: https://refactoring.guru/design-patterns

---

## Creational Patterns

### 1. Abstract Factory

**Intent:** Produce families of related objects without specifying their concrete classes.

**Use when:**
- Code must work with various families of related products without depending on their concrete implementations.
- A class has multiple Factory Methods that obscure its primary responsibility.
- You need to support future product families without breaking existing client code.

**Participants:**
- **Abstract Products** — Interfaces for each distinct product type.
- **Concrete Products** — Specific implementations grouped by variant.
- **Abstract Factory** — Interface declaring creation methods for all abstract product types.
- **Concrete Factories** — One per variant; creates only the matching product variants.
- **Client** — Works exclusively through abstract interfaces.

**Pros:** Guarantees product compatibility within a family; decouples client from concrete classes; new variants add without modifying client code.

**Cons:** Substantial complexity — many new interfaces and classes.

---

### 2. Builder

**Intent:** Construct complex objects step by step, producing different types and representations from the same construction code.

**Use when:**
- A constructor has numerous optional parameters (telescoping overloads).
- You need different representations of the same product using the same construction process.
- Clients must not access an incomplete (partially constructed) object.

**Participants:**
- **Builder Interface** — Declares common construction steps.
- **Concrete Builders** — Implement construction steps differently per product representation.
- **Products** — The resulting objects; different builders may produce incompatible types.
- **Director** — Defines specific construction sequences. Optional but useful for standard configurations.
- **Client** — Associates a builder with the director; retrieves the final product from the builder.

**Pros:** Step-by-step construction with deferred execution; same construction code for different representations; separates construction from business logic.

**Cons:** Requires multiple new classes even for moderately simple objects.

---

### 3. Factory Method

**Intent:** Define an interface for creating an object in a superclass, but let subclasses decide which class to instantiate.

**Use when:**
- The exact type of objects to create is unknown ahead of time.
- You want library users to extend internal components by overriding the factory method.
- You need to reuse expensive objects from a pool rather than recreating them.

**Participants:**
- **Product** — The common interface all concrete products implement.
- **Concrete Products** — Various implementations of the product interface.
- **Creator** — Declares the abstract factory method; may provide a default implementation.
- **Concrete Creators** — Override the factory method to return a specific product type.

**Pros:** Decouples creators from concrete products; new product types add without changing existing code.

**Cons:** Requires many subclasses; overkill if there is only ever one product type.

---

### 4. Prototype

**Intent:** Create new objects by copying existing ones without coupling code to their concrete classes.

**Use when:**
- Code should not depend on concrete classes of objects it needs to copy.
- You want to reduce subclass proliferation where subclasses exist solely for different initial configurations.

**Participants:**
- **Prototype Interface** — Declares the `clone()` method.
- **Concrete Prototype** — Implements `clone()` by copying all field values; can access private fields of same-class instances.
- **Client** — Calls `clone()` rather than invoking a constructor.
- **Prototype Registry** (optional) — A catalog of pre-built named prototypes for convenient retrieval.

**Pros:** Decouples cloning from concrete class names; eliminates repeated initialization code; alternative to subclassing for configuration variants.

**Cons:** Circular references between objects make cloning significantly harder.

---

### 5. Singleton

**Intent:** Ensure a class has only one instance and provide a global access point to it.

**Use when:**
- Exactly one instance must exist and be accessible throughout the program.
- You need stricter control over global variables.

**Participants:**
- **Static Instance Field** — Holds the single class instance.
- **Private Constructor** — Prevents external instantiation.
- **Static Creation Method (`getInstance`)** — Returns the cached instance, creating it on first call.

**Pros:** Guarantees a single instance; controlled global access; lazy initialization.

**Cons:** Violates Single Responsibility Principle; masks poor design; requires care in multithreaded environments; resists mocking in tests.

---

## Structural Patterns

### 6. Adapter

**Intent:** Allow objects with incompatible interfaces to collaborate by wrapping one with a translator.

**Use when:**
- You have a useful class you cannot modify and need to make it compatible with existing code.
- You want to reuse subclasses that lack common functionality without duplicating code in the superclass.

**Participants:**
- **Client** — Contains business logic expecting the Client Interface.
- **Client Interface** — The protocol the client works through.
- **Service** — The incompatible existing class.
- **Adapter** — Implements the Client Interface while wrapping the Service; translates calls and converts data.

**Pros:** Separates interface conversion from business logic; new adapters add without modifying client code.

**Cons:** Increases complexity; sometimes simpler to modify the service directly if you own it.

---

### 7. Bridge

**Intent:** Split a large class into two separate hierarchies — abstraction and implementation — which can be developed independently.

**Use when:**
- A class needs to extend in multiple independent dimensions (would produce exponential subclasses).
- You need to switch implementations at runtime.

**Participants:**
- **Abstraction** — High-level control layer; holds a reference to an Implementation and delegates work to it.
- **Implementation Interface** — Declares operations that Concrete Implementations provide.
- **Concrete Implementations** — Platform-specific or variant-specific code.
- **Refined Abstractions** — Variants of control logic.
- **Client** — Links an Abstraction with a specific Implementation at initialization.

**Pros:** Platform-independent high-level code; implementation can be swapped at runtime; satisfies Open/Closed and Single Responsibility.

**Cons:** May unnecessarily complicate cohesive classes unlikely to change in multiple dimensions.

---

### 8. Composite

**Intent:** Compose objects into tree structures and work with them as if they were individual objects.

**Use when:**
- The application's core model can be represented as a tree.
- Client code should treat simple and complex elements uniformly.

**Participants:**
- **Component Interface** — Declares common operations for both leaves and composites.
- **Leaf** — A basic element with no children; does the actual work.
- **Container (Composite)** — Has sub-elements; delegates operations to children and aggregates results.
- **Client** — Works exclusively through the Component interface.

**Pros:** Polymorphism and recursion simplify complex tree work; new element types integrate without modifying existing code.

**Cons:** Common interface may require overgeneralization; confusing when leaf and container responsibilities differ significantly.

---

### 9. Decorator

**Intent:** Attach new behaviors to objects dynamically by placing them inside wrapper objects.

**Use when:**
- Extra behaviors should be assignable to objects at runtime without modifying calling code.
- Extending behavior via inheritance is impractical (e.g., a `final` class).
- Business logic can be structured as optional composable layers.

**Participants:**
- **Component Interface** — Common interface for both the wrapped object and all wrappers.
- **Concrete Component** — The base object with fundamental behavior.
- **Base Decorator** — Holds a reference to a wrapped Component; delegates all operations to it.
- **Concrete Decorators** — Add behavior before and/or after delegating to the wrapped object.
- **Client** — Wraps the base component in one or more decorators in any combination.

**Pros:** Extend behavior without subclassing; add/remove responsibilities at runtime; stack multiple behaviors; Single Responsibility per decorator.

**Cons:** Hard to remove a specific wrapper from the middle of a stack; behavior may be order-dependent; deep stacks are complex to configure.

---

### 10. Facade

**Intent:** Provide a simplified interface to a complex subsystem.

**Use when:**
- You need a limited but straightforward interface to a complex subsystem.
- A subsystem is growing increasingly complex and demands more configuration boilerplate.
- You want to layer subsystems using facades as entry points to reduce inter-subsystem coupling.

**Participants:**
- **Facade** — High-level access to subsystem functionality; knows which subsystem classes to use and in what order.
- **Additional Facades** — Optional; prevent a single facade from becoming a god object.
- **Complex Subsystem** — Many interdependent objects requiring deep knowledge to use.
- **Client** — Interacts only with the Facade.

**Pros:** Isolates client code from subsystem complexity.

**Cons:** Can become a god object coupled to all classes in the application if not carefully managed.

---

### 11. Flyweight

**Intent:** Fit more objects in available RAM by sharing common state among multiple objects.

**Use when:**
- An application must spawn a huge number of similar objects and RAM is constrained.
- Objects contain significant duplicate state that can be extracted and shared.

**Participants:**
- **Flyweight** — Contains only *intrinsic* (unchanging, shareable) state; must be immutable.
- **Context** — Holds *extrinsic* (unique per instance) state alongside a reference to a Flyweight.
- **Flyweight Factory** — Manages a pool of Flyweights; returns an existing one if intrinsic state matches.
- **Client** — Stores or computes extrinsic state; passes it to Flyweight methods at call time.

**Pros:** Significant RAM savings when handling millions of similar objects.

**Cons:** Trades RAM for CPU if extrinsic state must be recalculated on every call; state separation confuses developers unfamiliar with the pattern.

---

### 12. Proxy

**Intent:** Provide a substitute or placeholder for another object to control access to it.

**Use when:**
- **Lazy initialization** — Delay creating a heavyweight object until needed.
- **Access control** — Restrict which clients can use a service.
- **Remote service** — Handle network communication transparently.
- **Logging** — Maintain a request history before delegating.
- **Caching** — Store and reuse responses to recurring identical requests.

**Participants:**
- **Service Interface** — Declares the contract both the Proxy and real Service must follow.
- **Service** — The real object providing business logic.
- **Proxy** — Holds a reference to the Service; applies cross-cutting concerns before/after delegating.
- **Client** — Works with both Service and Proxy through the same interface.

**Pros:** Controls access without client awareness; manages service lifecycle; new proxy types add without changing service or client.

**Cons:** Additional classes increase complexity; proxy processing can introduce latency.

---

## Behavioral Patterns

### 13. Chain of Responsibility

**Intent:** Pass a request along a chain of handlers, where each handler decides to process or forward it.

**Use when:**
- Multiple handlers can process a request but the exact type and sequence are unknown beforehand.
- The set of handlers and their order must change at runtime.

**Participants:**
- **Handler Interface** — Declares the request-processing method and optionally a method to set the next handler.
- **Base Handler** — Stores next handler reference; default implementation passes request forward.
- **Concrete Handlers** — Process specific request types or forward to the next link.
- **Client** — Assembles the chain; can send requests to any handler, not necessarily the first.

**Pros:** Explicit control over handling order; decouples sender from receivers; new handlers add without modifying existing ones.

**Cons:** Some requests may go unhandled if no handler in the chain claims them.

---

### 14. Command

**Intent:** Turn a request into a stand-alone object containing all information about the request.

**Use when:**
- You want to parameterize objects with operations or pass requests as method arguments.
- You need to queue operations, schedule execution, or execute remotely.
- You want reversible operations (undo/redo) via an operation history stack.

**Participants:**
- **Sender (Invoker)** — Triggers requests by executing a stored command; does not know how it's fulfilled.
- **Command Interface** — Declares `execute()` (and optionally `undo()`).
- **Concrete Commands** — Encapsulate a request; hold a reference to the Receiver and parameters.
- **Receiver** — The object containing the actual business logic.
- **Client** — Creates Command objects, configures them with Receivers, assigns them to Senders.

**Pros:** Decouples invokers from receivers; supports undo/redo; commands can be queued, serialized, or composed into macros.

**Cons:** Increases complexity through additional abstraction layers.

---

### 15. Iterator

**Intent:** Traverse elements of a collection without exposing its underlying representation.

**Use when:**
- Collections have complex internal structures clients should not be coupled to.
- Your code must work with various or unknown collection types uniformly.

**Participants:**
- **Iterator Interface** — Declares `getNext()`, `hasMore()`, optionally `rewind()`.
- **Concrete Iterators** — Implement a specific traversal algorithm; each maintains independent position state.
- **Collection Interface** — Declares a factory method for creating compatible iterators.
- **Concrete Collections** — Return appropriate Concrete Iterator instances.

**Pros:** Separates traversal from collection classes; multiple independent traversals can run in parallel; lazy traversal supported.

**Cons:** Overkill for simple collections; may be less efficient than direct access in specialized structures.

---

### 16. Mediator

**Intent:** Reduce chaotic dependencies between objects by forcing them to collaborate through a central mediator.

**Use when:**
- Classes are tightly coupled due to numerous interdependencies and are hard to modify.
- Components cannot be reused in different contexts because they depend too heavily on collaborators.

**Participants:**
- **Mediator Interface** — Declares notification methods that components use to communicate.
- **Concrete Mediator** — Encapsulates coordination logic; stores references to all managed components.
- **Components** — Contain business logic; hold a reference only to the Mediator, never to each other.

**Pros:** Centralizes complex relationships; reduces coupling; components become independently reusable.

**Cons:** Mediators can evolve into god objects if they absorb too much responsibility.

---

### 17. Memento

**Intent:** Save and restore the previous state of an object without exposing its implementation details.

**Use when:**
- Snapshots of object state are needed to support undo/redo or rollback.
- Direct access to the object's fields would violate encapsulation.

**Participants:**
- **Originator** — Creates Memento objects from its own state and restores itself from them.
- **Memento** — Immutable value object storing a snapshot; only the Originator accesses its internals.
- **Caretaker** — Decides when to snapshot and restore; maintains a history stack; never modifies a Memento.

**Pros:** Snapshots without violating encapsulation; Originator is simplified by offloading history management.

**Cons:** High RAM consumption if snapshots are large and frequent; dynamically typed languages cannot guarantee Memento immutability.

---

### 18. Observer

**Intent:** Define a subscription mechanism to automatically notify multiple objects about events.

**Use when:**
- Modifications to one object require updating others, but the set of dependents is unknown or changes dynamically.
- Some objects need to observe others only temporarily or conditionally.

**Participants:**
- **Publisher (Subject)** — Maintains a subscription registry; notifies all registered subscribers on events.
- **Subscriber Interface** — Declares the notification method (`update(event)`).
- **Concrete Subscribers** — Perform specific actions upon receiving notifications.
- **Client** — Creates publishers and subscribers, then registers subscribers with publishers.

**Pros:** New subscriber types add without modifying publisher code; relationships established dynamically at runtime.

**Cons:** Subscribers are notified in an unpredictable order; unaware subscribers can cause cascading updates.

---

### 19. State

**Intent:** Let an object alter its behavior when its internal state changes, appearing as if it changed its class.

**Use when:**
- An object behaves differently depending on its current state and the number of states is large.
- Methods are polluted with large conditionals switching behavior based on a state field.

**Participants:**
- **Context** — Holds a reference to a Concrete State; delegates state-specific work to it; exposes a state setter.
- **State Interface** — Declares the state-specific methods.
- **Concrete States** — Encodes behavior for one specific state; may trigger transitions via the Context's setter.

**Pros:** State-specific code in focused classes; new states add without modifying Context or existing states; eliminates large conditionals.

**Cons:** Overhead for simple state machines with few states or infrequent transitions.

---

### 20. Strategy

**Intent:** Define a family of algorithms, encapsulate each in a separate class, and make them interchangeable at runtime.

**Use when:**
- You need to swap between algorithm variants at runtime.
- Similar classes differ only in the way they execute a core behavior.
- A class has massive conditionals selecting between algorithm variants.

**Participants:**
- **Context** — Holds a reference to one Strategy; delegates algorithm-specific work to it; provides a setter.
- **Strategy Interface** — Declares the single common method all Concrete Strategies implement.
- **Concrete Strategies** — Each provides a different algorithm implementation.
- **Client** — Creates Strategy objects, passes them to the Context, and can replace them at runtime.

**Pros:** Algorithms swappable at runtime; isolated from calling code; replaces inheritance with composition; new strategies add without modifying Context.

**Cons:** Unnecessary complexity if only a few stable algorithms; clients must understand differences to choose correctly.

---

### 21. Template Method

**Intent:** Define the skeleton of an algorithm in a base class, deferring specific steps to subclasses.

**Use when:**
- You want clients to extend only particular steps, not the algorithm's overall structure.
- Several classes share nearly identical algorithms with minor differences.

**Participants:**
- **Abstract Class** — Declares the `templateMethod()` (marked `final`); calls step methods in a fixed order; declares abstract steps, optional steps, and hooks.
- **Concrete Classes** — Override only the abstract steps; never the template method itself.

**Step types:** *Abstract* (must override), *Optional* (have defaults), *Hooks* (empty extension points).

**Pros:** Clients customize steps without affecting structure; duplicate code consolidates into the superclass.

**Cons:** Client flexibility constrained by the predefined skeleton; risk of LSP violations if a subclass suppresses a default step.

---

### 22. Visitor

**Intent:** Separate an algorithm from the objects it operates on, allowing new operations without modifying those objects.

**Use when:**
- You need to perform operations on all elements of a complex object structure.
- You want to clean up primary classes by moving auxiliary behaviors elsewhere.

**Participants:**
- **Visitor Interface** — Declares a `visit(ConcreteElementX)` method for each Concrete Element type.
- **Concrete Visitors** — Implement behavior for each visitor operation × element type combination.
- **Element Interface** — Declares `accept(Visitor)`.
- **Concrete Elements** — Implement `accept()` by calling `visitor.visitConcreteElementX(this)`.
- **Client** — Passes Visitor objects to Element structures via `accept()`.

**Mechanism:** *Double Dispatch* — `element.accept(visitor)` resolves the element type; `visitor.visitX(this)` resolves the operation. No `instanceof` checks needed.

**Pros:** New operations add without modifying element classes; related behaviors consolidated in one Visitor.

**Cons:** Adding a new element type requires updating every existing Visitor; Visitors may lack access to private element fields.
