\i ./paths.sql

\echo '\n>>>>Creating & exporting query tables'

--! First Define the name variable like
\set name QUERYNAME
--! Then put these 3 lines below.
--! will create a table with queryname as name and a csv file in the outfolder (defined in paths.sql) with results
-- \i ./queries/:name.sql
-- \set file :outfolder:name'.csv'''
-- COPY :name TO :file CSV HEADER;

--! now part of matching algorithm and not query (run multiple times)
-- \set name spent_sets
-- \echo '>>Query: ':name
-- \i ./queries/:name.sql
-- \set file :outfolder:name'.csv'''
-- COPY :name TO :file CSV HEADER;

\set name matching_stats
\echo '>>Query: ':name
\i ./queries/:name.sql
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;

\set name ringsizes
\echo '>>Query: ':name
\i ./queries/:name.sql
\set name ringsizes
\set file :outfolder:name'.csv'''
COPY (select row_number() over() as row,date_part('month', age(month, '2014-04-01')) +12*date_part('year', age(month, '2014-04-01')) as age, * from :name) TO :file CSV HEADER DELIMITER E'\t';
\set name ringsizes_nontrivial
\set file :outfolder:name'.csv'''
COPY (select row_number() over() as row,date_part('month', age(month, '2014-04-01')) +12*date_part('year', age(month, '2014-04-01')) as age, * from :name) TO :file CSV HEADER DELIMITER E'\t';

\set name monthly_stats
\echo '>>Query: ':name
\i ./queries/:name.sql
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;

\set name input_count
\echo '>>Query: ':name
\i ./queries/:name.sql
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;

\set name input_age
\echo '>>Query: ':name
\i ./queries/:name.sql
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;

\set name denoms
\echo '>>Query: ':name
\i ./queries/:name.sql
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;

--! Currently deprecated.
--! Updated output_merge table has all the necessary data already
-- \set name output_merging
-- \echo '>>Query: ':name
-- \i ./queries/:name.sql
-- \set file :outfolder:name'.csv'''
-- COPY :name TO :file CSV HEADER;

\set name spent_sets_time
\echo '>>Query: ':name
\i ./queries/:name.sql
\set file :outfolder:name'.csv'''
COPY :name TO :file CSV HEADER;
