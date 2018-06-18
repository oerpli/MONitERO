with matchable as (
	select :inid from :ring
	where matched <> 'mixin' -- function that maps all possible enum values to their decidedstatus
	group by :inid
	having count(*) = 1 -- this makes sure only one possible match in next CTE
), new_real as (
	update :ring
	set matched = 'real'
	from matchable
	where matchable.:inid = :ring.:inid
	and undecided(matched) -- does not update rows that are already 'real' or 'mixin'
	returning outid
)
update :ring
set matched = 'mixin'
from new_real
where new_real.outid = :ring.outid
  and :ring.outid is not null
  and :ring.matched <> 'real';
