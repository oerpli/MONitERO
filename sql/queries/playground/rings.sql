\timing on
\set name rings

DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	SELECT row_number() over() as ringid, inid, count(outid) as ringsize, array_agg(outid order by outid) as ring
	FROM ring
	GROUP BY inid
	-- HAVING count(outid) > 1 -- ex/include trivially matched inputs
	ORDER BY ringsize asc
);
ALTER TABLE :name ADD PRIMARY KEY (ringid);
CREATE UNIQUE INDEX rings_inid ON :name(inid);
CREATE INDEX rings_ringsize ON :name(ringsize);
COMMENT ON TABLE :name IS 'Query: Contains full rings for all inputs.'; -- PLEASE FILL OUT TO PREVENT CONFUSION