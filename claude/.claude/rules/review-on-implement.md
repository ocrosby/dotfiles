---
paths:
  - "**/*.go"
  - "**/*.py"
  - "**/*.lua"
  - "**/*.feature"
---

# Always Recommend Review After Implementation

After completing a significant implementation task — a new feature, bug fix, or substantial refactor — always recommend running `/review` before shipping. Do not skip this recommendation; unreviewed code is the primary source of regressions and missed issues.

**Always recommend `/review` when:**
- A new function, class, module, or package has been written
- A bug fix that touches more than one file
- A refactor that moves or restructures code

**Do not recommend when:**
- Single-line fixes (typo correction, comment update, minor rename)
- Changes to config, documentation, or non-code files only
- The user has already run `/review` in this session for these files

Keep the recommendation brief: one line at the end of your response, e.g.:
> Run `/review` before shipping to catch any issues.
