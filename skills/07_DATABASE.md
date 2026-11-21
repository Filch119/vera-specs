# 07 — Database

**Purpose:** Identity strategy, constraints, table map, migration strategy, integrity invariants,
dangerous operations, and indexing. Read when designing or changing data models.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Current State

The database platform is Supabase (managed PostgreSQL). The idempotent initial schema snapshot is
`db-schema/v1.0.0.sql`. It defines the MVP tables, UUID relationships, server-only identity keys,
seed curriculum, and RLS policies.

## What We Know from Specs

| Aspect | Source | Detail |
|---|---|---|
| Platform | Architecture decision (01) | Supabase (PostgreSQL). |
| Schema baseline | `db-schema/v1.0.0.sql` | Idempotent MVP schema snapshot. |
| Identity | `db-design-choices.md` §2–3 | Server-only `id bigint`; application relationships use `*_uuid`. |
| Offline sync | `db-design-choices.md` §5–6 | Soft-delete tombstones and idempotent append-only attempt events. |
| Auth integration | `business-logic.md` §5.1 | Google Sign-In via Supabase Auth. |
| User levels | `business-logic.md` §4 | Five levels: System Administrator, Administrator, Content Reviewer, Student, Guest. |
| Privacy | `business-logic.md` §5.7, §6 | Data Privacy Act compliance, minimal student data access, cohort aggregation threshold, export and deletion rights. |
| Soft deletes | `git-guidelines.md` scope examples | The spec scope `vera-specs/schema: Clarify soft-delete columns` implies soft-delete is planned. |

## Decisions to Make Before First Migration

1. **Migration tooling:** apply reviewed versioned SQL scripts; forward migrations bump the patch
   component and exported full snapshots bump the minor component (see `db-design-choices.md`).
2. **Retention limits:** define automated purge jobs and evidence of deletion against the
   Data Privacy Act timelines in `business-logic.md`.
3. **RLS rollout:** the schema defines owner and staff policies, while the API currently uses the
   server-side service role. API authorization must enforce equivalent access boundaries because
   the service role bypasses RLS.

## Dangerous Operations (Future)

Document here as schema evolves:

```markdown
### Operation: <name>
**Risk:** what breaks.
**Safe procedure:** step-by-step.
**Retest:** what to verify after.
```

## Integrity Invariants (Future)

Document non-obvious constraints that the schema alone doesn't enforce:

```markdown
### Invariant: <description>
**Enforced by:** constraint / trigger / API code / none (manual).
**Miss →** what breaks.
```
