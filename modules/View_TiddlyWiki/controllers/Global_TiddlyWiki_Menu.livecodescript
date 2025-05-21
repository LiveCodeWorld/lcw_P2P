script "Global | TiddlyWiki | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | TiddlyWiki | Menu
type: controller
version: 0.4

/*
This is the default menu for a TiddlyWiki view.
*/


--> Variables
-
local LocalArray
constant ReadMePage = "Wikis with Readme"
constant LiveCodePluginTitle = "$:/plugins/LiveCode/wikiscript"

--> Menu | Props
-
getprop menu_Target [tObject]
   # Titles of displayed tiddlyWiki  
   put display_MenuTarget(tObject) into tiddlyView
   if exists (tiddlyView) is false then
      breakpoint
      put tObject into tiddlyView
   end if
   
   -- put the tiddly_ListTitles of tiddlyView into LocalArray ["sTitles"]
   put tiddly_ListShortFiles() into LocalArray ["mFiles"]
   
   return tiddlyView
end menu_Target

-- getprop checked_LiveCodePlugin [tiddlyView]
   return the tiddler_Exists [LiveCodePluginTitle] of tiddlyView
end checked_LiveCodePlugin

getprop menu_CheckTarget [tiddlyView]
   return exists (tiddlyView)
end menu_CheckTarget

getprop openReadme_Params
   put tiddly_OpenReadmeNames() into rNames
   return rNames
end openReadme_Params

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

getprop tiddlyTemplate_Params
   put tiddly_ListShortTemplates() into shortFiles
   filter shortFiles with "*.html"
   return shortFiles
end tiddlyTemplate_Params

getprop checked_ReadmeTiddler [tiddlyView]
   return "ReadMePage" is among the lines of LocalArray ["sTitles"]
end checked_ReadmeTiddler

getprop checked_FullScreen [tiddlyView]
   put the stack_Name of tiddlyView into sName
   return the fullscreen of stack sName
end checked_FullScreen

private on ___
end ___

getprop checked_ShowMenu [tiddlyView]
   put the menubar_View of tiddlyView into mView
   if exists (mView) is false then return false -- bug should not be needed
   --
   put the show_Menu of mView into sBoolean
   return sBoolean
end checked_ShowMenu

getprop goToWiki_Params [tiddlyView]
   return tiddly_OpenWikiMenu()
end goToWiki_Params


--> Global | TiddlyWiki | Menu
-
on menu_OpenGuide
   go to stack "View|Guide"
end menu_OpenGuide

on menu_GoToWiki tiddlyView, stackName
   go to stack stackName
end menu_GoToWiki

on menu_OpenReadme tiddlyView, rName
   put env_ReadmeNameArray() into nameArray
   put nameArray [rName] into tiddlyFile
   --
   display_TiddlyFile tiddlyFile
end menu_OpenReadme

on submenu_TiddlyPlugins
   -- return "Global | TiddlyWiki | Plugins | Menu"
   return the menu_CreateTitle ["Plugins"] of me
end submenu_TiddlyPlugins

private on _
end _

on menu_TiddlyWiki tiddlyView, shortFile
   -- put the browser_File of tiddlyView into htmlFile
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_HtmlFile [shortFile] of tiddlyTemplate into htmlFile
   if there is not a file htmlFile then breakpoint
   --
   if the shiftkey is "Down" then
      display_TiddlyFile htmlFile
   else
      set the browser_File of tiddlyView to htmlFile
      set the stack_Label of tiddlyView to shortFile
   end if
end menu_TiddlyWiki

on menu_TiddlyTemplate tiddlyView, shortFile
   display_TiddlyTemplate shortFile, tiddlyView
end menu_TiddlyTemplate

private on __
end __

on menu_ReadmeTiddler tiddlyView
   put the tiddler_Exists [ReadMePage] of tiddlyView into tExists
   if (tExists is false) OR the shiftKey is "down" then
      put env_ListReadmeNames() into readmeNames
      set the tiddler_Bullets [ReadMePage] of tiddlyView to readmeNames
   end if
   set the show_Tiddler of tiddlyView to ReadMePage
end menu_ReadmeTiddler

on menu_LiveCodePlugin tiddlyView
   set the tiddler_Plugin [LiveCodePluginTitle] of tiddlyView to "WikiScript"
   set the show_Tiddler of tiddlyView to LiveCodePluginTitle
end menu_LiveCodePlugin

private on ____
end ____

on menu_CreateModuleTiddlers tiddlyView
   put the browser_File of tiddlyView into tiddlyFile
   
   -- put the stack_Label of tiddlyView into relModulePath
   put the stack_Name of tiddlyView into moduleLabel
   put label_ToViewName (moduleLabel) into moduleName
   
   if exists (stack moduleName) is false then
      breakpoint
      exit to top
   end if
   
   set the itemdelimiter to slash
   put item 1 to -2 of tiddlyFile & slash into moduleFolder
   if there is not a folder moduleFolder then
      breakpoint
      exit to top
   end if
   
   # Get GuideArray = stackFileArray (for now)
   put the guide_Array of tiddlyView into stackFileArray
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

on menu_CreateProjectTiddlers tiddlyView
   breakpoint
end menu_CreateProjectTiddlers

on menu_CreateToolsPage tiddlyView
   put "Guide Tools" into sTitle
   put markdown_Construct ("Menus,Libraries,See also") into mdText
   --
   set the tiddler_Markdown [sTitle] of tiddlyView to mdText
   set the show_Tiddler of tiddlyView to mdText to sTitle
end menu_CreateToolsPage

private on ______
end ______

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

on menu_Recolour tiddlyView
   set the card_Colour of tiddlyView to "random"
end menu_Recolour

on menu_FullScreen tiddlyView
   put the stack_Name of tiddlyView into sName
   put the fullscreen of stack sName into isFullScreen
   set the fullscreen of stack sName to (isFullScreen is false)
end menu_FullScreen

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

on menu_Refresh tiddlyView
   dispatch "preOpenControl" to tiddlyView
end menu_Refresh

on menu_LoadReadmeData
   tiddly_LoadReadmeData
end menu_LoadReadmeData

on submenu_Dev
   return menu_DevTitle ("Global | TiddlyWiki | Menu")
end submenu_Dev

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
