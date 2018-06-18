-- Bring data into normalized form
\timing on
-- Create table
\echo '\n>>Creating tables'
DROP TABLE IF EXISTS tx CASCADE;
CREATE TABLE tx
(	txid SERIAL PRIMARY KEY
,	time TIMESTAMP WITHOUT TIME ZONE
,	block INTEGER NOT NULL
,	txhash VARCHAR NOT NULL
,	ringct BOOLEAN NOT NULL
,	coinbase BOOLEAN NOT NULL
-- ,	ringsize DECIMAL NOT NULL
);

DROP TABLE IF exists txin CASCADE;
CREATE TABLE txin
(	inid SERIAL PRIMARY KEY
,	txid INTEGER REFERENCES tx(txid) ON DELETE CASCADE
,	keyimg VARCHAR UNIQUE NOT NULL
);

DROP TABLE IF EXISTS txout CASCADE;
CREATE TABLE txout
(	outid SERIAL PRIMARY KEY
,	txid INTEGER REFERENCES tx(txid) ON DELETE CASCADE
,	out_index INTEGER -- number of output in tx
,	amount DECIMAL
,	pubk VARCHAR NOT NULL
);

DROP TABLE IF EXISTS ring CASCADE;
CREATE TABLE ring
(	inid INTEGER REFERENCES txin(inid) ON DELETE CASCADE 
,	outid INTEGER REFERENCES txout(outid) ON DELETE CASCADE
,	matched INPUT_TYPE NOT NULL DEFAULT 'unknown'
,	matched_merge INPUT_TYPE -- matched acc. to merge heuristic
,	matched_newest INPUT_TYPE -- matched acc. to newest input heuristic
,	primary key(inid,outid)
);

\echo '\n'
\echo '>>Normalizing data:'
\echo '>>>>TX:'
-- Get a unique id for every TX (instead of hash)
INSERT INTO tx(txhash,time,block,ringct,coinbase)
	SELECT DISTINCT txhash,time,block,tx_version = 2,true -- tx_version 2 is ringct, 1 = regular transaction
	FROM outputs; -- get TXs from output as CB transactions don't have inputs
CREATE UNIQUE INDEX tx_hash ON tx(txhash);
ANALYZE tx; --analyze to get faster queries used in next inserts

-- Newly inserted tx are assumed to be coinbase transactions (as they stem from the output table)
-- If a TX also has inputs (join with inputs table is not empty), coinbase is set to false
--! BUG(?): Some TX don't have outputs. Those are not in the database!
--! Compare:
-- select * from tx natural join txout where block = 1006680;
-- https://moneroblocks.info/search/1006680
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
CREATE INDEX index_txin_txid ON txin USING HASH (txid);
CREATE INDEX index_txin_keyimg ON txin USING HASH (keyimg);
ANALYZE txin;

\echo '\n>>>>TXout:'
-- Get a unique id for every TX output (instead of hash + idx)
INSERT INTO txout(txid,out_index,amount,pubk)
	SELECT DISTINCT txid,out_idx,amount,output_pubk
	FROM outputs o
	JOIN tx t on o.txhash = t.txhash;
CREATE INDEX index_txout_txid ON txout USING HASH (txid);
CREATE INDEX index_txout_pubk ON txout USING HASH (pubk);
CREATE INDEX index_txout_amount ON txout (amount);
ANALYZE txout;

\echo '\n>>>>Rings:'
INSERT INTO ring(inid,outid)
	SELECT DISTINCT inid,outid
	FROM inputs i
	JOIN txin t on i.key_image = t.keyimg -- get correct ring (= inid = input_id)
	JOIN txout o on i.ref_output_pubk = o.pubk;
-- dont analyze this alone because of next step
-- CREATE UNIQUE INDEX index_ring ON ring (inid, outid);
CREATE INDEX index_ring_in2 ON ring (inid);
CREATE INDEX index_ring_in ON ring USING HASH (inid);
CREATE INDEX index_ring_out ON ring USING HASH (outid);

\echo '\n>>Analyze DB:'
ANALYZE;

COMMENT ON TABLE tx IS 'All TXs (including cb) and their metadata';
COMMENT ON TABLE txout IS 'Outputs associated with TXs';
COMMENT ON TABLE txin IS 'Inputs associated with TXs';
COMMENT ON TABLE ring IS 'All outputs (outid) referenced in TX inputs (inid). A set of outputs is called a ring';