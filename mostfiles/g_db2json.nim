#[ Generic module to transfer data from the
database to a json-object (jnob). 
This jnob is used loosely or integrated in 
(a copy of) the json-definition (jnob) ]#


import std/[json, tables, db_sqlite]
import g_database, datajson_loadjson


var
  debugbo: bool = true
  versionfl: float = 0.2



# Beware: variable debugbo might be used globally, modularly and procedurally
# whereby lower scopes override the higher ones?
# Maybe best to use modular vars to balance between an overload of 
# messages and the need set the var at different places.

template log(messagest: string) =
  # replacement for echo that is only evaluated when debugbo = true
  if debugbo: 
    echo messagest




proc createHtmlTableNodeFromDB*(db_tablenamest: string): JsonNode =

  var
    rowsq: seq[Row]
    tablejnob: JsonNode = %*{}
    headersq:  seq[array[2, string]]
    rowcountit: int = 0

  
  tablejnob.add(db_tablenamest, %*{})
  echo tablejnob

  tablejnob[db_tablenamest].add("theader", %*[])
  echo tablejnob

  headersq = getFieldAndTypeList(db_tablenamest)

  for itemar in headersq:
    tablejnob[db_tablenamest]["theader"].add(%itemar[0])

  echo tablejnob

  tablejnob[db_tablenamest].add("tdata", %*[])


  # retrieve the rows from the desired table  
  rowsq = readFromParams(db_tablenamest)
  echo rowsq

  for row in rowsq:
    tablejnob[db_tablenamest]["tdata"].add(%*[])
    for value in row:
      tablejnob[db_tablenamest]["tdata"][rowcountit].add(%value)
    rowcountit += 1
  
  #echo tablejnob
  echo "============"

  result = tablejnob


proc createDropdownNodeFromDb() = 
  discard

when isMainModule:
  echo "-------------"
  echo createHtmlTableNodeFromDB("mr_data")
  echo "-------------"
  #echo createHtmlTableNodeFromDB("mr_data")["mr_data"]

  discard