

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
See also the module g_static_config.nim
Currently --threads :on compiles and runs succesfully.



ADAP HIS
-change static_config and calls

ADAP NOW


]#


import jester, moustachu, times, json, os
from g_static_config import nil
from g_html_json import nil


const 
  versionfl:float = 0.2
  appnamebriefst:string = "CT"
  appnamenormalst = "Controls"
  appnamesuffikst = "Controls-showcase"
  project_prefikst = "controls"


settings:
  port = Port(5160)



proc showPage(par_innervarob, par_outervarob: var Context, 
              custominnerhtmlst:string=""): string = 

  var innerhtmlst:string
  if custominnerhtmlst == "":
    innerhtmlst = render(readFile("controls_inner.html") , par_innervarob)    
  else:
    innerhtmlst = custominnerhtmlst
  par_outervarob["controls-group"] = innerhtmlst

  return render(readFile("controls_outer.html") , par_outervarob)


routes:
  # sleep 1000
  # echo "hai"
  # echo $now()

  get "/":
    # retrieve the json-file

    resp "Type: localhost:5160/controls"

    
  get "/controls":
    var
      statustekst:string
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions
    innervarob["statustext"] = """Basic webserver with some controls generated from 
    a gui-definition-file in json-format. 
    The webserver-interface without cliental javascript has only one button:
    submit your request to the server. Switches (like below) indicate what you want to do."""

    var gui_jnob = g_static_config.getGuiJsonNode(project_prefikst)

    innervarob["newtab"] = "_self"
    outervarob["version"] = $versionfl
    outervarob["loadtime"] ="Page-load: " & $now()
    outervarob["pagetitle"] = appnamenormalst
    outervarob["namesuffix"] = appnamesuffikst
    innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", "")
    innervarob["dropdown2"] = g_html_json.setDropDown(gui_jnob, "dropdownname_02", "")
    innervarob["radiobuttonset1"] = g_html_json.setRadioButtons(gui_jnob, 
                                            "radio-set-example", "")
    innervarob["checkboxset1"] = g_html_json.setCheckBoxSet(gui_jnob, 
                                                "check-set-example", @["default"])

    resp showPage(innervarob, outervarob)


  get "/hello":
    resp "Hello world"


  post "/controls":
    var
      statustekst, righttekst:string
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions

    # g_static_config.project_prefikst = project_prefikst
    # g_static_config.setGuiJsonNode()
    var gui_jnob = g_static_config.getGuiJsonNode(project_prefikst)


    innervarob["newtab"] = "_self"
    outervarob["version"] = $versionfl
    outervarob["loadtime"] ="Page-load: " & $now()
    outervarob["pagetitle"] = appnamenormalst
    outervarob["namesuffix"] = appnamesuffikst

    innervarob["linkcolor"] = "red"

    innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", 
                                                          @"dropdownname_01")
    righttekst = "The value of dropdownname_01 = " & @"dropdownname_01"

    innervarob["dropdown2"] = g_html_json.setDropDown(gui_jnob, "dropdownname_02", 
                                                request.params["dropdownname_02"])

    righttekst = righttekst & "<br>" & "The value of dropdownname_02 = " & @"dropdownname_02"

    innervarob["radiobuttonset1"] = g_html_json.setRadioButtons(gui_jnob, 
                                "radio-set-example", request.params["radio-set-example"])

    # righttekst = righttekst & "<br>" & "The selected radiobutton = " & 
    #                                   request.params["radio-set-example"]
    righttekst = righttekst & "<br>" & "The selected radiobutton = " & @"radio-set-example"


    innervarob["checkboxset1"] = g_html_json.setCheckBoxSet(gui_jnob, 
                                "check-set-example", @[@"check1", @"check2", @"check3"])

    righttekst = righttekst & "<br>" & "The boxes that are checked are: " & 
                                  @"check1" & " " & @"check2" & " " & @"check3"

    innervarob["righttext"] = righttekst

    resp showPage(innervarob, outervarob)

