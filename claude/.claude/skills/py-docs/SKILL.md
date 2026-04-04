---
description: Generates and audits Python documentation following Google-style docstring conventions.
triggers:
  - /py-docs
paths:
  - "**/*.py"
---

# Python Documentation Writer

## Workflow

### 1. Scan for Missing Documentation

Find all public modules, classes, and functions without docstrings:

```bash
# Functions and classes without docstrings
grep -n "^def [a-z]\|^class [A-Z]" **/*.py
```

Report which public symbols are missing docstrings (skip `_private` and `__dunder__` methods unless logic is non-obvious).

### 2. Write Module Docstrings

Every public module should have a module-level docstring as the first statement:

```python
"""User management domain — creation, authentication, and profile operations.

This module exposes UserService as the primary entry point. It depends on
a UserRepository protocol implementation for persistence.
"""
```

### 3. Document Public Classes

```python
class UserService:
    """Manages user lifecycle operations.

    Coordinates user creation, authentication, and profile updates.
    Requires a UserRepository for persistence and an EmailService
    for notifications.

    Attributes:
        repository: The persistence adapter for user storage.
        email_service: The notification adapter for sending emails.
    """
```

### 4. Document Public Functions and Methods

Use Google-style format:

```python
def create_user(name: str, email: str, role: str = "member") -> User:
    """Create a new user and send a welcome notification.

    Args:
        name: Display name for the user.
        email: Email address — must be unique across all accounts.
        role: Authorization role. Defaults to "member".

    Returns:
        The newly created user with a generated ID and timestamps.

    Raises:
        DuplicateEmailError: If the email is already registered.
        ValidationError: If the email format is invalid.
    """
```

### 5. Format Rules

- First line is a concise imperative summary — no period for single-line, period for multi-sentence
- `Args:` — one line per parameter; type info lives in the signature, not here
- `Returns:` — describe what is returned, not its type
- `Raises:` — list only exceptions the *caller* should handle
- Omit sections that don't apply — no empty `Args:` or `Returns:` blocks
- Private/internal functions (`_name`) do not require docstrings unless non-obvious

### 6. FastAPI Route Documentation

For FastAPI routes, add `summary` and `description` to non-obvious endpoints:

```python
@router.post(
    "/users",
    status_code=201,
    summary="Register a new user",
    description="Creates a user account and sends a verification email. "
                "Returns 409 if the email is already registered.",
    tags=["users"],
)
```

### 7. Verify

```bash
python -m pydoc <module>      # Verify docstrings render correctly
# Or if using mkdocs/sphinx:
make docs                      # Build and inspect rendered output
```

## Review Checklist

- [ ] Every public module has a module-level docstring
- [ ] Every public class has a docstring describing its purpose and key attributes
- [ ] Every public function documents Args, Returns, and Raises where applicable
- [ ] No empty sections in docstrings
- [ ] FastAPI routes have `summary` tags for non-obvious endpoints
- [ ] Private/internal code omits docstrings unless logic is non-obvious
