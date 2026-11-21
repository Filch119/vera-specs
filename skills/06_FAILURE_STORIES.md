# 06 — Failure Stories

**Purpose:** Numbered incidents — what happened, why, how it was found, the fix, and the lesson.
Read to understand why certain rules exist.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Incidents

No production incidents exist — the project is at greenfield stage with no running application.

Add incidents here as they happen, using this format:

```markdown
### Incident N: <title>
**Date:** YYYY-MM-DD
**Severity:** critical | major | minor
**What happened:** one paragraph.
**Why:** root cause.
**How it was found:** who noticed, what alerted, or what test caught it.
**Fix:** what was changed (with commit or PR reference).
**Lesson:** the rule or practice this incident created or reinforced.
**Confidence:** verified | inferred | suspected.
**See also:** 04 #N, 05 symptom, 16 #N.
```

### Incident 1: Inconsistent commit scopes across repos (pre-guidelines)

**Date:** 2026-11-22
**Severity:** minor
**What happened:** Early commits used ad-hoc scopes (`doc:`, `docs:`) that don't match the
conventions later formalized in `git-guidelines.md`.
**Why:** The guidelines didn't exist yet when the first commits were made.
**How it was found:** Reviewing git history during the handoff skills generation.
**Fix:** `git-guidelines.md` now defines the canonical scope format. Existing commits are not
rewritten (history is preserved), but all future commits must follow the standard.
**Lesson:** Establish commit conventions before the first commit, not after. Retrofitting is
possible for docs but impossible for rewritten history without force-push risks.
**Confidence:** verified — `git log --all --oneline` in all repos shows `doc:` and `docs:` scopes.
**See also:** 03 §Commit Conventions, 16 #1.
