-- Bring data into normalized form
-- Create table
\echo '\n>>Creating tables'
DROP TABLE IF EXISTS :tx CASCADE;
CREATE TABLE :tx
(	txid SERIAL PRIMARY KEY
,	time TIMESTAMP WITHOUT TIME ZONE
,	block INTEGER NOT NULL
,	txhash VARCHAR UNIQUE NOT NULL
,	ringct BOOLEAN NOT NULL
,	coinbase BOOLEAN NOT NULL
-- ,	ringsize DECIMAL NOT NULL
);

DROP TABLE IF exists :txin CASCADE;
CREATE TABLE :txin
(	:inid SERIAL PRIMARY KEY
,	txid INTEGER REFERENCES :tx(txid) ON DELETE CASCADE
,	keyimg VARCHAR
);

DROP TABLE IF EXISTS :txout CASCADE;
CREATE TABLE :txout
(	:outid SERIAL PRIMARY KEY
,	txid INTEGER REFERENCES :tx(txid) ON DELETE CASCADE
,	out_index INTEGER -- number of output in tx
,	amount DECIMAL
,	pubk VARCHAR
);

DROP TABLE IF EXISTS :ring CASCADE;
CREATE TABLE :ring
(	:inid INTEGER REFERENCES :txin(:inid) ON DELETE CASCADE 
,	:outid INTEGER REFERENCES :txout(:outid) ON DELETE CASCADE
,	outid INTEGER REFERENCES txout(outid) ON DELETE CASCADE
,	legacy BOOLEAN NOT NULL -- true if from pre-fork chain, false if output from post-fork chain
,	matched INPUT_TYPE NOT NULL DEFAULT 'unknown' -- 
-- ,	matched_merge INPUT_TYPE -- matched acc. to merge heuristic
-- ,	matched_newest INPUT_TYPE -- matched acc. to newest input heuristic
);

\echo '\n'
\echo '>>Normalizing data:'
\echo '>>>>TX:'
-- Get a unique id for every TX (instead of hash)
INSERT INTO :tx(txhash,time,block,ringct,coinbase)
	SELECT DISTINCT txhash,time,block,tx_version = 2 or tx_version = 3,true -- tx_version 2 is ringct, 1 = regular transaction
	FROM :outputs; -- get TXs from output as CB transactions don't have inputs
-- CREATE UNIQUE INDEX xmv_tx_hash ON xmv_tx(txhash);
ANALYZE :tx; --analyze to get faster queries used in next inserts

-- Newly inserted tx are assumed to be coinbase transactions (as they stem from the output table)
-- If a TX also has inputs (join with inputs table is not empty), coinbase is set to false
--! BUG(?): Some TX don't have outputs. Those are not in the database!
--! Compare:
-- select * from tx natural join txout where block = 1006680;
-- https://moneroblocks.info/search/1006680
--! This may not be valid for XMV!!
UPDATE :tx 
SET coinbase = false
FROM :inputs
WHERE :inputs.txhash = :tx.txhash;

\echo '\n>>>>TXin:'
-- Get a unique id for every TX input (ring)
INSERT INTO :txin(txid,keyimg)
	SELECT DISTINCT txid,key_image
	FROM :inputs i
	JOIN :tx t using (txhash);
-- CREATE INDEX xmv_index_txin_txid ON xmv_txin USING HASH (txid);
-- CREATE INDEX xmv_index_txin_keyimg ON xmv_txin USING HASH (keyimg);
ANALYZE :txin;

\echo '\n>>>>TXout:'
-- Get a unique id for every TX output (instead of hash + idx)
INSERT INTO :txout(txid,out_index,amount,pubk)
	SELECT DISTINCT txid,out_idx,amount,output_pubk
	FROM :outputs o
	JOIN :tx t using(txhash);
-- CREATE INDEX xmv_index_txout_txid ON xmv_txout USING HASH (txid);
-- CREATE INDEX xmv_index_txout_pubk ON xmv_txout USING HASH (pubk);
-- CREATE INDEX xmv_index_txout_amount ON xmv_txout (amount);
ANALYZE :txout;

\echo '\n>>>>Rings:'
INSERT INTO :ring(:inid,:outid, legacy)
	SELECT DISTINCT :inid,:outid, false -- legacy = false for outputs that are found in xmv_txout
	FROM :inputs i
	JOIN :txin t on i.key_image = t.keyimg -- get correct ring (= inid = input_id)
	JOIN :txout o on i.ref_output_pubk = o.pubk;

INSERT INTO :ring(:inid,outid, legacy)
	SELECT DISTINCT :inid,outid, true -- legacy = false for outputs that are found in xmv_txout
	FROM :inputs i
	JOIN :txin t on i.key_image = t.keyimg -- get correct ring (= inid = input_id)
	JOIN txout o on i.ref_output_pubk = o.pubk;
-- CREATE UNIQUE INDEX xmv_index_ring ON xmv_ring (inidv, outidv, outid);

COMMENT ON TABLE :tx IS    :q_curr: All TXs (including cb) and their metadata'; --'
COMMENT ON TABLE :txout IS :q_curr: Outputs associated with TXs'; --'
COMMENT ON TABLE :txin IS  :q_curr: Inputs associated with TXs'; --'
COMMENT ON TABLE :ring IS  :q_curr: All outputs (outid) referenced in TX inputs (inid). A set of outputs is called a ring'; --'