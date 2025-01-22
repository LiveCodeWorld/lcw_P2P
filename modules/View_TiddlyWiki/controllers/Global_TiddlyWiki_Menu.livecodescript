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
   put _ShortTiddlyFIles() into LocalArray ["mFiles"]
   
   return tiddlyView
end menu_Target

private function _ShortTiddlyTemplates
   # Default asset Files of View|TiddlyWiki Template
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles ["template"] of tiddlyTemplate into tFiles
   return tFiles
end _ShortTiddlyTemplates

private function _ShortTiddlyFIles
   # Default asset Files of View|TiddlyWiki Template
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles of tiddlyTemplate into mFiles
   return mFiles
end _ShortTiddlyFIles

getprop menu_CheckTarget [tiddlyView]
   return exists (tiddlyView)
end menu_CheckTarget


--> Global | TiddlyWiki | Menu
-
on menu_TiddlyWeb tiddlyView
   put "https://tiddlywiki.com/#GettingStarted" into sURL
   if the shiftkey is not "Down" then
      display_TiddlyWiki sURL
   else
      set the browser_URL of tiddlyView to sURL
   end if
end menu_TiddlyWeb

private on _
end _

on menu_TiddlyWiki tiddlyView, shortFile
   -- put the browser_File of tiddlyView into htmlFile
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_HtmlFile [shortFile] of tiddlyTemplate into htmlFile
   if there is not a file htmlFile then breakpoint
   --
   if the shiftkey is "Down" then
      display_TiddlyWiki shortFile
   else
      set the browser_File of tiddlyView to htmlFile
      set the stack_Label of tiddlyView to shortFile
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

on menu_TiddlyTemplate tiddlyView, shortFile
   display_TiddlyTemplate shortFile
end menu_TiddlyTemplate

getprop tiddlyTemplate_Params
   put _ShortTiddlyTemplates() into shortFiles
   filter shortFiles with "*.html"
   return shortFiles
end tiddlyTemplate_Params

private on __
end __

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

private on ___
end ___

on menu_CreateModuleTiddlers tiddlyView
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
   put keys (stackFileArray) into stackNames
   
   # Set and Display
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
end menu_CreateModuleTiddlers

private on ____
end ____

on menu_Launch tiddlyView
   put the browser_URL of tiddlyView into sURL
   if sURL is empty then
      put the browser_File of tiddlyView into sFile
      put browser_AppPath() into appPath
      launch sFile with appPath
      set the clipboardData to sFile
   else
      launch url sURL
      set the clipboardData to sURL
   end if
end menu_Launch

on menu_Kara
   display_TiddlyWiki "https://kookma.github.io/TW-Kara/#"
end menu_Kara

on menu_TodoList
   display_TiddlyWiki "https://kookma.github.io/TW-Todolist/#Install"
end menu_TodoList

on menu_Projectify
   display_TiddlyWiki "https://thaddeusjiang.github.io/Projectify/demo.html"
end menu_Projectify

on menu_TwScripts
   display_TiddlyWiki "https://kookma.github.io/TW-Scripts/"
end menu_TwScripts

on menu_Mermaid
   display_TiddlyWiki "https://efurlanm.github.io/mermaid-tw5/"
end menu_Mermaid

on menu_Reveal
   display_TiddlyWiki "https://sukima.github.io/tiddlywiki-reveal-js/"
end menu_Reveal

private on _____
end _____

on menu_IcoMoon
   put "https://icomoon.io/app/#/select" into someURL
   --
   if the shiftKey is "down" then
      display_Template "View|Browser"
   else
      display_Browser someURL
   end if
end menu_IcoMoon

on menu_Refresh tiddlyView
   dispatch "preOpenControl" to tiddlyView
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | TiddlyWiki | Menu")
end submenu_Dev
