\timing on
-- get folderpaths defined in paths.sql
-- \i ./paths.sql
-- \set inputfile :rootpath'matching/1E6/1e6_2.csv'''

-- provide inputfile as named argument to psql
-- psql -f 0_match.sql -v inputfile="whatever.csv"
\echo '>>Reading from file:'
\echo :inputfile

DROP TABLE IF exists new_matchings;
CREATE TABLE new_matchings (
	inid integer,
	outid integer
);

\echo '>>Importing matching table'
COPY new_matchings from :'inputfile' with (FORMAT csv, HEADER);

UPDATE ring as r
SET matched = bool_to_input(r.outid = n.outid)
FROM new_matchings as n
WHERE n.inid = r.inid;

UPDATE ring as r
SET matched = bool_to_input(r.inid = n.inid)
FROM new_matchings as n
WHERE n.outid = r.outid;

DROP TABLE new_matchings; -- remove again as not longer needed

-- UPDATE ring as r
-- SET matched = true
-- FROM new_matchings as n
-- WHERE	n.inid = r.inid
-- 	AND n.outid = r.outid;

