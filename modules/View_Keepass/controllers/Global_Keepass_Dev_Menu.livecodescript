script "Global | Keepass | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Keepass | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the displayed_Object of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Keepass | Dev | Menu
-
on menu_Import dView
   put the module_AssetFolder of dView into dPath
   answer file "Choose a file..." with dPath as sheet
   put it
end menu_Import

private on _
end _

on menu_Reveal dView
   put the module_AssetFolder of dView into aFolder
   finder_Reveal aFolder
end menu_Reveal
