\timing on
\set name deduced
\set granularity day
-- quoted granularity
\set q_granularity '''' :granularity ''''

DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select date_trunc(:q_granularity,time) as :granularity, count(*)
	from tx
	  join txin using (txid)
	  join ring using (inid)
	where matched = 'real'
	GROUP BY 1 order by 1 asc
	---- alternatively use this line selector that also counts inputs with only small candidate sets
	-- where not undecided(matched) 
);

COMMENT ON TABLE :name IS 'Query: #Inputs that have been deduced'; -- PLEASE FILL OUT TO PREVENT CONFUSION