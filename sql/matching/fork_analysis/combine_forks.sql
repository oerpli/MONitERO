-- First part is deprecated, due to better (more general) methods implemented now

-- with v_to_o as (
-- 	select * from (
-- 		select xmv_inid, xmo_inid,xmv_txi.effective_ringsize as ver, xmo_txi.effective_ringsize as oer-- fer = fork effective ringsize
-- 		from xmv_txi join xmo_txi using(keyimg)) as a
-- 	where oer <> ver and ver = 1
-- ), new_real as (
-- update xmo_ring
-- set matched = 'real'
-- from xmv_ring, v_to_o
-- where xmv_ring.matched = 'real'
-- and v_to_o.xmv_inid = xmv_ring.xmv_inid
-- and v_to_o.xmo_inid = xmo_ring.xmo_inid
-- and xmo_ring.outid = xmv_ring.outid
-- and xmo_ring.legacy
-- returning xmo_ring.xmo_inid
-- )
-- update xmo_ring
-- set matched = 'mixin'
-- from new_real
-- where xmo_ring.xmo_inid = new_real.xmo_inid
-- and matched <> 'real';

-- select * from (
-- 	select xmv_inid, xmo_inid,xmv_txi.effective_ringsize as ver, xmo_txi.effective_ringsize as oer-- fer = fork effective ringsize
-- 	from xmv_txi join xmo_txi using(keyimg)) as a natural join xmo_ring
-- where oer <> ver and ver = 1 and matched = 'real' order by xmo_inid;




\echo '>> Finding matching keyimgs that exist in both forks'

-- Set variables to first fork
\set txin1 xmo_txin
\set txi1 xmo_txi
\set ring1 xmo_ring
\set inid1 xmo_inid

-- Variables for second fork
\set txin2 xmv_txin
\set txi2 xmv_txi
\set ring2 xmv_ring
\set inid2 xmv_inid

-- Names for tables combining infos from both
\set matches xmov_matches
\set keyimg xmov_keyimg


DROP MATERIALIZED VIEW IF EXISTS :keyimg;
CREATE MATERIALIZED VIEW :keyimg AS
SELECT :inid1, :inid2, keyimg FROM :txin1 join :txin2 using (keyimg);

\echo '>> Looking at common inputs from matching keyimg-TXIs'
DROP TABLE IF EXISTS :matches;
CREATE TABLE :matches AS 
WITH in_xmo as (
select keyimg, :inid1
	, array_remove(array_agg(outid order by outid), NULL) as outidA
	from :keyimg
	join :ring1 using (:inid1)
	group by 1,2
), in_xmv as(
select keyimg,:inid2
	, array_remove(array_agg(outid order by outid), NULL) as outidB
	from :keyimg
	join :ring2 r using (:inid2)
	group by 1,2
)
SELECT :inid1, :inid2, (outidA & outidB) as common
FROM in_xmo join in_xmv using (keyimg);

select :inid1, :txi1.effective_ringsize as erA, :inid2, :txi2.effective_ringsize as erB, #common
from :matches join :txi1 using(:inid1) join :txi2 using(:inid2);

update :ring1 r
set matched = 'mixin'
from :matches m
where r.:inid1 = m.:inid1
and not (legacy and idx(common,r.outid) > 0); -- checks if outid is not in common 

update :ring2 r
set matched = 'mixin'
from :matches m
where r.:inid2 = m.:inid2
and not (legacy and idx(common,r.outid) > 0); -- checks if outid is not in common 


