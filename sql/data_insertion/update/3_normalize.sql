\timing on
\echo '>>Inserting data:'
\echo '>>>>TX:'
-- Get a unique id for every TX (instead of hash)
INSERT INTO tx(txhash,time,block,ringct,coinbase)
	SELECT DISTINCT txhash,time,block,tx_version = 2,true -- tx_version 2 is ringct, 1 = regular transaction
	FROM outputs; -- get TXs from output as CB transactions don't have inputs

-- see explanation in ../init/3_normalize.sql
UPDATE tx
SET coinbase = false
FROM inputs
WHERE inputs.txhash = tx.txhash;


\echo '\n>>>>TXin:'
-- Get a unique id for every TX input (ring)
INSERT INTO txin(txid,keyimg)
	SELECT DISTINCT txid,key_image
	FROM inputs i
	JOIN tx t on i.txhash = t.txhash;

\echo '\n>>>>TXout:'
-- Get a unique id for every new TX output (instead of hash + idx)
INSERT INTO txout(txid,out_index,amount,pubk)
	SELECT DISTINCT txid,out_idx,amount,output_pubk
	FROM outputs o
	JOIN tx t on o.txhash = t.txhash;

\echo '\n>>>>Rings:'
-- All these rings have a new inid but some of them have an old outid
INSERT INTO ring(inid,outid)
	SELECT DISTINCT inid,outid
	FROM inputs i
	JOIN txin t on i.key_image = t.keyimg -- get correct ring (= inid = input_id)
	JOIN txout o on i.ref_output_pubk = o.pubk;
\echo '\n>>Analyze DB:'
ANALYZE;
