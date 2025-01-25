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
   put "https://tiddlywiki.com/#GettingStarted" into sURL
   if the shiftkey is not "Down" then
      display_TiddlyWiki sURL
   else
      set the browser_URL of tiddlyView to sURL
   end if
end menu_TiddlyWeb

private on _
end _

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

private on __
end __

on menu_IcoMoon
   put "https://icomoon.io/app/#/select" into someURL
   --
   if the shiftKey is "down" then
      display_Template "View|Browser"
   else
      display_Browser someURL
   end if
end menu_IcoMoon
