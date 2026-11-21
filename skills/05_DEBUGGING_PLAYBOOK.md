# 05 — Debugging Playbook

**Purpose:** Where the logs are and how to diagnose common problems. Read when something breaks.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Where the Logs Are

No application code or infrastructure exists yet. When deployed:

| Component | Expected log location | Notes |
|---|---|---|
| `vera-api` | Supabase dashboard / server stdout | Supabase Edge Functions or custom server logs. |
| `vera-web` | Browser console (`F12`) | Client-side errors and network failures. |
| `vera-android` | Logcat (`adb logcat`) | Filter by app package name. |
| Git/release issues | `git log`, `git reflog` | For tag and branch problems. |

## Common Symptoms

This section is intentionally thin — there is no running code to debug yet. Add entries here as
the first bugs surface, using this format:

```markdown
### Symptom: <exact error message or behavior>
**Frequency:** common | rare | once
**Causes (by likelihood):**
1. Most likely cause — diagnostic shortcut
2. Second cause — diagnostic shortcut
**Resolution:** what to do
**See also:** 06 #N (failure story), 04 #N (lockstep set)
```

### Symptom: Push rejected — "non-fast-forward"

**Frequency:** common (multi-developer setup)
**Causes (by likelihood):**
1. Someone else pushed to the same branch — `git fetch; git log --oneline origin/main..HEAD`
2. Force-push happened upstream — `git reflog` to find divergence point
**Resolution:** `git pull --rebase origin main` then push again. Never force-push `main`, `beta`,
or `release` (see `git-guidelines.md` §Promotion rules #8).

### Symptom: Release tag points to wrong commit

**Frequency:** rare
**Causes (by likelihood):**
1. Tag was created from `main` or `beta` instead of `release` — check with `git log --oneline <tag>`
2. Tag was moved after creation — `git reflog` for tag movement
**Resolution:** Tags must never be moved or reused (`git-guidelines.md` §Creating a release #5).
If a bad tag exists, document the error and create the next sequential tag on the correct commit.

## Useful Commands

| Task | Command |
|---|---|
| Find which commit introduced a file | `git log --follow --diff-filter=A -- <path>` |
| Find unpushed commits | `git log --oneline @{upstream}..HEAD` |
| Check all repos' status at once | Loop through `vera-api`, `vera-android`, `vera-web`, `vera-specs` and run `git status --short` |
| Verify tag placement | `git log --oneline -1 <tag>` |
| Find week boundaries for tagging | `git log --format="%H %ai" --reverse` and bucket by ISO week |
