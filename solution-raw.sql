----------------------- Exercise 1 -----------------------
SELECT p, count(*)
FROM Pub  
GROUP BY p;

/*
       p       |  count  
---------------+---------
 article       | 2687970
 book          |   19019
 incollection  |   67439
 inproceedings | 2907806
 mastersthesis |      12
 phdthesis     |   81781
 proceedings   |   48705
 www           | 2857502

*/

----------------------- Exercise 2 -----------------------
select f.p
from Pub p, Field f
where p.k=f.k
group by f.p
having count(distinct p.p) = (SELECT count(distinct p) FROM Pub);
/*
   p    
--------
 author
 ee
 note
 title
 year
 
*/



