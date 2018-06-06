\timing on
\set name ringsize_comparison
-- \set granularity day
-- quoted granularity
-- \set q_granularity '''' :granularity ''''

DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select ringsize,effective_ringsize as effective, count(*)
	from txi
	group by 1,2 order by 1,2 asc
);

COMMENT ON TABLE :name IS 'Query: Flow from ringsize to effective ringsize'; -- PLEASE FILL OUT TO PREVENT CONFUSION
