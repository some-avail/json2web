import std/[db_sqlite, strutils]
import g_database

#[ Not yet used ]#


proc readRecordToInputs(): seq[Row] = 
  
  withDb:
    result = db.getAllRows(sql"SELECT * FROM mr_data WHERE Type = ?", "positronic")


