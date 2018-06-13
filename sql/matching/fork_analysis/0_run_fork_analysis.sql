\timing on
-- This filename has to be either defined in the console (with \set)
-- or submitted via commmand line arg
--! psql -f 0_run_fork_analysis.sql -v currency=defs_xmv.sql

-- \set currency defs_xmv.sql

-- Define fork-height for currencies:
-- Function that returns blockheights of forks
CREATE OR REPLACE FUNCTION fork(currency text) RETURNS INTEGER AS $$
DECLARE
	height INTEGER;
BEGIN
	CASE
		WHEN lower($1) = 'xmv' THEN height := 1564966;
		WHEN lower($1) = 'xmo' THEN height := 1546000;
		-- WHEN lower($1) = 'new' THEN height := 1234;
		----! ADD ADDITIONAL CURRENCIES AS IN LINES ABOVE
	END CASE;
	RETURN height;
END ; $$
LANGUAGE plpgsql immutable;

-- Load names for currency
\i :currency
-- Process data
\i ./1_create_raw_tables.sql
\i ./2_import.sql
\i ./3_normalize.sql
\i ./4_match_other.sql
\i ./5_match_keyimg.sql

---- If only matches in main-currency are relevant, tables created in this step can be dropped again
-- \i ./6_drop_fork_tables.sql