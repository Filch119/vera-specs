# 14 — Developer Workflows

**Purpose:** Setup instructions and step-by-step recipes for common tasks. Read when joining the
project or performing a task for the first time.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16).

## Initial Setup

### 1. Clone all repositories

```powershell
mkdir vera-ecosystem
cd vera-ecosystem
git clone https://github.com/Filch119/vera-api.git
git clone https://github.com/Filch119/vera-android.git
git clone https://github.com/Filch119/vera-web.git
git clone https://github.com/Filch119/vera-specs.git
```

### 2. Verify ecosystem structure

```powershell
# All four repos should be siblings under vera-ecosystem/
Get-ChildItem -Directory
# Expected: vera-api, vera-android, vera-web, vera-specs
```

### 3. Read the instructions

1. `vera-ecosystem/AGENTS.md` — points to per-repo instructions.
2. `vera-specs/git-guidelines.md` — commit and versioning conventions.
3. `vera-specs/skills/00_INDEX.md` — reading order for skills documents.
4. `vera-specs/business-logic.md` — proposed product requirements; confirm approval status before implementation.

## Common Tasks

### Making a commit

1. Stage your changes: `git add <files>`.
2. Write a commit message following the standard (see 03 §Commit Conventions):
   ```
   vera-<product>/<feature>: Imperative summary (≤50 chars)

   Why this change was necessary. Wrap at 72 characters.
   ```
3. Verify the scope matches the actual files changed (see 04 §Set 2).
4. If the change touches a lockstep set (see 04), verify all files in the set are updated.
5. Commit: `git commit`.

*Guards against:* vague commits (06 #1), broken lockstep sets (04).
Add what surprised you to `INBOX.md`.

### Checking status across all repos

```powershell
$repos = @("vera-api","vera-android","vera-web","vera-specs")
foreach ($r in $repos) {
    Set-Location ".\$r"
    Write-Host "=== $r ==="
    git status --short
    git log --oneline "@{upstream}..HEAD" 2>&1
    Set-Location ..
}
```

*Guards against:* forgetting to push one repo when others have been pushed.
Add what surprised you to `INBOX.md`.

### Pushing changes across all repos

```powershell
$repos = @("vera-api","vera-android","vera-web","vera-specs")
foreach ($r in $repos) {
    Set-Location ".\$r"
    Write-Host "=== Pushing $r ==="
    git push origin main
    Set-Location ..
}
```

**Before pushing:** verify no unpushed commits are left behind. After pushing, run the status check
above to confirm all repos are clean.
Add what surprised you to `INBOX.md`.

### Adding a new specification document

1. Create the file in `vera-specs/` with a descriptive kebab-case name.
2. Stage and commit with scope `vera-specs/<kind>:` where `<kind>` is `requirements`, `design`,
   `schema`, or `contracts` — or use the feature scope if it belongs to one feature.
3. If the document defines something other repos must follow (e.g., a new feature scope), update
   the lockstep set in 04.

Add what surprised you to `INBOX.md`.

### Creating a weekly release tag

Follow `git-guidelines.md` §Creating a release. Summary:

1. Confirm it's Friday 5:00 PM or later.
2. Identify all ISO weeks since the last tag that have commits.
3. For each such week (earliest first), find the last commit of that week.
4. Create an annotated tag: `git tag -a "<PREFIX>.01.0.<00Z>" <commit> -m "<PREFIX>.01.0.<00Z>"`.
5. Push: `git push origin <tag>`.
6. Update the release tag table in `git-guidelines.md`.

*Guards against:* tagging the wrong commit (05 §Release tag), skipping weeks (04 §Set 2).
Add what surprised you to `INBOX.md`.

## Development Environment (Future)

When each repo has its own setup requirements (Node.js, Android SDK, etc.), document them here:

| Repo | Runtime | Version | Setup command |
|---|---|---|---|
