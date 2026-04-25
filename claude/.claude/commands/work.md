Work journal manager. Dispatches on the first word of $ARGUMENTS as a subcommand.

Work journal root: /Users/omar.crosby/work
File path format: {root}/{YYYY}/{M}/{D}.md — year, month, and day with NO zero-padding (e.g. 2026/4/22.md, not 2026/04/22.md).

---

## Bootstrap

Run the following single Bash command before doing anything else. It handles all setup and emits four or five output lines: `CREATED_ROOT` or `OK_ROOT`, `CREATED_TODAY` or `OK_TODAY`, optionally `CARRYOVER:N` (only when a new file is created), the date string, and the completion ratio. Read those lines and use them as described below.

```bash
WORK=~/work
YEAR=$(date +%Y); MONTH=$(date +%-m); DAY=$(date +%-d)
TODAY_FILE="$WORK/$YEAR/$MONTH/$DAY.md"

if [ ! -d "$WORK" ]; then
  mkdir -p "$WORK"
  cat > "$WORK/README.md" <<'README'
# Work Journal

A date-structured daily log of engineering activity.

Structure: work/YYYY/M/D.md (no zero-padding)

Commands:
  /work                   Show help
  /work add <task>        Add a task to today's journal
  /work list [period]     List tasks (today/yesterday/this-week/last-week)
  /work done [task text]  Mark a task complete
README
  echo "CREATED_ROOT"
else
  echo "OK_ROOT"
fi

if [ ! -f "$TODAY_FILE" ]; then
  mkdir -p "$WORK/$YEAR/$MONTH"

  # Find the most recent previous journal file by sorting path components numerically
  PREV_FILE=$(find "$WORK" -name "[0-9]*.md" ! -path "$TODAY_FILE" 2>/dev/null | \
    sed 's|.*/\([0-9]*\)/\([0-9]*\)/\([0-9]*\)\.md$|\1 \2 \3 &|' | \
    sort -k1,1n -k2,2n -k3,3n | \
    awk '{print $4}' | tail -1)

  # Extract uncompleted tasks from the previous file
  CARRYOVER=""
  CARRYOVER_COUNT=0
  if [ -n "$PREV_FILE" ] && [ -f "$PREV_FILE" ]; then
    CARRYOVER=$(grep '- \[ \]' "$PREV_FILE" 2>/dev/null)
    [ -n "$CARRYOVER" ] && CARRYOVER_COUNT=$(echo "$CARRYOVER" | grep -c '- \[ \]')
  fi

  printf "%s\n\n## Tasks\n" "$(date '+%A %b %-d')" > "$TODAY_FILE"

  if [ -n "$CARRYOVER" ]; then
    echo "$CARRYOVER" >> "$TODAY_FILE"
    # Add default only when not already carried over
    echo "$CARRYOVER" | grep -q 'Review Jenkins Jobs' || printf "- [ ] Review Jenkins Jobs\n" >> "$TODAY_FILE"
  else
    printf "- [ ] Review Jenkins Jobs\n" >> "$TODAY_FILE"
  fi

  printf "\n## Notes\n" >> "$TODAY_FILE"

  echo "CREATED_TODAY"
  echo "CARRYOVER:$CARRYOVER_COUNT"
else
  echo "OK_TODAY"
fi

read DONE OPEN <<< $(awk '/- \[x\]/{d++} /- \[ \]/{o++} END{printf "%d %d",d+0,o+0}' "$TODAY_FILE")
TOTAL=$((DONE + OPEN))
PCT=$(awk -v d=$DONE -v t=$TOTAL 'BEGIN{if(t>0) printf "%d",int(d/t*100+0.5); else print 0}')

date "+%A, %B %-d, %Y — %-I:%M %p"
echo "How we're doing so far: $DONE/$TOTAL (${PCT}%) Complete"
```

Read the output:
- If the first line is `CREATED_ROOT`, notify the user: "Work journal directory created at ~/work."
- If the second line is `CREATED_TODAY`:
  - The third line is `CARRYOVER:N`. If N > 0, notify the user: "Today's journal created — N task(s) carried over from your last session." If N is 0, notify: "Today's journal created."
  - The date and completion ratio are on lines 4 and 5.
- If the second line is `OK_TODAY`, the date and completion ratio are on lines 3 and 4.
- Always display the date and completion ratio lines as the header.

---

## Subcommand dispatch

Parse $ARGUMENTS by splitting on the first space. The first word is the subcommand; everything after is the subcommand's argument.

---

### No arguments, or `help`

Print this help text exactly:

```
Usage: /work <subcommand> [arguments]

Subcommands:
  add <task>          Add a new task to today's journal
  list [period]       List tasks for a time period
    today               Today only (default)
    yesterday           Yesterday only
    this-week           Monday through today
    last-week           Previous Monday through Sunday
  done [task text]    Mark a task complete in today's journal
  update              Rename a task in today's journal
  note <text>         Append a note to today's journal
  help                Show this help
```

---

### `add <task text>`

1. Add `- [ ] <task text>` as a new line under `## Tasks` in today's file, before the `## Notes` heading.
2. Confirm the task was added and show today's full task list.

---

### `list [period]`

Period is one of: today (default), yesterday, this-week, last-week.

1. Determine the date range:
   - today: today only
   - yesterday: yesterday only
   - this-week: Monday through today of the current week
   - last-week: Monday through Sunday of the previous calendar week
2. For each date in the range, compute the file path and read it if it exists. Skip missing dates silently.
3. Display results grouped by date with a heading per day. Show all tasks with checkbox state. Show Notes only if non-empty.
4. End with a one-line summary: e.g. "3 of 7 tasks complete across 2 days."
5. If no files exist for the range, say so clearly.

---

### `done [task text]`

1. Determine today's file path and read it. If no file exists, say so and stop.
2. If task text was provided: find the open task (`- [ ]`) whose text best matches, change it to `- [x]`, confirm the change.
3. If no task text: list all open tasks numbered and ask which to mark complete, then apply the change.
4. Show the updated task list for today.

---

### `update`

1. Determine today's file path and read it. If no file exists, say so and stop.
2. List all tasks (both open and complete) numbered, preserving their checkbox state. Example:
   ```
   1. [ ] Review Jenkins Jobs
   2. [ ] Review claude Routines
   3. [x] Fix the datetime tests
   ```
3. Ask: "Which task would you like to update? Enter the number:"
4. Wait for the user's response with the number.
5. Ask: "New description:"
6. Wait for the user's response with the new text.
7. Replace the matched task line's description with the new text, preserving its checkbox state (`[ ]` or `[x]`).
8. Confirm the change and show today's full task list.

---

### `note <text>`

1. Append `$ARGUMENTS` (everything after `note`) as a new line under `## Notes` in today's file.
2. Confirm the note was added and show the full `## Notes` section.
