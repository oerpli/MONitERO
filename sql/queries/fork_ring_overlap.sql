drop table if exists fork_ring_overlap;
create table fork_ring_overlap as 
with keyimgs as (select keyimg, inid, xmo_inid from xmo_txin join txin using(keyimg))
, xmr_rings as(select keyimg, inid, array_agg(outid order by outid) as xmr_out from keyimgs join ring using (inid) group by 1,2)
, xmo_rings as(select keyimg, xmo_inid, array_agg(coalesce(outid,-xmo_outid) order by outid) as xmo_out from keyimgs join xmo_ring using (xmo_inid) group by 1,2)
select keyimg, 'XMO' as fork, #xmo_out as ringsize, #xmr_out as ringsize_xmr, #(xmo_out & xmr_out) as overlap from xmo_rings join xmr_rings using(keyimg);


with keyimgs as (select keyimg, inid, xmv_inid from xmv_txin join txin using(keyimg))
, xmr_rings as(select keyimg, inid, array_agg(outid order by outid) as xmr_out from keyimgs join ring using (inid)group by 1,2)
, xmv_rings as(select keyimg, xmv_inid, array_agg(coalesce(outid,-xmv_outid) order by outid) as xmv_out from keyimgs join xmv_ring using (xmv_inid)group by 1,2)
insert into fork_ring_overlap
select keyimg, 'XMV' as fork, #xmv_out as ringsize, #xmr_out as ringsize_xmr, #(xmv_out & xmr_out) as overlap from xmv_rings join xmr_rings using(keyimg);



\i ../paths.sql

-- ringsize distribution of matching keyimgs
-- 10 stands for >= 10
\set name fork_match_rings
\set file :outfolder:name'.csv'''
COPY(select
        case when ringsize<= 9 then ringsize else 10 end as ringsize
    ,   count(case when fork ='XMO' then 1 end) as XMO_total
    ,   count(case when fork ='XMV' then 1 end) as XMV_total
    ,   count(case when fork ='XMO' and ringsize > overlap then 1 end) as XMO_diff
    ,   count(case when fork ='XMV' and ringsize > overlap then 1 end) as XMV_diff
    ,   count(case when fork ='XMO' and ringsize = overlap then 1 end) as XMO_match
    ,   count(case when fork ='XMV' and ringsize = overlap then 1 end) as XMV_match
    from fork_ring_overlap
    group by 1
    order by 1 asc
)TO :file CSV HEADER DELIMITER E'\t';

