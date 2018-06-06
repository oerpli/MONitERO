# xmr-exporter
Exporters for various Monero-based blockchains. If you need to compile them yourself instructions can be found here: [moneroexamples/transactions-exporter project](https://github.com/moneroexamples/transactions-export/).
Usually, the TX-exporter has to be compiled using the current version of the [monero-wallet](https://github.com/monero-project/monero). 

In this repo, the following two binaries, compiled for and with WSL (Ubuntu 16.04 LTS I think) are provided:

* `xmr2csv`: Compiled with Monero  [v0.12.0.0 (Lithium Luna)](https://github.com/monero-project/monero/releases/tag/v0.12.0.0)
* `xmv2csv`: Compiled with MoneroV [d3cd9144a1](https://github.com/monerov/monerov/tree/d3cd9144a1b824aeeb4e2334cf086c962b83f26e)

The first can be used for the XMR (Monero) and XMO/XMC (Monero Original/Classic) blockchains, the second for the XMV (MoneroV) blockchain. 

The following bash scripts are provided:

* `xmr_export <START BLOCK> <END BLOCK>`: Export blocks from <START BLOCK> (inclusive) up to <END BLOCK> (exclusive) from the XMR blockchain.  
* `xmo_export`: Export the XMO blockchain from its fork date (1546000) up to the most recent block. 
* `xmv_export`: Export the XMV blockchain from its fork date (1564965) up to the most recent block. 

Set the path to the blockchain lmdb folders in each of these scripts to whatever you use.
For XMO/XMV it scripts will create a folder with the currency name in `../data/`, for XMR it will create a folder called `<START BLOCK>-<END BLOCK>`.
Assuming you have a folder with data from block 0 to 1000, thus named `0-1000` and you want to export a CSV file with the data of the next 1000 blocks, you should call `./xmr_export 1000 2000`.

In every case two CSV files are created, `inputs.csv` and `outputs.csv`, with content fitting their respective name. 