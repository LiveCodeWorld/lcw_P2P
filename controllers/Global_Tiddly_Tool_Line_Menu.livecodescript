script "Global | Tiddly | Tool | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Tiddly | Tool | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   return dView
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private function _ShortFiles dView
   put the selected_Line of dView into wDomain
   put help_ListShortTiddlyFiles (wDomain) into shortFiles
   return shortFiles
end _ShortFiles


--> Global | Tiddly | Tool | Line | Menu
-
on menu_OpenTiddlyWiki dView, shortFile
   put the selected_Line of dView into wDomain
   put help_TiddlyFile (shortFile, wDomain) into tFile
   if there is not a file tFile then
      breakpoint
   end if
   --
   display_TiddlyWikiFile tFile
end menu_OpenTiddlyWiki

getprop openTiddlyWiki_Params [dView]
   return _ShortFiles(dView)
end openTiddlyWiki_Params

getprop disabled_OpenTiddlyWiki [dView]
   return _ShortFiles(dView) is empty
end disabled_OpenTiddlyWiki

on menu_CreateTiddlyWiki dView
   put the selected_Line of dView into wDomain
   --
   put lcw_Ask ("What's the title of the wiki you want to create?", "Some Title", dView) into wTitle
   put title_ToShortFile (wTitle, "html") into shortFile
   put help_TiddlyFile (shortFile, wDomain) into tFile
   -- put label_FromMenuTitle (wTitle) into mLabel
   --
   tiddly_Create tFile
   --
   if item 1 of the result is "Error" then return the result
   --
   display_TiddlyWikiFile tFile, wTitle
end menu_CreateTiddlyWiki

function title_ToShortFile wTitle, pExt
   if pExt is empty then put "html" into pExt
   return wTitle & "." & pExt
end title_ToShortFile

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

on submenu_Dev
   return menu_DevTitle ("Global | Tiddly | Tool | Line | Menu")
end submenu_Dev
