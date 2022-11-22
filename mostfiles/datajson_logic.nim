import std/[db_sqlite, strutils]
import g_database



proc readSomeRecords(): seq[Row] = 
  
  withDb:
    result = db.getAllRows(sql"SELECT * FROM mr_data WHERE Type = ?", "positronic")



