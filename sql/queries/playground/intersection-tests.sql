\timing on
\set name unmatched

DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select ring,array_agg(inid order by inid) as inids, min(ringsize)-count(inid) as unmatched, min(ringsize) as ringsize
	from rings
	group by 1
	having count(inid) > 1
	order by unmatched asc
);
COMMENT ON TABLE :name IS 'Query: Reused rings and their uncertainty (unmatched = number of inputs not provably spent)';


\set name intersections
\set max_unmatched 2
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select ring,array_agg(inid order by inid) as inids, min(ringsize)-count(inid) as unmatched, min(ringsize) as ringsize
	from rings
	group by 1
	order by unmatched desc
);

COMMENT ON TABLE :name IS 'Query: For all pairs of rings contains & and ^ of their sets if ^-set-size >2'; -- 2 is :max_unmatched
