

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
  versionfl:float = 0.5
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
      gui_jnob: JsonNode
      recordsq: seq[Row] = @[]
      id_fieldst, fieldnamest, id_valuest, id_typest, tabidst, filternamest, filtervaluest: string
      colcountit, countit, addcountit: int
      fieldtypesq, fieldvaluesq, filtersq: seq[array[2, string]] = @[]
      filtervaluesq: seq[string] = @[]
      tablechangedbo: bool = false


    when persisttype == persistNot:
      gui_jnob = readInitialNode(project_prefikst)
    else:
      when persisttype == persistOnDisk: 
        if theTimeIsRight():
          deleteExpiredFromAccessBook()
      if len(@"tab_ID") == 0:
        tabidst = genTabId()
      else:
        tabidst = @"tab_ID"

      gui_jnob = readStoredNode(tabidst, project_prefikst)
      innervarob["tab_id"] = tabidst



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

    #echo gui_jnob
    innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "All_tables", 
                                                          @"All_tables", 1)

    #righttekst = "The value of dropdownname_01 = " & @"dropdownname_01"
    #innervarob["righttext"] = righttekst

    firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "basic tables fp")

    #delete old table-data from jsonnode
    when persisttype != persistNot:
      pruneJnodesFromTree(gui_jnob, firstelems_pathsq, getAllUserTables())


    #echo @"All_tables"
    fieldtypesq = getFieldAndTypeList(@"All_tables")
    id_fieldst = fieldtypesq[0][0]
    id_typest = fieldtypesq[0][1]
    fieldvaluesq = fieldtypesq
    #echo id_fieldst



    if @"curaction" == "new table..":
      innervarob["statustext"] = readFromParams("sqlite_master", @["sql"], compString, 
                                          @[["name", @"All_tables"]])[0][0]
      tablechangedbo = true

    echo "~~~~~~~~~~~~~~~"
    addcountit = 0
    # Collect filter-values
    # Reuse the var fieldtypesq and overwrite the second field 'type' for the filter-values
    if not tablechangedbo:   # only in the second pass when stuff has been created
      colcountit = getColumnCount(@"All_tables")
      echo "colcountit: ", colcountit
      for countit in 1..colcountit:
        filternamest = "filter_" & $countit
        if request.params.haskey(filternamest):     # needy for colcount-changes with new table-load
          filtervaluest = request.params[filternamest]

          if filtervaluest.len > 0:
            filtersq.add(["",""])
            filtersq[addcountit][0] = fieldtypesq[countit - 1][0]
            filtersq[addcountit][1] = filtervaluest
            addcountit += 1

            #echo filtersq
            #echo filternamest
            #echo filtervaluesq
            #echo "countit: ", countit
            #echo "addcountit: ", addcountit
            #echo "============"

            # for the filter-value-persistence also needy
          filtervaluesq.add(filtervaluest)


    if @"curaction" in ["saving..", "deleting.."]:
      # Reuse the var fieldvaluesq and overwrite the second field 'type' for the data-values
      colcountit = getColumnCount(@"All_tables")
      for countit in 1..colcountit:
        fieldnamest = "field_" & $countit
        if request.params.haskey(fieldnamest):
          #echo request.params[fieldnamest]
          #echo @fieldnamest

          if countit == 1:
            id_valuest = request.params[fieldnamest]

          # Reuse the var and overwrite the second field 'type' for the values
          fieldvaluesq[countit - 1][1] = request.params[fieldnamest]



    # table loading starts here
    if not tablechangedbo:
      graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                createHtmlTableNodeFromDB(@"All_tables", compSub, filtersq))
    else:
      graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                        createHtmlTableNodeFromDB(@"All_tables"))



    #echo @"radiorecord"
    if @"radiorecord" == "":
      if not tablechangedbo:
        innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables", 
                                                          filtersq = filtervaluesq)
      else:
        innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables")
    else:
      if not tablechangedbo:
        recordsq = readFromParams(@"All_tables", @[], compString, @[[id_fieldst, @"radiorecord"]])
        #echo recordsq
        if len(recordsq) > 0:
          if len(recordsq[0]) > 0:    # the record exist?
            innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables",
                                    @"radiorecord" , recordsq[0], filtervaluesq)
        else:
          innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables",
                                                              filtersq = filtervaluesq)
      else:
        innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables")




    if @"curaction" == "saving..":

      try:
        if len(id_valuest) == 0:    # empty-idfield 
          # must become new record if db-generated
          if getKeyFieldStatus(@"All_tables") == genIntegerByDb:
            #remove the id-field:
            fieldvaluesq.delete(0)
            addNewFromParams(@"All_tables", fieldvaluesq)
          else:
            innervarob["statustext"] = """Cannot save the record because 
              the ID-field has been left empty and the ID-value is not 
              automatically generated for this table."""

        else:   # filled id-field
          if idValueExists(@"All_tables", id_fieldst, id_valuest):
            # record exists allready; perform an update of the values only.
            fieldvaluesq.delete(0)
            updateFromParams(@"All_tables", fieldvaluesq, compString, @[[id_fieldst, id_valuest]])
          else:     # a new record will be entered with the given id-value
            # id-data must be kept in var fieldvaluesq

            addNewFromParams(@"All_tables", fieldvaluesq)


        # requery including the new record
        graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                             createHtmlTableNodeFromDB(@"All_tables", compSub, filtersq))

        innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables", 
                                                          filtersq = filtervaluesq)


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
        graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                             createHtmlTableNodeFromDB(@"All_tables", compSub, filtersq))
        innervarob["table01"] = g_html_json.setTableFromDb(gui_jnob, @"All_tables", 
                                                            filtersq = filtervaluesq)
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
          innervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, gui_jnob)
        elif locationst == "outer":
          outervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, gui_jnob)

    when persisttype != persistNot:
      writeStoredNode(tabidst, gui_jnob)


    resp showPage(innervarob, outervarob)

