script "behavior_ViewTiddlyWiki" with behavior "behavior_ViewBrowser"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTiddlyWiki
type: behavior
version: 0.3

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/

local LocalArray


--> Working on
-


--> Events | Unhandled
-
on browserUnhandledLoadRequest pUrl
   -- blob:null/fd81c341-358f-4c77-b2cd-ace3d7b09eea
   -- also get sent with "Export Tiddler"
   put the long id of me into tidddlyView
   --
   tiddlyWiki_ExportHtml tidddlyView
   tiddlyWiki_ExportJson tidddlyView
   return tiddlerHTML
end browserUnhandledLoadRequest

command tiddlyWiki_ExportHtml tidddlyView, pShortFile
   if pShortFile is empty then
      put "test.html" into pShortFile
   end if
   put the tiddlyWiki_HTML of me into tHTML
   --
   put the browser_File of tidddlyView into htmlFile
   set the itemdelimiter to slash
   put pShortFile into item -1 of htmlFile
   --
   text_Set htmlFile, tHTML
   return htmlFile
end tiddlyWiki_ExportHtml

command tiddlyWiki_ExportJson tidddlyView, pShortFile
   if pShortFile is empty then
      put "test.json" into pShortFile
   end if
   put the tiddlyWiki_JSON of tidddlyView into tJSON
   --
   put the browser_File of tidddlyView into jsonFile
   set the itemdelimiter to slash
   put pShortFile into item -1 of jsonFile
   --
   text_Set jsonFile, tJSON
   return jsonFile
end tiddlyWiki_ExportJson


--> Tiddler
-
getprop tiddler_Text [pTiddlerTitle]
   put merge("$tw.wiki.getTiddlerText('[[pTiddlerTitle]]')") into sJavascript
   put merge("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   return jsResult
end tiddler_Text

setprop tiddler_Text [pTitle] sContent
   if pTitle is empty then put the ticks into pTitle
   tiddler_Normalise sContent
   --
   get merge ("$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[pTitle]]', text: '[[sContent]]'}));")
   do it in me
   put the result into sResult
   return sResult
end tiddler_Text

getprop tiddler_IsShowing [sTiddler]
   get the tiddly_StoryTitles of me
   return sTiddler is among the lines of it
end tiddler_IsShowing

setprop hide_Tiddler pTitle
   -- JavaScript to remove the tiddler from $:/StoryList
   put "var storyList = $tw.wiki.getTiddlerList('$:/StoryList');" & \
         "var index = storyList.indexOf('" & pTitle & "');" & \
         "if (index > -1) {" & \
         "    storyList.splice(index, 1);" & \
         "    var modificationFields = $tw.wiki.getModificationFields();" & \
         "    $tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: storyList}, modificationFields);" & \
         "}" into sJavascript
   
   -- Execute the JavaScript in the browser widget
   do sJavascript in me
   return the result
end hide_Tiddler

setprop show_Tiddler pTitle
   -- JavaScript to update $:/StoryList and display the tiddler
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: ['" & pTitle & "']}, modificationFields);" into sJavascript
   
   -- Execute the JavaScript in the browser widget
   do sJavascript in me
   return the result
end show_Tiddler

-- setprop show_Tiddler pTitle
-- JavaScript to update $:/StoryList and display the tiddler
put "var modificationFields = $tw.wiki.getModificationFields();" & \
      "$tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: ['" & pTitle & "']}, modificationFields);" into sJavascript

-- Execute the JavaScript in the browser widget
do sJavascript in me
put the result into jResult
return jResult
end show_Tiddler

setprop show_Tiddlers pTitles
   -- Convert the comma-separated list into a JavaScript array
   put "[" & quote & replaceText(pTitles, ",", quote & "," & quote) & quote & "]" into tList
   
   -- JavaScript to update $:/StoryList with the list of tiddlers
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: " & tList & "}, modificationFields);" into sJavascript
   
   -- Execute the JavaScript in the browser widget
   do sJavascript in me
   put the result into jResult
   return jResult
end show_Tiddlers

-- setprop open_Tiddler pTitle
put "liveCode.javascript_Result($tw.rootWidget.dispatchEvent({type: 'tm-navigate', navigateTo: '" & pTitle & "'}));" into sJavascript
do sJavascript in me
return the result
end open_Tiddler


--> Tiddler
-
getprop tiddly_Tags
   -- JavaScript to filter and list all unique user-defined tags
   put "$tw.wiki.filterTiddlers('[all[tiddlers]!is[system]tags[]!duplicates[]sort[]]').join(';')" into sJavascript
   --
   put merge("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   --
   replace ";" with CR in jsResult
   return jsResult
end tiddly_Tags

getprop tiddly_Titles
   put "$tw.wiki.filterTiddlers('[all[tiddlers]]').join(';')" into sJavascript
   --
   put merge ("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put _GetJavascriptResult (livecodeJavascript) into jsResult
   --
   replace ";" with CR in jsResult
   return jsResult
end tiddly_Titles

getprop tiddly_ListTitles [sTag]
   if sTag is empty then
      -- JavaScript to filter and list all user-created tiddlers
      put "liveCode.javascript_Result(" & \
            "$tw.wiki.filterTiddlers('[!is[system]sort[title]]').join(';'));" into sJavascript
   else
      -- JavaScript to filter tiddlers by the specified tag
      put "liveCode.javascript_Result(" & \
            "$tw.wiki.filterTiddlers('[tag[" & sTag & "]!is[system]sort[title]]').join(';'));" into sJavascript
   end if
   
   -- Execute the JavaScript and get the result
   put _GetJavascriptResult(sJavascript) into tSerialized
   
   -- Replace semicolons with commas for a cleaner LiveCode list
   replace ";" with CR in tSerialized
   
   -- Return the serialized list of tagged tiddlers
   return tSerialized
end tiddly_ListTitles

getprop tiddly_StoryTitles
   -- JavaScript to get the story list
   put "$tw.wiki.getTiddlerList('$:/StoryList').join(';')" into tiddlyBit
   
   -- Wrap in JavaScript for LiveCode execution
   put "liveCode.javascript_Result(" & tiddlyBit & ");" into sJavascript
   
   -- Execute the JavaScript and get the result
   put _GetJavascriptResult(sJavascript) into tSerialized
   
   -- Replace semicolons with commas for a cleaner LiveCode list
   replace ";" with CR in tSerialized
   
   -- Return the serialized story list
   return tSerialized
end tiddly_StoryTitles

getprop tiddly_Data [sTag]
   put the tiddly_JSON [sTag] of me into tJSON
   put jsonImport (tJSON) into tData
   -- put json_ToArray (tJSON) into tData
   return tData
end tiddly_Data

getprop tiddly_JSON [sTag]
   if sTag is empty then
      -- JavaScript to get user-authored tiddlers as JSON
      put "liveCode.javascript_Result(JSON.stringify($tw.wiki.filterTiddlers('[!is[system]]').map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   else
      -- JavaScript to get user-authored tiddlers with a specific tag
      put "liveCode.javascript_Result(JSON.stringify($tw.wiki.filterTiddlers('[tag[" & sTag & "]]').map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   end if
   
   -- Execute JavaScript and retrieve the result
   put _GetJavascriptResult(sJavascript) into tSerialized
   
   -- Return the serialized user content
   return tSerialized
end tiddly_JSON

getprop tiddly_JSON
   -- JavaScript to fetch user-created tiddlers with fields
   put "liveCode.javascript_Result(" & \
         "JSON.stringify($tw.wiki.filterTiddlers('[!is[system]]').map(function(title) {" & \
         "var t = $tw.wiki.getTiddler(title);" & \
         "return t ? t.fields : null;" & \
         "}).filter(Boolean)));" into sJavascript
   
   -- Execute JavaScript and get the result
   put _GetJavascriptResult(sJavascript) into jsResult
   
   -- Parse JSON result if necessary
   return jsResult
end tiddly_JSON

setprop prepend_Tiddler pTitle
   -- JavaScript to prepend the tiddler to the existing $:/StoryList
   put "var storyList = $tw.wiki.getTiddlerList('$:/StoryList');" & \
         "if (!storyList.includes('" & pTitle & "')) {" & \
         "    storyList.unshift('" & pTitle & "');" & \
         "    var modificationFields = $tw.wiki.getModificationFields();" & \
         "    $tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: storyList}, modificationFields);" & \
         "}" into sJavascript
   
   -- Execute the JavaScript in the browser widget
   do sJavascript in me
   put the result into jResult
   return jResult
end prepend_Tiddler

setprop append_Tiddler pTitle
   -- JavaScript to append the tiddler to the existing $:/StoryList
   put "var storyList = $tw.wiki.getTiddlerList('$:/StoryList');" & \
         "if (!storyList.includes('" & pTitle & "')) {" & \
         "    storyList.push('" & pTitle & "');" & \
         "    var modificationFields = $tw.wiki.getModificationFields();" & \
         "    $tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: storyList}, modificationFields);" & \
         "}" into sJavascript
   
   -- Execute the JavaScript in the browser widget
   do sJavascript in me
   put the result into jResult
   return jResult
end append_Tiddler

setprop delete_Tiddler tiddlerTitle
   tiddler_NormaliseTitle tiddlerTitle
   get "$tw.wiki.deleteTiddler('" & tiddlerTitle & "');"
   do it in me
end delete_Tiddler


--> Events
-
getprop tiddlyWiki_HTML
   -- JavaScript to generate the full HTML of the wiki
   put "liveCode.javascript_Result($tw.wiki.renderTiddler('text/plain', '$:/core/save/all'));" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return word 1 to -1 of tSerialized
end tiddlyWiki_HTML

getprop tiddlyWiki_HTML
   -- JavaScript to get the entire HTML of the wiki
   put "liveCode.javascript_Result(document.documentElement.outerHTML);" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddlyWiki_HTML

getprop tiddlyWiki_JSON
   -- JavaScript to get all tiddlers as JSON
   put "liveCode.javascript_Result(JSON.stringify($tw.wiki.allTitles().map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddlyWiki_JSON

getprop tiddler_Exists [tiddlerTitle]
   put merge("liveCode.javascript_Result($tw.wiki.tiddlerExists('[[tiddlerTitle]]'));") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   return jsResult is "true"
end tiddler_Exists

command tiddler_Normalise @pContent
   -- replace CR with "&#xA;" in pContent
   -- replace CR with "&#xD;" in pContent
   -- replace CR with "<br>" in pContent
   replace CR with "<p>" in pContent
   
   -- Escape problematic characters with HTML entities
   replace "\" with "&#x22;" in pContent
   replace "'" with "&#x27;" in pContent
   replace "\\" with "&#x5C;" in pContent
   replace "/" with "&#x2F;" in pContent
   replace "[" with "&#x5B;" in pContent
   replace "]" with "&#x5D;" in pContent
   replace "{" with "&#x7B;" in pContent
   replace "}" with "&#x7D;" in pContent
end tiddler_Normalise

command tiddler_NormaliseTitle @pTitle
   -- Replace problematic characters in titles
   replace "[" with "{" in pTitle
   replace "]" with "}" in pTitle
   replace "\" with "\\" in pTitle
   
   -- Trim whitespace
   -- put trim (pTitle) into pTitle
   
   -- Ensure title is not empty
   if pTitle is empty then put "Untitled Tiddler" into pTitle
   
   return pTitle
end tiddler_NormaliseTitle

private function _GetJavascriptResult sJavascript
   -- set the javascriptHandlers of me to "javascript_Result"
   --
   do sJavascript in me
   -- get the result
   put LocalArray ["sResult"] into sResult
   put empty into LocalArray ["sResult"] -- otherwise we can get last result returned when js fails
   return sResult
end _GetJavascriptResult

on javascript_Result sResult
   -- Generic handler to return result to "getprop"
   -- Not called when js fails to return text
   put sResult into LocalArray ["sResult"]
   return sResult
end javascript_Result

--> Javascript | Events
-
getprop browser_File
   put the url of me into sURL
   put char 9 to -1 of sURL into sFile
   return sFile
end browser_File

setprop browser_File sFile
   put "file:///" & sFile into sURL
   set the url of me to sURL
   return sURL
end browser_File


--> Events | Document | Load
-
on browserDocumentLoadBegin pUrl
   -- breakpoint   
end browserDocumentLoadBegin

on browserDocumentLoadComplete pUrl
   -- breakpoint   
end browserDocumentLoadComplete

on browserDocumentLoadFailed pUrl, pError
   breakpoint
end browserDocumentLoadFailed


--> Events | Frame
-
on browserFrameDocumentLoadBegin pUrl
   breakpoint   
end browserFrameDocumentLoadBegin

on browserFrameDocumentLoadComplete pUrl
   -- breakpoint   
end browserFrameDocumentLoadComplete

on browserFrameDocumentLoadFailed pUrl, pError
   breakpoint   
end browserFrameDocumentLoadFailed


--> Events | Navigate
-
on browserNavigateBegin pUrl
   -- breakpoint   
end browserNavigateBegin

on browserNavigateFailed pUrl, pError
   breakpoint   
end browserNavigateFailed
