# 02 — Project Structure

**Purpose:** Annotated tree of the ecosystem, where new code goes and must not go, and naming
conventions that carry meaning.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Ecosystem Layout

```
vera-ecosystem/                  ← umbrella directory (not a git repo itself)
├── vera-api/                    ← back-end API server (git repo)
│   └── AGENTS.md                ← project identity for AI agents
├── vera-android/                ← Android application (git repo)
│   └── AGENTS.md
├── vera-web/                    ← web front-end (git repo)
│   └── AGENTS.md
├── vera-specs/                  ← specifications (git repo)
│   ├── AGENTS.md
│   ├── business-logic-v1.0.md   ← superseded requirements baseline
│   ├── business-logic-v1.1-proposed.md ← proposed updated requirements
│   ├── git-guidelines.md        ← commit and versioning conventions
│   ├── sense-making.md          ← environmental scanning prompt
│   └── skills/                  ← this folder: operational knowledge
│       ├── 00_INDEX.md
│       ├── INBOX.md
│       ├── 01_ARCHITECTURE.md
│       ├── ...
│       └── 16_ENGINEERING_PRINCIPLES.md
├── AGENTS.md                    ← ecosystem-level agent instructions
└── handoff.md                   ← skills generation instructions
```

## Where New Code Goes

| What | Where | Why |
|---|---|---|
| API routes, controllers, middleware | `vera-api/` | All server logic is centralized here. |
| Web pages, components, styles | `vera-web/` | Client-side web code only. |
| Android activities, fragments, ViewModels | `vera-android/` | Native Android code only. |
| Requirements, specs, schemas, conventions | `vera-specs/` | Single source of truth for all design. |
| Skills / operational knowledge | `vera-specs/skills/` | Knowledge about how to build and run Vera. |
| Research and planning artifacts | `vera-specs/planning/` | Output from sense-making and planning tasks. |

## Where New Code Must Not Go

| Do Not | Why | Miss → |
|---|---|---|
| Put API logic in `vera-web/` or `vera-android/` | Clients must not bypass the API layer (see 01 #1). | Validation and auth enforcement are skipped; data integrity breaks. |
| Put spec content in code repos | Specs diverge from each other; no single source of truth. | Implementations across repos contradict each other. |
| Put code in `vera-specs/` | Specs repo is documents only, not executable code. | CI confusion, wrong deploy targets. |
| Create files directly in `vera-ecosystem/` | The umbrella directory is not a git repo. | Files are untracked and will be lost. Only `AGENTS.md` and `handoff.md` live here by convention. |

## Naming Conventions

| Convention | Meaning |
|---|---|
| `vera-` prefix on repo names | All repos belong to the Vera ecosystem. |
| `AGENTS.md` in every repo root | Machine-readable project identity (read by AI agents). |
| `NN_TOPIC.md` in `skills/` | Numbered skill documents; never renumber, only append. |
| `business-logic-vX.Y.md` | Versioned requirements document. |
| Product prefixes (`WCN`, `BCN`, `ACN`, `SCN`) | Release tag prefixes identifying which product a tag belongs to. |
| `code-name-*` in git-guidelines scopes | Generic placeholder; actual scopes use `vera-*`. |
