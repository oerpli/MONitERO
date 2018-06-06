\timing on
-- \set granularity month

-- -- quoted granularity
-- \set q_granularity '''' :granularity ''''


\set name ringsizes
DROP MATERIALIZED VIEW IF EXISTS :name;
-- Short crosstab explanation (for more details look in documentation):
-- Given a query "A,B,V" where:
-- A: is something arbitrary
-- B: has N different categorical values (may also work else but no idea what it does in this case)
-- V: are values for the given A and B
-- crosstab(*sql*, N) then creates a table T(A, B_1, B_2, ..., B_N) where the values for each B_1 are given by whatever the value of V is in the row of the given A and B value.
-- the problem with crosstab(*sql,N) is that values go into the first column and it is not really checked what the value of B is (BUG MAYBE?)
-- therefore use (*sql*, *cat_sql*) where *cat_sql* is a query that gives all possible columns in a specific order
CREATE MATERIALIZED VIEW :name AS (
   with avgmedian as ( -- median needed?
     select date_trunc('month',time)::DATE as month
      , round(avg(ringsize)::numeric,4) as avg
      , round(avg(effective_ringsize)::numeric,4) as effavg
      , count(*) as total
     from tx join txi using(txid) group by 1
   )
   select month, avg, effavg,total --! SELECT FOR VIEW IS HERE
      ,coalesce(round("ring1"::numeric/total,4),0) as "ring1",coalesce(round("ring2"::numeric/total,4),0) as "ring2"
      ,coalesce(round("ring3"::numeric/total,4),0) as "ring3",coalesce(round("ring4"::numeric/total,4),0) as "ring4"
      ,coalesce(round("ring5"::numeric/total,4),0) as "ring5",coalesce(round("ring6"::numeric/total,4),0) as "ring6"
      ,coalesce(round("ring7"::numeric/total,4),0) as "ring7",coalesce(round("ring8"::numeric/total,4),0) as "ring8"
      ,coalesce(round("ring9"::numeric/total,4),0) as "ring9",coalesce(round("ring10"::numeric/total,4),0) as "ring10"
      ,coalesce(round("effring1"::numeric/total,4),0) as "effring1",coalesce(round("effring2"::numeric/total,4),0) as "effring2"
      ,coalesce(round("effring3"::numeric/total,4),0) as "effring3",coalesce(round("effring4"::numeric/total,4),0) as "effring4"
      ,coalesce(round("effring5"::numeric/total,4),0) as "effring5",coalesce(round("effring6"::numeric/total,4),0) as "effring6"
      ,coalesce(round("effring7"::numeric/total,4),0) as "effring7",coalesce(round("effring8"::numeric/total,4),0) as "effring8"
      ,coalesce(round("effring9"::numeric/total,4),0) as "effring9",coalesce(round("effring10"::numeric/total,4),0) as "effring10"
      from avgmedian
      natural join
      crosstab($$
        with temp as (
            SELECT  date_trunc('month',time)::DATE AS month
                , ringBrackets(ringsize) -- n > 10 => 10
                , count(*)
            FROM tx JOIN txi USING (txid)
            GROUP BY 1,2
            ORDER BY 1,2 ASC)
        select * from temp order by 1,2
    $$,$$ -- this query generates all possible categories (basically numbers from 1 to 10 (inclusive)
      select distinct ringbrackets(ringsize) from txi order by 1 asc$$
   ) as r(month date
      ,"ring1" bigint,"ring2" bigint,"ring3" bigint,"ring4" bigint,"ring5" bigint
      ,"ring6" bigint,"ring7" bigint,"ring8" bigint,"ring9" bigint,"ring10" bigint
   )
   natural join
    crosstab($$
        with temp as (
            SELECT  date_trunc('month',time)::DATE AS month
                , ringBrackets(effective_ringsize) -- n > 10 => 10
                , count(*)
            FROM tx JOIN txi USING (txid)
            GROUP BY 1,2
            ORDER BY 1,2 ASC)
        select * from temp order by 1,2
    $$,$$ -- this query generates all possible categories (basically numbers from 1 to 10 (inclusive)
      select distinct ringbrackets(ringsize) from txi order by 1 asc$$
   ) as er(month date
      ,"effring1" bigint,"effring2" bigint,"effring3" bigint,"effring4" bigint,"effring5" bigint
      ,"effring6" bigint,"effring7" bigint,"effring8" bigint,"effring9" bigint,"effring10" bigint
   )
);
COMMENT ON MATERIALIZED VIEW :name IS 'Query: Distribution of ringsizes (ring1-10) and effective ringsizes (effring1-10) for each month (x10: >= 10)';



\set name ringsizes_nontrivial
DROP MATERIALIZED VIEW IF EXISTS :name;
CREATE MATERIALIZED VIEW :name AS (
   with avgmedian as ( -- median needed?
     select date_trunc('month',time)::DATE as month
      , round(avg(ringsize)::numeric,4) as avg
      , round(avg(effective_ringsize)::numeric,4) as effavg
      , count(*) as total
     from tx join txi using(txid)
     where ringsize > 1
     group by 1
   )
   select month, avg, effavg,total --! SELECT FOR VIEW IS HERE
      ,coalesce(round("ring1"::numeric/total,4),0) as "ring1",coalesce(round("ring2"::numeric/total,4),0) as "ring2"
      ,coalesce(round("ring3"::numeric/total,4),0) as "ring3",coalesce(round("ring4"::numeric/total,4),0) as "ring4"
      ,coalesce(round("ring5"::numeric/total,4),0) as "ring5",coalesce(round("ring6"::numeric/total,4),0) as "ring6"
      ,coalesce(round("ring7"::numeric/total,4),0) as "ring7",coalesce(round("ring8"::numeric/total,4),0) as "ring8"
      ,coalesce(round("ring9"::numeric/total,4),0) as "ring9",coalesce(round("ring10"::numeric/total,4),0) as "ring10"
      ,coalesce(round("effring1"::numeric/total,4),0) as "effring1",coalesce(round("effring2"::numeric/total,4),0) as "effring2"
      ,coalesce(round("effring3"::numeric/total,4),0) as "effring3",coalesce(round("effring4"::numeric/total,4),0) as "effring4"
      ,coalesce(round("effring5"::numeric/total,4),0) as "effring5",coalesce(round("effring6"::numeric/total,4),0) as "effring6"
      ,coalesce(round("effring7"::numeric/total,4),0) as "effring7",coalesce(round("effring8"::numeric/total,4),0) as "effring8"
      ,coalesce(round("effring9"::numeric/total,4),0) as "effring9",coalesce(round("effring10"::numeric/total,4),0) as "effring10"
      from avgmedian
      natural join
      crosstab($$
        with temp as (
            SELECT  date_trunc('month',time)::DATE AS month
                , ringBrackets(ringsize) -- n > 10 => 10
                , count(*)
            FROM tx JOIN txi USING (txid)
            WHERE ringsize > 1
            GROUP BY 1,2
            ORDER BY 1,2 ASC)
        select * from temp order by 1,2
    $$,$$ -- this query generates all possible categories (basically numbers from 1 to 10 (inclusive)
      select distinct ringbrackets(ringsize) from txi order by 1 asc$$
   ) as r(month date
      ,"ring1" bigint,"ring2" bigint,"ring3" bigint,"ring4" bigint,"ring5" bigint
      ,"ring6" bigint,"ring7" bigint,"ring8" bigint,"ring9" bigint,"ring10" bigint
   )
   natural join
    crosstab($$
        with temp as (
            SELECT date_trunc('month',time)::DATE AS month
                , ringBrackets(effective_ringsize) -- n > 10 => 10
                , count(*)
            FROM tx JOIN txi USING (txid)
            WHERE RINGSIZE > 1
            GROUP BY 1,2
            ORDER BY 1,2 ASC)
        select * from temp order by 1,2
    $$,$$ -- this query generates all possible categories (basically numbers from 1 to 10 (inclusive)
      select distinct ringbrackets(ringsize) from txi order by 1 asc$$
   ) as er(month date
      ,"effring1" bigint,"effring2" bigint,"effring3" bigint,"effring4" bigint,"effring5" bigint
      ,"effring6" bigint,"effring7" bigint,"effring8" bigint,"effring9" bigint,"effring10" bigint
   )
);
COMMENT ON MATERIALIZED VIEW :name IS 'Query: Distribution of ringsizes (ring1-10) and effective ringsizes (effring1-10) of nontrivial TXs (rs>1) for each month (ring10: ringsize >= 10)'; 