script "Global | TiddlyWiki | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | TiddlyWiki | Menu
type: controller
version: 0.3

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   # Titles of displayed tiddlyWiki  
   put the displayed_Object [tObject] of tObject into tiddlyView
   if exists (tiddlyView) is false then
      breakpoint
      put tObject into tiddlyView
   end if
   put the tiddly_ListTitles of tiddlyView into LocalArray [sTitles]
   
   # Default asset Files of View|TiddlyWiki Template
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles of tiddlyTemplate into LocalArray ["mFiles"]
   
   return tiddlyView
end menu_Target

getprop menu_CheckTarget [tiddlyView]
   return exists (tiddlyView)
end menu_CheckTarget


--> Global | TiddlyWiki | Menu
-
on menu_LoadGettingStarted tiddlyView
   set the browser_URL of tiddlyView to "https://tiddlywiki.com/#GettingStarted"
end menu_LoadGettingStarted

on menu_TiddlyWiki tiddlyView, shortFile
   -- put the browser_File of tiddlyView into htmlFile
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_HtmlFile [shortFile] of tiddlyTemplate into htmlFile
   if there is not a file htmlFile then breakpoint
   --
   if the shiftkey is "Down" then
      
   else
      set the browser_File of tiddlyView to htmlFile
      --
      set the stack_Label of tiddlyView to shortFile
      -- put the tiddly_Title of tiddlyView
   end if
end menu_TiddlyWiki

getprop tiddlywiki_Param [tiddlyView]
   put the browser_File of tiddlyView into htmlFile
   set the itemdelimiter to slash
   return item -1 of htmlFile
end tiddlywiki_Param

getprop tiddlywiki_Params
   put LocalArray ["mFiles"] into shortFiles
   filter shortFiles with "*.html"
   return shortFiles
end tiddlywiki_Params

private on ____
end ____

on menu_ShowTiddler tiddlyView, sTitle
   if the tiddler_IsShowing [sTitle] of tiddlyView is true then
      set the hide_Tiddler of tiddlyView to sTitle
   else
      set the prepend_Tiddler of tiddlyView to sTitle
   end if
end menu_ShowTiddler

getprop disabled_ShowTiddler [tiddlyView]
   return LocalArray [sTitles] is empty
end disabled_ShowTiddler
   
getprop showTiddler_Param [tiddlyView]
   return the tiddly_StoryTitles of tiddlyView
end showTiddler_Param

getprop showTiddler_Params [tiddlyView]
   return LocalArray [sTitles]
end showTiddler_Params

on menu_DeleteTiddler tiddlyView, sTitle
   set the delete_Tiddler of tiddlyView to sTitle
end menu_DeleteTiddler

getprop disabled_ShowTiddler [tiddlyView]
   if LocalArray [sTitles] is empty then
      return "delete"
   else
      return false
   end if
end disabled_ShowTiddler
   
getprop deleteTiddler_Params [tiddlyView]
   return LocalArray [sTitles]
end deleteTiddler_Params

on menu_DisplayModuleText tiddlyView
   put the tiddler_Text ["Module"] of tiddlyView
end menu_DisplayModuleText

on menu_CreateModuleTiddler tiddlyView
   put the stack_Label of tiddlyView into sLabel
   put word 1 to -2 of sLabel into moduleName
   --
   -- put the project_Array of stack moduleName into projectArray
   --
   put the browser_File of tiddlyView into tiddlyFile
   set the itemdelimiter to slash
   put item 1 to -2 of tiddlyFile & slash into moduleFolder
   if there is not a folder moduleFolder then return empty
   --
   put the module_Array of stack moduleName into moduleArray
   if moduleArray is not an array then
      -- put the module_ConstructArray of stack moduleName into moduleArray
      put module_ConstructArray (moduleFolder) into moduleArray
      breakpoint
      set the module_Array of stack moduleName to moduleArray
   end if
   --
   -- put the stackFile_Array of stack moduleName into stackFileArray
   put moduleArray ["stackFileArray"] into stackFileArray
   
   -- display_Data stackFileArray, moduleName, "Module StackFileArray"
   put keys (stackFileArray) into stackNames
   
   # Set and Display
   -- put markdown_LinkedBullets (stackNames) into moduleStackBullets
   -- put tiddly_Bullets (stackNames) into moduleStackBullets
   -- set the tiddler_Markdown ["Module"] of tiddlyView to moduleStackBullets
   set the tiddler_Bullets ["Module"] of tiddlyView to stackNames
   
   repeat for each key stackName in stackFileArray
      put stackFileArray [stackName] into relPath
      --
      if exists (stack stackName) is false then
         put "Could not locate stack [[" & stackName & "]]." into mdText
         set the tiddler_Markdown [stackName] of tiddlyView to mdText
      else
         put the handlerLine_Index of stack stackName into hIndex
         put replaceText (hIndex, "private on _.*", "---") into hIndex
         --
         tiddly_ReplacePipe stackName
         set the tiddler_Bullets [stackName] of tiddlyView to hIndex
      end if
   end repeat
end menu_CreateModuleTiddler

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

private on ___
end ___

on menu_EditHtml tiddlyView
   -- file:///Users/david/Documents/git-repos/LiveCodeWorld/lcw_P2P/modules/View_TiddlyWiki/assets/index.html
   put the url of tiddlyView into sURL
   get char 1 to 8 of sURL
   if it is not "file:///" then lcw_AnswerWarning "Not a file..."
   put char 9 to -1 of sURL into htmlFile
   --
   code_EditFile htmlFile
end menu_EditHtml

on menu_RevealViewFolder tiddlyView
   put the module_Folder of tiddlyView into moduleFolder
   finder_Reveal moduleFolder
end menu_RevealViewFolder

on menu_DisplayWikiJson tiddlyView
   put the tiddly_JSON of tiddlyView into tiddlerJSON
   --
   display_Json tiddlerJSON, "the tiddly_JSON"
end menu_DisplayWikiJson

on menu_TiddlyHelp tiddlyView
   display_WikiPage "livecode.world", "tiddlywiki"
end menu_TiddlyHelp

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | TiddlyWiki | Menu")
end submenu_Dev
