\timing on
\set name output_merge

-- Materialized view "output_merge" (defined in ../../data_insertion/init/5_modify_tables.sql)
-- Stores information of TXs that use multiple inputs from a TX in different rings.

-- Some very strange transaction, e.g.:
-- https://moneroblocks.info/search/f065ad6262b350b21a5755828b6844e56175885a810a3c6f6f50aab7be52f24b
-- Lots of inputs with very similar rings

DROP MATERIALIZED VIEW IF EXISTS output_merge;
CREATE MATERIALIZED VIEW output_merge AS
WITH outtx as ( -- txid, outid
    select txid as txidout, unnest(outs) as outid from (select txid, array_agg(outid) as outs from  tx natural join txout group by 1 having count(*) > 1) as a
),intx as ( -- txid, inid
    select txid as txidin, unnest(ins) as inid from (select txid, array_agg(inid) as ins from  tx natural join txin group by 1 having count(*) > 1) as a
),output_mergeCTE as ( -- Ring with ref to TX as well as in/out
    SELECT txidin,inid, txidout as txos, outid as outids
    FROM ring natural join outtx natural join intx
)
SELECT a.txidin as txid -- TX that merges (possibly) two previous TXs
     , a.inid as inid_a -- ring that contains common TX
     , b.inid as inid_b -- ring that contains common TX as well (higher id always)
     , a.txos as txid_common -- TX that is in both TXs
     , a.outids as outid_a -- outid from ring (inid_a,outid_a) occurs in table ring
     , b.outids as outid_b -- same but for b
FROM output_mergeCTE as a
JOIN output_mergeCTE as b
    on a.txidin = b.txidin -- both input rings occur in same TX
    and a.txos = b.txos -- both outputs are from same TX
    and a.inid < b.inid -- prevent that every match is in table twice
    and a.outids <> b.outids; -- remove rows where two inputs ref same output (obviously not correct)

UPDATE RING r -- update all rows in ring that occur somewhere in output_merge table. 
SET matched_merge = 'real'
FROM output_merge o
WHERE (r.inid = inid_a and r.outid = outid_a)
 OR (r.inid = inid_b and r.outid = outid_b);

---- No idea what the purpose of this has been:
-- DROP TABLE IF EXISTS :name;
-- CREATE TABLE :name AS (
--     select a.txidin as txid
--         , a.inid as ain
--         , b.inid as bin
--         , unnest(a.txos & b.txos) as tx_overlap
--         , a.outids as aout
--         , b.outids as bout
--     from output_merge as a
--     join output_merge as b
--         on a.inid < b.inid
--         and a.txidin = b.txidin
--         and a.txos && b.txos
-- );
-- COMMENT ON TABLE :name IS 'Query: TXs that reference same TX in multiple inputs'; -- PLEASE FILL OUT TO PREVENT CONFUSION
