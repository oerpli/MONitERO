-- Before calling this somewhere, "one" and "two" each must be set to ./def_<FORK>.sql
-- First creates info_table, which contains the intersection of 
--   all rings with common key image from both forks,
--   as long as the rings are not identical on both chains.
-- This is then used to mark every mixin as input that is not in the intersection of the two.

-- Needs definitions for two currencies
-- inid1/inid2 - name of inid column
-- txin1/txin2 - name of txin table
-- ring1/ring2 - name of ring table
-- To make this easier, define variables "one" and "two", which are then combined in defs_XY.sql 
\i ./defs_XY.sql

with info_table as(
    select :inid1, :inid2 from :txin1 join :txin2 using(keyimg)
)
update :ring1 r
    set matched = 'mixin'
    from info_table i
    where i.:inid1 = r.:inid1
    and matched ='unknown'
    and r.outid IS NULL;
