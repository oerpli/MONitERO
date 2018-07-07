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
    , round(correct_out::numeric / (correct_out + wrong_out),:fprecision) as accuracy_out
    , round(correct_in::numeric / (correct_in + wrong_in),:fprecision) as accuracy_in
    from outstats join instats using (:granularity) order by :granularity asc;

COMMENT ON TABLE :name IS 'Query: Monthly stats for accuracy of OMH';


\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER DELIMITER E'\t';


