# Preliminaries
It is used a publicly available dataset on research publications. The DBLP data set can be found at
http://dblp.uni-trier.de. The full dataset can be downloaded for offline analysis at http://dblp.
uni-trier.de/xml/. A quick documentation of this dataset is at http://dblp.uni-trier.de/xml/docu/dblpxml.pdf. 

# ER.pdf
It contains the ER diagram of this Database

# createPubSchema.sql
It contains the code to create the PubSchema of the ER Diagram

# solution-raw.sql
Contains the solution to this two simple query:
- For each type of publication, count the total number of publications of that type. Your query should
return a set of (publication-type, count) pairs. For example (article, 20000), (inproceedings, 30000),
… (not the real answer)
- We say that a field ‘occurs’ in a publication type, if there exists at least one publication of that type
having that field. For example, ‘publisher occurs in incollection’, but ‘publisher does not occur in
inproceedings’ (because no inproceedings entry has a publisher field). Find the fields that occur in
all publications types. Your query should return a set of field names: for example it may return title,
if title occurs in all publication types (article, inproceedings, etc. notice that title does not have to
occur in every publication instance, only in some instance of every type), but it should not return
publisher (since the latter does not occur in any publication of type inproceedings) 

# transfor.sql
Transform the DBLP data from RawSchema to PubSchema.
The transformation consists of several SQL queries, one per PubSchema table.

# solution-analysis.sql
It contains the solution of the following sql query:
-  Find the top 20 authors with the largest number of publications 
-  Find the top 20 authors with the largest number of publications in STOC. Repeat this for one more
conferences of your choice (e.g.: SIGMOD or VLDB, careful with spelling the name of the conference)
- Two of the major database conferences are ‘PODS’ (theory) and ‘SIGMOD Conference’ (systems).
Find (a) all authors who published at least 10 SIGMOD papers but never published a PODS paper,
and (b) all authors who published at least 5 PODS papers but never published a SIGMOD paper 

# vis.sql and vis.pdf
It contains a script in python to connect to the database and submit queries to compute the histogram of the number of publications



