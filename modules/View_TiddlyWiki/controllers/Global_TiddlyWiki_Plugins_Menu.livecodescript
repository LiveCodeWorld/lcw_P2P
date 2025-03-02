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


--> Global | TiddlyWiki | Plugins | Menu
-
on menu_TiddlyWeb tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://tiddlywiki.com/#GettingStarted", rightView, false
end menu_TiddlyWeb

on menu_TiddlyDev tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://tiddlywiki.com/dev/", rightView, false
end menu_TiddlyDev

private on _
end _

on menu_Kara tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://kookma.github.io/TW-Kara/#", rightView, false
end menu_Kara

on menu_TodoList tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://kookma.github.io/TW-Todolist/#Install", rightView, false
end menu_TodoList

on menu_Projectify tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://thaddeusjiang.github.io/Projectify/demo.html", rightView, false
end menu_Projectify

on menu_RevealJs tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://sukima.github.io/tiddlywiki-reveal-js/", rightView, false
end menu_RevealJs

on menu_TwScripts tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://kookma.github.io/TW-Scripts/"
end menu_TwScripts

on menu_Mermaid tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://efurlanm.github.io/mermaid-tw5/", rightView, false
end menu_Mermaid

on menu_Reveal tiddlyView
   put the right_View of tiddlyView into rightView
   display_TiddlyWiki "https://sukima.github.io/tiddlywiki-reveal-js/", rightView, false
end menu_Reveal

on menu_PluginLibrary tiddlyView
   put the right_View of tiddlyView into rightView
   display_Browser "https://tw-cpl.netlify.app/#Welcome:Index%20Welcome", rightView
end menu_PluginLibrary

private on __
end __

on menu_ChatGpt tiddlyView
   put the right_View of tiddlyView into rightView
   display_Browser "https://chatgpt.com/c/679dc0a9-d4d8-8004-b7f1-e48fa9bb6fa3", rightView
end menu_ChatGpt

on menu_IcoMoon
   put "https://icomoon.io/app/#/select" into someURL
   --
   if the shiftKey is "down" then
      display_Template "View|Browser"
   else
      display_Browser someURL
   end if
end menu_IcoMoon
