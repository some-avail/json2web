#[ 
  This module contains the functions for the operation of 
  the cookie-tunnel called at the end of proj.startup.nim. 

]#


import tables, strutils, json
from g_html_json import nil


var debugbo: bool = true

template log(messagest: string) =
  # replacement for echo that is only evaluated when debugbo = true
  if debugbo: echo messagest


# template getattr(procst: string): untyped = 
#   module.proc



proc dummyPass(paramst: string): string = 
  result = paramst


proc getFuncParts*(functionpartst: string): OrderedTable[string, string] =
  # parse the function-parts
  # sample: "funcname::g_tools.dummyPass++location::inner++varname:statustext++param1::nieuwe statustekst"
  var 
    funcpartsq, keyvalsq: seq[string]
    functa =  initOrderedTable[string, string]()

  funcpartsq = functionpartst.split("++")
  log($funcpartsq)

  for item in funcpartsq:
    keyvalsq = item.split("::")
    functa[keyvalsq[0]] = keyvalsq[1]
  # log($functa)
  result = functa


proc runFunctionFromClient*(funcPartsta: OrderedTable[string, string], jnob: JsonNode): string = 

  # run the function
  if funcPartsta["funcname"] == "g_tools.dummyPass":
    result = dummyPass(funcPartsta["newcontent"])
  elif funcPartsta["funcname"] == "g_html_json.setDropDown":
    result = g_html_json.setDropDown(jnob, funcPartsta["html-elem-name"], funcPartsta["selected-value"], 
      parseInt(funcPartsta["dd-size"]))
  elif funcPartsta["funcname"] == "g_html_json.setDropDown":
    result = g_html_json.setDropDown(jnob, funcPartsta["html-elem-name"], funcPartsta["selected-value"], 
      parseInt(funcPartsta["dd-size"]))


#func split(s: string; sep: char; maxsplit: int = -1): seq[string] {.....}

proc split2*(st: string, sepst: string, maxsplit: int = -1): seq[string] =
  # As strutils.split, but liberalizing letter-case for the seperator sepst
  # Tested are: WORD, word and Word

  var sepsmallst, sepbigst, sepcapst: string
  
  sepsmallst = sepst.toLowerAscii()
  sepbigst = sepst.toUpperAscii()
  sepcapst = sepsmallst.capitalizeAscii()


  if st.contains(sepst):
    result = split(st, sepst, maxsplit)
  elif st.contains(sepsmallst):
    result = split(st, sepsmallst, maxsplit)
  elif st.contains(sepbigst):
    result = split(st, sepbigst, maxsplit)
  elif st.contains(sepcapst):
    result = split(st, sepcapst, maxsplit)

  

#     "funcname:g_html_json.setDropDown++location:inner++varname:dropdown1++param2:dropdownname_01++param3:third realvalue++param4:1", 60);
# proc setDropDown*(jnob: JsonNode, dropdownnamest, selected_valuest: string, 
#                     sizeit: int):string = 




when isMainModule:
  #var paramst: string = "funcname:g_tools.dummyPass++location:inner++varname:statustext++param1:nieuwe statustekst"
  #echo getFuncParts(paramst)

  # echo getattr("g_tools","dummyPass")("malle pietje")      #transformed into `day1.proc1(input)`

  echo split2("do Select after this", "SELECT")

