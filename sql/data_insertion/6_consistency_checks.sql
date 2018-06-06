-- All TXOs have a txid
\echo 'TXOs without txid'
select count(*) as no_invalid_txos from txout where txid is null;
\echo 'TXIs without txid'
select count(*) as no_invalid_txis from txin where txid is null;


\echo 'Coinbase TXs have no input'
select count(*) as no_invalid_coinbase_txs from tx natural join txin where coinbase;

\echo 'RingCT TXs should have an output of zero'
select max(amount) as highest_ringct_output from tx natural join txout where ringct and not coinbase;

\echo ''