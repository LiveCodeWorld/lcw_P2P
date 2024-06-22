script "Global | TiddlyWiki | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | TiddlyWiki | Menu
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
   put the displayed_Object of tObject into tiddlyView
   return tiddlyView
end menu_Target

getprop menu_CheckTarget [tiddlyView]
   put the module_ShortHtmlFiles of tiddlyView into LocalArray ["mFiles"]
   return exists (tiddlyView)
end menu_CheckTarget


--> Global | TiddlyWiki | Menu
-
on menu_GettingStarted tiddlyView
   set the browser_URL of tiddlyView to "https://tiddlywiki.com/#GettingStarted"
end menu_GettingStarted

on menu_Tiddlywiki tiddlyView, shortFile
   put the module_HtmlFile [shortFile] of tiddlyView into htmlFile
   --
   if there is a file htmlFile then
      set the browser_File of tiddlyView to htmlFile
   else
      breakpoint
      -- launch htmlFile with "/Applications/Firefox.app"
      -- launch url ("file:///" & htmlFile) with "/Applications/Firefox.app"
   end if
end menu_Tiddlywiki

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

on menu_Behavior tiddlyView
   put the behavior of tiddlyView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | TiddlyWiki | Menu")
end submenu_Dev
