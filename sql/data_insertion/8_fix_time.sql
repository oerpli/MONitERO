--! STUFF DOES NOT WORK YET

with blocktimes as (
	select distinct block as b, time as t from tx where block > 0
), avgtime as (
select block,time, to_timestamp(floor(avg(extract(epoch from t)))-7200)  as timeavg
from tx
join blocktimes
	on  tx.block <= b + 5
	and tx.block >= b - 5
where block > 123120
and   block < 123130
group by block,time)
select block, time, timeavg, time-timeavg as diff from avgtime order by block;



-- Block time interpolation function
CREATE OR REPLACE FUNCTION interpolate_time(height INTEGER) 
RETURNS timestamp without time zone AS $$
DECLARE
	t1 timestamp without time zone;
	t2 timestamp without time zone;
	t3 timestamp without time zone;
	i1 interval;
	i2 interval;
	return_time timestamp without time zone;
	max_block integer;
BEGIN
	-- t1 := (select time from tx where block = 1 limit 1); --  '2014-04-18 10:49:53';
	-- t2 := (select time from tx where block = 1009827 limit 1); -- '2016-03-23 15:57:38';
	-- -- max_block := select max(block) from tx;
	-- t3 := (select max(time) from tx limit 1); -- '2018-05-14 23:21:31'
	-- max_block := (select max(block) from tx limit 1); --1572893

	-- Use hardcoded values instead to improve speed.
	t1 := (select '2014-04-18 10:49:53');
	t2 := (select '2016-03-23 15:57:38');
	t3 := (select '2018-05-14 23:21:31');
	max_block := (select 1572893);

	i1 := (select (t2-t1) / (1009827 - 1));
	i2 := (select (t3-t2) / (max_block - 1009827));

	CASE
		WHEN $1 < 1009827
		THEN return_time := t1 +  ($1 - 1) * (i1);
		ELSE return_time := t2 +  ($1 - 1009827) * (i2);
	END CASE;
	return return_time;
END; $$
LANGUAGE plpgsql immutable;



select block, min(time), interpolate_time(block),  min(time)-interpolate_time(block) from tx group by block limit 10;
se