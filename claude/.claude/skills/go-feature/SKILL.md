---
description: Guides development of new Go features following clean architecture and idiomatic Go patterns.
paths:
  - "**/*.go"
---

# Go Feature Development

## Workflow

### 1. Understand the Feature

- Clarify what the feature does from the user's perspective
- Identify which layer it belongs to: domain, port, adapter, or cmd
- Determine if it needs new HTTP endpoints, CLI commands, or background workers

### 2. Design the Interface

- Define the public API: types, functions, and their signatures
- Design interfaces at the consumer side — small, focused
- Plan configuration via struct fields or functional options

> For features that introduce new packages, significant abstractions, or cross-cutting concerns, invoke `/architect` before implementing to get a comprehensive structural proposal.

### 3. Implement (Domain First)

- Start with domain types and service methods — pure logic, no I/O
- Define port interfaces for any new external dependencies
- Implement adapters: HTTP handlers, DB repositories, API clients
- Wire dependencies in `cmd/` via constructor injection

### 4. Structure

- One package per concern — split at 500 lines
- Domain logic has no external imports beyond stdlib
- Adapters are thin: parse request, delegate to domain, write response
- HTTP handlers use the stdlib `net/http` patterns or a thin router
- Accept `context.Context` as the first parameter on all I/O methods

### 5. Error Handling

- Wrap errors with context: `fmt.Errorf("creating user: %w", err)`
- Define sentinel errors for expected conditions: `var ErrNotFound = errors.New("not found")`
- Return early on error — no deep nesting
- Use custom error types when callers need to inspect details

### 6. Concurrency (if needed)

- Use `errgroup` for parallel work with error propagation
- Pass `context.Context` for cancellation
- Channels have a clear owner — one goroutine creates, one closes
- Ensure every goroutine has a termination path

### 7. Review Checklist

- [ ] All errors checked and wrapped with context
- [ ] Interfaces defined at the consumer, not the implementer
- [ ] Domain logic is pure — no I/O, no external imports
- [ ] Dependencies injected via constructors
- [ ] `context.Context` on all I/O methods
- [ ] No global mutable state
- [ ] Exported symbols have doc comments
