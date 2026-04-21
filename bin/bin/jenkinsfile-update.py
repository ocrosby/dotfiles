#!/usr/bin/env python3
"""Standardize Jenkinsfile Slack notifications to the sun-location-acceptance-tests pattern.

Finds Jenkinsfile in the current directory and all Jenkinsfiles under jenkins/,
then updates each file so that:
  - slackSend calls (and their containing script block) are removed from stage steps
  - post { success { ... } } is removed entirely
  - post { failure { ... } } uses the canonical sun-location-acceptance-tests pattern

The canonical failure notification includes ENVIRONMENT/REGION params, the
triggering user, build duration, and a direct link to the Allure report.

Usage:
    jenkinsfile-update.py [--dry-run]
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Final, NamedTuple


# Canonical failure block — verbatim match to sun-location-acceptance-tests.
# The \\n inside the slackSend message is a Groovy string escape (newline in Slack).
STANDARD_FAILURE_BLOCK: Final[str] = """\
        failure {
            script {
                def user = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')[0]?.userName ?: 'GitHub'
                slackSend(channel: env.SLACK_CHANNEL, color: 'danger', message: "'${env.JOB_NAME}' - #${env.BUILD_NUMBER} (${params.ENVIRONMENT}/${params.REGION}) Failed after ${currentBuild.durationString.replace(' and counting', '')} - Started by ${user} (<${env.BUILD_URL}|Open>)\\n<${env.BUILD_URL}allure/#suites|Allure Report>")
            }
        }"""


class ProcessResult(NamedTuple):
    """Result of processing a single Jenkinsfile."""

    content: str
    changes: list[str]
    warnings: list[str]


def _normalize(block: str) -> str:
    """Normalize a Groovy block for idempotency comparison.

    Strips both leading and trailing whitespace on every line, then strips
    surrounding blank lines. Two blocks are considered equivalent when their
    normalizations are equal, regardless of indentation style (4-space vs
    8-space Groovy conventions both compare equal to find_first_block output).
    """
    return "\n".join(line.strip() for line in block.splitlines()).strip()


def find_block_end(text: str, open_pos: int) -> int:
    """Return the exclusive end of the block whose '{' is at open_pos.

    Handles Groovy string literals (single-quoted, double-quoted, triple-quoted,
    with escape sequences) and line/block comments so brace counts are not
    confused by literal braces inside strings or comments.

    Args:
        text: Full file content.
        open_pos: Index of the opening '{' character.

    Returns:
        Exclusive end index (one past the closing '}'), or -1 on unmatched brace.
    """
    assert 0 <= open_pos < len(text), (
        f"open_pos {open_pos} out of range [0, {len(text)})"
    )
    depth = 0
    i = open_pos
    n = len(text)

    while i < n:
        # Triple-single-quoted strings (multi-line, backslash sequences valid)
        if text[i : i + 3] == "'''":
            i += 3
            while i < n:
                if text[i] == "\\" and i + 1 < n:
                    i += 2
                elif text[i : i + 3] == "'''":
                    i += 3
                    break
                else:
                    i += 1
            continue

        # Triple-double-quoted strings (multi-line GString, backslash sequences valid)
        if text[i : i + 3] == '"""':
            i += 3
            while i < n:
                if text[i] == "\\" and i + 1 < n:
                    i += 2
                elif text[i : i + 3] == '"""':
                    i += 3
                    break
                else:
                    i += 1
            continue

        # Line comment
        if text[i : i + 2] == "//":
            while i < n and text[i] != "\n":
                i += 1
            continue

        # Block comment
        if text[i : i + 2] == "/*":
            i += 2
            while i < n and text[i : i + 2] != "*/":
                i += 1
            i = min(i + 2, n)
            continue

        # Single-quoted string (not triple-quoted — already handled above)
        if text[i] == "'" and text[i : i + 3] != "'''":
            i += 1
            while i < n:
                if text[i] == "\\" and i + 1 < n:
                    i += 2
                elif text[i] == "'":
                    i += 1
                    break
                else:
                    i += 1
            continue

        # Double-quoted GString (not triple-quoted — already handled above)
        if text[i] == '"' and text[i : i + 3] != '"""':
            i += 1
            while i < n:
                if text[i] == "\\" and i + 1 < n:
                    i += 2
                elif text[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
            continue

        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return i + 1

        i += 1

    return -1


def find_first_block(
    text: str, keyword: str, start: int = 0, end: int | None = None
) -> tuple[int, int] | None:
    """Find the first `keyword {` block in text[start:end].

    Args:
        text: Full file content.
        keyword: Groovy DSL keyword to search for (e.g. "post", "failure").
        start: Start position for the search (absolute index).
        end: Exclusive end position for the search; defaults to end of text.

    Returns:
        (keyword_start, block_end) as absolute indices, or None if not found.
    """
    if end is None:
        end = len(text)
    m = re.search(r"\b" + re.escape(keyword) + r"\s*\{", text[start:end])
    if not m:
        return None
    abs_kw_start = start + m.start()
    abs_brace_pos = start + m.end() - 1
    block_end = find_block_end(text, abs_brace_pos)
    if block_end == -1 or block_end > end:
        return None
    return abs_kw_start, block_end


def find_script_blocks_with_slack(
    text: str, exclude_start: int, exclude_end: int
) -> list[tuple[int, int]]:
    """Find all top-level script { ... } blocks outside the excluded range that contain slackSend.

    Top-level means the search advances past each found block, so nested script
    blocks inside a slack-containing block are not returned separately.

    Args:
        text: Full file content.
        exclude_start: Start of the range to skip (typically the post block).
        exclude_end: Exclusive end of the range to skip.

    Returns:
        List of (block_start, block_end) tuples for blocks containing slackSend.
    """
    pattern = re.compile(r"\bscript\s*\{")
    results: list[tuple[int, int]] = []
    pos = 0

    while pos < len(text):
        m = pattern.search(text, pos)
        if not m:
            break
        block_start = m.start()
        brace_pos = m.end() - 1
        block_end = find_block_end(text, brace_pos)
        if block_end == -1:
            pos = m.end()
            continue
        # Skip blocks that fall entirely within the excluded (post) range
        if block_start >= exclude_start and block_end <= exclude_end:
            pos = block_end
            continue
        if "slackSend" in text[block_start:block_end]:
            results.append((block_start, block_end))
        # Always advance past the block to avoid re-entering nested blocks
        pos = block_end

    return results


def remove_block_with_line_cleanup(text: str, start: int, end: int) -> str:
    """Remove text[start:end], collapsing the line when it becomes blank.

    When the text before `start` on the same line is all whitespace and
    everything after `end` up to the next newline is also whitespace, the
    entire line is removed. When trailing non-whitespace exists on the same
    line after the block, only the block itself is removed.

    Args:
        text: Full file content.
        start: Start index of the region to remove.
        end: Exclusive end index of the region to remove.

    Returns:
        Updated file content with the block removed.
    """
    line_start = text.rfind("\n", 0, start)
    line_start = line_start + 1 if line_start != -1 else 0
    pre = text[line_start:start]

    if pre.strip() == "":
        line_end = text.find("\n", end)
        suffix = text[end:line_end] if line_end != -1 else text[end:]
        if suffix.strip() == "":
            # Entire line is the block — remove including the trailing newline
            adj_end = line_end + 1 if line_end != -1 else len(text)
            return text[:line_start] + text[adj_end:]
        # Non-whitespace trailing content — remove only the block itself
        return text[:start] + text[end:]

    return text[:start] + text[end:]


def process(content: str) -> ProcessResult:
    """Apply all Slack-notification normalizations to a Jenkinsfile.

    Args:
        content: Raw Jenkinsfile text.

    Returns:
        ProcessResult with updated content, a list of applied changes, and
        any warnings (e.g. missing post block). Changes and warnings are
        separate so callers can always surface warnings regardless of whether
        the file was modified.
    """
    changes: list[str] = []
    warnings: list[str] = []
    text = content

    # Locate the pipeline-level post {} block. Search after stages {} to avoid
    # binding to a stage-level post {} that may appear earlier in the file.
    stages = find_first_block(text, "stages")
    post_search_start = stages[1] if stages else 0
    post = find_first_block(text, "post", post_search_start)
    if post is None:
        return ProcessResult(
            text, changes, ["no post {} block found — skipping"]
        )
    post_start, post_end = post

    # --- Step 1: Remove slackSend script blocks from stage steps ---
    slack_blocks = find_script_blocks_with_slack(text, post_start, post_end)
    if slack_blocks:
        for sb_start, sb_end in reversed(slack_blocks):
            text = remove_block_with_line_cleanup(text, sb_start, sb_end)
        changes.append(
            f"Removed {len(slack_blocks)} slackSend script block(s) from stage steps"
        )
        stages = find_first_block(text, "stages")
        post_search_start = stages[1] if stages else 0
        post = find_first_block(text, "post", post_search_start)
        if post is None:
            warnings.append("lost post {} after stage cleanup")
            return ProcessResult(text, changes, warnings)
        post_start, post_end = post

    # --- Step 2: Remove post { success { ... } } ---
    success = find_first_block(text, "success", post_start, post_end)
    if success:
        s_start, s_end = success
        text = remove_block_with_line_cleanup(text, s_start, s_end)
        changes.append("Removed post { success { ... } } block")
        stages = find_first_block(text, "stages")
        post_search_start = stages[1] if stages else 0
        post = find_first_block(text, "post", post_search_start)
        if post is None:
            warnings.append("lost post {} after success removal")
            return ProcessResult(text, changes, warnings)
        post_start, post_end = post

    # --- Step 3: Normalize post { failure { ... } } ---
    failure = find_first_block(text, "failure", post_start, post_end)
    if failure:
        f_start, f_end = failure
        if _normalize(text[f_start:f_end]) == _normalize(
            STANDARD_FAILURE_BLOCK
        ):
            changes.append(
                "post { failure } already matches standard — no change"
            )
        else:
            # Replace from start of the failure keyword's line to end of block
            line_start = text.rfind("\n", 0, f_start)
            replace_start = line_start + 1 if line_start != -1 else 0
            text = text[:replace_start] + STANDARD_FAILURE_BLOCK + text[f_end:]
            changes.append(
                "Replaced post { failure { ... } } with standard block"
            )
    else:
        # Insert failure block before post's closing brace
        post_close = post_end - 1
        while post_close > post_start and text[post_close] != "}":
            post_close -= 1
        text = (
            text[:post_close]
            + "\n"
            + STANDARD_FAILURE_BLOCK
            + "\n"
            + text[post_close:]
        )
        changes.append("Added missing post { failure { ... } } block")

    return ProcessResult(text, changes, warnings)


def collect_jenkinsfiles(root: Path) -> list[Path]:
    """Collect Jenkinsfile from the root directory and jenkins/ subdirectory.

    Args:
        root: Directory to search from, typically Path.cwd().

    Returns:
        List of Jenkinsfile paths. The root Jenkinsfile (if present) comes
        first; jenkins/ files follow in lexicographic order (sorted() over
        rglob output, which is otherwise filesystem/OS-dependent).
    """
    files: list[Path] = []
    root_jf = root / "Jenkinsfile"
    if root_jf.is_file():
        files.append(root_jf)
    jenkins_dir = root / "jenkins"
    if jenkins_dir.is_dir():
        files.extend(sorted(jenkins_dir.rglob("Jenkinsfile")))
    return files


def main() -> None:
    """Entry point."""
    parser = argparse.ArgumentParser(
        description="Standardize Jenkinsfile Slack notifications",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without writing files",
    )
    args = parser.parse_args()

    root = Path.cwd()
    files = collect_jenkinsfiles(root)

    if not files:
        print(
            "No Jenkinsfiles found in current directory or jenkins/ subdirectory.",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"Found {len(files)} Jenkinsfile(s) in {root}")
    any_changes = False
    has_errors = False

    for path in files:
        rel = path.relative_to(root)
        try:
            original = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            print(f"  ERROR reading {rel}: {exc}", file=sys.stderr)
            has_errors = True
            continue

        result = process(original)

        for warning in result.warnings:
            print(f"  WARNING {rel}: {warning}", file=sys.stderr)
            has_errors = True

        if result.content == original:
            print(f"  unchanged  {rel}")
            continue

        any_changes = True
        prefix = "[dry-run] " if args.dry_run else ""
        print(f"  {prefix}updated   {rel}")
        for c in result.changes:
            print(f"    - {c}")

        if not args.dry_run:
            try:
                path.write_text(result.content, encoding="utf-8")
            except OSError as exc:
                print(f"  ERROR writing {rel}: {exc}", file=sys.stderr)
                has_errors = True

    if not any_changes and not has_errors:
        print("All files already match the standard.")
    elif args.dry_run:
        print("\nDry run complete — no files written.")
    else:
        print("\nDone.")

    if has_errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
