--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: fandom; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA fandom;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = fandom, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: answers; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
    remove_answer boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    call_to_action_id integer,
    media_image_file_name character varying(255),
    media_image_content_type character varying(255),
    media_image_file_size integer,
    media_image_updated_at timestamp without time zone,
    media_data text,
    media_type character varying(255),
    blocking boolean DEFAULT false
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: authentications; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE authentications (
    id integer NOT NULL,
    uid character varying(255),
    name character varying(255),
    oauth_token character varying(255),
    oauth_secret character varying(255),
    provider character varying(255),
    avatar character varying(255),
    oauth_expires_at timestamp without time zone,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    new boolean
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE call_to_actions (
    id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    description text,
    media_type character varying(255),
    enable_disqus boolean DEFAULT false,
    activated_at timestamp without time zone,
    secondary_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(255),
    media_image_file_name character varying(255),
    media_image_content_type character varying(255),
    media_image_file_size integer,
    media_image_updated_at timestamp without time zone,
    media_data text,
    user_id integer,
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comments; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: contest_periodicities; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE contest_periodicities (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    custom_periodicity integer,
    periodicity_type_id integer,
    contest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contest_periodicities_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE contest_periodicities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_periodicities_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE contest_periodicities_id_seq OWNED BY contest_periodicities.id;


--
-- Name: contest_points; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE contest_points (
    id integer NOT NULL,
    points integer,
    user_id integer,
    contest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contest_points_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE contest_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_points_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE contest_points_id_seq OWNED BY contest_points.id;


--
-- Name: contest_tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE contest_tags (
    id integer NOT NULL,
    tag_id integer,
    contest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contest_tags_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE contest_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE contest_tags_id_seq OWNED BY contest_tags.id;


--
-- Name: contests; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE contests (
    id integer NOT NULL,
    generated boolean DEFAULT false,
    "boolean" boolean DEFAULT false,
    title character varying(255) NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    property_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    conversion_rate integer DEFAULT 1
);


--
-- Name: contests_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE contests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contests_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE contests_id_seq OWNED BY contests.id;


--
-- Name: downloads; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: events; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    file_name character varying(255),
    method_name character varying(255),
    line_number character varying(255),
    params text,
    data text,
    event_hash character varying(255),
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    "timestamp" timestamp without time zone
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE home_launchers (
    id integer NOT NULL,
    description text,
    button character varying(255),
    url character varying(255),
    enable boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    anchor boolean
);


--
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instant_win_prizes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE instant_win_prizes (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    contest_periodicity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone
);


--
-- Name: instant_win_prizes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE instant_win_prizes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instant_win_prizes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE instant_win_prizes_id_seq OWNED BY instant_win_prizes.id;


--
-- Name: instantwins; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    contest_periodicity_id integer NOT NULL,
    time_to_win_start timestamp without time zone NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    time_to_win_end timestamp without time zone,
    unique_id character varying(255)
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interactions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: notices; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying(255) NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying(255)
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying(255) NOT NULL,
    refresh_token character varying(255),
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying(255)
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE oauth_applications (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    secret character varying(255) NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periodicity_types; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE periodicity_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    period integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: periodicity_types_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE periodicity_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periodicity_types_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE periodicity_types_id_seq OWNED BY periodicity_types.id;


--
-- Name: periods; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE periods (
    id integer NOT NULL,
    kind character varying(255),
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: periods_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: plays; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    text_before character varying(255),
    text_after character varying(255)
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: playticket_events; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE playticket_events (
    id integer NOT NULL,
    user_id integer,
    contest_periodicity_id integer,
    points_spent integer,
    used_at timestamp without time zone,
    winner boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instantwin_id integer
);


--
-- Name: playticket_events_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE playticket_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: playticket_events_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE playticket_events_id_seq OWNED BY playticket_events.id;


--
-- Name: promocodes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    property_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE quizzes (
    id integer NOT NULL,
    question character varying(255) NOT NULL,
    cache_correct_answer integer DEFAULT 0,
    cache_wrong_answer integer DEFAULT 0,
    quiz_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    one_shot boolean DEFAULT true
);


--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: rankings; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE rankings (
    id integer NOT NULL,
    reward_id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    period character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rank_type character varying(255),
    people_filter character varying(255)
);


--
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: registrations; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE registrations (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE registrations_id_seq OWNED BY registrations.id;


--
-- Name: releasing_files; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE releasing_files (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_file_name character varying(255),
    file_content_type character varying(255),
    file_file_size integer,
    file_updated_at timestamp without time zone
);


--
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    title character varying(255),
    short_description text,
    long_description text,
    button_label character varying(255),
    cost integer,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    video_url character varying(255),
    media_type character varying(255),
    currency_id integer,
    spendable boolean,
    countable boolean,
    numeric_display boolean,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    preview_image_file_name character varying(255),
    preview_image_content_type character varying(255),
    preview_image_file_size integer,
    preview_image_updated_at timestamp without time zone,
    main_image_file_name character varying(255),
    main_image_content_type character varying(255),
    main_image_file_size integer,
    main_image_updated_at timestamp without time zone,
    media_file_file_name character varying(255),
    media_file_content_type character varying(255),
    media_file_file_size integer,
    media_file_updated_at timestamp without time zone,
    not_awarded_image_file_name character varying(255),
    not_awarded_image_content_type character varying(255),
    not_awarded_image_file_size integer,
    not_awarded_image_updated_at timestamp without time zone,
    not_winnable_image_file_name character varying(255),
    not_winnable_image_content_type character varying(255),
    not_winnable_image_file_size integer,
    not_winnable_image_updated_at timestamp without time zone
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE shares (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    picture_file_name character varying(255),
    picture_content_type character varying(255),
    picture_file_size integer,
    picture_updated_at timestamp without time zone,
    providers json
);


--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tag_fields; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE tag_fields (
    id integer NOT NULL,
    tag_id integer,
    name character varying(255),
    field_type character varying(255),
    value text,
    upload_file_name character varying(255),
    upload_content_type character varying(255),
    upload_file_size integer,
    upload_updated_at timestamp without time zone
);


--
-- Name: tag_fields_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE tag_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE tag_fields_id_seq OWNED BY tag_fields.id;


--
-- Name: tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE uploads (
    id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    releasing boolean,
    releasing_description text,
    privacy boolean,
    privacy_description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    releasing_document_file_name character varying(255),
    releasing_document_content_type character varying(255),
    releasing_document_file_size integer,
    releasing_document_updated_at timestamp without time zone,
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE user_counters (
    id integer NOT NULL,
    name character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    counters json
);


--
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE user_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    interaction_id integer NOT NULL,
    answer_id integer,
    counter integer DEFAULT 1,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "like" boolean,
    outcome text,
    aux json
);


--
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE user_rewards (
    id integer NOT NULL,
    user_id integer,
    reward_id integer,
    available boolean,
    counter integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    period_id integer
);


--
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    avatar_selected character varying(255) DEFAULT 'upload'::character varying,
    swid character varying(255),
    privacy boolean,
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    role character varying(255),
    authentication_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    cap character varying(255),
    location character varying(255),
    province character varying(255),
    address character varying(255),
    phone character varying(255),
    number character varying(255),
    rule boolean,
    birth_date date,
    username character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE vote_rankings (
    id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    period character varying(255),
    rank_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    oneshot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = public, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
    remove_answer boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    call_to_action_id integer,
    media_image_file_name character varying(255),
    media_image_content_type character varying(255),
    media_image_file_size integer,
    media_image_updated_at timestamp without time zone,
    media_data text,
    media_type character varying(255),
    blocking boolean DEFAULT false
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authentications (
    id integer NOT NULL,
    uid character varying(255),
    name character varying(255),
    oauth_token character varying(255),
    oauth_secret character varying(255),
    provider character varying(255),
    avatar character varying(255),
    oauth_expires_at timestamp without time zone,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    new boolean,
    aux json
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE call_to_actions (
    id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    description text,
    media_type character varying(255),
    enable_disqus boolean DEFAULT false,
    activated_at timestamp without time zone,
    secondary_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(255),
    media_image_file_name character varying(255),
    media_image_content_type character varying(255),
    media_image_file_size integer,
    media_image_updated_at timestamp without time zone,
    media_data text,
    user_id integer,
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: contest_periodicities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contest_periodicities (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    custom_periodicity integer,
    periodicity_type_id integer,
    contest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contest_periodicities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contest_periodicities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_periodicities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contest_periodicities_id_seq OWNED BY contest_periodicities.id;


--
-- Name: contest_points; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contest_points (
    id integer NOT NULL,
    points integer,
    user_id integer,
    contest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contest_points_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contest_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contest_points_id_seq OWNED BY contest_points.id;


--
-- Name: contest_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contest_tags (
    id integer NOT NULL,
    tag_id integer,
    contest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contest_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contest_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contest_tags_id_seq OWNED BY contest_tags.id;


--
-- Name: contests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contests (
    id integer NOT NULL,
    generated boolean DEFAULT false,
    "boolean" boolean DEFAULT false,
    title character varying(255) NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    property_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    conversion_rate integer DEFAULT 1
);


--
-- Name: contests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contests_id_seq OWNED BY contests.id;


--
-- Name: downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    file_name character varying(255),
    method_name character varying(255),
    line_number character varying(255),
    params text,
    data text,
    event_hash character varying(255),
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    "timestamp" timestamp without time zone
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE home_launchers (
    id integer NOT NULL,
    description text,
    button character varying(255),
    url character varying(255),
    enable boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    anchor boolean
);


--
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instant_win_prizes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instant_win_prizes (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    contest_periodicity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone
);


--
-- Name: instant_win_prizes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instant_win_prizes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instant_win_prizes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instant_win_prizes_id_seq OWNED BY instant_win_prizes.id;


--
-- Name: instantwins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    contest_periodicity_id integer NOT NULL,
    time_to_win_start timestamp without time zone NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    time_to_win_end timestamp without time zone,
    unique_id character varying(255)
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: notices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying(255) NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying(255)
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying(255) NOT NULL,
    refresh_token character varying(255),
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying(255)
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_applications (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    secret character varying(255) NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periodicity_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE periodicity_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    period integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: periodicity_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE periodicity_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periodicity_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE periodicity_types_id_seq OWNED BY periodicity_types.id;


--
-- Name: periods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE periods (
    id integer NOT NULL,
    kind character varying(255),
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: plays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    text_before character varying(255),
    text_after character varying(255)
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: playticket_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE playticket_events (
    id integer NOT NULL,
    user_id integer,
    contest_periodicity_id integer,
    points_spent integer,
    used_at timestamp without time zone,
    winner boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instantwin_id integer
);


--
-- Name: playticket_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE playticket_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: playticket_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE playticket_events_id_seq OWNED BY playticket_events.id;


--
-- Name: promocodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    property_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quizzes (
    id integer NOT NULL,
    question character varying(255) NOT NULL,
    cache_correct_answer integer DEFAULT 0,
    cache_wrong_answer integer DEFAULT 0,
    quiz_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    one_shot boolean DEFAULT true
);


--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: rankings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rankings (
    id integer NOT NULL,
    reward_id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    period character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rank_type character varying(255),
    people_filter character varying(255)
);


--
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE registrations (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE registrations_id_seq OWNED BY registrations.id;


--
-- Name: releasing_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE releasing_files (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_file_name character varying(255),
    file_content_type character varying(255),
    file_file_size integer,
    file_updated_at timestamp without time zone
);


--
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    title character varying(255),
    short_description text,
    long_description text,
    button_label character varying(255),
    cost integer,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    video_url character varying(255),
    media_type character varying(255),
    currency_id integer,
    spendable boolean,
    countable boolean,
    numeric_display boolean,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    preview_image_file_name character varying(255),
    preview_image_content_type character varying(255),
    preview_image_file_size integer,
    preview_image_updated_at timestamp without time zone,
    main_image_file_name character varying(255),
    main_image_content_type character varying(255),
    main_image_file_size integer,
    main_image_updated_at timestamp without time zone,
    media_file_file_name character varying(255),
    media_file_content_type character varying(255),
    media_file_file_size integer,
    media_file_updated_at timestamp without time zone,
    not_awarded_image_file_name character varying(255),
    not_awarded_image_content_type character varying(255),
    not_awarded_image_file_size integer,
    not_awarded_image_updated_at timestamp without time zone,
    not_winnable_image_file_name character varying(255),
    not_winnable_image_content_type character varying(255),
    not_winnable_image_file_size integer,
    not_winnable_image_updated_at timestamp without time zone
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shares (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    picture_file_name character varying(255),
    picture_content_type character varying(255),
    picture_file_size integer,
    picture_updated_at timestamp without time zone,
    providers json
);


--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tag_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_fields (
    id integer NOT NULL,
    tag_id integer,
    name character varying(255),
    type character varying(255),
    value text,
    upload_file_name character varying(255),
    upload_content_type character varying(255),
    upload_file_size integer,
    upload_updated_at timestamp without time zone
);


--
-- Name: tag_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_fields_id_seq OWNED BY tag_fields.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    belongs_tag_id integer
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uploads (
    id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    releasing boolean,
    releasing_description text,
    privacy boolean,
    privacy_description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    releasing_document_file_name character varying(255),
    releasing_document_content_type character varying(255),
    releasing_document_file_size integer,
    releasing_document_updated_at timestamp without time zone,
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_counters (
    id integer NOT NULL,
    name character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    counters json
);


--
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    interaction_id integer NOT NULL,
    answer_id integer,
    counter integer DEFAULT 1,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "like" boolean,
    outcome text,
    aux json
);


--
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_rewards (
    id integer NOT NULL,
    user_id integer,
    reward_id integer,
    available boolean,
    counter integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    period_id integer
);


--
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    avatar_selected character varying(255) DEFAULT 'upload'::character varying,
    swid character varying(255),
    privacy boolean,
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    role character varying(255),
    authentication_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    cap character varying(255),
    location character varying(255),
    province character varying(255),
    address character varying(255),
    phone character varying(255),
    number character varying(255),
    rule boolean,
    birth_date date,
    username character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vote_rankings (
    id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    period character varying(255),
    rank_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    oneshot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = fandom, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY contest_periodicities ALTER COLUMN id SET DEFAULT nextval('contest_periodicities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY contest_points ALTER COLUMN id SET DEFAULT nextval('contest_points_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY contest_tags ALTER COLUMN id SET DEFAULT nextval('contest_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY contests ALTER COLUMN id SET DEFAULT nextval('contests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY instant_win_prizes ALTER COLUMN id SET DEFAULT nextval('instant_win_prizes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY periodicity_types ALTER COLUMN id SET DEFAULT nextval('periodicity_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY playticket_events ALTER COLUMN id SET DEFAULT nextval('playticket_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY registrations ALTER COLUMN id SET DEFAULT nextval('registrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY tag_fields ALTER COLUMN id SET DEFAULT nextval('tag_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contest_periodicities ALTER COLUMN id SET DEFAULT nextval('contest_periodicities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contest_points ALTER COLUMN id SET DEFAULT nextval('contest_points_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contest_tags ALTER COLUMN id SET DEFAULT nextval('contest_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contests ALTER COLUMN id SET DEFAULT nextval('contests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instant_win_prizes ALTER COLUMN id SET DEFAULT nextval('instant_win_prizes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY periodicity_types ALTER COLUMN id SET DEFAULT nextval('periodicity_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY playticket_events ALTER COLUMN id SET DEFAULT nextval('playticket_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrations ALTER COLUMN id SET DEFAULT nextval('registrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_fields ALTER COLUMN id SET DEFAULT nextval('tag_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = fandom, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: contest_periodicities_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_periodicities
    ADD CONSTRAINT contest_periodicities_pkey PRIMARY KEY (id);


--
-- Name: contest_points_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_points
    ADD CONSTRAINT contest_points_pkey PRIMARY KEY (id);


--
-- Name: contest_tags_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_tags
    ADD CONSTRAINT contest_tags_pkey PRIMARY KEY (id);


--
-- Name: contests_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contests
    ADD CONSTRAINT contests_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instant_win_prizes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instant_win_prizes
    ADD CONSTRAINT instant_win_prizes_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periodicity_types_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periodicity_types
    ADD CONSTRAINT periodicity_types_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: playticket_events_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY playticket_events
    ADD CONSTRAINT playticket_events_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: registrations_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tag_fields_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_fields
    ADD CONSTRAINT tag_fields_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: contest_periodicities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_periodicities
    ADD CONSTRAINT contest_periodicities_pkey PRIMARY KEY (id);


--
-- Name: contest_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_points
    ADD CONSTRAINT contest_points_pkey PRIMARY KEY (id);


--
-- Name: contest_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_tags
    ADD CONSTRAINT contest_tags_pkey PRIMARY KEY (id);


--
-- Name: contests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contests
    ADD CONSTRAINT contests_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instant_win_prizes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instant_win_prizes
    ADD CONSTRAINT instant_win_prizes_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periodicity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periodicity_types
    ADD CONSTRAINT periodicity_types_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: playticket_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY playticket_events
    ADD CONSTRAINT playticket_events_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tag_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_fields
    ADD CONSTRAINT tag_fields_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = fandom, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree (((aux ->> 'call_to_action_id'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = public, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree (((aux ->> 'call_to_action_id'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "public";

INSERT INTO schema_migrations (version) VALUES ('20130318164138');

INSERT INTO schema_migrations (version) VALUES ('20131122104219');

INSERT INTO schema_migrations (version) VALUES ('20131122134758');

INSERT INTO schema_migrations (version) VALUES ('20131122135000');

INSERT INTO schema_migrations (version) VALUES ('20131122135205');

INSERT INTO schema_migrations (version) VALUES ('20131122135412');

INSERT INTO schema_migrations (version) VALUES ('20131122144701');

INSERT INTO schema_migrations (version) VALUES ('20131122163002');

INSERT INTO schema_migrations (version) VALUES ('20131204110458');

INSERT INTO schema_migrations (version) VALUES ('20131204135640');

INSERT INTO schema_migrations (version) VALUES ('20131212090607');

INSERT INTO schema_migrations (version) VALUES ('20140114085855');

INSERT INTO schema_migrations (version) VALUES ('20140114093550');

INSERT INTO schema_migrations (version) VALUES ('20140114094054');

INSERT INTO schema_migrations (version) VALUES ('20140128094904');

INSERT INTO schema_migrations (version) VALUES ('20140129094208');

INSERT INTO schema_migrations (version) VALUES ('20140129132208');

INSERT INTO schema_migrations (version) VALUES ('20140207111529');

INSERT INTO schema_migrations (version) VALUES ('20140210081328');

INSERT INTO schema_migrations (version) VALUES ('20140210082727');

INSERT INTO schema_migrations (version) VALUES ('20140304135333');

INSERT INTO schema_migrations (version) VALUES ('20140304170936');

INSERT INTO schema_migrations (version) VALUES ('20140304172535');

INSERT INTO schema_migrations (version) VALUES ('20140304172604');

INSERT INTO schema_migrations (version) VALUES ('20140306104747');

INSERT INTO schema_migrations (version) VALUES ('20140306112853');

INSERT INTO schema_migrations (version) VALUES ('20140306113929');

INSERT INTO schema_migrations (version) VALUES ('20140311145158');

INSERT INTO schema_migrations (version) VALUES ('20140313085914');

INSERT INTO schema_migrations (version) VALUES ('20140324154512');

INSERT INTO schema_migrations (version) VALUES ('20140324154544');

INSERT INTO schema_migrations (version) VALUES ('20140324164314');

INSERT INTO schema_migrations (version) VALUES ('20140325090252');

INSERT INTO schema_migrations (version) VALUES ('20140325150835');

INSERT INTO schema_migrations (version) VALUES ('20140401154249');

INSERT INTO schema_migrations (version) VALUES ('20140519071411');

INSERT INTO schema_migrations (version) VALUES ('20140519093001');

INSERT INTO schema_migrations (version) VALUES ('20140523075749');

INSERT INTO schema_migrations (version) VALUES ('20140528093102');

INSERT INTO schema_migrations (version) VALUES ('20140528093124');

INSERT INTO schema_migrations (version) VALUES ('20140528142808');

INSERT INTO schema_migrations (version) VALUES ('20140529075725');

INSERT INTO schema_migrations (version) VALUES ('20140603151408');

INSERT INTO schema_migrations (version) VALUES ('20140609124641');

INSERT INTO schema_migrations (version) VALUES ('20140609141653');

INSERT INTO schema_migrations (version) VALUES ('20140609141711');

INSERT INTO schema_migrations (version) VALUES ('20140609145043');

INSERT INTO schema_migrations (version) VALUES ('20140609145127');

INSERT INTO schema_migrations (version) VALUES ('20140609145753');

INSERT INTO schema_migrations (version) VALUES ('20140611125838');

INSERT INTO schema_migrations (version) VALUES ('20140617143837');

INSERT INTO schema_migrations (version) VALUES ('20140619082008');

INSERT INTO schema_migrations (version) VALUES ('20140620093048');

INSERT INTO schema_migrations (version) VALUES ('20140625132747');

INSERT INTO schema_migrations (version) VALUES ('20140625132815');

INSERT INTO schema_migrations (version) VALUES ('20140625155307');

INSERT INTO schema_migrations (version) VALUES ('20140626133513');

INSERT INTO schema_migrations (version) VALUES ('20140626140922');

INSERT INTO schema_migrations (version) VALUES ('20140626142603');

INSERT INTO schema_migrations (version) VALUES ('20140627105239');

INSERT INTO schema_migrations (version) VALUES ('20140701080832');

INSERT INTO schema_migrations (version) VALUES ('20140701095215');

INSERT INTO schema_migrations (version) VALUES ('20140708103747');

INSERT INTO schema_migrations (version) VALUES ('20140708123117');

INSERT INTO schema_migrations (version) VALUES ('20140708155243');

INSERT INTO schema_migrations (version) VALUES ('20140708162117');

INSERT INTO schema_migrations (version) VALUES ('20140709084527');

INSERT INTO schema_migrations (version) VALUES ('20140709084646');

INSERT INTO schema_migrations (version) VALUES ('20140709091132');

INSERT INTO schema_migrations (version) VALUES ('20140709091255');

INSERT INTO schema_migrations (version) VALUES ('20140709091422');

INSERT INTO schema_migrations (version) VALUES ('20140709123136');

INSERT INTO schema_migrations (version) VALUES ('20140709123235');

INSERT INTO schema_migrations (version) VALUES ('20140709123320');

INSERT INTO schema_migrations (version) VALUES ('20140709152530');

INSERT INTO schema_migrations (version) VALUES ('20140710090744');

INSERT INTO schema_migrations (version) VALUES ('20140710092725');

INSERT INTO schema_migrations (version) VALUES ('20140710103901');

INSERT INTO schema_migrations (version) VALUES ('20140710133905');

INSERT INTO schema_migrations (version) VALUES ('20140715071424');

INSERT INTO schema_migrations (version) VALUES ('20140715155143');

INSERT INTO schema_migrations (version) VALUES ('20140717073247');

INSERT INTO schema_migrations (version) VALUES ('20140717074928');

INSERT INTO schema_migrations (version) VALUES ('20140717075333');

INSERT INTO schema_migrations (version) VALUES ('20140717080150');

INSERT INTO schema_migrations (version) VALUES ('20140717154512');

INSERT INTO schema_migrations (version) VALUES ('20140718080110');

INSERT INTO schema_migrations (version) VALUES ('20140722141157');

INSERT INTO schema_migrations (version) VALUES ('20140722162759');

INSERT INTO schema_migrations (version) VALUES ('20140723151953');

INSERT INTO schema_migrations (version) VALUES ('20140723152239');

INSERT INTO schema_migrations (version) VALUES ('20140724075422');

INSERT INTO schema_migrations (version) VALUES ('20140724080412');

INSERT INTO schema_migrations (version) VALUES ('20140806130040');

INSERT INTO schema_migrations (version) VALUES ('20140807094850');

INSERT INTO schema_migrations (version) VALUES ('20140807095109');

INSERT INTO schema_migrations (version) VALUES ('20140825141441');

INSERT INTO schema_migrations (version) VALUES ('20140825150931');

INSERT INTO schema_migrations (version) VALUES ('20140826071500');

INSERT INTO schema_migrations (version) VALUES ('20140826071530');

INSERT INTO schema_migrations (version) VALUES ('20140826134544');

INSERT INTO schema_migrations (version) VALUES ('20140826155607');

INSERT INTO schema_migrations (version) VALUES ('20140827144001');

INSERT INTO schema_migrations (version) VALUES ('20140827144235');

INSERT INTO schema_migrations (version) VALUES ('20140827144323');

INSERT INTO schema_migrations (version) VALUES ('20140829144118');

INSERT INTO schema_migrations (version) VALUES ('20140902155949');

INSERT INTO schema_migrations (version) VALUES ('20140902160245');

INSERT INTO schema_migrations (version) VALUES ('20140903070150');

INSERT INTO schema_migrations (version) VALUES ('20140903070224');

INSERT INTO schema_migrations (version) VALUES ('20140903070245');

INSERT INTO schema_migrations (version) VALUES ('20140904073030');

INSERT INTO schema_migrations (version) VALUES ('20140904135353');

INSERT INTO schema_migrations (version) VALUES ('20140904135454');

INSERT INTO schema_migrations (version) VALUES ('20140908093920');

INSERT INTO schema_migrations (version) VALUES ('20140909152010');

INSERT INTO schema_migrations (version) VALUES ('20140910084115');

INSERT INTO schema_migrations (version) VALUES ('20140911085734');

INSERT INTO schema_migrations (version) VALUES ('20140911124628');

INSERT INTO schema_migrations (version) VALUES ('20140917074818');