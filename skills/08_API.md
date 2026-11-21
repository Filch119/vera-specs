# 08 — API

**Purpose:** Response envelope, route inventory, endpoint conventions, validators, versioning, and
common mistakes. Read when building or consuming the API.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Current State

No API endpoints exist. `vera-api` contains only `AGENTS.md`. The API will serve as the sole
gateway between both clients (web and Android) and the Supabase database (see 01).

## What We Know from Specs

| Aspect | Source |
|---|---|
| Role | `vera-api/AGENTS.md`: "back-end web application that communicates between the Supabase database API and the web/Android clients" |
| Auth | Google Sign-In (business-logic-v1.0.md #1) |
| Access levels | 5 user levels with graduated feature access (business-logic-v1.0.md §MVP Features and Access) |

## Decisions to Make Before First Endpoint

1. **Response envelope:** Standardize the JSON shape for success and error responses across all
   endpoints. Example: `{ "data": ..., "error": null, "meta": { ... } }`.
2. **Versioning:** URL path (`/v1/`, `/v2/`) vs. header-based. The git-guidelines examples
   reference `/v1/login` and `/v2/auth`, suggesting URL-path versioning is expected.
3. **Authentication flow:** How the Google Sign-In token reaches the API, how it's validated, and
   how sessions are managed.
4. **Rate limiting:** per-user, per-IP, or per-endpoint.
5. **Validation library:** choose one and use it everywhere; ad-hoc validation leads to
   inconsistent error messages.

## How to Add an Endpoint (Template)

Once the API framework is chosen, document the step-by-step here:

```markdown
1. Define the route in ...
2. Create the handler in ...
3. Add input validation using ...
4. Add auth/authz middleware ...
5. Write tests (see 11) ...
6. Update this route inventory ...
7. If the endpoint changes a lockstep set, update 04.
```

## Route Inventory

*Empty — no routes exist yet.*

| Method | Path | Auth | Description | Added |
|---|---|---|---|---|

## Common Mistakes (Future)

Document API-specific anti-patterns here as they emerge.
