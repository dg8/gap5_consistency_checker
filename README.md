gap5_checker.pl is gap5 consistency checker. 
It takes in gap5 database(DBNAME.VERS)
and runs gap5_export and tg_index scripts on it. 
If metrics (number of contigs, total length, 
number of serquences, number of tags) of a new gap5 database
(tmp/DBMANE.X) are identical to the metrics of the original
one then the original database is rewritten by the new one.