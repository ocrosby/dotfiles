---
paths:
  - "**/*.py"
  - "**/docs/**/*.md"
---

# Python Documentation

## Docstrings

- Use Google-style docstrings on all public modules, classes, and functions
- Private/internal functions do not require docstrings unless the logic is non-obvious

### Format

```python
def create_user(name: str, email: str, role: str = "member") -> User:
    """Create a new user and send a welcome notification.

    Args:
        name: Display name for the user.
        email: Email address — must be unique.
        role: Authorization role. Defaults to "member".

    Returns:
        The newly created user with a generated ID.

    Raises:
        DuplicateEmailError: If the email is already registered.
        ValidationError: If the email format is invalid.
    """
```

### Rules

- First line is a concise imperative summary (no period unless multi-sentence)
- `Args:` — one line per parameter, type info lives in the signature not the docstring
- `Returns:` — describe what is returned, not the type
- `Raises:` — list exceptions the caller should handle
- Omit sections that don't apply (no empty `Args:` blocks)

## README

- Every project has a README with: purpose, quickstart, configuration, and development setup
- Quickstart shows `uv sync` and how to run the application
- Configuration documents all environment variables

## API Documentation

- FastAPI apps use Pydantic model docstrings and field descriptions for auto-generated OpenAPI docs
- Add `summary` and `description` to route decorators for non-obvious endpoints
- Tag routes with `tags=["domain"]` for logical grouping in the docs UI
