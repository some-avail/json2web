#[ 

Generic module and functions to generate html-code 
based on an external gui-def in json-format (project_gui.json)
whereby project is changeable prefix for the current project.

Remark: Do not use hyphenated element-names because they cannot be 
reused in javascript.


ADAP HIS
-jsonize procs
-update procs with onchange-event
-update dropdown with size-attribute


ADAP NOW
 ]#



import tables
import json
from g_json_plus import nil
from datajson_loadjson import nil


var 
  versionfl = 0.5


proc newlang(fromlangst:string):string = 
  # temporary dummy proc
  result = fromlangst



proc setRadioButtons*(jnob: JsonNode, setnamest, value_selectst:string): string = 
  #[ 
  UNIT INFO:
  Generate code for radio-buttons based on an json-gui-def
  for radio-buttons.

  Returns for sample-def:

<input type="radio" id="id_rbut1" name="radio-set-example" onchange="radio-set-example_onchange()" value="rbut1">
<label for="id_rbut1">this is button one</label><br>
<input type="radio" id="id_rbut2" name="radio-set-example" onchange="radio-set-example_onchange()" value="rbut2">
<label for="id_rbut2">this is button two</label><br>
<input type="radio" id="id_rbut3" name="radio-set-example" onchange="radio-set-example_onchange()" value="rbut3" checked>
<label for="id_rbut3">and here nr. 3</label><br>
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
        "\" name=\"" & setnamest & 
#        "\" onchange=\"" & setnamest & "_onchange()" &
        "\" onchange=\"" & setnamest & "_onchange(\'" & valuest & "\')" &
        "\" value=\"" & valuest & "\"" & checkst & ">\p"


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
       "\" name=\"" & boxnamest & "\" value=\"" & boxnamest & "\""  & 
        " onchange=\"" & boxnamest & "_onchange()\"" &
       checkst & ">\p"
    htmlst &= "<label for=\"id_" & boxnamest & "\">" & labelst & "</label><br>\p"

  return htmlst




proc setDropDown*(jnob: JsonNode, dropdownnamest, selected_valuest: string, 
                    sizeit: int):string = 

#[ 
UNIT INFO:
Generate code for a dropdown-control/ select-element,
based on an external json-based gui-def.
In this procedure you can only set one control per call.
The first string-item of the def is dropdownnamest, and you must choose 
a selected value that is to be shown after loading. Lastly with sizeit 
you define the number of visible options in a drop-down list;
that is 1 for normal dropdown, n for an n-sized picklist.

ADAP HIS:
-simplified json-def and the slightly (removed unneedy brackets)


Sample output:
<span ><label for="dropdownname_01">Some label:</label></span>
<select id="dropdownname_01" name="dropdownname_01" size="1" onchange="dropdownname_01_onchange">
<option value="some realvalue">this value is shown</option>
<option value="second realvalue">second value is shown</option>
<option value="third realvalue">third value is shown</option>
</select>
 ]#

  var
    dropdown_list, dropdown_html: string
    valIDst, valuest: string
    namest, labelst: string


  var foundjnob: JsonNode = %*{}
  g_json_plus.getDeepNodeFromKey(dropdownnamest, jnob, foundjnob)


  namest = dropdownnamest
  labelst = newlang(foundjnob["ddlab"].getStr())  # translated
  var valuelistsq = foundjnob["ddvalues"].getElems()   # values not translated for now


  for item in valuelistsq:
    valIDst = item["real-value"].getStr()
    valuest = item["show-value"].getStr()


    if valIDst == selected_valuest:
      dropdown_list &= "<option value=\"" & valIDst & "\" selected>" & valuest & "</option>\p"
    else:
      dropdown_list &= "<option value=\"" & valIDst & "\">" & valuest & "</option>\p"


  dropdown_html = "<span ><label for=\"" & namest & "\">" & labelst & "</label></span>\p"
  # dropdown_html &= "<select id=\"" & namest & "\" name=\"" & namest & "\">\p"
  dropdown_html &= "<select id=\"" & namest & "\" name=\"" & namest & "\" size=\"" & 
                      $sizeit & "\" onchange=\"" & namest & "_onchange()\">\p"
  dropdown_html &= dropdown_list
  dropdown_html &= "</select>\p"


# <span ><label for="dropdownname_01">Some label:</label></span>
# <select id="dropdownname_01" name="dropdownname_01" size="1" onchange="dropdownname_01_onchange">
# <option value="some realvalue">this value is shown</option>
# <option value="second realvalue">second value is shown</option>
# <option value="third realvalue">third value is shown</option>
# </select>

  return dropdown_html




proc setTableBasic*(jnob: JsonNode, tablenamest: string): string = 

#[ 
UNIT INFO:
Generate html-code for a table-element,
based on an external json-based gui-def.


Sample output:
<table>
  <tr>
    <th>head01</th>
    <th>head02</th>
    <th>head03</th>
    <th>head04</th>
  </tr>
  <tr>
    <td>a1</td>
    <td>b1</td>
    <td>c1</td>
    <td>d1</td>
  </tr>
  ...
</table> 
 ]#


  var
    table_htmlst: string = ""
    foundjnob: JsonNode = %*{}
    headersq, datasq, rowsq: seq[JsonNode] = @[]

  g_json_plus.getDeepNodeFromKey(tablenamest, jnob, foundjnob)
  
  # labelst = newlang(foundjnob[0]["ddlab"].getStr())  # translated
#  var valuelistsq = foundjnob[1]["ddvalues"].getElems()   # values not translated for now

  headersq = foundjnob["theader"].getElems()
  table_htmlst = "<table>\n  <tr>\n"

  for item in headersq:
    table_htmlst &= "    <th>" & item.getStr() & "</th>\n"

  table_htmlst &= "  </tr>\n"

  datasq = foundjnob["tdata"].getElems()
  
  for row in datasq:
    rowsq = row.getElems()
    table_htmlst &= "  <tr>\n"
    for item in rowsq:
      # echo item.getStr()
      table_htmlst &= "    <td>" & item.getStr() & "</td>\n"
    table_htmlst &= "  </tr>\n"

  table_htmlst &= "</table>\n"

  result = table_htmlst




proc setTableFromDb*(jnob: JsonNode, tablenamest: string, radiocheckst: string = "",
                              valuesq, filtersq: seq[string] = @[]): string = 

#[ 
UNIT INFO:
Generate html-code for a table-element with input and radio boxes.
Thus enabling crud-ops. Based on an external json-based gui-def, 
on which the data-table is grafted by g_db2json-functions.

ADAP HIS:
- add input boxes
- add radio boxes

ADAP NOW:

Sample output:


 ]#


  var
    table_htmlst: string = ""
    foundjnob: JsonNode = %*{}
    headersq, datasq, rowsq: seq[JsonNode] = @[]
    colcountit, rowcountit: int = 1
    valuest, idst: string


  g_json_plus.getDeepNodeFromKey(tablenamest, jnob, foundjnob)
  
  # labelst = newlang(foundjnob[0]["ddlab"].getStr())  # translated
#  var valuelistsq = foundjnob[1]["ddvalues"].getElems()   # values not translated for now

  headersq = foundjnob["theader"].getElems()
  table_htmlst = "<table>\n  <tr>\n"

  for item in headersq:
    table_htmlst &= "    <th>" & item.getStr() & "</th>\n"

  table_htmlst &= "  </tr>\n"

  # and now the input boxes for data-entry
  table_htmlst &= "  <tr>\n"

  if valuesq != @[]:
    for item in headersq:
      table_htmlst &= "    <td><input class=\"data-input\" name=\"field_" & $colcountit & "\" value=\"" & valuesq[colcountit - 1] & "\"></td>\n"
      colcountit += 1
  else:
    for item in headersq:
      table_htmlst &= "    <td><input class=\"data-input\" name=\"field_" & $colcountit & "\"></td>\n"
      colcountit += 1

  table_htmlst &= "  </tr>\n"

  # and the input boxes for filtering
  colcountit = 1    # resetting
  table_htmlst &= "  <tr>\n"

  if filtersq != @[]:
    for item in headersq:
      table_htmlst &= "    <td><input class=\"filtering\" name=\"filter_" & $colcountit & "\" value=\"" & filtersq[colcountit - 1] & "\"></td>\n"
      colcountit += 1
  else:
    for item in headersq:
      table_htmlst &= "    <td><input class=\"filtering\" name=\"filter_" & $colcountit & "\"></td>\n"
      colcountit += 1

  table_htmlst &= "  </tr>\n"


  datasq = foundjnob["tdata"].getElems()
  
  for row in datasq:
    rowsq = row.getElems()
    table_htmlst &= "  <tr>\n"
    colcountit = 1

    for item in rowsq:
      if colcountit == 1:

        idst = "rbut_" & $rowcountit
        valuest = item.getStr()
        if radiocheckst == valuest:    # make it checked
          table_htmlst &= "    <td><input type=\"radio\" id=\"id_" & idst & 
              "\" name=\"radiorecord\" onchange=\"radiorecord_onchange(\'" & valuest & 
              "\')\" value=\"" & valuest & "\" checked>\p"
        else:
          table_htmlst &= "    <td><input type=\"radio\" id=\"id_" & idst & 
              "\" name=\"radiorecord\" onchange=\"radiorecord_onchange(\'" & valuest &
               "\')\" value=\"" & valuest & "\" >\p"

        table_htmlst &= "    <label for=\"id_" & idst & "\">" & valuest & "</label></td>\p"

      else:
        # echo item.getStr()
        table_htmlst &= "    <td>" & item.getStr() & "</td>\n"
      colcountit += 1

    table_htmlst &= "  </tr>\n"
    rowcountit += 1

  table_htmlst &= "</table>\n"

  result = table_htmlst


proc OLD_setTableFromDb*(jnob: JsonNode, tablenamest: string, radiocheckst: string = "",
                              valuesq: seq[string] = @[]): string = 

#[ 
UNIT INFO:
Generate html-code for a table-element with input and radio boxes.
Thus enabling crud-ops. Based on an external json-based gui-def, 
on which the data-table is grafted by g_db2json-functions.

ADAP HIS:
- add input boxes
- add radio boxes

ADAP NOW:

Sample output:


 ]#


  var
    table_htmlst: string = ""
    foundjnob: JsonNode = %*{}
    headersq, datasq, rowsq: seq[JsonNode] = @[]
    colcountit, rowcountit: int = 1
    valuest, idst: string


  g_json_plus.getDeepNodeFromKey(tablenamest, jnob, foundjnob)
  
  # labelst = newlang(foundjnob[0]["ddlab"].getStr())  # translated
#  var valuelistsq = foundjnob[1]["ddvalues"].getElems()   # values not translated for now

  headersq = foundjnob["theader"].getElems()
  table_htmlst = "<table>\n  <tr>\n"

  for item in headersq:
    table_htmlst &= "    <th>" & item.getStr() & "</th>\n"

  table_htmlst &= "  </tr>\n"

  # and now the input boxes
  table_htmlst &= "  <tr>\n"

  if valuesq != @[]:
    for item in headersq:
      table_htmlst &= "    <td>" & "<input class=\"data-input\" name=\"field_" & $colcountit & "\" value=\"" & valuesq[colcountit - 1] & "\"></td>\n"
      colcountit += 1
  else:
    for item in headersq:
      table_htmlst &= "    <td>" & "<input class=\"data-input\" name=\"field_" & $colcountit & "\"></td>\n"
      colcountit += 1

  table_htmlst &= "  </tr>\n"


  datasq = foundjnob["tdata"].getElems()
  
  for row in datasq:
    rowsq = row.getElems()
    table_htmlst &= "  <tr>\n"
    colcountit = 1

    for item in rowsq:
      if colcountit == 1:

        idst = "rbut_" & $rowcountit
        valuest = item.getStr()
        if radiocheckst == valuest:    # make it checked
          table_htmlst &= "    <td><input type=\"radio\" id=\"id_" & idst & 
              "\" name=\"radiorecord" & 
              "\" onchange=\"radiorecord_onchange(\'" & valuest & "\')" &
              "\" value=\"" & valuest & "\" checked>\p"
        else:
          table_htmlst &= "    <td><input type=\"radio\" id=\"id_" & idst & 
              "\" name=\"radiorecord" & 
              "\" onchange=\"radiorecord_onchange(\'" & valuest & "\')" &
              "\" value=\"" & valuest & "\" >\p"

        table_htmlst &= "    <label for=\"id_" & idst & "\">" & valuest & "</label></td>\p"

      else:
        # echo item.getStr()
        table_htmlst &= "    <td>" & item.getStr() & "</td>\n"
      colcountit += 1

    table_htmlst &= "  </tr>\n"
    rowcountit += 1

  table_htmlst &= "</table>\n"

  result = table_htmlst



proc setDatalist*(jnob: JsonNode, dropdownnamest, selected_valuest: string, 
                    sizeit: int):string = 

#[ 
UNIT INFO:

////UNDER CONSTRUCTION/////ON HOLD///////

Generate code for an input and datalist-element,
based on an external json-based gui-def.
In this procedure you can only set one control per call.


ADAP HIS:

Sample output:

<label for="mylist">Pick an option:</label>
<input  list="options" id="mylist" name="mylist" onchange="mylist_onchange"/>
<datalist id="options">
  <option value="1">This</option>
  <option value="2">That</option>
  <option value="3">Those</option>
</datalist>


Old example of the select-element:
<span ><label for="dropdownname_01">Some label:</label></span>
<select id="dropdownname_01" name="dropdownname_01" size="1" onchange="dropdownname_01_onchange">
<option value="some realvalue">this value is shown</option>
<option value="second realvalue">second value is shown</option>
<option value="third realvalue">third value is shown</option>
</select>
 ]#

  var
    dropdown_list, dropdown_html: string
    valIDst, valuest: string
    namest, labelst: string


  var foundjnob: JsonNode = %*{}
  g_json_plus.getDeepNodeFromKey(dropdownnamest, jnob, foundjnob)


  namest = dropdownnamest
  labelst = newlang(foundjnob["ddlab"].getStr())  # translated
  var valuelistsq = foundjnob["ddvalues"].getElems()   # values not translated for now


  for item in valuelistsq:
    valIDst = item["real-value"].getStr()
    valuest = item["show-value"].getStr()


    if valIDst == selected_valuest:
      dropdown_list &= "<option value=\"" & valIDst & "\" selected>" & valuest & "</option>\p"
    else:
      dropdown_list &= "<option value=\"" & valIDst & "\">" & valuest & "</option>\p"


  dropdown_html = "<span ><label for=\"" & namest & "\">" & labelst & "</label></span>\p"
  # dropdown_html &= "<select id=\"" & namest & "\" name=\"" & namest & "\">\p"
  dropdown_html &= "<select id=\"" & namest & "\" name=\"" & namest & "\" size=\"" & 
                      $sizeit & "\" onchange=\"" & namest & "_onchange()\">\p"
  dropdown_html &= dropdown_list
  dropdown_html &= "</select>\p"


# <span ><label for="dropdownname_01">Some label:</label></span>
# <select id="dropdownname_01" name="dropdownname_01" size="1" onchange="dropdownname_01_onchange">
# <option value="some realvalue">this value is shown</option>
# <option value="second realvalue">second value is shown</option>
# <option value="third realvalue">third value is shown</option>
# </select>

  return dropdown_html





when isMainModule:
  # echo setRadioButtons("orders", "")
  # echo setCheckBoxSet("fr_checkset1", @["default"])
  # echo "---------"
  # echo setDropDown("text-language", "english")
  
  # datajson_loadjson.setGuiJsonNode("datajson")

  # echo setRadioButtons(datajson_loadjson.gui_jnob, "radiosetexample", "")
  # echo setCheckBoxSet(datajson_loadjson.getGuiJsonNode("datajson"), "checksetexample", @["default"])

  echo "============================"
#  echo setDropDown(datajson_loadjson.getGuiJsonNode("datajson"), "dropdownname_01", "second realvalue", 1)

  # echo setRadioButtons(datajson_loadjson.getGuiJsonNode("datajson"), "radiosetexample", "rbut3")

  echo setTableBasic(datajson_loadjson.getGuiJsonNode("datajson"), "table_01")

