-- Due to a bug in some wallet softwares some pubks occur multiple times
-- This is bad. Therefore only the oldest occurrence of each pubk is allowed in the db (oldest = in first block/with lowest outid if in same block/tx)
\timing on
-- Not sure if path relative to current file or to caller file (in ../) - just do both and let one throw an error
\echo 'The next error is expected behavior'
\i ./paths.sql
\i ../paths.sql
\set name reused_pubk
-- PUBKEYS that occur multiple time.
-- Should most likely not exist - could be a bug in the wallet software used by some clients
-- Related reddit thread: https://www.reddit.com/r/Monero/comments/4h7vy9/should_outputs_public_keys_be_unique_or_not/?st=jfs15d6h&sh=e75a6ba4

DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	SELECT pubk, count(*)
	FROM txout
	GROUP BY 1
	HAVING count(*) > 1
	ORDER BY 2 DESC
);
COMMENT ON TABLE :name IS 'Query: TXO pubkeys that occur multiple times (should not happen)';

--! Save to csv just in case
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;
\set file :outfolder:name'_full.csv'''
COPY (SELECT time,block,txhash,pubk FROM tx JOIN txout USING (txid) JOIN reused_pubk USING (pubk) ORDER BY count DESC,block ASC) TO  :file CSV HEADER;

----! If foreign key in ring table does not have cascade, first run this:
-- ALTER TABLE ring
-- DROP CONSTRAINT ring_outid_fkey,
-- ADD CONSTRAINT ring_outid_fkey
--    FOREIGN KEY (outid)
--    REFERENCES txout(outid)
--    ON DELETE CASCADE;


--! Then drop rows
WITH mintimes AS(
	SELECT pubk,count, min(time)
	FROM reused_pubk
		JOIN txout USING(pubk)
		JOIN tx USING(txid)
		GROUP BY pubk, count
		ORDER BY min asc
), outids AS (
	SELECT outid
	FROM txout
		JOIN tx USING (txid)
		JOIN mintimes USING(pubk)
		WHERE min < time -- only use TXouts that are older than the first one
		ORDER BY pubk,time ASC
)
DELETE FROM txout
WHERE outid in (SELECT outid FROM outids); --! uses foreign key with on delete cascade in ring table!


----! Some TXs use the same pubk multiple time - for these only leave the TXO with the minimum outid
-- select time,txhash,pubk,array_agg(outid) as outids from tx natural join txout natural join reused_pubk group by 1,2,3 having count(*) > 1 order by time asc;
--         time         |                              txhash                              |                               pubk                               |                  outids
--  2016-10-23 20:50:47 | 1834c1e6d93eb8c7b02e28e8f30aafa1c65e8b56ce2dcdd8e0475b4adc2e93a2 | 944e84a00c2e47b8ab6c1ed4e7d5325449940bd7d9947c321f2f78c6f67266cc | {2547290,2547292,2547291,2547293,2547289}
--  2016-10-23 20:55:35 | 57a91b097302de0f2db0ba4a62a7e6e97abd3026e2e6deea03155c51247db462 | 88883ef499326c4344935c57f088758e1370a80ab757d45e0e09413485542f3b | {9238611,9238609,9238610,9238608}
-- (2 rows)

WITH min_outids AS(
	SELECT pubk, min(outid) as outid
	FROM txout
		JOIN reused_pubk USING (pubk)
	GROUP BY pubk
	HAVING count(outid) > 1
)
DELETE FROM txout
WHERE pubk IN (SELECT pubk FROM min_outids)
	AND outid NOT IN (SELECT outid FROM min_outids);
