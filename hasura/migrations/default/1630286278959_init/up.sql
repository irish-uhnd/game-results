SET check_function_bodies = false;
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
CREATE TABLE public.coaches (
    id integer NOT NULL,
    first_name text,
    middle_name text,
    last_name text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    suffix text
);
CREATE SEQUENCE public.coaches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.coaches_id_seq OWNED BY public.coaches.id;
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
CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;
CREATE TABLE public.team_coaches (
    id integer NOT NULL,
    coach_id integer NOT NULL,
    team_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);
CREATE SEQUENCE public.team_coaches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.team_coaches_id_seq OWNED BY public.team_coaches.id;
CREATE TABLE public.teams (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;
ALTER TABLE ONLY public.coaches ALTER COLUMN id SET DEFAULT nextval('public.coaches_id_seq'::regclass);
ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);
ALTER TABLE ONLY public.team_coaches ALTER COLUMN id SET DEFAULT nextval('public.team_coaches_id_seq'::regclass);
ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);
ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_first_name_last_name_key UNIQUE (first_name, last_name);
ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_first_name_middle_name_last_name_key UNIQUE (first_name, middle_name, last_name);
ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.team_coaches
    ADD CONSTRAINT team_coaches_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);
CREATE TRIGGER set_public_coaches_updated_at BEFORE UPDATE ON public.coaches FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_coaches_updated_at ON public.coaches IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_teams_updated_at BEFORE UPDATE ON public.teams FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_teams_updated_at ON public.teams IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_nd_coach_fkey FOREIGN KEY (nd_coach) REFERENCES public.coaches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_opp_coach_fkey FOREIGN KEY (opp_coach) REFERENCES public.coaches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_opp_team_id_fkey FOREIGN KEY (opp_team_id) REFERENCES public.teams(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.team_coaches
    ADD CONSTRAINT team_coaches_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public.coaches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.team_coaches
    ADD CONSTRAINT team_coaches_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
