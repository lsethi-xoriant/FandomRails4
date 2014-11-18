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
CREATE INDEX orid_id_idx ON events(orig_id);
CREATE INDEX message_idx ON events(message);
CREATE INDEX request_uri_idx ON events(request_uri);
CREATE INDEX timestamp_idx ON events("timestamp");
