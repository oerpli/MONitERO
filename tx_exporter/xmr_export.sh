start=$1
to=$2
count=$((start - to))

cd ../data/
mkdir $start-$to
cd $start-$to
rm * # beware!

../../xmr-exporter/xmr2csv -b ../../../../xmr-data/lmdb -t $start -n $count --all-key-images --all-outputs --out-csv-file4 "inputs.csv"

mv xmr_report.csv outputs.csv

