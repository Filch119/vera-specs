# Business Logic v1.1 (Proposed)

> Specification for a Web and Android mastery-based study and practice app using
> React (TypeScript), Capacitor, and Supabase (PostgreSQL) for DOST-SEI JLSS
> examinees in the Philippines.

- **Status:** Proposed (Evolution of `business-logic-v1.0.md`)
- **Allowed Platforms:** Web (PWA/Responsive), Android (Capacitor)
- **Target Audience:** Incoming 3rd-year Filipino undergraduate STEM students
  reviewing for the DOST-SEI Junior Level Science Scholarship (JLSS).

---

## 1. Project Details & Strategic Positioning

- **Company / Team Name:** `Verifai`
- **Project Code Name:** `Vera` (JLSS Study Hub)
- **Project Short Code:** `VE` (Tag prefixes: `WVE`, `BVE`, `AVE`, `SVE`)
- **Product Vision:** The "Khan Academy of DOST-SEI JLSS" — combining
  deliberate practice, diagnostic phase planning, focus tracking, and transparent
  mastery metrics into an offline-first companion that turns overwhelmed examinees
  into confident scholarship qualifiers.
- **Short Description:** A Khan Academy-inspired JLSS exam prep app that combines
  a phase-based study calendar and focus timer with mastery-based topic practice,
  hints, worked solutions, spaced review, and timed mock exams, using verified
  AI-generated and admin-curated questions.
- **Long Description:** Vera guides examinees through an adaptive, disciplined study
  path tailored to the official DOST-SEI JLSS syllabus. Students set their target
  scholarship track (RA 7687, Merit, or RA 10612) and exam date to generate an
  adaptive phase calendar (Orientation, Core Mastery, Practice & Integration,
  Final Review & Rest). Each day is balanced across difficulty tiers (Rest, Light,
  Medium, Heavy). Examinees navigate the 4 DOST domains (Logical Reasoning,
  English, Science, and Mathematics), study concise high-yield notes, and practice
  standard DOST-style multiple-choice questions (A–D) designed strictly under the
  DOST "No Calculator" constraint. Subtopic mastery progresses through five
  deterministic tiers (Not Started, Attempted, Familiar, Proficient, Mastered).
  Misconceptions trigger targeted hints, worked rationales for distractors, and
  spaced review. A native Pomodoro timer reinforces focus sessions, while timed mock
  exams simulate actual exam pressure and deliver diagnostic score reports by
  subject and error category. Practice works seamlessly offline on Android and Web,
  syncing progress on reconnection. The app operates under strict Data Privacy Act
  (RA 10173) compliance, ensuring student data is private, never sold, and never
  used for unauthorized model training.

---

## 2. Competitive Positioning & MVP Gap Analysis (v1.0 vs v1.1)

To ensure a rapid time-to-market while delivering maximum utility, v1.1 addresses
critical gaps identified in the v1.0 baseline:

| Dimension | v1.0 Baseline | v1.1 Proposed Refinement | Why It Matters for Launch |
|---|---|---|---|
| **Scholarship Track Awareness** | Generic onboarding (date & hours only). | Captures Target Track (RA 7687, Merit, RA 10612) and College Major during onboarding. | Calibrates baseline diagnostics (e.g., Engineering students need biology focus; Bio students need calculus/physics focus). |
| **DOST Exam Constraints** | General multiple-choice practice. | **Strict "No Calculator Policy" enforcement** on all Math & Physics items; focus on estimation, mental math, and conceptual derivations. | Prevents drafting questions that are impossible to solve under actual exam constraints. |
| **Content Bottleneck & Curated Scope** | 115 subtopics (~2,300 questions needed before launch). | **Curated MVP Core of 48 High-Yield Subtopics (~1,000–1,200 questions)**; remaining subtopics slated for Phase 2 content drops. | **Slashes reviewer bottleneck by 50%**, enabling immediate product launch ahead of the exam cycle. |
| **Mastery Calculation Rules** | Abstract level labels without deterministic logic. | **Explicit, deterministic scoring thresholds** (Attempts, Accuracy % on rolling 10, Quiz score, and Spaced-Repetition verification). | Developers can implement cleanly without guessing or creating inconsistent client/server scoring logic. |
| **Diagnostic Quiz Friction** | Optional full subject diagnostic (risking drop-off). | **15-minute Rapid Diagnostic (20 items: 5 per domain)** or 1-tap "Self-Reported Baseline" skip. | Minimizes onboarding friction so students reach the value loop in <2 minutes. |
| **Offline Sync Conflict Model** | Unspecified sync queue logic. | **Append-only attempt log with idempotent server-side mastery/streak recalculation.** | Eliminates complex 2-way merge conflicts across offline phone and desktop web. |
| **AI Validation Guardrails** | General mention of automated checks. | **8 concrete deterministic pre-review validation rules** (syntax, LaTeX/MathJax sanity, 4 choices, 1 key, distractor rationales, solver verification, and similarity hash). | Protects reviewers from wasting time on broken formatting or hallucinated math keys. |

---

## 3. DOST-SEI JLSS Exam Blueprint & Domain Coverage

The JLSS examination evaluates candidates across four primary domains. All questions
follow the single-response multiple-choice format (Options A, B, C, D) with no
negative marking.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   DOST-SEI JLSS 4 CORE DOMAINS                         │
├────────────────────┬────────────────────┬──────────────────────────────┤
│ Domain             │ Weight / Questions │ Key Subject Areas Covered    │
├────────────────────┼────────────────────┼──────────────────────────────┤
│ 1. Logical         │ ~25% (40-50 items) │ Abstract Reasoning, Spatial, │
│    Reasoning       │                    │ Mechanical, Data Sufficiency │
├────────────────────┼────────────────────┼──────────────────────────────┤
│ 2. English         │ ~20% (30-40 items) │ Word Association, Analogy,   │
│                    │                    │ Grammar, Reading Compreh.    │
├────────────────────┼────────────────────┼──────────────────────────────┤
│ 3. Science         │ ~30% (50-60 items) │ Biology, General Chemistry,  │
│                    │                    │ Physics, Earth/Space Science │
├────────────────────┼────────────────────┼──────────────────────────────┤
│ 4. Mathematics     │ ~25% (40-50 items) │ Algebra, Geometry & Trig,    │
│                    │                    │ Statistics, Basic Calculus   │
└────────────────────┴────────────────────┴──────────────────────────────┘
```

### MVP High-Yield Subtopic Strategy (48 Core Subtopics)

Rather than delaying launch to populate all 115 theoretical subtopics, the MVP
prioritizes the **12 highest-frequency subtopics per domain**:

1. **Logical Reasoning (12):** Figure Series, Figure Matrix, Pattern Completion,
   Paper Folding/Spatial, Mechanical Reasoning (Pulleys/Gears), Verbal Classification,
   Number Series, Syllogisms, Logical Deduction, Data Sufficiency, Coding-Decoding,
   Direction Sense.
2. **English (12):** Vocabulary in Context, Analogies & Associations, Error
   Identification, Sentence Completion, Subject-Verb Agreement, Idiomatic Phrases,
   Pronoun-Antecedent Agreement, Parallel Structure, Paragraph Organization,
   Main Idea & Inference, Tone/Author's Purpose, Critical Reading.
3. **Science (12):**
   - *Biology:* Cell Biology & Mitosis/Meiosis, Genetics & Mendelian Inheritance,
     Ecology & Ecosystems, Human Organ Systems & Homeostasis.
   - *Chemistry:* Periodic Trends & Bonding, Chemical Reactions & Stoichiometry,
     Solutions & Concentrations (Molarity/Molality), Acids, Bases & pH.
   - *Physics:* Kinematics & Newton's Laws, Work, Energy & Power, Thermodynamics &
     Heat Transfer, Basic Electricity & Magnetism.
   - *Earth Science:* Plate Tectonics, Rock Cycle & Minerals.
4. **Mathematics (12):** Linear & Quadratic Equations, Polynomial Operations,
   System of Equations, Ratios, Proportions & Percentages, Exponents & Logarithms,
   Plane Geometry (Angles, Triangles, Circles), Trigonometric Identities & Right
   Triangles, Coordinate Geometry & Conics, Permutations & Combinations,
   Basic Probability, Descriptive Statistics (Mean, Median, Mode, Variance),
   Limits & Derivatives Fundamentals.

---

## 4. User Levels & Permissions

| User Level | Identifier | Role & Functional Scope |
|---|---|---|
| **System Administrator** | `A` | Manages environment configs, database maintenance, user role promotions, feature flags, security audit logs, backups, and restores. |
| **Administrator** | `B` | Configures official exam dates, study phase boundaries, curriculum definitions; triggers batch AI question generation; assigns reviewer queues; views anonymized cohort analytics (N ≥ 20). |
| **Content Reviewer** | `C` | Subject-matter expert who reviews, tests, edits, approves, rejects, and unpublishes question items and notes; resolves student error reports. **Zero access to any student's PII or individual score history.** |
| **Student (Examinee)** | `D` | Authenticated learner who configures study plans, completes diagnostic/practice sets, runs Pomodoro sessions, takes timed mock exams, tracks mastery, and manages privacy exports. |
| **Guest** | `E` | Unauthenticated visitor viewing public landing pages, curriculum map, sample 5-question preview set, and FAQ. Progress is unpersisted. |

---

## 5. System Requirements (Functional Specification)

### 5.1 Onboarding & Authentication
1. **Google Sign-In:** The system shall authenticate examinees using Google OAuth
   2.0 via Supabase Auth, storing minimal profile info (email, display name).
2. **Contextual Onboarding:** The app shall prompt new students to select:
   - Target JLSS Track (`RA 7687`, `Merit`, or `RA 10612`).
   - Current Undergraduate Program / Field (`Engineering/Math`, `Natural Sciences`,
     `Health Sciences`, `Secondary STEM Education`, `Other Priority S&T`).
   - Confirmed or estimated Exam Date.
   - Target Daily Study Window (30m, 60m, 90m, or 120m).
3. **Rapid Diagnostic Assessment:** The app shall offer a 20-item diagnostic quiz
   (5 items per domain) or allow immediate 1-tap self-assessment (Low, Moderate,
   Strong per domain) to seed the initial mastery state without friction.

### 5.2 Adaptive Phase Planning & Study Calendar
4. **Automated Phase Generation:** Based on the days remaining before the exam date,
   the system shall allocate the student's study timeline across 4 phases:
   - **Phase 1: Orientation & Diagnostic** (Week 1 / Days 1–7)
   - **Phase 2: Core Topic Mastery** (60% of remaining days)
   - **Phase 3: Integration & Timed Drills** (25% of remaining days)
   - **Phase 4: Final Review, Mock & Rest** (Final 10–14 days)
5. **Day Intensity Tiers:** Each calendar day shall be assigned an intensity tag:
   - `Rest`: 0 active items; habit maintained without penalty.
   - `Light`: 1 subtopic practice set (~15–20 mins).
   - `Medium`: 2 subtopic sets + 1 spaced-review drill (~45–60 mins).
   - `Heavy`: 3 subtopic sets + 1 quiz or mini-mock (~75–100 mins).
6. **Slip Recovery Engine:**
   - *1-Day Miss:* Automatically appends a 20-minute recap block to the next
     scheduled study day without doubling total workload.
   - *2–3 Days Miss:* Triggers an automatic calendar re-compression dialog,
     re-prioritizing unfinished High-Yield subtopics and dropping low-weight topics.
   - *Burnout Mode:* One-tap schedule reduction to "Maintenance Mode" (Light only
     for 3 days) with empathetic guidance.

### 5.3 Topic Practice, Mastery Engine & Spaced Review
7. **DOST Practice Engine:** Students can open any subtopic and solve multiple-choice
   questions (A–D). Every item features:
   - Optional 2-level progressive hints (Level 1: Formula/Concept hint; Level 2:
     Setup hint). Using hints reduces points earned by 50% for that attempt.
   - Instant feedback on submit with complete worked rationales for both the
     correct option and why distractors are incorrect.
   - **"No Calculator" design guarantee:** Calculations use clean integers,
     cancellable fractions, or round estimates.
8. **Deterministic 5-Tier Mastery Logic:**
   - `Not Started`: 0 attempts on subtopic.
   - `Attempted`: ≥ 1 practice item attempted, but accuracy < 60%.
   - `Familiar`: Accuracy between 60% and 79% over the last 10 attempts.
   - `Proficient`: Rolling accuracy ≥ 80% on standard difficulty OR scored ≥ 8/10
     on subtopic quiz.
   - `Mastered`: Passed subtopic quiz (≥ 8/10) AND successfully answered 2
     subsequent spaced-repetition checks across different calendar days.
   - *Decay/Review Condition:* Drops from `Mastered` to `Proficient` if a spaced
     review is failed or neglected for > 21 days.
9. **Spaced-Repetition Review Queue:** Missed questions and decaying subtopics are
   automatically surfaced via a fixed-interval ladder:
   - Interval 1: +1 day after error.
   - Interval 2: +3 days after correct response.
   - Interval 3: +7 days after correct response.
   - Interval 4: +14 days (final verification).
10. **Weak Spot Radar:** Automatically highlights up to 3 subtopics where rolling
    accuracy is < 60% after ≥ 5 attempts, placing them at the top of the daily
    dashboard as "Priority Recovery."
11. **Subtopic Quizzes:** Standardized 10-item quizzes per subtopic under mild time
    pressure (15 minutes). Passing mark is strictly 8/10.

### 5.4 Focus Timer & Habit Motivation
12. **Pomodoro Focus Timer:** Integrated timer with standard presets:
    - `25 / 5` (Standard), `50 / 10` (Deep Work), `90 / 20` (Ultradian), `15 / 5`
      (Quick Burst).
    - Runs in the background on Android using Capacitor Local Notifications and
      foreground audio chime on phase completion.
    - Completed intervals automatically increment the daily focus log and award
      Mastery Points.
13. **Streak & Habit Loop:**
    - Daily streak increments when the student meets their day's intensity goal.
    - `Rest` days designated by the calendar do not break streaks.
    - Students earn 1 `Streak Freeze` per 7 consecutive study days (max 2 banked).
    - Day boundary is calculated strictly in `Asia/Manila` time (UTC+8).
14. **Milestone Badges:** Awarded for objective accomplishments (e.g., "Math
    Whiz" for 5 Mastered Math topics, "Century Club" for 100 questions completed,
    "Calculators Forbidden" for 50 mental math problems solved).

### 5.5 Timed Mock Exams & Diagnostic Analytics
15. **Standardized Mock Exam Simulation:**
    - **Full Mock Exam:** 160 items, timed at 2 hours and 30 minutes, structured
      identically to the DOST JLSS proportion: 40 Logical Reasoning, 30 English,
      50 Science, 40 Mathematics.
    - **Mini Mock (Domain Drill):** 40 items, 45 minutes on a single chosen domain.
    - No mid-exam feedback; strictly simulates real test conditions.
16. **Diagnostic Performance Report:** At the conclusion of a mock exam:
    - Overall scaled score and percentage per domain.
    - Comparison against estimated JLSS qualifying cutoffs (historical baseline).
    - Error categorization breakdown:
      - *Conceptual Gap:* Chose distractor reflecting common misconception.
      - *Calculation / Careless Error:* Incorrect arithmetic or missed detail.
      - *Time Out / Unanswered:* Questions skipped due to pace.
    - 1-tap addition of all incorrect mock items into the Spaced Review Queue.

### 5.6 Question Curation & AI Generation Pipeline
17. **Admin Batch Generation Pipeline:** Administrators can request AI generation
    batches specifying domain, subtopic, difficulty (Easy, Medium, Hard), and count.
    - All outputs are inserted as `DRAFT` status with complete provenance metadata
      (model identifier, generation timestamp, prompt version).
18. **Automated Pre-Review Validation Gates (The 8 Sanity Checks):** Before an item
    can enter the Content Reviewer queue, automated scripts verify:
    1. Schema conforms to standardized JSON structure.
    2. Exactly 4 distinct options provided (A, B, C, D).
    3. Exactly 1 valid option marked as correct key.
    4. Explanations exist for the key AND all 3 distractors.
    5. Prompt text ≤ 350 words; each option text ≤ 50 words.
    6. Mathematical equations pass valid LaTeX/KaTeX syntax parsers.
    7. Semantic similarity / duplicate hash score < 0.85 against existing questions.
    8. Mental-math feasibility check (no computational item requiring multi-digit
       division or decimal approximations that necessitate a calculator).
19. **Content Reviewer Queue:** Reviewers can inspect assigned drafts, test the
    question in preview mode, edit text/rationales, approve (transitions status to
    `PUBLISHED`), or reject with structured reasons (e.g., Ambiguous Prompt, Wrong
    Answer Key, Inappropriate for JLSS).
20. **Student Question Flagging & Auto-Quarantine:**
    - Students can report questions with tags (`Wrong Answer`, `Typo / Broken Math`,
      `Ambiguous Question`).
    - An item that receives **3 independent reports** is automatically quarantined
      (hidden from public practice) and returned to the top of the Reviewer Queue.

### 5.7 Offline-First Architecture & Data Portability
21. **Offline Practice Packs:** Students can download high-yield subtopic bundles
    (JSON text + lightweight vector diagrams, < 2 MB per subject) for complete
    offline practice on Android and Web.
22. **Idempotent Sync Queue:**
    - Offline attempts, timer logs, and quiz results are stored locally in SQLite
      (Android) or IndexedDB (Web).
    - On reconnection, logs sync via an append-only transaction. The server computes
      mastery point increments, streak updates, and weak spots idempotently using
      the client event timestamp.
23. **Data Privacy Act (RA 10173) & Data Rights:**
    - Students can export their complete profile, study logs, and attempt history
      as standard JSON in one click.
    - Account deletion permanently erases all personal data, email, and session logs
      within 48 hours.
    - **No student data is ever shared, resold, or used for model fine-tuning.**

---

## 6. Required Solution Layers

1. **Security & Privacy Layer (RA 10173):**
   - Supabase Row-Level Security (RLS) enforcing strict tenant isolation.
   - Zero access by reviewers or administrators to student-specific answer logs.
   - Analytics queries enforced at cohort aggregation threshold (N ≥ 20).
   - Encrypted local storage on mobile device.
2. **AI Question Generation & Validation Layer:**
   - Back-end Python/Node script invoking Gemini/LLM with structured output schema.
   - Automated validator checking 8 sanity gates prior to reviewer intake.
   - Strict adherence to DOST-SEI JLSS syllabus primers and copyright standards.
3. **Question Bank & Content Repository:**
   - Versioned question schema with LaTeX/KaTeX math formula support.
   - Multi-tier tagging (Domain, Subtopic, Difficulty, Track-Relevance).
   - Provenance tracking (Draft, In-Review, Published, Quarantined, Deprecated).
4. **Planning & Calendar Engine:**
   - Dynamic schedule generator computing phase boundaries from exam countdown.
   - Slip-recalculation algorithms (1-day recap, 2-3 day recompression).
5. **Practice, Mastery & Spaced-Repetition Engine:**
   - Real-time client-side scoring with worked solution reveals.
   - Leitner/Fixed-interval spaced review scheduler.
   - Subtopic mastery state machine (5 tiers).
6. **Focus & Habit Engine:**
   - Native Capacitor Pomodoro timer service with local chime notifications.
   - Timezone-locked (Asia/Manila) streak calculator with freeze logic.
7. **Offline-First Synchronization Layer:**
   - Local database cache (Capacitor SQLite on Android, IndexedDB on Web).
   - Background sync worker executing on `navigator.onLine` or network change.

---

## 7. MVP Features and Access Matrix

| Feature Module | Scope Details | User Levels |
|---|---|---|
| **1. Public Preview & Topic Map** | Browse 4 DOST domains, view 48 core subtopics, read sample notes, try 5-item unpersisted preview set. | A, B, C, D, E |
| **2. Auth & Personalized Onboarding** | Google Sign-In, target track selection (RA 7687, Merit, RA 10612), major, exam date, 20-item diagnostic or instant baseline. | A, B, C, D |
| **3. Adaptive Phase Calendar** | 4-phase schedule, daily intensity tags (Rest/Light/Med/Heavy), slip adjustment (recap/recompress), burnout reset. | A, B, C, D |
| **4. Pomodoro Focus Timer** | Presets (25/5, 50/10, etc.), local audio alerts, background run on Android, automatic study log. | A, B, C, D |
| **5. Topic Practice & Worked Solutions** | Multiple choice (A–D), progressive hints, instant feedback, correct/distractor explanations, no-calculator math. | A, B, C, D |
| **6. Subtopic Quizzes & Mastery Tracking** | 10-item quizzes (8/10 pass), 5 mastery tiers, automated weak-spot detection radar. | A, B, C, D |
| **7. Spaced-Repetition Review** | Automated resurfacing of missed questions and decaying topics (1d, 3d, 7d, 14d ladder). | A, B, C, D |
| **8. Habit Loops & Motivation** | Daily streak with freeze protection, Asia/Manila day cutoff, mastery points, milestone achievement badges. | A, B, C, D |
| **9. Timed Mock Exams & Score Reports** | Full Mock (160 items, 2.5h) and Mini Mock (40 items, 45m), diagnostic breakdown by domain and error type. | A, B, C, D |
| **10. Offline Practice & Sync** | Download high-yield offline packs, offline practice/timer, automatic idempotent sync on reconnect. | A, B, C, D |
| **11. Privacy, Question Flagging & Export** | Report unclear/wrong items, download data as JSON, account deletion, clear DPA privacy notice. | A, B, C, D |
| **12. Content Reviewer Workspace** | Subject-assigned review queue, question editor, approve/reject/unpublish actions, report resolution. | A, B, C |
| **13. AI Question Generation Pipeline** | Admin-triggered batch generation by subtopic/difficulty, provenance logging, 8 automated validation checks. | A, B |
| **14. Curriculum & System Management** | Manage official exam date, phase rules, plan templates, core notes, and view cohort analytics (N ≥ 20). | A, B |
| **15. System Administration & Security** | User role management, feature flags, audit log reviews, backup and disaster recovery. | A |

---

## 8. Explicit Out-of-Scope Boundaries (Protecting Time-to-Market)

To guarantee that the engineering team ships a rock-solid, production-ready MVP on
schedule, the following capabilities are **explicitly excluded from v1.1**:

1. **No Social Leaderboards or Peer Comparisons:** Focus remains on individual
   mastery and stress-reduction rather than toxic social comparison.
2. **No Real-Time Multi-User Mock Exams:** Asynchronous, self-paced mock exams only.
3. **No Direct Student-Facing AI Chat / Tutoring Bots:** High latency, hallucination
   risks, and high operational API token costs make live student LLM chat unsuitable
   for MVP. Questions and hints are pre-generated and human-reviewed.
4. **No Video Lessons or Live Streaming:** High-yield text summaries and worked
   formula cards keep bandwidth low and app size lightweight.
5. **No Native iOS Build at Launch:** Android dominates >85% of collegiate student
   devices in the Philippines; Web serves desktop/iOS users via browser.
6. **No Paid Paywalls or Payment Gateway:** Free, open access for Filipino examinees
   during the initial scholarship season.
7. **No Server-Side Push Notification Infrastructure:** Uses native Android
   local notifications to eliminate server push dependency and push-service costs.

---

## 9. Implementation Notes & Operational Recommendations

- **Review Capacity Calculation:** 48 core subtopics × 25 questions = **1,200
  questions**. With 3 dedicated reviewers (Math, Science, English/Logic), each
  reviewer must vet 400 questions. At 25 questions/day, the content bank reaches
  100% human-verified completeness in **16 working days**.
- **Math/Formula Formatting:** All mathematical and chemical formulas must strictly
  use LaTeX strings rendered via KaTeX on both Web and Android to maintain crisp
  rendering across all screen resolutions without image bloat.
- **DOST-SEI Disclaimer:** A clear, permanent footer disclaimer must be displayed
  on Web and Mobile: *"Vera is an independent study companion developed by Verifai
  and is not affiliated with, endorsed by, or sponsored by the Department of Science
  and Technology - Science Education Institute (DOST-SEI)."*
