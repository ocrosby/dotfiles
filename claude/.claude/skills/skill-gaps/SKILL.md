---
description: Analyze Claude Code session history to find repeating tasks with no skill coverage. Run periodically to discover new skill candidates.
triggers:
  - /skill-gaps
---

# Skill Gaps: Identify Missing Skills from History

Scans `~/.claude/history.jsonl` to surface tasks you type repeatedly that are not covered by an existing skill. Run after a few weeks of sessions to find the next batch of skills worth writing.

## Usage

```
/skill-gaps
```

## Workflow

### Step 1 — Extract command patterns

```bash
python3 - << 'EOF'
import json
from collections import Counter

displays = []
with open("/Users/omar.crosby/.claude/history.jsonl") as f:
    for line in f:
        try:
            entry = json.loads(line.strip())
            d = entry.get("display", "")
            if d:
                displays.append(d.strip())
        except:
            pass

print(f"Total entries: {len(displays)}")

# Slash command frequency
slash = [d for d in displays if d.startswith("/")]
counts = Counter(slash)
print(f"\n=== TOP SKILL INVOCATIONS ({len(slash)} total) ===")
for cmd, count in counts.most_common(30):
    print(f"{count:4d}  {cmd[:80]}")

# Common natural language task starts (first 8 words)
non_slash = [d for d in displays if not d.startswith("/") and d != "exit" and len(d) > 10]
phrase_counts = Counter()
for d in non_slash:
    words = d.split()[:8]
    phrase = " ".join(words).lower()
    phrase_counts[phrase] += 1

print(f"\n=== COMMON NATURAL LANGUAGE TASK STARTS ===")
for phrase, count in phrase_counts.most_common(40):
    if count >= 2:
        print(f"{count:4d}  {phrase}")
EOF
```

### Step 2 — List existing skills

```bash
ls ~/.claude/skills/
ls ~/dotfiles/claude/.claude/skills/ 2>/dev/null
```

### Step 3 — Identify gaps

For each pattern appearing 5+ times as natural language (not a slash command), check whether an existing skill covers it. A pattern is a gap if:
- No skill triggers on the same intent
- The user is typing freeform what a skill could automate

### Step 4 — Report

Present a ranked table of candidates:

| Suggested Skill | Count | Example message | Gap reason |
|---|---|---|---|
| ... | ... | ... | ... |

Order by frequency descending. Include only gaps with 5+ occurrences and no existing skill. For each gap, suggest a skill name and one-line description.

Also report the top slash commands by frequency — these confirm which skills are getting used.
