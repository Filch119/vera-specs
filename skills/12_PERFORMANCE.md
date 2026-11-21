# 12 — Performance

**Purpose:** Hard limits, hot paths, deliberate inefficiencies, expensive operations, and
profiling. Read before optimizing or when investigating slowness.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Current State

No application code exists. This document is minimal because there is nothing to profile. It
establishes the structure for recording performance knowledge as the system grows.

## Hard Limits (Expected)

| Limit | Source | Impact |
|---|---|---|
| Supabase free-tier connection limits | Supabase plan | Concurrent database connections capped; connection pooling needed. |
| Supabase response payload size | Supabase API | Large queries may hit response size limits. |
| Google Sign-In token validation latency | Google API | Each auth check incurs network round-trip if not cached. |
| Android app memory on low-end devices | Target device specs (TBD) | UI rendering and local caching must respect device memory. |

## Hot Paths (Future)

Document the most frequently called code paths once the application exists:

```markdown
### Hot path: <name>
**Frequency:** N calls/sec (estimated or measured).
**Current cost:** X ms / Y allocations.
**Why it's hot:** what user action triggers it.
**Optimization notes:** what was tried, what worked, what to leave alone.
```

## Deliberate Inefficiencies

*None yet.* Document any inefficiency that must be left alone and why:

```markdown
### <what looks inefficient>
**Why it stays:** <what breaks if you "fix" it>.
```

## Profiling (Future)

| Component | Tool | Command |
|---|---|---|
| `vera-api` | TBD | — |
| `vera-web` | Browser DevTools Performance tab | `F12` → Performance |
| `vera-android` | Android Studio Profiler | — |
| Database | Supabase Dashboard → SQL Performance | — |
