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
-- Name: ballando; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ballando;


--
-- Name: braun_ic; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA braun_ic;


--
-- Name: coin; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA coin;


--
-- Name: disney; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA disney;


--
-- Name: fandom; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA fandom;


--
-- Name: forte; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA forte;


--
-- Name: intesa_expo; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA intesa_expo;


--
-- Name: maxibon; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA maxibon;


--
-- Name: orzoro; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA orzoro;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = ballando, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: answers; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    "timestamp" timestamp without time zone,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: events_id_seq1; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE events_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq1; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE events_id_seq1 OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: ballando; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: ballando; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: ballando; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = braun_ic, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: braun_ic; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: braun_ic; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = coin, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: coin; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: coin; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: coin; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = disney, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: disney; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: disney; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: disney; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = fandom, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
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
-- Name: attachments; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


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
    new boolean,
    aux json
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
-- Name: basics; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
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
-- Name: comment_likes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


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
    attachment_updated_at timestamp without time zone,
    ical_fields json
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
-- Name: easyadmin_stats; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
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
-- Name: instantwin_interactions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
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
-- Name: interaction_call_to_actions; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


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
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
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
-- Name: links; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


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
    updated_at timestamp without time zone NOT NULL,
    aux json
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
-- Name: pins; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: promocodes; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
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
-- Name: random_resources; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
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
-- Name: tags; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
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
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
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
    approved boolean,
    aux json
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
    updated_at timestamp without time zone NOT NULL,
    aux json
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
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
-- Name: view_counters; Type: TABLE; Schema: fandom; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: fandom; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: fandom; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


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
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
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


SET search_path = forte, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: forte; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: forte; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: forte; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = intesa_expo, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: intesa_expo; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: intesa_expo; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = maxibon, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: maxibon; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: maxibon; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


SET search_path = orzoro, pg_catalog;

--
-- Name: answers; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    text character varying(255) NOT NULL,
    correct boolean,
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
    blocking boolean DEFAULT false,
    aux json
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: attachments; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authentications; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: basics; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


--
-- Name: call_to_action_tags; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE call_to_action_tags (
    id integer NOT NULL,
    call_to_action_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE call_to_action_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_action_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE call_to_action_tags_id_seq OWNED BY call_to_action_tags.id;


--
-- Name: call_to_actions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE call_to_actions_id_seq OWNED BY call_to_actions.id;


--
-- Name: checks; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE checks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checks_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checks_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE checks_id_seq OWNED BY checks.id;


--
-- Name: comment_likes; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


--
-- Name: comments; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    must_be_approved boolean DEFAULT false,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: downloads; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    ical_fields json
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: easyadmin_stats; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: home_launchers; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: home_launchers_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE home_launchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: home_launchers_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE home_launchers_id_seq OWNED BY home_launchers.id;


--
-- Name: instantwin_interactions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
);


--
-- Name: instantwins_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE instantwins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwins_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE instantwins_id_seq OWNED BY instantwins.id;


--
-- Name: interaction_call_to_actions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


--
-- Name: interactions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE interactions (
    id integer NOT NULL,
    name character varying(255),
    seconds integer DEFAULT 0,
    when_show_interaction character varying(255),
    required_to_complete boolean,
    resource_id integer,
    resource_type character varying(255),
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE interactions_id_seq OWNED BY interactions.id;


--
-- Name: likes; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: links; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: notices; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    user_id integer,
    html_notice text,
    last_sent timestamp without time zone,
    viewed boolean DEFAULT false,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: periods; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: periods_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: pins; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plays_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE plays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plays_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE plays_id_seq OWNED BY plays.id;


--
-- Name: promocodes; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promocodes_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE promocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE promocodes_id_seq OWNED BY promocodes.id;


--
-- Name: quizzes; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: random_resources; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


--
-- Name: rankings; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE rankings_id_seq OWNED BY rankings.id;


--
-- Name: releasing_files; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: releasing_files_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE releasing_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releasing_files_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE releasing_files_id_seq OWNED BY releasing_files.id;


--
-- Name: reward_tags; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE reward_tags (
    id integer NOT NULL,
    tag_id integer,
    reward_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reward_tags_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE reward_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reward_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE reward_tags_id_seq OWNED BY reward_tags.id;


--
-- Name: rewards; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: shares; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: shares_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: synced_log_files; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE synced_log_files (
    id integer NOT NULL,
    pid character varying(255),
    server_hostname character varying(255),
    "timestamp" timestamp without time zone
);


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE synced_log_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synced_log_files_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE synced_log_files_id_seq OWNED BY synced_log_files.id;


--
-- Name: tags; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tags; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE tags_tags (
    id integer NOT NULL,
    tag_id integer,
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_tags_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE tags_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE tags_tags_id_seq OWNED BY tags_tags.id;


--
-- Name: uploads; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_comment_interactions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE user_comment_interactions (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean,
    aux json
);


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE user_comment_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_comment_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE user_comment_interactions_id_seq OWNED BY user_comment_interactions.id;


--
-- Name: user_counters; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: user_counters_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE user_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE user_counters_id_seq OWNED BY user_counters.id;


--
-- Name: user_interactions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: user_interactions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE user_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE user_interactions_id_seq OWNED BY user_interactions.id;


--
-- Name: user_rewards; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE user_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE user_rewards_id_seq OWNED BY user_rewards.id;


--
-- Name: user_upload_interactions; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE user_upload_interactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    call_to_action_id integer NOT NULL,
    upload_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aux json
);


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE user_upload_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upload_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE user_upload_interactions_id_seq OWNED BY user_upload_interactions.id;


--
-- Name: users; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_counters; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


--
-- Name: vote_ranking_tags; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE vote_ranking_tags (
    id integer NOT NULL,
    tag_id integer,
    vote_ranking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE vote_ranking_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_ranking_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE vote_ranking_tags_id_seq OWNED BY vote_ranking_tags.id;


--
-- Name: vote_rankings; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: vote_rankings_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE vote_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
--

ALTER SEQUENCE vote_rankings_id_seq OWNED BY vote_rankings.id;


--
-- Name: votes; Type: TABLE; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    title character varying(255),
    vote_min integer DEFAULT 1,
    vote_max integer DEFAULT 10,
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: orzoro; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: orzoro; Owner: -
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
    blocking boolean DEFAULT false,
    aux json
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
-- Name: attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


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
-- Name: basics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE basics (
    id integer NOT NULL,
    basic_type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: basics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE basics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE basics_id_seq OWNED BY basics.id;


--
-- Name: cache_rankings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cache_rankings (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    user_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cache_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cache_rankings_id_seq OWNED BY cache_rankings.id;


--
-- Name: cache_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cache_versions (
    id integer NOT NULL,
    name character varying(255),
    version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json
);


--
-- Name: cache_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cache_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cache_versions_id_seq OWNED BY cache_versions.id;


--
-- Name: cache_votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cache_votes (
    id integer NOT NULL,
    version integer,
    call_to_action_id integer,
    vote_count integer,
    vote_sum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '{}'::json,
    gallery_name text
);


--
-- Name: cache_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cache_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cache_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cache_votes_id_seq OWNED BY cache_votes.id;


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
    releasing_file_id integer,
    approved boolean,
    thumbnail_file_name character varying(255),
    thumbnail_content_type character varying(255),
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    user_id integer,
    aux json,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json
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
-- Name: comment_likes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comment_likes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying,
    comment_id integer
);


--
-- Name: comment_likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comment_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_likes_id_seq OWNED BY comment_likes.id;


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
    attachment_updated_at timestamp without time zone,
    ical_fields json
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
-- Name: easyadmin_stats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE easyadmin_stats (
    id integer NOT NULL,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "values" json DEFAULT '{}'::json
);


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE easyadmin_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: easyadmin_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE easyadmin_stats_id_seq OWNED BY easyadmin_stats.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    session_id character varying(255),
    pid integer,
    message character varying(255),
    request_uri character varying(255),
    "timestamp" timestamp without time zone,
    level character varying(255),
    tenant character varying(255),
    user_id integer,
    data json
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
-- Name: instantwin_interactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instantwin_interactions (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instantwin_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instantwin_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instantwin_interactions_id_seq OWNED BY instantwin_interactions.id;


--
-- Name: instantwins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instantwins (
    id integer NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_to timestamp without time zone,
    reward_info json,
    won boolean,
    instantwin_interaction_id integer
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
-- Name: interaction_call_to_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE interaction_call_to_actions (
    id integer NOT NULL,
    interaction_id integer,
    call_to_action_id integer,
    condition json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ordering integer
);


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE interaction_call_to_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interaction_call_to_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE interaction_call_to_actions_id_seq OWNED BY interaction_call_to_actions.id;


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
    call_to_action_id integer,
    aux json,
    stored_for_anonymous boolean,
    registration_needed boolean,
    interaction_positioning character varying
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
-- Name: links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying(255),
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


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
    updated_at timestamp without time zone NOT NULL,
    aux json
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
-- Name: pins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pins (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coordinates json
);


--
-- Name: pins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pins_id_seq OWNED BY pins.id;


--
-- Name: plays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plays (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: promocodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE promocodes (
    id integer NOT NULL,
    title character varying(255),
    code character varying(255),
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
-- Name: random_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE random_resources (
    id integer NOT NULL,
    tag text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: random_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE random_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: random_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE random_resources_id_seq OWNED BY random_resources.id;


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
    not_winnable_image_updated_at timestamp without time zone,
    call_to_action_id integer,
    aux json,
    extra_fields json DEFAULT '{}'::json
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
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    extra_fields json DEFAULT '{}'::json,
    title character varying(255),
    slug character varying(255)
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
    other_tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    upload_number integer,
    watermark_file_name character varying(255),
    watermark_content_type character varying(255),
    watermark_file_size integer,
    watermark_updated_at timestamp without time zone,
    title_needed boolean DEFAULT false
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
    approved boolean,
    aux json,
    like_counter integer DEFAULT 0
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
    updated_at timestamp without time zone NOT NULL,
    aux json
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
    username character varying(255),
    newsletter boolean,
    avatar_selected_url character varying(255),
    aux json,
    gender character varying(255),
    anonymous_id character varying
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
-- Name: view_counters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE view_counters (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_type character varying(255),
    ref_id integer,
    counter integer,
    aux json
);


--
-- Name: view_counters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE view_counters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: view_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE view_counters_id_seq OWNED BY view_counters.id;


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
    one_shot boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extra_fields json
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


SET search_path = ballando, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ballando; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = braun_ic, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: braun_ic; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = coin, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: coin; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = disney, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: disney; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = fandom, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


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

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


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

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


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

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


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

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


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

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: fandom; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


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

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


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


SET search_path = forte, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forte; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = intesa_expo, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: intesa_expo; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = maxibon, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: maxibon; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


SET search_path = orzoro, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY call_to_action_tags ALTER COLUMN id SET DEFAULT nextval('call_to_action_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY call_to_actions ALTER COLUMN id SET DEFAULT nextval('call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY checks ALTER COLUMN id SET DEFAULT nextval('checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY home_launchers ALTER COLUMN id SET DEFAULT nextval('home_launchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY interactions ALTER COLUMN id SET DEFAULT nextval('interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY promocodes ALTER COLUMN id SET DEFAULT nextval('promocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY releasing_files ALTER COLUMN id SET DEFAULT nextval('releasing_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY reward_tags ALTER COLUMN id SET DEFAULT nextval('reward_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY synced_log_files ALTER COLUMN id SET DEFAULT nextval('synced_log_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY tags_tags ALTER COLUMN id SET DEFAULT nextval('tags_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY user_comment_interactions ALTER COLUMN id SET DEFAULT nextval('user_comment_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY user_counters ALTER COLUMN id SET DEFAULT nextval('user_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY user_interactions ALTER COLUMN id SET DEFAULT nextval('user_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY user_rewards ALTER COLUMN id SET DEFAULT nextval('user_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY user_upload_interactions ALTER COLUMN id SET DEFAULT nextval('user_upload_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY vote_ranking_tags ALTER COLUMN id SET DEFAULT nextval('vote_ranking_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
--

ALTER TABLE ONLY vote_rankings ALTER COLUMN id SET DEFAULT nextval('vote_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: orzoro; Owner: -
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

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY basics ALTER COLUMN id SET DEFAULT nextval('basics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cache_rankings ALTER COLUMN id SET DEFAULT nextval('cache_rankings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cache_versions ALTER COLUMN id SET DEFAULT nextval('cache_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cache_votes ALTER COLUMN id SET DEFAULT nextval('cache_votes_id_seq'::regclass);


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

ALTER TABLE ONLY comment_likes ALTER COLUMN id SET DEFAULT nextval('comment_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY easyadmin_stats ALTER COLUMN id SET DEFAULT nextval('easyadmin_stats_id_seq'::regclass);


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

ALTER TABLE ONLY instantwin_interactions ALTER COLUMN id SET DEFAULT nextval('instantwin_interactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instantwins ALTER COLUMN id SET DEFAULT nextval('instantwins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY interaction_call_to_actions ALTER COLUMN id SET DEFAULT nextval('interaction_call_to_actions_id_seq'::regclass);


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

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


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

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pins ALTER COLUMN id SET DEFAULT nextval('pins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY plays ALTER COLUMN id SET DEFAULT nextval('plays_id_seq'::regclass);


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

ALTER TABLE ONLY random_resources ALTER COLUMN id SET DEFAULT nextval('random_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rankings ALTER COLUMN id SET DEFAULT nextval('rankings_id_seq'::regclass);


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

ALTER TABLE ONLY view_counters ALTER COLUMN id SET DEFAULT nextval('view_counters_id_seq'::regclass);


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


SET search_path = ballando, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: ballando; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = braun_ic, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: braun_ic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = coin, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: coin; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = disney, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: disney; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = fandom, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


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
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


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
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


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
-- Name: links_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


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
-- Name: periods_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


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
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


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
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: fandom; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


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


SET search_path = forte, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: forte; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = intesa_expo, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: intesa_expo; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = maxibon, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: maxibon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


SET search_path = orzoro, pg_catalog;

--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


--
-- Name: call_to_action_tags_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_action_tags
    ADD CONSTRAINT call_to_action_tags_pkey PRIMARY KEY (id);


--
-- Name: call_to_actions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_to_actions
    ADD CONSTRAINT call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: checks_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checks
    ADD CONSTRAINT checks_pkey PRIMARY KEY (id);


--
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: home_launchers_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY home_launchers
    ADD CONSTRAINT home_launchers_pkey PRIMARY KEY (id);


--
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


--
-- Name: interactions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


--
-- Name: promocodes_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY promocodes
    ADD CONSTRAINT promocodes_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: releasing_files_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY releasing_files
    ADD CONSTRAINT releasing_files_pkey PRIMARY KEY (id);


--
-- Name: reward_tags_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_tags
    ADD CONSTRAINT reward_tags_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: synced_log_files_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY synced_log_files
    ADD CONSTRAINT synced_log_files_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags_tags_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags_tags
    ADD CONSTRAINT tags_tags_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_comments_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_comment_interactions
    ADD CONSTRAINT user_comments_pkey PRIMARY KEY (id);


--
-- Name: user_counters_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_counters
    ADD CONSTRAINT user_counters_pkey PRIMARY KEY (id);


--
-- Name: user_interactions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- Name: user_rewards_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_upload_interactions_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_upload_interactions
    ADD CONSTRAINT user_upload_interactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


--
-- Name: vote_ranking_tags_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_ranking_tags
    ADD CONSTRAINT vote_ranking_tags_pkey PRIMARY KEY (id);


--
-- Name: vote_rankings_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vote_rankings
    ADD CONSTRAINT vote_rankings_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: basics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY basics
    ADD CONSTRAINT basics_pkey PRIMARY KEY (id);


--
-- Name: cache_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_rankings
    ADD CONSTRAINT cache_rankings_pkey PRIMARY KEY (id);


--
-- Name: cache_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_versions
    ADD CONSTRAINT cache_versions_pkey PRIMARY KEY (id);


--
-- Name: cache_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cache_votes
    ADD CONSTRAINT cache_votes_pkey PRIMARY KEY (id);


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
-- Name: comment_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: easyadmin_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY easyadmin_stats
    ADD CONSTRAINT easyadmin_stats_pkey PRIMARY KEY (id);


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
-- Name: instantwin_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwin_interactions
    ADD CONSTRAINT instantwin_interactions_pkey PRIMARY KEY (id);


--
-- Name: instantwins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instantwins
    ADD CONSTRAINT instantwins_pkey PRIMARY KEY (id);


--
-- Name: interaction_call_to_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interaction_call_to_actions
    ADD CONSTRAINT interaction_call_to_actions_pkey PRIMARY KEY (id);


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
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


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
-- Name: periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: pins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: plays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (id);


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
-- Name: random_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY random_resources
    ADD CONSTRAINT random_resources_pkey PRIMARY KEY (id);


--
-- Name: rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


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
-- Name: view_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY view_counters
    ADD CONSTRAINT view_counters_pkey PRIMARY KEY (id);


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


SET search_path = ballando, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: ballando; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = braun_ic, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: braun_ic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = coin, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: coin; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = disney, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: disney; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


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
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


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
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


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
-- Name: index_tags_on_slug; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


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
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: fandom; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = forte, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: forte; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = intesa_expo, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: intesa_expo; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = maxibon, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: maxibon; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = orzoro, pg_catalog;

--
-- Name: index_answers_on_call_to_action_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_call_to_action_id ON answers USING btree (call_to_action_id);


--
-- Name: index_answers_on_quiz_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_quiz_id ON answers USING btree (quiz_id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


--
-- Name: index_rewards_on_name; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rewards_on_name ON rewards USING btree (name);


--
-- Name: index_synced_log_files_on_pid_and_server_hostname_and_timestamp; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_synced_log_files_on_pid_and_server_hostname_and_timestamp ON synced_log_files USING btree (pid, server_hostname, "timestamp");


--
-- Name: index_tags_on_name; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_slug; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: orzoro; Owner: -; Tablespace: 
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
-- Name: index_cache_rankings_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_name ON cache_rankings USING btree (name);


--
-- Name: index_cache_rankings_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_position ON cache_rankings USING btree ("position");


--
-- Name: index_cache_rankings_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_user_id ON cache_rankings USING btree (user_id);


--
-- Name: index_cache_rankings_on_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_rankings_on_version ON cache_rankings USING btree (version);


--
-- Name: index_cache_versions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_versions_on_name ON cache_versions USING btree (name);


--
-- Name: index_cache_votes_on_call_to_action_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_call_to_action_id ON cache_votes USING btree (call_to_action_id);


--
-- Name: index_cache_votes_on_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cache_votes_on_version ON cache_votes USING btree (version);


--
-- Name: index_call_to_actions_on_activated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_activated_at ON call_to_actions USING btree (activated_at);


--
-- Name: index_call_to_actions_on_aux_aws_transcoding_media_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions USING btree (((aux ->> 'aws_transcoding_media_status'::text)));


--
-- Name: index_call_to_actions_on_aux_options; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_call_to_actions_on_instagram_media_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions USING btree (((aux ->> 'instagram_media_id'::text)));


--
-- Name: index_call_to_actions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_call_to_actions_on_name ON call_to_actions USING btree (name);


--
-- Name: index_call_to_actions_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_slug ON call_to_actions USING btree (slug);


--
-- Name: index_call_to_actions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_updated_at ON call_to_actions USING btree (updated_at);


--
-- Name: index_call_to_actions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_user_id ON call_to_actions USING btree (user_id);


--
-- Name: index_call_to_actions_on_valid_from; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_from ON call_to_actions USING btree (valid_from);


--
-- Name: index_call_to_actions_on_valid_to; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_call_to_actions_on_valid_to ON call_to_actions USING btree (valid_to);


--
-- Name: index_events_on_message; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_message ON events USING btree (message);


--
-- Name: index_events_on_request_uri; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_request_uri ON events USING btree (request_uri);


--
-- Name: index_events_on_timestamp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_timestamp ON events USING btree ("timestamp");


--
-- Name: index_instantwins_on_reward_info_prize_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins USING btree (((reward_info ->> 'prize_code'::text)));


--
-- Name: index_interaction_call_to_actions_on_call_to_action_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_call_to_action_id ON interaction_call_to_actions USING btree (call_to_action_id);


--
-- Name: index_interaction_call_to_actions_on_interaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_call_to_actions_on_interaction_id ON interaction_call_to_actions USING btree (interaction_id);


--
-- Name: index_interaction_ctas_on_interaction_id_and_cta_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_interaction_ctas_on_interaction_id_and_cta_id ON interaction_call_to_actions USING btree (interaction_id, call_to_action_id);


--
-- Name: index_interactions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_interactions_on_name ON interactions USING btree (name);


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
-- Name: index_periods_on_end_datetime; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_end_datetime ON periods USING btree (end_datetime);


--
-- Name: index_periods_on_start_datetime; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_periods_on_start_datetime ON periods USING btree (start_datetime);


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
-- Name: index_tags_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_slug ON tags USING btree (slug);


--
-- Name: index_tags_tags_on_other_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_other_tag_id ON tags_tags USING btree (other_tag_id);


--
-- Name: index_tags_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_tags_on_tag_id ON tags_tags USING btree (tag_id);


--
-- Name: index_user_comment_interactions_on_approved; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions USING btree (approved);


--
-- Name: index_user_comment_interactions_on_comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_comment_id ON user_comment_interactions USING btree (comment_id);


--
-- Name: index_user_comment_interactions_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions USING btree (created_at);


--
-- Name: index_user_interactions_on_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_answer_id ON user_interactions USING btree (answer_id);


--
-- Name: index_user_interactions_on_aux_call_to_action_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions USING btree ((((aux ->> 'call_to_action_id'::text))::integer));


--
-- Name: index_user_interactions_on_aux_like; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_like ON user_interactions USING btree (((aux ->> 'like'::text)));


--
-- Name: index_user_interactions_on_aux_share; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_aux_share ON user_interactions USING btree (((aux ->> 'share'::text)));


--
-- Name: index_user_interactions_on_interaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_interaction_id ON user_interactions USING btree (interaction_id);


--
-- Name: index_user_interactions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_interactions_on_user_id ON user_interactions USING btree (user_id);


--
-- Name: index_user_rewards_on_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_reward_id ON user_rewards USING btree (reward_id);


--
-- Name: index_user_rewards_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_rewards_on_user_id ON user_rewards USING btree (user_id);


--
-- Name: index_user_uploads_on_aux_fields; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions USING btree (((aux ->> 'extra_fields'::text)));


--
-- Name: index_users_on_anonymous_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonymous_id ON users USING btree (anonymous_id);


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
-- Name: index_view_counters_on_counter; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_counter ON view_counters USING btree (counter);


--
-- Name: index_view_counters_on_ref_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_ref_id ON view_counters USING btree (ref_id);


--
-- Name: index_view_counters_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_view_counters_on_type ON view_counters USING btree (ref_type);


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

INSERT INTO schema_migrations (version) VALUES ('20140919073315');

INSERT INTO schema_migrations (version) VALUES ('20140919145152');

INSERT INTO schema_migrations (version) VALUES ('20140919145505');

INSERT INTO schema_migrations (version) VALUES ('20140919145609');

INSERT INTO schema_migrations (version) VALUES ('20140919151718');

INSERT INTO schema_migrations (version) VALUES ('20140926073909');

INSERT INTO schema_migrations (version) VALUES ('20141007160640');

INSERT INTO schema_migrations (version) VALUES ('20141016093356');

INSERT INTO schema_migrations (version) VALUES ('20141016154259');

INSERT INTO schema_migrations (version) VALUES ('20141020093014');

INSERT INTO schema_migrations (version) VALUES ('20141021073929');

INSERT INTO schema_migrations (version) VALUES ('20141103153007');

INSERT INTO schema_migrations (version) VALUES ('20141111165529');

INSERT INTO schema_migrations (version) VALUES ('20141113154913');

INSERT INTO schema_migrations (version) VALUES ('20141113154935');

INSERT INTO schema_migrations (version) VALUES ('20141117151750');

INSERT INTO schema_migrations (version) VALUES ('20141117152534');

INSERT INTO schema_migrations (version) VALUES ('20141117152636');

INSERT INTO schema_migrations (version) VALUES ('20141117155629');

INSERT INTO schema_migrations (version) VALUES ('20141117161246');

INSERT INTO schema_migrations (version) VALUES ('20141117164343');

INSERT INTO schema_migrations (version) VALUES ('20141118105612');

INSERT INTO schema_migrations (version) VALUES ('20141118135727');

INSERT INTO schema_migrations (version) VALUES ('20141118162728');

INSERT INTO schema_migrations (version) VALUES ('20141120111044');

INSERT INTO schema_migrations (version) VALUES ('20141120142856');

INSERT INTO schema_migrations (version) VALUES ('20141201165859');

INSERT INTO schema_migrations (version) VALUES ('20141211113833');

INSERT INTO schema_migrations (version) VALUES ('20141212114607');

INSERT INTO schema_migrations (version) VALUES ('20141212114624');

INSERT INTO schema_migrations (version) VALUES ('20141212114640');

INSERT INTO schema_migrations (version) VALUES ('20141215101145');

INSERT INTO schema_migrations (version) VALUES ('20141215102204');

INSERT INTO schema_migrations (version) VALUES ('20141216085855');

INSERT INTO schema_migrations (version) VALUES ('20141218153951');

INSERT INTO schema_migrations (version) VALUES ('20150109111504');

INSERT INTO schema_migrations (version) VALUES ('20150112151054');

INSERT INTO schema_migrations (version) VALUES ('20150113164916');

INSERT INTO schema_migrations (version) VALUES ('20150113171522');

INSERT INTO schema_migrations (version) VALUES ('20150117115050');

INSERT INTO schema_migrations (version) VALUES ('20150119161752');

INSERT INTO schema_migrations (version) VALUES ('20150122113027');

INSERT INTO schema_migrations (version) VALUES ('20150123114506');

INSERT INTO schema_migrations (version) VALUES ('20150123115529');

INSERT INTO schema_migrations (version) VALUES ('20150123151020');

INSERT INTO schema_migrations (version) VALUES ('20150126160149');

INSERT INTO schema_migrations (version) VALUES ('20150129102847');

INSERT INTO schema_migrations (version) VALUES ('20150129103550');

INSERT INTO schema_migrations (version) VALUES ('20150130145005');

INSERT INTO schema_migrations (version) VALUES ('20150203092457');

INSERT INTO schema_migrations (version) VALUES ('20150203103504');

INSERT INTO schema_migrations (version) VALUES ('20150205101617');

INSERT INTO schema_migrations (version) VALUES ('20150205152504');

INSERT INTO schema_migrations (version) VALUES ('20150206170033');

INSERT INTO schema_migrations (version) VALUES ('20150206170306');

INSERT INTO schema_migrations (version) VALUES ('20150210144800');

INSERT INTO schema_migrations (version) VALUES ('20150212101118');

INSERT INTO schema_migrations (version) VALUES ('20150212111531');

INSERT INTO schema_migrations (version) VALUES ('20150212143420');

INSERT INTO schema_migrations (version) VALUES ('20150212162357');

INSERT INTO schema_migrations (version) VALUES ('20150213081903');

INSERT INTO schema_migrations (version) VALUES ('20150216160308');

INSERT INTO schema_migrations (version) VALUES ('20150219101047');

INSERT INTO schema_migrations (version) VALUES ('20150227151546');

INSERT INTO schema_migrations (version) VALUES ('20150311143324');

INSERT INTO schema_migrations (version) VALUES ('20150313111511');

INSERT INTO schema_migrations (version) VALUES ('20150316103146');

INSERT INTO schema_migrations (version) VALUES ('20150324171203');

INSERT INTO schema_migrations (version) VALUES ('20150413144521');

INSERT INTO schema_migrations (version) VALUES ('20150504101145');

INSERT INTO schema_migrations (version) VALUES ('20150507085715');

INSERT INTO schema_migrations (version) VALUES ('20150511143302');

INSERT INTO schema_migrations (version) VALUES ('20150528134030');

INSERT INTO schema_migrations (version) VALUES ('20150528162710');

INSERT INTO schema_migrations (version) VALUES ('20150608085400');

INSERT INTO schema_migrations (version) VALUES ('20150610135146');

INSERT INTO schema_migrations (version) VALUES ('20150611135346');

INSERT INTO schema_migrations (version) VALUES ('20150622132011');

INSERT INTO schema_migrations (version) VALUES ('20150623074631');

INSERT INTO schema_migrations (version) VALUES ('20150702082610');

INSERT INTO schema_migrations (version) VALUES ('20150707073343');

INSERT INTO schema_migrations (version) VALUES ('20150707080811');

INSERT INTO schema_migrations (version) VALUES ('20150710135954');

INSERT INTO schema_migrations (version) VALUES ('20150710140116');

INSERT INTO schema_migrations (version) VALUES ('20150710140146');

INSERT INTO schema_migrations (version) VALUES ('20150710140400');

INSERT INTO schema_migrations (version) VALUES ('20150710140431');

INSERT INTO schema_migrations (version) VALUES ('20151015105328');

INSERT INTO schema_migrations (version) VALUES ('20151015153155');

