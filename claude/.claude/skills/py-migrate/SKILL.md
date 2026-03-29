---
description: Identifies and replaces deprecated or outdated Python patterns with modern equivalents.
paths:
  - "**/*.py"
---

# Python Migration Guide

## Workflow

1. **Scan** the codebase for outdated patterns
2. **Identify** the modern replacement
3. **Replace** preserving behavior
4. **Verify** with tests

## Common Migrations

### Testing

| Outdated | Modern |
|---|---|
| `unittest.TestCase` | Plain pytest functions |
| `unittest.mock.patch` | `pytest-mock` (`mocker.patch`) |
| `setUp` / `tearDown` | pytest fixtures |
| `self.assertEqual(a, b)` | `assert a == b` |
| `self.assertRaises(E)` | `pytest.raises(E)` |

### Type Hints

| Outdated | Modern (Python 3.10+) |
|---|---|
| `typing.List[int]` | `list[int]` |
| `typing.Dict[str, int]` | `dict[str, int]` |
| `typing.Tuple[int, ...]` | `tuple[int, ...]` |
| `typing.Optional[str]` | `str \| None` |
| `typing.Union[str, int]` | `str \| int` |
| `typing.Callable[[int], str]` | `collections.abc.Callable[[int], str]` |

### Package Management

| Outdated | Modern |
|---|---|
| `pip install` | `uv add` |
| `pip freeze > requirements.txt` | `uv lock` |
| `requirements.txt` | `pyproject.toml` + `uv.lock` |
| `setup.py` / `setup.cfg` | `pyproject.toml` |
| `virtualenv` / `venv` manual | `uv sync` (manages venv automatically) |

### FastAPI

| Outdated | Modern |
|---|---|
| `@app.on_event("startup")` | `lifespan` context manager |
| `@app.on_event("shutdown")` | `lifespan` context manager |
| Manual CORS strings | `CORSMiddleware` with explicit origins |
| Returning `dict` from routes | Pydantic `response_model` |

### String Formatting

| Outdated | Modern |
|---|---|
| `"Hello %s" % name` | `f"Hello {name}"` |
| `"Hello {}".format(name)` | `f"Hello {name}"` |

### General

| Outdated | Modern |
|---|---|
| `os.path.join` | `pathlib.Path` |
| `open()` without context manager | `with open() as f:` |
| `json.loads(f.read())` | `json.load(f)` |
| `dict.keys()` iteration | Iterate the dict directly |
| `type(x) == SomeType` | `isinstance(x, SomeType)` |
| `ABC` / `abstractmethod` | `Protocol` for structural subtyping |
| `NamedTuple` from typing | `@dataclass` or `NamedTuple` class syntax |

## Scan Patterns

Search for these to find outdated code:

- `from typing import List, Dict, Tuple, Optional, Union`
- `unittest.TestCase`, `unittest.mock`
- `setup.py`, `requirements.txt`
- `@app.on_event`
- `os.path.join`, `% s`, `.format(`
