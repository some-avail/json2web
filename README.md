## Json2web - Web-element-generator

To begin with: Json2web is in mid-phase. Not all web-elements have been added to the json-approach but manually everything is possible of course.

Json2web is for now a component (some nim-modules) to make it easy to create web-controls, like checkboxes. The method to do this is that you start with a json-file in which you create the definition of the needed controls or web-elements, based on a template-json-file. In this template-definition all the possible controls are written, which you can alter or copy to accomodate you gui.

The json-file-technique is usable for databases, because a future loadGuiFromDatebase-module can write data from the database to the json-definition-file, for example to fill a table-element with data. 

This repo makes use of generic files (g_somemodule.nim) and project-specific files (projectprefix_startup.nim). The generic files are used in all the projects. Currently available projects (prefixes) are hello, controls and scricon (scripted controls); so for example you have controls_startup.nim to start the controls-project. Nimwebbie is futurally planned project to create a web-gui-builder. 

It is no longer a pure server-side approach; javascript is used in Scricon. Imported components that are used are jester, moustachu (substitution-engine) and json. The latest testing-project is DataJson, in which database-operations are to be introduced.

People who want to join in are welcome, for example to write a control-generator plus accompanying definition-code.





