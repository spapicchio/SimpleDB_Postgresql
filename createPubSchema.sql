CREATE TABLE Author(
                    id text PRIMARY KEY,
                    name_author text, 
                    homepage text
                    );

CREATE TABLE Publication(
                        pubid text PRIMARY KEY,
                        pubkey text unique not null,
                        title text,
                        year int
                        );

CREATE TABLE Publish(
                    id text,
                    pubid text,
                    PRIMARY KEY (id, pubid),
                    FOREIGN KEY (id) REFERENCES Author,
                    FOREIGN KEY (pubid) REFERENCES Publication
                    );

CREATE TABLE Article(
                    pubid text,
                    number_article int,
                    journal text,
                    month int,
                    volume int,
                    PRIMARY KEY (pubid),
                    FOREIGN KEY (pubid) REFERENCES Publication
                                        ON DELETE CASCADE
                    );

CREATE TABLE Book(
                pubid text,
                publisher text,
                isbn text,
                PRIMARY KEY (pubid),
                FOREIGN KEY (pubid) REFERENCES Publication
                                    ON DELETE CASCADE
                );

CREATE TABLE Inproceedings(
                        pubid text,
                        booktitle text,
                        editor text,
                        PRIMARY KEY (pubid),
                        FOREIGN KEY (pubid) REFERENCES Publication
                                            ON DELETE CASCADE
                        );

CREATE TABLE Incollection(
                        pubid text,
                        publisher text,
                        booktitle text,
                        isbn text,
                        PRIMARY KEY (pubid),
                        FOREIGN KEY (pubid) REFERENCES Publication
                                            ON DELETE CASCADE
                        );