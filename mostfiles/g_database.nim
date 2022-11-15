import std/[db_sqlite, strutils]

#[ Test-module for the sqlite-db thru the lib db_sqlite.
    (there are also comparable libs like tiny_sqlite)
  Remarks:
  - sqlite has a system-table called "sqlite_master" in which 
  meta-information is stored.
 ]#


type 
  Comparetype = enum
    compString
    compSubstring


proc getDb*: DbConn =
  ## Create a DbConn
  let filepathst = "/home/bruik/Bureaublad/nimtest.db"
  open(filepathst, "", "", "")



template withDb*(body: untyped): untyped =
  # perform db-ops with automatic opening and closing of the db
  block:
    let db {.inject.} = getDb()
    try:
      body
    finally:
      close db



proc getFieldAndTypeList*(tablenamest: string): seq[array[2, string]] = 
  # get fields and types for the desired table from the system-table "sqlite_master"
  # by means of the create-string.
  # Limits till now: cannot yet handle spaces or hyphens in field-names

#[sample-create-string:
 CREATE TABLE mr_data 
(anID INTEGER CONSTRAINT auto_inc PRIMARY KEY ASC AUTOINCREMENT, Droidname TEXT UNIQUE, 
Type TEXT, Builder STRING, Date_of_build DATE, Weight REAL, Cost NUMERIC, 
Purpose STRING, Modelnr TEXT)
 ]#

  var 
    create_stringst, fieldandtypest: string
    fielddatasq, field_elemsq: seq[string]
    field_typesq: seq[array[2, string]]


  withDb:
    create_stringst = getValue(db, sql"SELECT sql FROM sqlite_master WHERE name = ?", tablenamest)
    # echo create_stringst
  
  fieldandtypest = create_stringst.split('(')[1]
  fieldandtypest = fieldandtypest.split(')')[0]
  fielddatasq = fieldandtypest.split(", ")

  for fielddata in fielddatasq:
    field_elemsq = fielddata.split(' ')
    field_typesq.add([field_elemsq[0],field_elemsq[1]])

  result = field_typesq




proc readFromParams(tablenamest: string, comparetype: Comparetype, 
                  fieldvaluesq: seq[array[2, string]]): seq[Row] = 
  #[ Retrieve a sequence of rows based on the 
    entered parameters. Comparetype-enum see top of file.
    Call like: readFromParams("mr_data", @[["Weight", "58"]])

    ADAP FUT:
    - add substring-search

   ]#


  #create sql-string
  var
    sqlst, whereclausest, comparatorst: string
    lengthit, countit: int
    valuesq: seq[string]

  if comparetype == compString:
    comparatorst = " = ?"
  elif comparetype == compSubstring:
    comparatorst = " LIKE '?'"

  lengthit = len(fieldvaluesq)
  countit = 0

  sqlst = "SELECT * FROM " & tablenamest & " WHERE "
  for fieldvalar in fieldvaluesq:
    valuesq.add(fieldvalar[1])
    countit += 1
    whereclausest &= fieldvalar[0] & comparatorst
    if countit < lengthit:
      whereclausest &= " AND "

  sqlst &= whereclausest
  echo sqlst

  # get the row-sequence
  withDb:
    result = db.getAllRows(sql(sqlst), valuesq)



when isMainModule:
  echo readFromParams("mr_data", compSubstring, @[["Type", "ga"]])

