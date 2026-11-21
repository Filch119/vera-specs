# 11 — Testing

**Purpose:** Honest coverage assessment, how the team gains confidence, what must be tested,
mocking strategy, and the dimensions that break. Read when writing tests or evaluating test
adequacy.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Honest Coverage

**Current coverage: 0%.** No application code or tests exist in any repository.

## How the Team Gains Confidence

The project defines four testing stages in `git-guidelines.md` §Release Testing and Approval:

| Stage | Who | Where | Purpose |
|---|---|---|---|
| Unit testing | Developers | `main` | Verify individual units before QA. |
| System testing | QA | `beta` | Validate major product claims. |
| Integration testing | Independent testers | `release` | Test published release bundles. |
| Production approval | Designated final approver | — | Decide production readiness. |

**Key rule:** Independent integration testers test only published release bundles, not unreleased
code on development branches. *Miss → testers validate code that may change before release.*

## What Must Be Tested

*To be established with the first implementation.* At minimum, based on the specs:

| Area | Why | Minimum confidence |
|---|---|---|
| Google Sign-In flow | Single auth provider — if it breaks, nobody can use the system. | End-to-end test across API + at least one client. |
| User level enforcement | 5 levels with different feature access; privilege escalation is a security risk. | Unit tests for every level × feature combination. |
| API ↔ Supabase integration | The API is the sole data gateway; a failure here blocks all clients. | Integration test against a Supabase test instance. |
| Data privacy compliance | Legal requirement (Data Privacy Act). | Verify retention limits, aggregation thresholds, and no per-user trails. |

## Testing Strategy (Template)

When the first tests are written, document:

1. **Framework:** what test runner / assertion library.
2. **Structure:** where test files live relative to source.
3. **Naming:** test file and test case naming conventions.
4. **Mocking:** what to mock (external services, Supabase), what library, and what must never
   be mocked (auth enforcement, data validation).
5. **CI integration:** how tests run on push, on PR, and before promotion.

## Dimensions That Break

Based on the architecture, these are the dimensions most likely to cause failures:

| Dimension | Why |
|---|---|
| Cross-repo contract changes | API changes that web or Android depend on but weren't updated. |
| Auth token expiry edge cases | Token refresh races, expired tokens in offline-first Android app. |
| User level boundary conditions | Guest accessing Contributor features; Moderator accessing Admin features. |
| Supabase RLS ↔ API auth mismatch | API allows something that RLS blocks, or vice versa. |
