-- Get sets for each input
\timing on
\set name spent_sets

DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
WITH sets AS (
	SELECT inid
	,	effective_ringsize
	,	array_agg(outid ORDER BY outid) AS outids
	FROM ring join txi using (inid)
	where matched = 'unknown'
	GROUP BY inid, effective_ringsize
)
SELECT outids
	,	array_agg(inid) as inids
	,	effective_ringsize
	FROM sets
	WHERE effective_ringsize > 1
	GROUP BY effective_ringsize, outids
	HAVING count(inid) = effective_ringsize  -- sets that are completely spent
);

--! -- This version does not take already identified real inputs into account.
--! -- Therefore most likely worse than the above, though maybe interesting for whatever
-- \set name spent_sets_legacy
-- DROP TABLE IF EXISTS :name;
-- CREATE TABLE :name AS (
-- WITH sets AS (
-- 	SELECT inid, amount, count(outid) as ringsize, array_agg(outid ORDER BY outid) AS outids
-- 	FROM ring join txout using (outid)
-- 	GROUP BY inid, amount
-- )
-- SELECT amount, ringsize, outids, array_agg(inid) as inids
-- 	FROM sets
-- 	WHERE ringsize > 1
-- 	GROUP BY (amount, ringsize,outids)
-- 	HAVING count(inid) = ringsize  -- sets that are completely spent
-- );
-- COMMENT ON TABLE :name IS 'Query: Sets of TXOs that are spent in TXIs (not sure in which one though) [before applying 0-mixin-removal]';
