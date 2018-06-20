\timing on
\set name guess_newest

DROP TABLE IF EXISTS guess_newest_data;
CREATE TABLE guess_newest_data AS (
WITH new_inputs AS (
	select inid, time as txtime
		from txi
		join tx using (txid)
		where effective_ringsize = 1  -- that are traced/linked
		and ringsize > 1 -- and were nontrivial
), all_txos AS (
	select inid, txtime, max(time) as newest, array_agg(time order by time) as times
		from new_inputs
		join ring using (inid)
		join txout using (outid)
		join tx using (txid)
		group by 1,2 order by 1,2
), correct_txo AS (
	select inid, time as time_spent
		from new_inputs
		join ring using(inid)
		join txout using (outid)
		join tx using (txid)
		where matched ='real'
		order by 1
)
select inid, txtime, time_spent, time_spent = newest as valid, times
from all_txos join correct_txo using (inid)
);
COMMENT ON TABLE guess_newest_data IS 'Query: All identified NT rings and whether guess new is correct';

drop table if exists :name;
create table :name as 
select date_trunc('month', txtime )
	, count(*) as total
	, count(case when valid then 1 end)  as valid
	, count(case when not valid then 1 end) as invalid
	, round(count(case when valid then 1 end)::numeric / count(*), 4) as accurracy
from guess_newest_data
group by 1
order by 1 asc;

COMMENT ON TABLE :name is 'Accurracy of guess newest heuristic aggregated by month';