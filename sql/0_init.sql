\timing on
-- get folderpaths defined in paths.sql
\i ./paths.sql
\set init_update init


\set inputfile :datapath:foldername'/inputs.csv'''
\set outputfile :datapath:foldername'/outputs.csv'''

\echo '>>Importing modules:'
DROP EXTENSION IF EXISTS intarray;
DROP EXTENSION IF EXISTS tablefunc;
CREATE EXTENSION intarray;
CREATE EXTENSION tablefunc;

\echo '>>Reading from files:'
\echo :inputfile
\echo :outputfile


--TODO Maybe remove constraints before inserts and add them again afterwards in the future
\i ./data_insertion/:init_update/0_typedefs.sql
\i ./data_insertion/1_create_raw_tables.sql
\i ./data_insertion/2_import.sql
\i ./data_insertion/:init_update/3_normalize.sql
-- This step is needed at this point
\echo '>>Cleaning: Reused Pubkeys'
\i ./data_insertion/4_drop_reused_pubk.sql
-- Then stuff follows
\i ./data_insertion/:init_update/5_modify_tables.sql -- update version only runs REFRESH MATERIALIZED VIEW (may be unnecessary due to refresh on commit?)
\i ./data_insertion/6_consistency_checks.sql
\i ./data_insertion/:init_update/7_functions.sql


\i ./q_run_all.sql