-- Bring data into normalized form
-- Create table
\echo '\n>>Creating tables'
DROP TABLE IF EXISTS :tx CASCADE;
CREATE TABLE :tx
(	txid integer DEFAULT nextval('txout_outid_seq') NOT NULL
,	time TIMESTAMP WITHOUT TIME ZONE
,	block INTEGER NOT NULL
,	txhash VARCHAR UNIQUE NOT NULL
,	ringct BOOLEAN NOT NULL
,	coinbase BOOLEAN NOT NULL
-- ,	ringsize DECIMAL NOT NULL
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
INSERT INTO txin(:txid,keyimg)
	SELECT DISTINCT :txid,key_image
	FROM :inputs i
	JOIN :tx t using (txhash)
ON CONFLICT (pubk) DO UPDATE SET :txid = EXCLUDED.:txid;

\echo '\n>>>>TXout:'
-- Get a unique id for every TX output (instead of hash + idx)
INSERT INTO txout(txid,out_index,amount,pubk)
	SELECT DISTINCT txid,out_idx,amount,output_pubk
	FROM :outputs o
	JOIN :tx t using(txhash);

\echo '\n>>>>Rings:'
INSERT INTO :ring(inid,outid)
	SELECT DISTINCT inid,outid
	FROM :inputs i
	JOIN txin t on i.key_image = t.keyimg -- get correct ring (= inid = input_id)
	JOIN txout o on i.ref_output_pubk = o.pubk
	WHERE t.:txid is not null -- only insert rings that belong to :fork
;

INSERT INTO :ring(:inid,outid, legacy)
	SELECT DISTINCT :inid,outid, true -- legacy = false for outputs that are found in xmv_txout
	FROM :inputs i
	JOIN :txin t on i.key_image = t.keyimg -- get correct ring (= inid = input_id)
	JOIN txout o on i.ref_output_pubk = o.pubk;
-- CREATE UNIQUE INDEX xmv_index_ring ON xmv_ring (inidv, outidv, outid);



DROP MATERIALIZED VIEW IF EXISTS :txi;
CREATE MATERIALIZED VIEW :txi AS
SELECT :inid,txid,keyimg, ringsize, effective_ringsize
FROM :txin natural join
(	SELECT :inid
	,	count(*) as ringsize
	,	count(case
				when matched <> 'mixin' then 1 -- This should be somewhat faster
				-- when matched = 'unknown' then 1
				-- when matched = 'real' then 1
				-- when matched = 'spent' then 1
			end) as effective_ringsize
	FROM :ring
	GROUP BY :inid
	ORDER BY :inid asc
) as a;


COMMENT ON TABLE :tx IS    :q_curr: All TXs (including cb) and their metadata'; --'
COMMENT ON TABLE :txout IS :q_curr: Outputs associated with TXs'; --'
COMMENT ON TABLE :txin IS  :q_curr: Inputs associated with TXs'; --'
COMMENT ON TABLE :ring IS  :q_curr: All outputs (outid) referenced in TX inputs (inid). A set of outputs is called a ring'; --'
COMMENT ON MATERIALIZED VIEW :txi IS :q_curr: Inputs and their (effective) ringsizes'; --'