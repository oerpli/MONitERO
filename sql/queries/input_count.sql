\timing on
\set name input_count
\set granularity month

-- quoted granularity
\set q_granularity '''' :granularity ''''

-- QUERY
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	SELECT date_trunc(:q_granularity,day) as :granularity,sum(icount(ringsizes)) as count
	FROM ringsize_distr
	GROUP BY :granularity
	ORDER BY :granularity
);

COMMENT ON TABLE :name IS 'Query: Count number of transaction inputs (rings) per ':q_granularity;
