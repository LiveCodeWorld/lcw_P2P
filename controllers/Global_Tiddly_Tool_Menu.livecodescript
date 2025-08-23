script "Global | Tiddly | Tool | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Tiddly | Tool | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   --
   put help_ListTiddlyMenuTitles() into LocalArray ["mTitles"]
   --
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Tiddly | Tool | Menu
-
on menu_MenuHelp dView, mTitle
   if the shiftKey is "Down" then
      # Fix the Sitetitle
      put tiddlyMenu_GetHelp (mTitle) into tHtml
      put label_FromMenuTitle (mTitle) into sitetitle
      tiddlyHtml_SetSiteTitle tHtml, sitetitle
      tiddlyMenu_SetHelp mTitle, tHtml
   end if
   --
   put menuItem_PageArray (mTitle) into pageArray
   --
   draft_WikiPage "localhost", pageArray, true
   
   -- display_Wiki
   -- display_MenuHelp mTitle
end menu_MenuHelp

getprop menuHelp_Params
   return LocalArray ["mTitles"]
end menuHelp_Params

getprop menuItemCurlyData_Params
   return LocalArray ["mTitles"]
end menuItemCurlyData_Params

on menu_MenuItemCurlyData dView, mTitle
   put menuItem_CurlyData (mTitle) into curlyData
   --
   display_Data curlyData, mTitle, "menuItem_CurlyData()"
end menu_MenuItemCurlyData

on menu_RevealMenuHelpFolder
   put help_MenuFolder() into mFolder
   finder_Reveal mFolder
end menu_RevealMenuHelpFolder

private on _
end _

on menu_LiveHelp dView, rName
   if the shiftKey is "Down" then
      display_Readme rName, tiddlyView
   else
      display_Readme rName
   end if
end menu_LiveHelp

getprop liveHelp_Params
   put tiddly_OpenReadmeNames() into rNames
   return rNames
end liveHelp_Params

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Tiddly | Tool | Menu")
end submenu_Dev
