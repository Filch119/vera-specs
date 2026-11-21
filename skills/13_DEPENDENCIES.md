# 13 — Dependencies

**Purpose:** The dependency policy, each dependency's reason, upgrade traps, and deliberate
rejections. Read before adding or upgrading a dependency.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Policy

1. **Every dependency needs a reason.** Record it in this document when you add it. No reason, no
   dependency.
2. **Prefer standard library and platform features** over third-party packages when the
   functionality is comparable.
3. **Pin versions** in lock files. Document known upgrade traps here.
4. **One dependency per concern.** Don't add two libraries that do the same thing.
5. **Record rejections.** When a dependency is considered and rejected, document why, so the next
   person doesn't re-evaluate it.

## Current Dependencies

### Ecosystem-Level

| Dependency | Reason | Repository | Notes |
|---|---|---|---|
| Supabase | Managed PostgreSQL + Auth + real-time | `vera-api` (primary), clients (SDK) | Architecture decision (see 01). |
| Google Sign-In | Sole auth provider per `business-logic-v1.1-proposed.md` §5.1 | All (via Supabase Auth) | — |

### vera-api

*No dependencies beyond git.* Tech stack not yet chosen.

### vera-web

*No dependencies beyond git.* Tech stack not yet chosen.

### vera-android

*No dependencies beyond git.* Tech stack not yet chosen.

### vera-specs

*No runtime dependencies.* Content is Markdown documents only.

## Upgrade Traps (Future)

```markdown
### <dependency>: <version range>
**Trap:** what breaks on upgrade.
**Safe upgrade path:** step-by-step.
```

## Deliberate Rejections

| Dependency | Rejected for | Why | Date |
|---|---|---|---|
| Firebase | Database and auth | Vendor lock-in, NoSQL (not PostgreSQL), less control over data layer. | 2026 (see 01 decision record) |
| PlanetScale | Database | MySQL, not PostgreSQL; Supabase chosen for Postgres compatibility. | 2026 (see 01 decision record) |
