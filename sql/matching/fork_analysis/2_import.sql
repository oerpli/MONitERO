\timing on
\i ../../paths.sql
-- -- Set constant part of csv path
-- \set path '''Y:/Crypto/transactions-export/build/out/'
-- -- Set foldername (should be a number in most cases)
-- \set number 150000
-- -- Don't touch things below here
\set inputfile :datapath:fork_folder'inputs.csv'''
\set outputfile :datapath:fork_folder'outputs.csv'''

-- Importing
\echo '\n'
\echo '>>Importing input table (check path if errors occur)'
\echo :inputfile
COPY :inputs from :inputfile with (FORMAT csv, HEADER);

\echo '\n'
\echo '>>Importing output table (check path if errors occur)'
\echo :outputfile
COPY :outputs from :outputfile with (FORMAT csv, HEADER);
\echo '\n'