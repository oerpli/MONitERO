\timing on
-- -- Set constant part of csv path
-- \set path '''Y:/Crypto/transactions-export/build/out/'
-- -- Set foldername (should be a number in most cases)
-- \set number 150000
-- -- Don't touch things below here
-- \set inputfile :path:number'/key_images_outputs.csv'''
-- \set outputfile :path:number'/xmr_report.csv'''
-- \echo :inputfile
-- \echo :outputfile


-- Importing
\echo '\n'
\echo '>>Importing input table'
COPY inputs from :inputfile with (FORMAT csv, HEADER);

\echo '\n'
\echo '>>Importing output table'
COPY outputs from :outputfile with (FORMAT csv, HEADER);
\echo '\n'