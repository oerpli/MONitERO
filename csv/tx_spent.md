# Spent and risky transaction outputs [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1304032.svg)](https://doi.org/10.5281/zenodo.1304032)

Monero's untraceability is based on the sampling of decoy inputs for each real transaction input.
If a decoy input is a reference to an output which is known to be spent, it does not contribute to the size of the anonymity set of the real input.
To prevent the sampling of spent outputs as decoys, the blackballing tool (released together with Monero v.0.12) can be used.

## Blackball database:
In June 2018, I've compiled a list of outputs which should be avoided, which can be obtained by following the links below.
Though I would recommend using the database published by [Justin Ehrenhofer](https://twitter.com/JEhrenhofer), which is available here: 

https://monero-blackball.github.io/monero-blackball-site/

It is more complete (more recently updated and also incorporates some information from Mining Payouts, in contrast to my work, which is only based on data from the blockchain.

Still, here links to the provably spent outputs between April 2014 and June 8th 2018:

* Provably spent: [spent_outputs.csv](https://zenodo.org/record/1304033/files/spent_outputs.csv?download=1)
* (Probably) spent on a forked chain: [referenced_on_fork.csv](https://zenodo.org/record/1304033/files/referenced_on_fork.csv?download=1)
* At risk of being identified as spent: [risky_outputs.csv](https://zenodo.org/record/1304033/files/risky_outputs.csv?download=1)

The queries for these files can be found here: [../sql/queries/spent_outputs.sql](https://github.com/oerpli/MONitERO/blob/master/sql/queries/spent_outputs.sql)

The CSV files cannot be included in the repo due to their size and are therefore published on [Zenodo.org](https://zenodo.org/record/1304033).
