
#[ Module-function: 
  This module concerns both the initial json-node
  and the stored json-node that is bound to a tab-ID.


  Initial node:
  Read the json-file, convert it to a jnob,
  load additional public data to the jnob, and 
  expose it as function.

  Public in this context means unchangable data
  relevant to all users.
  User-data must be loaded from the routes-location
  in project_startup.nim to avoid shared data.

  Stored node (in mem or on disk):
  In this all tab-specific changes are stored, so 
  that the state of the tab's gui is saved. 
  When saved in memory this breaks multi-threading 
  because of a global var.
  When saved on disk the global var is omitted and 
  you can compile with multi-threading.

  The below constant "persisttype" determines the 
  behaviour.

 ]#



import json, tables, os
import g_database, g_db2json, g_json_plus


const storednodesdir = "stored_gui_nodes"

var versionfl: float = 0.3



type
  PersistModeJson* = enum
    persistNot        # use only initial node without storage-needs
    persistInMem
    persistOnDisk

const persisttype* = persistOnDisk     # see enum above



# create a table with jnobs, one for every tab
# (futural multi-user-approach)
#var jsondefta* {.threadvar.} = initTable[string, JsonNode]()
when persisttype == persistInMem:
  var jsondefta* = initTable[string, JsonNode]()


proc initialLoading(parjnob: JsonNode): JsonNode = 
  # custom - load extra public data to the json-object
  # this is a dummy function for now
  var 
    tablesq: seq[string]
    firstelems_pathsq: seq[string] = @["all web-pages", "first web-page", "web-elements fp", "your-elem-type"]
    newjnob: JsonNode = parjnob

  firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "dropdowns fp")
  graftJObjectToTree("All_tables", firstelems_pathsq, newjnob, 
                    createDropdownNodeFromDb("All_tables", "sqlite_master", @["name", "name"], 
                        compNotSub, @[["name", "sqlite"]], @["name"], "ASC"))

  result = parjnob




proc readInitialNode*(proj_prefikst: string): JsonNode = 
  var 
    filest: string
    jnob, secondjnob: JsonNode

  filest = proj_prefikst & "_gui.json"
  jnob = parseFile(filest)
  secondjnob = initialLoading(jnob)

  result = secondjnob



proc readStoredNode*(tabIDst, project_prefikst: string): JsonNode = 

  var filepathst: string

  when persisttype == persistInMem:
    if not jsondefta.hasKey(tabIDst):
        jsondefta.add(tabIDst, readInitialNode(project_prefikst))
        #echo "====*******========************======="
    result = jsondefta[tabIDst]

  elif persisttype == persistOnDisk:
    filepathst = storednodesdir / tabIDst & ".json"
    if fileExists(filepathst):
      result = parseFile(filepathst)
    else:
      result = readInitialNode(project_prefikst)



proc writeStoredNode*(tabIDst: string, storedjnob: JsonNode) = 
  
  var filepathst: string

  when persisttype == persistInMem:
    # store in table of json-nodes
    jsondefta[tabIDst] = storedjnob
  elif persisttype == persistOnDisk:
    #then serialize with pretty and write to file
    filepathst = storednodesdir / tabIDst & ".json"
    writeFile(filepathst, pretty(storedjnob))
    


