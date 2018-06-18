-- First creates info_table, which contains the intersection of 
--   all rings with common key image from both forks,
--   as long as the rings are not identical on both chains.
-- This is then used to mark every mixin as input that is not in the intersection of the two.

-- Needs definitions for two currencies
-- inid1/inid2 - name of inid column
-- txin1/txin2 - name of txin table
-- ring1/ring2 - name of ring table

with info_table as(
    select :inid1,:inid2, (one & two) as common from 
        (select :inid1, keyimg, array_agg(:ring1.outid order by :ring1.outid) as one
            from :txin2
            join :txin1 using(keyimg)
            join :ring1 using(:inid1)
            where matched <> 'mixin'
            group by 1,2
        ) as a
    join
        (select :inid2, keyimg, array_agg(:ring2.outid order by :ring2.outid) as two
            from :txin1
            join :txin2 using(keyimg)
            join :ring2 using(:inid2)
            where matched <> 'mixin'
            group by 1,2
        ) as b
    using (keyimg)
    where one<>two
), r1 as (
    update :ring1 r
    set matched = 'mixin'
    from info_table i
    where i.:inid1 = r.:inid1
    and r.matched = 'unknown'
    and outid is not null
    and idx(common, r.outid) > 0
    returning 0
)
    update :ring2 r
    set matched = 'mixin'
    from info_table i
    where i.:inid2 = r.:inid2
    and r.matched = 'unknown'
    and outid is not null
    and idx(common, r.outid) > 0
;
