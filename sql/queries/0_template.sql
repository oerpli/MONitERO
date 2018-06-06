\timing on
\set name QUERYNAME
\set granularity day
-- quoted granularity
\set q_granularity '''' :granularity ''''


DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	-- QUERY HERE (dont forget to order)
);

COMMENT ON TABLE :name IS 'Query: '; -- PLEASE FILL OUT TO PREVENT CONFUSION