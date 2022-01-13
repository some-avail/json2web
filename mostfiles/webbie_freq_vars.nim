


import moustachu



template useFreqVars*(statementsut: untyped) = 

  var
    statustekst, statusdatast:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions

  statementsut



# useFreqVars:
#   innervarob["newtab"] = "_self"

#   outervarob["version"] = $versionfl
#   # outervarob["loadtime"] = newlang("Server-start: ") & $now()
#   outervarob["loadtime"] ="Server-start: " & $now()
#   outervarob["pagetitle"] = appnamenormalst
#   outervarob["namesuffix"] = appnamesuffikst
#   resp showPage(innervarob, outervarob)
#   