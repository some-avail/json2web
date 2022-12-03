

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
Currently --threads :on compiles and runs succesfully no more because of 
the global variable jsondefta. In the future i might use a database instead 
of a global var to reenable multi-threading.



ADAP HIS
-change static_config and calls

ADAP NOW


]#


import jester, moustachu, times, json, os, tables, db_sqlite

import datajson_loadjson, g_db2json, g_json_plus
import g_database
import datajson_logic
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

    var initialjnob = datajson_loadjson.readInitialNode(project_prefikst)

    innervarob["newtab"] = "_self"
    outervarob["version"] = $versionfl
    outervarob["loadtime"] ="Page-load: " & $now()
    outervarob["namenormal"] = appnamenormalst
    outervarob["namelong"] = appnamelongst
    outervarob["namesuffix"] = appnamesuffikst
    outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
    outervarob["project_prefix"] = project_prefikst

    innervarob["project_prefix"] = project_prefikst  
    #innervarob["dropdown1"] = g_html_json.setDropDown(initialjnob, "dropdownname_01", "", 1)
    innervarob["dropdown1"] = g_html_json.setDropDown(initialjnob, "All_tables", "", 1)

    innervarob["table01"] = g_html_json.setTableBasic(initialjnob, "table_01")

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
      storedjnob: JsonNode
      recordsq: seq[Row] = @[]
      id_fieldst, fieldnamest, id_valuest, id_typest, tabidst: string
      colcountit, countit: int
      fieldtypesq, savefieldvaluesq: seq[array[2, string]]

 
    if len(@"tab_ID") == 0:
      tabidst = genTabId()
    else:
      tabidst = @"tab_ID"


    storedjnob = readStoredNode(tabidst, project_prefikst)
    innervarob["tab_id"] = tabidst


    # tabID formerly was: sua - single user approach
    #storedjnob = readStoredNode("sua", project_prefikst)


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

    innervarob["dropdown1"] = g_html_json.setDropDown(storedjnob, "All_tables", 
                                                          @"All_tables", 1)

    #righttekst = "The value of dropdownname_01 = " & @"dropdownname_01"
    #innervarob["righttext"] = righttekst

    firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "basic tables fp")

    pruneJnodesFromTree(storedjnob, firstelems_pathsq, getAllUserTables())
    graftJObjectToTree(@"All_tables", firstelems_pathsq, storedjnob, 
                         createHtmlTableNodeFromDB(@"All_tables"))


    #echo @"All_tables"
    fieldtypesq = getFieldAndTypeList(@"All_tables")
    id_fieldst = fieldtypesq[0][0]
    id_typest = fieldtypesq[0][1]
    savefieldvaluesq = fieldtypesq
    #echo id_fieldst


    if @"curaction" == "loading table..":
      innervarob["statustext"] = readFromParams("sqlite_master", @["sql"], compString, 
                                          @[["name", @"All_tables"]])[0][0]


    #echo @"radiorecord"
    if @"radiorecord" == "":
      innervarob["table01"] = g_html_json.setTableFromDb(storedjnob, @"All_tables")
    else:
      recordsq = readFromParams(@"All_tables", @[], compString, @[[id_fieldst, @"radiorecord"]])
      echo recordsq
      if len(recordsq) > 0:
        if len(recordsq[0]) > 0:
          innervarob["table01"] = g_html_json.setTableFromDb(storedjnob, @"All_tables",
                                  @"radiorecord" , recordsq[0])
      else:
        innervarob["table01"] = g_html_json.setTableFromDb(storedjnob, @"All_tables")


    #innervarob["table01"] = g_html_json.setTableBasic(storedjnob, @"All_tables")


    if @"curaction" == "saving.." or @"curaction" == "deleting..":
      # Reuse the var savefieldvaluesq and overwrite the second field 'type' for the values
      colcountit = getColumnCount(@"All_tables")
      for countit in 1..colcountit:
        fieldnamest = "field_" & $countit
        if request.params.haskey(fieldnamest):
          #echo request.params[fieldnamest]
          #echo @fieldnamest

          if countit == 1:
            id_valuest = request.params[fieldnamest]

          # Reuse the var and overwrite the second field 'type' for the values
          savefieldvaluesq[countit - 1][1] = request.params[fieldnamest]


    if @"curaction" == "saving..":

      try:
        if len(id_valuest) == 0:    # empty-idfield 
          # must become new record if db-generated
          if getKeyFieldStatus(@"All_tables") == genIntegerByDb:
            #remove the id-field:
            savefieldvaluesq.delete(0)
            addNewFromParams(@"All_tables", savefieldvaluesq)
          else:
            innervarob["statustext"] = """Cannot save the record because 
              the ID-field has been left empty and the ID-value is not 
              automatically generated for this table."""

        else:   # filled id-field
          if idValueExists(@"All_tables", id_fieldst, id_valuest):
            # record exists allready; perform an update of the values only.
            savefieldvaluesq.delete(0)
            updateFromParams(@"All_tables", savefieldvaluesq, compString, @[[id_fieldst, id_valuest]])
          else:     # a new record will be entered with the given id-value
            # id-data must be kept in var savefieldvaluesq

            addNewFromParams(@"All_tables", savefieldvaluesq)


        # requery including the new record
        graftJObjectToTree(@"All_tables", firstelems_pathsq, storedjnob, 
                             createHtmlTableNodeFromDB(@"All_tables"))
        innervarob["table01"] = g_html_json.setTableFromDb(storedjnob, @"All_tables")


      except DbError:
        innervarob["statustext"] = getCurrentExceptionMsg()


      except:
        let errob = getCurrentException()
        echo "\p******* Unanticipated error ******* \p" 
        echo repr(errob) & "\p****End exception****\p"



    if @"curaction" == "deleting..":
      if len(id_valuest) > 0:    # idfield must present
        deleteFromParams(@"All_tables", compString, @[[id_fieldst, id_valuest]])

        # requery - deletion gone well?
        graftJObjectToTree(@"All_tables", firstelems_pathsq, storedjnob, 
                             createHtmlTableNodeFromDB(@"All_tables"))
        innervarob["table01"] = g_html_json.setTableFromDb(storedjnob, @"All_tables")
      else:
        innervarob["statustext"] = "Only records with ID-field can be deleted.."



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
          innervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, storedjnob)
        elif locationst == "outer":
          outervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, storedjnob)


    writeStoredNode(tabidst, storedjnob)

    resp showPage(innervarob, outervarob)

