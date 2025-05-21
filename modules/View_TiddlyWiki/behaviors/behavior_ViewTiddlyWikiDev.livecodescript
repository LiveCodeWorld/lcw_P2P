script "behavior_ViewTiddlyWikiDev" with behavior "behavior_ViewTiddlyWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTiddlyWikiDev
type: behavior
version: 0.1


/*
This is the behavior for a browser widget that is customised to host a TiddlyWiki file.
*/

local LocalArray
constant NotificationTemplate = "$:/temp/NotificationTemplate"


--> Init | Fancy
-
command init_Titles
   set the itemdelimiter to slash
   put the browser_File of me into tiddlyFile
   put item -1 of tiddlyFile into shortFile
   switch
      case tiddlyFile is empty
         # Not a file (url or empty)
         -- set the stack_Label of me to the url of me
         break
      case there is a file tiddlyFile
      case shortFile = "README.html"
         put item -5 to -1 of tiddlyFile into relPath
         set the stack_Label of me to relPath
         --
         put the tiddly_Label of me into tiddlyLabel
         set the tiddly_SubTitle of me to tiddlyLabel
         break
      default
         put the browser_URL of me into tiddlyURL
         set the tiddly_Notification of me to "No browser_File:" && tiddlyFile
   end switch
end init_Titles

command init_Menus
   put the long id of me into tiddlyView
   tiddly_InstallGuideTools tiddlyView
   -- send "tiddly_InstallGuideTools" to me in 2 ticks
   -- dispatch "tiddly_InstallGuideTools" with tiddlyView
end init_Menus

command tiddly_InstallGuideTools tiddlyView, pAppend   
   set the cursor to watch
   put pAppend is not false into pAppend
   put the menuBar_View of tiddlyView into mGroup
   
   # Get section "Menus" of tiddler "Guide Tools"
   put the tiddler_Text ["Guide Tools"] of tiddlyView into mdText
   put markdown_GetSection (mdText, "Menus") into mSection
   if mSection is empty then return empty
   
   # Filter for linked bullets
   -- filter lines of mSection with "- *" into mLines
   put "- \[\[(.+)\]\]" into rPattern
   filter lines of mSection with regex pattern rPattern into mLines
   
   # Construct 
   repeat for each line mLine in mLines
      if matchText (mLine, rPattern, mLabel) then
         if mLabel is among the items of "Edit,Exists,File,Tools,Help" then
            put merge ("Global | Menu | Group | [[mLabel]] | Menu") into mTitle
         else
            put label_ToMenuTitle (mLabel) into mTitle
         end if
         put mTitle & CR after mTitles
      end if
   end repeat
   delete char -1 of mTitles
   
   # Set menubar
   set the menubar_Titles [pAppend] of mGroup to mTitles
   -- set the menubar_Table [pAppend] of mGroup to mTable
   -- put menubar_TableFromNames (mLines) into mTitles
   
   return mLabels
end tiddly_InstallGuideTools


--> Tiddly | Javascript
-
function menubar_TableFromNames mNames, pForceFirst
   replace comma with CR in mNames
   set the itemdelimiter to "|"
   
   put 1 into btnNum
   if pForceFirst is true then
      # Rewrite first mName/mTitle
      put the module_MenuTitle of me into mTitle
      put word 1 to -1 of item -2 of mTitle into mName
      -- put line 1 of mNames into mName
      put mName & ":" && mTitle & CR into mTable
      delete line 1 of mNames
      add 1 to btnNum
   end if
   
   repeat for each line mLabel in mNames
      put label_ToMenuTitle (mLabel) into mLine
      put mLine & CR after mTable
      add 1 to btnNum
   end repeat
   delete char -1 of mTable
   return mTable
end menubar_TableFromNames

command guide_Go sUrl
   put item 3 to -1 of sUrl into guideName
   if exists (stack guideName) then
      go to stack guideName
   else
      put the long id of the target into dView
      lcw_Answer "Launch guide '[[guideName]]'?", dView, guideName
   end if
end guide_Go


--> Working on
-
setprop tiddler_Plugin [pluginTitle] scaffoldName
   -- experimental use by menu_LiveCodePlugin
   if pluginTitle is empty then put the ticks into pluginTitle
   
   put scaffold_Get (scaffoldName) into tiddlerJavascript
   -- set the tiddler_Text [pluginTitle] of me to tiddlerJavascript
   -- return the result
   
   put tiddler_GetPluginJavascript (scaffoldName, pluginTitle) into sJavascript
   do sJavascript in me
   put the result into sResult
   return sResult
end tiddler_Plugin

function tiddler_GetPluginJavascript scaffoldName, pluginTitle
   # Get javascript template
   put scaffold_Get (scaffoldName) into tiddlerJavascript
   tw_Normalize tiddlerJavascript
   -- put "hello" into tiddlerJavascript
   
   set the tiddler_Text [pluginTitle] of tiddlyView to "WikiScript"
   
   # Send the content with actual newlines directly (no escaping)
   -- && "fields: {'module-type': 'widget'}," \
   -- && "type: 'application/javascript'," \
   
   get "$tw.wiki.addTiddler(new $tw.Tiddler({" \
         & "title: '[[pluginTitle]]'," \
         && "text: `" & tiddlerJavascript \
         & "`}));"
   return merge (it)
   
   /*
   # Update the tiddler to be a JavaScript tiddler with custom fields
   get"var tiddler = new $tw.Tiddler({title: '[[pTitle]]', text: '" \
         & tiddlerJavascript \
         & "', type: 'application/javascript', fields: {'module-type': 'widget'}});"
   & "$tw.wiki.addTiddler(tiddler);"
   put merge (it) into sJavascript
   */
end tiddler_GetPluginJavascript

on tiddly_FixBehavior
   # Fix behavior (widgets lose behavior bug)
   put "behavior_ViewTiddlyWiki" into bName
   if exists (stack bName) is false then
      breakpoint
      return "Error, cannot locate stack:" && bName
   end if
   put the name of stack bName into bObject
   set the behavior of me to bObject
   return bObject
end tiddly_FixBehavior


--> Tiddly | Title
-
getprop test_Behavior
   -- let's check this behavior is attached (checked on openStack)
   return true
end test_Behavior


--> JS
-
getprop js_Result
   return LocalArray ["sResult"]
end js_Result

setprop js_Result sResult
   javascript_Result sResult
end js_Result


--> Tiddler | Array
-
setprop tiddler_ContentArray cArray
   put tiddler_JavascriptFromArray(cArray) into sJavascript
   do sJavascript in me
   -- put the result into sResult -- does nothing
   return sJavascript
end tiddler_ContentArray

function tiddler_JavascriptFromArray cArray
   put cArray ["title"] into sTitle
   if sTitle is empty then put the ticks into sTitle
   put cArray ["text"] into sContent
   
   switch cArray ["type"]
      case "meramid"
         put "text/vnd.tiddlywiki.mermaid" into cType
         break
      case "markdown"
         put "text/markdown" into cType
         break
      case "html"
         put "text/html" into cType
         break
      case "text"
         put "text/plain" into cType
         break
      case "svg"
         put "image/svg+xml" into cType
         break
      case "png"
         put "image/png" into cType
         break
      case "jpeg"
         put "image/jpeg" into cType
         break
      case "ICO"
      case "icon"
         put "image/image/x-icon" into cType
         break
      case "gif"
         put "image/gif" into cType
         break
      case "json"
         put "application/json" into cType
         break
      case "dictionary"
         put "application/x-tiddler-dictionary" into cType
         break
      case "javascript"
         put "application/javascript" into cType
         break
      case "stylesheet"
      case "css"
         put "text/css" into cType
         break
      case "TiddlyWiki"
      default
         put "text/vnd.tiddlywiki" into cType
   end switch
   
   # Construct javascript
   get merge ("$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[sTitle]]', text: `" & sContent & "`, type: '[[cType]]'}));")
   return it
end tiddler_JavascriptFromArray


--> Events | Unhandled
-
setprop tiddly_ImportJSON exportedTiddlyJSON
   -- Ensure the input JSON is valid and not empty
   if exportedTiddlyJSON is empty then
      answer "Error: No JSON data provided."
      exit to top
   end if
   
   -- JavaScript to trigger TiddlyWiki's import tiddler UI with the JSON data
   put "try {" & \
         "var jsonBlob = new Blob([`" & exportedTiddlyJSON & "`], {type: 'application/json'});" & \
         "var jsonFile = new File([jsonBlob], 'imported-tiddlers.json');" & \
         "$tw.wiki.importTiddlers([jsonFile]);" & \
         "$tw.rootWidget.dispatchEvent({type: 'tm-import-tiddlers'});" & \
         "liveCode.javascript_Result('Success');" & \
         "} catch(e) { liveCode.javascript_Result('Error: ' + e.message); }" into sJavascript
   
   -- Execute the JavaScript and catch results
   set the javascriptHandlers of widget "YourBrowserWidget" to "javascript_Result"
   do sJavascript in widget "YourBrowserWidget"
   put the result into sResult
   return sResult
end tiddly_ImportJSON


--> Browser
-
setprop browser_Navigate whichDirection
   switch whichDirection
      case "first"
         -- Navigate to the first entry in the browser's history stack
         put "while (window.history.length > 1) { window.history.back(); }" into sJavascript
         break
      case "back"
         -- Navigate backward in the browser widget
         put "window.history.back();" into sJavascript
         break
      case "forward"
         -- Navigate forward in the browser widget
         put "window.history.forward();" into sJavascript
         break
      case "reload"
      default
         -- Reload the current page in the browser widget
         put "window.location.reload();" into sJavascript
   end switch
   --
   do sJavascript in me
   return the result
end browser_Navigate


--> Private
-
private command _NormalizeEntities @pContent --not used?
   -- Escape problematic characters with HTML entities
   replace "\" with "&#x22;" in pContent
   replace "'" with "&#x27;" in pContent
   replace "\\" with "&#x5C;" in pContent
   replace "/" with "&#x2F;" in pContent
   replace "[" with "&#x5B;" in pContent
   replace "]" with "&#x5D;" in pContent
   replace "{" with "&#x7B;" in pContent
   replace "}" with "&#x7D;" in pContent
   
   -- replace CR with "&#xA;" in pContent
   -- replace CR with "&#xD;" in pContent
   -- replace CR with "<br>" in pContent
   -- replace CR with "<p>" in pContent
end _NormalizeEntities


--> Deps
-
