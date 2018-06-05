# MONitERO
Various pgsql scripts to monitor the Monero blockchain.
Mostly useful if you plan to create a blackball database (more on that below) or calculate some metrics concerning Monero transactions and you'ld like to use (PG)SQL for that purpose.

## WTF is a blackball?
Monero transactions use other inputs to hide the real inputs spent in transactions. Over the years, [several](https://arxiv.org/abs/1704.04299) [researchers](https://www.researchgate.net/publication/319071434_A_Traceability_Analysis_of_Monero%27s_Blockchain) have found, that some transaction outputs are definitely spent and therefore can be removed from rings, reducing the anonymity set of the affected transaction. 

For this purpose the Monero community developed a tool which is distributed with [Monero as of v.0.12](https://github.com/monero-project/monero/releases/tag/v0.12.0.0).
Using this tool, one could prevent the sampling of known spent transactions as mixins for newly created transaction.

More in a [related question on StackExchange](https://monero.stackexchange.com/questions/8225/how-can-i-use-monero-blockchain-blackball-to-improve-my-privacy)

## How do I use it?
Basically there are three steps to it:
* Export the Monero blockchain data using [transactions-export](https://github.com/moneroexamples/transactions-export).
* Create a DB and run the `0_init.sql` script to import the CSV files created in step 1 into the DB
* Then run some other scripts, depending on what you want to do exactly.

If you only want a blackball database, I will provide a CSV file with transactions that are currently known to be spent <somewhere>.

## How is this project organized
It consists of several ± independent parts, organized in the following folders:

### TX_EXPORTER
Contains some binaries of [transactions-export](https://github.com/moneroexamples/transactions-export) (compiled for Ubuntu 16.04 using WSL) and a few bash scripts that use the binaries to export blockchain data.
These scripts do not work as is, as you have to provide the correct path to your Monero blockchain (the `lmdb` folder to be exact). 
Additional details are provided in the `readme.md` in the folder. 
If you don't trust me (and why should you?) you can compile these binaries yourself. A guide on how to achieve this is provided in the folder.

Usage:
```
./xmr_export.sh <StartBlock> <EndBlock>
```

This creates a folder in `./data/` that contains two `.csv` files with the transaction data exported from the raw monero blockchain, starting from block <StartBlock>, up to (not including) <EndBlock>. You should use the values 0 and 9999999, if you're not sure, what you're doing. 

### DATA
The raw blockchain data is first converted to csv files which are put in this directory.
The SQL scripts expects data at this location.
You can look at what is going on here, though I recommend to not change much. 

### SQL
Various SQL files for transforming the monero data from csv to some useful schema. The two most important ones are `paths.sql` and `0_init.sql`.
In `paths.sql` you have to provide some paths to where things are located on your PC (must be absolute paths as postgres prefers those over relative paths). If you've done this, open `0_init.sql`, where you should find a parameter that can be set to either `init` or `update`. 
The first time it should be set to `init`, this then runs all the scripts in the `data_insertion[/init]` folder (table creation etc) and inserts data.
For incremental insertions `update` should be used.
After you've done this, you can start the whole procedure, by calling `psql -f 0_init.sql`. This could take some time. 

Some notable subdirectories:

 * `queries`: contains several queries that create tables that contains some data of interest. Usually these query tables are also exported to CSV files in the `./csv/` directory. Some of these may be of interest or some people. 
 * `meta`: Queries used for DB development. List all indices or references or similar. 
 * `algorithm`: Here some methods used to find spent outputs are implemented.  

### CSV
If some scripts collect some data for later analysis, the resulting csv files should be put in this folder.

### Python
Some Python (3.6) scripts that generate plots or similar.

## Is it any good?
Yes
