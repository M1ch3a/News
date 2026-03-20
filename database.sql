CREATE TABLE news (
  id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  title   VARCHAR(128) NOT NULL,
  slug    VARCHAR(128) NOT NULL,
  body    TEXT NOT NULL,
  PRIMARY KEY (id),
  KEY slug (slug)
);
