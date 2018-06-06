\timing on
with matchable as (
	select inid from ring
	where undecided(matched) -- function that maps all possible enum values to their decidedstatus
	group by inid
	having count(*) = 1 -- this makes sure only one possible match in next CTE
), new_real as (
	update ring
	set matched = 'real'
	from matchable
	where matchable.inid = ring.inid
	and undecided(matched) -- only applies once, due to match with prev. table
	returning outid
)
update ring
set matched = 'mixin'
from new_real
where	new_real.outid = ring.outid
  and	ring.matched <> 'real';



-- select matched,count(*) from ring group by 1 order by 1 asc;