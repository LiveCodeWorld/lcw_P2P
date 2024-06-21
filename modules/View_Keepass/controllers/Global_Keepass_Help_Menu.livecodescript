script "Global | Keepass | Help | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Keepass | Help | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the displayed_Object of tObject into keeView
   return keeView
end menu_Target

getprop menu_CheckTarget [keeView]
   return exists (keeView)
end menu_CheckTarget


--> Global | Keepass | Help | Menu
-
on menu_KeepassHelp keeView
   display_WikiPage "localhost", "keepass"
end menu_KeepassHelp

on menu_ModuleHelp keeView
   put the view_Name of keeView into mName
   -- 
   display_WikiPage "module.livecode.world", mName
end menu_ModuleHelp

private on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | Keepass | Help | Menu")
end submenu_Dev
