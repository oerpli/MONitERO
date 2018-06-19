\timing on
\set name trivial_ring_coinbase_payout
\set granularity month
-- quoted granularity
\set q_granularity '''' :granularity ''''


DROP TABLE IF EXISTS :name;
WITH coinbase_outputs AS (select outid from tx join txout using (txid) where coinbase) -- 5,876,821
CREATE TABLE :name AS (
	select count(distinct inid)
	from txi
	join ring using (inid)
	join coinbase_outputs using (outid)
	where ringsize = 1
); --3,404,776

-- 3.4M coinbase outputs are spent in a trivial transaction.
-- 25% of trivial transactions are most likely CB payouts.

COMMENT ON TABLE :name IS 'Query: '; -- PLEASE FILL OUT TO PREVENT CONFUSION


