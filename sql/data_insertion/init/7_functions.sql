-- Minimum Ringsize enforced after block n:
CREATE OR REPLACE FUNCTION minRingSize(blockheight integer) RETURNS INTEGER AS $$
DECLARE
	minRingsize INTEGER;
BEGIN
		-- Add additional values at top, as "> N" cases have to be sorted by N desc to ensure correctness
		-- as PGSQL always evaluates the conditions until one is fulfilled (no break needed)
	CASE
		-- WHEN $1 >= 2000000 THEN minRingsize := 123;  -- EXAMPLE
		WHEN $1 >= 1546000 THEN minRingsize := 7;
		WHEN $1 >= 1400000 THEN minRingsize := 5;
		WHEN $1 >= 1009827 THEN minRingsize := 3;
		ELSE minRingsize := 1;
	END CASE;
	RETURN minRingsize;
END ; $$
LANGUAGE plpgsql immutable;


-- Minimum Ringsize enforced after block n:
CREATE OR REPLACE FUNCTION ringBrackets(ringsize bigint) RETURNS INTEGER AS $$
DECLARE
	bracket INTEGER;
BEGIN
	CASE
		WHEN $1 >= 10 THEN bracket := 10; -- everything >= 10 => 10
		ELSE bracket := $1; -- => else return ringsize
	END CASE;
	RETURN bracket;
END ; $$
LANGUAGE plpgsql immutable;


-- MAX for intarrays
CREATE OR REPLACE FUNCTION array_max(anyarray)
	RETURNS anyelement LANGUAGE SQL AS $$
	SELECT max(x) FROM unnest($1) as x;
	$$;
	
CREATE OR REPLACE FUNCTION txi(input_id INTEGER) 
RETURNS TABLE(
	txid INTEGER,
	t timestamp without time zone,
	block integer,
	txhash varchar
) AS $$
	BEGIN
		RETURN QUERY
			SELECT tx.txid,tx.time,tx.block,tx.txhash
			FROM tx natural join txin
			WHERE inid = input_id;
	END; $$
LANGUAGE plpgsql immutable;

CREATE OR REPLACE FUNCTION txi(key_img varchar) 
RETURNS TABLE(
	txid INTEGER,
	t timestamp without time zone,
	block integer,
	txhash varchar
) AS $$
	BEGIN
		RETURN QUERY
			SELECT tx.txid,tx.time,tx.block,tx.txhash
			FROM tx natural join txin
			WHERE keyimg = key_img;
	END; $$
LANGUAGE plpgsql immutable;



CREATE OR REPLACE FUNCTION txo(output_id INTEGER) 
RETURNS TABLE(
	txid INTEGER,
	t timestamp without time zone,
	block integer,
	txhash varchar
) AS $$
	BEGIN
		RETURN QUERY
			SELECT tx.txid,tx.time,tx.block,tx.txhash
			FROM tx natural join txout
			WHERE outid = output_id;
	END; $$
LANGUAGE plpgsql immutable;

CREATE OR REPLACE FUNCTION txo(pub_key varchar) 
RETURNS TABLE(
	txid INTEGER,
	t timestamp without time zone,
	block integer,
	txhash varchar
) AS $$
	BEGIN
		RETURN QUERY
			SELECT tx.txid,tx.time,tx.block,tx.txhash
			FROM tx natural join txout
			WHERE pubk = pub_key;
	END; $$
LANGUAGE plpgsql immutable;

CREATE OR REPLACE FUNCTION t(tx_id INTEGER) 
RETURNS TABLE(
	txid INTEGER,
	t timestamp without time zone,
	block integer,
	txhash varchar
) AS $$
	BEGIN
		RETURN QUERY
			SELECT tx.txid,tx.time,tx.block,tx.txhash
			FROM tx 
			WHERE tx.txid = tx_id;
	END; $$
LANGUAGE plpgsql immutable;
