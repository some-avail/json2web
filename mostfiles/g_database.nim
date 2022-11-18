#[ Abstraction-layer-module for the sqlite-db thru the lib db_sqlite.
    (there are also comparable libs like tiny_sqlite)
    This means that you can run SQL-statements without using SQL; instead 
    by using parametrized procs.

  Remarks:
  - sqlite has a system-table called "sqlite_master" in which 
  meta-information is stored.

  ADAP FUT:
  - optionalizing double quotes for names with spaces or hyphens in them
  -creating facilities to convert special characters
    * like converting single quote to double-single and vice versa
 ]#


import std/[
  db_sqlite, 
  strutils]

type 
  Comparetype = enum
    compDoNot
    compString
    compSubstr

var
  debugbo: bool = true
  versionfl: float = 0.2
  double_quote_namesbo: bool


# Beware: variable debugbo might be used globally, modularly and procedurally
# whereby lower scopes override the higher ones?
# Maybe best to use modular vars to balance between an overload of 
# messages and the need set the var at different places.

template log(messagest: string) =
  # replacement for echo that is only evaluated when debugbo = true
  if debugbo: 
    echo messagest



proc getDb*: DbConn =
  ## Create a DbConn
  # let filepathst = "/home/bruik/Bureaublad/nimtest.db"
  let filepathst = "/media/OnsSpul/1klein/1joris/k1-onderwerpen/computer/Programmeren/nimtaal/jester/json2web/mostfiles/datajson.db"
  open(filepathst, "", "", "")



template withDb*(body: untyped): untyped =
  # perform db-ops with automatic opening and closing of the db
  block:
    let db {.inject.} = getDb()
    try:
      body
    finally:
      close db


proc enquote(unquoted_namest: string): string = 
  # to be implemented
  discard

proc dequote(quoted_namest: string): string =
  # to be implemented
  discard

proc convertChars() = 
  # to be implemented
  # convert special characters, like apostrophe
  discard


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



proc readFromParams*(tablenamest: string, fieldsq: seq[string] = @[], 
      comparetype: Comparetype = compDoNot, fieldvaluesq: seq[array[2, string]] = @[],
      ordersq: seq[string] = @[], ordertypest: string = ""): seq[Row] = 


  #[ Retrieve a sequence of rows based on the entered parameters. 
    Comparetype-enum see top of file. 
    fieldsq = @[]  means empty sequence and return all fields
    fieldvaluesq = @[] means empty and thus all records are returned
    ordersq - creating ordered fields
    ordertypest - ASC or DESC, for ascending or descending

    You can either sequentially enter params without varnames, or when one param
    is omitted, you must use the varnames in the following ones (var = value).
    Generally, parameter-omission results in the defaults.


    Call like: 
      readFromParams("mr_data", @[], compString, @[["Weight", "58"]])     > no(=all) fields, one cond.
      readFromParams("mr_data", @["anID", "Droidname"], compSubstr, @[["Weight", "58"]])
      readFromParams("mr_data", @[], ordersq = @["Droidname"], ordertypest = "ASC")    > all fields, no conditions, do order

    ADAP HIS:
    - add substring-search
    - add an order-option

    ADAP FUT:
   ]#

  var
    sqlst, whereclausest, fieldlist, orderlist: string
    lengthit, countit: int

  # which fields to query
  if fieldsq.len == 0:
    sqlst = "SELECT * FROM " & tablenamest
  elif fieldsq.len == 1:
    sqlst = "SELECT " & fieldsq[0] & " FROM " & tablenamest
  else:
    fieldlist = fieldsq.join(", ")
    sqlst = "SELECT " & fieldlist & " FROM " & tablenamest

  # prepare the where-clause / row-filter
  lengthit = len(fieldvaluesq)
  countit = 0

  if fieldvaluesq.len > 0:
    sqlst &= " WHERE "

    if comparetype == compString:
      for fieldvalar in fieldvaluesq:
        countit += 1
        whereclausest &= fieldvalar[0] & " = '" & fieldvalar[1] & "'"
        if countit < lengthit:
          whereclausest &= " AND "
    elif comparetype == compSubstr:
      for fieldvalar in fieldvaluesq:
        countit += 1
        whereclausest &= fieldvalar[0] & " LIKE '%" & fieldvalar[1] & "%'"
        if countit < lengthit:
          whereclausest &= " AND "

    sqlst &= whereclausest
 
  
  # prep order-strings
  if ordersq.len == 1:
    orderlist = ordersq[0]
    sqlst &= " ORDER BY " & orderlist & " " & ordertypest
  elif ordersq.len > 1:
    orderlist = ordersq.join(", ")
    sqlst &= " ORDER BY " & orderlist & " " & ordertypest

  echo sqlst

  # get the row-sequence
  withDb:
    result = db.getAllRows(sql(sqlst))



proc addNewFromParams*(tablenamest: string, fieldvaluesq: seq[array[2, string]]) =
  #[ 
  Base on sql: "INSERT INTO my_table (id, name) VALUES (0, jack)"
  Apostrophes-possibs:
    *Apostrophes can be added by prefixing another apostrophe in sql, thus ''
    *replace apostrs by some sequence like _-_-_-_and then back for showing 
    purposes.
  Call like:
    addNewFromParams("mr_data", @[["Droidname", "Koid"], ["Type","neutronic"]])
    addNewFromParams("mr_data", @[["Weight", "63"]])
   ]#


  var
    sqlst, fieldlist, valuelist: string
    lengthit, countit: int

  sqlst = "INSERT INTO " & tablenamest & " ("

  lengthit = len(fieldvaluesq)
  countit = 0

  if lengthit == 1:
    fieldlist = fieldvaluesq[0][0]
    valuelist = "'" & fieldvaluesq[0][1] & "'"
  elif lengthit > 1:
    for fieldvalar in fieldvaluesq:
      countit += 1
      if countit < lengthit:
        fieldlist &= fieldvalar[0] & ", "
        valuelist &= "'" & fieldvalar[1] & "', "

      elif countit == lengthit:
        fieldlist &= fieldvalar[0]
        valuelist &= "'" & fieldvalar[1] & "'"
  
  sqlst &= fieldlist & ") VALUES (" & valuelist & ")"

  log("==================")
  log(sqlst)

  withDb:
    db.exec(sql(sqlst))



proc deleteFromParams*(tablenamest: string, comparetype: Comparetype = compString, 
                        fieldvaluesq: seq[array[2, string]] = @[]) =

  #[ Delete a sequence of rows based on the entered parameters. 
    Comparetype-enum see top of file. 
    fieldvaluesq = @[] must have at least one array-pair

   ]#

  var
    sqlst, whereclausest, fieldlist: string
    lengthit, countit: int

  sqlst = "DELETE FROM " & tablenamest


  # prepare the where-clause / row-filter
  lengthit = len(fieldvaluesq)
  countit = 0

  sqlst &= " WHERE "

  if comparetype == compString:
    for fieldvalar in fieldvaluesq:
      countit += 1
      whereclausest &= fieldvalar[0] & " = '" & fieldvalar[1] & "'"
      if countit < lengthit:
        whereclausest &= " AND "
  elif comparetype == compSubstr:
    for fieldvalar in fieldvaluesq:
      countit += 1
      whereclausest &= fieldvalar[0] & " LIKE '%" & fieldvalar[1] & "%'"
      if countit < lengthit:
        whereclausest &= " AND "

  sqlst &= whereclausest
 
  log("-------------------------") 
  log(sqlst)

  # get the row-sequence
  withDb:
    db.exec(sql(sqlst))




proc updateFromParams*(tablenamest: string, setfieldvaluesq: seq[array[2, string]],
                           comparetype: Comparetype = compString, 
                        wherefieldvaluesq: seq[array[2, string]] = @[]) =
  
  var
    sqlst, whereclausest, setclausest: string
    wlengthit, wcountit, slengthit, scountit: int


  # starting-sql-statement
  sqlst = "UPDATE " & tablenamest & " SET "

  # prepare the set-clause
  slengthit = len(setfieldvaluesq)
  scountit = 0
  
  for fieldvalar in setfieldvaluesq:
    scountit += 1
    setclausest &= fieldvalar[0] & " = '" & fieldvalar[1] & "'"
    if scountit < slengthit:
      setclausest &= ", "

  sqlst &= setclausest & " WHERE "

  # prepare the where-clause / row-filter
  wlengthit = len(wherefieldvaluesq)
  wcountit = 0

  if comparetype == compString:
    for fieldvalar in wherefieldvaluesq:
      wcountit += 1
      whereclausest &= fieldvalar[0] & " = '" & fieldvalar[1] & "'"
      if wcountit < wlengthit:
        whereclausest &= " AND "
  elif comparetype == compSubstr:
    for fieldvalar in wherefieldvaluesq:
      wcountit += 1
      whereclausest &= fieldvalar[0] & " LIKE '%" & fieldvalar[1] & "%'"
      if wcountit < wlengthit:
        whereclausest &= " AND "


  sqlst &= whereclausest
 
  log("-------------------------") 
  log(sqlst)

  withDb():
    db.exec(sql(sqlst))



when isMainModule:
  #echo readFromParams("mr_data", comparetype = compString, fieldvaluesq = @[["Weight", "54"]])
  # echo readFromParams("mr_data", @["anID", "Droidname"], ordersq = @["anID"], ordertypest = "DESC")
  #echo readFromParams("mr_data", @["Droidname"], ordersq = @["anID"], ordertypest = "DESC")
  #echo readFromParams("mr_data", ordersq = @["Type", "Weight"], ordertypest = "ASC")
  echo readFromParams("mr_data")
  #echo readFromParams("planten")

  #addNewFromParams("mr_data", @[["Droidname", "Koid"], ["Type","neutronic"]])
  #addNewFromParams("mr_data", @[["Weight", "63"]])
  #sleep(1000)
  #deleteFromParams("mr_data", compString, @[["Weight", "63"]])

  #addNewFromParams("mr_data", @[["Weight", "63"]])

  #updateFromParams("mr_data", @[["Date_of_build", "2428-03-25"]], compString, @[["Droidname", "Koid"]])

