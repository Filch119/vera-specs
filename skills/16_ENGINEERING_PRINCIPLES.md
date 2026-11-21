# 16 — Engineering Principles

**Purpose:** Numbered, quotable rules, each with its reasoning, evidence, and source story. The
principles that explain the patterns in this project.

**Confidence note:** verified against `a4fe1d2` on 2026-11-22. The code wins (see 16 #8).

---

### Principle 1: Establish conventions before the first commit

**Rule:** Define commit format, branching model, versioning, and naming conventions before writing
application code — not after.

**Reasoning:** Retrofitting conventions onto existing history is painful and sometimes impossible.
Rewriting git history requires force-pushes that break every collaborator's local clone.

**Evidence:** The first commits in all Vera repos used `doc:` and `docs:` scopes before
`git-guidelines.md` was written. Those commits cannot be fixed without history rewriting, so the
project carries inconsistent early history permanently.

**Source:** 06 #1.

---

### Principle 2: Specs lead, code follows

**Rule:** A feature is not designed until it has a specification in `vera-specs`. Code implements
specs; it does not define them.

**Reasoning:** Three codebases (API, web, Android) implement the same features. Without a shared
spec, each implementation invents its own interpretation. Disagreements surface as bugs in
integration testing, when they're most expensive to fix.

**Evidence:** Architecture decision (01). The existence of `vera-specs` as a dedicated,
version-controlled repository.

**Source:** 01 §Hard Boundaries #2.

---

### Principle 3: One gateway, no shortcuts

**Rule:** All client data access goes through `vera-api`. Clients never talk to Supabase directly.

**Reasoning:** Server-side validation, authentication, authorization, rate limiting, and audit
logging must happen in one place. If clients bypass the API, every client must independently
re-implement every check — and each will do it differently, or not at all.

**Evidence:** Architecture decision (01). `vera-api/AGENTS.md` defines the API's role explicitly.

**Source:** 01 §Hard Boundaries #1.

---

### Principle 4: Every rule has a reason, and every reason names what breaks

**Rule:** Do not write a rule without explaining the failure it prevents. If you can't name what
breaks, the rule shouldn't exist.

**Reasoning:** Unjustified rules get ignored or cargo-culted. When someone doesn't understand why a
rule exists, they either skip it (risk) or follow it blindly and can't adapt when circumstances
change (waste).

**Evidence:** Handoff standards: "No reason, no rule."

**Source:** `handoff.md` §Standards.

---

### Principle 5: Lockstep sets cause most incidents

**Rule:** Identify, number, and document every group of files that must change together. Mark each
with what breaks if you miss one.

**Reasoning:** The most common production incidents come from updating one side of a lockstep pair
and forgetting the other. In a multi-repo ecosystem, the risk multiplies because a single logical
change may span repos with separate commits, PRs, and deploy cycles.

**Evidence:** Four lockstep sets identified at greenfield (04). The ecosystem's multi-repo
structure makes cross-repo lockstep misses likely as the team grows.

**Source:** `handoff.md` §Generate the skills folder #2; 04.

---

### Principle 6: Never move or reuse a tag

**Rule:** Once a release tag exists, it is permanent. Create a new tag with the next sequential
number for corrections.

**Reasoning:** Moving a tag changes what an existing reference points to. Anyone who checked out,
tested, or approved that tag is now looking at different code than they think. Audit trails break.
Reproducibility breaks.

**Evidence:** `git-guidelines.md` §Creating a release #5: "Never retag or move an existing tag."

**Source:** `git-guidelines.md`.

---

### Principle 7: The promotion gate is not optional

**Rule:** Code moves from `main` → `beta` → `release` only after each stage's gate is satisfied.
No skipping.

**Reasoning:** Each stage serves a different testing purpose with different testers. Skipping a
stage means untested code reaches people who assume it was tested. The `release` branch is not
"released" — it is "being tested for release." Presence on `release` is not production approval.

**Evidence:** `git-guidelines.md` §Promotion rules.

**Source:** `git-guidelines.md` §Branching Models.

---

### Principle 8: Trust the code over any document, including this one

**Rule:** When a document disagrees with the running code, the document is the bug — unless the
code is a known defect filed against a spec.

**Reasoning:** Documents rot. Code is what actually runs. A document that confidently describes
behavior the code doesn't have is worse than no document at all, because it teaches the wrong
thing with authority.

**Evidence:** Handoff standard: "The code wins."

**Source:** `handoff.md` §Standards.
