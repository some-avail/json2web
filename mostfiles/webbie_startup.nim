#[ Helper-program for the creation of browser-apps / web-apps 

ADAP HIS
-0.2 
  - make nw gc-safe by removing global vars
-0.2b -   v- try to move repeating vars to a separate module
  with keeping of gc-safety; this failed because all externally
  called vars are seen as globals (compiler didnt buy it).
  To avoid dragging those vars along i tried also:
    -templating - didnt compile
    -include - didnt compile either; wouldnot expect eval.


ADAP NOW
-0.3
]#


import jester
import moustachu
import times



const 
  versionfl:float = 0.3
  appnamebriefst:string = "NW"
  appnamenormalst = "NimWebbie"
  appnamesuffikst = "Web-app-helper"


settings:
  port = Port(5150)



proc showPage(par_innervarob, par_outervarob: var Context, 
              custominnerhtmlst:string=""): string = 

  var innerhtmlst:string
  if custominnerhtmlst == "":
    innerhtmlst = render(readFile("webbie_inner.html") , par_innervarob)    
  else:
    innerhtmlst = custominnerhtmlst
  par_outervarob["nimwebbie"] = innerhtmlst

  return render(readFile("webbie_outer.html") , par_outervarob)



routes:
  get "/":
    var
      statustekst, statusdatast:string
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions

    # innervarob["statustext"] = ""
    # innervarob["statusdata"] = ""
    innervarob["newtab"] = "_self"

    outervarob["version"] = $versionfl
    # outervarob["loadtime"] = newlang("Server-start: ") & $now()
    outervarob["loadtime"] ="Server-start: " & $now()
    outervarob["pagetitle"] = appnamenormalst
    outervarob["namesuffix"] = appnamesuffikst
    resp showPage(innervarob, outervarob)

  get "/hello":
    resp "Hello world"

  post "/nimwebbie":
    var
      statustekst, statusdatast:string
      innervarob: Context = newContext()  # inner html insertions
      outervarob: Context = newContext()   # outer html insertions

    # innervarob["statustext"] = ""
    # innervarob["statusdata"] = ""
    innervarob["newtab"] = "_self"

    outervarob["version"] = $versionfl
    # outervarob["loadtime"] = newlang("Server-start: ") & $now()
    outervarob["loadtime"] ="Server-start: " & $now()
    outervarob["pagetitle"] = appnamenormalst
    outervarob["namesuffix"] = appnamesuffikst

    innervarob["linkcolor"] = "red"
    resp showPage(innervarob, outervarob)

