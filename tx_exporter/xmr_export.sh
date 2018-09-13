start=$1

cd ../data/
mkdir $start
cd $start
rm * # beware!

../../tx_exporter/xmr2csv -b ../../../monero-data/xmr-data/lmdb -t $start --all-key-images --all-outputs --out-csv-file4 "inputs.csv"

mv xmr_report.csv outputs.csv
