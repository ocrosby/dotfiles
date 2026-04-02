---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/.env*"
---

# Python Security

## Secrets & Environment Variables

- Never hardcode secrets, API keys, tokens, or passwords in source code
- Load all sensitive values from environment variables via pydantic Settings
- Never commit `.env` files containing real credentials — use `.env.example` with placeholder values
- Add `.env` to `.gitignore` in every project
