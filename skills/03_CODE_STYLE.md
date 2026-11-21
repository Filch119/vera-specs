# 03 — Code Style

**Purpose:** Comment philosophy, commit conventions, naming, error handling, preferred patterns,
and anti-patterns. Read when writing or reviewing code.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Comment Philosophy

Comments explain **why**, not what. The code shows what; the comment names the reason, the risk, or
the decision. Put the comment at the line it protects, not in a header block three screens away.

## Commit Conventions

The project follows the commit standard defined in `git-guidelines.md`. Key rules:

1. **Format:** `scope: Imperative summary` — 50 characters or fewer.
2. **Scopes:** use product/feature scopes (`vera-api/auth:`, `vera-web/sync:`, `vera-app/auth:`,
   `vera-specs/requirements:`). Do not use generic scopes (`ui:`, `api:`) when a product scope is
   clearer.
3. **Imperative mood:** "Add", "Fix", "Remove" — not "Added", "Fixed", "Removed".
4. **Body:** explain why (wrap at 72 chars). The diff shows what changed.
5. **Breaking changes:** append `!` after scope, add `BREAKING CHANGE:` trailer.
6. **No AI authorship:** AI agents must not be listed as commit author, tag creator, or PR author.

*Miss → vague commit messages make `git log` useless for debugging and release notes.*

See `git-guidelines.md` for the full standard, examples, and versioning rules.

## Naming Conventions

Naming conventions for application code will be established as each repo's tech stack is chosen.
Until then, the following ecosystem-level conventions apply:

| Element | Convention | Example |
|---|---|---|
| Repository names | `vera-<component>` | `vera-api`, `vera-web` |
| Specification files | Descriptive kebab-case with version | `business-logic-v1.0.md` |
| Skill documents | `NN_TOPIC.md`, uppercase topic | `01_ARCHITECTURE.md` |
| Git tag prefixes | Product letter + short code | `WCN.01.0.001` |
| Branch names | `main`, `beta`, `release` | Fixed set per git-guidelines |

## Error Handling

*Not yet applicable.* No application code exists. When the first API endpoint or client component
is built, document the error handling strategy here: how errors propagate, what gets logged, what
the user sees, and what gets swallowed (and why).

## Preferred Patterns

*To be established with the first implementation.* Record patterns here as they prove themselves.

## Anti-Patterns

| Anti-Pattern | Cost | Source |
|---|---|---|
| Client-side direct database access | Bypasses all validation and auth; data corruption risk. | Architecture decision (see 01). |
| Committing with vague summaries (`fix`, `update`, `misc`) | Breaks traceability; `git bisect` and blame become useless. | `git-guidelines.md` |
| Mixing independent changes in one commit | Cannot revert or cherry-pick cleanly. | `git-guidelines.md` |
| Skipping the blank line after commit summary | Breaks every git tool's subject/body parsing. | `git-guidelines.md` |
