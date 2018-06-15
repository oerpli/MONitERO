-- Definitions that are used in the processing files in this folder
-- To enable processing of an additional currency (<NAME>) do the following:
-- 0. In 0_run_fork_analysis.sql fork-fn add an additional CASE that returns the fork-height of <NAME>
-- 1. Download <NAME>-blockchain
-- 2. Export TX data of <NAME> blockchain to CSV
--	  2a. Compile TX-export against <NAME> (https://github.com/moneroexamples/transactions-export)
--	  2b. Export using the <NAME>-TX-exporter
-- 3. Put CSV files in some subfolder of the data folder, e.g. '<NAME>_data/'
-- 4. Copy this file and save as e.g. 'defs_<NAME>.sql'
-- 4. Update all definitions below (replace all occurrences of xmv in this file with <NAME>)
-- 5. Execute 0_run_fork_analysis.sql, i.e.
--!		psql -f 0_run_fork_analysis.sql -v currency=<NAME>

\set fork_folder 'xmv_data/'
\set q_curr '''(XMV)'
\set curr '''xmv'''
\set tx xmv_tx
\set txout xmv_txout
\set txin xmv_txin
\set txi xmv_txi
\set ring xmv_ring
\set inid xmv_inid
\set outid xmv_outid

\set keyimg xmv_keyimg
\set matches xmv_matches

\set inputs xmv_inputs
\set outputs xmv_outputs
