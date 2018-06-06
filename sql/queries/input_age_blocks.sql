\timing on

\set name input_age_block_old
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select floor(log(2, block_diff)) as logBlockDiff, matched, count(*) as count from ringtime where spendheight < 1000000 group by 1,2 order by 1,2 asc
);
COMMENT ON TABLE :name IS 'Age of inputs, logBlockDiff is rounded down. Before block 1.0E6';

\set name input_age_block_new
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select floor(log(2, block_diff)) as logBlockDiff, matched, count(*) as count from ringtime where spendheight > 1100000 group by 1,2 order by 1,2 asc
);
COMMENT ON TABLE :name IS 'Age of inputs, logBlockDiff is rounded down. After block 1.1E6';

\set name input_age_block
DROP TABLE IF EXISTS :name;
CREATE TABLE :name AS (
	select floor(log(2, block_diff)) as logBlockDiff, matched, count(*) as count from ringtime group by 1,2 order by 1,2 asc
);
COMMENT ON TABLE :name IS 'Age of inputs, logBlockDiff is rounded down. No block restrictions';
