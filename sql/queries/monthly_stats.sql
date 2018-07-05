\timing on
-- name of new table
\set name monthly_stats
-- aggregate over month/day/year/whatever?
\set granularity month
-- desired precision of various floats in the table. a precision of 2 should be enough for everybody (abraham hinteregger)
\set fprecision 2

-- creat quoted version of variable
\set q_granularity '''' :granularity ''''
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
WITH tx_stats as (select date_trunc(:q_granularity,time)::DATE as :granularity
      , count(distinct txid) as num_tx -- #TXs
      , count(distinct case when coinbase then txid end) as cb_tx -- #non coinbase TXs
      , count(distinct case when not coinbase then txid end) as real_tx -- #non coinbase TXs
      , count(distinct case when ringct then txid end) as ringct -- #ringct TXs
   from tx
   group by 1 order by 1 asc
) -- No CB TXs per default when joining with tx inputs
,   input_stats as (select date_trunc(:q_granularity,time)::DATE as :granularity
      , round(count(distinct inid)::numeric / count(distinct txid),:fprecision) as avg_in -- AVG #inputs per TX
      , count(*) as num_in -- #Inputs
      , count(case when effective_ringsize = 1 then 1 end) as linked_in -- #Inputs with known real
      , count(case when ringsize > 1 then 1 end) as nt_in -- #Inputs(ringsize > 1)
      , round(count(case when ringsize > 1 and  effective_ringsize = 1 then 1 end)::numeric/ count(distinct case when ringsize > 1 then inid end),:fprecision) as linked_nt -- #Inputs(ringsize > 1) with known real (relative)
      , count(case when ringsize > 1 and effective_ringsize = 1 then 1 end) as linked_nt_abs -- #Inputs(ringsize > 1) with known real (absolute)
      , round(avg(ringsize)::numeric,:fprecision) as avg_rs -- Average Ringsize
      , round(avg(effective_ringsize)::numeric,:fprecision) as avg_eff_rs -- Average Effective Ringsize
      , round(count(case when ringsize <= minringsize(block) then 1 end)::numeric/ count(distinct inid),:fprecision) as rel_min_rs -- Amount of inputs that only uses minimum possible RS (or less, due to some old pre-RingCT outputs with denom)
    --   , round(avg(case when ringsize > minringsize(block) then ringsize - minringsize(block) -1 end),:fprecision) as avgExtraMixins -- commented out - uninteresting table
   from tx join txi using(txid)
   group by 1 order by 1 asc
) -- Excluded CB TXs with where clause
,   output_stats as (select date_trunc(:q_granularity,time)::DATE as :granularity
      , count(*) as num_out -- #Outputs
      , round(count(distinct outid)::numeric / count(distinct txid),:fprecision) as avg_out -- Average #Outputs per TX
      , count(distinct amount) as dist_amount -- # distinct nonCB denominations
      , round(sum(amount),:fprecision) as volume -- nonCB TX volume  (not useful after ringct though)
   from tx join txout using (txid)
   where not coinbase
   group by 1 order by 1 asc
)
select *
from tx_stats
    join input_stats using (:granularity)
    join output_stats using(:granularity)
order by :granularity asc
);
COMMENT ON TABLE :name IS 'Monthly TX stats, output and input stats exclude coinbase TXs. Details in .sql file';


-- \set file :outfolder:name'.csv'''
-- COPY :name TO :file CSV HEADER DELIMITER E'\t';
