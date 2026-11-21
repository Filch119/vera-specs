# 15 — Known Limitations

**Purpose:** Gaps ordered by how likely they are to surprise: drift, deferred features,
architectural constraints, security weaknesses, bugs, and redesign candidates. Read to understand
what the system cannot do and where it might break.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Most Likely to Surprise

### 1. No application code exists

**Impact:** high — there is nothing to run, test, or deploy.
**Status:** expected at greenfield.
**When it changes:** when the first feature branch is merged to `main` in any code repo.

### 2. Business logic is still proposed

**Impact:** medium — the detailed requirements in `business-logic.md` have not yet
been approved as the implementation baseline.
**Risk:** development begins against unapproved scope, leading to rework.
**Mitigation:** review and approve the proposal before implementation begins.

### 3. Single auth provider (Google Sign-In only)

**Impact:** medium — users without Google accounts are excluded.
**Status:** accepted for MVP (see 09 §Accepted Gaps).
**When it changes:** when additional auth providers are added to business logic requirements.

### 4. Tech stacks not yet chosen

**Impact:** medium — cannot establish code style (03), testing strategy (11), dependency policy
(13), or build pipeline (10) until frameworks are selected.
**Risk:** ad-hoc choices made independently per repo may conflict.
**Mitigation:** choose tech stacks before coding begins and record decisions in 01.

### 5. No CI/CD pipelines

**Impact:** low (at greenfield) → high (once code exists).
**Risk:** the branching model and promotion gates (`main` → `beta` → `release`) require automated
checks to enforce. Without CI, the gates rely entirely on manual discipline.
**Mitigation:** set up CI before the first promotion from `main` to `beta`.

### 6. No branch protection rules

**Impact:** low (at greenfield) → high (multi-developer).
**Risk:** anyone can push directly to `beta` or `release`, bypassing the promotion flow.
**Mitigation:** configure branch protection in GitHub for all repos before adding contributors.

## Deferred Features

*See the explicit out-of-scope boundaries in `business-logic.md` §8.*

## Architectural Constraints

| Constraint | Why it exists | What it prevents |
|---|---|---|
| API-as-sole-gateway | Auth enforcement and validation centralization. | No direct client-to-database features (e.g., Supabase Realtime subscriptions from clients without API mediation). |
| Four separate repos | Independent toolchains and deploy cycles. | Atomic cross-repo commits; must coordinate via specs and conventions. |
| Single branching model for all repos | Cross-repo release coordination. | Per-repo branching experimentation (e.g., trunk-based for one, gitflow for another). |

## Redesign Candidates

| # | Candidate | Why it might need redesign | Trigger |
|---|---|---|---|
| 1 | API-as-sole-gateway | May become a bottleneck if real-time features require direct Supabase subscriptions. | Performance issues with proxied real-time streams. |
| 2 | Four separate repos | Coordination overhead grows with team size and cross-repo features. | Frequent lockstep-set misses across repos. |
