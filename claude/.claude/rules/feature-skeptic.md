---
description: Pushback protocol for feature-add requests. Triggers whenever the user asks to add a new feature, endpoint, page, command, option, flag, or setting. Counters Feature Compounding by forcing scope, displacement, and ICP-fit questions before the first edit.
---

# Feature Skeptic

Most products fail not because they were missing a feature, but because they accumulated too many. Each addition individually looked reasonable; the sum was incoherent surface area no user could hold in their head.

When the user requests a code change that **adds new surface**, do not implement immediately. Run the protocol below first. If the user has already answered the questions in their request or in `CLAUDE.md`, skip ahead — do not re-ask what's already on the table.

## What counts as "adding new surface"

Trigger this protocol on requests that introduce:

- A new route, endpoint, RPC, or webhook handler
- A new page, screen, modal, or top-level navigation item
- A new CLI command or subcommand
- A new config option, feature flag, environment variable, or user-facing setting
- A new public function, exported type, or plugin extension point
- A new third-party integration

Phrases that usually indicate this: "add support for…", "let users also…", "introduce a…", "make it possible to…", "expose a…", "wire up a…".

## What does NOT trigger this protocol

Implement these directly without pushback:

- Bug fixes and regressions
- Refactors that preserve behavior
- Performance work
- Test additions
- Documentation updates
- Internal helpers with no external surface
- Changes the user explicitly framed as deletion or simplification

## The protocol

Before writing code, surface answers to these in one short message — not as a checklist for the user to fill out, but as your reasoning. If the answer is already obvious from the repo or the request, say so and move on; only ask the user when an answer is genuinely missing.

1. **Who specifically asked, and are they in the ICP?**
   Check `CLAUDE.md` for an ICP / "who this is for" line. If the requester (or the use case) sits outside it, name that explicitly. Building for "everyone" is the most common form of Crowded ICP.

2. **What existing feature already covers 60%+ of this?**
   Grep the codebase. If something close exists, the default proposal should be to extend it, not add a parallel surface. Two ways to do the same thing is a worse outcome than the original gap.

3. **Can this be a config option or parameter on an existing surface instead of a new surface?**
   New flags are cheap; new pages, routes, and commands are expensive. Argue for the smaller form first.

4. **What gets removed or deprecated to make room?**
   Surface area has a cost — onboarding, docs, test matrix, support load. If nothing is being removed, the product is getting heavier on net. Name what could come out, even if the user ultimately keeps it.

5. **What's the smallest version that proves demand before the full build?**
   A read-only version. A manual workflow with a Slack notification instead of an in-app UI. A hardcoded list before a settings page. Resist building the full feature on speculation.

6. **What's the rollback path if it doesn't get used?**
   If the answer is "we'd have to rip out three months of work," the design is wrong. Features should be removable.

## Output shape

When the protocol fires, your first response is **not code**. It's a short block like:

> **Feature skeptic check** (per `rules/feature-skeptic.md`):
> - **ICP fit:** ✅ matches the "solo SaaS founder" ICP in `CLAUDE.md`
> - **Existing coverage:** the `/billing/portal` route already does ~70% of this — propose extending it rather than adding `/subscription/manage`
> - **Smaller form:** could ship as a query param on the existing route this week, full page later if usage justifies
> - **Displacement:** the legacy `/account/plan` page becomes redundant — flag for removal
> - **Rollback:** single route handler, easy to revert
>
> Recommend: extend `/billing/portal` with `?action=cancel`. Proceed?

Keep it under 10 lines. Wait for the user to confirm or redirect before editing.

## When to skip the protocol entirely

- The user explicitly says "just do it", "skip the protocol", or otherwise opts out for this request
- The change is in a throwaway/spike branch the user has marked as such
- The repo is a personal scratch project (no `CLAUDE.md` ICP line, no users beyond the author)

In all other cases, run the protocol. The cost of one short message is low; the cost of unbounded surface growth compounds for the life of the product.
