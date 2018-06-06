\timing on
\set name denoms
---- Currently not considered, though may be in the future (look how denoms change over time)
-- \set granularity day
-- -- quoted granularity
-- \set q_granularity '''' :granularity ''''


DROP TABLE IF EXISTS :name CASCADE;
CREATE TABLE :name AS (
	SELECT
		rank() over (order by count desc),
		*
	FROM (
		SELECT
			amount, ringct,
			count(*)
		FROM txout
			NATURAL JOIN tx
		GROUP BY amount,ringct
		ORDER BY count DESC
	) as a
);

CREATE INDEX index_denoms_amount ON :name(amount);
CREATE INDEX index_denoms_count ON :name(count);



COMMENT ON TABLE :name IS 'Query: Denominations and their respective count';