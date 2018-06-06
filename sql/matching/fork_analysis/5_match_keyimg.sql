\echo '>> Finding matching keyimgs in both chains'
DROP MATERIALIZED VIEW IF EXISTS :keyimg;
CREATE MATERIALIZED VIEW :keyimg AS
SELECT inid, :inid, keyimg FROM txin join :txin using (keyimg);

\echo '>> Looking at common inputs from matching keyimg-TXIs'
DROP TABLE IF EXISTS :matches;
CREATE TABLE :matches AS 
WITH in_fork as (
select keyimg, :inid
	, array_remove(array_agg(:outid order by :outid), NULL) as fork_out_new
	, array_remove(array_agg(outid order by outid), NULL) as :outid
	from :keyimg
	join :ring rv using (:inid)
	group by 1,2
), in_xmr as(
select keyimg,inid
	, array_remove(array_agg(r.outid order by r.outid), NULL) as outid
	from :keyimg
	join ring r using (inid)
	group by 1,2
)
SELECT inid, :inid, (:outid & outid) as common, outid, :outid, fork_out_new
FROM in_fork join in_xmr using (keyimg);


-- Replayed transactions (same inputs in both chains) can not be used as no additional information is obtained
\echo '>> Remove replayed TXs (identical in both chains, no info gain)'
DELETE FROM :matches WHERE common = outid AND common = :outid;

\echo '>> Update both ring-tables with mixin-information from keyimg-match'
\echo '>>>>Set mixins in ring-table'
UPDATE ring r
SET matched = 'mixin'
FROM (select inid, unnest(outid - common) as outid from :matches) as k
WHERE   r.inid = k.inid
	AND r.outid = k.outid;

\echo '>>>>Set mixins in fork-ring-table (2 UPDATES)'
UPDATE :ring r
SET matched = 'mixin'
FROM (select :inid, unnest(:outid - common) as outid from :matches) as k
WHERE   r.:inid = k.:inid
	AND r.outid = k.outid;

UPDATE :ring r
SET matched = 'mixin'
FROM (select :inid, unnest(:outid) as :outid from :matches) as k
WHERE   r.:inid = k.:inid
	AND r.:outid = k.:outid;

\echo '>> Set real input to spent'
\echo '>>>>Set real in ring-table'
UPDATE ring r
SET matched = 'real'
FROM (select inid, unnest(common) as outid from :matches where #common = 1) as k
WHERE r.inid = k.inid and r.outid= k.outid;

\echo '>>>>Update other occurrences of spent output to mixin in ring-table'
UPDATE ring r
SET matched = 'mixin'
FROM (select inid, unnest(common) as outid from :matches where #common = 1) as k
WHERE r.inid <> k.inid and r.outid= k.outid;

\echo '>>>>Set real in fork-ring-table'
UPDATE :ring r
SET matched = 'real'
FROM (select :inid, unnest(common) as outid from :matches where #common = 1) as k
WHERE r.:inid = k.:inid and r.outid= k.outid;

\echo '>>>>Update other occurrences of spent output to mixin in fork-ring-table'
UPDATE :ring r
SET matched = 'mixin'
FROM (select :inid, unnest(common) as outid from :matches where #common = 1) as k
WHERE r.:inid <> k.:inid and r.outid= k.outid;
