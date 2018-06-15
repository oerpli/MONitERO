with matched_xmr as (
	select :inid, outid from :txi join txi using(keyimg) join ring using (inid) where matched = 'real'
), u1 as (
update :ring r
set matched = 'real'
from matched_xmr x
where r.:inid = x.:inid
and r.outid = x.outid
and legacy
returning 1
)
update :ring r
set matched = 'mixin'
from matched_xmr x
where r.:inid = x.:inid
and r.outid <> x.outid;

-- Update ring members in fork ring-table. 
-- Caution: Legacy and non-legacy (post-fork-outputs) have to be handled differently
-- Thus 2 update statements
with new_real as (
	select :inid, :outid from :ring where matched ='real' and :outid is not null
)
update :ring 
set matched ='mixin'
from new_real
where :ring.:inid = new_real.:inid
and :ring.:outid <> new_real.:outid ;

with new_real as (
	select :inid, outid from :ring where matched ='real' and outid is not null
)
update :ring 
set matched = 'mixin'
from new_real
where :ring.:inid = new_real.:inid
and (:ring.outid <> new_real.outid or :ring.outid is null);

\i zmr_fork.sql
-- Very low chance that calling this more often helps anything.
-- But for sake of completeness, here it is called another 5 times.
-- Feel free to implement this in a cleaner way. 
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql

REFRESH MATERIALIZED VIEW :txi;

--! Now that the Zero Mixin Removal is done on the fork chain, new 'real' matches can be propagated back to the original chain.
--! Though this only makes sense if one of the newly matched inputs is also on the original chain.
-- select * from (
-- 	select inid, :inid, txi.effective_ringsize as er, :txi.effective_ringsize as fer-- fer = fork effective ringsize
-- 	from txi join :txi using(keyimg)) as a
-- where fer < er;

with fork_info as (
	select inid, :inid, :ring.outid, matched
	from :ring join :matches using(:inid)
	where legacy --equivalent to outid is not null
	and matched <> 'unknown'
)
update ring r
set matched = x.matched
from fork_info x
where x.inid = r.inid
and x.outid = r.outid
and undecided(r.matched);