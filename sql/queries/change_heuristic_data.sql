\timing on
\set name change_heuristic_data
\set granularity month
-- quoted granularity
\set q_granularity '''' :granularity ''''


DROP MATERIALIZED VIEW IF EXISTS :name;
CREATE MATERIALIZED VIEW :name AS (
    select date_trunc(:q_granularity, time) as :granularity
        ,  count(*)
    from(
        select txid
        from txi
        group by txid
        having max(effective_ringsize) = 1
        and   count(*) > 1
    ) as a
    natural join tx
    group by 1
    order by 1 asc
);

COMMENT ON MATERIALIZED VIEW :name IS 'Query: Number of transactions that could be used to estimate change and real outputs'; -- PLEASE FILL OUT TO PREVENT CONFUSION