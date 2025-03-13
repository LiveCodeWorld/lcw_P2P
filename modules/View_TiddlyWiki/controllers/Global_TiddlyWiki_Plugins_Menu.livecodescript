script "Global | TiddlyWiki | Plugins | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | TiddlyWiki | Plugins | Menu
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
   put display_MenuTarget (tObject) into dView
   --
   put the tiddly_View of dView into tiddlyView
   if exists (tiddlyView) then
      return tiddlyView
   else
      put the right_View of dView into rightView
      return rightView
   end if
end menu_Target

private function _dView
   return display_View()
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | TiddlyWiki | Plugins | Menu
-
on menu_TiddlyWeb tiddlyView
   display_TiddlyWiki "https://tiddlywiki.com/#GettingStarted", tiddlyView, false
end menu_TiddlyWeb

on menu_TiddlyDev tiddlyView
   display_TiddlyWiki "https://tiddlywiki.com/dev/", tiddlyView, false
end menu_TiddlyDev

private on _
end _

on menu_Shiraz tiddlyView
   display_TiddlyWiki "https://kookma.github.io/TW-Shiraz/", tiddlyView, false
end menu_Shiraz

on menu_Kara tiddlyView
   display_TiddlyWiki "https://kookma.github.io/TW-Kara/#", tiddlyView, false
end menu_Kara

on menu_TodoList tiddlyView
   display_TiddlyWiki "https://kookma.github.io/TW-Todolist/#Install", tiddlyView, false
end menu_TodoList

on menu_Projectify tiddlyView
   display_TiddlyWiki "https://thaddeusjiang.github.io/Projectify/demo.html", tiddlyView, false
end menu_Projectify

on menu_RevealJs tiddlyView
   display_TiddlyWiki "https://sukima.github.io/tiddlywiki-reveal-js/", tiddlyView, false
end menu_RevealJs

on menu_TwScripts tiddlyView
   display_TiddlyWiki "https://kookma.github.io/TW-Scripts/", tiddlyView, false
end menu_TwScripts

on menu_Mermaid tiddlyView
   display_TiddlyWiki "https://efurlanm.github.io/mermaid-tw5/", rightView, false
end menu_Mermaid

on menu_Reveal tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://sukima.github.io/tiddlywiki-reveal-js/", rightView, false
end menu_Reveal

on menu_PluginLibrary tiddlyView
   put the right_View of tiddlyView into rightView
   display_Browser "https://tw-cpl.netlify.app/#Welcome:Index%20Welcome", rightView, false
end menu_PluginLibrary

on menu_TidsToTable tiddlyView
   display_Browser "https://tids-to-table.tiddlyhost.com/", rightView, false
end menu_TidsToTable

private on __
end __

on menu_ChatGpt.G tiddlyView
   display_Browser "https://chatgpt.com/c/679dc0a9-d4d8-8004-b7f1-e48fa9bb6fa3", rightView, false
end menu_ChatGpt.G

on menu_IcoMoon
   put "https://icomoon.io/app/#/select" into someURL
   --
   if the shiftKey is "down" then
      display_Template "View|Browser"
   else
      display_Browser someURL
   end if
end menu_IcoMoon
