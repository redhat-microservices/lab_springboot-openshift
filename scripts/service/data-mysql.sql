CREATE TABLE IF NOT EXISTS catalog (
  id               BIGINT NOT NULL AUTO_INCREMENT,
  artist           VARCHAR(255),
  description      LONGTEXT,
  price            FLOAT,
  publication_date DATE,
  title            VARCHAR(255),
  version          INTEGER,
  PRIMARY KEY (id)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 2
  DEFAULT CHARSET = utf8;
INSERT INTO catalog (id, version, artist, description, price, publication_date, title)
VALUES (1001, 1, "ACDC", "Australian hard rock band", 15.0, "1980-07-25", "Back in Black");
INSERT INTO catalog (id, version, artist, description, price, publication_date, title)
VALUES (1002, 1, "Abba", "Swedish pop music group", 12.0, "1976-10-11", "Arrival");
INSERT INTO catalog (id, version, artist, description, price, publication_date, title)
VALUES (1003, 1, "Coldplay", "British rock band ", 17.0, "2008-07-12", "Viva la Vida");
INSERT INTO catalog (id, version, artist, description, price, publication_date, title)
VALUES (1004, 1, "U2", "Irish rock band ", 18.0, "1987-03-09", "The Joshua Tree");
INSERT INTO catalog (id, version, artist, description, price, publication_date, title)
VALUES (1005, 1, "Metallica", "Heavy metal band", 15.0, "1991-08-12", "Black");