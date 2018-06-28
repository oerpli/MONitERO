\timing on
\set name guess_newest

-- aggregate over month/day/year/whatever?
\set granularity month
\set q_granularity '''' :granularity ''''


-- Set the criterion used for determining the most recent output
-- Either block_diff (block height of input - block height of output)
-- Or age (timestamp of input(-block) - timestamp of output block)
-- As timestamps are not in a linear order i assume that block_diff is the better choice
\set match_criterion block_diff


drop table if exists :name;
create table :name as 
with newest as(
	select inid, min(:match_criterion) as :match_criterion
	from ringtime
	group by 1
), new_match as (
	select inid, spendtime, matched
	from ringtime
	join newest using(inid, :match_criterion)
), results as (
	select date_trunc(:q_granularity,spendtime)::date as :granularity
	,	count(case when undecided(matched) then 1 end) as unknown
	,	count(case when matched = 'real' then 1 end) as correct
	,	count(case when matched = 'mixin' then 1 end) as wrong
	from new_match
	group by 1
)
select *, round(correct::numeric/(correct+wrong), 4) as accuracy
from results
order by 1;

COMMENT ON TABLE :name is 'Query: Accurracy of guess newest heuristic aggregated by month';


-- \set file :outfolder:name'.csv'''
-- COPY :name TO :file CSV HEADER DELIMITER E'\t';
