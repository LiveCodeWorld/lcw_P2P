script "Global | TiddlyWiki | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | TiddlyWiki | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put tObject into tiddlyView
   -- put the displayed_Object of tObject into tiddlyView
   --
   put the tiddly_ListTitles of tiddlyView into LocalArray [sTitles]
   --
   return tObject
end menu_Target

getprop menu_CheckTarget [tiddlyView]
   put the module_ShortHtmlFiles of tiddlyView into LocalArray ["mFiles"]
   return exists (tiddlyView)
end menu_CheckTarget


--> Global | TiddlyWiki | Menu
-
on menu_LoadGettingStarted tiddlyView
   set the browser_URL of tiddlyView to "https://tiddlywiki.com/#GettingStarted"
end menu_LoadGettingStarted

on menu_ShowTiddler tiddlyView, sTitle
   if the tiddler_IsShowing [sTitle] of tiddlyView is true then
      set the hide_Tiddler of tiddlyView to sTitle
   else
      set the prepend_Tiddler of tiddlyView to sTitle
   end if
end menu_ShowTiddler

getprop showTiddler_Param [tiddlyView]
   return the tiddly_StoryTitles of tiddlyView
end showTiddler_Param

getprop showTiddler_Params [tiddlyView]
   return LocalArray [sTitles]
end showTiddler_Params

on menu_DeleteTiddler tiddlyView, sTitle
   set the delete_Tiddler of tiddlyView to sTitle
end menu_DeleteTiddler

getprop deleteTiddler_Params [tiddlyView]
   return LocalArray [sTitles]
end deleteTiddler_Params

on menu_Tiddlywiki tiddlyView, shortFile
   put the module_HtmlFile [shortFile] of tiddlyView into htmlFile
   if there is not a file htmlFile then breakpoint
   --
   set the browser_File of tiddlyView to htmlFile
end menu_Tiddlywiki

on menu_EditHtml tiddlyView
   -- file:///Users/david/Documents/git-repos/LiveCodeWorld/lcw_P2P/modules/View_TiddlyWiki/assets/index.html
   put the url of tiddlyView into sURL
   get char 1 to 8 of sURL
   if it is not "file:///" then lcw_AnswerWarning "Not a file..."
   put char 9 to -1 of sURL into htmlFile
   --
   code_OpenFile htmlFile
end menu_EditHtml

getprop tiddlywiki_Params
   put LocalArray ["mFiles"] into shortFiles
   return shortFiles
end tiddlywiki_Params

on menu_TiddlyHelp tiddlyView
   display_WikiPage "livecode.world", "tiddlywiki"
end menu_TiddlyHelp

private on _
end _

on menu_AddBrowserBehavior tiddlyView
   set the module_AddBehavior of tiddlyView to "View|Browser"
   edit the script of bObject
end menu_AddBrowserBehavior

getprop checked_AddBrowserBehavior [tiddlyView]
   get the behavior_StackNames of tiddlyView
   return "behavior_ViewBrowser" is among the lines of it
end checked_AddBrowserBehavior

private on __
end __

on menu_ExportWikJson tiddlyView
   put the tiddly_Data of tiddlyView into tiddlerData
   --
   
end menu_ExportWikJson

on menu_DisplayTiddlyData tiddlyView, sTag
   if sTag = "All" then
      put the tiddly_Data of tiddlyView into tiddlerData
   else
      put the tiddly_Data [sTag] of tiddlyView into tiddlerData
   end if
   --
   display_Data tiddlerData, "the tiddly_Data", "Tiddly Wiki"
end menu_DisplayTiddlyData

getprop displayTiddlyData_Params [tiddlyView]
   return the tiddly_Tags of tiddlyView & ",-,All"
end displayTiddlyData_Params

private on ___
end ___

on menu_RevealViewFolder tiddlyView
   put the module_Folder of tiddlyView into moduleFolder
   finder_Reveal moduleFolder
end menu_RevealViewFolder

on menu_Behavior tiddlyView
   put the behavior of tiddlyView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools tiddlyView
   put the view_Name of tiddlyView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | TiddlyWiki | Menu")
end submenu_Dev
