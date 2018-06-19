-- IR works somewhat differently on multiple chains.
-- For each set of inputs, get set of keyimgs
-- If #(set of inputs) = #(keyimgs), there is an intersection.

-- Extremely unlikely, though implemented for shit & giggles

-- Note that for forks not only outid but also fork_outids have to be considered as possible real input.
-- To prevent matches if xmv_/xmo_ outids are by chance the same (will never happen but whatever), take negative value of those.



with xmr_rings as
	(select keyimg, array_agg(outid) as outs from ring natural join txi where matched = 'unknown' group by 1)
,	 xmv_rings as
	(select keyimg, array_agg(coalesce(outid,-xmv_outid)) as outs from xmv_ring natural join xmv_txi where matched = 'unknown' group by 1)
,	 xmo_rings as
	(select keyimg, array_agg(coalesce(outid,-xmo_outid)) as outs from xmo_ring natural join xmo_txi  where matched = 'unknown' group by 1)
select array_agg(keyimg) as keyimgs, outs
from xmr_rings
join xmv_ring using(outs)
join xmo_ring using(outs)
group by 


select array_agg(chain) as chains, outs, array_agg(keyimg) as keyimgs
from (
	(select 1 as chain, keyimg, array_agg(outid) as outs from ring natural join txi
	where matched = 'unknown' group by 1,2)
	union
	(select 2 as chain, keyimg, array_agg(coalesce(outid,-xmv_outid)) as outs from xmv_ring natural join xmv_txi
	where matched = 'unknown' group by 1,2)
	union
	(select 3 as chain, keyimg, array_agg(coalesce(outid,-xmo_outid)) as outs from xmo_ring natural join xmo_txi
	where matched = 'unknown' group by 1,2)
) as a
group by outs having count(distinct keyimg) = #outs;
