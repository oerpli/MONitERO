import db_conn as db
import sys
from itertools import chain, groupby
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.collections import PolyCollection
from matplotlib import cm
import matplotlib.pyplot as plt

import pandas as pd

# max_ringsize = sys.argv[1]


def getValue(q):
    return db.query(q)


def queryTemplate(x):
    (name, query) = x
    result = db.query(query)
    macro = r"\def\NAME{{{}\\xspace}}".format(result)
    print(macro)
    return macro


def numberMacrosGenerate():
    queries = []
    # To compare activities of forks and main chain, two subsets of the dataset are also generated.
    omin_xmr = 1546600
    vmin_xmr = 1564966
    omax_xmr = getValue("select max(block) from tx where time < '2018-09-01'")
    vmax_xmr = getValue("select max(block) from tx where time < '2018-09-01'")


    # For this purpose the block height that is closest to the last block on each chain before the cutoff date is chosen
    # Deprecated, just take last block before cutoff
    # omax_xmr = getValue("select block from tx order by (time - (select max(block) from xmo_tx where time < '2018-09-01')) asc limit 1")
    # vmax_xmr = getValue("select block from tx order by (time - (select max(block) from xmv_tx where time < '2018-09-01')) asc limit 1")

    queries += [("XMRDATEF","select time from tx where block = 1")]
    queries += [("XMODATEF","select min(time) from xmo_tx")]
    queries += [("XMVDATEF","select min(time) from xmv_tx")]
    queries += [("XMRDATEL","select max(time) from tx where time < '2018-09-01' ")]
    queries += [("XMODATEL","select max(time) from xmo_tx where time < '2018-09-01' ")]
    queries += [("XMVDATEL","select max(time) from xmv_tx where time < '2018-09-01' ")]
    queries += [("XMOFORK","select {}".format(omin_xmr-1))]
    queries += [("XMVFORK","select {}".format(vmin_xmr-1))]
    queries += [("XMRFIRST","select 1")]
    queries += [("XMOFIRST","select {}".format(omin_xmr))]
    queries += [("XMVFIRST","select {}".format(vmin_xmr))]
    # Height at analysis cutoff
    queries += [("XMRHEIGHT","select max(block) from tx where time < '2018-09-01'")]
    queries += [("XMRHEIGHTo","select {}".format(vmax_xmr))]
    queries += [("XMRHEIGHTv","select {}".format(omax_xmr))]
    queries += [("XMOHEIGHT","select max(block) from xmo_tx where time < '2018-09-01'")]
    queries += [("XMVHEIGHT","select max(block) from xmv_tx where time < '2018-09-01'")]
    # Last block timestamp before cutoff date
    queries += [("XMRTIMESTAMP","select max(time) from tx where time < '2018-09-01'")]
    queries += [("XMOTIMESTAMP","select max(time) from xmo_tx where time < '2018-09-01'")]
    queries += [("XMVTIMESTAMP","select max(time) from xmv_tx where time < '2018-09-01'")]
# TEMPLATE FOR COPYING
#"select count(*) from tx natural join txout where time < '2018-09-01'"
#"select count(*) from tx natural join txout where block between {} and {}'".format(omin_xmr,omax_xmr)
#"select count(*) from tx natural join txout where block between {} and {}'".format(vmin_xmr,vmax_xmr)
#"select count(*) from xmo_tx natural join xmo_txout where time < '2018-09-01'"
#"select count(*) from xmv_tx natural join xmv_txout where time < '2018-09-01'"

    # Number of TXs
    queries += [("XMRTX", "select count(*) from tx where time < '2018-09-01'")]
    queries += [("XMRTXo","select count(*) from tx where block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRTXv","select count(*) from tx where block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOTX", "select count(*) from xmo_tx where time < '2018-09-01'")]
    queries += [("XMVTX", "select count(*) from xmv_tx where time < '2018-09-01'")]
    # Number of Coinbase TXs
    queries += [("XMRCB", "select count(*) from tx where coinbase and time < '2018-09-01'")]
    queries += [("XMRCBo","select count(*) from tx where coinbase and block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRCBv","select count(*) from tx where coinbase and block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOCB", "select count(*) from xmo_tx where coinbase and time < '2018-09-01'")]
    queries += [("XMVCB", "select count(*) from xmv_tx where coinbase and time < '2018-09-01'")]
    # Number of Outputs
    queries += [("XMRTXOUT","select count(*) from tx natural join txout where time < '2018-09-01'")]
    queries += [("XMRTXOUTo","select count(*) from tx natural join txout where block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRTXOUTv","select count(*) from tx natural join txout where block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOTXOUT","select count(*) from xmo_tx natural join xmo_txout where time < '2018-09-01'")]
    queries += [("XMVTXOUT","select count(*) from xmv_tx natural join xmv_txout where time < '2018-09-01'")]
    # Number of Rings (inputs)
    queries += [("XMRR", "select count(*) from tx natural join txin where time < '2018-09-01'")]
    queries += [("XMRRo","select count(*) from tx natural join txin where block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRRv","select count(*) from tx natural join txin where block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOR", "select count(*) from xmo_tx natural join xmo_txin where time < '2018-09-01'")]
    queries += [("XMVR", "select count(*) from xmv_tx natural join xmv_txin where time < '2018-09-01'")]
    # Number of nontrivial rings
    queries += [("XMRRNT", "select count(*) from tx natural join txi where ringsize >1 and time < '2018-09-01'")]
    queries += [("XMRRNTo","select count(*) from tx natural join txi where ringsize >1 and block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRRNTv","select count(*) from tx natural join txi where ringsize >1 and block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMORNT", "select count(*) from xmo_tx natural join xmo_txi where ringsize >1 and time < '2018-09-01'")]
    queries += [("XMVRNT", "select count(*) from xmv_tx natural join xmv_txi where ringsize >1 and time < '2018-09-01'")]
    # Number of nontrivial rings deduced
    queries += [("XMRRNTL","select count(*) from tx natural join txi where ringsize>1 and effective_ringsize=1 and time < '2018-09-01'")]
    queries += [("XMRRNTLo","select count(*) from tx natural join txi where ringsize>1 and effective_ringsize=1 and block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRRNTLv","select count(*) from tx natural join txi where ringsize>1 and effective_ringsize=1 and block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMORNTL","select count(*) from xmo_tx natural join xmo_txi where ringsize>1 and effective_ringsize=1 and time < '2018-09-01'")]
    queries += [("XMVRNTL","select count(*) from xmv_tx natural join xmv_txi where ringsize>1 and effective_ringsize=1 and time < '2018-09-01'")]
    # Total ring members
    queries += [("XMRRM","select count(*) from tx natural join txin natural join ring where time < '2018-09-01'")]
    queries += [("XMRRMo","select count(*) from tx natural join txin natural join ring where block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRRMv","select count(*) from tx natural join txin natural join ring where block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMORM","select count(*) from xmo_tx natural join txin natural join ring where time < '2018-09-01'")]
    queries += [("XMVRM","select count(*) from xmv_tx natural join txin natural join ring where time < '2018-09-01'")]
    # Identified mixin
    queries += [("XMRIM","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and time < '2018-09-01'")]
    queries += [("XMRIMo","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRIMv","select count(*) from tx join txi using(txid) join ring using(inid) where matched = 'mixin' and block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOIM","select count(*) from xmo_tx join txi using(txid) join ring using(inid) where matched = 'mixin' and time < '2018-09-01'")]
    queries += [("XMVIM","select count(*) from xmv_tx join txi using(txid) join ring using(inid) where matched = 'mixin' and time < '2018-09-01'")]
    # Identified real
    queries += [("XMRIR","select count(*) from tx join txin using(txid) join ring using(inid) where matched = 'real' and time < '2018-09-01'")]
    queries += [("XMRIRo","select count(*) from tx join txin using(txid) join ring using(inid) where matched = 'real' and block between {} and {}'".format(omin_xmr,omax_xmr))]
    queries += [("XMRIRv","select count(*) from tx join txin using(txid) join ring using(inid) where matched = 'real' and block between {} and {}'".format(vmin_xmr,vmax_xmr))]
    queries += [("XMOIR","select count(*) from xmo_tx join txin using(txid) join ring using(inid) where matched = 'real' and time < '2018-09-01'")]
    queries += [("XMVIR","select count(*) from xmv_tx join txin using(txid) join ring using(inid) where matched = 'real' and time < '2018-09-01'")]
    # Correctly redeemed
    queries += [("XMOREDEEM"," ")]
    queries += [("XMVREDEEM"," ")]
    queries += [("XMVPUBLICBLOCK","select {}".format(1565244))]
    queries += [("XMVPUBLICDATE", "select {}".format('2018-05-08'))]


if __name__ == "__main__":
    plotTable("ringsize_distr_linked")  # exclude trivial inputs (those with 1 input)
    plotTable("ringsize_distr")  # all inputs
