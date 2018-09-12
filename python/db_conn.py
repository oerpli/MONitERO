import psycopg2
import psycopg2.extras
import sys

from sqlalchemy import create_engine
import pandas as pd

def get_cursor():
	conn_string = "host='localhost' dbname='HintereggerA' user='HintereggerA' password='root'"
	# print the connection string we will use to connect
	print("Connecting to database: {}".format(conn_string), file=sys.stderr)
 	# get a connection, if a connect cannot be made an exception will be raised here
	conn = psycopg2.connect(conn_string)
 	# conn.cursor will return a cursor object, you can use this cursor to perform queries
	cursor = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
	# cursor = conn.cursor()
	return cursor

def query(query_string):
	cursor.execute(query_string)
	return cursor.fetchall()

engine = create_engine('postgresql://HintereggerA:root@localhost/HintereggerA')

def pandaquery(query_string):
	print("SQL: " + query_string)
	return pd.read_sql_query(query_string, engine)

cursor = get_cursor()

# print("DB Cursor is available as cursor")
# print("query with query(str)")