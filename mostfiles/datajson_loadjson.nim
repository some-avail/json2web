
#[ Module-function: 
  This module concerns both the initial json-node
  and the stored json-node that is / will be bound to a tab-ID.


  Initial node:
  Read the json-file, convert it to a jnob,
  load additional public data to the jnob, and 
  expose it as function.

  Public in this context means unchangable data
  relevant to all users.
  User-data must be loaded from the routes-location
  in project_startup.nim to avoid shared data.

  Stored node:
  In this all tab-specific changes are stored, so 
  that the state of the tab's gui is saved. However this 
  breaks multi-threading because of a global var.
  Futurally i might write the jnob to the database 
  so that the global var can be omitted and 
  multi-threading can be restored.
  
 ]#



import json, tables
#import g_database, g_db2json


var versionfl: float = 0.3

# create a table with jnobs, one for every tab
# (futural multi-user-approach)
#var jsondefta* {.threadvar.} = initTable[string, JsonNode]()
var jsondefta* = initTable[string, JsonNode]()


proc initialLoading(parjnob: JsonNode): JsonNode = 
  # custom - load extra public data to the json-object
  # this is a dummy function for now

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

  if not jsondefta.hasKey(tabIDst):
      jsondefta.add(tabIDst, readInitialNode(project_prefikst))

  result = jsondefta[tabIDst]



proc writeStoredNode*(tabIDst: string, storedjnob: JsonNode) = 

  jsondefta[tabIDst] = storedjnob




