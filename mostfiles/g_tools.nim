

import tables, strutils



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
  # sample: "funcname:g_tools.dummyPass++location:inner++varname:statustext++param1:nieuwe statustekst"
  var 
    funcpartsq, keyvalsq: seq[string]
    functa =  initOrderedTable[string, string]()

  funcpartsq = functionpartst.split("++")
  log($funcpartsq)

  for item in funcpartsq:
    keyvalsq = item.split(":")
    functa[keyvalsq[0]] = keyvalsq[1]
  # log($functa)
  result = functa


proc runFunctionFromClient*(funcPartsta: OrderedTable[string, string]): string = 

  # run the function
  if funcPartsta["funcname"] == "g_tools.dummyPass":
    result = dummyPass(funcPartsta["param1"])




when isMainModule:
  var paramst: string = "funcname:g_tools.dummyPass++location:inner++varname:statustext++param1:nieuwe statustekst"
  echo getFuncParts(paramst)


  # echo getattr("g_tools","dummyPass")("malle pietje")      #transformed into `day1.proc1(input)`

