#[ 

Generic module and functions to generate html-code 
based on an external gui-def in json-format (project_gui.json)
whereby project is changeable prefix for the current project.

ADAP HIS


ADAP NOW
-jsonize procs
 ]#


import tables
import webgui_def
# import fr_tools 
import json
from g_json_plus import nil
from g_static_config import nil


var 
  versionfl = 0.2


proc newlang(fromlangst:string):string = 
  # temporary dummy proc
  result = fromlangst



proc setRadioButtons*(jnob: JsonNode, setnamest, value_selectst:string): string = 
  #[ 
  UNIT INFO:
  Generate code for radio-buttons based on an json-gui-def
  for radio-buttons.

  Returns for sample-def:
  <input type="radio" id="id_aap" name="een-naam" value="aap">
  <label for="id_aap">grote aap</label><br>
  <input type="radio" id="id_noot" name="een-naam" value="noot">
  <label for="id_noot">notenboom</label><br>
  <input type="radio" id="id_mies" name="een-naam" value="mies" checked>
  <label for="id_mies">mies-bouwman</label><br>
   ]#


  var foundjnob: JsonNode = %*{}
  g_json_plus.getDeepNodeFromKey(setnamest, jnob, foundjnob)
  var 
    htmlst, valuest, labelst, checkst:string
    selectbo: bool
  htmlst = ""


  # every item in the array is a Jobject
  for item in foundjnob.items:
    valuest = item["name"].getStr()
    labelst = newlang(item["lab"].getStr())
    selectbo = item["selected"].getBool()

    checkst = ""    # reset checkst

    if value_selectst == "":
      if selectbo:
        checkst = " checked"
    else:
      if value_selectst == valuest:
        checkst = " checked"

    htmlst &= "<input type=\"radio\" id=\"id_" & valuest & 
       "\" name=\"" & setnamest & "\" value=\"" & valuest & "\"" & checkst & ">\p"
    htmlst &= "<label for=\"id_" & valuest & "\">" & labelst & "</label><br>\p"

  return htmlst





proc setCheckBoxSet*(jnob: JsonNode, setnamest:string, checked_onesq:seq[string]): string = 
#[ 
UNIT INFO:
Generate code for a set of checkboxes with setnamest,
based on an external gui-def (project_gui.json)
Fill in the checked ones (checked_onesq) with the names 
for checkboxes you want to check,
or fill in "default" to read the default-values from webgui_def.


Returns for sample-def (default):
<input type="checkbox" id="id_aap" name="aap">
<label for="id_aap">grote aap</label><br>
<input type="checkbox" id="id_noot" name="noot" checked>
<label for="id_noot">notenboom</label><br>
<input type="checkbox" id="id_mies" name="mies" checked>
<label for="id_mies">mies-bouwman</label><br>
 ]#


  var foundjnob: JsonNode = %*{}
  g_json_plus.getDeepNodeFromKey(setnamest, jnob, foundjnob)

  var 
    htmlst, boxnamest, labelst, checkst:string
    selectbo: bool

  htmlst = ""

    # every item in the array is a Jobject
  for item in foundjnob.items:
    boxnamest = item["name"].getStr()
    labelst = newlang(item["lab"].getStr())
    selectbo = item["selected"].getBool()

    checkst = ""    # reset checkst

    if checked_onesq.len > 0:
      if "default" in checked_onesq:
        if selectbo:
          checkst = " checked"
      else:
        if boxnamest in checked_onesq:
          checkst = " checked"

    htmlst &= "<input type=\"checkbox\" id=\"id_" & boxnamest & 
       "\" name=\"" & boxnamest & "\" value=\"" & boxnamest & "\""  & checkst & ">\p"
    htmlst &= "<label for=\"id_" & boxnamest & "\">" & labelst & "</label><br>\p"

  return htmlst



proc setDropDown*(jnob: JsonNode, dropdownnamest, selected_valuest: string):string = 

#[ 
UNIT INFO:
Generate code for a dropdown-control/ select-element,
based on an external json-based gui-def.
In this procedure you can only set one control per call.
The first string-item of the def is dropdownnamest, and you must choose 
a selected value that is to be shown after loading.

Sample output:
<span style="font-size:small"><label for="language">Language</label></span>
<select id="language" name="language">
<option value="dutch">Dutch</option>
<option value="english" selected>English</option>
</select>
 ]#

  var
    dropdown_list, dropdown_html: string
    valIDst, valuest: string
    namest, labelst: string


  var foundjnob: JsonNode = %*{}
  g_json_plus.getDeepNodeFromKey(dropdownnamest, jnob, foundjnob)


  namest = dropdownnamest
  labelst = newlang(foundjnob[0]["ddlab"].getStr())  # translated
  var valuelistar = foundjnob[1]["ddvalues"].getElems()   # values not translated for now


  for item in valuelistar:
    valIDst = item["real-value"].getStr()
    valuest = item["show-value"].getStr()


    if valIDst == selected_valuest:
      dropdown_list &= "<option value=\"" & valIDst & "\" selected>" & valuest & "</option>\p"
    else:
      dropdown_list &= "<option value=\"" & valIDst & "\">" & valuest & "</option>\p"


  dropdown_html = "<span ><label for=\"" & namest & "\">" & labelst & "</label></span>\p"
  dropdown_html &= "<select id=\"" & namest & "\" name=\"" & namest & "\">\p"
  dropdown_html &= dropdown_list
  dropdown_html &= "</select>\p"


  # <span style="font-size:small"><label for="language">Language</label></span>
  # <select id="language" name="language">
  # {{{text_language}}}
  # </select>

  return dropdown_html





when isMainModule:
  # echo setRadioButtons("orders", "")
  # echo setCheckBoxSet("fr_checkset1", @["default"])
  # echo "---------"
  # echo setDropDown("text-language", "english")
  
  
  g_static_config.project_prefikst = "controls"
  g_static_config.setGuiJsonNode()

  # echo setRadioButtons(g_static_config.gui_jnob, "radio-set-example", "")
  # echo setCheckBoxSet(g_static_config.gui_jnob, "check-set-example", @["default"])

  echo setDropDown(g_static_config.gui_jnob, "dropdownname_01", "some realvalue")
