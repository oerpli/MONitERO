[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1303433.svg)](https://doi.org/10.5281/zenodo.1303433)



# MONitERO
Various pgsql scripts to monitor the Monero blockchain.
Mostly useful if you plan to create a blackball database (more on that below) or calculate some metrics concerning Monero transactions and you would like to use (PG)SQL for that purpose.

If you only want a blackball database, I will provide a CSV file with transactions that are currently known to be spent <somewhere> (currently looking for a place to reliably host approx. 1-3GB uncompressable text files).

## WTF is a blackball?
Monero transactions use other inputs to hide the real inputs spent in transactions. Over the years, [several](https://arxiv.org/abs/1704.04299) [researchers](https://www.researchgate.net/publication/319071434_A_Traceability_Analysis_of_Monero%27s_Blockchain) have found, that some transaction outputs are definitely spent and therefore can be removed from rings, reducing the anonymity set of the affected transaction. 

For this purpose the Monero community developed a tool which is distributed with [Monero as of v.0.12](https://github.com/monero-project/monero/releases/tag/v0.12.0.0).
Using this tool, one could prevent the sampling of known spent transactions as mixins for newly created transaction.

More in a [related question on StackExchange](https://monero.stackexchange.com/questions/8225/how-can-i-use-monero-blockchain-blackball-to-improve-my-privacy)

## How do I use it?
Basically there are three steps to it:
* Export the Monero blockchain data using [transactions-export](https://github.com/moneroexamples/transactions-export).
* Create a DB and run the SQL scripts to import the CSV files created in step 1 and identify inputs. More on this below

### Exporting the blockchain to CSV
For this step, you first need to sync the Monero blockchain, then head to the `tx_exporter` folder where you'll find a few binaries and a few bash scripts. 
The binaries are compiled for Ubuntu 16.04, if you have another OS or don't trust me compile them yourself (see further below).
Also note, that the scripts do not work as is, as you have to provide the correct path to your Monero (or MoneroV/Monero Original) blockchain (their `lmdb` folder to be exact). 

After you've done this, you call the export script as follows:
Usage:
```
# Insert correct values for <*> here:
./xmr_export.sh <StartBlock> <EndBlock>
# E.g.
./xmr_export.sh 0 9999999
```

This creates a folder in `./data/` that contains two `.csv` files with the transaction data exported from the raw Monero blockchain, starting from block <StartBlock>, up to (not including) <EndBlock>. You should use the values 0 and 9999999, if you're not sure, what you're doing. 

If you would like to apply cross-chain-analysis, you also need to sync the XMO and XMV (and/or other forks) and provide the correct paths in the respective export scripts.
These do not take arguments, as it is assumed, that they contain way less data and are therefore always exported from start (fork height) to the most recent block. 


### Importing the blockchain export
In `paths.sql` you have to provide some paths to where things are located on your PC (must be absolute paths as postgres prefers those over relative paths).

After you've done this, you can start the whole procedure, by calling `psql -f 0_init.sql`. This could take some time, as it calls various scripts in the `data_insertion[/init]` folder (table creation etc) and inserts data and normalizes it.

If you already have a database in place which you would like to extend with a new export (e.g. you have block 0-1000 in the DB and now your new export, covering blocks 1000-2000 is in the `./data/1000-2000`) set the variables in `paths.sql` accordingly and run `0_update.sql` instead of `0_init.sql`.

After this step the database is more or less a copy of the blockchain, which you usually want to analyse now.
For this 

### Analyse the data in the DB
Assuming that you want to find out which transaction outputs you should avoid as mixins, you have to determine which outputs are spent where. 
For this purpose, several methods exist, see e.g. [Möser et al.,2017](https://arxiv.org/abs/1704.04299) and [Kumar et al.,2017](http://www.comp.nus.edu.sg/~shruti90/papers/monero-analysis.pdf).
Some of them and a few additional ones are implemented here.

Use them as follows:
#### Zero Mixin Removal & Intersection Removal:
Head to `./sql/matching/zero_mixin_removal` and run `./Matching-Algorithm.ps1`. This is a powershell script, if someone want to translate it to a bash/python script or implement it in SQL, feel free to open a pull request.
What it does is the following:
* 0 Mixin Removal:  
	* Find input rings with size 1 (only one output), set output as real output and remove it from every other input ring (actually set its status to `'mixin'` instead of removing it)
	* Repeat until convergence
* Intersection Removal:
	* Find identical input rings of size n that exist n times. All referenced outputs have to be spent, remove them from other rings (set as mixin yadayada).
	* Go back to first step
* Repeat both steps until convergence. This is done in a very primitive way: The powershell script redirects the outputs from `psql -f <File>` to `log.txt` and reads the last few lines after each step to check for `UPDATE 0` or similar. I wasn't aiming for a Turing award with this (though I would still accept it, if you're offering). 

#### Cross Chain Analysis
If you want to  analyse MoneroV and Monero Original, scripts are already provided.
If you are interested in other forks, the scripts can be easily adapted.

For this purpose you should have the `<fork>_data` folders in `./data`, each with the inputs/outputs CSV file, where `<fork>` is the abbreviation of the fork, e.g. `xmv` or `xmo`.

Then head to the `./sql/matching/fork_analysis` folder and look if the file `defs_<fork>.sql` already exists. If not, copy one of the existing defs-files and follow the guidelines in the first few lines on how to adapt it for your fork of choice. 

Open `0_run_fork_analysis.sql` and add the fork-height of <fork> to the function, something like `WHEN lower($1) = 'xmo' THEN height := 1546000;`.

Then run the script. For this, you have to provide the correct `defs_<fork>.sql` file as an argument, i.e.:

```
# For <fork>
psql -f 0_run_fork_analysis.sql -v currency=defs_<fork>.sql
# Concrete example:
psql -f 0_run_fork_analysis.sql -v currency=defs_xmv.sql
```

Wait some time until it's done. After it is finished, you could run Zero Mixin Removal algorithm again and see if some new inputs can be deduced. 

#### Output Merging
I would not recommend using this heuristic. If you want to use it, figure out how to do it.
(It will lead to false positives most likely)


### Other things
You can run any queries that interest you on the database. I won't even judge your rusty SQL skills.
In the `./sql/queries` folder a few queries can be found which I found interesting at some point. You can look there for some inspiration.   

## How is this project organized
It consists of several ± independent parts, organized in the following folders:

### TX_EXPORTER
Contains some binaries of [transactions-export](https://github.com/moneroexamples/transactions-export) (compiled for Ubuntu 16.04 using WSL) and a few bash scripts that use the binaries to export blockchain data.
Additional details are provided in the `readme.md` in the folder. 
If you don't trust me (and why should you?) you can compile these binaries yourself. A guide on how to achieve this is provided in the folder.

### DATA
The raw blockchain data is first converted to csv files which are put in this directory.
The SQL scripts expects data at this location.
You can look at what is going on here, though I recommend to not change much. 

### SQL
Various SQL files for transforming the monero data from csv to some useful schema. The two most important ones are `paths.sql` and `0_init.sql`.

Some subdirectories of interest:

 * `queries`: contains several queries that create tables that contains some data of interest. Usually these query tables are also exported to CSV files in the `./csv/` directory. Some of these may be of interest or some people. 
 * `meta`: Queries used for DB development. List all indices or references or similar. 
 * `algorithm`: Here some methods used to find spent outputs are implemented.  

### CSV
If some scripts collect some data for later analysis, the resulting csv files will be put in this folder.
Contains various files with statistics for various things of interest. 

### Python
Some Python (3.6) scripts that generate plots or similar.
These are mostly not in the repo right now as I've changed my plot-generation-pipeline. 

## Is it any good?
Yes

## I have questions/concerns/other
You can contact me or open an issue. If you find some bug/oversight before my thesis is finished you will not only help Science™, but you may even get a mention in my acknowledgements!
