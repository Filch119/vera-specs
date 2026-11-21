# 09 — Security

**Purpose:** Threat model, authentication, authorization, secrets handling, injection surfaces,
and change checklist. Read before any auth, access control, or data-handling change.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Threat Model (High Level)

| Threat | Attack surface | Mitigation (planned or in place) |
|---|---|---|
| Unauthorized data access | API endpoints, Supabase direct access | API-layer auth enforcement; Supabase RLS as defense-in-depth (see 07). Clients must not access DB directly (see 01). |
| Privilege escalation | User level checks (A–E) | Role-based access per feature matrix (`business-logic-v1.1-proposed.md` §7). |
| Data exfiltration / privacy violation | All data endpoints | Data Privacy Act compliance: retention limits, no per-user trails, aggregation thresholds, consent for resale (see 07). |
| Token theft / session hijacking | Google Sign-In tokens, session cookies | HTTPS only; token validation on every request; short-lived tokens with refresh. |
| Injection (SQL, XSS, etc.) | API inputs, web front-end rendering | Server-side input validation (parameterized queries via Supabase client); client-side output encoding. |

## Authentication

- **Provider:** Google Sign-In (sole provider per `business-logic-v1.1-proposed.md` §5.1).
- **Mechanism:** Supabase Auth with Google OAuth (suspected — to be confirmed when implemented).
- **Flow:** Client obtains Google token → sends to API → API validates via Supabase Auth → returns session token.

## Authorization Layers

| Layer | Where | What it enforces |
|---|---|---|
| API middleware | `vera-api` | User level (A–E) checked against feature access matrix. |
| Supabase RLS | Database | Row-level policies as defense-in-depth (planned). |
| Client-side UI | `vera-web`, `vera-android` | Hides UI elements per role (cosmetic only — not a security boundary). |

*Miss → relying on client-side checks alone lets a modified client access any feature.*

## Secrets Handling

- **Rule:** Name environment variables in docs and code, never their values.
- **Storage:** Use `.env` files locally (never committed), environment variables in production.
- **Expected secrets (once implemented):**

| Variable | Purpose |
|---|---|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (server-side only, never in clients) |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |

## Accepted Gaps

| Gap | Risk | Why accepted |
|---|---|---|
| Single auth provider (Google only) | Users without Google accounts are excluded. | MVP scope decision; additional providers can be added later. |
| No application code to audit | Cannot verify security implementation. | Greenfield; this document establishes the security design before code exists. |

## Security Change Checklist

Before merging any change that touches auth, access control, or data handling:

- [ ] Does it maintain the API-as-sole-gateway boundary?
- [ ] Are user levels checked server-side, not just client-side?
- [ ] Are all inputs validated and parameterized?
- [ ] Are secrets referenced by variable name only (no values in code or docs)?
- [ ] Does it comply with the Data Privacy Act requirements in `business-logic-v1.1-proposed.md` §5.7 and §6?
- [ ] Has the lockstep set for auth changes been reviewed (see 04)?
