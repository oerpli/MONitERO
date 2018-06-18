\timing on
with matchable as (
	select inid from ring
	where matched <> 'mixin' -- these are not real for sure
	group by inid
	having count(*) = 1 -- only those with 1 possible input left
), new_real as (
	update ring
	set matched = 'real'
	from matchable
	where matchable.inid = ring.inid
	and undecided(matched) -- does not update rows that are already 'real' or 'mixin'
	returning outid
)
update ring
set matched = 'mixin'
from new_real
where	new_real.outid = ring.outid
  and	ring.matched <> 'real';



-- select matched,count(*) from ring group by 1 order by 1 asc;