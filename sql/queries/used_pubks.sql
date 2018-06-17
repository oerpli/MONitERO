\timing on

\set name spent_pubks
\set file :outfolder:name'.csv'''
COPY (SELECT pubk FROM txout natural join ring where matched = 'real' or matched ='spent') TO :file CSV HEADER DELIMITER E'\t';

COMMENT ON TABLE :name IS 'Query: '; -- PLEASE FILL OUT TO PREVENT CONFUSION

