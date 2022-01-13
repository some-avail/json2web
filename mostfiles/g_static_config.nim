
#[ Precompilational config. (g_static_config.nim)

  
  3 config-files can be used in nimwebbie-projects:
  -precompilational configuration: static_config.nim
  -on-start-configuration: project_onstart_config.json of .conf ?
  -post-start-configuration: project_dynamic_config.json of .conf ?

  This module is currently used as generic module, that is not 
  project-specific. The other two configs are project-specific (future).

  Below jsonnode-object variable has been given the 
  pragma {.threadvar.} to enable multi-threading. Without this pragma
  global vars are not allowed to be compiled with --threads:on
  Unfortunately --Threads:on compiles but crashes with sigsegv
  ]#



import json

var versionfl: float = 0.1

var project_prefikst*: string
# var gui_jnob* {.threadvar.}: JsonNode
var gui_jnob*: JsonNode


proc setGuiJsonNode*() =
  var filest = project_prefikst & "_gui.json"
  echo filest
  gui_jnob = parseFile(filest)

