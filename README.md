## Json2web - Web-element-generator

To begin with: Json2web is still in starting phase. Only few web-elements have been added.

Json2web is for now a component (some nim-modules) to make it easy to create web-controls, like checkboxes. The method to do this is that you start with a json-file in which you create the definition of the needed controls or web-elements, based on a template-json-file. In this template-definition all the possible controls are written, which you can alter or copy to accomodate you gui.

The json-file-technique is usable for databases, because a future loadGuiFromDatebase-module can write data from the database to the json-definition, for example to fill a table-def with data. 

This repo makes use of generic files (g_somemodule.nim) and project-specific files (projectprefix_startup.nim). The generic files are used in all the projects. Currently available projects (prefixes) are hello, controls and nimwebbie; so for example you have controls_startup.nim to start the controls-project. Nimwebbie is futurally planned project to create a web-gui-builder. When mature it will be moved to another repo with the same name nimwebbie.

For now it is purely a server-side approach; no javascript is used but in the future that will change (of course). Imported components are used are jester, moustachu (substitution-engine) and json.

People who want to join in are welcome, for example to write a control-generator plus accompanying definition-code.





