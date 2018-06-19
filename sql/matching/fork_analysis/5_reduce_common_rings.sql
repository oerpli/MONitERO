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
    select :inid1,:inid2, (one & two) as common from 
        (select :inid1, keyimg, array_agg(:ring1.outid order by :ring1.outid) as one
            from :txin2
            join :txin1 using(keyimg)
            join :ring1 using(:inid1)
            where matched <> 'mixin' and :ring1.outid is not null
            group by 1,2
        ) as a
    join
        (select :inid2, keyimg, array_agg(:ring2.outid order by :ring2.outid) as two
            from :txin1
            join :txin2 using(keyimg)
            join :ring2 using(:inid2)
            where matched <> 'mixin' and :ring2.outid is not null
            group by 1,2
        ) as b
    using (keyimg)
    where one<>two
    -- and #(one & two) > 0
), r1 as (
    update :ring1 r
    set matched = 'mixin'
    from info_table i
    where i.:inid1 = r.:inid1
    and r.matched = 'unknown'
    and (
        r.outid IS NULL -- this only happens if its an output not on the other chains. must be mixin as keyimg is shared with other chains
        OR
        idx(common, r.outid) = 0)
    returning 0
)
    update :ring2 r
    set matched = 'mixin'
    from info_table i
    where i.:inid2 = r.:inid2
    and r.matched = 'unknown'
    and (
        r.outid IS NULL -- this only happens if its an output not on the other chains. must be mixin as keyimg is shared with other chains
        OR
        idx(common, r.outid) = 0)
;