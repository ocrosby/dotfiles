# Documentation Principles

Apply these principles whenever writing, editing, or reviewing any documentation: READMEs, API docs, tutorials, reference pages, error messages, UI copy, changelogs, and inline comments intended for readers.

These principles are sourced from writethedocs.org/guide/. Full detail is in memory `writethedocs_guide.md` when running in the dotfiles project context; in all other projects the signal tables and mandatory behaviors below are self-contained.

---

## Recognition Signals

### Structure — when the document needs reorganization

| Signal | Principle |
|---|---|
| Wall of prose with no headings | **Skimmable** — add descriptive headings; readers must be able to skip what they know |
| Link text reads "click here" or "this page" | **Addressable** — link text must describe the destination |
| Tutorial covers advanced material before basic | **Cumulative** — prerequisites before concepts; concepts before tasks |
| Doc covers only half the related items | **Complete** — cover in full or not at all; partial coverage is worse than none |
| Topic exists but is impossible to find from related pages | **Discoverable** — insert helpful pointers everywhere a user might land |
| Doc describes implementation details users don't need | **Audience** — separate user-facing docs from developer/contributor docs |

### Content — when the writing itself needs work

| Signal | Principle |
|---|---|
| No working code example in a guide | **Exemplary** — include examples for the most common use cases |
| Same term spelled or capitalized inconsistently | **Consistent** — one term, one spelling, one meaning throughout |
| Doc describes a feature that was changed | **Current** — incorrect docs are worse than missing docs; update on every change |
| Repetition removed so aggressively that understanding a concept requires following multiple links | **ARID violation** — restore the repeated explanation; see ARID Guard section |
| FAQ section present | **Anti-FAQ** — FAQs become stale, scattered, and unsearchable; replace with structured content |
| Error message blames the user or gives no action | **Human-centered errors** — be precise about the problem, never blame, always give a constructive next step |

### Sources — when docs are in the wrong place

| Signal | Principle |
|---|---|
| Docs live in a separate repo from the code they describe | **Nearby** — store docs as close as possible to the code; merge documentation and development workflows |
| Same content maintained in two places | **Unique** — eliminate overlap; one source of truth prevents drift |

### API Documentation

| Signal | Principle |
|---|---|
| API being designed without documentation | **Design-first** — write the API docs before writing the code; doc changes are cheap, code changes are expensive |
| API doc written after implementation | **Retrofit** — still write it; use automated tools (OpenAPI/Swagger) to bootstrap from existing code |
| Data structures duplicated across endpoints | **Reusable structures** — define once, reference everywhere |

### UX / Interface Copy

| Signal | Principle |
|---|---|
| Error message says "Error" or "Something went wrong" | **Precise** — name the specific problem and what to do about it |
| Tooltip or label is vague or missing | **Microcopy** — interface text is documentation; users read it before ever opening the docs |
| UI copy contradicts the product docs | **Voice** — UI and docs must share the same voice, tone, and terminology |

---

## Mandatory Behaviors

**When writing any documentation**: apply every relevant principle from the signal tables above. If a principle cannot be evaluated because information is unavailable, note the gap rather than skipping it.

**When writing error messages or UI copy**: always be human-centered. Name the specific problem, never blame the user, always give a constructive next step. A friendly, precise error message is worth more than any help article.

**When writing API documentation**: apply documentation-driven design. If the API does not yet exist, document the intended design first to validate it before writing code.

**When editing code that has adjacent documentation**: update the docs in the same change. Do not leave documentation that describes behavior the code no longer has.

**When reviewing documentation** (the user explicitly requests a review, uses `/doc-review`, or asks for feedback on a document without requesting direct edits): apply the three-severity findings format:
- **Must Fix** — incorrect content (worse than missing), broken links, missing examples in a tutorial, "click here" links
- **Should Fix** — non-skimmable structure, inconsistent terminology, FAQs, docs stored far from code
- **Consider** — optional improvements: more examples, cross-references, better heading wording

**Never**:
- Use "click here" or "this link" as link text
- Write a FAQ section — direct users to structured content instead
- Write documentation that is intentionally incomplete (cover in full or not at all)
- Leave docs unupdated when changing the code they describe

---

## ARID Guard (the exception to DRY)

The DRY principle applies to code, not documentation. Do not remove documentation repetition the way you would remove duplicate code. When a concept must be understood to use two different features, it is correct to explain it in both places. Minimize unnecessary repetition, but acknowledge that some "moisture" in documentation is required — eliminating it forces readers to follow chains of links to understand a single concept.

---

## Style Guide Essentials

Apply these defaults only when no project-level style guide is present. When a project style guide exists, follow it; flag conflicts with these defaults as **Consider** findings rather than errors.

- Use active voice and imperative mood in instructions: "Run the command" not "The command should be run"
- Second person ("you") for user-facing docs; first-person plural ("we") sparingly in narrative context
- Sentence case for headings, not title case
- Code terms, file names, and commands in `backticks`
- Accessibility: alt text on every image (one or two sentences describing the information conveyed, not the appearance)
- Bias: avoid idioms that reference violence or animal harm; use terms that are clear to non-native English speakers
- Note: a `docs/` directory is an acceptable location for project-level documentation; the Nearby principle applies primarily to per-module or per-package API documentation
