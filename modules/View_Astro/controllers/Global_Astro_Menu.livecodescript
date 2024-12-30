script "Global | Astro | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Astro | Menu
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
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private command _TrashAssets astroView
   put the module_AssetFolder of astroView into assetFolder
   --
   revDeleteFolder assetFolder
   create folder assetFolder
   --
   put display_FindView ("Module Tools", "View|Astro") into dView
   if exists (dView) then
      put the view_Name of dView into moduleName
      display_ModuleTools moduleName
   end if
   --
   return assetFolder
end _TrashAssets


--> Global | Astro | Menu
-
on menu_Astro dView
   put the params
end menu_Astro

private on _
end _

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on menu_InstallBrutal aView
   _TrashAssets aView
   --
   astro_InstallWithXterm aView, "eliancodes/brutal"
end menu_InstallBrutal

on menu_InstallAstro aView
   _TrashAssets aView
   --
   astro_InstallWithXterm aView, "eliancodes/brutal"
end menu_InstallAstro

private on ___
end ___

on menu_TrashAssets sView
   _TrashAssets sView
end menu_TrashAssets

on menu_AstroHelp
   launch url "https://www.one-tab.com/page/BLWFkSpBShGtEDdHDUCOqg"
end menu_AstroHelp

on submenu_Dev
   return menu_DevTitle ("Global | Astro | Menu")
end submenu_Dev
