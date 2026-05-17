---
description: Generates a changelog or release notes from conventional commits since the last tag, grouped by type. Use after merging to main when preparing a release.
---

# Release Notes

Use this skill when preparing a release. It reads git history since the last tag, groups commits by conventional commit type, and produces a formatted changelog.

## Usage

```
/release-notes                      # changelog since last tag, output inline
/release-notes --tag v1.2.3         # label the release with this version
/release-notes --since v1.1.0       # use a specific ref instead of the last tag
/release-notes --write              # append to CHANGELOG.md in addition to inline output
/release-notes --tag v1.2.3 --write # label + write to CHANGELOG.md
```

## Workflow

### 1. Find the Baseline

```bash
# Find the most recent tag
git describe --tags --abbrev=0 2>/dev/null || echo "none"
```

If no tags exist, use the first commit: `git rev-list --max-parents=0 HEAD`.

If `--since <ref>` was passed, use that ref as the baseline instead.

### 2. Collect Commits

```bash
git log "<baseline>"..HEAD --pretty=format:"%H %s" --no-merges
```

Always quote the baseline ref — tags can contain characters (`-`, `.`, `+`) that may behave unexpectedly in some shells when unquoted.

Exclude merge commits — they add noise without content.

### 3. Parse and Group

Parse each commit subject as a conventional commit: `<type>(<scope>): <description>`.

Group into these sections, in this order:

| Section heading | Commit types included |
|---|---|
| Breaking Changes | any commit with `!` after type, or a `BREAKING CHANGE:` footer |
| New Features | `feat` |
| Bug Fixes | `fix` |
| Performance | `perf` |
| Other Changes | `refactor`, `chore`, `build`, `ci`, `docs`, `style`, `test` |

A commit with a `BREAKING CHANGE:` footer or `!` after the type always goes to **Breaking Changes** regardless of its primary type. Classify by primary type for everything else; a commit cannot appear in more than one section.

Skip commits that do not parse as conventional commits (manual merge resolutions, etc.) — list them separately under **Uncategorized** only if there are more than 3.

### 4. Determine the Version

If `--tag <version>` was passed, use it as the release label.

Otherwise, infer the version bump from the commit types present:
- Any `BREAKING CHANGE` or `!` → major bump
- Any `feat` → minor bump
- Only `fix`, `perf`, or `chore` → patch bump

Version bumping applies only to stable releases. If the last tag is a pre-release (contains `-alpha`, `-beta`, `-rc`), do not increment — suggest finalizing that version first: "Last tag is a pre-release (`<last-tag>`). Did you mean to finalize it as `<stable-version>`, or increment to `<next-version>`?"

Suggest the version: "Based on these commits, the next version after `<last-tag>` should be `<suggested>`."

### 5. Format the Output

```markdown
## [v1.2.0] — 2026-05-03

### Breaking Changes

- `auth`: remove legacy session cookie support (#42) — [abc1234]

### New Features

- `users`: add OAuth2 token refresh endpoint (#38) — [def5678]
- `api`: support cursor-based pagination on all collection endpoints (#35) — [ghi9012]

### Bug Fixes

- `auth`: correct 404 returned for expired tokens instead of 401 (#40) — [jkl3456]

### Performance

- `query`: replace N+1 user lookup with batch fetch (#37) — [mno7890]

### Other Changes

- `ci`: upgrade golangci-lint-action to v9 (#36) — [pqr1234]
```

Each line: `- <scope>: <description> (<PR link if available>) — [<short hash>]`

To get PR numbers, try:
```bash
# GitHub CLI — link commit to PR
gh pr list --state merged --json number,mergeCommit --jq '.[] | select(.mergeCommit.oid | startswith("<hash>")) | .number'
```

If PR lookup is slow or unavailable, omit the PR reference and use only the hash.

### 6. Write to CHANGELOG.md (only when `--write` is passed)

**If `--write` was not passed: stop after printing the formatted output.**

If the file does not exist, create it with a standard header:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/) and
[Conventional Commits](https://www.conventionalcommits.org/).

---
```

Insert the new release section **at the top**, below the header, above any existing entries. Do not overwrite existing entries.

After writing, show a confirmation:

```
✓ CHANGELOG.md updated — new section at top: [v1.2.0] — 2026-05-03
```

## Rules

- Always use `--no-merges` when collecting commits — merge commit subjects carry no content
- If the baseline tag does not exist in the repository, stop and report the error rather than silently falling back
- Do not infer versions without stating the reasoning — show which commit types drove the bump
- If `CHANGELOG.md` already contains an entry for the suggested version, warn the user before writing rather than duplicating it
- When `--write` is not passed, output only — never modify files
