\timing on
\set name verify_guess_newest
\set startDate '''2018-01-01'''


DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
WITH new_inputs AS (
	select inid
		from txi
		join tx using (txid)
		where time > :startDate -- new inputs
		and effective_ringsize = 1  -- that are traced/linked
		and ringsize > 1 -- and were nontrivial
), all_txos AS (
	select inid, max(time) as newest, array_agg(time) as times
		from new_inputs
		join ring using (inid)
		join txout using (outid)
		join tx using (txid)
		group by 1 order by 1
), correct_txo AS (
	select inid, time as time_spent
		from new_inputs
		join ring using(inid)
		join txout using (outid)
		join tx using (txid)
		where matched ='real'
		order by 1
)
	select inid, time_spent, time_spent = newest as valid, times
	from all_txos join correct_txo using (inid)
);

COMMENT ON TABLE :name IS 'Query: Rings (since 2018-01-01) where guess-newest is correct';