DROP TABLE IF EXISTS statuses;

CREATE TABLE statuses (
  guid text,
  success boolean DEFAULT false NOT NULL,
  url text,
  updated_at timestamp without time zone,
  valid_readme boolean DEFAULT false NOT NULL
);
