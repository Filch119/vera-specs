# 04 — Change Rules

**Purpose:** Lockstep sets, hidden dependencies, high-risk areas, and what to retest after a
change. Read before making any cross-cutting change.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Lockstep Sets

Lockstep sets are groups of files, constants, or definitions that must change together. Miss one
and the system breaks silently or loudly.

### Set 1: Ecosystem Agent Instructions

| # | File | Repository |
|---|---|---|
| 1 | `AGENTS.md` | `vera-ecosystem/` (root) |
| 2 | `AGENTS.md` | `vera-api/` |
| 3 | `AGENTS.md` | `vera-android/` |
| 4 | `AGENTS.md` | `vera-web/` |
| 5 | `AGENTS.md` | `vera-specs/` |

**Trigger:** changing the project identity, adding a repo, or changing how agents discover
instructions.
*Miss → AI agents read stale or contradictory project descriptions; generated code targets the
wrong architecture.*

### Set 2: Git Scopes and Product Prefixes

| # | File | What to sync |
|---|---|---|
| 1 | `vera-specs/git-guidelines.md` §Preferred application scopes | Scope table |
| 2 | `vera-specs/git-guidelines.md` §Product prefixes | Prefix table (`WCN`, `BCN`, `ACN`, `SCN`) |
| 3 | `vera-specs/git-guidelines.md` §Release Tags (per-product tables) | Tag inventory |

**Trigger:** adding a new product, renaming a repo, or changing the project short code.
*Miss → tags and commit scopes reference nonexistent products; release automation breaks.*

### Set 3: Business Logic User Levels ↔ Feature Access Matrix

| # | Section | What to sync |
|---|---|---|
| 1 | `business-logic-v1.1-proposed.md` §User Levels & Permissions | User level definitions (A–E) |
| 2 | `business-logic-v1.1-proposed.md` §MVP Features and Access Matrix | Access column references |

**Trigger:** adding, removing, or renaming a user level.
*Miss → access matrix references a user level that doesn't exist; authorization is undefined.*

### Set 4: Branching Model (Future)

| # | What | Where |
|---|---|---|
| 1 | Branch protection rules | Each repo's GitHub settings |
| 2 | Branching model documentation | `git-guidelines.md` §Branching Models |
| 3 | CI pipeline branch triggers | Each repo's CI config (when created) |

**Trigger:** changing the promotion flow (`main` → `beta` → `release`).
*Miss → CI builds the wrong branch; unreviewed code reaches release.*

## Hidden Dependencies

| Dependency | Why it's hidden | Impact |
|---|---|---|
| `vera-ecosystem/AGENTS.md` references glob patterns `*-api/AGENTS.md`, etc. | Adding or renaming a repo silently breaks the glob. | Agents miss the new repo's instructions entirely. |
| `business-logic-v1.1-proposed.md` is a proposal, not an approved baseline | The proposed scope can be mistaken for an implementation commitment. | Downstream specs and code may implement unapproved requirements. |

## High-Risk Areas

| Area | Risk | Retest |
|---|---|---|
| Branching model changes | Affects all 4 repos simultaneously | Verify branch protection, CI triggers, and tag derivation rules across all repos. |
| Auth design changes | Ripples through API, web, and Android | Verify Google Sign-In integration spec, Supabase auth config, and both client implementations. |
| Adding a new repo to the ecosystem | Must update AGENTS.md glob, git-guidelines scopes/prefixes, release tag tables | Full Set 1 and Set 2 review. |
