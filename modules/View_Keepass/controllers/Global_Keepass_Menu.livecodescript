script "Global | Keepass | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Keepass | Menu
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
   -- put display_MenuTarget (tObject) into keeView
   -- put the display_View of tObject into keeView
   return keeView
end menu_Target

getprop menu_CheckTarget [keeView]
   return exists (keeView)
end menu_CheckTarget


--> Global | Keepass | Menu
-
on menu_Keepass keeView
   -- http://localhost/view/welcome-visitors/view/keepass
   display_WikiPage "localhost", "keepass"
end menu_Keepass

private on _
end _

on menu_EditHtml keeView
   put the module_HtmlFile of keeView into htmlFile
   put the view_Name of keeView into displayTitle
   display_Text htmlFile, displayTitle, "Module Index Html"
end menu_EditHtml

on menu_Save.S keeView
   revIDESaveStack keeView
end menu_Save.S

private on __
end __

on menu_RevealAssets keeView
   put the module_AssetFolder of keeView into assetFolder
   finder_Reveal assetFolder
end menu_RevealAssets

on menu_ModuleTools keeView
   put the view_Name of keeView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

on menu_Refresh keeView
   put the module_HtmlFile of keeView into htmlFile
   set the browser_URL of keeView to htmlFile
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | Keepass | Menu")
end submenu_Dev
