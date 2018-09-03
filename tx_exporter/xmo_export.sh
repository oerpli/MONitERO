start=1546000

cd ../data/
mkdir xmo_data
cd xmo_data
rm * # beware!

../../tx_exporter/xmv2csv -b ../../../monero-data/xmo-data/lmdb -t $start --all-key-images --all-outputs --out-csv-file4 "inputs.csv"

mv xmr_report.csv outputs.csv
