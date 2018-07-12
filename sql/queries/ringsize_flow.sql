\set name flow_eff
drop table if exists :name;
create table :name as  
select effective_ringsize
	,coalesce(ring1,0) as ring1
	,coalesce(ring2,0) as ring2
	,coalesce(ring3,0) as ring3
	,coalesce(ring4,0) as ring4
	,coalesce(ring5,0) as ring5
	,coalesce(ring6,0) as ring6
	,coalesce(ring7,0) as ring7
	,coalesce(ring8,0) as ring8
	,coalesce(ring9,0) as ring9
	,coalesce(ring10,0) as ring10
 from crosstab($$
	select ringBrackets(effective_ringsize), ringBrackets(ringsize), count(*) from txi where ringsize > 1 group by 1,2 order by 1,2
	$$,$$ -- this query generates all possible categories (basically numbeeffective_ringsize from 1 to 10 (inclusive)
		select distinct ringbrackets(ringsize) from txi order by 1 asc$$
	) as r(effective_ringsize integer
	, ring1 integer
	, ring2 integer
	, ring3 integer
	, ring4 integer
	, ring5 integer
	, ring6 integer
	, ring7 integer
	, ring8 integer
	, ring9 integer
	, ring10 integer
	);
comment on table :name is 'Query: For any eff. ringsize (1..9,10+), how many rings of size (1..9,10+) end up in this set';

\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER DELIMITER E'\t';


\set name flow_rs
drop table if exists :name;
create table :name as 
select ringsize
	,coalesce(eff_ring1,0) as eff_ring1
	,coalesce(eff_ring2,0) as eff_ring2
	,coalesce(eff_ring3,0) as eff_ring3
	,coalesce(eff_ring4,0) as eff_ring4
	,coalesce(eff_ring5,0) as eff_ring5
	,coalesce(eff_ring6,0) as eff_ring6
	,coalesce(eff_ring7,0) as eff_ring7
	,coalesce(eff_ring8,0) as eff_ring8
	,coalesce(eff_ring9,0) as eff_ring9
	,coalesce(eff_ring10,0) as eff_ring10
 from crosstab($$
	select ringBrackets(ringsize), ringBrackets(effective_ringsize), count(*) from txi where ringsize > 1 group by 1,2 order by 1,2
	$$,$$ -- this query generates all possible categories (basically numbers from 1 to 10 (inclusive)
		select distinct ringbrackets(effective_ringsize) from txi order by 1 asc$$
	) as r(ringsize integer
	, eff_ring1 integer
	, eff_ring2 integer
	, eff_ring3 integer
	, eff_ring4 integer
	, eff_ring5 integer
	, eff_ring6 integer
	, eff_ring7 integer
	, eff_ring8 integer
	, eff_ring9 integer
	, eff_ring10 integer
	);
comment on table :name is 'Query: For rings of size (1..9,10+), what is their eff. rs after traceability analysis?';
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER DELIMITER E'\t';
