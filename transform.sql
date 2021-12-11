/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= AUTHOR ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

/*as homepage I consider the field url which is associated 
only with the first author of the publication
EXAMPLE
@inproceedings{DBLP:conf/stacs/GemiciKMPP19,
author = {Kurtulus Gemici and
Elias Koutsoupias and
Barnab{\'{e}} Monnot and
Christos H. Papadimitriou and
Georgios Piliouras},
title = {Wealth Inequality and the Price of Anarchy},
booktitle = {36th International Symposium on Theoretical Aspects of Computer Science,
{STACS} 2019, March 13-16, 2019, Berlin, Germany},
pages = {31:1--31:16},
year = {2019},
crossref = {DBLP:conf/stacs/2019},
url = {https://doi.org/10.4230/LIPIcs.STACS.2019.31},
doi = {10.4230/LIPIcs.STACS.2019.31},
timestamp = {Thu, 02 May 2019 17:40:17 +0200},
biburl = {https://dblp.org/rec/bib/conf/stacs/GemiciKMPP19},

Author => Kurtulus Gemici
Homepage => https://dblp.org/rec/bib/conf/stacs/GemiciKMPP19

*/
drop sequence if exists author_id;
create sequence author_id;

DROP TABLE IF EXISTS Author;
CREATE TABLE Author(id text, name_author text, homepage text);

WITH first_author AS (
                    select k, v 
                    from Field
                    where p='author'
                    ),

     first_url AS   (
                    select k, v 
                    from Field
                    where p='url'
                    ),

     name_url AS    ( -- distinc on is used to avoid different authors name in the table
                    select distinct on (fa.v) fa.v as name_author, fu.v as homepage
                    from (
                        first_author fa
                        LEFT JOIN first_url fu ON fa.k = fu.k
                        )
                    order by fa.v
                    )    
INSERT INTO Author (select nextval('author_id') as id, name_author, homepage from name_url);

drop sequence if exists author_id;

ALTER TABLE Author ADD PRIMARY KEY(id);

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= PUBLICATION ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
drop sequence if exists pubid_id;
create sequence pubid_id;


DROP TABLE IF EXISTS Publication;
CREATE TABLE Publication(pubid text, pubkey text, title text, year text);
-- title and year have both multiple fieds. for this reason is used distinc on 

WITH pub_title AS (
                    select k, v 
                    from Field
                    where p='title'

                    ),

     pub_year  AS   (
                    select k, v 
                    from Field
                    where p='year' 
                    ),

     name_url AS    (
                    select distinct on (pub_title.v) pub_title.v as title, pub_year.v as year
                    from (
                        pub_title
                        LEFT JOIN pub_year ON pub_title.k = pub_year.k
                        )
                    order by pub_title.v
                    )    
INSERT INTO Publication(pubid, pubkey, title, year)
SELECT pk, pk, title, year FROM (select nextval('pubid_id') as pk, title, year from name_url) as alias;

drop sequence if exists pubid_id;

ALTER TABLE Publication ADD PRIMARY KEY (pubid);

ALTER TABLE Publication 
ALTER COLUMN pubkey
SET NOT NULL;

ALTER TABLE Publication 
ADD CONSTRAINT my_con UNIQUE (pubkey);


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= PUBLISH ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

DROP TABLE IF EXISTS Publish;
CREATE TABLE Publish(id text, pubid text);

WITH id_key_name AS (
                    select distinct on (f.k) f.k, a.id -- id author, key field of author name
                    from Field f, Author a
                    where f.p='author' and f.v=a.name_author -- join by author name
                    order by f.k --in case of duplicate author name (errors), it takes only one 
                    ),
    id_key_title AS (
                    select distinct on (f.v) f.v, p.pubid, f.k -- id publication, key field of title
                    from Field f, Publication p
                    where f.p='title' and f.v=p.title -- join by title
                    order by f.v
                    ),
    id_name_title AS (
                    select id_n.id as id, id_t.pubid as pubid -- id name author, pubid publication
                    from id_key_name id_n, id_key_title id_t
                    where id_n.k = id_t.k -- join by the key field
                    )
INSERT INTO Publish(id, pubid)
SELECT id, pubid FROM id_name_title;




ALTER TABLE Publish ADD PRIMARY KEY (id, pubid);


ALTER TABLE Publish
ADD FOREIGN KEY (id) REFERENCES Author(id);


ALTER TABLE Publish
ADD FOREIGN KEY (pubid) REFERENCES Publication(pubid);
 
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= TEMPORARY TABLE/INDEX ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/


/* the temporary table is used to not compute each time the join and in addition
    it is used a clustered index in order to speed up the query on it. More precisely,
    since I will query the temporary table on the type of publication 
    (to know in which table to put the selected field) and on the type of field (to know
    in which column to put the value)
*/
/*I also removed the field that are not used in the ER model*/

drop table if exists Temp_join_Pub_Field;
create temp table Temp_join_Pub_Field (pubid text, key_f text, typePub text, typeField text, valueField text);

create index on Temp_join_Pub_Field(typePub, typeField);

-- it is also useful to add the pubid in this temporary table
-- to reduce the number of join later
WITH pubid_key_t AS (
                    select distinct on (f.v) f.v, p.pubid, f.k -- id publication, key field of title
                    from Field f, Publication p
                    where f.p='title' and f.v=p.title -- join by title
                    order by f.v
                    )
INSERT INTO Temp_join_Pub_Field (
                                   select pk.pubid, -- the id present in Publication 
                                        p.k as key_f , -- the key of the Publication in Field
                                        p.p as typePub, -- the type of Publication (book, article, ... )
                                        f.p as typeField, -- the type of the Field (author, title, month,...)
                                        f.v as valueField -- the value of the field
                                   from Pub p, Field f, pubid_key_t pk
                                   where p.k = f.k and f.k = pk.k -- join by field key
                                               and f.p in ('number', 'journal', 'month', 'volume',
                                                           'publisher', 'isbn', 'booktitle', 'editor') 
                                    );
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= ARTICLE ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
DROP TABLE IF EXISTS Article;
CREATE TABLE Article(
                    pubid text ,
                    number_article text,
                    journal text,
                    month text,
                    volume text
                    );

WITH         pubid_t AS (
                            select distinct on (pubid) pubid, key_f
                            from Temp_join_Pub_Field
                            where typePub='article'
                            order by pubid
                        ), 
    number_article_t AS (
                            select key_f, valueField as number_article
                            from Temp_join_Pub_Field  
                            where typePub='article' and typeField='number'
                        ),
     journal_t        AS  (
                            select key_f, valueField as journal
                            from Temp_join_Pub_Field  
                            where typePub='article' and typeField='journal'
                          ),
     month_t          AS (
                            select key_f, valueField as month
                            from Temp_join_Pub_Field  
                            where typePub='article' and typeField='month'
                            ),
     volume_t          AS (
                            select key_f, valueField as volume
                            from Temp_join_Pub_Field  
                            where typePub='article' and typeField='volume'
                            ),
     join_table        AS  ( 
                            select pubid, number_article, journal, month, volume 
                            from (
                                   pubid_t pu
                                   LEFT JOIN number_article_t n ON pu.key_f = n.key_f
                                   LEFT JOIN journal_t j ON pu.key_f = j.key_f
                                   LEFT JOIN month_t m  ON pu.key_f = m.key_f
                                   LEFT JOIN  volume_t v  ON pu.key_f = v.key_f
                                   )
                            )
INSERT INTO Article
SELECT pubid, number_article, journal, month, volume
FROM join_table;

ALTER TABLE Article ADD PRIMARY KEY (pubid);

ALTER TABLE Article
ADD FOREIGN KEY (pubid) REFERENCES Publication ON DELETE CASCADE;

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          ============= BOOK ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
DROP TABLE IF EXISTS Book;

CREATE TABLE Book(
               pubid text,
               publisher text,
               isbn text);

WITH    pubid_t AS (
                            select distinct on (pubid) pubid, key_f
                            from Temp_join_Pub_Field
                            where typePub='book'
                            order by pubid
                        ), 
    publisher_t AS (
                            select key_f, valueField as publisher
                            from Temp_join_Pub_Field  
                            where typePub='book' and typeField='publisher'
                        ),
     isbn_t        AS  (
                            select key_f, valueField as isbn
                            from Temp_join_Pub_Field  
                            where typePub='book' and typeField='isbn'
                          ),
     join_table        AS  ( 
                              select distinct on (pubid) pubid, publisher, isbn -- done in order to remove the duplicates key caused by duplicates isbn, publisher
                              from (
                                   pubid_t pu
                                   LEFT JOIN isbn_t i ON pu.key_f = i.key_f
                                   LEFT JOIN publisher_t p ON pu.key_f = p.key_f
                                   )
                              order by pubid
                            )
INSERT INTO Book
SELECT pubid, publisher, isbn
FROM join_table;


ALTER TABLE Book
ADD PRIMARY KEY (pubid);

ALTER TABLE Book
ADD FOREIGN KEY (pubid) REFERENCES Publication ON DELETE CASCADE;
                
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= INPROCEEDINGS ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

DROP TABLE IF EXISTS Inproceedings;

CREATE TABLE Inproceedings(
                        pubid text,
                        booktitle text,
                        editor text
                        );

WITH  pubid_t AS (
                            select distinct on (pubid) pubid, key_f
                            from Temp_join_Pub_Field
                            where typePub='inproceedings'
                            order by pubid
                        ), 
      booktitle_t AS (
                            select key_f, valueField as booktitle
                            from Temp_join_Pub_Field  
                            where typePub='inproceedings' and typeField='booktitle'
                        ),
     editor_t        AS  (
                            select key_f, valueField as editor
                            from Temp_join_Pub_Field  
                            where typePub='inproceedings' and typeField='editor'
                          ),
     join_table        AS  ( 
                            select distinct on (pubid) pubid, booktitle, editor -- remove duplicates pubid caused by error in Field (booktitle and editor)
                            from (
                                   pubid_t pu
                                   LEFT JOIN booktitle_t b ON pu.key_f = b.key_f
                                   LEFT JOIN editor_t e ON pu.key_f = e.key_f   
                                   )
                              order by pubid 
                            )
INSERT INTO Inproceedings
SELECT pubid, booktitle, editor
FROM join_table;

ALTER TABLE Inproceedings
ADD PRIMARY KEY (pubid);

ALTER TABLE Inproceedings
ADD FOREIGN KEY (pubid) REFERENCES Publication ON DELETE CASCADE;


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= INCOLLECTION ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

DROP TABLE IF EXISTS Incollection;

CREATE TABLE Incollection(
                        pubid text,
                        publisher text,
                        booktitle text,
                        isbn text
                        );

WITH      pubid_t AS (
                            select distinct on (pubid) pubid, key_f
                            from Temp_join_Pub_Field
                            where typePub='incollection'
                            order by pubid
                        ), 
      publisher_t AS (
                            select key_f, valueField as publisher
                            from Temp_join_Pub_Field  
                            where typePub='incollection' and typeField='publisher'
                        ),
     booktitle_t AS (
                            select key_f, valueField as booktitle
                            from Temp_join_Pub_Field  
                            where typePub='incollection' and typeField='booktitle'
                        ),
     isbn_t        AS  (
                            select key_f, valueField as isbn
                            from Temp_join_Pub_Field  
                            where typePub='incollection' and typeField='isbn'
                          ),
     join_table        AS  ( 
                            select distinct on(pubid) pubid , publisher, booktitle, isbn
                            from (
                                 pubid_t pu
                                 LEFT JOIN publisher_t p on pu.key_f = p.key_f
                                 LEFT JOIN booktitle_t b on pu.key_f = b.key_f -- LEFT JOIN BECAUSE OF THE ERROR IN FIELD "Contrast Data Mining"
                                 LEFT JOIN isbn_t e on pu.key_f = e.key_f
                                   ) 
                              order by pubid
                            )
INSERT INTO Incollection
SELECT pubid, publisher, booktitle, isbn
FROM join_table;

ALTER TABLE Incollection
ADD PRIMARY KEY (pubid);

ALTER TABLE Incollection
ADD FOREIGN KEY (pubid) REFERENCES Publication ON DELETE CASCADE;
