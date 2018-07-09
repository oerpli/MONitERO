\set name merge_stats
-- aggregate over month/day/year/whatever?
\set granularity month
\set q_granularity '''' :granularity ''''
\set fprecision 3

drop table if exists :name;
create table :name as
with outstats as(
    select date_trunc(:q_granularity, time)::date as :granularity
    , count(distinct txid) as count_out -- number of TXs where some outputs are later identified via OMH
    , count(case when matched = 'real' then inid end) as correct_out -- same result as ZMR
    , count(case when matched = 'mixin' then inid end) as wrong_out -- WRONG result
    , count(case when matched = 'unknown' then inid end) as unknown_out -- Unknown
    from tx
     join txout using(txid)
     join (select inid,outid,matched,matched_merge from ring join txi using(inid) where ringsize > 1) as a using(outid)
    where matched_merge = 'real'
    group by 1
), instats as(
    select date_trunc(:q_granularity, time)::date as :granularity
    , count(distinct txid) as count_in -- number of TXs where some inputs are identified via OMH
    , count(case when matched = 'real' then inid end) as correct_in -- different results as above. 
    , count(case when matched = 'mixin' then inid end) as wrong_in -- different results as above. 
    , count(case when matched = 'unknown' then inid end) as unknown_in -- different results as above. 
    from tx
     join txi using (txid)
     join ring using (inid)
    where ringsize > 1 and matched_merge = 'real'
    group by 1
)
select * 
    , round(correct_out::numeric / NULLIF(correct_out + wrong_out,0),:fprecision) as accuracy_out
    , round(correct_in::numeric / NULLIF(correct_in + wrong_in,0),:fprecision) as accuracy_in
from outstats
join instats using (:granularity)
order by :granularity asc;

COMMENT ON TABLE :name IS 'Query: Monthly stats for accuracy of OMH';


\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER DELIMITER E'\t';


\set name merge_ringstats
\set file :outfolder:name'.csv'''

drop table if exists :name;
create table :name as
select ringsize
	, count(case when matched = 'real' then 1 end) as real
	, count(case when matched = 'mixin'then 1 end) as mixin
	, count(case when matched = 'unknown' then 1 end) as unknown
	, count(case when time > '2018-01-01' and matched = 'real' then 1 end) as real_new
	, count(case when time > '2018-01-01' and matched = 'mixin'then 1 end) as mixin_new
	, count(case when time > '2018-01-01' and matched = 'unknown' then 1 end) as unknown_new
--	replication of kumar et al
	, count(case when block <= 1240503 and matched = 'real' then 1 end) as real_old
	, count(case when block <= 1240503 and matched = 'mixin'then 1 end) as mixin_old
	, count(case when block <= 1240503 and matched = 'unknown' then 1 end) as unknown_old
from txi
join ring using(inid)
join tx using(txid)
where ringsize < 11
and matched_merge = 'real'
group by 1 order by 1 asc;

COPY (
	select * -- select everything and also add relative amounts for each
	-- relative amounts for overall real/mixin/unknown (per ringsize)
	, round(real::numeric / nullif(real+mixin+unknown,0), :fprecision) as real_rel
	, round(mixin::numeric / nullif(real+mixin+unknown,0), :fprecision) as mixin_rel
	, round(unknown::numeric / nullif(real+mixin+unknown,0), :fprecision) as unknown_rel
	-- relative amounts for new real/mixin/unknown (per ringsize)
	, round(real_new::numeric / nullif(real_new+mixin_new+unknown_new,0), :fprecision) as real_rel_new
	, round(mixin_new::numeric / nullif(real_new+mixin_new+unknown_new,0), :fprecision) as mixin_rel_new
	, round(unknown_new::numeric / nullif(real_new+mixin_new+unknown_new,0), :fprecision) as unknown_rel_new
	-- replication of their results?
	, round(real_old::numeric / nullif(real_old+mixin_old+unknown_old,0), :fprecision) as real_rel_old
	, round(mixin_old::numeric / nullif(real_old+mixin_old+unknown_old,0), :fprecision) as mixin_rel_old
	, round(unknown_old::numeric / nullif(real_old+mixin_old+unknown_old,0), :fprecision) as unknown_rel_old
from :name
) TO :file CSV HEADER DELIMITER E'\t';
