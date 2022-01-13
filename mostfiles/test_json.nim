#[ For testing json-files on validity. 
  Crashes when file is invalid]#


import json


var filest: string
# filest = "testedit.json"
filest = "controls_gui.json"
# var jnob = parseFile(filest)





proc validateJsonFile(filest: string) =
  try:
    var jsonObject = parseFile(filest)
    echo "============================================================="
    echo "\pTesting file:  ", filest, "\p"
    echo "--------------------------"
    echo jsonObject
    echo "--------------------------"
    echo pretty(jsonObject)
    echo "--------------------------"
    echo " FILE IS A VALID JSON-FILE"
  
  except IOError:
    echo "**************************************"
    echo "\pThe designated file can not be found.\p"
    let errob = getCurrentException()
    echo repr(errob) & "\p****End exception****\p"

  
  except JsonParsingError:
    echo "***************************************"
    echo "\pThe file contains an invalid json-expression.\p"
    let errob = getCurrentException()
    echo repr(errob) & "\p****End exception****\p"

  except:
    let errob = getCurrentException()
    echo "\p******* Unanticipated error ******* \p" 
    echo repr(errob) & "\p****End exception****\p"



when isMainModule:
  validateJsonFile(filest)

