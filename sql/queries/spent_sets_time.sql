\timing on
\set name spent_sets_time
\set granularity day
-- quoted granularity
\set q_granularity '''' :granularity ''''


DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select 
		date_trunc(:q_granularity,time) as :granularity, 
		count(*)
	from(select
		inid
		--, row_number() over (partition by sn) as num
	from(select
		unnest(inids) as inid from spent_sets) as a
		--, row_number() over() as sn,
	) as b natural join txin natural join tx
	group by :granularity order by :granularity asc
);

COMMENT ON TABLE :name IS 'Query: Time distribution of overlapping sets'; -- PLEASE FILL OUT TO PREVENT CONFUSION

