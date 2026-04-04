---
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
  - "**/*.feature"
---

# Suggest Review After Implementation

After completing a significant implementation task — a new feature, bug fix, or substantial refactor — suggest running `/review` before shipping.

**When to suggest it:**
- A new function, class, module, or package has been written
- A bug fix that touches more than one file
- A refactor that moves or restructures code

**When NOT to suggest it:**
- Single-line fixes (typo correction, comment update, minor rename)
- Changes to config, documentation, or non-code files only
- The user has already run `/review` in this session for these files

Keep the suggestion brief: one line at the end of your response, e.g.:
> Consider running `/review` before shipping to catch any issues.
