# 10 — Deployment

**Purpose:** Release order, how each component ships, tagging conventions, and the release
checklist. Read before cutting a release.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Branching Model

All repos follow the same maturity-based branching model (see `git-guidelines.md` §Branching
Models):

```
main (development) → beta (QA/system testing) → release (integration testing) → production
```

**Promotion rules summary:**
1. Develop on `main`. Unit test here.
2. Promote to `beta` for system testing against product claims.
3. Only after QA approval, promote to `release`.
4. Bundle and publish to the release website for independent integration testing.
5. Test through `a` → `b` → `rc` candidate stages.
6. The designated final approver decides production readiness.
7. Deploy the exact approved `rc` candidate.

*Miss → unapproved code reaches testers or production. See `git-guidelines.md` for the full rules.*

## Release Order Across Components

Not yet established. When multiple components must ship together (e.g., API changes that clients
depend on), document the required deployment order here:

```markdown
1. Database migrations (if any)
2. vera-api (API must be live before clients reference new endpoints)
3. vera-web / vera-android (can deploy independently of each other)
4. vera-specs tags (documentation baseline)
```

*Suspect:* API-first deployment will be required whenever a client depends on new API contracts.

## Versioning

Format: `<prefix>.0X.Y.00Z[label]`

| Product | Prefix | Next tag |
|---|---|---|
| Web front-end | `WCN` | `WCN.01.0.001` |
| Back-end API | `BCN` | `BCN.01.0.001` |
| Android app | `ACN` | `ACN.01.0.001` |
| Specifications | `SCN` | `SCN.01.0.001` |

See `git-guidelines.md` §Format, §Rules, and §Release Tags for the full derivation.

## Weekly Tagging Rules

1. First tag (`001`) goes on the ISO week of the repo's first commit.
2. No commits in a week → no tag, no build number consumed.
3. Never tag the current week until Friday 5:00 PM local time.
4. Each tag covers all commits in its ISO week, pointing to the last commit.
5. Never retag or move an existing tag.
6. Build numbers increase with ISO week order.

## How Each Component Ships

*Not yet applicable — no deployable code exists.* When each component has a build pipeline,
document:

| Component | Build tool | Deploy target | Deploy command | Needs |
|---|---|---|---|---|

## Release Checklist

- [ ] All planned development tasks at 100% completion.
- [ ] Code promoted through `main` → `beta` → `release` with gate approvals.
- [ ] Release bundle published to the release website.
- [ ] Candidate testing completed (`a` → `b` → `rc`).
- [ ] Final `rc` candidate approved by designated approver.
- [ ] Release tags created on `release` branch (not `main` or `beta`).
- [ ] Tags follow `<prefix>.0X.Y.00Z` format.
- [ ] No existing tags moved or reused.
- [ ] Cross-repo dependencies verified (API deployed before dependent clients).
- [ ] `git-guidelines.md` §Release Tags tables updated with new tag entries.
- [ ] Skills documents refreshed (see handoff §Keeping it fresh).
