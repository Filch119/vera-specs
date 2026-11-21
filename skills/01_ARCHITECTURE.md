# 01 — Architecture

**Purpose:** The mental model of the system — components, boundaries, data flows, decisions, and
debt. Read this first when joining the project.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## One-Paragraph Model

Vera is a multi-platform ecosystem for regulatory compliance. It consists of four repositories
under one umbrella (`vera-ecosystem`): a Supabase-backed API server (`vera-api`), a web front-end
(`vera-web`), an Android app (`vera-android`), and a version-controlled specifications repository
(`vera-specs`). The API mediates all data access between the Supabase database and both client
applications. Authentication uses Google Sign-In. The specs repo is the single source of truth for
requirements, design decisions, schema definitions, and conventions — code follows specs, and when
they disagree, the spec is updated or the code is filed as a defect.

## Components and Ownership

| Component | Repository | Owns |
|---|---|---|
| Back-end API | `vera-api` | All server-side logic, Supabase integration, authentication relay, data validation, and API contracts. |
| Web Front-end | `vera-web` | Browser-based regulatory compliance UI, routing, client-side validation, and presentation. |
| Android App | `vera-android` | Native Android regulatory compliance UI, offline behavior, and mobile-specific features. |
| Specifications | `vera-specs` | Requirements (`business-logic-v1.0.md`), conventions (`git-guidelines.md`), research prompts (`sense-making.md`), and this skills folder. |

## Data Flow (End to End)

```
[Android App] ──┐
                ├──▶ [vera-api] ──▶ [Supabase DB]
[Web App]    ──┘         ▲
                         │
                   Google Sign-In
```

Both clients call the API; neither talks to Supabase directly. The API is the single gateway.
*Miss → clients bypass validation, auth, and rate limiting; data integrity breaks.*

## Hard Boundaries

1. **Clients never access the database directly.** All reads and writes go through `vera-api`.
   *Reason:* server-side validation, auth enforcement, and audit logging live in the API layer.
2. **Specs lead, code follows.** A feature is not "designed" until it has a spec in `vera-specs`.
   *Reason:* the ecosystem spans three codebases; without a shared spec, implementations diverge.
3. **One branching model for all repos.** `main` → `beta` → `release` (see `git-guidelines.md`).
   *Reason:* cross-repo releases must be coordinated; different branching models would break the
   promotion gates.

## Decision Records

### Decision: Supabase as the database platform (2026, team)
**Status:** accepted
**Context:** Need a managed PostgreSQL backend with built-in auth helpers and real-time
subscriptions.
**Choice:** Supabase.
**Alternatives:** Firebase (vendor lock-in, NoSQL), raw PostgreSQL (more ops burden), PlanetScale
(MySQL, not Postgres).
**Consequences:** Ties the API to Supabase client libraries; row-level security policies are
available but must be coordinated with API-layer auth.

### Decision: Google Sign-In as the sole auth provider (2026, team)
**Status:** accepted
**Context:** Business logic v1.0 specifies Google Sign-In (requirement #1).
**Choice:** Google Sign-In integration, likely via Supabase Auth.
**Alternatives:** Email/password, magic link, multi-provider.
**Consequences:** Users without Google accounts cannot authenticate. Simplifies the auth surface
for MVP.

### Decision: Mono-ecosystem, multi-repo structure (2026, team)
**Status:** accepted
**Context:** Web, Android, API, and specs each have distinct toolchains and deploy independently.
**Choice:** Four separate repositories under one `vera-ecosystem` umbrella directory.
**Alternatives:** Monorepo (single repo, all code), git submodules.
**Consequences:** Each repo has its own git history, tags, and CI. Cross-repo coordination relies
on the specs repo and consistent branching/versioning conventions. Release tags use product
prefixes (`WCN`, `BCN`, `ACN`, `SCN`) to disambiguate.

## Debt Register

| # | Debt | Severity | Notes |
|---|---|---|---|
| 1 | No application code exists yet — all repos are scaffolding only. | Low | Expected at greenfield. No technical debt, only missing implementation. |
| 2 | Business logic template (`business-logic-v1.0.md`) has placeholder values (`<Code Name>`, `<Team Name>`, feature descriptions). | Medium | Must be filled before development begins, or implementations will diverge from intent. |
| 3 | AGENTS.md files are minimal one-liners. | Low | Sufficient for now; expand as codebases grow. |
