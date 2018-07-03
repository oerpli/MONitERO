\timing on

-- Provably spent outputs:
\set name spent_outputs
\set file :outfolder:name'.csv'''
COPY (select distinct pubk
	from ring
	join txout using(outid)
	where matched = 'real'
	or matched = 'spent'
	order by 1
) TO :file CSV HEADER DELIMITER E'\t';


-- Occurs in TX with only 1-2 mixins (but not with 0)
\set name risky_outputs
\set file :outfolder:name'.csv'''
COPY (select distinct pubk
	from txi 
	join ring using(inid)
	join txout using(outid)
	where matched = 'unknown'
	and effective_ringsize > 1
	and effective_ringsize <= 3
	order by 1
) TO :file CSV HEADER DELIMITER E'\t';


-- Pre-fork outputs that are spent in XMV or XMO
\set name referenced_on_fork
\set file :outfolder:name'.csv'''
COPY (select distinct pubk from (
	(select pubk
		from xmv_txi 
		join xmv_ring using(xmv_inid)
		join txout using(outid)
		where matched <> 'mixin'
		order by 1
	) UNION (select pubk
		from xmo_txi 
		join xmo_ring using(xmo_inid)
		join txout using(outid)
		where matched <> 'mixin'
		order by 1)
	) as fork_pubks
	order by 1
) TO :file CSV HEADER DELIMITER E'\t';