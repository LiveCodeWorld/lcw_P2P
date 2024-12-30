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

getprop tiddlers_ByTag [someTag]
   breakpoint
   -- $tw.wiki.filterTiddlers('[tag[Welcome]]');
   -- think we need to escape filter expression
   put "tag[" & someTag & "]]" into fTag
   -- put "tag&#x5B;" & someTag & "&#x5D;]" into fTag
   --
   put merge ("liveCode.javascript_Result($tw.wiki.filterTiddlers('[[fTag]]').join(';'));") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   replace ";" with CR in jsResult
   return jsResult
end tiddlers_ByTag

getprop tiddler_Exists [tiddlerTitle]
   put merge("liveCode.javascript_Result($tw.wiki.tiddlerExists('[[tiddlerTitle]]'));") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   return jsResult is "true"
end tiddler_Exists

setprop tiddler_Delete tiddlerTitle
   tiddler_NormaliseTitle tiddlerTitle
   get "$tw.wiki.deleteTiddler('" & tiddlerTitle & "');"
   do it in me
end tiddler_Delete

setprop tiddler_Text [pTitle] sContent
   if pTitle is empty then put the ticks into pTitle
   tiddler_Normalise sContent
   --
   get merge ("$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[pTitle]]', text: '[[sContent]]'}));")
   do it in me
   put the result into sResult
   return sResult
end tiddler_Text

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

getprop tiddler_Text [pTiddlerTitle]
   put merge("$tw.wiki.getTiddlerText('[[pTiddlerTitle]]')") into sJavascript
   put merge("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   return jsResult
end tiddler_Text

getprop tiddly_Titles
   -- put "document.querySelector('h1').outerHTML" into sJavascript
   put "$tw.wiki.filterTiddlers('[all[tiddlers]]').join(';')" into sJavascript
   --
   put merge ("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put _GetJavascriptResult (livecodeJavascript) into jsResult
   --
   -- put livecodeJavascript & CR&CR before jsResult
   replace ";" with CR in jsResult
   return jsResult
end tiddly_Titles

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
   breakpoint   
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
