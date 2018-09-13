import db_conn as db
import sys


# TEMPLATE FOR COPYING
#"select count(*) from tx natural join txout where time < '{}'".format(cutoff_date)
#"select count(*) from tx natural join txout where block between {} and {}".format(omin_xmr,omax_xmr)
#"select count(*) from tx natural join txout where block between {} and {}".format(vmin_xmr,vmax_xmr)
#"select count(*) from xmo_tx natural join xmo_txout where time < '{}'".format(cutoff_date)
#"select count(*) from xmv_tx natural join xmv_txout where time < '{}'".format(cutoff_date)


def getValue(q):
    return db.query(q)[0][0]


def queryTemplate(x):
    (name, query) = x
    result = db.query(query)
    macro = r"\def\{}{{{}\xspace}}".format(name,result[0][0])
    print(macro, flush=True)
    print("{} = {}".format(name,result[0][0]), flush=True, file=sys.stderr)
    return macro


def queryList():
    queryGroups = []
    # To compare activities of forks and main chain, two subsets of the dataset are also generated.
    omin_xmr = 1546600
    vmin_xmr = 1564966
    cutoff_date = "2018-09-01"

    omax_xmr = getValue("select max(block) from tx where time < '{}'".format(cutoff_date))
    vmax_xmr = getValue("select max(block) from tx where time < '{}'".format(cutoff_date))
    # For this purpose the block height that is closest to the last block on each chain before the cutoff date is chosen
    # Deprecated, just take last block before cutoff
    # omax_xmr = getValue("select block from tx order by (time - (select max(block) from xmo_tx where time < '2018-09-01')) asc limit 1")
    # vmax_xmr = getValue("select block from tx order by (time - (select max(block) from xmv_tx where time < '2018-09-01')) asc limit 1")

    name = "Blockchain meta data"
    queries = []
    queries += [("XMRDATEF","select time::date from tx where block = 1")]
    queries += [("XMODATEF","select min(time)::date from xmo_tx")]
    queries += [("XMVDATEF","select min(time)::date from xmv_tx")]
    queries += [("XMRDATEL","select max(time)::date from tx where time < '2018-09-01' ")]
    queries += [("XMODATEL","select max(time)::date from xmo_tx where time < '2018-09-01' ")]
    queries += [("XMVDATEL","select max(time)::date from xmv_tx where time < '2018-09-01' ")]
    queries += [("XMOFORK","select {}".format(omin_xmr-1))]
    queries += [("XMVFORK","select {}".format(vmin_xmr-1))]
    queries += [("XMRFIRST","select 1")]
    queries += [("XMOFIRST","select {}".format(omin_xmr))]
    queries += [("XMVFIRST","select {}".format(vmin_xmr))]
    queryGroups.append((name,queries.copy()))

    name = "Height at analysis cutoff"
    queries = []
    queries += [("XMRHEIGHT","select max(block) from tx where time < '{}'".format(cutoff_date))]
    queries += [("XMRHEIGHTo","select {}".format(vmax_xmr))]
    queries += [("XMRHEIGHTv","select {}".format(omax_xmr))]
    queries += [("XMOHEIGHT","select max(block) from xmo_tx where time < '{}'".format(cutoff_date))]
    queries += [("XMVHEIGHT","select max(block) from xmv_tx where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Last block timestamp before cutoff date"
    queries = []
    queries += [("XMRTIMESTAMP","select max(time) from tx where time < '{}'".format(cutoff_date))]
    queries += [("XMOTIMESTAMP","select max(time) from xmo_tx where time < '{}'".format(cutoff_date))]
    queries += [("XMVTIMESTAMP","select max(time) from xmv_tx where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of TXs"
    queries = []
    queries += [("XMRTX", "select count(*) from tx where time < '{}'".format(cutoff_date))]
    queries += [("XMRTXo","select count(*) from tx where block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRTXv","select count(*) from tx where block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOTX", "select count(*) from xmo_tx where time < '{}'".format(cutoff_date))]
    queries += [("XMVTX", "select count(*) from xmv_tx where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of Coinbase TXs"
    queries = []
    queries += [("XMRCB", "select count(*) from tx where coinbase and time < '{}'".format(cutoff_date))]
    queries += [("XMRCBo","select count(*) from tx where coinbase and block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRCBv","select count(*) from tx where coinbase and block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOCB", "select count(*) from xmo_tx where coinbase and time < '{}'".format(cutoff_date))]
    queries += [("XMVCB", "select count(*) from xmv_tx where coinbase and time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of Outputs"
    queries = []
    queries += [("XMRTXOUT","select count(*) from tx natural join txout where time < '{}'".format(cutoff_date))]
    queries += [("XMRTXOUTo","select count(*) from tx natural join txout where block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRTXOUTv","select count(*) from tx natural join txout where block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOTXOUT","select count(*) from xmo_tx natural join xmo_txout where time < '{}'".format(cutoff_date))]
    queries += [("XMVTXOUT","select count(*) from xmv_tx natural join xmv_txout where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of Inputs (Rings)"
    queries = []
    queries += [("XMRR", "select count(*) from tx natural join txin where time < '{}'".format(cutoff_date))]
    queries += [("XMRRo","select count(*) from tx natural join txin where block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRRv","select count(*) from tx natural join txin where block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOR", "select count(*) from xmo_tx natural join xmo_txin where time < '{}'".format(cutoff_date))]
    queries += [("XMVR", "select count(*) from xmv_tx natural join xmv_txin where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of nontrivial rings"
    queries = []
    queries += [("XMRRNT", "select count(*) from tx natural join txi where ringsize >1 and time < '{}'".format(cutoff_date))]
    queries += [("XMRRNTo","select count(*) from tx natural join txi where ringsize >1 and block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRRNTv","select count(*) from tx natural join txi where ringsize >1 and block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMORNT", "select count(*) from xmo_tx natural join xmo_txi where ringsize >1 and time < '{}'".format(cutoff_date))]
    queries += [("XMVRNT", "select count(*) from xmv_tx natural join xmv_txi where ringsize >1 and time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of traced nontrivial rings"
    queries = []
    queries += [("XMRRNTL","select count(*) from tx natural join txi where ringsize>1 and effective_ringsize=1 and time < '{}'".format(cutoff_date))]
    queries += [("XMRRNTLo","select count(*) from tx natural join txi where ringsize>1 and effective_ringsize=1 and block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRRNTLv","select count(*) from tx natural join txi where ringsize>1 and effective_ringsize=1 and block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMORNTL","select count(*) from xmo_tx natural join xmo_txi where ringsize>1 and effective_ringsize=1 and time < '{}'".format(cutoff_date))]
    queries += [("XMVRNTL","select count(*) from xmv_tx natural join xmv_txi where ringsize>1 and effective_ringsize=1 and time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of ring members"
    queries = []
    queries += [("XMRRM","select count(*) from tx natural join txin natural join ring where time < '{}'".format(cutoff_date))]
    queries += [("XMRRMo","select count(*) from tx natural join txin natural join ring where block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRRMv","select count(*) from tx natural join txin natural join ring where block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMORM","select count(*) from xmo_tx natural join xmo_txin natural join xmo_ring where time < '{}'".format(cutoff_date))]
    queries += [("XMVRM","select count(*) from xmv_tx natural join xmv_txin natural join xmv_ring where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of identified mixins"
    queries = []
    queries += [("XMRIM","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and time < '{}'".format(cutoff_date))]
    queries += [("XMRIMo","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRIMv","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOIM","select count(*) from xmo_tx join xmo_txi using(txid) join xmo_ring using(xmo_inid) where matched = 'mixin' and time < '{}'".format(cutoff_date))]
    queries += [("XMVIM","select count(*) from xmv_tx join xmv_txi using(txid) join xmv_ring using(xmv_inid) where matched = 'mixin' and time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of identified reals"
    queries = []
    queries += [("XMRIR","select count(*) from tx join txin using(txid) join ring using(inid) where matched = 'real' and time < '{}'".format(cutoff_date))]
    queries += [("XMRIRo","select count(*) from tx join txin using(txid) join ring using(inid) where matched = 'real' and block between {} and {}".format(omin_xmr,omax_xmr))]
    queries += [("XMRIRv","select count(*) from tx join txin using(txid) join ring using(inid) where matched = 'real' and block between {} and {}".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOIR","select count(*) from xmo_tx join xmo_txin using(txid) join xmo_ring using(xmo_inid) where matched = 'real' and time < '{}'".format(cutoff_date))]
    queries += [("XMVIR","select count(*) from xmv_tx join xmv_txin using(txid) join xmv_ring using(xmv_inid) where matched = 'real' and time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Number of correctly redeemed TXs"
    queries = []
    # queries += [("XMOREDEEM"," ")]
    # queries += [("XMVREDEEM"," ")]

    name = "Some Monerov Metadata"
    queries = []
    queries += [("XMVPUBLICBLOCK","select {}".format(1565244))]
    queries += [("XMVPUBLICDATE", "select {}".format('2018-05-08'))]
    queryGroups.append((name,queries.copy()))

    name = "Recent XMR data"
    queries = []
    ra = '2018-04-01'
    rb = '2018-08-31'
    queries += [("recenta","select {}::date".format(ra))]
    queries += [("recentb","select {}::date".format(rb))]
    queries += [("recentnofork","select count(*) from tx join txi using(txid) join ring_pre_fork using(inid) where matched = 'real' and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recentfork","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'real' and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recentmixinnofork","select count(*) from tx join txi using(txid) join ring_pre_fork using(inid) where matched = 'mixin' and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recentmixinfork","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recenttotal","select count(*) from tx join txi using(txid) join ring using(inid) where (matched = 'mixin' or matched = 'real') and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recentrm","select count(*) from tx join txi using(txid) join ring using(inid) where time between '{}' and '{}'".format(ra,rb))]

    queries += [("recenttotalnf","select count(*) from tx join txi using(txid) join ring_pre_fork using(inid) where (matched = 'mixin' or matched = 'real') and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recentrings","select count(*) from tx join txi using(txid) where ringsize > 1 and time between '{}' and '{}'".format(ra,rb))]
    queries += [("recenttxnoncb","select count(*) from tx where not coinbase and time between '{}' and '{}'".format(ra,rb))]
    queryGroups.append((name,queries.copy()))


    name = "Spent inputs"
    queries = []
    queries += [("numspent","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'spent' and time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    name = "Shared keyimgs"
    queries = []
    queries += [("sharedxmo","select count(*) from tx join txi using(txid) join xmo_txi using(keyimg) where time < '{}'".format(cutoff_date))]
    queries += [("sharedxmv","select count(*) from tx join txi using(txid) join xmv_txi using(keyimg) where time < '{}'".format(cutoff_date))]
    queryGroups.append((name,queries.copy()))

    return queryGroups

def fileContent():
    print("%\tThis file was generated by /python/data_table.py. Definitions etc. can be found there.")
    for (name,queries) in queryList():
        print('%\t', name)
        print('%\t', name, file=sys.stderr)
        for q in queries:
            queryTemplate(q)


if __name__ == "__main__":
    fileContent()