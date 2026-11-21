-- Vera database snapshot v1.0.0
-- Target: Supabase PostgreSQL
--
-- Idempotent initial snapshot. Safe to apply more than once to a database at
-- this version. Forward migrations are separate v1.0.1, v1.0.2, ... files;
-- exported full snapshots are v1.1.0, v1.2.0, ... (see db-design-choices.md).
--
-- `id` is a server-only bigint surrogate key. It is never returned to a client
-- or used as a relationship. Every application relationship uses a *_uuid
-- column. User-owned records reference auth.users(id) only through user_uuid;
-- other UUID relationships are intentionally not strict constraints where
-- offline sync may deliver rows out of order.

BEGIN;

CREATE TABLE IF NOT EXISTS public.account_profiles (
  id                         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                       uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid                  uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  email                      text,
  display_name               text,
  target_track               text CHECK (target_track IN ('ra_7687', 'merit', 'ra_10612')),
  program_field              text CHECK (program_field IN ('engineering_math', 'natural_sciences', 'health_sciences', 'secondary_stem_education', 'other_priority_st')),
  exam_date                  date,
  exam_date_is_estimated     boolean NOT NULL DEFAULT true,
  daily_study_window_minutes smallint CHECK (daily_study_window_minutes IN (30, 60, 90, 120)),
  self_reported_baseline     jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(self_reported_baseline) = 'object'),
  consent_history            jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(consent_history) = 'array'),
  created_at                 timestamptz NOT NULL DEFAULT now(),
  updated_at                 timestamptz NOT NULL DEFAULT now(),
  archived_at                timestamptz
);

CREATE TABLE IF NOT EXISTS public.account_roles (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid       uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  role            text NOT NULL CHECK (role IN ('system_administrator', 'administrator', 'content_reviewer', 'student')),
  created_by_uuid uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

CREATE TABLE IF NOT EXISTS public.curriculum_domains (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  slug            text NOT NULL UNIQUE,
  title           text NOT NULL,
  description     text NOT NULL DEFAULT '',
  display_order   smallint NOT NULL,
  exam_weight     numeric(5,2) CHECK (exam_weight BETWEEN 0 AND 100),
  status          text NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
  created_by_uuid uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

CREATE TABLE IF NOT EXISTS public.curriculum_subtopics (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  domain_uuid     uuid NOT NULL,
  slug            text NOT NULL UNIQUE,
  title           text NOT NULL,
  description     text NOT NULL DEFAULT '',
  display_order   smallint NOT NULL DEFAULT 0,
  is_core         boolean NOT NULL DEFAULT false,
  track_relevance jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(track_relevance) = 'array'),
  status          text NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
  created_by_uuid uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

CREATE TABLE IF NOT EXISTS public.curriculum_notes (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  domain_uuid     uuid NOT NULL,
  subtopic_uuid   uuid,
  title           text NOT NULL,
  body_markdown   text NOT NULL,
  version         integer NOT NULL DEFAULT 1 CHECK (version > 0),
  status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'in_review', 'published', 'unpublished', 'archived')),
  created_by_uuid uuid,
  reviewed_by_uuid uuid,
  published_at    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

-- Append-only review history for question/solution and note edits.
CREATE TABLE IF NOT EXISTS public.content_revisions (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  content_kind      text NOT NULL CHECK (content_kind IN ('question', 'note')),
  content_uuid      uuid NOT NULL,
  revision_number   integer NOT NULL CHECK (revision_number > 0),
  content_snapshot  jsonb NOT NULL CHECK (jsonb_typeof(content_snapshot) = 'object'),
  change_summary    text NOT NULL DEFAULT '',
  changed_by_uuid   uuid,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz,
  UNIQUE (content_kind, content_uuid, revision_number)
);

CREATE TABLE IF NOT EXISTS public.study_plans (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exam_date         date NOT NULL,
  exam_date_is_estimated boolean NOT NULL DEFAULT true,
  target_track      text CHECK (target_track IN ('ra_7687', 'merit', 'ra_10612')),
  daily_window_minutes smallint CHECK (daily_window_minutes IN (30, 60, 90, 120)),
  status            text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'archived')),
  generation_inputs jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(generation_inputs) = 'object'),
  created_by_uuid   uuid,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.study_plan_days (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  study_plan_uuid uuid NOT NULL,
  local_date      date NOT NULL,
  phase           text NOT NULL CHECK (phase IN ('orientation', 'core_mastery', 'integration', 'final_review')),
  intensity       text NOT NULL CHECK (intensity IN ('rest', 'light', 'medium', 'heavy')),
  target_minutes  smallint NOT NULL DEFAULT 0 CHECK (target_minutes >= 0),
  recovery_minutes smallint NOT NULL DEFAULT 0 CHECK (recovery_minutes >= 0),
  completion_state text NOT NULL DEFAULT 'scheduled' CHECK (completion_state IN ('scheduled', 'in_progress', 'completed', 'missed', 'recompressed')),
  client_event_uuid uuid,
  created_by_uuid uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz,
  UNIQUE (study_plan_uuid, local_date)
);

CREATE TABLE IF NOT EXISTS public.study_plan_day_items (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid        uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  study_plan_day_uuid uuid NOT NULL,
  subtopic_uuid    uuid,
  item_kind        text NOT NULL CHECK (item_kind IN ('practice', 'spaced_review', 'quiz', 'mock', 'recap', 'rest')),
  display_order    smallint NOT NULL DEFAULT 0,
  target_count     smallint CHECK (target_count IS NULL OR target_count >= 0),
  completion_state text NOT NULL DEFAULT 'pending' CHECK (completion_state IN ('pending', 'in_progress', 'completed', 'skipped')),
  created_by_uuid  uuid,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  archived_at      timestamptz
);

CREATE TABLE IF NOT EXISTS public.question_generation_batches (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  requested_by_uuid  uuid,
  domain_uuid        uuid NOT NULL,
  subtopic_uuid      uuid NOT NULL,
  difficulty         text NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  requested_count    smallint NOT NULL CHECK (requested_count > 0),
  model_identifier   text NOT NULL,
  prompt_version     text NOT NULL,
  status             text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'running', 'completed', 'failed', 'cancelled')),
  request_metadata   jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(request_metadata) = 'object'),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.questions (
  id                   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                 uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  domain_uuid          uuid NOT NULL,
  subtopic_uuid        uuid NOT NULL,
  generation_batch_uuid uuid,
  difficulty           text NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  prompt               text NOT NULL,
  options              jsonb NOT NULL CHECK (jsonb_typeof(options) = 'array' AND jsonb_array_length(options) = 4),
  track_relevance      jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(track_relevance) = 'array'),
  status               text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'in_review', 'published', 'quarantined', 'rejected', 'deprecated', 'unpublished')),
  provenance           jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(provenance) = 'object'),
  duplicate_hash       text,
  similarity_score     numeric(5,4) CHECK (similarity_score IS NULL OR similarity_score BETWEEN 0 AND 1),
  created_by_uuid      uuid,
  reviewed_by_uuid     uuid,
  published_at         timestamptz,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  archived_at          timestamptz
);

-- Kept separate so a public question read can never reveal its key or rationale.
CREATE TABLE IF NOT EXISTS public.question_solutions (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  question_uuid     uuid NOT NULL UNIQUE,
  answer_key        text NOT NULL CHECK (answer_key IN ('A', 'B', 'C', 'D')),
  correct_rationale text NOT NULL,
  distractor_rationales jsonb NOT NULL CHECK (jsonb_typeof(distractor_rationales) = 'object'),
  hints             jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(hints) = 'array' AND jsonb_array_length(hints) <= 2),
  created_by_uuid   uuid,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.question_validation_runs (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  question_uuid    uuid NOT NULL,
  validation_version text NOT NULL,
  gate_results     jsonb NOT NULL CHECK (
    jsonb_typeof(gate_results) = 'object'
    AND gate_results ?& ARRAY['schema', 'four_options', 'one_key', 'rationales', 'length_limits', 'formula_syntax', 'duplicate_similarity', 'mental_math']
  ),
  passed           boolean NOT NULL,
  executed_at      timestamptz NOT NULL DEFAULT now(),
  created_by_uuid  uuid,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  archived_at      timestamptz,
  CHECK (
    NOT passed OR (
      gate_results ->> 'schema' = 'true'
      AND gate_results ->> 'four_options' = 'true'
      AND gate_results ->> 'one_key' = 'true'
      AND gate_results ->> 'rationales' = 'true'
      AND gate_results ->> 'length_limits' = 'true'
      AND gate_results ->> 'formula_syntax' = 'true'
      AND gate_results ->> 'duplicate_similarity' = 'true'
      AND gate_results ->> 'mental_math' = 'true'
    )
  )
);

CREATE TABLE IF NOT EXISTS public.review_assignments (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  question_uuid      uuid NOT NULL,
  reviewer_uuid      uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  assigned_by_uuid   uuid,
  status             text NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'in_progress', 'approved', 'rejected', 'returned')),
  reviewer_notes     text,
  assigned_at        timestamptz NOT NULL DEFAULT now(),
  resolved_at        timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.question_reports (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  question_uuid   uuid NOT NULL,
  reporter_uuid   uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  report_tag      text NOT NULL CHECK (report_tag IN ('wrong_answer', 'typo_broken_math', 'ambiguous_question')),
  details         text,
  resolution      text,
  resolved_by_uuid uuid,
  resolved_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz,
  UNIQUE (question_uuid, reporter_uuid)
);

CREATE TABLE IF NOT EXISTS public.assessment_sessions (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid          uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  assessment_kind    text NOT NULL CHECK (assessment_kind IN ('rapid_diagnostic', 'subtopic_quiz', 'full_mock', 'mini_mock')),
  domain_uuid        uuid,
  subtopic_uuid      uuid,
  status             text NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned', 'expired')),
  started_at         timestamptz NOT NULL,
  completed_at       timestamptz,
  time_limit_seconds integer CHECK (time_limit_seconds IS NULL OR time_limit_seconds > 0),
  planned_item_count smallint CHECK (planned_item_count IS NULL OR planned_item_count > 0),
  client_event_uuid  uuid NOT NULL UNIQUE,
  result_summary     jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(result_summary) = 'object'),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.assessment_items (
  id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                  uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid             uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  assessment_session_uuid uuid NOT NULL,
  question_uuid         uuid NOT NULL,
  display_order         smallint NOT NULL,
  domain_uuid           uuid NOT NULL,
  subtopic_uuid         uuid NOT NULL,
  points_possible       numeric(6,2) NOT NULL DEFAULT 1 CHECK (points_possible >= 0),
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  archived_at           timestamptz,
  UNIQUE (assessment_session_uuid, display_order),
  UNIQUE (assessment_session_uuid, question_uuid)
);

-- Append-only synced learner events. client_event_uuid makes retries idempotent.
CREATE TABLE IF NOT EXISTS public.attempts (
  id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                  uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  client_event_uuid     uuid NOT NULL UNIQUE,
  user_uuid             uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_uuid         uuid NOT NULL,
  domain_uuid           uuid NOT NULL,
  subtopic_uuid         uuid NOT NULL,
  assessment_session_uuid uuid,
  assessment_item_uuid  uuid,
  study_plan_uuid       uuid,
  selected_answer       text CHECK (selected_answer IS NULL OR selected_answer IN ('A', 'B', 'C', 'D')),
  is_correct            boolean NOT NULL,
  hint_level_used       smallint NOT NULL DEFAULT 0 CHECK (hint_level_used BETWEEN 0 AND 2),
  elapsed_milliseconds integer CHECK (elapsed_milliseconds IS NULL OR elapsed_milliseconds >= 0),
  error_category        text CHECK (error_category IS NULL OR error_category IN ('conceptual_gap', 'calculation_careless', 'time_out_unanswered')),
  activity_source       text NOT NULL CHECK (activity_source IN ('practice', 'quiz', 'diagnostic', 'mock', 'spaced_review')),
  points_awarded        numeric(7,2) NOT NULL DEFAULT 0 CHECK (points_awarded >= 0),
  event_at              timestamptz NOT NULL,
  received_at           timestamptz NOT NULL DEFAULT now(),
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  archived_at           timestamptz
);

CREATE TABLE IF NOT EXISTS public.student_mastery (
  id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                  uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid             uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subtopic_uuid         uuid NOT NULL,
  mastery_tier          text NOT NULL DEFAULT 'not_started' CHECK (mastery_tier IN ('not_started', 'attempted', 'familiar', 'proficient', 'mastered')),
  attempt_count         integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  rolling_attempt_count smallint NOT NULL DEFAULT 0 CHECK (rolling_attempt_count BETWEEN 0 AND 10),
  rolling_correct_count smallint NOT NULL DEFAULT 0 CHECK (rolling_correct_count BETWEEN 0 AND 10),
  rolling_accuracy      numeric(5,2) CHECK (rolling_accuracy IS NULL OR rolling_accuracy BETWEEN 0 AND 100),
  latest_quiz_score     smallint CHECK (latest_quiz_score IS NULL OR latest_quiz_score BETWEEN 0 AND 10),
  spaced_checks_passed  smallint NOT NULL DEFAULT 0 CHECK (spaced_checks_passed BETWEEN 0 AND 2),
  last_attempt_at       timestamptz,
  last_mastered_at      timestamptz,
  next_review_at        timestamptz,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  archived_at           timestamptz,
  UNIQUE (user_uuid, subtopic_uuid)
);

CREATE TABLE IF NOT EXISTS public.spaced_review_items (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid        uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_uuid    uuid,
  subtopic_uuid    uuid NOT NULL,
  source_attempt_uuid uuid,
  interval_step    smallint NOT NULL DEFAULT 1 CHECK (interval_step BETWEEN 1 AND 4),
  due_at           timestamptz NOT NULL,
  last_result      text CHECK (last_result IS NULL OR last_result IN ('correct', 'incorrect', 'unanswered')),
  status           text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'suspended')),
  completed_at     timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  archived_at      timestamptz
);

CREATE TABLE IF NOT EXISTS public.focus_sessions (
  id                     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                   uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  client_event_uuid      uuid NOT NULL UNIQUE,
  user_uuid              uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  study_plan_uuid        uuid,
  local_date             date NOT NULL,
  preset                 text NOT NULL CHECK (preset IN ('25_5', '50_10', '90_20', '15_5', 'custom')),
  focus_minutes_planned  smallint NOT NULL CHECK (focus_minutes_planned > 0),
  break_minutes_planned  smallint NOT NULL CHECK (break_minutes_planned >= 0),
  focus_minutes_actual   smallint NOT NULL DEFAULT 0 CHECK (focus_minutes_actual >= 0),
  started_at             timestamptz NOT NULL,
  completed_at           timestamptz,
  completed              boolean NOT NULL DEFAULT false,
  points_awarded          numeric(7,2) NOT NULL DEFAULT 0 CHECK (points_awarded >= 0),
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  archived_at            timestamptz
);

CREATE TABLE IF NOT EXISTS public.student_daily_activity (
  id                     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                   uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid              uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  local_date             date NOT NULL,
  timezone               text NOT NULL DEFAULT 'Asia/Manila' CHECK (timezone = 'Asia/Manila'),
  intensity_goal         text CHECK (intensity_goal IN ('rest', 'light', 'medium', 'heavy')),
  goal_met               boolean NOT NULL DEFAULT false,
  questions_completed    integer NOT NULL DEFAULT 0 CHECK (questions_completed >= 0),
  focus_minutes          integer NOT NULL DEFAULT 0 CHECK (focus_minutes >= 0),
  rest_day                boolean NOT NULL DEFAULT false,
  streak_freeze_used      boolean NOT NULL DEFAULT false,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),
  archived_at             timestamptz,
  UNIQUE (user_uuid, local_date)
);

CREATE TABLE IF NOT EXISTS public.student_streaks (
  id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid           uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  current_days        integer NOT NULL DEFAULT 0 CHECK (current_days >= 0),
  longest_days        integer NOT NULL DEFAULT 0 CHECK (longest_days >= 0),
  last_qualifying_date date,
  freezes_available   smallint NOT NULL DEFAULT 0 CHECK (freezes_available BETWEEN 0 AND 2),
  study_days_toward_freeze smallint NOT NULL DEFAULT 0 CHECK (study_days_toward_freeze BETWEEN 0 AND 6),
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  archived_at         timestamptz
);

CREATE TABLE IF NOT EXISTS public.reminder_preferences (
  id                   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                 uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid            uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  practice_enabled     boolean NOT NULL DEFAULT false,
  practice_local_time  time,
  streak_risk_enabled  boolean NOT NULL DEFAULT false,
  quiet_hours_start    time,
  quiet_hours_end      time,
  timezone             text NOT NULL DEFAULT 'Asia/Manila' CHECK (timezone = 'Asia/Manila'),
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  archived_at          timestamptz
);

CREATE TABLE IF NOT EXISTS public.badge_definitions (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  slug            text NOT NULL UNIQUE,
  title           text NOT NULL,
  description     text NOT NULL,
  criteria        jsonb NOT NULL CHECK (jsonb_typeof(criteria) = 'object'),
  status          text NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

CREATE TABLE IF NOT EXISTS public.student_badges (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid          uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_uuid         uuid NOT NULL,
  earned_at          timestamptz NOT NULL DEFAULT now(),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  UNIQUE (user_uuid, badge_uuid)
);

CREATE TABLE IF NOT EXISTS public.offline_content_packs (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  slug             text NOT NULL UNIQUE,
  title            text NOT NULL,
  domain_uuid      uuid NOT NULL,
  version          integer NOT NULL DEFAULT 1 CHECK (version > 0),
  manifest         jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(manifest) = 'object'),
  estimated_bytes  integer CHECK (estimated_bytes IS NULL OR estimated_bytes >= 0),
  status           text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  published_at     timestamptz,
  created_by_uuid  uuid,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  archived_at      timestamptz
);

CREATE TABLE IF NOT EXISTS public.privacy_requests (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid        uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  request_kind     text NOT NULL CHECK (request_kind IN ('export', 'deletion')),
  status           text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'processing', 'completed', 'rejected')),
  requested_at     timestamptz NOT NULL DEFAULT now(),
  completed_at     timestamptz,
  expires_at       timestamptz,
  processing_notes text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  archived_at      timestamptz
);

CREATE TABLE IF NOT EXISTS public.cohort_analytics_snapshots (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  metric_key        text NOT NULL,
  period_start      date NOT NULL,
  period_end        date NOT NULL,
  domain_uuid       uuid,
  subtopic_uuid     uuid,
  cohort_size       integer NOT NULL CHECK (cohort_size >= 20),
  aggregate_value   jsonb NOT NULL CHECK (jsonb_typeof(aggregate_value) = 'object'),
  calculated_at     timestamptz NOT NULL DEFAULT now(),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz,
  CHECK (period_end >= period_start),
  UNIQUE (metric_key, period_start, period_end, domain_uuid, subtopic_uuid)
);

CREATE TABLE IF NOT EXISTS public.app_settings (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  setting_key     text NOT NULL UNIQUE,
  setting_value   jsonb NOT NULL,
  is_public       boolean NOT NULL DEFAULT false,
  description     text NOT NULL DEFAULT '',
  created_by_uuid uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  actor_uuid      uuid,
  action          text NOT NULL,
  target_type     text NOT NULL,
  target_uuid     uuid,
  event_metadata  jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(event_metadata) = 'object'),
  occurred_at     timestamptz NOT NULL DEFAULT now(),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz
);

-- UUID relationship indexes: no application relationship uses a surrogate id.
CREATE INDEX IF NOT EXISTS curriculum_subtopics_domain_uuid_idx ON public.curriculum_subtopics (domain_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS curriculum_notes_domain_uuid_idx ON public.curriculum_notes (domain_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS curriculum_notes_subtopic_uuid_idx ON public.curriculum_notes (subtopic_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS content_revisions_content_uuid_idx ON public.content_revisions (content_kind, content_uuid, revision_number DESC);
CREATE INDEX IF NOT EXISTS study_plans_user_uuid_idx ON public.study_plans (user_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS study_plan_days_user_date_idx ON public.study_plan_days (user_uuid, local_date) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS study_plan_days_plan_uuid_idx ON public.study_plan_days (study_plan_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS study_plan_day_items_user_uuid_idx ON public.study_plan_day_items (user_uuid, study_plan_day_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS question_batches_requester_idx ON public.question_generation_batches (requested_by_uuid, created_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS question_batches_curriculum_idx ON public.question_generation_batches (domain_uuid, subtopic_uuid, created_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS questions_domain_subtopic_idx ON public.questions (domain_uuid, subtopic_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS questions_published_subtopic_idx ON public.questions (subtopic_uuid, difficulty) WHERE status = 'published' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS questions_generation_batch_uuid_idx ON public.questions (generation_batch_uuid) WHERE generation_batch_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS questions_duplicate_hash_idx ON public.questions (duplicate_hash) WHERE duplicate_hash IS NOT NULL;
CREATE INDEX IF NOT EXISTS question_solutions_question_uuid_idx ON public.question_solutions (question_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS validation_runs_question_uuid_idx ON public.question_validation_runs (question_uuid, executed_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS review_assignments_reviewer_status_idx ON public.review_assignments (reviewer_uuid, status, assigned_at) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS review_assignments_question_uuid_idx ON public.review_assignments (question_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS question_reports_question_uuid_idx ON public.question_reports (question_uuid, created_at) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS assessments_user_started_idx ON public.assessment_sessions (user_uuid, started_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS assessments_domain_subtopic_idx ON public.assessment_sessions (domain_uuid, subtopic_uuid, started_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS assessment_items_user_session_idx ON public.assessment_items (user_uuid, assessment_session_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS assessment_items_question_uuid_idx ON public.assessment_items (question_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS assessment_items_curriculum_idx ON public.assessment_items (domain_uuid, subtopic_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_user_event_idx ON public.attempts (user_uuid, event_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_subtopic_event_idx ON public.attempts (user_uuid, subtopic_uuid, event_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_question_uuid_idx ON public.attempts (question_uuid, event_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_domain_uuid_idx ON public.attempts (domain_uuid, event_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_assessment_uuid_idx ON public.attempts (assessment_session_uuid, event_at) WHERE assessment_session_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS attempts_assessment_item_uuid_idx ON public.attempts (assessment_item_uuid) WHERE assessment_item_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS attempts_study_plan_uuid_idx ON public.attempts (study_plan_uuid) WHERE study_plan_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS mastery_user_tier_idx ON public.student_mastery (user_uuid, mastery_tier) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS spaced_review_due_idx ON public.spaced_review_items (user_uuid, due_at) WHERE status = 'pending' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS spaced_review_question_uuid_idx ON public.spaced_review_items (question_uuid) WHERE question_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS spaced_review_subtopic_uuid_idx ON public.spaced_review_items (user_uuid, subtopic_uuid, due_at) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS spaced_review_source_attempt_uuid_idx ON public.spaced_review_items (source_attempt_uuid) WHERE source_attempt_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS focus_sessions_user_date_idx ON public.focus_sessions (user_uuid, local_date) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS focus_sessions_study_plan_uuid_idx ON public.focus_sessions (study_plan_uuid) WHERE study_plan_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS daily_activity_user_date_idx ON public.student_daily_activity (user_uuid, local_date DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS student_badges_user_earned_idx ON public.student_badges (user_uuid, earned_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS student_badges_badge_uuid_idx ON public.student_badges (badge_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS offline_packs_domain_uuid_idx ON public.offline_content_packs (domain_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS privacy_requests_user_status_idx ON public.privacy_requests (user_uuid, status, requested_at) WHERE user_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS question_reports_reporter_uuid_idx ON public.question_reports (reporter_uuid, created_at DESC) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS assessment_items_session_uuid_idx ON public.assessment_items (assessment_session_uuid, display_order) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS cohort_analytics_period_idx ON public.cohort_analytics_snapshots (metric_key, period_start, period_end) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS cohort_analytics_domain_uuid_idx ON public.cohort_analytics_snapshots (domain_uuid, period_start) WHERE domain_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS cohort_analytics_subtopic_uuid_idx ON public.cohort_analytics_snapshots (subtopic_uuid, period_start) WHERE subtopic_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS audit_logs_actor_uuid_idx ON public.audit_logs (actor_uuid, occurred_at DESC) WHERE actor_uuid IS NOT NULL;
CREATE INDEX IF NOT EXISTS audit_logs_target_idx ON public.audit_logs (target_type, target_uuid, occurred_at DESC);

CREATE OR REPLACE FUNCTION public.has_any_role(allowed_roles text[])
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.account_roles r
    WHERE r.user_uuid = auth.uid()
      AND r.role = ANY (allowed_roles)
      AND r.archived_at IS NULL
  );
$$;

CREATE OR REPLACE FUNCTION public.create_account_for_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.account_profiles (user_uuid, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name')
  )
  ON CONFLICT (user_uuid) DO NOTHING;

  INSERT INTO public.account_roles (user_uuid, role)
  VALUES (NEW.id, 'student')
  ON CONFLICT (user_uuid) DO NOTHING;

  RETURN NEW;
END;
$$;

-- Account deletion cascades all learner-owned rows and anonymizes attribution
-- on retained curriculum, content, configuration, and audit records.
CREATE OR REPLACE FUNCTION public.anonymize_deleted_account()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  UPDATE public.account_roles SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.curriculum_domains SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.curriculum_subtopics SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.curriculum_notes SET created_by_uuid = NULL, reviewed_by_uuid = NULL, updated_at = now()
   WHERE created_by_uuid = OLD.id OR reviewed_by_uuid = OLD.id;
  UPDATE public.content_revisions SET changed_by_uuid = NULL, updated_at = now() WHERE changed_by_uuid = OLD.id;
  UPDATE public.study_plans SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.study_plan_days SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.study_plan_day_items SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.question_generation_batches SET requested_by_uuid = NULL, updated_at = now() WHERE requested_by_uuid = OLD.id;
  UPDATE public.questions SET created_by_uuid = NULL, reviewed_by_uuid = NULL, updated_at = now()
   WHERE created_by_uuid = OLD.id OR reviewed_by_uuid = OLD.id;
  UPDATE public.question_solutions SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.question_validation_runs SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.review_assignments SET assigned_by_uuid = NULL, updated_at = now() WHERE assigned_by_uuid = OLD.id;
  UPDATE public.question_reports SET resolved_by_uuid = NULL, updated_at = now() WHERE resolved_by_uuid = OLD.id;
  UPDATE public.offline_content_packs SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.app_settings SET created_by_uuid = NULL, updated_at = now() WHERE created_by_uuid = OLD.id;
  UPDATE public.audit_logs SET actor_uuid = NULL, updated_at = now() WHERE actor_uuid = OLD.id;
  RETURN OLD;
END;
$$;

CREATE OR REPLACE FUNCTION public.quarantine_reported_question()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE distinct_reporters integer;
BEGIN
  SELECT count(DISTINCT reporter_uuid)::integer
    INTO distinct_reporters
    FROM public.question_reports
   WHERE question_uuid = NEW.question_uuid
     AND archived_at IS NULL;

  IF distinct_reporters >= 3 THEN
    UPDATE public.questions
       SET status = 'quarantined', updated_at = now()
     WHERE uuid = NEW.question_uuid
       AND status = 'published'
       AND archived_at IS NULL;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.require_question_validation_before_publish()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.status = 'published' AND (TG_OP = 'INSERT' OR OLD.status IS DISTINCT FROM 'published') THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.question_solutions s
      WHERE s.question_uuid = NEW.uuid AND s.archived_at IS NULL
    ) THEN
      RAISE EXCEPTION 'A question must have a solution before publication';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM public.question_validation_runs v
      WHERE v.question_uuid = NEW.uuid AND v.passed = true AND v.archived_at IS NULL
      ORDER BY v.executed_at DESC
      LIMIT 1
    ) THEN
      RAISE EXCEPTION 'A question must pass all validation gates before publication';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE VIEW public.question_report_summary
WITH (security_barrier = true)
AS
SELECT r.question_uuid,
       r.report_tag,
       count(DISTINCT r.reporter_uuid)::integer AS report_count,
       max(r.created_at) AS latest_reported_at
FROM public.question_reports r
WHERE r.archived_at IS NULL
GROUP BY r.question_uuid, r.report_tag;

DROP TRIGGER IF EXISTS vera_create_account_after_auth_signup ON auth.users;
CREATE TRIGGER vera_create_account_after_auth_signup
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.create_account_for_auth_user();

DROP TRIGGER IF EXISTS vera_anonymize_before_auth_delete ON auth.users;
CREATE TRIGGER vera_anonymize_before_auth_delete
BEFORE DELETE ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.anonymize_deleted_account();

DROP TRIGGER IF EXISTS vera_quarantine_after_question_report ON public.question_reports;
CREATE TRIGGER vera_quarantine_after_question_report
AFTER INSERT ON public.question_reports
FOR EACH ROW EXECUTE FUNCTION public.quarantine_reported_question();

DROP TRIGGER IF EXISTS vera_require_validation_before_publish ON public.questions;
CREATE TRIGGER vera_require_validation_before_publish
BEFORE INSERT OR UPDATE ON public.questions
FOR EACH ROW EXECUTE FUNCTION public.require_question_validation_before_publish();

-- RLS is enabled on every application table. The product architecture routes
-- data access through vera-api. Because service_role bypasses RLS, the API must
-- authorize every request itself, return only UUID relationships (never id),
-- and restrict student details/analytics to the rules in business-logic.md.
ALTER TABLE public.account_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curriculum_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curriculum_subtopics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curriculum_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_plan_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_plan_day_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_generation_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_solutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_validation_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_mastery ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spaced_review_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_daily_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminder_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_content_packs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.privacy_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cohort_analytics_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Policies are dropped/recreated so rerunning the snapshot remains idempotent.
DO $$
DECLARE p record;
BEGIN
  FOR p IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND policyname LIKE 'vera_%'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', p.policyname, p.schemaname, p.tablename);
  END LOOP;
END;
$$;

CREATE POLICY vera_profile_self ON public.account_profiles FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_roles_self_read ON public.account_roles FOR SELECT TO authenticated
  USING (user_uuid = auth.uid() OR public.has_any_role(ARRAY['system_administrator']));
CREATE POLICY vera_roles_system_admin_manage ON public.account_roles FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator']));

CREATE POLICY vera_domains_read_published ON public.curriculum_domains FOR SELECT TO anon, authenticated
  USING ((status = 'published' AND archived_at IS NULL) OR public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_domains_staff_manage ON public.curriculum_domains FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_subtopics_read_published ON public.curriculum_subtopics FOR SELECT TO anon, authenticated
  USING ((status = 'published' AND archived_at IS NULL) OR public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_subtopics_staff_manage ON public.curriculum_subtopics FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_notes_read_published ON public.curriculum_notes FOR SELECT TO anon, authenticated
  USING ((status = 'published' AND archived_at IS NULL) OR public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_notes_staff_manage ON public.curriculum_notes FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_content_revisions_staff_read ON public.content_revisions FOR SELECT TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_content_revisions_staff_insert ON public.content_revisions FOR INSERT TO authenticated
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));

CREATE POLICY vera_plans_owner ON public.study_plans FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_plan_days_owner ON public.study_plan_days FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_plan_day_items_owner ON public.study_plan_day_items FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());

CREATE POLICY vera_batches_admin_manage ON public.question_generation_batches FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_questions_read_published ON public.questions FOR SELECT TO anon, authenticated
  USING ((status = 'published' AND archived_at IS NULL) OR public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_questions_staff_manage ON public.questions FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_solutions_staff_only ON public.question_solutions FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_validations_staff_only ON public.question_validation_runs FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator', 'content_reviewer']));
CREATE POLICY vera_review_assignment_read ON public.review_assignments FOR SELECT TO authenticated
  USING (reviewer_uuid = auth.uid() OR public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_review_assignment_update ON public.review_assignments FOR UPDATE TO authenticated
  USING (reviewer_uuid = auth.uid() OR public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (reviewer_uuid = auth.uid() OR public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_review_assignment_admin_manage ON public.review_assignments FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_reports_owner_read ON public.question_reports FOR SELECT TO authenticated
  USING (reporter_uuid = auth.uid());
CREATE POLICY vera_reports_owner_insert ON public.question_reports FOR INSERT TO authenticated
  WITH CHECK (reporter_uuid = auth.uid());

CREATE POLICY vera_assessment_sessions_owner ON public.assessment_sessions FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_assessment_items_owner ON public.assessment_items FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_attempts_owner_read_insert ON public.attempts FOR SELECT TO authenticated
  USING (user_uuid = auth.uid());
CREATE POLICY vera_attempts_owner_insert ON public.attempts FOR INSERT TO authenticated
  WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_mastery_owner ON public.student_mastery FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_spaced_review_owner ON public.spaced_review_items FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_focus_owner ON public.focus_sessions FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_daily_activity_owner ON public.student_daily_activity FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_streak_owner ON public.student_streaks FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_reminder_preferences_owner ON public.reminder_preferences FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_badges_read_published ON public.badge_definitions FOR SELECT TO anon, authenticated
  USING (status = 'published' AND archived_at IS NULL);
CREATE POLICY vera_badges_admin_manage ON public.badge_definitions FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_student_badges_owner ON public.student_badges FOR SELECT TO authenticated
  USING (user_uuid = auth.uid());
CREATE POLICY vera_offline_packs_read_published ON public.offline_content_packs FOR SELECT TO anon, authenticated
  USING ((status = 'published' AND archived_at IS NULL) OR public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_offline_packs_admin_manage ON public.offline_content_packs FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_privacy_requests_owner ON public.privacy_requests FOR ALL TO authenticated
  USING (user_uuid = auth.uid()) WITH CHECK (user_uuid = auth.uid());
CREATE POLICY vera_analytics_admin_only ON public.cohort_analytics_snapshots FOR SELECT TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_settings_read_public ON public.app_settings FOR SELECT TO anon, authenticated
  USING (is_public AND archived_at IS NULL);
CREATE POLICY vera_settings_admin_manage ON public.app_settings FOR ALL TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator', 'administrator']))
  WITH CHECK (public.has_any_role(ARRAY['system_administrator', 'administrator']));
CREATE POLICY vera_audit_system_admin_read ON public.audit_logs FOR SELECT TO authenticated
  USING (public.has_any_role(ARRAY['system_administrator']));

-- Keep the direct database API closed to client roles. vera-api uses its
-- server-side service role after authenticating/authorizing each request.
-- Never expose service_role credentials to Web or Android clients.
REVOKE ALL ON FUNCTION public.has_any_role(text[]) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.create_account_for_auth_user() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.anonymize_deleted_account() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.quarantine_reported_question() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.require_question_validation_before_publish() FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
DO $$
DECLARE
  object_name text;
  identity_sequence text;
BEGIN
  FOREACH object_name IN ARRAY ARRAY[
    'account_profiles', 'account_roles', 'curriculum_domains', 'curriculum_subtopics',
    'curriculum_notes', 'content_revisions', 'study_plans', 'study_plan_days',
    'study_plan_day_items', 'question_generation_batches', 'questions',
    'question_solutions', 'question_validation_runs', 'review_assignments',
    'question_reports', 'assessment_sessions', 'assessment_items', 'attempts',
    'student_mastery', 'spaced_review_items', 'focus_sessions',
    'student_daily_activity', 'student_streaks', 'reminder_preferences',
    'badge_definitions', 'student_badges', 'offline_content_packs',
    'privacy_requests', 'cohort_analytics_snapshots', 'app_settings',
    'audit_logs', 'question_report_summary'
  ]
  LOOP
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM anon, authenticated', object_name);
    EXECUTE format('GRANT ALL ON TABLE public.%I TO service_role', object_name);
    identity_sequence := pg_get_serial_sequence(format('public.%I', object_name), 'id');
    IF identity_sequence IS NOT NULL THEN
      EXECUTE format('REVOKE ALL ON SEQUENCE %s FROM anon, authenticated', identity_sequence);
      EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO service_role', identity_sequence);
    END IF;
  END LOOP;
END;
$$;
GRANT SELECT ON public.question_report_summary TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_any_role(text[]) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.create_account_for_auth_user() TO service_role;

-- The four official domains are inserted idempotently; content remains editable.
INSERT INTO public.curriculum_domains (slug, title, description, display_order, exam_weight, status)
VALUES
  ('logical-reasoning', 'Logical Reasoning', 'Abstract, spatial, mechanical, and data sufficiency reasoning.', 1, 25, 'published'),
  ('english', 'English', 'Vocabulary, grammar, reading comprehension, and verbal reasoning.', 2, 20, 'published'),
  ('science', 'Science', 'Biology, chemistry, physics, and earth science.', 3, 30, 'published'),
  ('mathematics', 'Mathematics', 'Algebra, geometry, trigonometry, statistics, and calculus.', 4, 25, 'published')
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  exam_weight = EXCLUDED.exam_weight,
  updated_at = now();

INSERT INTO public.curriculum_subtopics (domain_uuid, slug, title, display_order, is_core, status)
SELECT d.uuid, seed.slug, seed.title, seed.display_order, true, 'published'
FROM (VALUES
  ('logical-reasoning', 'figure-series', 'Figure Series', 1),
  ('logical-reasoning', 'figure-matrix', 'Figure Matrix', 2),
  ('logical-reasoning', 'pattern-completion', 'Pattern Completion', 3),
  ('logical-reasoning', 'paper-folding-spatial', 'Paper Folding and Spatial Reasoning', 4),
  ('logical-reasoning', 'mechanical-reasoning', 'Mechanical Reasoning: Pulleys and Gears', 5),
  ('logical-reasoning', 'verbal-classification', 'Verbal Classification', 6),
  ('logical-reasoning', 'number-series', 'Number Series', 7),
  ('logical-reasoning', 'syllogisms', 'Syllogisms', 8),
  ('logical-reasoning', 'logical-deduction', 'Logical Deduction', 9),
  ('logical-reasoning', 'data-sufficiency', 'Data Sufficiency', 10),
  ('logical-reasoning', 'coding-decoding', 'Coding and Decoding', 11),
  ('logical-reasoning', 'direction-sense', 'Direction Sense', 12),
  ('english', 'vocabulary-in-context', 'Vocabulary in Context', 1),
  ('english', 'analogies-associations', 'Analogies and Associations', 2),
  ('english', 'error-identification', 'Error Identification', 3),
  ('english', 'sentence-completion', 'Sentence Completion', 4),
  ('english', 'subject-verb-agreement', 'Subject-Verb Agreement', 5),
  ('english', 'idiomatic-phrases', 'Idiomatic Phrases', 6),
  ('english', 'pronoun-antecedent-agreement', 'Pronoun-Antecedent Agreement', 7),
  ('english', 'parallel-structure', 'Parallel Structure', 8),
  ('english', 'paragraph-organization', 'Paragraph Organization', 9),
  ('english', 'main-idea-inference', 'Main Idea and Inference', 10),
  ('english', 'tone-author-purpose', 'Tone and Author Purpose', 11),
  ('english', 'critical-reading', 'Critical Reading', 12),
  ('science', 'cell-biology-division', 'Cell Biology and Mitosis/Meiosis', 1),
  ('science', 'genetics-mendelian-inheritance', 'Genetics and Mendelian Inheritance', 2),
  ('science', 'ecology-ecosystems', 'Ecology and Ecosystems', 3),
  ('science', 'human-systems-homeostasis', 'Human Organ Systems and Homeostasis', 4),
  ('science', 'periodic-trends-bonding', 'Periodic Trends and Bonding', 5),
  ('science', 'reactions-stoichiometry', 'Chemical Reactions and Stoichiometry', 6),
  ('science', 'solutions-concentrations', 'Solutions and Concentrations', 7),
  ('science', 'acids-bases-ph', 'Acids, Bases, and pH', 8),
  ('science', 'mechanics', 'Mechanics: Kinematics, Newton Laws, Work, and Energy', 9),
  ('science', 'thermodynamics-heat-transfer', 'Thermodynamics and Heat Transfer', 10),
  ('science', 'electricity-magnetism', 'Basic Electricity and Magnetism', 11),
  ('science', 'earth-systems', 'Earth Systems: Plate Tectonics, Rock Cycle, and Minerals', 12),
  ('mathematics', 'linear-quadratic-equations', 'Linear and Quadratic Equations', 1),
  ('mathematics', 'polynomial-operations', 'Polynomial Operations', 2),
  ('mathematics', 'systems-of-equations', 'Systems of Equations', 3),
  ('mathematics', 'ratios-proportions-percentages', 'Ratios, Proportions, and Percentages', 4),
  ('mathematics', 'exponents-logarithms', 'Exponents and Logarithms', 5),
  ('mathematics', 'plane-geometry', 'Plane Geometry: Angles, Triangles, and Circles', 6),
  ('mathematics', 'trigonometry', 'Trigonometric Identities and Right Triangles', 7),
  ('mathematics', 'coordinate-geometry-conics', 'Coordinate Geometry and Conics', 8),
  ('mathematics', 'permutations-combinations', 'Permutations and Combinations', 9),
  ('mathematics', 'basic-probability', 'Basic Probability', 10),
  ('mathematics', 'descriptive-statistics', 'Descriptive Statistics', 11),
  ('mathematics', 'limits-derivatives', 'Limits and Derivatives Fundamentals', 12)
) AS seed(domain_slug, slug, title, display_order)
JOIN public.curriculum_domains d ON d.slug = seed.domain_slug
ON CONFLICT (slug) DO UPDATE SET
  domain_uuid = EXCLUDED.domain_uuid,
  title = EXCLUDED.title,
  display_order = EXCLUDED.display_order,
  is_core = EXCLUDED.is_core,
  updated_at = now();

INSERT INTO public.badge_definitions (slug, title, description, criteria, status)
VALUES
  ('math-whiz', 'Math Whiz', 'Master five Mathematics subtopics.', '{"kind":"mastered_subtopics","domain":"mathematics","count":5}', 'published'),
  ('century-club', 'Century Club', 'Complete 100 questions.', '{"kind":"questions_completed","count":100}', 'published'),
  ('calculators-forbidden', 'Calculators Forbidden', 'Solve 50 mental-math questions.', '{"kind":"mental_math_questions","count":50}', 'published')
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  criteria = EXCLUDED.criteria,
  status = EXCLUDED.status,
  updated_at = now();

INSERT INTO public.app_settings (setting_key, setting_value, is_public, description)
VALUES
  ('study_phase_rules', '{"orientation_days":7,"core_mastery_percent":60,"integration_percent":25,"final_review_days_min":10,"final_review_days_max":14}'::jsonb, true, 'Default adaptive study-plan phase allocation.'),
  ('daily_intensity_rules', '{"rest":{"items":0},"light":{"sets":1,"minutes_min":15,"minutes_max":20},"medium":{"sets":2,"review_drills":1,"minutes_min":45,"minutes_max":60},"heavy":{"sets":3,"quizzes_or_mini_mocks":1,"minutes_min":75,"minutes_max":100}}'::jsonb, true, 'Default daily study intensity targets.'),
  ('assessment_blueprints', '{"rapid_diagnostic":{"items":20,"items_per_domain":5,"minutes":15},"subtopic_quiz":{"items":10,"pass_score":8,"minutes":15},"full_mock":{"items":160,"minutes":150,"logical_reasoning":40,"english":30,"science":50,"mathematics":40},"mini_mock":{"items":40,"minutes":45}}'::jsonb, true, 'Default diagnostic, quiz, and mock-exam blueprints.'),
  ('spaced_review_intervals_days', '[1,3,7,14]'::jsonb, true, 'Fixed spaced-review ladder after errors and correct answers.'),
  ('mastery_thresholds', '{"familiar_min_percent":60,"proficient_min_percent":80,"subtopic_quiz_pass_score":8,"mastered_spaced_checks":2,"mastery_decay_days":21,"weak_spot_min_attempts":5,"weak_spot_max_accuracy_percent":60}'::jsonb, true, 'Deterministic mastery and weak-spot thresholds.'),
  ('privacy_retention_rules', '{"account_deletion_hours":48,"analytics_min_cohort_size":20,"timezone":"Asia/Manila"}'::jsonb, false, 'Operational privacy limits; API jobs must enforce deletion and retention deadlines.')
ON CONFLICT (setting_key) DO NOTHING;

COMMIT;
