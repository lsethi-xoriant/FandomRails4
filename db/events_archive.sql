CREATE TABLE events (
    id SERIAL,
    orig_id integer NOT NULL,
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