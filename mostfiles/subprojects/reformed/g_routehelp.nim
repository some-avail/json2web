import jester, moustachu, times, json, os, tables
import g_html_json, g_tools
import reformed_loadjson
import app_globals



proc showPage*(par_innervarob, par_outervarob: var Context, 
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



proc vlu*(controlta: var Table[string, string]; keyst: string): string = 
  #[
    Safe lookup of control-value vlu based on control-key keyst
    Look up and return a value in the table and if the key is missing return an empty string
  ]#
  try:
    result = controlta[keyst]
  except:
    result = ""



