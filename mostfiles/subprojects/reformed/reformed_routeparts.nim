import moustachu, times, json, os, tables

import g_html_json, g_tools, g_routehelp
import reformed_loadjson
import app_globals




proc doGet_Reformed*(): tuple[x,y: Context] = 
  #[
  GET-code from the routes can extracted without extra handling.
  The filled-in moustachu context-vars are returned
  ]#

  var
    statustekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
  innervarob["statustext"] = """Basic webserver with some controls generated from 
  a gui-definition-file in json-format. 
  The webserver-interface without cliental javascript has only one button:
  submit your request to the server. Switches (like below) indicate what you want to do."""


  var gui_jnob = getGuiJsonNode(project_prefikst)

  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()
  outervarob["namenormal"] = appnamenormalst
  outervarob["namelong"] = appnamelongst
  outervarob["namesuffix"] = appnamesuffikst
  outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
  outervarob["project_prefix"] = project_prefikst

  innervarob["project_prefix"] = project_prefikst  
  innervarob["dropdown1"] = setDropDown(gui_jnob, "dropdownname_01", "", 1)
  innervarob["dropdown2"] = setDropDown(gui_jnob, "dropdownname_02", "", 1)
  innervarob["dropdown3"] = setDropDown(gui_jnob, "dropdownname_03", "", 3)
  innervarob["radiobuttonset1"] = setRadioButtons(gui_jnob, 
                                          "radiosetexample", "")
  innervarob["checkboxset1"] = setCheckBoxSet(gui_jnob, 
                                              "checksetexample", @["default"])

  innervarob["table01"] = setTableBasic(gui_jnob, "table_01")

  result = (innervarob, outervarob)



proc doPost_Reformed*(cta: var Table[string, string]): tuple[x,y: Context] = 
  
  #[
  POST-code from the routes can be extracted by passing a control-table based on the request-params
  The filled-in moustachu context-vars are returned
  ]#

  # cta = control-table

  var
    statustekst, righttekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions


  var gui_jnob = getGuiJsonNode(project_prefikst)



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

  innervarob["dropdown1"] = setDropDown(gui_jnob, "dropdownname_01", 
                                                        cta.vlu("dropdownname_01"), 1)
  righttekst = "The value of dropdownname_01 = " & cta.vlu("dropdownname_01")

  innervarob["dropdown2"] = setDropDown(gui_jnob, "dropdownname_02", 
                                              cta.vlu("dropdownname_02"), 1)

  righttekst = righttekst & "<br>" & "The value of dropdownname_02 = " & cta.vlu("dropdownname_02")

  innervarob["radiobuttonset1"] = setRadioButtons(gui_jnob, "radiosetexample", cta.vlu("radiosetexample"))

  innervarob["dropdown3"] = setDropDown(gui_jnob, "dropdownname_03", 
                                                        cta.vlu("dropdownname_03"), 3)

  # righttekst = righttekst & "<br>" & "The selected radiobutton = " & 
  #                                   cta.vlu("radiosetexample")
  righttekst = righttekst & "<br>" & "The selected radiobutton = " & cta.vlu("radiosetexample")


  innervarob["checkboxset1"] = setCheckBoxSet(gui_jnob, 
                              "checksetexample", @[cta.vlu("check1"), cta.vlu("check2"), cta.vlu("check3")])

  righttekst = righttekst & "<br>" & "The boxes that are checked are: " & 
                                cta.vlu("check1") & " " & cta.vlu("check2") & " " & cta.vlu("check3")

  innervarob["righttext"] = righttekst

  result = (innervarob, outervarob)

  


proc doRunFunctionFromClient*(cookievaluest: string; innervarob, outervarob: var Context): tuple[x, y: Context] =

    # A server-function may have been called from client-side (browser-javascript) by
    # preparing a cookie for the server (that is here) to pick up and execute.
    # (what i call a cookie-tunnel)

  var 
    locationst, mousvarnamest: string
    funcpartsta =  initOrderedTable[string, string]()

  var gui_jnob = getGuiJsonNode(project_prefikst)


  if cookievaluest != "DISABLED":
    funcpartsta = getFuncParts(cookievaluest) 
    locationst = funcpartsta["location"]  # innerhtml-page or outerhtml-page
    mousvarnamest = funcpartsta["mousvarname"]

    if locationst == "inner":
      innervarob[mousvarnamest] = runFunctionFromClient(funcpartsta, gui_jnob)
    elif locationst == "outer":
      outervarob[mousvarnamest] = runFunctionFromClient(funcpartsta, gui_jnob)

  result = (innervarob, outervarob)
