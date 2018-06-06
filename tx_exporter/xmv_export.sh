start=1564965
to=$2
count=$((start - to))

cd ../data/
mkdir xmv_data
cd xmv_data
rm * # beware!

../../xmr-exporter/xmv2csv -b ../../../../monero-data/xmv-data/lmdb -t $start --all-key-images --all-outputs --out-csv-file4 "inputs.csv"

mv xmr_report.csv outputs.csv

