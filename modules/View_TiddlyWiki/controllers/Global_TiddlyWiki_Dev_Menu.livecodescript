script "Global | TiddlyWiki | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | TiddlyWiki | Dev | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | TiddlyWiki | Dev | Menu
-
on menu_Recolour tiddlyView
   set the card_Colour of tiddlyView to "random"
end menu_Recolour

on menu_RevealReadme tiddlyView
   put the browser_File of tiddlyView into tiddlyFile
   finder_Reveal tiddlyFile
end menu_RevealReadme

on menu_DraftAbout tiddlyView
   put _GuideName (tiddlyView) into moduleName
   if exists (stack moduleName) is false then
      breakpoint
      exit to top
   end if
   
   put the project_Name of stack moduleName into projectName
   put the project_Folder of stack moduleName into projectFolder
   
   put scaffold_Get ("Guide: About") into mTemplate
   put merge (mTemplate) into aboutText
   --
   set the tiddler_Text ["ProjectName"] of tiddlyView to projectName
   set the tiddler_Text ["About"] of tiddlyView to aboutText
end menu_DraftAbout

on menu_ShowMenu tiddlyView
   put the menubar_View of tiddlyView into mView
   menuBar_ToggleShowMenu mView
end menu_ShowMenu

on menu_LoadReadmeData
   tiddly_InitMenuCache
end menu_LoadReadmeData

/*
on menu_ShowTiddler tiddlyView, sTitle
   if the tiddler_IsShowing [sTitle] of tiddlyView is true then
      set the hide_Tiddler of tiddlyView to sTitle
   else
      set the prepend_Tiddler of tiddlyView to sTitle
   end if
end menu_ShowTiddler

getprop disabled_ShowTiddler [tiddlyView]
   return LocalArray ["sTitles"] is empty
end disabled_ShowTiddler

getprop showTiddler_Param [tiddlyView]
   return the tiddly_StoryTitles of tiddlyView
end showTiddler_Param

getprop showTiddler_Params [tiddlyView]
   return LocalArray ["sTitles"]
end showTiddler_Params

on menu_DeleteTiddler tiddlyView, sTitle
   set the delete_Tiddler of tiddlyView to sTitle
end menu_DeleteTiddler

getprop disabled_ShowTiddler [tiddlyView]
   if LocalArray ["sTitles"] is empty then
      return "delete"
   else
      return false
   end if
end disabled_ShowTiddler

getprop deleteTiddler_Params [tiddlyView]
   return LocalArray ["sTitles"]
end deleteTiddler_Params

*/
private on _
end _

on menu_TiddlerText tiddlyView, tiddlerTitle
   put the tiddler_Text [tiddlerTitle] of tiddlyView into tiddlerText
   --
   display_Text tiddlerText, tiddlerTitle
end menu_TiddlerText

getprop tiddlerText_Params [tiddlyView]
   return LocalArray [sTitles]
end tiddlerText_Params

on menu_TiddlerArray tiddlyView, tiddlerTitle
   put the tiddler_Array [tiddlerTitle] of tiddlyView into tiddlerArray
   --
   display_Data tiddlerArray, tiddlerTitle, "Tiddler Array"
end menu_TiddlerArray

getprop tiddlerArray_Params [tiddlyView]
   return LocalArray [sTitles]
end tiddlerArray_Params

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

private on __
end __

on menu_Notify tiddlyView
   set the tiddly_Notification of tiddlyView to "Hello world" 
end menu_Notify

on menu_TestLoadTemplate tiddlyView
   breakpoint
   display_TiddlyTemplate "empty.html"
   put the result into newView
   
   # tiddly_JSON not working
   -- put the tiddly_JSON of tiddlyView into tiddlyJSON
   -- set the tiddly_JSON of newView to tiddlyJSON
   -- set the tiddly_ImportJSON of newView to tiddlyJSON
   
   put the tiddly_Data of tiddlyView into tiddlyData
   repeat with itemNum = 1 to item 2 of the extents of tiddlyData
      put tiddlyData [itemNum] into tArray
      set the tiddler_Array of newView to tArray
   end repeat
end menu_TestLoadTemplate

on menu_AddBrowserBehavior tiddlyView
   set the module_AddBehavior of tiddlyView to "View|Browser"
   edit the script of bObject
end menu_AddBrowserBehavior

getprop checked_AddBrowserBehavior [tiddlyView]
   get the behavior_StackNames of tiddlyView
   return "behavior_ViewBrowser" is among the lines of it
end checked_AddBrowserBehavior

on menu_EditHtml tiddlyView
   -- file:///Users/david/Documents/git-repos/LiveCodeWorld/lcw_P2P/modules/View_TiddlyWiki/assets/index.html
   put the url of tiddlyView into sURL
   get char 1 to 8 of sURL
   if it is not "file:///" then lcw_AnswerWarning "Not a file..."
   put char 9 to -1 of sURL into htmlFile
   --
   code_EditFile htmlFile
end menu_EditHtml

private on ___
end ___

on menu_RevealViewFolder tiddlyView
   put the module_Folder of tiddlyView into moduleFolder
   finder_Reveal moduleFolder
end menu_RevealViewFolder

on menu_TiddlyHelp tiddlyView
   display_WikiPage "livecode.world", "tiddlywiki"
end menu_TiddlyHelp
