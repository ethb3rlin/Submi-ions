SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: excellence_award_track; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.excellence_award_track AS ENUM (
    'smart_contracts',
    'ux',
    'crypto'
);


--
-- Name: join_application_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.join_application_state AS ENUM (
    'pending',
    'approved',
    'declined'
);


--
-- Name: judging_track; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.judging_track AS ENUM (
    'transact',
    'infra',
    'tooling',
    'social',
    'meta'
);


--
-- Name: user_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_kind AS ENUM (
    'hacker',
    'judge',
    'organizer'
);


--
-- Name: que_validate_tags(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_validate_tags(tags_array jsonb) RETURNS boolean
    LANGUAGE sql
    AS $$
  SELECT bool_and(
    jsonb_typeof(value) = 'string'
    AND
    char_length(value::text) <= 100
  )
  FROM jsonb_array_elements(tags_array)
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    job_class text NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error_message text,
    queue text DEFAULT 'default'::text NOT NULL,
    last_error_backtrace text,
    finished_at timestamp with time zone,
    expired_at timestamp with time zone,
    args jsonb DEFAULT '[]'::jsonb NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    job_schema_version integer NOT NULL,
    kwargs jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT error_length CHECK (((char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000))),
    CONSTRAINT job_class_length CHECK ((char_length(
CASE job_class
    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN ((args -> 0) ->> 'job_class'::text)
    ELSE job_class
END) <= 200)),
    CONSTRAINT queue_length CHECK ((char_length(queue) <= 100)),
    CONSTRAINT valid_args CHECK ((jsonb_typeof(args) = 'array'::text)),
    CONSTRAINT valid_data CHECK (((jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND public.que_validate_tags((data -> 'tags'::text))))))
)
WITH (fillfactor='90');


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.que_jobs IS '7';


--
-- Name: que_determine_job_state(public.que_jobs); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_determine_job_state(job public.que_jobs) RETURNS text
    LANGUAGE sql
    AS $$
  SELECT
    CASE
    WHEN job.expired_at  IS NOT NULL    THEN 'expired'
    WHEN job.finished_at IS NOT NULL    THEN 'finished'
    WHEN job.error_count > 0            THEN 'errored'
    WHEN job.run_at > CURRENT_TIMESTAMP THEN 'scheduled'
    ELSE                                     'ready'
    END
$$;


--
-- Name: que_job_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_job_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    locker_pid integer;
    sort_key json;
  BEGIN
    -- Don't do anything if the job is scheduled for a future time.
    IF NEW.run_at IS NOT NULL AND NEW.run_at > now() THEN
      RETURN null;
    END IF;

    -- Pick a locker to notify of the job's insertion, weighted by their number
    -- of workers. Should bounce pseudorandomly between lockers on each
    -- invocation, hence the md5-ordering, but still touch each one equally,
    -- hence the modulo using the job_id.
    SELECT pid
    INTO locker_pid
    FROM (
      SELECT *, last_value(row_number) OVER () + 1 AS count
      FROM (
        SELECT *, row_number() OVER () - 1 AS row_number
        FROM (
          SELECT *
          FROM public.que_lockers ql, generate_series(1, ql.worker_count) AS id
          WHERE
            listening AND
            queues @> ARRAY[NEW.queue] AND
            ql.job_schema_version = NEW.job_schema_version
          ORDER BY md5(pid::text || id::text)
        ) t1
      ) t2
    ) t3
    WHERE NEW.id % count = row_number;

    IF locker_pid IS NOT NULL THEN
      -- There's a size limit to what can be broadcast via LISTEN/NOTIFY, so
      -- rather than throw errors when someone enqueues a big job, just
      -- broadcast the most pertinent information, and let the locker query for
      -- the record after it's taken the lock. The worker will have to hit the
      -- DB in order to make sure the job is still visible anyway.
      SELECT row_to_json(t)
      INTO sort_key
      FROM (
        SELECT
          'job_available' AS message_type,
          NEW.queue       AS queue,
          NEW.priority    AS priority,
          NEW.id          AS id,
          -- Make sure we output timestamps as UTC ISO 8601
          to_char(NEW.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at
      ) t;

      PERFORM pg_notify('que_listener_' || locker_pid::text, sort_key::text);
    END IF;

    RETURN null;
  END
$$;


--
-- Name: que_state_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_state_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    row record;
    message json;
    previous_state text;
    current_state text;
  BEGIN
    IF TG_OP = 'INSERT' THEN
      previous_state := 'nonexistent';
      current_state  := public.que_determine_job_state(NEW);
      row            := NEW;
    ELSIF TG_OP = 'DELETE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := 'nonexistent';
      row            := OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := public.que_determine_job_state(NEW);

      -- If the state didn't change, short-circuit.
      IF previous_state = current_state THEN
        RETURN null;
      END IF;

      row := NEW;
    ELSE
      RAISE EXCEPTION 'Unrecognized TG_OP: %', TG_OP;
    END IF;

    SELECT row_to_json(t)
    INTO message
    FROM (
      SELECT
        'job_change' AS message_type,
        row.id       AS id,
        row.queue    AS queue,

        coalesce(row.data->'tags', '[]'::jsonb) AS tags,

        to_char(row.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at,
        to_char(now()      AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time,

        CASE row.job_class
        WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' THEN
          coalesce(
            row.args->0->>'job_class',
            'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          )
        ELSE
          row.job_class
        END AS job_class,

        previous_state AS previous_state,
        current_state  AS current_state
    ) t;

    PERFORM pg_notify('que_state', message::text);

    RETURN null;
  END
$$;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethereum_addresses (
    id bigint NOT NULL,
    address character varying,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ethereum_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ethereum_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ethereum_addresses_id_seq OWNED BY public.ethereum_addresses.id;


--
-- Name: excellence_judgements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excellence_judgements (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    submission_id bigint NOT NULL,
    score double precision NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: excellence_judgements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.excellence_judgements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: excellence_judgements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.excellence_judgements_id_seq OWNED BY public.excellence_judgements.id;


--
-- Name: excellence_team_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excellence_team_memberships (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    excellence_team_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: excellence_team_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.excellence_team_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: excellence_team_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.excellence_team_memberships_id_seq OWNED BY public.excellence_team_memberships.id;


--
-- Name: excellence_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excellence_teams (
    id bigint NOT NULL,
    track public.excellence_award_track NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: excellence_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.excellence_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: excellence_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.excellence_teams_id_seq OWNED BY public.excellence_teams.id;


--
-- Name: hacking_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hacking_teams (
    id bigint NOT NULL,
    name character varying,
    agenda text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hacking_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hacking_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hacking_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hacking_teams_id_seq OWNED BY public.hacking_teams.id;


--
-- Name: join_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.join_applications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    hacking_team_id bigint NOT NULL,
    decided_by_id bigint,
    decided_at timestamp(6) without time zone,
    state public.join_application_state DEFAULT 'pending'::public.join_application_state NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: join_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.join_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: join_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.join_applications_id_seq OWNED BY public.join_applications.id;


--
-- Name: judgements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.judgements (
    id bigint NOT NULL,
    judging_team_id bigint NOT NULL,
    submission_id bigint NOT NULL,
    technical_vote_id bigint,
    product_vote_id bigint,
    concept_vote_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "time" time without time zone,
    no_show boolean DEFAULT false NOT NULL
);


--
-- Name: judgements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.judgements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: judgements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.judgements_id_seq OWNED BY public.judgements.id;


--
-- Name: judging_breaks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.judging_breaks (
    id bigint NOT NULL,
    begins time without time zone NOT NULL,
    ends time without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: judging_breaks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.judging_breaks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: judging_breaks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.judging_breaks_id_seq OWNED BY public.judging_breaks.id;


--
-- Name: judging_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.judging_teams (
    id bigint NOT NULL,
    track public.judging_track NOT NULL,
    technical_judge_id bigint,
    product_judge_id bigint,
    concept_judge_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    location character varying
);


--
-- Name: judging_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.judging_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: judging_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.judging_teams_id_seq OWNED BY public.judging_teams.id;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.que_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.que_jobs_id_seq OWNED BY public.que_jobs.id;


--
-- Name: que_lockers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.que_lockers (
    pid integer NOT NULL,
    worker_count integer NOT NULL,
    worker_priorities integer[] NOT NULL,
    ruby_pid integer NOT NULL,
    ruby_hostname text NOT NULL,
    queues text[] NOT NULL,
    listening boolean NOT NULL,
    job_schema_version integer DEFAULT 1,
    CONSTRAINT valid_queues CHECK (((array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL))),
    CONSTRAINT valid_worker_priorities CHECK (((array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)))
);


--
-- Name: que_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_values (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT valid_value CHECK ((jsonb_typeof(value) = 'object'::text))
)
WITH (fillfactor='90');


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: submission_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_comments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    text text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    submission_id bigint NOT NULL
);


--
-- Name: submission_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submission_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submission_comments_id_seq OWNED BY public.submission_comments.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id bigint NOT NULL,
    title text,
    description text,
    repo_url text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    hacking_team_id bigint,
    track public.judging_track DEFAULT 'infra'::public.judging_track NOT NULL,
    pitchdeck_url character varying,
    excellence_award_track public.excellence_award_track
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: ticket_invalidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_invalidations (
    ticket_id uuid NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    github_handle character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    kind public.user_kind DEFAULT 'hacker'::public.user_kind NOT NULL,
    approved_at timestamp(6) without time zone DEFAULT NULL::timestamp without time zone,
    approved_by_id bigint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id bigint NOT NULL,
    mark double precision,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    completed boolean DEFAULT false
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: ethereum_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_addresses ALTER COLUMN id SET DEFAULT nextval('public.ethereum_addresses_id_seq'::regclass);


--
-- Name: excellence_judgements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_judgements ALTER COLUMN id SET DEFAULT nextval('public.excellence_judgements_id_seq'::regclass);


--
-- Name: excellence_team_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_team_memberships ALTER COLUMN id SET DEFAULT nextval('public.excellence_team_memberships_id_seq'::regclass);


--
-- Name: excellence_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_teams ALTER COLUMN id SET DEFAULT nextval('public.excellence_teams_id_seq'::regclass);


--
-- Name: hacking_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hacking_teams ALTER COLUMN id SET DEFAULT nextval('public.hacking_teams_id_seq'::regclass);


--
-- Name: join_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_applications ALTER COLUMN id SET DEFAULT nextval('public.join_applications_id_seq'::regclass);


--
-- Name: judgements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements ALTER COLUMN id SET DEFAULT nextval('public.judgements_id_seq'::regclass);


--
-- Name: judging_breaks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_breaks ALTER COLUMN id SET DEFAULT nextval('public.judging_breaks_id_seq'::regclass);


--
-- Name: judging_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_teams ALTER COLUMN id SET DEFAULT nextval('public.judging_teams_id_seq'::regclass);


--
-- Name: que_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN id SET DEFAULT nextval('public.que_jobs_id_seq'::regclass);


--
-- Name: submission_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_comments ALTER COLUMN id SET DEFAULT nextval('public.submission_comments_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: ethereum_addresses ethereum_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_addresses
    ADD CONSTRAINT ethereum_addresses_pkey PRIMARY KEY (id);


--
-- Name: excellence_judgements excellence_judgements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_judgements
    ADD CONSTRAINT excellence_judgements_pkey PRIMARY KEY (id);


--
-- Name: excellence_team_memberships excellence_team_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_team_memberships
    ADD CONSTRAINT excellence_team_memberships_pkey PRIMARY KEY (id);


--
-- Name: excellence_teams excellence_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_teams
    ADD CONSTRAINT excellence_teams_pkey PRIMARY KEY (id);


--
-- Name: hacking_teams hacking_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hacking_teams
    ADD CONSTRAINT hacking_teams_pkey PRIMARY KEY (id);


--
-- Name: join_applications join_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_applications
    ADD CONSTRAINT join_applications_pkey PRIMARY KEY (id);


--
-- Name: judgements judgements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements
    ADD CONSTRAINT judgements_pkey PRIMARY KEY (id);


--
-- Name: judging_breaks judging_breaks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_breaks
    ADD CONSTRAINT judging_breaks_pkey PRIMARY KEY (id);


--
-- Name: judging_teams judging_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_teams
    ADD CONSTRAINT judging_teams_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (id);


--
-- Name: que_lockers que_lockers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_lockers
    ADD CONSTRAINT que_lockers_pkey PRIMARY KEY (pid);


--
-- Name: que_values que_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_values
    ADD CONSTRAINT que_values_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (key);


--
-- Name: submission_comments submission_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_comments
    ADD CONSTRAINT submission_comments_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: idx_on_user_id_excellence_team_id_1dc1542532; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_user_id_excellence_team_id_1dc1542532 ON public.excellence_team_memberships USING btree (user_id, excellence_team_id);


--
-- Name: index_ethereum_addresses_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ethereum_addresses_on_address ON public.ethereum_addresses USING btree (address);


--
-- Name: index_ethereum_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ethereum_addresses_on_user_id ON public.ethereum_addresses USING btree (user_id);


--
-- Name: index_excellence_judgements_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excellence_judgements_on_submission_id ON public.excellence_judgements USING btree (submission_id);


--
-- Name: index_excellence_judgements_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excellence_judgements_on_user_id ON public.excellence_judgements USING btree (user_id);


--
-- Name: index_excellence_judgements_on_user_id_and_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_excellence_judgements_on_user_id_and_submission_id ON public.excellence_judgements USING btree (user_id, submission_id);


--
-- Name: index_excellence_team_memberships_on_excellence_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excellence_team_memberships_on_excellence_team_id ON public.excellence_team_memberships USING btree (excellence_team_id);


--
-- Name: index_excellence_team_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_excellence_team_memberships_on_user_id ON public.excellence_team_memberships USING btree (user_id);


--
-- Name: index_excellence_teams_on_track; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_excellence_teams_on_track ON public.excellence_teams USING btree (track);


--
-- Name: index_join_applications_on_decided_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_join_applications_on_decided_by_id ON public.join_applications USING btree (decided_by_id);


--
-- Name: index_join_applications_on_hacking_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_join_applications_on_hacking_team_id ON public.join_applications USING btree (hacking_team_id);


--
-- Name: index_join_applications_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_join_applications_on_state ON public.join_applications USING btree (state);


--
-- Name: index_join_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_join_applications_on_user_id ON public.join_applications USING btree (user_id);


--
-- Name: index_join_applications_on_user_id_and_hacking_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_join_applications_on_user_id_and_hacking_team_id ON public.join_applications USING btree (user_id, hacking_team_id);


--
-- Name: index_judgements_on_concept_vote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judgements_on_concept_vote_id ON public.judgements USING btree (concept_vote_id);


--
-- Name: index_judgements_on_judging_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judgements_on_judging_team_id ON public.judgements USING btree (judging_team_id);


--
-- Name: index_judgements_on_product_vote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judgements_on_product_vote_id ON public.judgements USING btree (product_vote_id);


--
-- Name: index_judgements_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judgements_on_submission_id ON public.judgements USING btree (submission_id);


--
-- Name: index_judgements_on_technical_vote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judgements_on_technical_vote_id ON public.judgements USING btree (technical_vote_id);


--
-- Name: index_judgements_on_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judgements_on_time ON public.judgements USING btree ("time");


--
-- Name: index_judging_breaks_on_begins; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judging_breaks_on_begins ON public.judging_breaks USING btree (begins);


--
-- Name: index_judging_breaks_on_ends; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judging_breaks_on_ends ON public.judging_breaks USING btree (ends);


--
-- Name: index_judging_teams_on_concept_judge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judging_teams_on_concept_judge_id ON public.judging_teams USING btree (concept_judge_id);


--
-- Name: index_judging_teams_on_product_judge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judging_teams_on_product_judge_id ON public.judging_teams USING btree (product_judge_id);


--
-- Name: index_judging_teams_on_technical_judge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_judging_teams_on_technical_judge_id ON public.judging_teams USING btree (technical_judge_id);


--
-- Name: index_submission_comments_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submission_comments_on_submission_id ON public.submission_comments USING btree (submission_id);


--
-- Name: index_submission_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submission_comments_on_user_id ON public.submission_comments USING btree (user_id);


--
-- Name: index_submissions_on_excellence_award_track; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_excellence_award_track ON public.submissions USING btree (excellence_award_track);


--
-- Name: index_submissions_on_hacking_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_hacking_team_id ON public.submissions USING btree (hacking_team_id);


--
-- Name: index_submissions_on_track; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_track ON public.submissions USING btree (track);


--
-- Name: index_ticket_invalidations_on_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_invalidations_on_ticket_id ON public.ticket_invalidations USING btree (ticket_id);


--
-- Name: index_ticket_invalidations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_invalidations_on_user_id ON public.ticket_invalidations USING btree (user_id);


--
-- Name: index_users_on_approved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_approved_by_id ON public.users USING btree (approved_by_id);


--
-- Name: index_users_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_kind ON public.users USING btree (kind);


--
-- Name: index_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_user_id ON public.votes USING btree (user_id);


--
-- Name: que_jobs_args_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_args_gin_idx ON public.que_jobs USING gin (args jsonb_path_ops);


--
-- Name: que_jobs_data_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_data_gin_idx ON public.que_jobs USING gin (data jsonb_path_ops);


--
-- Name: que_jobs_kwargs_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_kwargs_gin_idx ON public.que_jobs USING gin (kwargs jsonb_path_ops);


--
-- Name: que_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_poll_idx ON public.que_jobs USING btree (job_schema_version, queue, priority, run_at, id) WHERE ((finished_at IS NULL) AND (expired_at IS NULL));


--
-- Name: que_jobs que_job_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_job_notify AFTER INSERT ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_job_notify();


--
-- Name: que_jobs que_state_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_state_notify AFTER INSERT OR DELETE OR UPDATE ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_state_notify();


--
-- Name: excellence_judgements fk_rails_06f64c5e2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_judgements
    ADD CONSTRAINT fk_rails_06f64c5e2e FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: judgements fk_rails_09047d697d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements
    ADD CONSTRAINT fk_rails_09047d697d FOREIGN KEY (judging_team_id) REFERENCES public.judging_teams(id);


--
-- Name: submission_comments fk_rails_151af9f565; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_comments
    ADD CONSTRAINT fk_rails_151af9f565 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: judgements fk_rails_44810ea7e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements
    ADD CONSTRAINT fk_rails_44810ea7e7 FOREIGN KEY (technical_vote_id) REFERENCES public.votes(id) ON DELETE SET NULL;


--
-- Name: judging_teams fk_rails_53da7764c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_teams
    ADD CONSTRAINT fk_rails_53da7764c5 FOREIGN KEY (concept_judge_id) REFERENCES public.users(id);


--
-- Name: ticket_invalidations fk_rails_57a52ebd3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_invalidations
    ADD CONSTRAINT fk_rails_57a52ebd3e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: join_applications fk_rails_662f7c8109; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_applications
    ADD CONSTRAINT fk_rails_662f7c8109 FOREIGN KEY (decided_by_id) REFERENCES public.users(id);


--
-- Name: excellence_team_memberships fk_rails_6dc9eee186; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_team_memberships
    ADD CONSTRAINT fk_rails_6dc9eee186 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: join_applications fk_rails_79b580ba0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_applications
    ADD CONSTRAINT fk_rails_79b580ba0b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: judgements fk_rails_7ade181073; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements
    ADD CONSTRAINT fk_rails_7ade181073 FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: submissions fk_rails_867ed14b77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT fk_rails_867ed14b77 FOREIGN KEY (hacking_team_id) REFERENCES public.hacking_teams(id);


--
-- Name: excellence_team_memberships fk_rails_8dbfed4ff1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_team_memberships
    ADD CONSTRAINT fk_rails_8dbfed4ff1 FOREIGN KEY (excellence_team_id) REFERENCES public.excellence_teams(id);


--
-- Name: users fk_rails_9c2d7e0c9d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_9c2d7e0c9d FOREIGN KEY (approved_by_id) REFERENCES public.users(id);


--
-- Name: judgements fk_rails_ab6b10a49b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements
    ADD CONSTRAINT fk_rails_ab6b10a49b FOREIGN KEY (concept_vote_id) REFERENCES public.votes(id) ON DELETE SET NULL;


--
-- Name: ethereum_addresses fk_rails_b093f53460; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_addresses
    ADD CONSTRAINT fk_rails_b093f53460 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: votes fk_rails_c9b3bef597; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT fk_rails_c9b3bef597 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: judging_teams fk_rails_d85da3e256; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_teams
    ADD CONSTRAINT fk_rails_d85da3e256 FOREIGN KEY (technical_judge_id) REFERENCES public.users(id);


--
-- Name: judging_teams fk_rails_e31508abac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judging_teams
    ADD CONSTRAINT fk_rails_e31508abac FOREIGN KEY (product_judge_id) REFERENCES public.users(id);


--
-- Name: judgements fk_rails_e3571e34fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.judgements
    ADD CONSTRAINT fk_rails_e3571e34fd FOREIGN KEY (product_vote_id) REFERENCES public.votes(id) ON DELETE SET NULL;


--
-- Name: submission_comments fk_rails_e4ff9f0115; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_comments
    ADD CONSTRAINT fk_rails_e4ff9f0115 FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: excellence_judgements fk_rails_ec19bb2546; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excellence_judgements
    ADD CONSTRAINT fk_rails_ec19bb2546 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: join_applications fk_rails_fb744d600b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_applications
    ADD CONSTRAINT fk_rails_fb744d600b FOREIGN KEY (hacking_team_id) REFERENCES public.hacking_teams(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240521013859'),
('20240520211620'),
('20240520144709'),
('20240520144352'),
('20240520133837'),
('20240519150608'),
('20240517100307'),
('20240516213805'),
('20240516194903'),
('20240516145819'),
('20240514215949'),
('20240513224636'),
('20240512140326'),
('20240510113819'),
('20240506231307'),
('20240503234521'),
('20240503234212'),
('20240503165434'),
('20240503100231'),
('20240503092427'),
('20240426111516'),
('20240425204203'),
('20240423165330'),
('20240416032958'),
('20240416011832'),
('20240415123145'),
('20240409192041'),
('20240311120426'),
('20240220113836'),
('20240220113718'),
('20240219191554');

