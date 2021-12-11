/*Start by writing a SQL query that returns a set (k, f(k)),
 where k=1,2,3,… and f(k) = number of authors that
have exactly k publications. Retrieve the results back into your program.
 From there, either output a CSV file and import it into Excel 
 or use whatever other method you like to produce the graph.*/

drop table tempTable if exists;
create temp TABLE tempTable(k text, countID text);

WITH query_1 AS ( --per each id the number of publication
                    SELECT a.id, count(*) as numPublication 
                    FROM Author a, Publish p
                    WHERE a.id = p.id
                    group by a.id
                ),
    kCount AS (
                SELECT numPublication as k, count(*) as countID
                FROM query_1
                GROUP BY numPublication 
            )
INSERT INTO tempTable
SELECT k, countID
FROM kCount;

 \copy tempTable to 'kCountID.csv' csv header