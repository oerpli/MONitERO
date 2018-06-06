\timing on
---- Use this CTE if txin table does not have ringsize.
---- This field would be added by calling 4_modify_tables.sql
-- WITH ringsizes as (
--    select inid, count(outid) as ringsize
--    from ring
--    group by inid
-- )

-- aggregate over month/day/year/whatever?
\set granularity month
-- name of new table
\set name monthly_stats

-- creat quoted version of variable
\set q_granularity '''' :granularity ''''
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
   select date_trunc(:q_granularity,time)::DATE as :granularity
      , count(*) as total
      , count(case when ringsize = 1 then 1 end) as trivial
      , count(case when effective_ringsize = 1 then 1 end) as linked
      , count(case when ringsize > 1 and  effective_ringsize = 1 then 1 end) as linked_nontrivial
      , count(case when ringsize > minringsize(block) then 1 end) as nonMin
   from tx join txi using (txid)
   group by 1 order by 1 asc
);

COMMENT ON TABLE :name IS 'Ringsize and effective ringsizes over time';
