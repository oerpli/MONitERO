$count = 0
$logfile = '.\log.txt'
$mixin_removal = '.\0-mixin-removal.sql'
$spent_sets = '.\spent_sets.sql'
$update_views = '..\data_insertion\update\5_modify_tables.sql'
echo "Start" > $logfile
get-time >> $logfile

# 1. Run mixin_removal in loop until no 0-mixin TXs are found
# 2. Look for spent input_sets and mark them as spent in $spent_sets
# 3. If any spent_sets are found, mark as spent and mark other occurrences as mixin and start from 1 again
do {
    do {
        $count++
        echo $count
        psql -f $mixin_removal >> $logfile
        # echo "UPDATE 0" >> $logfile
        # echo "TEST" >> $logfile
	} until ((cat $logfile -tail 2 | select-string -pattern "UPDATE 0" -SimpleMatch))
	echo "0-mixins removed, finding spent sets:" >> $logfile
    psql -f $spent_sets >> $logfile
    # echo "UPDATE 0" >> $logfile
    # echo "TEST" >> $logfile
} until ((cat $logfile -tail 3 | select-string -pattern "UPDATE 0" -SimpleMatch))
echo $count >> $logfile
get-time >> $logfile

echo "Updating materialized views to make sure everything is fine, tidy and consistent"
psql -f $update_views >> $logfile
