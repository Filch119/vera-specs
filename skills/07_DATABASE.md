# 07 — Database

**Purpose:** Identity strategy, constraints, table map, migration strategy, integrity invariants,
dangerous operations, and indexing. Read when designing or changing data models.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Current State

The database platform is Supabase (managed PostgreSQL). No schema, tables, migrations, or
row-level security policies have been created yet.

## What We Know from Specs

| Aspect | Source | Detail |
|---|---|---|
| Platform | Architecture decision (01) | Supabase (PostgreSQL). |
| Auth integration | `business-logic-v1.1-proposed.md` §5.1 | Google Sign-In via Supabase Auth. |
| User levels | `business-logic-v1.1-proposed.md` §4 | Five levels: System Administrator, Administrator, Content Reviewer, Student, Guest. |
| Privacy | `business-logic-v1.1-proposed.md` §5.7, §6 | Data Privacy Act compliance, minimal student data access, cohort aggregation threshold, export and deletion rights. |
| Soft deletes | `git-guidelines.md` scope examples | The spec scope `vera-specs/schema: Clarify soft-delete columns` implies soft-delete is planned. |

## Decisions to Make Before First Migration

1. **Identity strategy:** UUIDs vs. sequential IDs. Supabase defaults to UUID for auth users.
   Decide whether application tables follow the same pattern.
2. **Soft-delete convention:** column name (`deleted_at`?), indexing strategy, query defaults.
3. **Row-level security:** whether to enforce at the Supabase level, the API level, or both.
   *Suspect:* both — Supabase RLS as defense-in-depth, API layer as primary enforcement.
4. **Migration tooling:** Supabase CLI migrations, raw SQL, or an ORM migration layer.
5. **Retention limits:** what gets purged, when, and how (per Data Privacy Act requirement).

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
