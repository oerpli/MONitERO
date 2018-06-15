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
\set fork_folder 'xmo_data/'
\set oq_curr '''(xmo)'
\set ocurr '''xmo'''
\set otx xmo_tx
\set otxout xmo_txout
\set otxin xmo_txin
\set otxi xmo_txi
\set oring xmo_ring
\set oinid xmo_inid
\set ooutid xmo_outid
\set okeyimg xmo_keyimg
\set omatches xmo_matches
\set oinputs xmo_inputs
\set ooutputs xmo_outputs


\set vq_curr '''(xmv)'
\set vcurr '''xmv'''
\set vtx xmv_tx
\set vtxout xmv_txout
\set vtxin xmv_txin
\set vtxi xmv_txi
\set vring xmv_ring
\set vinid xmv_inid
\set voutid xmv_outid
\set vkeyimg xmv_keyimg
\set vmatches xmv_matches
\set vinputs xmv_inputs
\set voutputs xmv_outputs


\set fork_folder 'xmo_data/'
\set q_curr '''(xmov)'
\set curr '''xmov'''
\set tx xmov_tx
\set txout xmov_txout
\set txin xmov_txin
\set ring xmov_ring
\set inid xmov_inid
\set outid xmov_outid
\set keyimg xmov_keyimg
\set matches xmov_matches
\set inputs xmov_inputs
\set outputs xmov_outputs



DROP MATERIALIZED VIEW IF EXISTS :keyimg;
CREATE MATERIALIZED VIEW :keyimg AS
SELECT :oinid, :vinid, keyimg FROM :otxin join :vtxin using (keyimg);

\echo '>> Looking at common inputs from matching keyimg-TXIs'
DROP TABLE IF EXISTS :matches;
CREATE TABLE :matches AS 
WITH in_xmo as (
select keyimg, :oinid
	, array_remove(array_agg(outid order by outid), NULL) as ooutid
	from :keyimg
	join :oring using (:oinid)
	group by 1,2
), in_xmv as(
select keyimg,:vinid
	, array_remove(array_agg(outid order by outid), NULL) as voutid
	from :keyimg
	join :vring r using (:vinid)
	group by 1,2
)
SELECT :oinid, :vinid, (ooutid & voutid) as common
FROM in_xmo join in_xmv using (keyimg);

select :oinid, :otxi.effective_ringsize as oer, :vinid, :vtxi.effective_ringsize as ver, #common
from :matches join :otxi using(:oinid) join :vtxi using(:vinid);

update :oring r
set matched = 'mixin'
from :matches m
where r.:oinid = m.:oinid
and not (legacy and idx(common,r.outid) > 0); -- checks if outid is not in common 

update :vring r
set matched = 'mixin'
from :matches m
where r.:vinid = m.:vinid
and not (legacy and idx(common,r.outid) > 0); -- checks if outid is not in common 


