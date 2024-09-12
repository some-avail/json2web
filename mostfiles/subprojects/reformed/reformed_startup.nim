

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
See also the module reform_loadjson.nim
Currently --threads :on compiles and runs not succesfully.



ADAP HIS
-change static_config and calls
-refactor the routes

ADAP NOW
]#



import jester, moustachu, times, json, os, tables
#import jolibs/generic/[g_json2html, g_tools, g_cookie]
import g_html_json, g_tools, g_routehelp
import reformed_loadjson, reformed_routeparts
import app_globals


settings:
  port = Port(portnumberit)



routes:

  get "/":
    resp "Type: localhost:" & $portnumberit & "/" & project_prefikst



  get "/reformed":

  # hard code because following does not work:
  # get ("/" & project_prefikst):

    var 
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions

    (innervarob, outervarob) = doGet_Reformed()

    resp showPage(innervarob, outervarob)



  get "/hello":
    resp "Hello world"



  post "/reformed":

    # read in the vars from request.params into control-table cta
    var cta = initTable[string, string]()
    for key, value in request.params:
      cta[$key] = $value

    var 
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions

    (innervarob, outervarob) = doPost_Reformed(cta)


    var cookievaluest: string

    if request.cookies.haskey(project_prefikst & "_run_function"):
      cookievaluest = request.cookies[project_prefikst & "_run_function"]

      (innervarob, outervarob) = doRunFunctionFromClient(cookievaluest, innervarob, outervarob)

    resp showPage(innervarob, outervarob)

