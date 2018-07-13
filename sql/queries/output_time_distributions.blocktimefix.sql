\i paths.sql
\set fprecision 1

\set name output_time_distributions_fix



drop table if exists time_distr_test_fix;
create table time_distr_test_fix as
-- instead of just the block_diff, here the approximated time is computed
-- this is necessary, because up to block 1009827 (:f) the block-time has been 1 minute
-- and since its 2 minutes. Therefore the time-difference (which is approximated with block difference) is twice as large.
-- y = output_block_height
-- x = spent_block_height
-- f = fork_height
-- there are 3 cases:
-- x > f & y > f: 2(x-y) +   0
-- x > f & f > y: 2(x-f) + (f-y)
-- f > x & f > y:    0   + (x-y)
-- The first two can be combined as follows:
-- 2(x-MAX(f,y)) + MAX(0,f-y) // first max takes the larger and second expression is 0 if y > f, just like desired
-- Now combine the 3rd case with this expression to get:
-- MAX(0,2(x-MAX(f,y))) + MAX(0,MIN(f,x)-y)
--
-- Define shortcuts to make formula readable
\set f 1009827
\set x spendheight
\set y (spendheight - block_diff)
--
select trunc(log(2,
	greatest(0,2*(:x-greatest(:f,:y))) + greatest(0,least(:f,:x)-:y)
), :fprecision) as logBlockTime
	,	date_trunc('year',spendtime)::date as year
	,	count(*) as total
	,	count(case when matched = 'real' then 1 end) as real
	,	count(case when matched = 'mixin' then 1 end) as mixin
from ringtime
group by 1,2
order by 1,2 asc;

drop table if exists :name;
create table :name as 
with total_yearly as (
	select *
	from crosstab($$select logBlockTime, year, total from time_distr_test_fix order by 1,2$$
				 ,$$select distinct year from time_distr_test_fix order by 1$$)
		as ct(logBlockTime numeric
			,total_14 integer
			,total_15 integer
			,total_16 integer
			,total_17 integer
			,total_18 integer)
), real_yearly as (
	select * from crosstab($$
	 select logBlockTime, year, real from time_distr_test_fix order by 1,2
	$$,$$
	 select distinct year from time_distr_test_fix order by 1$$) as ct(logBlockTime numeric
		,real_14 integer
		,real_15 integer
		,real_16 integer
		,real_17 integer
		,real_18 integer)
), mixin_yearly as (
	select * from crosstab($$
	 select logBlockTime, year, mixin from time_distr_test_fix order by 1,2
	$$,$$
	 select distinct year from time_distr_test_fix order by 1$$) as ct(logBlockTime numeric
		,mixin_14 integer
		,mixin_15 integer
		,mixin_16 integer
		,mixin_17 integer
		,mixin_18 integer)
), total_overall as (
	select logBlockTime
	, sum(total) as total
	, sum(real) as real
	, sum(mixin) as mixin
	from time_distr_test_fix
	group by 1 order by 1 asc
)
select logBlockTime
	,	coalesce(total, 0) as total
	,	coalesce(real, 0) as real 
	,	coalesce(mixin, 0) as mixin
	-- Yearly values for each
	,	coalesce(total_14, 0) as total_14
	,	coalesce(total_15, 0) as total_15
	,	coalesce(total_16, 0) as total_16
	,	coalesce(total_17, 0) as total_17
	,	coalesce(total_18, 0) as total_18
	,	coalesce(real_14, 0) as real_14 
	,	coalesce(real_15, 0) as real_15
	,	coalesce(real_16, 0) as real_16
	,	coalesce(real_17, 0) as real_17
	,	coalesce(real_18, 0) as real_18
	,	coalesce(mixin_14, 0) as mixin_14
	,	coalesce(mixin_15, 0) as mixin_15
	,	coalesce(mixin_16, 0) as mixin_16
	,	coalesce(mixin_17, 0) as mixin_17
	,	coalesce(mixin_18, 0) as mixin_18
from total_overall
natural join total_yearly
natural join real_yearly
natural join mixin_yearly;

\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER DELIMITER E'\t';
