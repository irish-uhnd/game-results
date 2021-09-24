--
-- PostgreSQL database dump
--

-- Dumped from database version 12.8 (Debian 12.8-1.pgdg100+1)
-- Dumped by pg_dump version 13.4

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
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: coaches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coaches (
    id integer NOT NULL,
    first_name text,
    middle_name text,
    last_name text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    suffix text,
    is_notre_dame boolean DEFAULT false NOT NULL,
    is_opponent boolean DEFAULT true
);


ALTER TABLE public.coaches OWNER TO postgres;

--
-- Name: coach_full_name(public.coaches); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.coach_full_name(coach_row public.coaches) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE full_name text;
BEGIN

    full_name := coach_row.first_name;
    
    IF coach_row.middle_name IS NOT NULL THEN
        full_name := full_name || ' ' || coach_row.middle_name;
    END IF;
    
    IF coach_row.last_name IS NOT NULL THEN
        full_name := full_name || ' ' || coach_row.last_name;
    END IF;
    
    IF coach_row.suffix IS NOT NULL THEN
        full_name := full_name || ' ' || coach_row.suffix;
    END IF;
    
    RETURN full_name;

END;
$$;


ALTER FUNCTION public.coach_full_name(coach_row public.coaches) OWNER TO postgres;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


ALTER FUNCTION public.set_current_timestamp_updated_at() OWNER TO postgres;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO postgres;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO postgres;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO postgres;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO postgres;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO postgres;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO postgres;

--
-- Name: coaches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.coaches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.coaches_id_seq OWNER TO postgres;

--
-- Name: coaches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.coaches_id_seq OWNED BY public.coaches.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    id integer NOT NULL,
    date date NOT NULL,
    result text NOT NULL,
    site text NOT NULL,
    nd_coach integer NOT NULL,
    opp_coach integer NOT NULL,
    nd_score integer NOT NULL,
    opp_score integer NOT NULL,
    nd_rank text,
    nd_final_rank text,
    opp_rank text,
    opp_final_rank text,
    opp_team_id integer NOT NULL
);


ALTER TABLE public.games OWNER TO postgres;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.games_id_seq OWNER TO postgres;

--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: team_coaches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_coaches (
    id integer NOT NULL,
    coach_id integer NOT NULL,
    team_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);


ALTER TABLE public.team_coaches OWNER TO postgres;

--
-- Name: team_coaches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_coaches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.team_coaches_id_seq OWNER TO postgres;

--
-- Name: team_coaches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_coaches_id_seq OWNED BY public.team_coaches.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_id_seq OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: coaches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches ALTER COLUMN id SET DEFAULT nextval('public.coaches_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: team_coaches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_coaches ALTER COLUMN id SET DEFAULT nextval('public.team_coaches_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"sources":[{"kind":"postgres","name":"default","tables":[{"computed_fields":[{"definition":{"function":{"schema":"public","name":"coach_full_name"}},"name":"full_name","comment":""}],"table":{"schema":"public","name":"coaches"}},{"object_relationships":[{"using":{"foreign_key_constraint_on":"nd_coach"},"name":"ndCoach"},{"using":{"foreign_key_constraint_on":"opp_coach"},"name":"oppCoach"},{"using":{"foreign_key_constraint_on":"opp_team_id"},"name":"opponent"}],"table":{"schema":"public","name":"games"}},{"table":{"schema":"public","name":"team_coaches"}},{"table":{"schema":"public","name":"teams"}}],"configuration":{"connection_info":{"use_prepared_statements":false,"database_url":{"from_env":"PG_DATABASE_URL"},"isolation_level":"read-committed"}}}],"version":3}	3
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":[]}	3	df9932be-7555-4650-9319-94688196bbb1	2021-09-22 05:38:44.728489+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
2c9a0c69-98ad-4b25-8fa8-3e5da46da49c	47	2021-09-22 05:37:23.588051+00	{"settings": {"migration_mode": "true"}, "migrations": {"default": {"1630286278959": false, "1630295383112": false, "1630297788981": false, "1630297817933": false, "1630298009809": false, "1630298050689": false, "1630298149201": false, "1630298605914": false, "1630382821996": false, "1630978791903": false, "1630978797537": false}}, "isStateCopyCompleted": true}	{"console_notifications": {"admin": {"date": null, "read": [], "showBadge": true}}, "telemetryNotificationShown": true}
\.


--
-- Data for Name: coaches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coaches (id, first_name, middle_name, last_name, created_at, updated_at, suffix, is_notre_dame, is_opponent) FROM stdin;
466	None	\N	\N	2021-09-23 05:02:27.34233+00	2021-09-23 05:02:27.34233+00	\N	t	t
467	Unknown	\N	\N	2021-09-23 05:02:34.069442+00	2021-09-23 05:02:34.069442+00	\N	t	t
3	Brian	\N	Kelly	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
4	Charlie	\N	Weis	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
6	Edward	\N	McKeever	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
7	Elmer	\N	Layden	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
8	Frank	\N	Hering	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
40	Amos	Alonzo	Stagg	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
9	Frank	\N	Leahy	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
10	Frank	\N	Longman	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
11	Gerry	\N	Faust	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
12	H.G.	\N	Hadden	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
13	Henry	\N	McGlew	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
14	Hugh	\N	Devore	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
15	Hunk	\N	Anderson	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
16	James	\N	Farragher	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
17	James	\N	McWeeney	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
18	James	\N	Morrison	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
20	Joe	\N	Kuharich	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
21	John	\N	Marks	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
22	Kent	\N	Baer	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
23	Knute	\N	Rockne	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
24	Lou	\N	Holtz	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
25	Pat	\N	O'Dea	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
26	Red	\N	Salmon	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
27	Terry	\N	Brennan	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
28	Thomas	\N	Barry	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
30	Victor	\N	Place	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
1	Ara	\N	Parseghian	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
2	Bob	\N	Davie	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
5	Dan	\N	Devine	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
19	Jesse	\N	Harper	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
29	Tyrone	\N	Willingham	2021-09-23 00:25:22.75047+00	2021-09-23 01:45:52.601991+00	\N	t	t
31	A.E.	\N	Hernstein	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
32	A.J.	\N	Jones	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
33	Ad	\N	Lindsey	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
34	Al	\N	Conover	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
231	Glenn "Pop"	\N	Warner	2021-09-23 01:17:31.996114+00	2021-09-23 05:38:36.775474+00	\N	f	t
330	Langdon "Biff"	\N	Lea	2021-09-23 01:17:31.996114+00	2021-09-23 05:38:49.102105+00	\N	f	t
373	Paul "Bear"	\N	Bryant	2021-09-23 01:17:31.996114+00	2021-09-23 05:38:59.87651+00	\N	f	t
121	Chauncey	L.	Berrien	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
206	Fred	M.	Walker	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
249	Herbert	C.	Reed	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
257	Ion	J.	Cortright	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
264	James	H.	Henry	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
268	James	M.	Saunderson	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
269	James	N.	Ashmore	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
304	John	L.	Smith	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
392	Ralph	H.	Young	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
412	Samuel	K.	Ruick	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
430	Thomas	J.	Smull	2021-09-23 01:17:31.996114+00	2021-09-23 01:17:31.996114+00	\N	f	t
112	Charles "Gus"	\N	Dorais	2021-09-23 01:17:31.996114+00	2021-09-23 05:38:22.385394+00	\N	f	t
132	Claude	\N	Simons	2021-09-23 01:17:31.996114+00	2021-09-23 05:41:58.449505+00	Jr.	f	t
35	Al	\N	Golden	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
36	Al	\N	Onofrio	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
37	Albert	\N	Barron	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
38	Alex	\N	Agase	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
39	Alpha	\N	Jamison	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
41	Andy	\N	Gustafson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
42	Art	\N	Curtis	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
43	Arthur	\N	Hamrick	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
44	Ben	\N	Martin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
45	Ben	\N	Schwartzwalder	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
46	Bennie	\N	Ellender	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
47	Bernie	\N	Bierman	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
48	Bernie	\N	Crimmins	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
49	Bernie	\N	Masterson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
50	Bert	\N	Kennedy	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
51	Biff	\N	Jones	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
52	Biggie	\N	Munn	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
53	Bill	\N	Arnsparger	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
54	Bill	\N	Barnes	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
55	Bill	\N	Cubit	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
56	Bill	\N	Curry	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
57	Bill	\N	Doba	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
58	Bill	\N	Dooley	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
59	Bill	\N	Elias	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
60	Bill	\N	Hargiss	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
61	Bill	\N	Hollenback	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
62	Bill	\N	Ingram	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
63	Bill	\N	Kern	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
64	Bill	\N	Mallory	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
65	Bill	\N	McCartney	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
66	Bill	\N	Meek	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
67	Bill	\N	Murray	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
68	Bill	\N	Parcells	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
69	Bill	\N	Roper	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
70	Bill	\N	Walsh	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
71	Bill	\N	Yeoman	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
72	Billick	\N	Whelchel	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
73	Billy	\N	Brewer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
74	Billy	\N	Tohill	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
75	Blaine	\N	McKusick	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
76	Bo	\N	McMillin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
77	Bo	\N	Schembechler	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
78	Bob	\N	DeMoss	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
79	Bob	\N	Devaney	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
80	Bob	\N	Hicks	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
81	Bob	\N	Stoops	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
82	Bob	\N	Sutton	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
83	Bob	\N	Voights	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
84	Bob	\N	Wagner	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
85	Bob	\N	Zuppke	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
86	Bobby	\N	Bowden	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
87	Bobby	\N	Collins	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
88	Bobby	\N	Dodd	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
89	Bobby	\N	Petrino	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
90	Bobby	\N	Ross	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
91	Bobby	\N	Williams	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
92	Brady	\N	Hoke	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
93	Brian	\N	Polian	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
94	Bronco	\N	Mendenhall	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
95	Bruce	\N	Snyder	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
96	Bud	\N	Carson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
97	Bud	\N	Wilkinson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
98	Buddy	\N	Teevens	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
99	Burt	\N	Kennedy	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
100	Butch	\N	Davis	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
101	Butch	\N	Scanlon	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
102	C.J	\N	Kenney	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
103	C.M.	\N	Best	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
104	C.M.	\N	Hollister	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
105	Carl	\N	DePasqua	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
106	Carl	\N	Peters	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
107	Carl	\N	Selmer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
108	Carl	\N	Snavely	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
109	Cecil	\N	Isbell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
110	Chalmer	\N	Woodward	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
111	Chan	\N	Gailey	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
113	Charles	\N	Bemies	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
114	Charles	\N	Daly	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
115	Charles	\N	Fairweather	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
116	Charley	\N	Pell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
117	Charlie	\N	McClendon	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
118	Charlie	\N	Strong	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
119	Charlie	\N	Tate	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
120	Charlie	\N	Weatherbie	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
122	Chester	\N	Brewer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
123	Chris	\N	Ault	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
124	Chuck	\N	Amato	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
125	Chuck	\N	Fairbanks	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
126	Chuck	\N	Long	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
127	Chuck	\N	Martin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
128	Clarence	\N	Herschberger	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
129	Clarence	\N	McReavy	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
130	Clarence	\N	Spears	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
131	Clark	\N	Shaughnessy	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
133	Clay	\N	Helton	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
134	Clem	\N	Crowe	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
135	Clyde	\N	Smith	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
136	Coach	\N	Atwood	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
137	Coach	\N	Gage	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
138	Coach	\N	Howe	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
139	Coach	\N	Jacobs	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
140	D.	\N	Pickett	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
141	D.H.	\N	Jackson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
142	D.M.	\N	Balliet	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
143	Dabo	\N	Swinney	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
144	Dan	\N	Henning	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
145	Dan	\N	Reed	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
146	Dan	\N	Savage	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
147	Danny	\N	Ford	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
148	Danny	\N	Hope	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
149	Darrell	\N	Hazell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
150	Darrell	\N	Royal	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
151	Darryl	\N	Rogers	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
152	Dave	\N	Allerdice	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
153	Dave	\N	Clawson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
154	Dave	\N	Doeren	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
155	Dave	\N	Roberts	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
156	Dave	\N	Wannstedt	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
157	David	\N	Bailiff	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
158	David	\N	Cutcliffe	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
159	David	\N	Hart	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
160	David	\N	Shaw	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
161	Dennis	\N	Erickson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
162	Dennis	\N	Green	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
163	Denny	\N	Stolz	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
164	Derek	\N	Mason	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
165	Dick	\N	Hanley	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
166	Dino	\N	Babers	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
167	Don	\N	Clark	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
168	Don	\N	Faurot	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
169	Don	\N	Nehlen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
170	Don	\N	Read	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
171	Duffy	\N	Daugherty	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
172	Dutch	\N	Clark	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
173	E.E.	\N	Bearg	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
174	E.J.	\N	Stewart	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
175	Earl	\N	Blaik	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
176	Earl	\N	Brown	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
177	Earle	\N	Hayes	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
178	Ed	\N	Cavanaugh	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
179	Ed	\N	Orgeron	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
180	Ed	\N	Price	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
181	Eddie	\N	Anderson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
182	Eddie	\N	Erdelatz	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
183	Edward	\N	Baker	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
184	Elliot	\N	Uzelac	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
185	Elmer	\N	McDevitt	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
186	Evan	\N	Williams	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
187	Fielding	\N	Yost	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
188	Fisher	\N	DeBerry	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
189	Foge	\N	Fazio	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
190	Forest	\N	Evashevski	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
191	Forrest	\N	Gregg	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
192	Fran	\N	Curci	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
193	Francis	\N	Cayou	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
194	Francis	\N	Schmidt	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
195	Frank	\N	Bridges	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
196	Frank	\N	Dennie	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
197	Frank	\N	Haggerty	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
198	Frank	\N	Hinkey	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
199	Frank	\N	O'Neill	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
200	Frank	\N	Solich	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
201	Frank	\N	Sommer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
202	Frank	\N	Spaziani	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
203	Frank	\N	Waters	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
204	Fred	\N	Akers	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
205	Fred	\N	Dawson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
207	Fred	\N	von Appen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
208	Fritz	\N	Crisler	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
209	Gar	\N	Davidson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
210	Gary	\N	Barnett	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
211	Gary	\N	Crowton	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
212	Gary	\N	Moeller	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
213	Gary	\N	Tranquill	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
214	Geoff	\N	Collins	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
215	Geoffrey	\N	Keyes	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
216	George	\N	Barclay	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
217	George	\N	Chaump	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
218	George	\N	Clark	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
219	George	\N	Denman	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
220	George	\N	Gauthier	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
221	George	\N	Huff	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
222	George	\N	Keogan	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
223	George	\N	Munger	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
224	George	\N	O'Brien	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
225	George	\N	O'Leary	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
226	George	\N	Perles	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
227	George	\N	Sanford	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
228	George	\N	Sauer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
229	George	\N	Welsh	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
230	Gerry	\N	Dinardo	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
232	Glenn	\N	Thistlethwaite	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
233	Greg	\N	McMackin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
234	Greg	\N	Robinson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
235	Greg	\N	Schiano	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
236	Gustave	\N	Ferbert	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
237	H.	\N	Schnellenberger	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
238	H.F.	\N	Schulte	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
239	H.N.	\N	Russell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
240	Hank	\N	Hardwick	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
241	Harlan	\N	Page	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
242	Harold	\N	Iddings	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
243	Harry	\N	Stuhldreher	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
244	Harry	\N	Towne	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
245	Harvey	\N	Harman	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
246	Henry	\N	Frnka	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
247	Henry	\N	Hall	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
248	Henry	\N	Keep	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
250	Herbert	\N	Huebel	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
251	Heze	\N	Clark	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
252	Homer	\N	Smith	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
253	Howard	\N	Harpster	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
254	Howard	\N	Jones	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
255	Howard	\N	Odell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
256	Hugo	\N	Bezdek	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
258	Jack	\N	Bicknell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
259	Jack	\N	Chevigny	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
260	Jack	\N	Elway	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
261	Jack	\N	Mollenkopf	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
262	Jack	\N	Ryan	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
263	Jackie	\N	Sherrill	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
265	James	\N	Henderson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
266	James	\N	Herron	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
267	James	\N	Horne	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
270	James	\N	Phelan	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
271	James	\N	Sheldon	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
272	Jeff	\N	Cravath	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
273	Jeff	\N	Hafley	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
274	Jeff	\N	Jagodzinski	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
275	Jeff	\N	Monken	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
276	Jeff	\N	Scott	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
277	Jeff	\N	Stoutland	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
278	Jerry	\N	Berndt	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
279	Jerry	\N	Burns	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
280	Jerry	\N	Stovall	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
281	Jess	\N	Hill	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
282	Jim	\N	Carlen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
283	Jim	\N	Colletto	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
284	Jim	\N	Grobe	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
285	Jim	\N	Harbaugh	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
286	Jim	\N	Hickey	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
287	Jim	\N	Lambright	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
288	Jim	\N	Mackenzie	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
289	Jim	\N	Pittman	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
290	Jim	\N	Tatum	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
291	Jim	\N	Tressel	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
292	Jim	\N	Valek	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
293	Jim	\N	Young	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
294	Jimbo	\N	Fisher	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
295	Jimmy	\N	Conzelman	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
296	Jimmy	\N	Johnson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
297	Jock	\N	Sutherland	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
298	Joe	\N	Morrison	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
299	Joe	\N	Paterno	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
300	Joe	\N	Tiller	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
301	John	\N	Bunting	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
302	John	\N	Cooper	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
303	John	\N	Hollister	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
305	John	\N	Mackovic	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
306	John	\N	McEwan	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
307	John	\N	McKay	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
308	John	\N	McLean	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
309	John	\N	Michelosen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
310	John	\N	Pont	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
311	John	\N	Ralston	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
312	John	\N	Richards	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
313	John	\N	Robinson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
314	Johnny	\N	Majors	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
315	Joseph	\N	Thompson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
316	Joseph	\N	Yukica	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
317	Jumbo	\N	Stiehm	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
318	Justin	\N	Fuente	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
319	Karl	\N	Dorrell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
320	Keith	\N	Gilbertson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
321	Ken	\N	Cooper	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
322	Ken	\N	Hatfield	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
323	Ken	\N	Niumatalolo	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
324	Kirby	\N	Smart	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
325	Kyle	\N	Flood	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
326	Kyle	\N	Whittingham	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
327	L.	\N	Raffensperger	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
328	L.C.	\N	Turner	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
329	Lane	\N	Kiffin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
331	Larry	\N	Fedora	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
332	Larry	\N	Smith	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
333	Lavell	\N	Edwards	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
334	Len	\N	Casanova	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
335	Leon	\N	Burtnett	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
336	Les	\N	Miles	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
337	Lloyd	\N	Carr	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
338	Lou	\N	Saban	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
339	Lowell	\N	Dawson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
340	Ludlow	\N	Wray	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
341	M.E.	\N	Witham	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
342	M.J.	\N	Bradshaw	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
343	Mack	\N	Brown	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
344	Mal	\N	Elward	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
345	Marchy	\N	Schwartz	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
346	Mark	\N	Dantonio	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
347	Mark	\N	Richt	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
348	Mark	\N	Whipple	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
349	Marv	\N	Levy	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
350	Matt	\N	Campbell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
351	Matt	\N	Rhule	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
352	Matty	\N	Bell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
353	Maynard	\N	Street	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
354	Mike	\N	Gottfried	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
355	Mike	\N	London	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
356	Mike	\N	Neu	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
357	Mike	\N	Norvell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
358	Mike	\N	Riley	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
359	Miles	\N	Casteel	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
360	Milt	\N	Bruhn	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
361	Moray	\N	Eby	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
362	Nick	\N	Saban	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
363	No	\N	Coach	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
364	Noble	\N	Kizer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
365	O.H.	\N	Luck	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
366	Oliver	\N	Cutts	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
367	Oscar	\N	Hagberg	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
368	Ossie	\N	Solem	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
369	Pappy	\N	Waldorf	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
370	Pat	\N	Fitzgerald	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
371	Pat	\N	Narduzzi	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
372	Pat	\N	Pasini	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
374	Paul	\N	Brown	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
375	Paul	\N	Chryst	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
376	Paul	\N	Dietzel	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
377	Paul	\N	Hackett	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
378	Paul	\N	Johnson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
379	Paul	\N	Pasqualoni	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
380	Paul	\N	Sheeks	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
381	Paul	\N	Wulff	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
382	Pepper	\N	Rodgers	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
383	Pete	\N	Carroll	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
384	Pete	\N	Elliott	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
385	Pete	\N	Vaughn	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
386	Phil	\N	Arbuckle	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
387	Phil	\N	Dickens	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
388	Phil	\N	King	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
389	Phillip	\N	Fulmer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
390	R.C.	\N	Slocum	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
391	Ralph	\N	Friedgen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
393	Ralph	\N	Jones	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
394	Ralph	\N	Sasse	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
395	Randy	\N	Edsall	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
396	Ray	\N	Eliot	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
397	Ray	\N	Morrison	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
398	Ray	\N	Nagel	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
399	Ray	\N	Perkins	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
400	Ray	\N	Willsey	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
401	Rich	\N	Brooks	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
402	Rich	\N	Ellerson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
403	Rich	\N	Rodriguez	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
404	Rick	\N	Forzano	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
405	Rick	\N	Lantz	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
406	Rip	\N	Miller	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
407	Rod	\N	Dowhower	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
408	Roy	\N	Bohler	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
409	Russell	\N	Townsend	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
410	S.M.	\N	Hammond	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
411	Sam	\N	Barry	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
413	Scot	\N	Loeffler	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
414	Scott	\N	Satterfield	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
415	Scott	\N	Shafer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
416	Skip	\N	Holtz	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
417	Snuff	\N	Mackowan	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
418	Sol	\N	Metzger	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
419	Stephen	\N	O'Rourke	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
420	Steve	\N	Addazio	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
421	Steve	\N	Sarkisian	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
422	Steve	\N	Sebo	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
423	Steve	\N	Spurrier	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
424	Stu	\N	Holcomb	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
425	Swede	\N	Larson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
426	Ted	\N	Roof	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
427	Ted	\N	Tollner	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
428	Terry	\N	Allen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
429	Terry	\N	Shea	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
431	Thomas	\N	McFadden	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
432	Todd	\N	Graham	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
433	Tom	\N	Cahill	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
434	Tom	\N	Coughlin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
435	Tom	\N	Hamilton	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
436	Tom	\N	Harp	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
437	Tom	\N	Leith	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
438	Tom	\N	O'Brien	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
439	Tommy	\N	Mills	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
440	Tony	\N	Hinkle	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
441	Troy	\N	Calhoun	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
442	Tug	\N	Wilson	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
443	Tuss	\N	McLaughry	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
444	Urban	\N	Meyer	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
445	Vee	\N	Green	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
446	Vernon	\N	Randall	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
447	Vince	\N	Dooley	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
448	W.C.	\N	Blaemaster	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
449	W.G.	\N	Kline	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
450	Walt	\N	Harris	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
451	Walter	\N	McCornack	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
452	Walter	\N	Milligan	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
453	Walter	\N	Powell	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
454	Walter	\N	Steffen	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
455	Warren	\N	Powers	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
456	Wayne	\N	Hardin	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
457	Wes	\N	Fesler	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
458	Wesley	\N	Englehorn	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
459	William	\N	Alexander	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
460	William	\N	Boone	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
461	William	\N	Dietz	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
462	William	\N	Juneau	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
463	William	\N	Spaulding	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
464	William	\N	Wood	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
465	Willie	\N	Taggart	2021-09-23 01:17:31.996114+00	2021-09-23 01:45:52.601991+00	\N	f	t
\.


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games (id, date, result, site, nd_coach, opp_coach, nd_score, opp_score, nd_rank, nd_final_rank, opp_rank, opp_final_rank, opp_team_id) FROM stdin;
1622	1887-11-23	L	HOME	466	466	0	8	No Poll	\N	No Poll	No Poll	76
1623	1888-04-20	L	HOME	466	466	6	26	No Poll	\N	No Poll	No Poll	76
1624	1888-04-21	L	HOME	466	466	4	10	No Poll	\N	No Poll	No Poll	76
1625	1888-12-06	W	HOME	466	466	20	0	No Poll	\N	No Poll	No Poll	48
1626	1889-11-14	W	AWAY	466	466	9	0	No Poll	\N	No Poll	No Poll	90
1627	1892-10-19	W	HOME	466	467	56	0	No Poll	\N	No Poll	No Poll	117
1628	1892-11-24	T	HOME	466	466	10	10	No Poll	\N	No Poll	No Poll	52
1629	1893-10-25	W	HOME	466	466	34	0	No Poll	\N	No Poll	No Poll	61
1630	1893-11-11	W	HOME	466	136	8	6	No Poll	\N	No Poll	No Poll	5
1631	1893-11-23	W	HOME	466	467	28	0	No Poll	\N	No Poll	No Poll	35
1632	1893-11-30	W	HOME	466	466	22	10	No Poll	\N	No Poll	No Poll	52
1633	1894-01-01	L	AWAY	466	40	0	8	No Poll	\N	No Poll	No Poll	23
1634	1894-10-13	W	HOME	18	466	14	0	No Poll	\N	No Poll	No Poll	52
1635	1894-10-20	T	HOME	18	137	6	6	No Poll	\N	No Poll	No Poll	5
1636	1894-11-15	W	HOME	18	446	30	0	No Poll	\N	No Poll	No Poll	141
1637	1894-11-22	W	HOME	18	467	18	6	No Poll	\N	No Poll	No Poll	110
1638	1894-11-29	L	HOME	18	137	12	19	No Poll	\N	No Poll	No Poll	5
1639	1895-10-19	W	HOME	12	467	20	0	No Poll	\N	No Poll	No Poll	91
1640	1895-11-07	W	HOME	12	467	18	2	No Poll	\N	No Poll	No Poll	55
1641	1895-11-22	L	HOME	12	467	0	18	No Poll	\N	No Poll	No Poll	57
1642	1895-11-28	W	HOME	12	467	32	0	No Poll	\N	No Poll	No Poll	26
1643	1896-10-08	L	HOME	8	467	0	4	No Poll	\N	No Poll	No Poll	26
1644	1896-10-14	L	HOME	8	40	0	18	No Poll	\N	No Poll	No Poll	23
1645	1896-10-27	W	HOME	8	467	46	0	No Poll	\N	No Poll	No Poll	116
1646	1896-11-14	L	HOME	8	410	22	28	No Poll	\N	No Poll	No Poll	106
1647	1896-11-19	W	HOME	8	138	24	0	No Poll	\N	No Poll	No Poll	5
1648	1896-11-20	W	HOME	8	467	82	0	No Poll	\N	No Poll	No Poll	51
1649	1896-11-26	W	HOME	8	104	8	0	No Poll	\N	No Poll	No Poll	13
1650	1897-10-03	W	HOME	8	43	4	0	No Poll	\N	No Poll	No Poll	36
1651	1897-10-13	T	HOME	8	467	0	0	No Poll	\N	No Poll	No Poll	110
1652	1897-10-28	W	HOME	8	467	62	0	No Poll	\N	No Poll	No Poll	24
1653	1897-11-06	L	AWAY	8	40	5	34	No Poll	\N	No Poll	No Poll	23
1654	1897-11-13	W	HOME	8	467	60	0	No Poll	\N	No Poll	No Poll	123
1655	1897-11-25	W	HOME	8	248	34	6	No Poll	\N	No Poll	No Poll	77
1656	1898-10-08	W	AWAY	8	221	5	0	No Poll	\N	No Poll	No Poll	54
1657	1898-10-15	W	HOME	8	248	53	0	No Poll	\N	No Poll	No Poll	77
1658	1898-10-21	L	AWAY	8	236	0	23	No Poll	\N	No Poll	No Poll	76
1659	1898-10-29	W	HOME	8	412	32	0	No Poll	\N	No Poll	No Poll	36
1660	1898-11-11	L	HOME	8	267	5	11	No Poll	\N	No Poll	No Poll	56
1661	1898-11-19	W	AWAY	8	139	60	0	No Poll	\N	No Poll	No Poll	5
1662	1899-09-27	W	HOME	17	466	29	5	No Poll	\N	No Poll	No Poll	40
1663	1899-09-30	W	HOME	17	113	40	0	No Poll	\N	No Poll	No Poll	77
1664	1899-10-04	L	AWAY	17	40	6	23	No Poll	\N	No Poll	No Poll	23
1665	1899-10-14	W	HOME	17	141	38	0	No Poll	\N	No Poll	No Poll	65
1666	1899-10-18	L	AWAY	17	236	0	12	No Poll	\N	No Poll	No Poll	76
1667	1899-10-23	W	HOME	17	267	17	0	No Poll	\N	No Poll	No Poll	56
1668	1899-10-28	W	HOME	17	104	12	0	No Poll	\N	No Poll	No Poll	90
1669	1899-11-04	W	HOME	17	467	17	0	No Poll	\N	No Poll	No Poll	110
1670	1899-11-18	T	AWAY	17	39	10	10	No Poll	\N	No Poll	No Poll	106
1671	1899-11-30	L	HOME	17	467	0	5	No Poll	\N	No Poll	No Poll	103
1672	1900-09-29	W	HOME	25	466	55	0	No Poll	\N	No Poll	No Poll	46
1673	1900-10-06	W	HOME	25	466	68	0	No Poll	\N	No Poll	No Poll	40
1674	1900-10-13	W	HOME	25	466	64	0	No Poll	\N	No Poll	No Poll	112
1675	1900-10-20	W	HOME	25	145	58	0	No Poll	\N	No Poll	No Poll	28
1676	1900-10-25	L	AWAY	25	267	0	6	No Poll	\N	No Poll	No Poll	56
1677	1900-11-03	T	HOME	25	303	6	6	No Poll	\N	No Poll	No Poll	13
1678	1900-11-10	L	AWAY	25	388	0	54	No Poll	\N	No Poll	No Poll	150
1679	1900-11-17	L	AWAY	25	330	0	7	No Poll	\N	No Poll	No Poll	76
1680	1900-11-24	W	HOME	25	467	5	0	No Poll	\N	No Poll	No Poll	110
1681	1900-11-29	W	HOME	25	467	5	0	No Poll	\N	No Poll	No Poll	103
1682	1901-09-28	T	HOME	25	466	0	0	No Poll	\N	No Poll	No Poll	116
1683	1901-10-05	W	AWAY	25	466	6	0	No Poll	\N	No Poll	No Poll	92
1684	1901-10-12	L	AWAY	25	104	0	2	No Poll	\N	No Poll	No Poll	90
1685	1901-10-19	W	HOME	25	467	32	0	No Poll	\N	No Poll	No Poll	25
1686	1901-10-26	W	AWAY	25	303	5	0	No Poll	\N	No Poll	No Poll	13
1687	1901-11-02	W	HOME	25	467	16	0	No Poll	\N	No Poll	No Poll	65
1688	1901-11-09	W	HOME	25	142	12	6	No Poll	\N	No Poll	No Poll	106
1689	1901-11-16	W	HOME	25	267	18	5	No Poll	\N	No Poll	No Poll	56
1690	1901-11-23	W	HOME	25	467	34	0	No Poll	\N	No Poll	No Poll	103
1691	1901-11-28	W	HOME	25	467	22	6	No Poll	\N	No Poll	No Poll	116
1692	1902-09-27	W	HOME	16	219	33	0	No Poll	\N	No Poll	No Poll	77
1693	1902-10-11	W	HOME	16	128	28	0	No Poll	\N	No Poll	No Poll	65
1694	1902-10-18	L	TOLEDO	16	187	0	23	No Poll	\N	No Poll	No Poll	76
1695	1902-10-25	W	AWAY	16	267	11	5	No Poll	\N	No Poll	No Poll	56
1696	1902-11-01	W	AWAY	16	467	6	5	No Poll	\N	No Poll	No Poll	92
1697	1902-11-08	L	AWAY	16	308	5	12	No Poll	\N	No Poll	No Poll	64
1698	1902-11-15	W	HOME	16	467	92	0	No Poll	\N	No Poll	No Poll	7
1699	1902-11-22	W	AWAY	16	264	22	0	No Poll	\N	No Poll	No Poll	36
1700	1902-11-27	T	AWAY	16	103	6	6	No Poll	\N	No Poll	No Poll	106
1701	1903-10-03	W	HOME	16	122	12	0	No Poll	\N	No Poll	No Poll	77
1702	1903-10-10	W	HOME	16	128	28	0	No Poll	\N	No Poll	No Poll	65
1703	1903-10-17	W	AWAY	16	121	56	0	No Poll	\N	No Poll	No Poll	36
1704	1903-10-24	W	HOME	16	467	52	0	No Poll	\N	No Poll	No Poll	7
1705	1903-10-29	W	HOME	16	467	46	0	No Poll	\N	No Poll	No Poll	26
1706	1903-11-07	W	HOME	16	467	28	0	No Poll	\N	No Poll	No Poll	63
1707	1903-11-14	T	AWAY	16	451	0	0	No Poll	\N	No Poll	No Poll	90
1708	1903-11-21	W	AWAY	16	467	35	0	No Poll	\N	No Poll	No Poll	92
1709	1903-11-26	W	AWAY	16	442	34	0	No Poll	\N	No Poll	No Poll	141
1710	1904-10-01	W	HOME	26	193	12	4	No Poll	\N	No Poll	No Poll	141
1711	1904-10-08	W	HOME	26	467	44	0	No Poll	\N	No Poll	No Poll	7
1712	1904-10-15	L	MILWAUKEE	26	42	0	58	No Poll	\N	No Poll	No Poll	150
1713	1904-10-22	W	AWAY	26	467	17	5	No Poll	\N	No Poll	No Poll	92
1714	1904-10-27	W	HOME	26	467	6	0	No Poll	\N	No Poll	No Poll	132
1715	1904-11-05	L	AWAY	26	50	5	24	No Poll	\N	No Poll	No Poll	62
1716	1904-11-19	W	HOME	26	431	10	0	No Poll	\N	No Poll	No Poll	36
1717	1904-11-24	L	AWAY	26	366	0	36	No Poll	\N	No Poll	No Poll	106
1718	1905-09-30	W	HOME	13	466	44	0	No Poll	\N	No Poll	No Poll	89
1719	1905-10-07	W	HOME	13	122	28	0	No Poll	\N	No Poll	No Poll	77
1720	1905-10-14	L	MILWAUKEE	13	388	0	21	No Poll	\N	No Poll	No Poll	150
1721	1905-10-21	L	HOME	13	193	0	5	No Poll	\N	No Poll	No Poll	141
1722	1905-10-28	W	HOME	13	467	142	0	No Poll	\N	No Poll	No Poll	7
1723	1905-11-04	W	HOME	13	365	71	0	No Poll	\N	No Poll	No Poll	36
1724	1905-11-11	L	AWAY	13	271	5	22	No Poll	\N	No Poll	No Poll	56
1725	1905-11-18	W	HOME	13	467	22	0	No Poll	\N	No Poll	No Poll	14
1726	1905-11-24	L	AWAY	13	31	0	32	No Poll	\N	No Poll	No Poll	106
1727	1906-10-06	W	HOME	28	467	26	0	No Poll	\N	No Poll	No Poll	43
1728	1906-10-13	W	HOME	28	460	17	0	No Poll	\N	No Poll	No Poll	52
1729	1906-10-17	W	HOME	28	122	5	0	No Poll	\N	No Poll	No Poll	77
1730	1906-10-20	W	HOME	28	467	28	0	No Poll	\N	No Poll	No Poll	26
1731	1906-11-03	W	AWAY	28	341	2	0	No Poll	\N	No Poll	No Poll	106
1732	1906-11-10	L	AWAY	28	271	0	12	No Poll	\N	No Poll	No Poll	56
1733	1906-11-24	W	HOME	28	115	29	0	No Poll	\N	No Poll	No Poll	13
1734	1907-10-12	W	HOME	28	467	32	0	No Poll	\N	No Poll	No Poll	26
1735	1907-10-19	W	HOME	28	32	23	0	No Poll	\N	No Poll	No Poll	43
1736	1907-10-26	W	HOME	28	99	22	4	No Poll	\N	No Poll	No Poll	97
1737	1907-11-02	T	HOME	28	271	0	0	No Poll	\N	No Poll	No Poll	56
1738	1907-11-09	W	HOME	28	244	22	4	No Poll	\N	No Poll	No Poll	64
1739	1907-11-23	W	AWAY	28	328	17	0	No Poll	\N	No Poll	No Poll	106
1740	1907-11-28	W	AWAY	28	467	21	12	No Poll	\N	No Poll	No Poll	124
1741	1908-10-03	W	HOME	30	249	39	0	No Poll	\N	No Poll	No Poll	52
1742	1908-10-10	W	HOME	30	467	64	0	No Poll	\N	No Poll	No Poll	43
1743	1908-10-17	L	AWAY	30	187	6	12	No Poll	\N	No Poll	No Poll	76
1744	1908-10-24	W	HOME	30	467	88	0	No Poll	\N	No Poll	No Poll	26
1745	1908-10-29	W	HOME	30	417	58	4	No Poll	\N	No Poll	No Poll	93
1746	1908-11-07	W	AWAY	30	271	11	0	No Poll	\N	No Poll	No Poll	56
1747	1908-11-13	W	AWAY	30	393	8	4	No Poll	\N	No Poll	No Poll	141
1748	1908-11-18	W	HOME	30	467	46	0	No Poll	\N	No Poll	No Poll	123
1749	1908-11-26	W	AWAY	30	462	6	0	No Poll	\N	No Poll	No Poll	71
1750	1909-10-09	W	HOME	10	247	58	0	No Poll	\N	No Poll	No Poll	97
1751	1909-10-16	W	HOME	10	251	60	11	No Poll	\N	No Poll	No Poll	108
1752	1909-10-23	W	HOME	10	122	17	0	No Poll	\N	No Poll	No Poll	77
1753	1909-10-30	W	FORBES FIELD	10	315	6	0	No Poll	\N	No Poll	No Poll	104
1754	1909-11-06	W	AWAY	10	187	11	3	No Poll	\N	No Poll	No Poll	76
1755	1909-11-13	W	HOME	10	242	46	0	No Poll	\N	No Poll	No Poll	75
1756	1909-11-20	W	HOME	10	19	38	0	No Poll	\N	No Poll	No Poll	141
1757	1909-11-25	T	AWAY	10	462	0	0	No Poll	\N	No Poll	No Poll	71
1758	1910-10-08	W	HOME	10	247	48	0	No Poll	\N	No Poll	No Poll	97
1759	1910-10-22	W	HOME	10	197	51	0	No Poll	\N	No Poll	No Poll	3
1760	1910-10-29	L	AWAY	10	122	0	17	No Poll	\N	No Poll	No Poll	77
1761	1910-11-12	W	AWAY	10	251	41	3	No Poll	\N	No Poll	No Poll	108
1762	1910-11-19	W	HOME	10	430	47	0	No Poll	\N	No Poll	No Poll	93
1763	1910-11-24	T	AWAY	10	462	5	5	No Poll	\N	No Poll	No Poll	71
1764	1911-10-07	W	HOME	21	342	32	6	No Poll	\N	No Poll	No Poll	93
1765	1911-10-14	W	HOME	21	467	43	0	No Poll	\N	No Poll	No Poll	123
1766	1911-10-21	W	HOME	21	467	27	0	No Poll	\N	No Poll	No Poll	17
1767	1911-10-28	W	HOME	21	467	80	0	No Poll	\N	No Poll	No Poll	68
1768	1911-11-04	T	FORBES FIELD	21	315	0	0	No Poll	\N	No Poll	No Poll	104
1769	1911-11-11	W	HOME	21	140	34	0	No Poll	\N	No Poll	No Poll	122
1770	1911-11-20	W	AWAY	21	19	6	3	No Poll	\N	No Poll	No Poll	141
1771	1911-11-30	T	AWAY	21	462	0	0	No Poll	\N	No Poll	No Poll	71
1772	1912-10-05	W	HOME	21	467	116	7	No Poll	\N	No Poll	No Poll	123
1773	1912-10-12	W	HOME	21	437	74	7	No Poll	\N	No Poll	No Poll	1
1774	1912-10-19	W	HOME	21	467	39	0	No Poll	\N	No Poll	No Poll	81
1775	1912-10-26	W	HOME	21	19	41	6	No Poll	\N	No Poll	No Poll	141
1776	1912-11-02	W	FORBES FIELD	21	315	3	0	No Poll	\N	No Poll	No Poll	104
1777	1912-11-09	W	AWAY	21	196	47	7	No Poll	\N	No Poll	No Poll	113
1778	1912-11-12	W	AWAY	21	102	69	0	No Poll	\N	No Poll	No Poll	71
1779	1913-10-04	W	HOME	19	106	87	0	No Poll	\N	No Poll	No Poll	93
1780	1913-10-18	W	HOME	19	265	20	7	No Poll	\N	No Poll	No Poll	119
1781	1913-10-25	W	HOME	19	448	62	0	No Poll	\N	No Poll	No Poll	6
1782	1913-11-01	W	AWAY	19	114	35	13	No Poll	\N	No Poll	No Poll	10
1783	1913-11-08	W	AWAY	19	61	14	7	No Poll	\N	No Poll	No Poll	101
1784	1913-11-22	W	AWAY	19	467	20	7	No Poll	\N	No Poll	No Poll	27
1785	1913-11-27	W	AWAY	19	152	30	7	No Poll	\N	No Poll	No Poll	129
1786	1914-10-03	W	HOME	19	448	56	0	No Poll	\N	No Poll	No Poll	6
1787	1914-10-10	W	HOME	19	250	103	0	No Poll	\N	No Poll	No Poll	109
1788	1914-10-17	L	AWAY	19	198	0	28	No Poll	\N	No Poll	No Poll	151
1789	1914-10-24	W	SIOUX FALLS	19	257	33	0	No Poll	\N	No Poll	No Poll	119
1790	1914-10-31	W	HOME	19	50	21	7	No Poll	\N	No Poll	No Poll	49
1791	1914-11-07	L	AWAY	19	114	7	20	No Poll	\N	No Poll	No Poll	10
1792	1914-11-14	W	CHICAGO	19	231	48	6	No Poll	\N	No Poll	No Poll	20
1793	1914-11-26	W	AWAY	19	199	20	0	No Poll	\N	No Poll	No Poll	126
1794	1915-10-02	W	HOME	19	448	32	0	No Poll	\N	No Poll	No Poll	6
1795	1915-10-09	W	HOME	19	50	34	0	No Poll	\N	No Poll	No Poll	49
1796	1915-10-23	L	AWAY	19	317	19	20	No Poll	\N	No Poll	No Poll	84
1797	1915-10-30	W	HOME	19	257	6	0	No Poll	\N	No Poll	No Poll	119
1798	1915-11-06	W	AWAY	19	114	7	0	No Poll	\N	No Poll	No Poll	10
1799	1915-11-13	W	AWAY	19	439	41	0	No Poll	\N	No Poll	No Poll	33
1800	1915-11-25	W	AWAY	19	152	36	7	No Poll	\N	No Poll	No Poll	129
1801	1915-11-27	W	AWAY	19	386	55	2	No Poll	\N	No Poll	No Poll	107
1802	1916-09-30	W	HOME	19	458	48	0	No Poll	\N	No Poll	No Poll	22
1803	1916-10-07	W	AWAY	19	453	48	0	No Poll	\N	No Poll	No Poll	149
1804	1916-10-14	W	HOME	19	50	25	0	No Poll	\N	No Poll	No Poll	49
1805	1916-10-28	W	HOME	19	380	60	0	No Poll	\N	No Poll	No Poll	141
1806	1916-11-04	L	AWAY	19	114	10	30	No Poll	\N	No Poll	No Poll	10
1807	1916-11-11	W	SIOUX FALLS	19	75	21	0	No Poll	\N	No Poll	No Poll	119
1808	1916-11-18	W	AWAY	19	201	14	0	No Poll	\N	No Poll	No Poll	77
1809	1916-11-25	W	HOME	19	448	46	0	No Poll	\N	No Poll	No Poll	6
1810	1916-11-30	W	AWAY	19	174	20	0	No Poll	\N	No Poll	No Poll	84
1811	1917-10-06	W	HOME	19	392	55	0	No Poll	\N	No Poll	No Poll	61
1812	1917-10-13	T	AWAY	19	312	0	0	No Poll	\N	No Poll	No Poll	150
1813	1917-10-20	L	AWAY	19	174	0	7	No Poll	\N	No Poll	No Poll	84
1814	1917-10-27	W	HOME	19	75	40	0	No Poll	\N	No Poll	No Poll	119
1815	1917-11-03	W	AWAY	19	215	7	2	No Poll	\N	No Poll	No Poll	10
1816	1917-11-10	W	AWAY	19	268	13	0	No Poll	\N	No Poll	No Poll	80
1817	1917-11-17	W	HOME	19	122	23	0	No Poll	\N	No Poll	No Poll	77
1818	1917-11-24	W	AWAY	19	418	3	0	No Poll	\N	No Poll	No Poll	144
1819	1918-09-28	W	AWAY	23	372	26	6	No Poll	\N	No Poll	No Poll	22
1820	1918-11-02	W	AWAY	23	409	67	7	No Poll	\N	No Poll	No Poll	141
1821	1918-11-09	T	HOME	23	129	7	7	No Poll	\N	No Poll	No Poll	47
1822	1918-11-16	L	AWAY	23	220	7	13	No Poll	\N	No Poll	No Poll	77
1823	1918-11-23	W	AWAY	23	101	26	6	No Poll	\N	No Poll	No Poll	106
1824	1918-11-28	T	AWAY	23	449	0	0	No Poll	\N	No Poll	No Poll	84
1825	1919-10-04	W	HOME	23	392	14	0	No Poll	\N	No Poll	No Poll	61
1826	1919-10-11	W	HOME	23	224	60	7	No Poll	\N	No Poll	No Poll	82
1827	1919-10-18	W	AWAY	23	238	14	9	No Poll	\N	No Poll	No Poll	84
1828	1919-10-25	W	HOME	23	463	53	0	No Poll	\N	No Poll	No Poll	148
1829	1919-11-01	W	INDIANAPOLIS	23	317	16	3	No Poll	\N	No Poll	No Poll	56
1830	1919-11-08	W	AWAY	23	114	12	9	No Poll	\N	No Poll	No Poll	10
1831	1919-11-15	W	HOME	23	122	13	0	No Poll	\N	No Poll	No Poll	77
1832	1919-11-22	W	AWAY	23	101	33	13	No Poll	\N	No Poll	No Poll	106
1833	1919-11-27	W	AWAY	23	268	14	6	No Poll	\N	No Poll	No Poll	80
1834	1920-10-02	W	HOME	23	392	39	0	No Poll	\N	No Poll	No Poll	61
1835	1920-10-09	W	HOME	23	463	42	0	No Poll	\N	No Poll	No Poll	148
1836	1920-10-16	W	AWAY	23	238	16	7	No Poll	\N	No Poll	No Poll	84
1837	1920-10-23	W	HOME	23	222	28	3	No Poll	\N	No Poll	No Poll	137
1838	1920-10-30	W	AWAY	23	114	27	17	No Poll	\N	No Poll	No Poll	10
1839	1920-11-06	W	HOME	23	101	28	0	No Poll	\N	No Poll	No Poll	106
1840	1920-11-13	W	AWAY	23	317	13	10	No Poll	\N	No Poll	No Poll	56
1841	1920-11-20	W	AWAY	23	185	33	7	No Poll	\N	No Poll	No Poll	90
1842	1920-11-25	W	AWAY	23	218	25	0	No Poll	\N	No Poll	No Poll	77
1843	1921-09-24	W	HOME	23	392	56	0	No Poll	\N	No Poll	No Poll	61
1844	1921-10-01	W	HOME	23	206	57	10	No Poll	\N	No Poll	No Poll	36
1845	1921-10-08	L	AWAY	23	254	7	10	No Poll	\N	No Poll	No Poll	58
1846	1921-10-15	W	AWAY	23	461	33	0	No Poll	\N	No Poll	No Poll	106
1847	1921-10-22	W	HOME	23	205	7	0	No Poll	\N	No Poll	No Poll	84
1848	1921-10-29	W	AWAY	23	317	28	7	No Poll	\N	No Poll	No Poll	56
1849	1921-11-05	W	AWAY	23	114	28	0	No Poll	\N	No Poll	No Poll	10
1850	1921-11-08	W	POLO GROUNDS	23	227	48	0	No Poll	\N	No Poll	No Poll	111
1851	1921-11-12	W	HOME	23	352	42	7	No Poll	\N	No Poll	No Poll	49
1852	1921-11-19	W	AWAY	23	262	21	7	No Poll	\N	No Poll	No Poll	71
1853	1921-11-24	W	HOME	23	37	48	0	No Poll	\N	No Poll	No Poll	77
1854	1922-09-30	W	HOME	23	392	46	0	No Poll	\N	No Poll	No Poll	61
1855	1922-10-07	W	HOME	23	419	26	0	No Poll	\N	No Poll	No Poll	113
1856	1922-10-14	W	AWAY	23	270	20	0	No Poll	\N	No Poll	No Poll	106
1857	1922-10-21	W	HOME	23	269	34	7	No Poll	\N	No Poll	No Poll	36
1858	1922-10-28	W	AWAY	23	459	13	3	No Poll	\N	No Poll	No Poll	45
1859	1922-11-04	W	HOME	23	266	27	0	No Poll	\N	No Poll	No Poll	56
1860	1922-11-11	T	AWAY	23	114	0	0	No Poll	\N	No Poll	No Poll	10
1861	1922-11-18	W	AWAY	23	241	31	3	No Poll	\N	No Poll	No Poll	17
1862	1922-11-25	W	AWAY	23	454	19	0	No Poll	\N	No Poll	No Poll	21
1863	1922-11-30	L	AWAY	23	205	6	14	No Poll	\N	No Poll	No Poll	84
1864	1923-09-29	W	HOME	23	353	74	0	No Poll	\N	No Poll	No Poll	61
1865	1923-10-06	W	HOME	23	466	14	0	No Poll	\N	No Poll	No Poll	66
1866	1923-10-13	W	EBBETS FIELD	23	306	13	0	No Poll	\N	No Poll	No Poll	10
1867	1923-10-20	W	AWAY	23	69	25	2	No Poll	\N	No Poll	No Poll	105
1868	1923-10-27	W	HOME	23	459	35	7	No Poll	\N	No Poll	No Poll	45
1869	1923-11-03	W	HOME	23	270	34	7	No Poll	\N	No Poll	No Poll	106
1870	1923-11-10	L	AWAY	23	205	7	14	No Poll	\N	No Poll	No Poll	84
1871	1923-11-17	W	HOME	23	241	34	7	No Poll	\N	No Poll	No Poll	17
1872	1923-11-24	W	AWAY	23	454	26	0	No Poll	\N	No Poll	No Poll	21
1873	1923-11-29	W	AWAY	23	146	13	0	No Poll	\N	No Poll	No Poll	113
1874	1924-10-04	W	HOME	23	466	40	0	No Poll	\N	No Poll	No Poll	66
1875	1924-10-11	W	HOME	23	385	34	0	No Poll	\N	No Poll	No Poll	141
1876	1924-10-18	W	POLO GROUNDS	23	306	13	7	No Poll	\N	No Poll	No Poll	10
1877	1924-10-25	W	AWAY	23	69	12	0	No Poll	\N	No Poll	No Poll	105
1878	1924-11-01	W	HOME	23	459	34	3	No Poll	\N	No Poll	No Poll	45
1879	1924-11-08	W	AWAY	23	262	38	3	No Poll	\N	No Poll	No Poll	150
1880	1924-11-15	W	HOME	23	205	34	6	No Poll	\N	No Poll	No Poll	84
1881	1924-11-22	W	SOLDIER FIELD	23	232	13	6	No Poll	\N	No Poll	No Poll	90
1882	1924-11-29	W	FORBES FIELD	23	454	40	19	No Poll	\N	No Poll	No Poll	21
1883	1925-01-01	W	ROSE BOWL	23	231	27	10	No Poll	\N	No Poll	No Poll	125
1884	1925-09-26	W	HOME	23	195	41	0	No Poll	\N	No Poll	No Poll	12
1885	1925-10-03	W	HOME	23	467	69	0	No Poll	\N	No Poll	No Poll	66
1886	1925-10-10	W	HOME	23	439	19	3	No Poll	\N	No Poll	No Poll	13
1887	1925-10-17	L	YANKEE STADIUM	23	306	0	27	No Poll	\N	No Poll	No Poll	10
1888	1925-10-24	W	AWAY	23	130	19	7	No Poll	\N	No Poll	No Poll	78
1889	1925-10-31	W	AWAY	23	459	13	0	No Poll	\N	No Poll	No Poll	45
1890	1925-11-07	T	AWAY	23	256	0	0	No Poll	\N	No Poll	No Poll	101
1891	1925-11-14	W	HOME	23	454	26	0	No Poll	\N	No Poll	No Poll	21
1892	1925-11-21	W	HOME	23	232	13	10	No Poll	\N	No Poll	No Poll	90
1893	1925-11-26	L	AWAY	23	173	0	17	No Poll	\N	No Poll	No Poll	84
1894	1926-10-02	W	HOME	23	408	77	0	No Poll	\N	No Poll	No Poll	13
1895	1926-10-09	W	AWAY	23	130	20	7	No Poll	\N	No Poll	No Poll	78
1896	1926-10-16	W	HOME	23	256	28	0	No Poll	\N	No Poll	No Poll	101
1897	1926-10-23	W	AWAY	23	232	6	0	No Poll	\N	No Poll	No Poll	90
1898	1926-10-30	W	HOME	23	459	12	0	No Poll	\N	No Poll	No Poll	45
1899	1926-11-06	W	HOME	23	241	26	0	No Poll	\N	No Poll	No Poll	56
1900	1926-11-13	W	YANKEE STADIUM	23	51	7	0	No Poll	\N	No Poll	No Poll	10
1901	1926-11-20	W	HOME	23	368	21	0	No Poll	\N	No Poll	No Poll	38
1902	1926-11-27	L	FORBES FIELD	23	454	0	19	No Poll	\N	No Poll	No Poll	21
1903	1926-12-04	W	AWAY	23	254	13	12	No Poll	\N	No Poll	No Poll	121
1904	1927-10-01	W	HOME	23	361	28	7	No Poll	\N	No Poll	No Poll	30
1905	1927-10-08	W	AWAY	23	112	20	0	No Poll	\N	No Poll	No Poll	37
1906	1927-10-15	W	AWAY	23	62	19	6	No Poll	\N	No Poll	No Poll	83
1907	1927-10-22	W	AWAY	23	241	19	6	No Poll	\N	No Poll	No Poll	56
1908	1927-10-29	W	HOME	23	459	26	7	No Poll	\N	No Poll	No Poll	45
1909	1927-11-05	T	HOME	23	130	7	7	No Poll	\N	No Poll	No Poll	78
1910	1927-11-12	L	YANKEE STADIUM	23	51	0	18	No Poll	\N	No Poll	No Poll	10
1911	1927-11-19	W	AWAY	23	368	32	0	No Poll	\N	No Poll	No Poll	38
1912	1927-11-26	W	SOLDIER FIELD	23	254	7	6	No Poll	\N	No Poll	No Poll	121
1913	1928-09-29	W	HOME	23	131	12	6	No Poll	\N	No Poll	No Poll	69
1914	1928-10-06	L	AWAY	23	232	6	22	No Poll	\N	No Poll	No Poll	150
1915	1928-10-13	W	SOLDIER FIELD	23	62	7	0	No Poll	\N	No Poll	No Poll	83
1916	1928-10-20	L	AWAY	23	459	0	13	No Poll	\N	No Poll	No Poll	45
1917	1928-10-27	W	HOME	23	368	32	6	No Poll	\N	No Poll	No Poll	38
1918	1928-11-03	W	PHILADELPHIA	23	256	9	0	No Poll	\N	No Poll	No Poll	101
1919	1928-11-10	W	YANKEE STADIUM	23	51	12	6	No Poll	\N	No Poll	No Poll	10
1920	1928-11-17	L	HOME	23	454	7	27	No Poll	\N	No Poll	No Poll	21
1921	1928-12-01	L	AWAY	23	254	14	27	No Poll	\N	No Poll	No Poll	121
1922	1929-10-05	W	AWAY	23	241	14	0	No Poll	\N	No Poll	No Poll	56
1923	1929-10-12	W	AWAY	23	62	14	7	No Poll	\N	No Poll	No Poll	83
1924	1929-10-19	W	SOLDIER FIELD	23	232	19	0	No Poll	\N	No Poll	No Poll	150
1925	1929-10-26	W	AWAY	23	454	7	0	No Poll	\N	No Poll	No Poll	21
1926	1929-11-02	W	AWAY	23	459	26	6	No Poll	\N	No Poll	No Poll	45
1927	1929-11-09	W	SOLDIER FIELD	23	368	19	7	No Poll	\N	No Poll	No Poll	38
1928	1929-11-16	W	SOLDIER FIELD	23	254	13	12	No Poll	\N	No Poll	No Poll	121
1929	1929-11-23	W	AWAY	23	165	26	6	No Poll	\N	No Poll	No Poll	90
1930	1929-11-30	W	YANKEE STADIUM	23	51	7	0	No Poll	\N	No Poll	No Poll	10
1931	1930-10-04	W	HOME	23	397	20	14	No Poll	\N	No Poll	No Poll	115
1932	1930-10-11	W	HOME	23	62	26	2	No Poll	\N	No Poll	No Poll	83
1933	1930-10-18	W	HOME	23	454	21	6	No Poll	\N	No Poll	No Poll	21
1934	1930-10-25	W	AWAY	23	297	35	19	No Poll	\N	No Poll	No Poll	104
1935	1930-11-01	W	HOME	23	241	27	0	No Poll	\N	No Poll	No Poll	56
1936	1930-11-08	W	AWAY	23	340	60	20	No Poll	\N	No Poll	No Poll	102
1937	1930-11-15	W	HOME	23	368	28	7	No Poll	\N	No Poll	No Poll	38
1938	1930-11-22	W	AWAY	23	165	14	0	No Poll	\N	No Poll	No Poll	90
1939	1930-11-29	W	SOLDIER FIELD	23	394	7	6	No Poll	\N	No Poll	No Poll	10
1940	1930-12-06	W	AWAY	23	254	27	0	No Poll	\N	No Poll	No Poll	121
1941	1931-10-03	W	AWAY	15	177	25	0	No Poll	\N	No Poll	No Poll	56
1942	1931-10-10	T	SOLDIER FIELD	15	165	0	0	No Poll	\N	No Poll	No Poll	90
1943	1931-10-17	W	HOME	15	368	63	0	No Poll	\N	No Poll	No Poll	38
1944	1931-10-24	W	HOME	15	297	25	12	No Poll	\N	No Poll	No Poll	104
1945	1931-10-31	W	AWAY	15	454	19	0	No Poll	\N	No Poll	No Poll	21
1946	1931-11-07	W	HOME	15	245	49	0	No Poll	\N	No Poll	No Poll	102
1947	1931-11-14	W	AWAY	15	406	20	0	No Poll	\N	No Poll	No Poll	83
1948	1931-11-21	L	HOME	15	254	14	16	No Poll	\N	No Poll	No Poll	121
1949	1931-11-28	L	YANKEE STADIUM	15	394	0	12	No Poll	\N	No Poll	No Poll	10
1950	1932-10-08	W	HOME	15	461	73	0	No Poll	\N	No Poll	No Poll	49
1951	1932-10-15	W	HOME	15	186	62	0	No Poll	\N	No Poll	No Poll	38
1952	1932-10-22	W	HOME	15	454	42	0	No Poll	\N	No Poll	No Poll	21
1953	1932-10-29	L	AWAY	15	297	0	12	No Poll	\N	No Poll	No Poll	104
1954	1932-11-05	W	AWAY	15	60	24	6	No Poll	\N	No Poll	No Poll	62
1955	1932-11-12	W	HOME	15	165	21	0	No Poll	\N	No Poll	No Poll	90
1956	1932-11-19	W	AWAY	15	406	12	0	No Poll	\N	No Poll	No Poll	83
1957	1932-11-26	W	YANKEE STADIUM	15	394	21	0	No Poll	\N	No Poll	No Poll	10
1958	1932-12-10	L	AWAY	15	254	0	13	No Poll	\N	No Poll	No Poll	121
1959	1933-10-07	T	HOME	15	33	0	0	No Poll	\N	No Poll	No Poll	62
1960	1933-10-14	W	AWAY	15	177	12	2	No Poll	\N	No Poll	No Poll	56
1961	1933-10-21	L	AWAY	15	253	0	7	No Poll	\N	No Poll	No Poll	21
1962	1933-10-28	L	HOME	15	297	0	14	No Poll	\N	No Poll	No Poll	104
1963	1933-11-04	L	AWAY	15	406	0	7	No Poll	\N	No Poll	No Poll	83
1964	1933-11-11	L	HOME	15	364	0	19	No Poll	\N	No Poll	No Poll	106
1965	1933-11-18	W	AWAY	15	165	7	0	No Poll	\N	No Poll	No Poll	90
1966	1933-11-25	L	HOME	15	254	0	19	No Poll	\N	No Poll	No Poll	121
1967	1933-12-02	W	YANKEE STADIUM	15	209	13	12	No Poll	\N	No Poll	No Poll	10
1968	1934-10-06	L	HOME	7	259	6	7	No Poll	\N	No Poll	No Poll	129
1969	1934-10-13	W	HOME	7	364	18	7	No Poll	\N	No Poll	No Poll	106
1970	1934-10-20	W	HOME	7	253	13	0	No Poll	\N	No Poll	No Poll	21
1971	1934-10-27	W	HOME	7	130	19	0	No Poll	\N	No Poll	No Poll	150
1972	1934-11-03	L	AWAY	7	297	0	19	No Poll	\N	No Poll	No Poll	104
1973	1934-11-10	L	AWAY	7	435	6	10	No Poll	\N	No Poll	No Poll	83
1974	1934-11-17	W	AWAY	7	165	20	7	No Poll	\N	No Poll	No Poll	90
1975	1934-11-24	W	YANKEE STADIUM	7	209	12	6	No Poll	\N	No Poll	No Poll	10
1976	1934-12-08	W	AWAY	7	254	14	0	No Poll	\N	No Poll	No Poll	121
1977	1935-09-28	W	HOME	7	33	28	7	No Poll	\N	No Poll	No Poll	62
1978	1935-10-05	W	AWAY	7	253	14	3	No Poll	\N	No Poll	No Poll	21
1979	1935-10-12	W	AWAY	7	130	27	0	No Poll	\N	No Poll	No Poll	150
1980	1935-10-19	W	AWAY	7	297	9	6	No Poll	\N	No Poll	No Poll	104
1981	1935-10-26	W	AWAY	7	435	14	0	No Poll	\N	No Poll	No Poll	83
1982	1935-11-02	W	AWAY	7	194	18	13	No Poll	\N	No Poll	No Poll	94
1983	1935-11-09	L	HOME	7	369	7	14	No Poll	\N	No Poll	No Poll	90
1984	1935-11-16	T	YANKEE STADIUM	7	209	6	6	No Poll	\N	No Poll	No Poll	10
1985	1935-11-23	W	HOME	7	254	20	13	No Poll	\N	No Poll	No Poll	121
1986	1936-10-03	W	HOME	7	253	21	7	UNRANKED	\N	UNRANKED	UNRANKED	21
1987	1936-10-10	W	HOME	7	295	14	6	UNRANKED	\N	UNRANKED	UNRANKED	146
1988	1936-10-17	W	HOME	7	243	27	0	UNRANKED	\N	UNRANKED	UNRANKED	150
1989	1936-10-24	L	AWAY	7	297	0	26	7	\N	9	3	104
1990	1936-10-31	W	HOME	7	194	7	2	UNRANKED	\N	UNRANKED	UNRANKED	94
1991	1936-11-07	L	AWAY	7	435	0	3	13	\N	UNRANKED	18	83
1992	1936-11-14	W	YANKEE STADIUM	7	209	20	6	UNRANKED	\N	UNRANKED	UNRANKED	10
1993	1936-11-21	W	HOME	7	369	26	6	11	\N	1	7	90
1994	1936-12-05	T	AWAY	7	254	13	13	9	\N	UNRANKED	UNRANKED	121
1995	1937-10-02	W	HOME	7	445	21	0	UNRANKED	\N	UNRANKED	UNRANKED	38
1996	1937-10-09	T	AWAY	7	85	0	0	UNRANKED	\N	UNRANKED	UNRANKED	54
1997	1937-10-16	L	AWAY	7	63	7	9	UNRANKED	\N	UNRANKED	UNRANKED	21
1998	1937-10-23	W	HOME	7	240	9	7	UNRANKED	\N	UNRANKED	UNRANKED	83
1999	1937-10-30	W	AWAY	7	47	7	6	UNRANKED	\N	4	5	78
2000	1937-11-06	L	HOME	7	297	6	21	12	\N	3	1	104
2001	1937-11-13	W	YANKEE STADIUM	7	209	7	0	18	\N	UNRANKED	UNRANKED	10
2002	1937-11-20	W	AWAY	7	369	7	0	12	\N	UNRANKED	UNRANKED	90
2003	1937-11-27	W	HOME	7	254	13	6	9	\N	UNRANKED	UNRANKED	121
2004	1938-10-01	W	HOME	7	33	52	0	UNRANKED	\N	UNRANKED	UNRANKED	62
2005	1938-10-08	W	AWAY	7	459	14	6	UNRANKED	\N	UNRANKED	UNRANKED	45
2006	1938-10-15	W	HOME	7	85	14	6	UNRANKED	\N	UNRANKED	UNRANKED	54
2007	1938-10-22	W	HOME	7	63	7	0	5	\N	13	6	21
2008	1938-10-29	W	YANKEE STADIUM	7	464	19	7	7	\N	UNRANKED	UNRANKED	10
2009	1938-11-05	W	AWAY	7	240	15	0	4	\N	UNRANKED	UNRANKED	83
2010	1938-11-12	W	HOME	7	47	19	0	2	\N	12	10	78
2011	1938-11-19	W	AWAY	7	369	9	7	1	\N	16	17	90
2012	1938-12-03	L	AWAY	7	254	0	13	1	\N	8	7	121
2013	1939-09-30	W	HOME	7	344	3	0	UNRANKED	\N	UNRANKED	UNRANKED	106
2014	1939-10-07	W	HOME	7	459	17	14	UNRANKED	\N	UNRANKED	16	45
2015	1939-10-14	W	HOME	7	352	20	19	UNRANKED	\N	UNRANKED	UNRANKED	115
2016	1939-10-21	W	AWAY	7	425	14	7	2	\N	UNRANKED	UNRANKED	83
2017	1939-10-28	W	AWAY	7	63	7	6	2	\N	UNRANKED	UNRANKED	21
2018	1939-11-04	W	YANKEE STADIUM	7	464	14	0	4	\N	UNRANKED	UNRANKED	10
2019	1939-11-11	L	YANKEE STADIUM	7	181	6	7	3	\N	UNRANKED	9	58
2020	1939-11-18	W	HOME	7	369	7	0	9	\N	UNRANKED	UNRANKED	90
2021	1939-11-25	L	HOME	7	254	12	20	7	\N	4	3	121
2022	1940-10-05	W	HOME	7	40	25	7	UNRANKED	\N	UNRANKED	UNRANKED	100
2023	1940-10-12	W	HOME	7	459	26	20	UNRANKED	\N	UNRANKED	UNRANKED	45
2024	1940-10-19	W	HOME	7	183	61	0	6	\N	UNRANKED	UNRANKED	21
2025	1940-10-26	W	AWAY	7	85	26	0	2	\N	UNRANKED	UNRANKED	54
2026	1940-11-02	W	YANKEE STADIUM	7	464	7	0	2	\N	UNRANKED	UNRANKED	10
2027	1940-11-09	W	AWAY	7	425	13	7	7	\N	UNRANKED	UNRANKED	83
2028	1940-11-16	L	HOME	7	181	0	7	7	\N	UNRANKED	UNRANKED	58
2029	1940-11-23	L	AWAY	7	369	0	20	14	\N	10	8	90
2030	1940-12-07	W	AWAY	7	254	10	6	UNRANKED	\N	UNRANKED	UNRANKED	121
2031	1941-09-27	W	HOME	9	359	38	7	UNRANKED	\N	UNRANKED	UNRANKED	8
2032	1941-10-04	W	HOME	9	76	19	6	UNRANKED	\N	UNRANKED	UNRANKED	56
2033	1941-10-11	W	AWAY	9	459	20	0	UNRANKED	\N	UNRANKED	UNRANKED	45
2034	1941-10-18	W	AWAY	9	183	16	0	8	\N	UNRANKED	UNRANKED	21
2035	1941-10-25	W	HOME	9	85	49	14	7	\N	UNRANKED	UNRANKED	54
2036	1941-11-01	T	YANKEE STADIUM	9	175	0	0	6	\N	14	UNRANKED	10
2037	1941-11-08	W	AWAY	9	425	20	13	7	\N	6	10	83
2038	1941-11-15	W	AWAY	9	369	7	6	5	\N	8	11	90
2039	1941-11-22	W	HOME	9	411	20	18	4	\N	UNRANKED	UNRANKED	121
2040	1942-09-26	T	AWAY	9	243	7	7	UNRANKED	\N	UNRANKED	3	150
2041	1942-10-03	L	HOME	9	459	6	13	UNRANKED	\N	UNRANKED	5	45
2042	1942-10-10	W	HOME	9	345	27	0	UNRANKED	\N	UNRANKED	12	125
2043	1942-10-17	W	HOME	9	47	28	0	UNRANKED	\N	UNRANKED	UNRANKED	59
2044	1942-10-24	W	AWAY	9	396	21	14	8	\N	5	UNRANKED	54
2045	1942-10-31	W	AWAY	9	72	9	0	4	\N	UNRANKED	UNRANKED	83
2046	1942-11-07	W	YANKEE STADIUM	9	175	13	0	4	\N	19	UNRANKED	10
2047	1942-11-14	L	HOME	9	208	20	32	4	\N	6	9	76
2048	1942-11-21	W	HOME	9	369	27	20	8	\N	UNRANKED	UNRANKED	90
2049	1942-11-28	W	AWAY	9	272	13	0	8	\N	14	UNRANKED	121
2050	1942-12-05	T	AWAY	9	440	13	13	8	\N	UNRANKED	UNRANKED	47
2051	1943-09-25	W	AWAY	9	131	41	0	UNRANKED	\N	UNRANKED	UNRANKED	104
2052	1943-10-02	W	HOME	9	459	55	13	UNRANKED	\N	UNRANKED	13	45
2053	1943-10-09	W	AWAY	9	208	35	12	1	\N	2	3	76
2054	1943-10-16	W	AWAY	9	243	50	0	1	\N	UNRANKED	UNRANKED	150
2055	1943-10-23	W	HOME	9	396	47	0	1	\N	UNRANKED	UNRANKED	54
2056	1943-10-30	W	CLEVELAND	9	72	33	6	1	\N	3	4	83
2057	1943-11-06	W	YANKEE STADIUM	9	175	26	0	1	\N	3	11	10
2058	1943-11-13	W	AWAY	9	369	25	6	1	\N	8	9	90
2059	1943-11-20	W	HOME	9	168	14	13	1	\N	2	2	59
2060	1943-11-27	L	AWAY	9	440	14	19	1	\N	UNRANKED	6	47
2061	1944-09-30	W	AWAY	6	131	58	0	UNRANKED	\N	UNRANKED	UNRANKED	104
2062	1944-10-07	W	HOME	6	132	26	0	UNRANKED	\N	UNRANKED	UNRANKED	133
2063	1944-10-14	W	FENWAY PARK	6	176	64	0	1	\N	UNRANKED	UNRANKED	34
2064	1944-10-21	W	HOME	6	243	28	13	1	\N	UNRANKED	UNRANKED	150
2065	1944-10-28	W	HOME	6	396	13	7	1	\N	14	15	54
2066	1944-11-04	L	AWAY	6	367	13	32	2	\N	6	4	83
2067	1944-11-11	L	YANKEE STADIUM	6	175	0	59	5	\N	1	1	10
2068	1944-11-18	W	HOME	6	369	21	0	11	\N	UNRANKED	UNRANKED	90
2069	1944-11-25	W	AWAY	6	459	21	0	18	\N	10	13	45
2070	1944-12-02	W	HOME	6	374	28	7	9	\N	12	17	47
2071	1945-09-29	W	HOME	14	396	7	0	UNRANKED	\N	UNRANKED	UNRANKED	54
2072	1945-10-06	W	AWAY	14	88	40	7	UNRANKED	\N	UNRANKED	UNRANKED	45
2073	1945-10-13	W	HOME	14	443	34	0	3	\N	UNRANKED	UNRANKED	34
2074	1945-10-20	W	AWAY	14	131	39	9	3	\N	UNRANKED	UNRANKED	104
2075	1945-10-27	W	HOME	14	134	56	0	2	\N	UNRANKED	UNRANKED	58
2076	1945-11-03	T	AWAY	14	367	6	6	2	\N	3	3	83
2077	1945-11-10	L	YANKEE STADIUM	14	175	0	48	2	\N	1	1	10
2078	1945-11-17	W	AWAY	14	369	34	7	7	\N	UNRANKED	UNRANKED	90
2079	1945-11-24	W	AWAY	14	132	32	6	5	\N	UNRANKED	UNRANKED	133
2080	1945-12-01	L	AWAY	14	374	7	39	5	\N	UNRANKED	UNRANKED	47
2081	1946-09-28	W	AWAY	9	396	26	6	UNRANKED	\N	UNRANKED	5	54
2082	1946-10-05	W	HOME	9	457	33	0	UNRANKED	\N	UNRANKED	UNRANKED	104
2083	1946-10-12	W	HOME	9	109	49	6	3	\N	UNRANKED	UNRANKED	106
2084	1946-10-26	W	AWAY	9	181	41	6	2	\N	17	UNRANKED	58
2085	1946-11-02	W	AWAY	9	435	28	0	2	\N	UNRANKED	UNRANKED	83
2086	1946-11-09	T	YANKEE STADIUM	9	175	0	0	2	\N	1	2	10
2087	1946-11-16	W	HOME	9	369	27	0	2	\N	UNRANKED	UNRANKED	90
2088	1946-11-23	W	AWAY	9	246	41	0	2	\N	UNRANKED	UNRANKED	133
2089	1946-11-30	W	HOME	9	272	26	6	2	\N	16	UNRANKED	121
2090	1947-10-04	W	AWAY	9	452	40	6	UNRANKED	\N	UNRANKED	UNRANKED	104
2091	1947-10-11	W	AWAY	9	424	22	7	1	\N	UNRANKED	UNRANKED	106
2092	1947-10-18	W	HOME	9	49	31	0	2	\N	UNRANKED	UNRANKED	84
2093	1947-10-25	W	HOME	9	181	21	0	2	\N	UNRANKED	UNRANKED	58
2094	1947-11-01	W	CLEVELAND	9	435	27	0	1	\N	UNRANKED	UNRANKED	83
2095	1947-11-08	W	HOME	9	175	27	7	1	\N	9	11	10
2096	1947-11-15	W	AWAY	9	83	26	19	1	\N	UNRANKED	UNRANKED	90
2097	1947-11-22	W	HOME	9	246	59	6	2	\N	UNRANKED	UNRANKED	133
2098	1947-12-06	W	AWAY	9	272	38	7	1	\N	3	8	121
2099	1948-09-25	W	HOME	9	424	28	27	UNRANKED	\N	UNRANKED	UNRANKED	106
2100	1948-10-02	W	AWAY	9	452	40	0	UNRANKED	\N	UNRANKED	UNRANKED	104
2101	1948-10-09	W	HOME	9	52	26	7	1	\N	UNRANKED	14	77
2102	1948-10-16	W	AWAY	9	218	44	13	2	\N	UNRANKED	UNRANKED	84
2103	1948-10-23	W	AWAY	9	181	27	12	2	\N	UNRANKED	UNRANKED	58
2104	1948-10-30	W	AWAY	9	228	41	7	2	\N	UNRANKED	UNRANKED	83
2105	1948-11-06	W	AWAY	9	135	42	6	1	\N	UNRANKED	UNRANKED	56
2106	1948-11-13	W	HOME	9	83	12	7	2	\N	8	7	90
2107	1948-11-27	W	HOME	9	255	46	0	2	\N	UNRANKED	UNRANKED	143
2108	1948-12-04	T	AWAY	9	272	14	14	2	\N	UNRANKED	UNRANKED	121
2109	1949-09-24	W	HOME	9	135	49	6	UNRANKED	\N	UNRANKED	UNRANKED	56
2110	1949-10-01	W	AWAY	9	255	27	7	UNRANKED	\N	UNRANKED	UNRANKED	143
2111	1949-10-08	W	AWAY	9	424	35	12	2	\N	UNRANKED	UNRANKED	106
2112	1949-10-15	W	HOME	9	246	46	7	1	\N	4	UNRANKED	133
2113	1949-10-29	W	AWAY	9	228	40	0	1	\N	UNRANKED	UNRANKED	83
2114	1949-11-05	W	AWAY	9	52	34	21	1	\N	10	19	77
2115	1949-11-12	W	YANKEE STADIUM	9	108	42	6	1	\N	UNRANKED	16	87
2116	1949-11-19	W	HOME	9	181	28	7	1	\N	UNRANKED	UNRANKED	58
2117	1949-11-26	W	HOME	9	272	32	0	1	\N	17	UNRANKED	121
2118	1949-12-03	W	COTTON BOWL	9	352	27	20	1	\N	UNRANKED	UNRANKED	115
2119	1950-09-30	W	HOME	9	108	14	7	1	\N	20	UNRANKED	87
2120	1950-10-07	L	HOME	9	424	14	28	1	\N	UNRANKED	UNRANKED	106
2121	1950-10-14	W	AWAY	9	246	13	9	10	\N	UNRANKED	20	133
2122	1950-10-21	L	AWAY	9	135	7	20	11	\N	UNRANKED	UNRANKED	56
2123	1950-10-28	L	HOME	9	52	33	36	UNRANKED	\N	15	8	77
2124	1950-11-04	W	AWAY	9	182	19	10	UNRANKED	\N	UNRANKED	UNRANKED	83
2125	1950-11-11	W	HOME	9	334	18	7	UNRANKED	\N	UNRANKED	UNRANKED	104
2126	1950-11-18	T	AWAY	9	327	14	14	UNRANKED	\N	UNRANKED	UNRANKED	58
2127	1950-12-02	L	AWAY	9	272	7	9	UNRANKED	\N	UNRANKED	UNRANKED	121
2128	1951-09-29	W	HOME	9	135	48	6	14	\N	UNRANKED	UNRANKED	56
2129	1951-10-05	W	BRIGGS STADIUM	9	172	40	6	5	\N	UNRANKED	UNRANKED	37
2130	1951-10-13	L	HOME	9	239	20	27	5	\N	UNRANKED	UNRANKED	115
2131	1951-10-20	W	AWAY	9	435	33	0	UNRANKED	\N	UNRANKED	UNRANKED	104
2132	1951-10-27	W	HOME	9	424	30	9	15	\N	UNRANKED	UNRANKED	106
2133	1951-11-03	W	AWAY	9	182	19	0	13	\N	UNRANKED	UNRANKED	83
2134	1951-11-10	L	AWAY	9	52	0	35	11	\N	5	2	77
2135	1951-11-17	W	AWAY	9	108	12	7	UNRANKED	\N	UNRANKED	UNRANKED	87
2136	1951-11-24	T	HOME	9	327	20	20	UNRANKED	\N	UNRANKED	UNRANKED	58
2137	1951-12-01	W	AWAY	9	281	19	12	UNRANKED	\N	20	UNRANKED	121
2138	1952-09-27	T	AWAY	9	223	7	7	10	\N	12	UNRANKED	102
2139	1952-10-04	W	AWAY	9	180	14	3	19	\N	5	10	129
2140	1952-10-11	L	HOME	9	339	19	22	8	\N	UNRANKED	UNRANKED	104
2141	1952-10-18	W	AWAY	9	424	26	14	UNRANKED	\N	9	18	106
2142	1952-10-25	W	HOME	9	108	34	14	16	\N	UNRANKED	UNRANKED	87
2143	1952-11-01	W	AWAY	9	182	17	6	13	\N	UNRANKED	UNRANKED	83
2144	1952-11-08	W	HOME	9	97	27	21	10	\N	4	4	95
2145	1952-11-15	L	AWAY	9	52	3	21	6	\N	1	1	77
2146	1952-11-22	W	AWAY	9	190	27	0	9	\N	UNRANKED	UNRANKED	58
2147	1952-11-29	W	HOME	9	281	9	0	7	\N	2	5	121
2148	1953-09-26	W	AWAY	9	97	28	21	1	\N	6	4	95
2149	1953-10-03	W	AWAY	9	424	37	7	1	\N	UNRANKED	UNRANKED	106
2150	1953-10-17	W	HOME	9	339	23	14	1	\N	15	UNRANKED	104
2151	1953-10-24	W	HOME	9	88	27	14	1	\N	4	8	45
2152	1953-10-31	W	HOME	9	182	38	7	1	\N	20	UNRANKED	83
2153	1953-11-07	W	AWAY	9	223	28	20	1	\N	UNRANKED	UNRANKED	102
2154	1953-11-14	W	AWAY	9	216	34	14	1	\N	UNRANKED	UNRANKED	87
2155	1953-11-21	T	HOME	9	190	14	14	1	\N	20	9	58
2156	1953-11-28	W	AWAY	9	281	48	14	2	\N	20	UNRANKED	121
2157	1953-12-05	W	HOME	9	110	40	14	2	\N	UNRANKED	UNRANKED	115
2158	1954-09-25	W	HOME	27	180	21	0	2	\N	4	UNRANKED	129
2159	1954-10-02	L	HOME	27	424	14	27	1	\N	19	UNRANKED	106
2160	1954-10-09	W	AWAY	27	339	33	0	8	\N	UNRANKED	UNRANKED	104
2161	1954-10-16	W	HOME	27	171	20	19	8	\N	UNRANKED	UNRANKED	77
2162	1954-10-30	W	AWAY	27	182	6	0	6	\N	15	5	83
2163	1954-11-06	W	AWAY	27	422	42	7	5	\N	UNRANKED	UNRANKED	102
2164	1954-11-13	W	HOME	27	216	42	13	5	\N	UNRANKED	UNRANKED	87
2165	1954-11-20	W	AWAY	27	190	34	18	4	\N	19	UNRANKED	58
2166	1954-11-27	W	HOME	27	281	23	17	4	\N	17	17	121
2167	1954-12-04	W	COTTON BOWL	27	110	26	14	4	\N	UNRANKED	UNRANKED	115
2168	1955-09-24	W	HOME	27	110	17	0	11	\N	UNRANKED	UNRANKED	115
2169	1955-10-01	W	HOME	27	48	19	0	4	\N	UNRANKED	UNRANKED	56
2170	1955-10-07	W	AWAY	27	41	14	0	5	\N	15	14	74
2171	1955-10-15	L	AWAY	27	171	7	21	4	\N	13	2	77
2172	1955-10-22	W	AWAY	27	424	22	7	11	\N	UNRANKED	UNRANKED	106
2173	1955-10-29	W	HOME	27	182	21	7	9	\N	4	18	83
2174	1955-11-05	W	AWAY	27	422	46	14	6	\N	UNRANKED	UNRANKED	102
2175	1955-11-12	W	AWAY	27	216	27	7	5	\N	UNRANKED	UNRANKED	87
2176	1955-11-19	W	HOME	27	190	17	14	4	\N	UNRANKED	UNRANKED	58
2177	1955-11-26	L	AWAY	27	281	20	42	5	\N	UNRANKED	13	121
2178	1956-09-22	L	COTTON BOWL	27	110	13	19	3	\N	UNRANKED	UNRANKED	115
2179	1956-10-06	W	HOME	27	48	20	6	17	\N	UNRANKED	UNRANKED	56
2180	1956-10-13	L	HOME	27	261	14	28	18	\N	UNRANKED	UNRANKED	106
2181	1956-10-20	L	HOME	27	171	14	47	UNRANKED	\N	2	9	77
2182	1956-10-27	L	HOME	27	97	0	40	UNRANKED	\N	2	1	95
2183	1956-11-03	L	AWAY	27	182	7	33	UNRANKED	\N	UNRANKED	16	83
2184	1956-11-10	L	AWAY	27	309	13	26	UNRANKED	\N	20	13	104
2185	1956-11-17	W	HOME	27	290	21	14	UNRANKED	\N	UNRANKED	UNRANKED	87
2186	1956-11-24	L	AWAY	27	190	8	48	UNRANKED	\N	3	3	58
2187	1956-12-01	L	AWAY	27	281	20	28	UNRANKED	\N	17	18	121
2188	1957-09-28	W	AWAY	27	261	12	0	UNRANKED	\N	UNRANKED	UNRANKED	106
2189	1957-10-05	W	HOME	27	80	26	0	16	\N	UNRANKED	UNRANKED	56
2190	1957-10-12	W	AWAY	27	175	23	21	12	\N	10	18	10
2191	1957-10-26	W	HOME	27	309	13	7	7	\N	UNRANKED	UNRANKED	104
2192	1957-11-02	L	HOME	27	182	6	20	5	\N	16	5	83
2193	1957-11-09	L	AWAY	27	171	6	34	15	\N	4	3	77
2194	1957-11-16	W	AWAY	27	97	7	0	UNRANKED	\N	2	4	95
2195	1957-11-23	L	HOME	27	190	13	21	9	\N	8	6	58
2196	1957-11-30	W	HOME	27	167	40	12	12	\N	UNRANKED	UNRANKED	121
2197	1957-12-07	W	COTTON BOWL	27	66	54	21	12	\N	UNRANKED	UNRANKED	115
2198	1958-09-27	W	HOME	27	387	18	0	5	\N	UNRANKED	UNRANKED	56
2199	1958-10-04	W	COTTON BOWL	27	66	14	6	7	\N	17	18	115
2200	1958-10-11	L	HOME	27	175	2	14	4	\N	3	3	10
2201	1958-10-18	W	HOME	27	67	9	7	12	\N	UNRANKED	UNRANKED	39
2202	1958-10-25	L	HOME	27	261	22	29	11	\N	15	13	106
2203	1958-11-01	W	AWAY	27	182	40	20	UNRANKED	\N	15	UNRANKED	83
2204	1958-11-08	L	AWAY	27	309	26	29	14	\N	UNRANKED	UNRANKED	104
2205	1958-11-15	W	HOME	27	290	34	24	UNRANKED	\N	11	UNRANKED	87
2206	1958-11-22	L	AWAY	27	190	21	31	15	\N	6	2	58
2207	1958-11-29	W	AWAY	27	167	20	13	18	\N	UNRANKED	UNRANKED	121
2208	1959-09-26	W	HOME	20	286	28	8	UNRANKED	\N	UNRANKED	UNRANKED	87
2209	1959-10-03	L	AWAY	20	261	7	28	8	\N	UNRANKED	UNRANKED	106
2210	1959-10-10	W	AWAY	20	384	28	6	UNRANKED	\N	UNRANKED	UNRANKED	19
2211	1959-10-17	L	AWAY	20	171	0	19	UNRANKED	\N	UNRANKED	UNRANKED	77
2212	1959-10-24	L	HOME	20	1	24	30	UNRANKED	\N	2	UNRANKED	90
2213	1959-10-31	W	HOME	20	456	25	22	UNRANKED	\N	UNRANKED	UNRANKED	83
2214	1959-11-07	L	HOME	20	88	10	14	UNRANKED	\N	19	UNRANKED	45
2215	1959-11-14	L	AWAY	20	309	13	28	UNRANKED	\N	UNRANKED	20	104
2216	1959-11-21	W	AWAY	20	190	20	19	UNRANKED	\N	16	UNRANKED	58
2217	1959-11-28	W	HOME	20	167	16	6	UNRANKED	\N	7	14	121
2218	1960-09-24	W	HOME	20	349	21	7	UNRANKED	\N	UNRANKED	UNRANKED	19
2219	1960-10-01	L	HOME	20	261	19	51	12	\N	UNRANKED	19	106
2220	1960-10-08	L	AWAY	20	286	7	12	UNRANKED	\N	UNRANKED	UNRANKED	87
2221	1960-10-15	L	HOME	20	171	0	21	UNRANKED	\N	14	15	77
2222	1960-10-22	L	AWAY	20	1	6	7	UNRANKED	\N	UNRANKED	UNRANKED	90
2223	1960-10-29	L	AWAY	20	456	7	14	UNRANKED	\N	4	4	83
2224	1960-11-05	L	HOME	20	309	13	20	UNRANKED	\N	14	UNRANKED	104
2225	1960-11-12	L	AWAY	20	41	21	28	UNRANKED	\N	UNRANKED	UNRANKED	74
2226	1960-11-19	L	HOME	20	190	0	28	UNRANKED	\N	2	3	58
2227	1960-11-26	W	AWAY	20	307	17	0	UNRANKED	\N	UNRANKED	UNRANKED	121
2228	1961-09-30	W	HOME	20	97	19	6	UNRANKED	\N	UNRANKED	UNRANKED	95
2229	1961-10-07	W	AWAY	20	261	22	20	UNRANKED	\N	UNRANKED	12	106
2230	1961-10-14	W	HOME	20	307	30	0	8	\N	UNRANKED	UNRANKED	121
2231	1961-10-21	L	AWAY	20	171	7	17	6	\N	1	8	77
2232	1961-10-28	L	HOME	20	1	10	12	8	\N	UNRANKED	UNRANKED	90
2233	1961-11-04	L	HOME	20	456	10	13	UNRANKED	\N	UNRANKED	UNRANKED	83
2234	1961-11-11	W	AWAY	20	309	26	20	UNRANKED	\N	UNRANKED	UNRANKED	104
2235	1961-11-18	W	HOME	20	45	17	15	UNRANKED	\N	10	14	126
2236	1961-11-25	L	AWAY	20	279	21	42	UNRANKED	\N	UNRANKED	UNRANKED	58
2237	1961-12-02	L	AWAY	20	67	13	37	UNRANKED	\N	UNRANKED	20	39
2238	1962-09-29	W	AWAY	20	97	13	7	UNRANKED	\N	UNRANKED	8	95
2239	1962-10-06	L	HOME	20	261	6	24	UNRANKED	\N	UNRANKED	UNRANKED	106
2240	1962-10-13	L	AWAY	20	360	8	17	UNRANKED	\N	UNRANKED	2	150
2241	1962-10-20	L	HOME	20	171	7	31	UNRANKED	\N	UNRANKED	UNRANKED	77
2242	1962-10-27	L	AWAY	20	1	6	35	UNRANKED	\N	3	UNRANKED	90
2243	1962-11-03	W	AWAY	20	456	20	12	UNRANKED	\N	UNRANKED	UNRANKED	83
2244	1962-11-10	W	HOME	20	309	43	22	UNRANKED	\N	UNRANKED	UNRANKED	104
2245	1962-11-17	W	HOME	20	286	21	7	UNRANKED	\N	UNRANKED	UNRANKED	87
2246	1962-11-24	W	HOME	20	279	35	12	UNRANKED	\N	UNRANKED	UNRANKED	58
2247	1962-12-01	L	AWAY	20	307	0	25	UNRANKED	\N	1	1	121
2248	1963-09-28	L	HOME	14	360	9	14	UNRANKED	\N	6	UNRANKED	150
2249	1963-10-05	L	AWAY	14	261	6	7	UNRANKED	\N	UNRANKED	UNRANKED	106
2250	1963-10-12	W	HOME	14	307	17	14	UNRANKED	\N	7	UNRANKED	121
2251	1963-10-19	W	HOME	14	54	27	12	UNRANKED	\N	UNRANKED	UNRANKED	135
2252	1963-10-26	L	AWAY	14	311	14	24	UNRANKED	\N	UNRANKED	UNRANKED	125
2253	1963-11-02	L	HOME	14	456	14	35	UNRANKED	\N	4	2	83
2254	1963-11-09	L	HOME	14	309	7	27	UNRANKED	\N	8	4	104
2255	1963-11-16	L	AWAY	14	171	7	12	UNRANKED	\N	4	9	77
2256	1963-11-28	L	YANKEE STADIUM	14	45	7	14	UNRANKED	\N	UNRANKED	UNRANKED	126
2257	1964-09-26	W	AWAY	1	360	31	7	UNRANKED	\N	UNRANKED	UNRANKED	150
2258	1964-10-03	W	HOME	1	261	34	15	9	\N	UNRANKED	UNRANKED	106
2259	1964-10-10	W	AWAY	1	44	34	7	6	\N	UNRANKED	UNRANKED	2
2260	1964-10-17	W	HOME	1	54	24	0	4	\N	UNRANKED	UNRANKED	135
2261	1964-10-24	W	HOME	1	311	28	6	2	\N	UNRANKED	UNRANKED	125
2262	1964-10-31	W	PHILADELPHIA	1	456	40	0	2	\N	UNRANKED	UNRANKED	83
2263	1964-11-07	W	AWAY	1	309	17	15	1	\N	UNRANKED	UNRANKED	104
2264	1964-11-14	W	HOME	1	171	34	7	1	\N	UNRANKED	UNRANKED	77
2265	1964-11-21	W	HOME	1	279	28	0	1	\N	UNRANKED	UNRANKED	58
2266	1964-11-28	L	AWAY	1	307	17	20	1	\N	UNRANKED	10	121
2267	1965-09-18	W	AWAY	1	400	48	6	3	\N	UNRANKED	UNRANKED	19
2268	1965-09-25	L	AWAY	1	261	21	25	1	\N	6	UNRANKED	106
2269	1965-10-02	W	HOME	1	38	38	7	8	\N	UNRANKED	UNRANKED	90
2270	1965-10-09	W	SHEA STADIUM	1	376	17	0	7	\N	UNRANKED	UNRANKED	10
2271	1965-10-23	W	HOME	1	307	28	7	7	\N	4	10	121
2272	1965-10-30	W	HOME	1	59	29	3	4	\N	UNRANKED	UNRANKED	83
2273	1965-11-06	W	AWAY	1	309	69	13	4	\N	UNRANKED	UNRANKED	104
2274	1965-11-13	W	HOME	1	286	17	0	4	\N	UNRANKED	UNRANKED	87
2275	1965-11-20	L	HOME	1	171	3	12	4	\N	1	2	77
2276	1965-11-27	T	AWAY	1	119	0	0	6	\N	UNRANKED	UNRANKED	74
2277	1966-09-24	W	HOME	1	261	26	14	8	\N	7	7	106
2278	1966-10-01	W	AWAY	1	38	35	7	4	\N	UNRANKED	UNRANKED	90
2279	1966-10-08	W	HOME	1	433	35	0	3	\N	UNRANKED	UNRANKED	10
2280	1966-10-15	W	HOME	1	286	32	0	2	\N	UNRANKED	UNRANKED	87
2281	1966-10-22	W	AWAY	1	288	38	0	1	\N	10	UNRANKED	95
2282	1966-10-29	W	PHILADELPHIA	1	59	31	7	1	\N	UNRANKED	UNRANKED	83
2283	1966-11-05	W	HOME	1	159	40	0	1	\N	UNRANKED	UNRANKED	104
2284	1966-11-12	W	HOME	1	436	64	0	1	\N	UNRANKED	UNRANKED	39
2285	1966-11-19	T	AWAY	1	171	10	10	1	\N	2	2	77
2286	1966-11-26	W	AWAY	1	307	51	0	1	\N	10	UNRANKED	121
2287	1967-09-23	W	HOME	1	400	41	8	1	\N	UNRANKED	UNRANKED	19
2288	1967-09-30	L	AWAY	1	261	21	28	1	\N	10	9	106
2289	1967-10-07	W	HOME	1	398	56	6	6	\N	UNRANKED	UNRANKED	58
2290	1967-10-14	L	HOME	1	307	7	24	5	\N	1	1	121
2291	1967-10-21	W	AWAY	1	292	47	7	UNRANKED	\N	UNRANKED	UNRANKED	54
2292	1967-10-28	W	HOME	1	171	24	12	UNRANKED	\N	UNRANKED	UNRANKED	77
2293	1967-11-04	W	HOME	1	59	43	14	10	\N	UNRANKED	UNRANKED	83
2294	1967-11-11	W	AWAY	1	159	38	0	9	\N	UNRANKED	UNRANKED	104
2295	1967-11-18	W	AWAY	1	96	36	3	9	\N	UNRANKED	UNRANKED	45
2296	1967-11-24	W	AWAY	1	119	24	22	6	\N	UNRANKED	UNRANKED	74
2297	1968-09-21	W	HOME	1	125	45	21	3	\N	5	11	95
2298	1968-09-28	L	HOME	1	261	22	37	2	\N	1	10	106
2299	1968-10-05	W	AWAY	1	398	51	28	5	\N	UNRANKED	UNRANKED	58
2300	1968-10-12	W	HOME	1	38	27	7	5	\N	UNRANKED	UNRANKED	90
2301	1968-10-19	W	HOME	1	292	58	8	6	\N	UNRANKED	UNRANKED	54
2302	1968-10-26	L	AWAY	1	171	17	21	5	\N	UNRANKED	UNRANKED	77
2303	1968-11-02	W	PHILADELPHIA	1	59	45	14	12	\N	UNRANKED	UNRANKED	83
2304	1968-11-09	W	HOME	1	159	56	7	12	\N	UNRANKED	UNRANKED	104
2305	1968-11-16	W	HOME	1	96	34	6	9	\N	UNRANKED	UNRANKED	45
2306	1968-11-30	T	AWAY	1	307	21	21	9	\N	2	4	121
2307	1969-09-20	W	HOME	1	38	35	10	11	\N	UNRANKED	UNRANKED	90
2308	1969-09-27	L	AWAY	1	261	14	28	9	\N	16	18	106
2309	1969-10-04	W	HOME	1	171	42	28	UNRANKED	\N	14	UNRANKED	77
2310	1969-10-11	W	YANKEE STADIUM	1	433	45	0	15	\N	UNRANKED	UNRANKED	10
2311	1969-10-18	T	HOME	1	307	14	14	11	\N	3	3	121
2312	1969-10-25	W	AWAY	1	289	37	0	12	\N	UNRANKED	UNRANKED	133
2313	1969-11-01	W	HOME	1	404	47	0	10	\N	UNRANKED	UNRANKED	83
2314	1969-11-08	W	AWAY	1	105	49	7	8	\N	UNRANKED	UNRANKED	104
2315	1969-11-15	W	AWAY	1	96	38	20	9	\N	UNRANKED	UNRANKED	45
2316	1969-11-22	W	HOME	1	44	13	6	8	\N	UNRANKED	UNRANKED	2
2317	1970-01-01	L	COTTON BOWL	1	150	17	21	9	\N	1	1	129
2318	1970-09-19	W	AWAY	1	38	35	14	6	\N	UNRANKED	UNRANKED	90
2319	1970-09-26	W	HOME	1	78	48	0	6	\N	UNRANKED	UNRANKED	106
2320	1970-10-03	W	AWAY	1	171	29	0	4	\N	UNRANKED	UNRANKED	77
2321	1970-10-10	W	HOME	1	433	51	10	3	\N	UNRANKED	UNRANKED	10
2322	1970-10-17	W	AWAY	1	5	24	7	3	\N	18	UNRANKED	79
2323	1970-10-31	W	PHILADELPHIA	1	404	56	7	3	\N	UNRANKED	UNRANKED	83
2324	1970-11-07	W	HOME	1	105	46	14	2	\N	UNRANKED	UNRANKED	104
2325	1970-11-14	W	HOME	1	96	10	7	1	\N	UNRANKED	13	45
2326	1970-11-21	W	HOME	1	117	3	0	2	\N	7	7	70
2327	1970-11-28	L	AWAY	1	307	28	38	4	\N	UNRANKED	15	121
2328	1971-01-01	W	COTTON BOWL	1	150	24	11	6	\N	1	3	129
2329	1971-09-18	W	HOME	1	38	50	7	2	\N	UNRANKED	UNRANKED	90
2330	1971-09-25	W	AWAY	1	78	8	7	2	\N	UNRANKED	UNRANKED	106
2331	1971-10-02	W	HOME	1	171	14	2	4	\N	UNRANKED	UNRANKED	77
2332	1971-10-09	W	ORANGE BOWL	1	192	17	0	7	\N	UNRANKED	UNRANKED	74
2333	1971-10-16	W	HOME	1	58	16	0	7	\N	UNRANKED	UNRANKED	87
2334	1971-10-23	L	HOME	1	307	14	28	6	\N	UNRANKED	20	121
2335	1971-10-30	W	HOME	1	404	21	0	12	\N	UNRANKED	UNRANKED	83
2336	1971-11-06	W	AWAY	1	105	56	7	8	\N	UNRANKED	UNRANKED	104
2337	1971-11-13	W	HOME	1	46	21	7	8	\N	UNRANKED	UNRANKED	133
2338	1971-11-20	L	AWAY	1	117	8	28	7	\N	14	11	70
2339	1972-09-23	W	AWAY	1	38	37	0	13	\N	UNRANKED	UNRANKED	90
2340	1972-09-30	W	HOME	1	78	35	14	10	\N	UNRANKED	UNRANKED	106
2341	1972-10-07	W	AWAY	1	171	16	0	7	\N	UNRANKED	UNRANKED	77
2342	1972-10-14	W	HOME	1	105	42	16	7	\N	UNRANKED	UNRANKED	104
2343	1972-10-21	L	HOME	1	36	26	30	8	\N	UNRANKED	UNRANKED	79
2344	1972-10-28	W	HOME	1	74	21	0	13	\N	UNRANKED	UNRANKED	131
2345	1972-11-04	W	VETERANS STADIUM	1	404	42	23	12	\N	UNRANKED	UNRANKED	83
2346	1972-11-11	W	AWAY	1	44	21	7	12	\N	UNRANKED	UNRANKED	2
2347	1972-11-18	W	HOME	1	192	20	17	10	\N	UNRANKED	UNRANKED	74
2348	1972-12-02	L	AWAY	1	307	23	45	10	\N	1	1	121
2349	1973-01-01	L	ORANGE BOWL	1	79	6	40	12	\N	9	4	84
2350	1973-09-22	W	HOME	1	310	44	0	8	\N	UNRANKED	UNRANKED	90
2351	1973-09-29	W	AWAY	1	38	20	7	7	\N	UNRANKED	UNRANKED	106
2352	1973-10-06	W	HOME	1	163	14	10	8	\N	UNRANKED	UNRANKED	77
2353	1973-10-13	W	AWAY	1	34	28	0	9	\N	UNRANKED	UNRANKED	107
2354	1973-10-20	W	AWAY	1	433	62	3	8	\N	UNRANKED	UNRANKED	10
2355	1973-10-27	W	HOME	1	307	23	14	8	\N	6	8	121
2356	1973-11-03	W	HOME	1	229	44	7	5	\N	UNRANKED	UNRANKED	83
2357	1973-11-10	W	AWAY	1	314	31	10	5	\N	20	UNRANKED	104
2358	1973-11-22	W	HOME	1	44	48	15	5	\N	UNRANKED	UNRANKED	2
2359	1973-12-01	W	AWAY	1	384	44	0	5	\N	UNRANKED	UNRANKED	74
2360	1973-12-31	W	SUGAR BOWL	1	373	24	23	3	\N	1	4	4
2361	1974-09-09	W	AWAY	1	382	31	7	3	\N	UNRANKED	UNRANKED	45
2362	1974-09-21	W	AWAY	1	310	49	3	1	\N	UNRANKED	UNRANKED	90
2363	1974-09-28	L	HOME	1	38	20	31	2	\N	UNRANKED	UNRANKED	106
2364	1974-10-05	W	AWAY	1	163	19	14	7	\N	UNRANKED	12	77
2365	1974-10-12	W	HOME	1	34	10	3	6	\N	UNRANKED	UNRANKED	107
2366	1974-10-19	W	HOME	1	252	48	0	7	\N	UNRANKED	UNRANKED	10
2367	1974-10-26	W	HOME	1	384	38	7	7	\N	UNRANKED	UNRANKED	74
2368	1974-11-02	W	VETERANS STADIUM	1	229	14	6	7	\N	UNRANKED	UNRANKED	83
2369	1974-11-16	W	HOME	1	314	14	10	5	\N	17	UNRANKED	104
2370	1974-11-23	W	HOME	1	44	38	0	5	\N	UNRANKED	UNRANKED	2
2371	1974-11-30	L	AWAY	1	307	24	55	5	\N	6	2	121
2372	1975-01-01	W	ORANGE BOWL	1	373	13	11	9	\N	2	5	4
2373	1975-09-15	W	FOXBORO MA	5	316	17	3	9	\N	UNRANKED	UNRANKED	15
2374	1975-09-20	W	AWAY	5	38	17	0	9	\N	UNRANKED	UNRANKED	106
2375	1975-09-27	W	HOME	5	310	31	7	7	\N	UNRANKED	UNRANKED	90
2376	1975-10-04	L	HOME	5	163	3	10	8	\N	UNRANKED	UNRANKED	77
2377	1975-10-11	W	AWAY	5	58	21	14	15	\N	UNRANKED	UNRANKED	87
2378	1975-10-18	W	AWAY	5	44	31	30	15	\N	UNRANKED	UNRANKED	2
2379	1975-10-25	L	HOME	5	307	17	24	14	\N	3	17	121
2380	1975-11-01	W	HOME	5	229	31	10	15	\N	UNRANKED	UNRANKED	83
2381	1975-11-08	W	HOME	5	382	24	3	12	\N	UNRANKED	UNRANKED	45
2382	1975-11-15	L	AWAY	5	314	20	34	9	\N	UNRANKED	15	104
2383	1975-11-22	W	ORANGE BOWL	5	107	32	9	UNRANKED	\N	UNRANKED	UNRANKED	74
2384	1976-09-11	L	HOME	5	314	10	31	11	\N	9	1	104
2385	1976-09-18	W	HOME	5	38	23	0	UNRANKED	\N	UNRANKED	UNRANKED	106
2386	1976-09-25	W	AWAY	5	310	48	0	UNRANKED	\N	UNRANKED	UNRANKED	90
2387	1976-10-02	W	AWAY	5	151	24	6	18	\N	UNRANKED	UNRANKED	77
2388	1976-10-16	W	HOME	5	170	41	0	14	\N	UNRANKED	UNRANKED	98
2389	1976-10-23	W	AWAY	5	282	13	6	12	\N	19	UNRANKED	118
2390	1976-10-30	W	CLEVELAND	5	229	27	21	11	\N	UNRANKED	UNRANKED	83
2391	1976-11-06	L	AWAY	5	382	14	23	11	\N	UNRANKED	UNRANKED	45
2392	1976-11-13	W	HOME	5	373	21	18	18	\N	10	11	4
2393	1976-11-20	W	HOME	5	107	40	27	13	\N	UNRANKED	UNRANKED	74
2394	1976-11-27	L	AWAY	5	313	13	17	13	\N	3	2	121
2395	1976-12-27	W	GATOR BOWL	5	299	20	9	15	\N	20	UNRANKED	101
2396	1977-09-10	W	AWAY	5	263	19	9	3	\N	7	8	104
2397	1977-09-17	L	AWAY	5	321	13	20	3	\N	UNRANKED	UNRANKED	96
2398	1977-09-24	W	AWAY	5	293	31	24	11	\N	UNRANKED	UNRANKED	106
2399	1977-10-01	W	HOME	5	151	16	6	14	\N	UNRANKED	UNRANKED	77
2400	1977-10-15	W	GIANTS STADIUM	5	252	24	0	11	\N	UNRANKED	UNRANKED	10
2401	1977-10-22	W	HOME	5	313	49	19	11	\N	5	13	121
2402	1977-10-29	W	HOME	5	229	43	10	5	\N	UNRANKED	UNRANKED	83
2403	1977-11-05	W	HOME	5	382	69	14	5	\N	UNRANKED	UNRANKED	45
2404	1977-11-12	W	AWAY	5	116	21	17	5	\N	15	19	29
2405	1977-11-19	W	HOME	5	44	49	0	6	\N	UNRANKED	UNRANKED	2
2406	1977-12-03	W	AWAY	5	338	48	10	5	\N	UNRANKED	UNRANKED	74
2407	1978-01-02	W	COTTON BOWL	5	204	38	10	5	\N	1	4	129
2408	1978-09-09	L	HOME	5	455	0	3	5	\N	UNRANKED	15	79
2409	1978-09-23	L	HOME	5	77	14	28	14	\N	5	5	76
2410	1978-09-30	W	HOME	5	293	10	6	UNRANKED	\N	UNRANKED	13	106
2411	1978-10-07	W	AWAY	5	151	29	25	UNRANKED	\N	UNRANKED	12	77
2412	1978-10-14	W	HOME	5	263	26	17	UNRANKED	\N	9	UNRANKED	104
2413	1978-10-21	W	AWAY	5	68	38	15	20	\N	UNRANKED	UNRANKED	2
2414	1978-10-28	W	HOME	5	338	20	0	19	\N	UNRANKED	UNRANKED	74
2415	1978-11-04	W	CLEVELAND	5	229	27	7	15	\N	11	UNRANKED	83
2416	1978-11-11	W	HOME	5	314	31	14	14	\N	UNRANKED	UNRANKED	128
2417	1978-11-18	W	AWAY	5	382	38	21	10	\N	20	UNRANKED	45
2418	1978-11-25	L	AWAY	5	313	25	27	8	\N	3	2	121
2419	1979-01-01	W	COTTON BOWL	5	71	35	34	10	\N	9	10	53
2420	1979-09-15	W	AWAY	5	77	12	10	9	\N	6	18	76
2421	1979-09-22	L	AWAY	5	293	22	28	5	\N	17	10	106
2422	1979-09-29	W	HOME	5	151	27	3	15	\N	7	UNRANKED	77
2423	1979-10-06	W	HOME	5	382	21	13	10	\N	UNRANKED	UNRANKED	45
2424	1979-10-13	W	AWAY	5	322	38	13	10	\N	UNRANKED	UNRANKED	2
2425	1979-10-20	L	HOME	5	313	23	42	9	\N	4	2	121
2426	1979-10-27	W	HOME	5	282	18	17	14	\N	UNRANKED	UNRANKED	118
2427	1979-11-03	W	HOME	5	229	14	0	13	\N	UNRANKED	UNRANKED	83
2428	1979-11-10	L	AWAY	5	314	18	40	13	\N	UNRANKED	UNRANKED	128
2429	1979-11-17	L	HOME	5	147	10	16	UNRANKED	\N	14	UNRANKED	29
2430	1979-11-24	W	TOKYO	5	237	40	15	UNRANKED	\N	UNRANKED	UNRANKED	74
2431	1980-09-06	W	HOME	5	293	31	10	11	\N	9	17	106
2432	1980-09-20	W	HOME	5	77	29	27	8	\N	14	4	76
2433	1980-10-04	W	AWAY	5	203	26	21	7	\N	UNRANKED	UNRANKED	77
2434	1980-10-11	W	HOME	5	237	32	14	7	\N	13	18	74
2435	1980-10-18	W	HOME	5	178	30	3	5	\N	UNRANKED	UNRANKED	10
2436	1980-10-25	W	AWAY	5	332	20	3	4	\N	UNRANKED	UNRANKED	8
2437	1980-11-01	W	GIANTS STADIUM	5	229	33	0	3	\N	UNRANKED	UNRANKED	83
2438	1980-11-08	T	AWAY	5	56	3	3	1	\N	UNRANKED	UNRANKED	45
2439	1980-11-15	W	BIRMINGHAM	5	373	7	0	6	\N	5	6	4
2440	1980-11-22	W	HOME	5	322	24	10	2	\N	UNRANKED	UNRANKED	2
2441	1980-12-06	L	AWAY	5	313	3	20	2	\N	17	11	121
2442	1981-01-01	L	SUGAR BOWL	5	447	10	17	7	\N	1	1	44
2443	1981-09-12	W	HOME	11	280	27	9	4	\N	UNRANKED	UNRANKED	70
2444	1981-09-19	L	AWAY	11	77	7	25	1	\N	11	12	76
2445	1981-09-26	L	AWAY	11	293	14	15	13	\N	UNRANKED	UNRANKED	106
2446	1981-10-03	W	HOME	11	203	20	7	UNRANKED	\N	UNRANKED	UNRANKED	77
2447	1981-10-10	L	HOME	11	86	13	19	UNRANKED	\N	20	UNRANKED	42
2448	1981-10-24	L	HOME	11	313	7	14	UNRANKED	\N	5	14	121
2449	1981-10-31	W	HOME	11	229	38	0	UNRANKED	\N	UNRANKED	UNRANKED	83
2450	1981-11-07	W	HOME	11	56	35	3	UNRANKED	\N	UNRANKED	UNRANKED	45
2451	1981-11-14	W	AWAY	11	322	35	7	UNRANKED	\N	UNRANKED	UNRANKED	2
2452	1981-11-21	L	AWAY	11	299	21	24	UNRANKED	\N	13	3	101
2453	1981-11-27	L	AWAY	11	237	15	37	UNRANKED	\N	9	8	74
2454	1982-09-18	W	HOME	11	77	23	17	20	\N	10	UNRANKED	76
2455	1982-09-25	W	HOME	11	335	28	14	10	\N	UNRANKED	UNRANKED	106
2456	1982-10-02	W	AWAY	11	203	11	3	11	\N	UNRANKED	UNRANKED	77
2457	1982-10-09	W	HOME	11	237	16	14	10	\N	17	UNRANKED	74
2458	1982-10-16	L	HOME	11	332	13	16	9	\N	UNRANKED	UNRANKED	8
2459	1982-10-23	T	AWAY	11	401	13	13	15	\N	UNRANKED	UNRANKED	98
2460	1982-10-30	W	GIANTS STADIUM	11	213	27	10	UNRANKED	\N	UNRANKED	UNRANKED	83
2461	1982-11-06	W	AWAY	11	189	31	16	UNRANKED	\N	1	10	104
2462	1982-11-13	L	HOME	11	299	14	24	13	\N	5	1	101
2463	1982-11-20	L	AWAY	11	322	17	30	18	\N	UNRANKED	UNRANKED	2
2464	1982-11-27	L	AWAY	11	313	13	17	UNRANKED	\N	17	15	121
2465	1983-09-10	W	AWAY	11	335	52	6	5	\N	UNRANKED	UNRANKED	106
2466	1983-09-17	L	HOME	11	226	23	28	4	\N	UNRANKED	UNRANKED	77
2467	1983-09-24	L	AWAY	11	237	0	20	13	\N	UNRANKED	1	74
2468	1983-10-01	W	AWAY	11	65	27	3	UNRANKED	\N	UNRANKED	UNRANKED	31
2469	1983-10-08	W	AWAY	11	298	30	6	UNRANKED	\N	UNRANKED	UNRANKED	118
2470	1983-10-15	W	GIANTS STADIUM	11	293	42	0	UNRANKED	\N	UNRANKED	UNRANKED	10
2471	1983-10-22	W	HOME	11	427	27	6	UNRANKED	\N	UNRANKED	UNRANKED	121
2472	1983-10-29	W	HOME	11	213	28	12	19	\N	UNRANKED	UNRANKED	83
2473	1983-11-05	L	HOME	11	189	16	21	18	\N	UNRANKED	18	104
2474	1983-11-12	L	AWAY	11	299	30	34	UNRANKED	\N	UNRANKED	UNRANKED	101
2475	1983-11-19	L	HOME	11	322	22	23	UNRANKED	\N	UNRANKED	13	2
2476	1983-12-29	W	LIBERTY BOWL	11	258	19	18	UNRANKED	\N	13	19	15
2477	1984-09-08	L	HOOSIER DOME	11	335	21	23	7	\N	UNRANKED	UNRANKED	106
2478	1984-09-15	W	AWAY	11	226	24	20	UNRANKED	\N	UNRANKED	UNRANKED	77
2479	1984-09-22	W	HOME	11	65	55	14	UNRANKED	\N	UNRANKED	UNRANKED	31
2480	1984-09-29	W	AWAY	11	455	16	14	19	\N	UNRANKED	UNRANKED	79
2481	1984-10-06	L	HOME	11	296	13	31	16	\N	14	18	74
2482	1984-10-13	L	HOME	11	188	7	21	UNRANKED	\N	UNRANKED	UNRANKED	2
2483	1984-10-20	L	HOME	11	298	32	36	UNRANKED	\N	11	11	118
2484	1984-10-27	W	AWAY	11	53	30	22	UNRANKED	\N	7	15	70
2485	1984-11-03	W	GIANTS STADIUM	11	213	18	17	UNRANKED	\N	UNRANKED	UNRANKED	83
2486	1984-11-17	W	HOME	11	299	44	7	UNRANKED	\N	UNRANKED	UNRANKED	101
2487	1984-11-24	W	AWAY	11	427	19	7	UNRANKED	\N	14	10	121
2488	1984-12-29	L	ALOHA BOWL	11	87	20	27	17	\N	10	8	115
2489	1985-09-14	L	AWAY	11	77	12	20	13	\N	UNRANKED	2	76
2490	1985-09-21	W	HOME	11	226	27	10	UNRANKED	\N	UNRANKED	UNRANKED	77
2491	1985-09-28	L	AWAY	11	335	17	35	UNRANKED	\N	UNRANKED	UNRANKED	106
2492	1985-10-05	L	AWAY	11	188	15	21	UNRANKED	\N	17	8	2
2493	1985-10-19	W	HOME	11	293	24	10	UNRANKED	\N	19	UNRANKED	10
2494	1985-10-26	W	HOME	11	427	37	3	UNRANKED	\N	UNRANKED	UNRANKED	121
2495	1985-11-02	W	HOME	11	213	41	17	UNRANKED	\N	UNRANKED	UNRANKED	83
2496	1985-11-09	W	HOME	11	73	37	14	UNRANKED	\N	UNRANKED	UNRANKED	96
2497	1985-11-16	L	AWAY	11	299	6	36	UNRANKED	\N	1	3	101
2498	1985-11-23	L	HOME	11	53	7	10	UNRANKED	\N	17	20	70
2499	1985-11-30	L	AWAY	11	296	7	58	UNRANKED	\N	4	9	74
2500	1986-09-13	L	HOME	24	77	23	24	UNRANKED	\N	3	8	76
2501	1986-09-20	L	AWAY	24	226	15	20	20	\N	UNRANKED	UNRANKED	77
2502	1986-09-27	W	HOME	24	335	41	9	UNRANKED	\N	UNRANKED	UNRANKED	106
2503	1986-10-04	L	BIRMINGHAM	24	399	10	28	UNRANKED	\N	2	9	4
2504	1986-10-11	L	HOME	24	354	9	10	UNRANKED	\N	UNRANKED	UNRANKED	104
2505	1986-10-18	W	HOME	24	188	31	3	UNRANKED	\N	UNRANKED	UNRANKED	2
2506	1986-11-01	W	AWAY	24	213	33	14	UNRANKED	\N	UNRANKED	UNRANKED	83
2507	1986-11-08	W	HOME	24	87	61	29	UNRANKED	\N	UNRANKED	UNRANKED	115
2508	1986-11-15	L	HOME	24	299	19	24	UNRANKED	\N	3	1	101
2509	1986-11-22	L	AWAY	24	53	19	21	UNRANKED	\N	8	10	70
2510	1986-11-29	W	AWAY	24	427	38	37	UNRANKED	\N	17	UNRANKED	121
2511	1987-09-12	W	AWAY	24	77	26	7	16	\N	9	19	76
2512	1987-09-19	W	HOME	24	226	31	8	9	\N	17	8	77
2513	1987-09-26	W	AWAY	24	204	44	20	8	\N	UNRANKED	UNRANKED	106
2514	1987-10-10	L	AWAY	24	354	22	30	4	\N	UNRANKED	UNRANKED	104
2515	1987-10-17	W	AWAY	24	188	35	14	11	\N	UNRANKED	UNRANKED	2
2516	1987-10-24	W	HOME	24	332	26	15	10	\N	UNRANKED	18	121
2517	1987-10-31	W	HOME	24	184	56	13	9	\N	UNRANKED	UNRANKED	83
2518	1987-11-07	W	HOME	24	258	32	25	9	\N	UNRANKED	UNRANKED	15
2519	1987-11-14	W	HOME	24	56	37	6	7	\N	11	UNRANKED	4
2520	1987-11-21	L	AWAY	24	299	20	21	7	\N	UNRANKED	UNRANKED	101
2521	1987-11-28	L	AWAY	24	296	0	24	10	\N	2	1	74
2522	1988-01-01	L	COTTON BOWL	24	263	10	35	12	\N	13	10	130
2523	1988-09-10	W	HOME	24	77	19	17	13	\N	9	4	76
2524	1988-09-17	W	AWAY	24	226	20	3	8	\N	UNRANKED	UNRANKED	77
2525	1988-09-24	W	HOME	24	204	52	7	8	\N	UNRANKED	UNRANKED	106
2526	1988-10-01	W	HOME	24	260	42	14	5	\N	UNRANKED	UNRANKED	125
2527	1988-10-08	W	AWAY	24	354	30	20	5	\N	UNRANKED	UNRANKED	104
2528	1988-10-15	W	HOME	24	296	31	30	4	\N	1	2	74
2529	1988-10-22	W	HOME	24	188	41	13	2	\N	UNRANKED	UNRANKED	2
2530	1988-10-29	W	AWAY	24	184	22	7	2	\N	UNRANKED	UNRANKED	83
2531	1988-11-05	W	HOME	24	278	54	11	1	\N	UNRANKED	UNRANKED	107
2532	1988-11-19	W	HOME	24	299	21	3	1	\N	UNRANKED	UNRANKED	101
2533	1988-11-26	W	AWAY	24	332	27	10	1	\N	2	7	121
2534	1989-01-02	W	FIESTA BOWL	24	169	34	21	1	\N	3	5	147
2535	1989-08-31	W	GIANTS STADIUM	24	229	36	13	2	\N	UNRANKED	18	139
2536	1989-09-16	W	AWAY	24	77	24	19	1	\N	2	7	76
2537	1989-09-23	W	HOME	24	226	21	13	1	\N	UNRANKED	16	77
2538	1989-09-30	W	AWAY	24	204	40	7	1	\N	UNRANKED	UNRANKED	106
2539	1989-10-07	W	AWAY	24	162	27	17	1	\N	UNRANKED	UNRANKED	125
2540	1989-10-14	W	AWAY	24	188	41	27	1	\N	17	UNRANKED	2
2541	1989-10-21	W	HOME	24	332	28	24	1	\N	9	8	121
2542	1989-10-28	W	HOME	24	354	45	7	1	\N	7	17	104
2543	1989-11-04	W	HOME	24	184	41	0	1	\N	UNRANKED	UNRANKED	83
2544	1989-11-11	W	HOME	24	191	59	6	1	\N	UNRANKED	UNRANKED	115
2545	1989-11-18	W	AWAY	24	299	34	23	1	\N	17	15	101
2546	1989-11-25	L	AWAY	24	161	10	27	1	\N	7	1	74
2547	1990-01-01	W	ORANGE BOWL	24	65	21	6	4	\N	1	4	31
2548	1990-09-15	W	HOME	24	212	28	24	1	\N	4	7	76
2549	1990-09-22	W	AWAY	24	226	20	19	1	\N	24	16	77
2550	1990-09-29	W	HOME	24	204	37	11	1	\N	UNRANKED	UNRANKED	106
2551	1990-10-06	L	HOME	24	162	31	36	1	\N	UNRANKED	UNRANKED	125
2552	1990-10-13	W	HOME	24	188	57	27	8	\N	UNRANKED	UNRANKED	2
2553	1990-10-20	W	HOME	24	161	29	20	6	\N	2	3	74
2554	1990-10-27	W	AWAY	24	377	31	22	3	\N	UNRANKED	UNRANKED	104
2555	1990-11-03	W	GIANTS STADIUM	24	217	52	31	2	\N	UNRANKED	UNRANKED	83
2556	1990-11-10	W	AWAY	24	314	34	29	1	\N	9	8	128
2557	1990-11-17	L	HOME	24	299	21	24	1	\N	18	11	101
2558	1990-11-24	W	AWAY	24	332	10	6	7	\N	18	20	121
2559	1991-01-01	L	ORANGE BOWL	24	65	9	10	5	\N	1	1	31
2560	1991-09-07	W	HOME	24	64	49	27	7	\N	UNRANKED	UNRANKED	56
2561	1991-09-14	L	AWAY	24	212	14	24	7	\N	3	6	76
2562	1991-09-21	W	HOME	24	226	49	10	11	\N	UNRANKED	UNRANKED	77
2563	1991-09-28	W	AWAY	24	283	45	20	8	\N	UNRANKED	UNRANKED	106
2564	1991-10-05	W	AWAY	24	162	42	26	8	\N	UNRANKED	22	125
2565	1991-10-12	W	HOME	24	377	42	7	7	\N	12	UNRANKED	104
2566	1991-10-19	W	AWAY	24	188	28	15	5	\N	UNRANKED	25	2
2567	1991-10-26	W	HOME	24	332	24	20	5	\N	UNRANKED	UNRANKED	121
2568	1991-11-02	W	HOME	24	217	38	0	5	\N	UNRANKED	UNRANKED	83
2569	1991-11-09	L	HOME	24	314	34	35	5	\N	13	14	128
2570	1991-11-16	L	AWAY	24	299	13	35	12	\N	8	3	101
2571	1991-11-30	W	AWAY	24	84	48	42	18	\N	UNRANKED	UNRANKED	50
2572	1992-01-01	W	SUGAR BOWL	24	423	39	28	18	\N	3	7	41
2573	1992-09-05	W	SOLDIER FIELD	24	210	42	7	3	\N	UNRANKED	UNRANKED	90
2574	1992-09-12	T	HOME	24	212	17	17	3	\N	6	5	76
2575	1992-09-19	W	AWAY	24	226	52	31	7	\N	UNRANKED	UNRANKED	77
2576	1992-09-26	W	HOME	24	283	48	0	6	\N	UNRANKED	UNRANKED	106
2577	1992-10-03	L	HOME	24	70	16	33	6	\N	18	9	125
2578	1992-10-10	W	AWAY	24	377	52	21	13	\N	UNRANKED	UNRANKED	104
2579	1992-10-24	W	HOME	24	333	42	16	10	\N	UNRANKED	UNRANKED	18
2580	1992-10-31	W	GIANTS STADIUM	24	217	38	7	10	\N	UNRANKED	UNRANKED	83
2581	1992-11-07	W	HOME	24	434	54	7	8	\N	9	21	15
2582	1992-11-14	W	HOME	24	299	17	16	8	\N	22	UNRANKED	101
2583	1992-11-28	W	AWAY	24	332	31	23	5	\N	19	UNRANKED	121
2584	1993-01-01	W	COTTON BOWL	24	390	28	3	5	\N	4	7	130
2585	1993-09-04	W	HOME	24	210	27	12	7	\N	UNRANKED	UNRANKED	90
2586	1993-09-11	W	AWAY	24	212	27	23	11	\N	3	21	76
2587	1993-09-18	W	HOME	24	226	36	14	4	\N	UNRANKED	UNRANKED	77
2588	1993-09-25	W	AWAY	24	283	17	0	4	\N	UNRANKED	UNRANKED	106
2589	1993-10-02	W	AWAY	24	70	48	20	4	\N	UNRANKED	UNRANKED	125
2590	1993-10-09	W	HOME	24	314	44	0	4	\N	UNRANKED	UNRANKED	104
2591	1993-10-16	W	AWAY	24	333	45	20	3	\N	UNRANKED	UNRANKED	18
2592	1993-10-23	W	HOME	24	313	31	13	2	\N	UNRANKED	UNRANKED	121
2593	1993-10-30	W	VETERANS STADIUM	24	217	58	27	2	\N	UNRANKED	UNRANKED	83
2594	1993-11-13	W	HOME	24	86	31	24	2	\N	1	1	42
2595	1993-11-20	L	HOME	24	434	39	41	1	\N	17	13	15
2596	1994-01-01	W	COTTON BOWL	24	390	24	21	4	\N	7	9	130
2597	1994-09-03	W	SOLDIER FIELD	24	210	42	15	3	\N	UNRANKED	UNRANKED	90
2598	1994-09-10	L	HOME	24	212	24	26	3	\N	6	12	76
2599	1994-09-17	W	AWAY	24	226	21	20	8	\N	UNRANKED	UNRANKED	77
2600	1994-09-24	W	HOME	24	283	39	21	9	\N	UNRANKED	UNRANKED	106
2601	1994-10-01	W	HOME	24	70	34	15	8	\N	UNRANKED	UNRANKED	125
2602	1994-10-08	L	AWAY	24	144	11	30	8	\N	UNRANKED	23	15
2603	1994-10-15	L	HOME	24	333	14	21	17	\N	UNRANKED	18	18
2604	1994-10-29	W	HOME	24	217	58	21	UNRANKED	\N	UNRANKED	UNRANKED	83
2605	1994-11-12	L	CITRUS BOWL	24	86	16	23	UNRANKED	\N	8	4	42
2606	1994-11-19	W	HOME	24	188	42	30	UNRANKED	\N	UNRANKED	UNRANKED	2
2607	1994-11-26	T	AWAY	24	313	17	17	UNRANKED	\N	17	13	121
2608	1995-01-02	L	FIESTA BOWL	24	65	24	41	UNRANKED	\N	4	3	31
2609	1995-09-02	L	HOME	24	210	15	17	9	\N	UNRANKED	8	90
2610	1995-09-09	W	AWAY	24	283	35	28	25	\N	UNRANKED	UNRANKED	106
2611	1995-09-16	W	HOME	24	407	41	0	24	\N	UNRANKED	UNRANKED	138
2612	1995-09-23	W	HOME	24	305	55	27	21	\N	13	14	129
2613	1995-09-30	L	AWAY	24	302	26	45	15	\N	7	6	94
2614	1995-10-07	W	AWAY	24	287	29	21	23	\N	15	UNRANKED	143
2615	1995-10-14	W	GIANTS STADIUM	24	82	28	27	17	\N	UNRANKED	UNRANKED	10
2616	1995-10-21	W	HOME	24	313	38	10	17	\N	5	12	121
2617	1995-10-28	W	HOME	24	144	20	10	12	\N	UNRANKED	UNRANKED	15
2618	1995-11-04	W	HOME	24	120	35	17	8	\N	UNRANKED	UNRANKED	83
2619	1995-11-18	W	AWAY	24	188	44	14	8	\N	UNRANKED	UNRANKED	2
2620	1996-01-01	L	ORANGE BOWL	24	86	26	31	6	\N	8	4	42
2621	1996-09-05	W	AWAY	24	407	14	7	6	\N	UNRANKED	UNRANKED	138
2622	1996-09-14	W	HOME	24	283	35	0	9	\N	UNRANKED	UNRANKED	106
2623	1996-09-21	W	AWAY	24	305	27	24	9	\N	6	23	129
2624	1996-09-28	L	HOME	24	302	16	29	5	\N	4	2	94
2625	1996-10-12	W	HOME	24	287	54	20	11	\N	16	16	143
2626	1996-10-19	L	HOME	24	188	17	20	8	\N	UNRANKED	UNRANKED	2
2627	1996-11-02	W	DUBLIN	24	120	54	27	19	\N	UNRANKED	UNRANKED	83
2628	1996-11-09	W	AWAY	24	144	48	21	17	\N	UNRANKED	UNRANKED	15
2629	1996-11-16	W	HOME	24	314	60	6	14	\N	UNRANKED	UNRANKED	104
2630	1996-11-23	W	HOME	24	429	62	0	10	\N	UNRANKED	UNRANKED	111
2631	1996-11-30	L	AWAY	24	313	20	27	10	\N	UNRANKED	UNRANKED	121
2632	1997-09-06	W	HOME	2	225	17	13	11	\N	UNRANKED	25	45
2633	1997-09-13	L	AWAY	2	300	17	28	12	\N	UNRANKED	15	106
2634	1997-09-20	L	HOME	2	362	7	23	UNRANKED	\N	17	UNRANKED	77
2635	1997-09-27	L	AWAY	2	337	14	21	UNRANKED	\N	6	1	76
2636	1997-10-04	L	AWAY	2	29	15	33	UNRANKED	\N	19	UNRANKED	125
2637	1997-10-11	W	AWAY	2	450	45	21	UNRANKED	\N	UNRANKED	UNRANKED	104
2638	1997-10-18	L	HOME	2	313	17	20	UNRANKED	\N	UNRANKED	UNRANKED	121
2639	1997-10-25	W	HOME	2	438	52	20	UNRANKED	\N	UNRANKED	UNRANKED	15
2640	1997-11-01	W	HOME	2	120	21	17	UNRANKED	\N	UNRANKED	UNRANKED	83
2641	1997-11-15	W	AWAY	2	230	24	6	UNRANKED	\N	11	13	70
2642	1997-11-22	W	HOME	2	169	21	14	UNRANKED	\N	22	UNRANKED	147
2643	1997-11-29	W	AWAY	2	207	23	22	UNRANKED	\N	UNRANKED	UNRANKED	50
2644	1997-12-28	L	INDEPENDENCE BOWL	2	230	9	27	UNRANKED	\N	15	13	70
2645	1998-09-05	W	HOME	2	337	36	20	22	\N	5	12	76
2646	1998-09-12	L	AWAY	2	362	23	45	10	\N	UNRANKED	UNRANKED	77
2647	1998-09-26	W	HOME	2	300	31	30	23	\N	UNRANKED	24	106
2648	1998-10-03	W	HOME	2	29	35	17	23	\N	UNRANKED	UNRANKED	125
2649	1998-10-10	W	AWAY	2	95	28	9	22	\N	UNRANKED	UNRANKED	9
2650	1998-10-24	W	HOME	2	82	20	17	18	\N	UNRANKED	UNRANKED	10
2651	1998-10-31	W	HOME	2	155	27	3	16	\N	UNRANKED	UNRANKED	12
2652	1998-11-07	W	AWAY	2	438	31	26	13	\N	UNRANKED	UNRANKED	15
2653	1998-11-14	W	RALJON MD	2	120	30	0	12	\N	UNRANKED	UNRANKED	83
2654	1998-11-21	W	HOME	2	230	39	36	10	\N	UNRANKED	UNRANKED	70
2655	1998-11-28	L	AWAY	2	377	0	10	9	\N	UNRANKED	UNRANKED	121
2656	1999-01-01	L	GATOR BOWL	2	225	28	35	17	\N	12	9	45
2657	1999-08-28	W	HOME	2	428	48	13	18	\N	UNRANKED	UNRANKED	62
2658	1999-09-04	L	AWAY	2	337	22	26	16	\N	7	5	76
2659	1999-09-11	L	AWAY	2	300	23	28	16	\N	20	25	106
2660	1999-09-18	L	HOME	2	362	13	23	24	\N	UNRANKED	7	77
2661	1999-10-02	W	HOME	2	81	34	30	UNRANKED	\N	23	UNRANKED	95
2662	1999-10-09	W	HOME	2	95	48	17	UNRANKED	\N	UNRANKED	UNRANKED	9
2663	1999-10-16	W	HOME	2	377	25	24	UNRANKED	\N	UNRANKED	UNRANKED	121
2664	1999-10-30	W	HOME	2	120	28	24	UNRANKED	\N	UNRANKED	UNRANKED	83
2665	1999-11-06	L	AWAY	2	389	14	38	24	\N	4	9	128
2666	1999-11-13	L	AWAY	2	450	27	37	UNRANKED	\N	UNRANKED	UNRANKED	104
2667	1999-11-20	L	HOME	2	438	29	31	UNRANKED	\N	25	UNRANKED	15
2668	1999-11-27	L	AWAY	2	29	37	40	UNRANKED	\N	UNRANKED	UNRANKED	125
2669	2000-09-02	W	HOME	2	390	24	10	UNRANKED	\N	25	UNRANKED	130
2670	2000-09-09	L	HOME	2	200	24	27	23	\N	1	8	84
2671	2000-09-16	W	HOME	2	300	23	21	21	\N	13	13	106
2672	2000-09-23	L	AWAY	2	91	21	27	16	\N	23	UNRANKED	77
2673	2000-10-07	W	HOME	2	29	20	14	25	\N	UNRANKED	UNRANKED	125
2674	2000-10-14	W	ORLANDO	2	120	45	14	20	\N	UNRANKED	UNRANKED	83
2675	2000-10-21	W	AWAY	2	169	42	28	20	\N	UNRANKED	UNRANKED	147
2676	2000-10-28	W	HOME	2	188	34	31	19	\N	UNRANKED	UNRANKED	2
2677	2000-11-11	W	HOME	2	438	28	16	11	\N	UNRANKED	UNRANKED	15
2678	2000-11-18	W	AWAY	2	429	45	17	11	\N	UNRANKED	UNRANKED	111
2679	2000-11-25	W	AWAY	2	377	38	21	11	\N	UNRANKED	UNRANKED	121
2680	2001-01-01	L	FIESTA BOWL	2	161	9	41	10	\N	5	4	99
2681	2001-09-08	L	AWAY	2	200	10	27	17	\N	5	8	84
2682	2001-09-22	L	HOME	2	91	10	17	23	\N	UNRANKED	UNRANKED	77
2683	2001-09-29	L	AWAY	2	390	3	24	UNRANKED	\N	UNRANKED	UNRANKED	130
2684	2001-10-06	W	HOME	2	450	24	7	UNRANKED	\N	UNRANKED	UNRANKED	104
2685	2001-10-13	W	HOME	2	403	34	24	UNRANKED	\N	UNRANKED	UNRANKED	147
2686	2001-10-20	W	HOME	2	383	27	16	UNRANKED	\N	UNRANKED	UNRANKED	121
2687	2001-10-27	L	AWAY	2	438	17	21	UNRANKED	\N	UNRANKED	21	15
2688	2001-11-03	L	HOME	2	389	18	28	UNRANKED	\N	7	4	128
2689	2001-11-17	W	HOME	2	405	34	16	UNRANKED	\N	UNRANKED	UNRANKED	83
2690	2001-11-24	L	AWAY	2	29	13	17	UNRANKED	\N	13	16	125
2691	2001-12-01	W	AWAY	2	300	24	18	UNRANKED	\N	UNRANKED	UNRANKED	106
2692	2002-08-31	W	GIANTS STADIUM	29	391	22	0	UNRANKED	\N	21	13	72
2693	2002-09-07	W	HOME	29	300	24	17	23	\N	UNRANKED	UNRANKED	106
2694	2002-09-14	W	HOME	29	337	25	23	20	\N	7	9	76
2695	2002-09-21	W	AWAY	29	91	21	17	12	\N	UNRANKED	UNRANKED	77
2696	2002-10-05	W	HOME	29	98	31	7	9	\N	UNRANKED	UNRANKED	125
2697	2002-10-12	W	HOME	29	450	14	6	8	\N	UNRANKED	19	104
2698	2002-10-19	W	AWAY	29	188	21	14	7	\N	18	UNRANKED	2
2699	2002-10-26	W	AWAY	29	86	34	24	6	\N	11	21	42
2700	2002-11-02	L	HOME	29	438	7	14	4	\N	UNRANKED	UNRANKED	15
2701	2002-11-09	W	BALTIMORE	29	378	30	23	9	\N	UNRANKED	UNRANKED	83
2702	2002-11-23	W	HOME	29	235	42	0	8	\N	UNRANKED	UNRANKED	111
2703	2002-11-30	L	AWAY	29	383	13	44	7	\N	6	4	121
2704	2003-01-01	L	GATOR BOWL	29	124	6	28	11	\N	17	12	88
2705	2003-09-06	W	HOME	29	57	29	26	19	\N	UNRANKED	9	145
2706	2003-09-13	L	AWAY	29	337	0	38	15	\N	5	6	76
2707	2003-09-20	L	HOME	29	304	16	22	UNRANKED	\N	UNRANKED	UNRANKED	77
2708	2003-09-27	L	AWAY	29	300	10	23	UNRANKED	\N	22	18	106
2709	2003-10-11	W	AWAY	29	450	20	14	UNRANKED	\N	15	UNRANKED	104
2710	2003-10-18	L	HOME	29	383	14	45	UNRANKED	\N	5	1	121
2711	2003-10-25	L	AWAY	29	438	25	27	UNRANKED	\N	UNRANKED	UNRANKED	15
2712	2003-11-01	L	HOME	29	86	0	37	UNRANKED	\N	5	11	42
2713	2003-11-08	W	HOME	29	378	27	24	UNRANKED	\N	UNRANKED	UNRANKED	83
2714	2003-11-15	W	HOME	29	211	33	14	UNRANKED	\N	UNRANKED	UNRANKED	18
2715	2003-11-29	W	AWAY	29	98	57	7	UNRANKED	\N	UNRANKED	UNRANKED	125
2716	2003-12-06	L	AWAY	29	379	12	38	UNRANKED	\N	UNRANKED	UNRANKED	126
2717	2004-09-04	L	AWAY	29	211	17	20	UNRANKED	\N	UNRANKED	UNRANKED	18
2718	2004-09-11	W	HOME	29	337	28	20	UNRANKED	\N	8	14	76
2719	2004-09-18	W	AWAY	29	304	31	24	UNRANKED	\N	UNRANKED	UNRANKED	77
2720	2004-09-25	W	HOME	29	320	38	3	UNRANKED	\N	UNRANKED	UNRANKED	143
2721	2004-10-02	L	HOME	29	300	16	41	UNRANKED	\N	15	UNRANKED	106
2722	2004-10-09	W	HOME	29	98	23	15	UNRANKED	\N	UNRANKED	UNRANKED	125
2723	2004-10-16	W	GIANTS STADIUM	29	378	27	9	UNRANKED	\N	UNRANKED	24	83
2724	2004-10-23	L	HOME	29	438	23	24	24	\N	UNRANKED	21	15
2725	2004-11-06	W	AWAY	29	389	17	13	UNRANKED	\N	9	13	128
2726	2004-11-13	L	HOME	29	450	38	41	24	\N	UNRANKED	25	104
2727	2004-11-27	L	AWAY	29	383	10	41	UNRANKED	\N	1	1	121
2728	2004-12-28	L	INSIGHT BOWL	22	358	21	38	UNRANKED	\N	UNRANKED	UNRANKED	99
2729	2005-09-03	W	AWAY	4	156	42	21	UNRANKED	\N	23	UNRANKED	104
2730	2005-09-10	W	AWAY	4	337	17	10	20	\N	3	UNRANKED	76
2731	2005-09-17	L	HOME	4	304	41	44	10	\N	UNRANKED	UNRANKED	77
2732	2005-09-24	W	AWAY	4	29	36	17	16	\N	UNRANKED	UNRANKED	143
2733	2005-10-01	W	AWAY	4	300	49	28	13	\N	22	UNRANKED	106
2734	2005-10-15	L	HOME	4	383	31	34	9	\N	1	2	121
2735	2005-10-22	W	HOME	4	94	49	23	9	\N	UNRANKED	UNRANKED	18
2736	2005-11-05	W	HOME	4	389	41	21	8	\N	UNRANKED	UNRANKED	128
2737	2005-11-12	W	HOME	4	378	42	21	7	\N	UNRANKED	UNRANKED	83
2738	2005-11-19	W	HOME	4	234	34	10	6	\N	UNRANKED	UNRANKED	126
2739	2005-11-26	W	AWAY	4	450	38	31	6	\N	UNRANKED	UNRANKED	125
2740	2006-01-02	L	FIESTA BOWL	4	291	20	34	5	\N	4	4	94
2741	2006-09-02	W	AWAY	4	111	14	10	2	\N	UNRANKED	UNRANKED	45
2742	2006-09-09	W	HOME	4	299	41	17	4	\N	19	24	101
2743	2006-09-16	L	HOME	4	337	21	47	2	\N	11	8	76
2744	2006-09-23	W	AWAY	4	304	40	37	12	\N	UNRANKED	UNRANKED	77
2745	2006-09-30	W	HOME	4	300	35	21	12	\N	UNRANKED	UNRANKED	106
2746	2006-10-07	W	HOME	4	450	31	10	12	\N	UNRANKED	UNRANKED	125
2747	2006-10-21	W	HOME	4	319	20	17	10	\N	UNRANKED	UNRANKED	135
2748	2006-10-28	W	BALTIMORE	4	378	38	14	11	\N	UNRANKED	UNRANKED	83
2749	2006-11-04	W	HOME	4	301	45	26	11	\N	UNRANKED	UNRANKED	87
2750	2006-11-11	W	AWAY	4	188	39	17	9	\N	UNRANKED	UNRANKED	2
2751	2006-11-18	W	HOME	4	90	41	9	6	\N	UNRANKED	UNRANKED	10
2752	2006-11-25	L	AWAY	4	383	24	44	6	\N	3	4	121
2753	2007-01-03	L	SUGAR BOWL	4	336	14	41	11	\N	4	3	70
2754	2007-09-01	L	HOME	4	111	3	33	UNRANKED	\N	UNRANKED	UNRANKED	45
2755	2007-09-08	L	AWAY	4	299	10	31	UNRANKED	\N	14	UNRANKED	101
2756	2007-09-15	L	AWAY	4	337	0	38	UNRANKED	\N	UNRANKED	18	76
2757	2007-09-22	L	HOME	4	346	14	31	UNRANKED	\N	UNRANKED	UNRANKED	77
2758	2007-09-29	L	AWAY	4	300	19	33	UNRANKED	\N	UNRANKED	UNRANKED	106
2759	2007-10-06	W	AWAY	4	319	20	6	UNRANKED	\N	UNRANKED	UNRANKED	135
2760	2007-10-13	L	HOME	4	274	14	27	UNRANKED	\N	4	10	15
2761	2007-10-20	L	HOME	4	383	0	38	UNRANKED	\N	13	3	121
2762	2007-11-03	L	HOME	4	378	44	46	UNRANKED	\N	UNRANKED	UNRANKED	83
2763	2007-11-10	L	HOME	4	441	24	41	UNRANKED	\N	UNRANKED	UNRANKED	2
2764	2007-11-17	W	HOME	4	426	28	7	UNRANKED	\N	UNRANKED	UNRANKED	39
2765	2007-11-24	W	AWAY	4	285	21	14	UNRANKED	\N	UNRANKED	UNRANKED	125
2766	2008-09-06	W	HOME	4	126	21	13	UNRANKED	\N	UNRANKED	UNRANKED	114
2767	2008-09-13	W	HOME	4	403	35	17	UNRANKED	\N	UNRANKED	UNRANKED	76
2768	2008-09-20	L	AWAY	4	346	7	23	UNRANKED	\N	UNRANKED	24	77
2769	2008-09-27	W	HOME	4	300	38	21	UNRANKED	\N	UNRANKED	UNRANKED	106
2770	2008-10-04	W	HOME	4	285	28	21	UNRANKED	\N	UNRANKED	UNRANKED	125
2771	2008-10-11	L	AWAY	4	100	24	29	UNRANKED	\N	22	UNRANKED	87
2772	2008-10-25	W	AWAY	4	29	33	7	UNRANKED	\N	UNRANKED	UNRANKED	143
2773	2008-11-01	L	HOME	4	156	33	36	UNRANKED	\N	UNRANKED	UNRANKED	104
2774	2008-11-08	L	AWAY	4	274	0	17	UNRANKED	\N	UNRANKED	UNRANKED	15
2775	2008-11-15	W	BALTIMORE	4	323	27	21	UNRANKED	\N	UNRANKED	UNRANKED	83
2776	2008-11-22	L	HOME	4	234	23	24	UNRANKED	\N	UNRANKED	UNRANKED	126
2777	2008-11-29	L	AWAY	4	383	3	38	UNRANKED	\N	5	3	121
2778	2008-12-24	W	HAWAII BOWL	4	233	49	21	UNRANKED	\N	UNRANKED	UNRANKED	50
2779	2009-09-05	W	HOME	4	123	35	0	23	\N	UNRANKED	UNRANKED	85
2780	2009-09-12	L	AWAY	4	403	34	38	18	\N	UNRANKED	UNRANKED	76
2781	2009-09-19	W	HOME	4	346	33	30	UNRANKED	\N	UNRANKED	UNRANKED	77
2782	2009-09-26	W	AWAY	4	148	24	21	UNRANKED	\N	UNRANKED	UNRANKED	106
2783	2009-10-03	W	HOME	4	421	37	30	UNRANKED	\N	UNRANKED	UNRANKED	143
2784	2009-10-17	L	HOME	4	383	27	34	25	\N	6	22	121
2785	2009-10-24	W	HOME	4	202	20	16	UNRANKED	\N	UNRANKED	UNRANKED	15
2786	2009-10-31	W	SAN ANTONIO	4	381	40	14	25	\N	UNRANKED	UNRANKED	145
2787	2009-11-07	L	HOME	4	323	21	23	19	\N	UNRANKED	UNRANKED	83
2788	2009-11-14	L	AWAY	4	156	22	27	UNRANKED	\N	8	15	104
2789	2009-11-21	L	HOME	4	395	30	33	UNRANKED	\N	UNRANKED	UNRANKED	32
2790	2009-11-28	L	AWAY	4	285	38	45	UNRANKED	\N	UNRANKED	UNRANKED	125
2791	2010-09-04	W	HOME	3	148	23	12	UNRANKED	\N	UNRANKED	UNRANKED	106
2792	2010-09-11	L	HOME	3	403	24	28	UNRANKED	\N	UNRANKED	UNRANKED	76
2793	2010-09-18	L	AWAY	3	346	31	34	UNRANKED	\N	UNRANKED	14	77
2794	2010-09-25	L	HOME	3	285	14	37	UNRANKED	\N	16	4	125
2795	2010-10-02	W	AWAY	3	202	31	13	UNRANKED	\N	UNRANKED	UNRANKED	15
2796	2010-10-09	W	HOME	3	156	23	17	UNRANKED	\N	UNRANKED	UNRANKED	104
2797	2010-10-16	W	HOME	3	55	44	20	UNRANKED	\N	UNRANKED	UNRANKED	148
2798	2010-10-23	L	NEW MEADOWLANDS STADIUM	3	323	17	35	UNRANKED	\N	UNRANKED	UNRANKED	83
2799	2010-10-30	L	HOME	3	432	27	28	UNRANKED	\N	UNRANKED	24	134
2800	2010-11-13	W	HOME	3	326	28	3	UNRANKED	\N	15	UNRANKED	136
2801	2010-11-20	W	YANKEE STADIUM	3	402	27	3	UNRANKED	\N	UNRANKED	UNRANKED	10
2802	2010-11-27	W	AWAY	3	329	20	16	UNRANKED	\N	UNRANKED	UNRANKED	121
2803	2010-12-31	W	SUN BOWL	3	277	33	17	UNRANKED	\N	UNRANKED	UNRANKED	74
2804	2011-09-03	L	HOME	3	416	20	23	16	\N	UNRANKED	UNRANKED	120
2805	2011-09-10	L	AWAY	3	92	31	35	UNRANKED	\N	UNRANKED	12	76
2806	2011-09-17	W	HOME	3	346	31	13	UNRANKED	\N	15	11	77
2807	2011-09-24	W	AWAY	3	432	15	12	UNRANKED	\N	UNRANKED	UNRANKED	104
2808	2011-10-01	W	AWAY	3	148	38	10	UNRANKED	\N	UNRANKED	UNRANKED	106
2809	2011-10-08	W	HOME	3	441	59	33	UNRANKED	\N	UNRANKED	UNRANKED	2
2810	2011-10-22	L	HOME	3	329	17	31	UNRANKED	\N	UNRANKED	6	121
2811	2011-10-29	W	HOME	3	323	56	14	UNRANKED	\N	UNRANKED	UNRANKED	83
2812	2011-11-05	W	AWAY	3	284	24	17	UNRANKED	\N	UNRANKED	UNRANKED	142
2813	2011-11-12	W	FEDEX FIELD	3	395	45	21	UNRANKED	\N	UNRANKED	UNRANKED	72
2814	2011-11-19	W	HOME	3	202	16	14	24	\N	UNRANKED	UNRANKED	15
2815	2011-11-26	L	AWAY	3	160	14	28	22	\N	4	7	125
2816	2011-12-29	L	CHAMPS SPORTS BOWL	3	294	14	18	UNRANKED	\N	25	23	42
2817	2012-09-01	W	DUBLIN	3	323	50	10	UNRANKED	\N	UNRANKED	UNRANKED	83
2818	2012-09-08	W	HOME	3	148	20	17	22	\N	UNRANKED	UNRANKED	106
2819	2012-09-15	W	AWAY	3	346	20	3	20	\N	10	UNRANKED	77
2820	2012-09-22	W	HOME	3	92	13	6	11	\N	18	24	76
2821	2012-10-06	W	SOLDIER FIELD	3	35	41	3	9	\N	UNRANKED	UNRANKED	74
2822	2012-10-13	W	HOME	3	160	20	13	7	\N	17	7	125
2823	2012-10-20	W	HOME	3	94	17	14	5	\N	UNRANKED	UNRANKED	18
2824	2012-10-27	W	AWAY	3	81	30	13	5	\N	8	15	95
2825	2012-11-03	W	HOME	3	375	29	26	4	\N	UNRANKED	UNRANKED	104
2826	2012-11-10	W	AWAY	3	202	21	6	4	\N	UNRANKED	UNRANKED	15
2827	2012-11-17	W	HOME	3	284	38	0	3	\N	UNRANKED	UNRANKED	142
2828	2012-11-24	W	AWAY	3	329	22	13	1	\N	UNRANKED	UNRANKED	121
2829	2013-01-07	L	BCS TITLE GAME	3	362	14	42	1	\N	2	1	4
2830	2013-08-31	W	HOME	3	351	28	6	14	\N	UNRANKED	UNRANKED	127
2831	2013-09-07	L	AWAY	3	92	30	41	14	\N	17	UNRANKED	76
2832	2013-09-14	W	AWAY	3	149	31	24	21	\N	UNRANKED	UNRANKED	106
2833	2013-09-21	W	HOME	3	346	17	13	22	\N	UNRANKED	3	77
2834	2013-09-28	L	HOME	3	81	21	35	22	\N	14	6	95
2835	2013-10-05	W	ARLINGTON	3	432	37	34	UNRANKED	\N	22	21	9
2836	2013-10-19	W	HOME	3	179	14	10	UNRANKED	\N	UNRANKED	19	121
2837	2013-10-26	W	AWAY	3	441	45	10	UNRANKED	\N	UNRANKED	UNRANKED	2
2838	2013-11-02	W	HOME	3	323	38	34	UNRANKED	\N	UNRANKED	UNRANKED	83
2839	2013-11-09	L	AWAY	3	375	21	28	24	\N	UNRANKED	UNRANKED	104
2840	2013-11-23	W	HOME	3	94	23	13	UNRANKED	\N	UNRANKED	UNRANKED	18
2841	2013-11-30	L	AWAY	3	160	20	27	25	\N	8	11	125
2842	2013-12-28	W	PINSTRIPE BOWL	3	325	29	16	25	\N	UNRANKED	UNRANKED	111
2843	2014-08-30	W	HOME	3	157	48	17	17	\N	UNRANKED	UNRANKED	107
2844	2014-09-06	W	HOME	3	92	31	0	16	\N	UNRANKED	UNRANKED	76
2845	2014-09-13	W	INDIANAPOLIS	3	149	30	14	11	\N	UNRANKED	UNRANKED	106
2846	2014-09-27	W	METLIFE STADIUM	3	415	31	15	8	\N	UNRANKED	UNRANKED	126
2847	2014-10-04	W	HOME	3	160	17	14	9	\N	14	UNRANKED	125
2848	2014-10-11	W	HOME	3	331	50	43	6	\N	UNRANKED	UNRANKED	87
2849	2014-10-18	L	AWAY	3	294	27	31	5	\N	2	5	42
2850	2014-11-01	W	FEDEX FIELD	3	323	49	39	6	\N	UNRANKED	UNRANKED	83
2851	2014-11-08	L	AWAY	3	432	31	55	8	\N	11	12	9
2852	2014-11-15	L	HOME	3	370	40	43	15	\N	UNRANKED	UNRANKED	90
2853	2014-11-22	L	HOME	3	89	28	31	UNRANKED	\N	UNRANKED	24	67
2854	2014-11-29	L	AWAY	3	421	14	49	UNRANKED	\N	UNRANKED	20	121
2855	2014-12-30	W	MUSIC CITY BOWL	3	336	31	28	UNRANKED	\N	22	UNRANKED	70
2856	2015-09-05	W	HOME	3	118	38	3	11	\N	UNRANKED	UNRANKED	129
2857	2015-09-12	W	AWAY	3	355	34	27	9	\N	UNRANKED	UNRANKED	139
2858	2015-09-19	W	HOME	3	378	30	22	8	\N	14	UNRANKED	45
2859	2015-09-26	W	HOME	3	348	62	27	6	\N	UNRANKED	UNRANKED	73
2860	2015-10-03	L	AWAY	3	143	22	24	6	\N	12	2	29
2861	2015-10-10	W	HOME	3	323	41	24	15	\N	UNRANKED	18	83
2862	2015-10-17	W	HOME	3	133	41	31	14	\N	UNRANKED	UNRANKED	121
2863	2015-10-31	W	PHILADELPHIA	3	351	24	20	9	\N	21	UNRANKED	127
2864	2015-11-07	W	AWAY	3	371	42	30	8	\N	UNRANKED	UNRANKED	104
2865	2015-11-14	W	HOME	3	153	28	7	6	\N	UNRANKED	UNRANKED	142
2866	2015-11-21	W	FENWAY PARK	3	420	19	16	5	\N	UNRANKED	UNRANKED	15
2867	2015-11-28	L	AWAY	3	160	36	38	4	\N	13	3	125
2868	2016-01-01	L	FIESTA BOWL	3	444	28	44	8	\N	7	4	94
2869	2016-09-04	L	AWAY	3	118	47	50	10	\N	UNRANKED	UNRANKED	129
2870	2016-09-10	W	HOME	3	93	39	10	18	\N	UNRANKED	UNRANKED	85
2871	2016-09-17	L	HOME	3	346	28	36	18	\N	12	UNRANKED	77
2872	2016-09-24	L	HOME	3	158	35	38	UNRANKED	\N	UNRANKED	UNRANKED	39
2873	2016-10-01	W	METLIFE STADIUM	3	166	50	33	UNRANKED	\N	UNRANKED	UNRANKED	126
2874	2016-10-08	L	AWAY	3	154	3	10	UNRANKED	\N	UNRANKED	UNRANKED	88
2875	2016-10-15	L	HOME	3	160	10	17	UNRANKED	\N	UNRANKED	12	125
2876	2016-10-29	W	HOME	3	347	30	27	UNRANKED	\N	UNRANKED	20	74
2877	2016-11-05	L	JACKSONVILLE	3	323	27	28	UNRANKED	\N	UNRANKED	UNRANKED	83
2878	2016-11-12	W	SAN ANTONIO	3	275	44	6	UNRANKED	\N	UNRANKED	UNRANKED	10
2879	2016-11-19	L	HOME	3	318	31	34	UNRANKED	\N	UNRANKED	16	140
2880	2016-11-26	L	AWAY	3	133	27	45	UNRANKED	\N	12	3	121
2881	2017-09-02	W	HOME	3	214	49	16	UNRANKED	\N	UNRANKED	UNRANKED	127
2882	2017-09-09	L	HOME	3	324	19	20	24	\N	15	2	44
2883	2017-09-16	W	AWAY	3	420	49	20	UNRANKED	\N	UNRANKED	UNRANKED	15
2884	2017-09-23	W	AWAY	3	346	38	18	UNRANKED	\N	UNRANKED	15	77
2885	2017-09-30	W	HOME	3	127	52	17	22	\N	UNRANKED	UNRANKED	75
2886	2017-10-07	W	AWAY	3	331	33	10	21	\N	UNRANKED	UNRANKED	87
2887	2017-10-21	W	HOME	3	133	49	14	13	\N	11	12	121
2888	2017-10-28	W	HOME	3	154	35	14	9	\N	14	23	88
2889	2017-11-04	W	HOME	3	153	48	37	5	\N	UNRANKED	UNRANKED	142
2890	2017-11-11	L	AWAY	3	347	8	41	3	\N	7	13	74
2891	2017-11-18	W	HOME	3	323	24	17	9	\N	UNRANKED	UNRANKED	83
2892	2017-11-25	L	AWAY	3	160	20	38	9	\N	20	20	125
2893	2018-01-01	W	CITRUS BOWL	3	179	21	17	14	\N	16	18	70
2894	2018-09-01	W	HOME	3	285	24	17	12	\N	14	14	76
2895	2018-09-08	W	HOME	3	356	24	16	8	\N	UNRANKED	UNRANKED	11
2896	2018-09-15	W	HOME	3	164	22	17	8	\N	UNRANKED	UNRANKED	138
2897	2018-09-22	W	AWAY	3	153	56	27	8	\N	UNRANKED	UNRANKED	142
2898	2018-09-29	W	HOME	3	160	38	17	8	\N	7	UNRANKED	125
2899	2018-10-06	W	AWAY	3	318	45	23	6	\N	24	UNRANKED	140
2900	2018-10-13	W	HOME	3	371	19	14	5	\N	UNRANKED	UNRANKED	104
2901	2018-10-27	W	SAN DIEGO	3	323	44	22	3	\N	UNRANKED	UNRANKED	83
2902	2018-11-03	W	AWAY	3	370	31	21	3	\N	UNRANKED	21	90
2903	2018-11-10	W	HOME	3	465	42	13	3	\N	UNRANKED	UNRANKED	42
2904	2018-11-17	W	YANKEE STADIUM	3	166	36	3	3	\N	12	15	126
2905	2018-11-24	W	AWAY	3	133	24	17	3	\N	UNRANKED	UNRANKED	121
2906	2018-12-29	L	COTTON BOWL	3	143	3	30	3	\N	2	1	29
2907	2019-09-02	W	AWAY	3	414	35	17	9	\N	UNRANKED	UNRANKED	67
2908	2019-09-14	W	HOME	3	2	66	14	7	\N	UNRANKED	UNRANKED	86
2909	2019-09-21	L	AWAY	3	324	17	23	7	\N	3	4	44
2910	2019-09-28	W	HOME	3	94	35	20	10	\N	18	UNRANKED	139
2911	2019-10-05	W	HOME	3	413	52	0	9	\N	UNRANKED	UNRANKED	16
2912	2019-10-12	W	HOME	3	133	30	27	9	\N	UNRANKED	UNRANKED	121
2913	2019-10-26	L	AWAY	3	285	14	45	8	\N	19	18	76
2914	2019-11-02	W	HOME	3	318	21	20	16	\N	UNRANKED	UNRANKED	140
2915	2019-11-09	W	AWAY	3	158	38	7	15	\N	UNRANKED	UNRANKED	39
2916	2019-11-16	W	HOME	3	323	52	20	16	\N	23	20	83
2917	2019-11-23	W	HOME	3	420	40	7	16	\N	UNRANKED	UNRANKED	15
2918	2019-11-30	W	AWAY	3	160	45	24	16	\N	UNRANKED	UNRANKED	125
2919	2019-12-28	W	CAMPING WORLD BOWL	3	350	33	9	15	\N	UNRANKED	UNRANKED	60
2920	2020-09-12	W	HOME	3	158	27	13	10	\N	UNRANKED	UNRANKED	39
2921	2020-09-19	W	HOME	3	276	52	0	7	\N	UNRANKED	UNRANKED	120
2922	2020-10-10	W	HOME	3	357	42	26	5	\N	UNRANKED	UNRANKED	42
2923	2020-10-17	W	HOME	3	414	12	7	4	\N	UNRANKED	UNRANKED	67
2924	2020-10-24	W	AWAY	3	371	45	3	3	\N	UNRANKED	UNRANKED	104
2925	2020-10-31	W	AWAY	3	214	31	13	4	\N	UNRANKED	UNRANKED	45
2926	2020-11-07	W	HOME	3	143	47	40	4	\N	1	3	29
2927	2020-11-14	W	AWAY	3	273	45	31	2	\N	UNRANKED	UNRANKED	15
2928	2020-11-27	W	AWAY	3	343	31	17	2	\N	19	18	87
2929	2020-12-05	W	HOME	3	166	45	21	2	\N	UNRANKED	UNRANKED	126
2930	2020-12-19	L	BANK OF AMERICA STADIUM	3	143	10	34	2	\N	3	3	29
2931	2021-01-01	L	ROSE BOWL	3	362	14	31	4	\N	1	1	4
\.


--
-- Data for Name: team_coaches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_coaches (id, coach_id, team_id, start_date, end_date) FROM stdin;
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, name, created_at, updated_at) FROM stdin;
1	Adrian	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
2	Air Force	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
3	Akron	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
4	Alabama	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
5	Albion	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
6	Alma	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
7	American Medical	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
8	Arizona	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
9	Arizona State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
10	Army	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
11	Ball State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
12	Baylor	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
13	Beloit	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
14	Bennett Medical	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
15	Boston College	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
16	Bowling Green	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
17	Butler	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
18	BYU	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
19	California	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
20	Carlisle	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
21	Carnegie Mellon	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
22	Case Tech	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
23	Chicago	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
24	Chicago Dental Infirmary	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
25	Chicago Medical	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
26	Chicago Physicians & Surgeons	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
27	Christian Brothers	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
28	Cincinnati	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
29	Clemson	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
30	Coe	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
31	Colorado	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
32	Connecticut	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
33	Creighton	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
34	Dartmouth	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
35	De LaSalle	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
36	Depauw	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
37	Detroit Mercy	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
38	Drake	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
39	Duke	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
40	Englewood High	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
41	Florida	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
42	Florida State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
43	Franklin	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
44	Georgia	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
45	Georgia Tech	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
46	Goshen	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
47	Great Lakes Navy	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
48	Harvard Prep	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
49	Haskell	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
50	Hawaii	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
51	Highland Views	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
52	Hillsdale	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
53	Houston	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
54	Illinois	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
55	Illinois Cycling Club	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
56	Indiana	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
57	Indianapolis Light Artillery	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
58	Iowa	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
59	Iowa Pre-Flight	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
60	Iowa State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
61	Kalamazoo	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
62	Kansas	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
63	Kirksville Osteopath	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
64	Knox	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
65	Lake Forest	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
66	Lombard	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
67	Louisville	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
68	Loyola	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
69	Loyola (LA)	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
70	LSU	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
71	Marquette	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
72	Maryland	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
73	Massachusetts	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
74	Miami (FL)	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
75	Miami (OH)	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
76	Michigan	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
77	Michigan State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
78	Minnesota	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
79	Missouri	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
80	Morningside	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
81	Morris Harvey	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
82	Mount Union	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
83	Navy	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
84	Nebraska	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
85	Nevada	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
86	New Mexico	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
87	North Carolina	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
88	North Carolina State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
89	North Division High	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
90	Northwestern	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
91	Northwestern Law School	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
92	Ohio Medical	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
93	Ohio Northern	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
94	Ohio State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
95	Oklahoma	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
96	Ole Miss	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
97	Olivet	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
98	Oregon	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
99	Oregon State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
100	Pacific	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
101	Penn State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
102	Pennsylvania	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
103	Physicians & Surgeons	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
104	Pittsburgh	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
105	Princeton	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
106	Purdue	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
107	Rice	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
108	Rose Polytechnic	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
109	Rose-Hulman	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
110	Rush Medical	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
111	Rutgers	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
112	S.B. Howard Park	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
113	Saint Louis	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
114	San Diego State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
115	SMU	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
116	South Bend Athletic Club	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
117	South Bend High School	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
118	South Carolina	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
119	South Dakota	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
120	South Florida	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
121	Southern Cal	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
122	St. Bonaventure	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
123	St. Viator	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
124	St. Vincent's	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
125	Stanford	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
126	Syracuse	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
127	Temple	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
128	Tennessee	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
129	Texas	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
130	Texas A&M	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
131	Texas Christian	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
132	Toledo A.C.	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
133	Tulane	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
134	Tulsa	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
135	UCLA	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
136	Utah	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
137	Valparaiso	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
138	Vanderbilt	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
139	Virginia	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
140	Virginia Tech	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
141	Wabash	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
142	Wake Forest	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
143	Washington	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
144	Washington & Jefferson	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
145	Washington State	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
146	Washington-St. Louis	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
147	West Virginia	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
148	Western Michigan	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
149	Western Reserve	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
150	Wisconsin	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
151	Yale	2021-09-22 05:55:17.191778+00	2021-09-22 05:55:17.191778+00
\.


--
-- Name: coaches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coaches_id_seq', 467, true);


--
-- Name: games_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.games_id_seq', 2931, true);


--
-- Name: team_coaches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_coaches_id_seq', 1, false);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_id_seq', 151, true);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: coaches coaches_first_name_last_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_first_name_last_name_key UNIQUE (first_name, last_name);


--
-- Name: coaches coaches_first_name_middle_name_last_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_first_name_middle_name_last_name_key UNIQUE (first_name, middle_name, last_name);


--
-- Name: coaches coaches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_pkey PRIMARY KEY (id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: team_coaches team_coaches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_coaches
    ADD CONSTRAINT team_coaches_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: coaches set_public_coaches_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_coaches_updated_at BEFORE UPDATE ON public.coaches FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_coaches_updated_at ON coaches; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_coaches_updated_at ON public.coaches IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: teams set_public_teams_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_teams_updated_at BEFORE UPDATE ON public.teams FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_teams_updated_at ON teams; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_teams_updated_at ON public.teams IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: games games_nd_coach_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_nd_coach_fkey FOREIGN KEY (nd_coach) REFERENCES public.coaches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: games games_opp_coach_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_opp_coach_fkey FOREIGN KEY (opp_coach) REFERENCES public.coaches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: games games_opp_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_opp_team_id_fkey FOREIGN KEY (opp_team_id) REFERENCES public.teams(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: team_coaches team_coaches_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_coaches
    ADD CONSTRAINT team_coaches_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public.coaches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: team_coaches team_coaches_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_coaches
    ADD CONSTRAINT team_coaches_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

