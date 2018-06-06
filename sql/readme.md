# SQL Data processing
PostgreSQL data transformation from csv-export of XMR (/XMV) blockchain to usable schema.

## Basic usage

First, initialize a postgres database (10.3 or higher) by doing the following:

* Clear postgres data folder (location of which can be found in pgconfig)
* Run `dbinit` and `dbcreate`. Note: Some of the linking scripts assume that no username/password is needed when `psql` is called. If this is not possible in your env, adapt those scripts accordingly.

### 1. Setting up paths (`paths.sql`)
Then, in `paths.sql` the absolute paths to the data directory should be set (which is `../data/` from the location of this file). 

Foldername is the folder that contains `inputs/outputs.csv` files which should be added to the DB (usually the folders are named according to the blocks which the csv files in them contain).

In `:outfolder` the results from the queries are written as CSV files. 


### 2. Insert data (`0_init.sql, 0_update.sql`)

For reading data, there are two scenarios:

* Initializing DB with complete dataset starting from block 0
* Adding data from block n to m, where n-1 is the current max height stored in the DB.

In the first case, `0_init.sql` should be run, in the latter `0_update.sql` should be called. The only difference between the two files is the setting of the `:init_update` variable

### 3. Matching outputs to transaction (`./matching/*`)

Several methods to match outputs to the transactions where they are used can be found in this folder. 

* 0 Mixin Removal:
    * If an input (ring) has only one output with undetermined status, the output is set to `real` for the input in question. Every other reference to the output in question is marked as `mixin`. Iterated until convergence
    * Look for identical rings of size n that appear n times. All members have to be spent. Set to `spent` and all other references to `mixin`
    * Iterate both steps until convergence
* Fork Analysis: If there is a hardfork of Monero, some key images may occur on both blockchains (fork & XMR). This can be exploited to identify the real output being spent in the transaction. Use as follows:
    * Export forked blockchains starting from fork block to some folder, e.g. `<CURRENCY>_data` (there are scripts for thsi in the `tx_exporter` folder)
    * If there is no definition file for the <CURRENCY>, copy the `defs_xmo.sql` file and rename it to `defs_<CURRENCY>.sql` and update the variables as specified in the comments there
    * Add the fork height of <CURRENCY> in the function definition in `0_run_fork_analysis.sql`
    * Save all files and run `psql -f 0_run_fork_analysis.sql -v currency=defs_<CURRENCY>.sql`
* Output Merging:
    * If a transaction references two different outputs of previous transactions in two rings, it can often be assumed, that these two outputs are the real inputs of that transaction.
* ~~CSV Import~~: [Deprecated]

### 4. Some queries (`q_run_all.sql`)

Generates tables or views for some analysis queries and outputs them as CSV in the folder specified above.
As in some cases heuristics should be applied before running the queries, this is a seperate file.

## Folders and their content

Outline of the organization of the bits and pieces in this folder:

* `data_insertion`: Takes raw data from csv-export and either appends to existing db (if csv-export contains data starting from some block > 0) or creates a new one.
* `queries`: Queries that are mostly called in `q_run_all.sql` - creation of views/tables of some properties of interest. In this folder is a template that should be used to create additional queries.
* `matching/zero_mixin_removal`: To link monero outputs to the tx where it is used, several heuristics are applied. This folder contains SQL implementations of these algorithms, look in the folder on how to use them 
* `matching/fork_analysis`: Reads data from the MoneroV blockchain and tries to use information from there to improve the XMR-linking. 
* `matching/output_merging`: Link TXs that merge outputs from previous transaction (nondeterministic, => seperate link column)
* `matching/csv_import`: If the linking is done via external methods, here are scripts that import the csv-output to the DB. [Deprecated]
* `meta`: Queries that output relations and indexes on the DB. Can be used to check how the different tables interact with each other. 
