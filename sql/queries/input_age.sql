\timing on
\set name input_age
\set granularity month
-- quoted granularity
\set q_granularity '''' :granularity ''''
\set dgranularity hour
-- quoted granularity
\set q_dgranularity '''' :granularity ''''


DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select date_trunc(:q_granularity,intime) as :granularity,log(extract(epoch from age)::integer +1,2) as log2_age_min, count(*) as age_count
	from ringtime
	group by 1,2
	order by 1,2 asc
);

COMMENT ON TABLE :name IS 'Query: Age distribution (precision: minute) of inputs, aggregated by month'; -- PLEASE FILL OUT TO PREVENT CONFUSION