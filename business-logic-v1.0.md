# Business Logic

> Development of a Web and Android mastery-based study and practice app using
> React (TypeScript), Capacitor, and Supabase (PostgreSQL) for DOST-SEI JLSS
> examinees in the Philippines

- Allowed Platforms: Web, Android

## Project Details

- Company/Startup/Team Name: `Verifai`
- Project Code Name: `Vera`
- Project Short Code: `VE`
- Short Description: A Khan Academy-inspired JLSS exam prep app that combines a
  phase-based study calendar and focus timer with mastery-based topic practice,
  hints and worked solutions, spaced review, and timed mock exams, using
  AI-generated and admin-reviewed questions.
- Long Description: JLSS Study Hub helps students prepare for the exam on a
  schedule and learn each topic until they master it. The student sets an exam
  date and the app generates a phase calendar (Orientation, Core Mastery,
  Practice & Integration, Final Review & Rest) with each day tagged Rest, Light,
  Medium or Heavy. Students open any subtopic from the topic map (Logical
  Reasoning, English, Science, Mathematics), read short instructional notes, and
  practice DOST-style multiple-choice questions at adaptive difficulty with
  hints, instant feedback and worked solutions. Mastery per subtopic moves
  through Attempted, Familiar, Proficient and Mastered based on performance,
  mistakes return through spaced review, and weak spots are detected
  automatically. Timed mock exams mirror the real exam structure and produce
  score reports by section and error type. A Pomodoro timer logs focus sessions,
  and light motivation features (mastery points, streaks, badges, daily goal)
  support the habit. Questions are generated in batches by an AI model trained
  on previous exams and primers, then validated automatically and reviewed by
  content reviewers before publishing; students never interact with the model
  directly. Practice works offline. The app is unofficial and not affiliated
  with DOST-SEI.

## User Levels

> Note: Modify/rename the list of users based on the actual users that you
> expect to use the system.

| User Level              | Description                                                                                                                                                                                                                                  |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A. System Administrator | Maintains/overrides system/server configurations, manages roles, feature flags and audit logs, and performs regular backups.                                                                                                                 |
| B. Administrator        | Manages the exam date, phases, plan templates, topic map, notes and mastery rules; runs AI question generation and assigns batches to reviewers; and generates periodic system analytics and reports. Can also perform any reviewer task.    |
| C. Content Reviewer     | Subject-matter reviewer who checks AI-generated questions, hints and worked solutions for accuracy and quality; edits, approves, rejects or unpublishes them; and resolves reported questions. Has no access to any student's personal data. |
| D. Student              | Logged-in examinee who plans, practices, takes mock exams and owns their progress data.                                                                                                                                                      |
| E. Guest                | Users who do not log in, but view limited contents on the app/web (topic map, phase plan overview and a sample practice set; progress is not saved).                                                                                         |

## System Requirements

1. The app shall allow the users to authenticate using Google Sign-In
   integration.
2. The app shall allow the users to set their exam date and daily availability
   during onboarding, and optionally take a short diagnostic quiz per subject to
   seed their mastery levels and weak spots.
3. The app shall generate a phase-based study calendar from the exam date, with
   each day tagged Rest, Light, Medium or Heavy and assigned subjects or topics,
   and allow the users to edit and reschedule any day.
4. The app shall automatically adjust the calendar when days are missed (1-day
   slip adds a 30-minute recap with no double-ups; 2-3 missed days compress the
   plan and re-prioritize), and show recovery guidance for scenarios such as
   burnout, overwhelm and the night before the exam.
5. The app shall allow the users to browse the topic map by subject and
   subtopic, open any subtopic in any order, and read short instructional notes.
6. The app shall allow the users to practice DOST-style multiple-choice
   questions (A-D) at adaptive difficulty, with optional step-by-step hints,
   instant feedback, and a worked solution explaining why the correct and wrong
   options are right or wrong.
7. The app shall provide a 10-item quiz per subtopic where 8 of 10 counts as
   passed; a lower score offers a new question set.
8. The app shall allow the users to run a Pomodoro timer (50/10, 25/5, 90/20,
   15/5) that keeps running in the background on Android, alerts at the end of
   each interval, and logs completed sessions automatically.
9. The app shall compute mastery per subtopic (Not started, Attempted, Familiar,
   Proficient, Mastered) from the user's practice and quiz performance, using
   administrator-configurable rules, and automatically flag weak spots.
10. The app shall resurface missed questions and previously mastered subtopics
    through spaced-repetition review.
11. The app shall allow the users to take timed mock exams that mirror the exam
    structure, and view score reports by section, subtopic and error type.
12. The app shall award mastery points, badges and a daily streak with streak
    freezes, with the daily goal based on the day's intensity; Rest days do not
    break the streak.
13. The app shall show a progress dashboard with exam countdown, streak and
    activity calendar, time studied, mastery per subject and mock exam score
    trend.
14. The app shall allow the users to set practice and streak-at-risk reminders
    delivered as local notifications.
15. The app shall allow the users to report an incorrect or unclear question.
16. The app shall allow the users to export their data as JSON, view their
    consent history, and delete their account and all associated data.
17. The app shall allow the administrators to generate batches of questions,
    hints and worked solutions with the AI model by subtopic, difficulty and
    count, with each item stored as a draft together with its provenance (model
    version, generation date, reviewer, review status), and to assign batches to
    content reviewers by subject area.
18. The app shall automatically check each generated question before review
    (exactly one correct answer, answer verification by a solver or independent
    check, option and format rules, and duplicate or near-duplicate detection
    against the existing bank and the source exams).
19. The app shall allow the content reviewers to work through a review queue of
    assigned drafts, and to edit, approve (which publishes), reject with a
    reason, or unpublish questions, hints, worked solutions and notes, with
    every change versioned and attributed to the reviewer.
20. The app shall allow the content reviewers to resolve reported questions
    (reporter identities are hidden), and shall automatically unpublish a
    question for review once it reaches a configurable number of reports.
21. The app shall allow the administrators to manage notes, the exam date,
    phases, plan templates and mastery rules, and to view aggregated analytics
    (question difficulty, quiz completion, subject usage) and generate periodic
    reports.
22. The app shall allow the system administrators to manage roles, system
    configuration, feature flags, audit logs, and backups and restores.
23. The app shall allow the users to download practice sets and use the
    calendar, timer, practice and review offline, and sync progress when a
    connection returns.

## Required Solution Layers

1. Security and privacy by design. Data Privacy Act compliance, location
   protection, retention limits, no per-user trails, aggregation thresholds, and
   consent for any data resale.
   - Data Privacy Act (RA 10173): Data Protection Officer, privacy notice,
     recorded consent, access/correction/portability/erasure, Privacy Impact
     Assessment, 72-hour breach notification, parental consent if users are
     minors.
   - Location protection: no GPS or location collected; IP addresses used only
     for rate limiting and not stored with user records.
   - Retention limits: inactive accounts deleted after 12 months with prior
     notice; answer and session history offered for archive or deletion after
     the exam (auto-deleted 90 days after the exam date unless the user keeps
     it); audit logs 90 days; backups 30 days.
   - No per-user trails: administrators and content reviewers cannot view any
     individual's answers, scores, sessions or weak spots, and reviewers see
     only question-level aggregates and anonymized reports; support access needs
     the user's time-limited grant; no advertising or tracking SDKs.
   - Aggregation thresholds: question and subject analytics only on cohorts of
     20 or more users; smaller groups suppressed; no individual-level exports.
   - Consent for any data resale or model training: data is not sold; student
     data is never sent to the AI model or used to train or tune it; any sharing
     of aggregated data, or any use of student data for model improvement, needs
     separate, opt-in, revocable consent and DPO approval.
2. AI question generation pipeline. An admin-only, batch process (not real-time
   per student) that calls the trained model, stores every output as a draft
   with provenance, runs automated checks, and publishes only after a content
   reviewer or administrator approves it. Training material (previous exams and
   primers) must be used only with confirmed rights, and generated items must be
   original rather than reproductions of source exam items.
3. Question bank and content layer. Tagged (subject, subtopic, difficulty),
   versioned questions, hints, worked solutions and instructional notes; CSV
   import; difficulty recalibrated from aggregated answer data; report-driven
   unpublishing, and a review queue with reviewer assignment by subject.
4. Planning engine. Phase calendar generated from the admin-managed exam date
   and plan templates, with missed-day rescheduling rules.
5. Practice and mastery engine. Adaptive difficulty, mastery-level rules,
   spaced-repetition scheduling, quiz and mock exam assembly by section.
6. Motivation engine. Mastery points, streaks, freezes, badges and daily goals,
   with day boundaries computed in Asia/Manila time.
7. Timer and notifications. Android foreground service and local notifications
   keep the Pomodoro timer and reminders reliable; no server push in MVP.
8. Offline-first sync. Downloadable practice sets, local storage on device, a
   sync queue, and a one-time importer for the original Study Hub JSON export.

## MVP Features and Access

> See the User Levels table for reference.

| Feature                                                                                | Access    |
| -------------------------------------------------------------------------------------- | --------- |
| 1. Topic map, phase plan overview and sample practice set (not saved)                  | A,B,C,D,E |
| 2. Google Sign-In, onboarding and diagnostic quiz                                      | A,B,C,D   |
| 3. Phase calendar with missed-day adjustment and recovery guidance                     | A,B,C,D   |
| 4. Pomodoro timer and automatic session log                                            | A,B,C,D   |
| 5. Topic practice: notes, adaptive questions, hints, worked solutions, quizzes         | A,B,C,D   |
| 6. Mastery levels, weak spots and spaced-repetition review                             | A,B,C,D   |
| 7. Mastery points, streaks, daily goal and badges                                      | A,B,C,D   |
| 8. Timed mock exams and score reports                                                  | A,B,C,D   |
| 9. Progress dashboard and reminders                                                    | A,B,C,D   |
| 10. Reporting a question, data export, privacy center, offline practice sets           | A,B,C,D   |
| 11. Review queue: review, edit, approve, reject, unpublish; reported-question handling | A,B,C     |
| 12. AI question generation, automated checks and batch assignment                      | A,B       |
| 13. Notes, exam date, phase, plan template and mastery rule management                 | A,B       |
| 14. Aggregated analytics and periodic reports                                          | A,B       |
| 15. Roles, system configuration, audit logs, backups                                   | A         |

## Notes

- The exam date, phases and plan templates must be administrator-managed
  settings, and the next exam date must be confirmed with DOST-SEI.
- AI-generated questions can be wrong (wrong answer key, ambiguous wording,
  inconsistent explanations), and wrong keys directly harm exam prep.
  Recommended: 100% administrator review of Mathematics and Science items before
  launch, solver or code-based answer checks for computational items, and
  spot-check sampling only after the error rate is measured and low.
- Review is the bottleneck. The topic list has roughly 115 subtopics; at 15-20
  questions each, that is about 1,700-2,300 questions plus hints and worked
  solutions. Content reviewers should be subject-matter experts (for example,
  someone strong in Math, one in Science, one in English and Reasoning),
  assigned by subject so each reviewer works only in their area.
- Out of scope for MVP: leaderboards and social features, a locked learning
  path, runtime AI generation or chat tutoring, video lessons, iOS,
  user-submitted content, server push notifications, payments.
