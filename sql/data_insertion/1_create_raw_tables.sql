DROP TABLE IF exists inputs;
CREATE TABLE inputs (
	time TIMESTAMP WITHOUT TIME ZONE,
	block DECIMAL NOT NULL,
	txhash VARCHAR NOT NULL,
	key_image VARCHAR NOT NULL,
	ring_size DECIMAL NOT NULL,
	absolute_key_offset DECIMAL NOT NULL, -- origin block -1 (or +1)
	ref_output_pubk VARCHAR NOT NULL, --referenced_output_pub_key
	ref_txhash VARCHAR NOT NULL, --referenced_txhash
	ref_out_index DECIMAL NOT NULL --reference_out_index_in_the_ref_tx
);

DROP TABLE IF exists outputs;
CREATE TABLE outputs (
	time TIMESTAMP WITHOUT TIME ZONE,
	block DECIMAL NOT NULL,
	txhash VARCHAR NOT NULL,
	tx_public_key VARCHAR NOT NULL,
	tx_version INTEGER NOT NULL,
	payment_id VARCHAR NOT NULL, --???
	out_idx DECIMAL NOT NULL,
	amount DECIMAL NOT NULL,
	output_pubk VARCHAR NOT NULL,
	output_key_img VARCHAR NOT NULL, --???
	output_spend BOOLEAN NOT NULL --???
);

COMMENT ON TABLE inputs IS 'Inputs (from csv file) exported by transaction-exporter';
COMMENT ON TABLE outputs IS 'Outputs (from csv file) exported by transaction-exporter';