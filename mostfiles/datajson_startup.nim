

#[ Sample-project "controls" to learn how to use jester, moustachu and
g_html_json (html-elements generated from a json-definition-file).

Beware of the fact  that there are two kinds of variables:
-moustachu-variables in the html-code, in which the generated html-controls are 
substituted. Designated with {{}} or {{{}}}. Sometimes two braces are enough,
but it is saver to use three to avoid premature evaluation.
-control-variables used by jester. Jester reads control-states and puts them 
in either of two variables (i dont know if they are fully equivalent):
* variables like @"controlname"
* request.params["controlname"]

Do not use global vars  or otherwise you can not compile for multi-threading
with switch --threads:on
The trick is to put your globals in a proc thence they are no globals 
anymore. But you cannot store a global in a proc so retrieve them from a 
file. When you only read from the files no-problemo but if you write you 
might get problems because of the shared data corruption; that is different 
threads writing and expecting different data.
See also the module datajson_loadjson.nim
Currently --threads :on compiles and runs succesfully.



ADAP HIS
-change static_config and calls

ADAP NOW


]#


import jester, moustachu, times, json, os, tables

import datajson_loadjson, g_db2json, g_json_plus
#from datajson_loadjson import nil
from g_html_json import nil
from g_tools import nil



const 
  versionfl:float = 0.2
  project_prefikst = "datajson"
  appnamebriefst = "DJ"
  appnamenormalst = "DataJson"
  appnamelongst = "Database thru json"
  appnamesuffikst = " showcase"
  portnumberit = 5170

  firstelems_pathst = @["all web-pages", "first web-page", "web-elements fp"]


settings:
  port = Port(portnumberit)



proc showPage(par_innervarob, par_outervarob: var Context, 
              custominnerhtmlst:string=""): string = 

  var innerhtmlst:string
  if custominnerhtmlst == "":
    innerhtmlst = render(readFile(project_prefikst & "_inner.html") , par_innervarob)    
  else:
    innerhtmlst = custominnerhtmlst
  par_outervarob["controls-group"] = innerhtmlst

  return render(readFile(project_prefikst & "_outer.html"), par_outervarob)



  # sleep 1000
  # echo "hai"
  # echo $now()



routes:

  get "/":
    resp "Type: localhost:" & $portnumberit & "/" & project_prefikst


  get "/datajson":

  # hard code because following does not work:
  # get ("/" & project_prefikst):

    var
      statustekst:string
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions

    innervarob["statustext"] = """Status OK"""

    var gui_jnob = datajson_loadjson.getGuiJsonNode(project_prefikst)

    innervarob["newtab"] = "_self"
    outervarob["version"] = $versionfl
    outervarob["loadtime"] ="Page-load: " & $now()
    outervarob["namenormal"] = appnamenormalst
    outervarob["namelong"] = appnamelongst
    outervarob["namesuffix"] = appnamesuffikst
    outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
    outervarob["project_prefix"] = project_prefikst

    innervarob["project_prefix"] = project_prefikst  
    innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", "", 1)

    innervarob["table01"] = g_html_json.setTableBasic(gui_jnob, "table_01")

    resp showPage(innervarob, outervarob)


  get "/hello":
    resp "Hello world"


  post "/datajson":

    var
      statustekst, righttekst:string
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions
      cookievaluest, locationst, mousvarnamest: string
      funcpartsta =  initOrderedTable[string, string]()
      firstelems_pathsq: seq[string] = @["all web-pages", "first web-page", "web-elements fp", "your-element"]

    var gui_jnob = datajson_loadjson.getGuiJsonNode(project_prefikst)
    #var copyjnob = gui_jnob


    # for now sua - single user approach
    if not jsondefta.hasKey("sua"):
      jsondefta.add("sua", getGuiJsonNode(project_prefikst))


    innervarob["newtab"] = "_self"
    outervarob["version"] = $versionfl
    outervarob["loadtime"] ="Page-load: " & $now()

    outervarob["namenormal"] = appnamenormalst
    outervarob["namelong"] = appnamelongst
    outervarob["namesuffix"] = appnamesuffikst
    outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
    outervarob["project_prefix"] = project_prefikst     


    innervarob["project_prefix"] = project_prefikst  
    innervarob["linkcolor"] = "red"

    innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", 
                                                          @"dropdownname_01", 1)
    righttekst = "The value of dropdownname_01 = " & @"dropdownname_01"

    innervarob["righttext"] = righttekst

    firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "basic tables fp")
    graftJObjectToTree("mr_data", firstelems_pathsq, jsondefta["sua"], 
                         createHtmlTableNodeFromDB("mr_data"))

    innervarob["table01"] = g_html_json.setTableBasic(jsondefta["sua"], "mr_data")
    #innervarob["table01"] = g_html_json.setTableBasic(copyjnob, "table_01")


    # A server-function may have been called from client-side (browser-javascript) by
    # preparing a cookie for the server (that is here) to pick up and execute.
    # (what i call a cookie-tunnel)
    if request.cookies.haskey(project_prefikst & "_run_function"):
      cookievaluest = request.cookies[project_prefikst & "_run_function"]
      if cookievaluest != "DISABLED":
        funcpartsta = g_tools.getFuncParts(cookievaluest) 
        locationst = funcpartsta["location"]  # innerhtml-page or outerhtml-page
        mousvarnamest = funcpartsta["mousvarname"]

        if locationst == "inner":
          innervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, gui_jnob)
        elif locationst == "outer":
          outervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, gui_jnob)



    resp showPage(innervarob, outervarob)

