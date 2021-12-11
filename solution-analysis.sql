/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        --============= FIRST QUERY ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
SELECT a.id, a.name_author, numPublication
FROM (select p.id, count(*) as numPublication
      from Author a, Publish p
      where a.id = p.id 
      group by p.id) AS temp, Author a
WHERE a.id = temp.id
ORDER BY numPublication DESC
FETCH FIRST 20 rows only;

/*   id    |     name_author      | numpublication 
---------+----------------------+----------------
 904975  | H. Vincent Poor      |            617
 1799548 | Mohamed-Slim Alouini |            541
 2193990 | Ronald R. Yager      |            489
 2029845 | Philip S. Yu         |            484
 2842317 | Yu Zhang             |            469
 2778809 | Yang Liu             |            462
 261869  | Azzedine Boukerche   |            458
 2716931 | Witold Pedrycz       |            441
 429775  | Chin-Chen Chang 0001 |            436
 1483764 | Li Zhang             |            417
 672475  | Elisa Bertino        |            408
 2683990 | Wei Wang             |            407
 2639128 | Victor C. M. Leung   |            406
 1053516 | Irith Pomeranz       |            402
 1185767 | Jie Wu 0001          |            373
 1913820 | Noga Alon            |            368
 2775953 | Yan Zhang            |            359
 658581  | Edwin R. Hancock     |            353
 65307   | Ajith Abraham        |            351
 1196252 | Jing Zhang           |            350
(20 rows)*/

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          --============= SECOND QUERY ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
SELECT a.id, a.name_author, numPubStoc
FROM (select a.id, count(*) as numPubStoc
    from Author a, Inproceedings i, Publish p
    where p.id = a.id and i.pubid = p.pubid and booktitle='STOC'
    group by a.id) temp, Author a
WHERE temp.id = a.id
ORDER BY numPubStoc DESC
FETCH FIRST 20 rows only;

/*
   id    |        name_author        | numpubstoc 
---------+---------------------------+------------
 254278  | Avi Wigderson             |         21
 2115801 | Ran Raz                   |         20
 2611105 | Uriel Feige               |         19
 1770067 | Miklós Ajtai              |         18
 166130  | Andrew Chi-Chih Yao       |         17
 2236416 | S. Rao Kosaraju           |         15
 2165102 | Robert Endre Tarjan       |         14
 1913820 | Noga Alon                 |         14
 1911662 | Noam Nisan                |         14
 2927586 | Zvi Galil                 |         14
 1480145 | Leslie G. Valiant         |         13
 1219084 | Johan Håstad              |         13
 1927194 | Oded Goldreich 0001       |         13
 1814734 | Moni Naor                 |         12
 2433342 | Stephen A. Cook           |         12
 281536  | Baruch Awerbuch           |         12
 2293977 | Scott Aaronson            |         11
 2634240 | Venkatesan Guruswami      |         11
 1545088 | László Babai              |         11
 461659  | Christos H. Papadimitriou |         11
(20 rows)*/

SELECT a.id, a.name_author, numPubStoc
FROM (select a.id, count(*) as numPubStoc
    from Author a, Inproceedings i, Publish p
    where p.id = a.id and i.pubid = p.pubid and booktitle='SIGMOD Conference'
    group by a.id) temp, Author a
WHERE temp.id = a.id
ORDER BY numPubStoc DESC
FETCH FIRST 20 rows only;
/*
   id    |      name_author      | numpubstoc 
---------+-----------------------+------------
 2464176 | Surajit Chaudhuri     |         25
 1739735 | Michael J. Carey 0001 |         23
 560349  | David J. DeWitt       |         16
 1263246 | Joseph M. Hellerstein |         16
 1748462 | Michael Stonebraker   |         16
 1145941 | Jeffrey F. Naughton   |         16
 611545  | Divesh Srivastava     |         15
 904870  | H. V. Jagadish        |         15
 358158  | C. Mohan 0001         |         13
 1183274 | Jiawei Han 0001       |         13
 461574  | Christos Faloutsos    |         12
 621591  | Donald Kossmann       |         12
 611946  | Divyakant Agrawal     |         12
 2264634 | Samuel Madden         |         11
 553353  | David B. Lomet        |         11
 1221545 | Johannes Gehrke       |         11
 2381683 | Sihem Amer-Yahia      |         11
 2854427 | Yufei Tao             |         11
 523722  | Dan Suciu             |         10
 109164  | Alfons Kemper         |         10
(20 rows)
*/
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            --============= THIRD QUERY ============= 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

-- all authors who published at least 10 SIGMOD papers but never published a PODS paper

WITH idPubicationInPods AS ( -- all the authors who published in PODS
                            select a.id as id
                            from Author a, Inproceedings i, Publish p
                            where p.id = a.id and i.pubid = p.pubid and booktitle='PODS'
                            ),
   idPublicationInSigmod AS ( -- all the authors with at least 10 sigmod papers
                            select a.id as id, name_author, count(*) as numPubSig
                            from Author a, Inproceedings i, Publish p
                            where p.id = a.id and i.pubid = p.pubid and booktitle='SIGMOD Conference'
                            group by a.id
                            having count(*) > 9
                            )
select s.id, name_author, numPubSig
from idPublicationInSigmod s
where s.id NOT IN (select id from idPubicationInPods); -- remove the authors who have published in PODS

/*
   id    |     name_author     | numpubsig 
---------+---------------------+------------
 109164  | Alfons Kemper       |         10
 1183274 | Jiawei Han 0001     |         13
 1190082 | Jim Gray 0001       |         10
 1748462 | Michael Stonebraker |         16
 2010780 | Per-Åke Larson      |         10
 2264634 | Samuel Madden       |         11
 2381683 | Sihem Amer-Yahia    |         11
 553353  | David B. Lomet      |         11
 621591  | Donald Kossmann     |         12
 823069  | Gautam Das 0001     |         10
 */

--all authors who published at least 5 PODS papers but never published a SIGMOD paper

 WITH idPubicationInSigmod AS ( -- all the authors who published in SIGMOD
                            select a.id as id
                            from Author a, Inproceedings i, Publish p
                            where p.id = a.id and i.pubid = p.pubid and booktitle='SIGMOD Conference'
                            ),
   idPublicationInPods AS ( -- all the authors with at least 4 PODS paper
                            select a.id as id, name_author, count(*) as numPubPods
                            from Author a, Inproceedings i, Publish p
                            where p.id = a.id and i.pubid = p.pubid and booktitle='PODS'
                            group by a.id
                            having count(*) > 4
                            )
select p.id, name_author, numPubPods
from idPublicationInPods p
where p.id NOT IN (select id from idPubicationInSigmod); -- remove the authors who have published in PODS

/* 
   id    |      name_author      | numpubpods 
---------+-----------------------+------------
 1111663 | Jan Chomicki          |          5
 124628  | Alon Y. Levy          |          5
 1522482 | Luc Segoufin          |          8
 1605772 | Marcelo Arenas        |          5
 160944  | Andreas Pieris        |          6
 1961861 | Pablo Barceló         |          5
 2419958 | Stavros S. Cosmadakis |          6
 2546495 | Thomas Schwentick     |          5
 566038  | David P. Woodruff     |          5
 771216  | Floris Geerts         |          5
 785242  | Frank Neven           |          8
 829837  | Georg Gottlob         |         12
(12 rows)
*/
