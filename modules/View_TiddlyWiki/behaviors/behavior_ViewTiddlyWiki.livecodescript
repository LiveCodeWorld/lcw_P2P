script "behavior_ViewTiddlyWiki"
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


--> Events | Unhandled
-
on browserUnhandledLoadRequest pUrl
   -- Check if the URL is a Blob URL
   if pUrl begins with "blob:" then
      # Use TiddlyWiki's built-in export function to get full HTML including state
      # Corrected JavaScript to properly use fetch and return the result via callback
      put "fetch('" & pUrl & "')" & \
            ".then(function(response) { return response.text(); })" & \
            ".then(function(data) { liveCode.javascript_Result(data); })" & \
            ".catch(function(error) { liveCode.javascript_Result('Error: ' + error); });" into sJavascript
      
      # Set up the JavaScript handler for asynchronous results
      -- set the javascriptHandlers of me to "javascript_Result" -- already set
      
      # Call the JavaScript and wait for the result using the utility handler
      put _WaitJavascriptResult(sJavascript) into tHtmlContent
      
      _SaveText tHtmlContent -- , "test_Export.html"
      put the tiddly_Title of me into tiddlyTitle
      lcw_Notify "Saved Tiddler" && tiddlyTitle
   else
      -- Handle normal URLs
      put "URL not recognized as a Blob URL"
   end if
end browserUnhandledLoadRequest

on javascript_Result sResult
   -- Generic handler to return result to "getprop"
   -- Not called when js fails to return text
   put sResult into LocalArray ["sResult"]
   return sResult
end javascript_Result

getprop tiddly_HTML
   # Use TiddlyWiki's built-in export function to get full HTML including state
   put "liveCode.javascript_Result($tw.saveChanges());" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddly_HTML


--> Working on
-
getprop tiddler_Array [pTiddlerTitle]
   -- JavaScript to get all fields from a tiddler as a JSON object
   put merge ("liveCode.javascript_Result(" & \
         "JSON.stringify($tw.wiki.getTiddler('[[pTiddlerTitle]]')?.fields || {}));") into sJavascript
   
   -- Execute JavaScript and get the result (JSON)
   put _GetJavascriptResult(sJavascript) into jsResult
   
   -- Convert JSON result into a LiveCode associative array
   local tTiddlerArray
   if jsResult is not empty then
      put JSONToArray (jsResult) into tTiddlerArray
   end if
   
   -- Return the associative array
   return tTiddlerArray
end tiddler_Array

getprop tiddly_Layout
   -- JavaScript to read the current layout setting from TiddlyWiki
   put "liveCode.javascript_Result($tw.wiki.getTiddlerText('$:/config/PageLayout'));" into sJavascript
   put _GetJavascriptResult(sJavascript) into jsResult
   return jsResult
end tiddly_Layout

setprop tiddly_Layout pLayout
   -- JavaScript to change the page layout in TiddlyWiki
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler({title: '$:/config/PageLayout', text: '" & pLayout & "'}, modificationFields);" & \
         "$tw.rootWidget.refresh();" into sJavascript
   
   -- Execute JavaScript in the LiveCode browser widget
   do sJavascript in me
   return the result
end tiddly_Layout


--> Tiddler
-
getprop tiddler_Visible [pTitle]
   
end tiddler_Visible

setprop tiddler_Visible [sTitle] sBoolean
   if sBoolean is true then
      set the show_Tiddler of me to sTitle
   else
      set the hide_Tiddler of me to sTitle
   end if
end tiddler_Visible

setprop show_Tiddler pTitle
   -- JavaScript to update $:/StoryList and display the tiddler
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: ['" & pTitle & "']}, modificationFields);" into sJavascript
   
   -- Execute the JavaScript in the browser widget
   do sJavascript in me
   return the result
end show_Tiddler

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


--> Browser | Props
-
getprop browser_HTML
   -- JavaScript to get the entire HTML of the wiki
   put "liveCode.javascript_Result(document.documentElement.outerHTML);" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return tSerialized
end browser_HTML

getprop browser_URL
   put the url of me into sURL
   return sURL
end browser_URL

setprop browser_URL sURL
   set the url of me to sURL
   return sURL
end browser_URL

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
   
   -- Normalize to ensure safe JavaScript string handling but preserve line breaks
   _Normalize sContent
   
   -- Send the content with actual newlines directly (no escaping)
   get merge ("$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[pTitle]]', text: `" & sContent & "`}));")
   do it in me
   put the result into sResult
   return sResult
end tiddler_Text

getprop tiddler_BulletMarkdown [sIndex]
   -- formatted so we can set the tiddler_RawMarkdown fo a wiki
   put _Tiddlerbullets (sIndex) into sBullets
   return sBullets
end tiddler_BulletMarkdown

setprop tiddler_Bullets [pTitle] sIndex
   if pTitle is empty then put the ticks into pTitle
   --
   put _Tiddlerbullets (sIndex) into sBullets
   
   set the tiddler_RawMarkdown [pTitle] of me to sBullets
   put the result into sResult
   return sResult
   
   # Send the content with actual newlines directly (no escaping)
   get merge ("$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[pTitle]]', text: `" & sBullets & "`, type: 'text/markdown'}));")
   do it in me
   put the result into sResult
   return sResult
end tiddler_Bullets

setprop tiddler_Markdown [pTitle] sContent
   if pTitle is empty then put the ticks into pTitle
   
   # Normalize to ensure safe JavaScript string handling but preserve line breaks
   _Normalize sContent
   
   set the tiddler_RawMarkdown [pTitle] of me to sContent
   put the result into sResult
   return sResult
end tiddler_Markdown

setprop tiddler_RawMarkdown [pTitle] sContent
   if pTitle is empty then put the ticks into pTitle
    
   # Send the content with actual newlines directly (no escaping)
   get merge ("$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[pTitle]]', text: `" & sContent & "`, type: 'text/markdown'}));")
   do it in me
   put the result into sResult
   return sResult
end tiddler_RawMarkdown

private function _Tiddlerbullets sIndex
   -- Normalize to ensure safe JavaScript string handling but preserve line breaks
   
   tiddly_ReplacePipe sIndex
   --
   repeat for each line sLine in sIndex
      if sLine = "---" then
         put "---\n" after sBullets
         next repeat
      end if
      
      -- tiddly_ReplacePipe sLine
      if sLine contains "_" then
         put "- [[" & sLine & "|" & sLine & "]]\n" after sBullets
      else
         put "- [[" & sLine & "]]\n" after sBullets
      end if
   end repeat
   return sBullets
end _Tiddlerbullets

private command _Normalize @sContent   
   # Escape only quotes that break JavaScript strings
   tiddler_ReplaceQuotes sContent
   
   # Preserve real line breaks as actual CR for TiddlyWiki compatibility (do last)
   replace CR with "\n" in sContent  -- Use single \n without escaping for JavaScript strings
   
   -- Do not escape square brackets or any TiddlyWiki syntax
   -- Not possible to escape the pipe character
   tiddly_ReplacePipe sContent
   -- replace "_" with "-" in pContent
end _Normalize

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

getprop tiddler_IsShowing [sTiddler]
   get the tiddly_StoryTitles of me
   return sTiddler is among the lines of it
end tiddler_IsShowing

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


--> Tiddler
-
getprop tiddly_Title
   -- JavaScript to get the TiddlyWiki title from $:/SiteTitle
   put "liveCode.javascript_Result($tw.wiki.getTiddlerText('$:/SiteTitle'));" into sJavascript
   
   -- Execute JavaScript and retrieve the result
   put _GetJavascriptResult(sJavascript) into jsResult
   
   -- Return the title of the TiddlyWiki
   return jsResult
end tiddly_Title

setprop tiddly_Title [pStrapline] pTitle
   # Ensure title is provided
   if pTitle is empty then 
      return "Error: The title cannot be empty."
   end if
   
   -- Normalize inputs for safe JavaScript usage
   _Normalize pTitle
   _Normalize pStrapline
   
   # Prepare the JavaScript for setting title and strapline using $tw.wiki.setText()
   if pStrapline is empty then
      put "liveCode.javascript_Result($tw.wiki.setText('$:/SiteTitle', 'text', null, `" & pTitle & "`));" into sJavascript
   else
      put "liveCode.javascript_Result($tw.wiki.setText('$:/SiteTitle', 'text', null, `" & pTitle & "`));" & \
            "liveCode.javascript_Result($tw.wiki.setText('$:/SiteSubtitle', 'text', null, `" & pStrapline & "`));" into sJavascript
   end if
   
   # Execute JavaScript in the browser widget
   do sJavascript in me
   put the result into sResult
   return sResult
end tiddly_Title

-- setprop tiddly_Title [pStrapline] pTitle
# Ensure title is always provided
if pTitle is empty then 
   return "Error: The title cannot be empty."
end if

# Normalize the inputs to prevent JavaScript errors
_Normalize pTitle
_Normalize pStrapline

-- Prepare the JavaScript for setting the title and optional strapline
if pStrapline is empty then
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler(new $tw.Tiddler({title: '$:/SiteTitle', text: `" & pTitle & "`}, modificationFields));" & \
         "$tw.rootWidget.refresh();" into sJavascript
else
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler(new $tw.Tiddler({title: '$:/SiteTitle', text: `" & pTitle & "`}, modificationFields));" & \
         "$tw.wiki.addTiddler(new $tw.Tiddler({title: '$:/SiteSubtitle', text: `" & pStrapline & "`}, modificationFields));" & \
         "$tw.rootWidget.refresh();" into sJavascript
end if

-- Execute the JavaScript in the browser widget
do sJavascript in me
put the result into sResult
return sResult
end tiddly_Title

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
   _NormalizeTitle tiddlerTitle
   get "$tw.wiki.deleteTiddler('" & tiddlerTitle & "');"
   do it in me
end delete_Tiddler


--> Events
-
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


--> Events | Document | Load
-
on browserDocumentLoadBegin pUrl
   -- breakpoint   
end browserDocumentLoadBegin

on browserDocumentLoadComplete pUrl
   -- breakpoint   
end browserDocumentLoadComplete

on browserDocumentLoadFailed pUrl, pError
   -- breakpoint
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
   -- breakpoint
   lcw_Notify pError
end browserNavigateFailed


--> Private
-
private command _NormalizeTitle @pTitle
   -- Replace problematic characters in titles
   replace "[" with "{" in pTitle
   replace "]" with "}" in pTitle
   replace "\" with "\\" in pTitle
   
   -- Trim whitespace
   -- put trim (pTitle) into pTitle
   
   -- Ensure title is not empty
   if pTitle is empty then put "Untitled Tiddler" into pTitle
   
   return pTitle
end _NormalizeTitle

private function _WaitJavascriptResult sJavascript
   -- Ensure the result storage is cleared before execution
   put empty into LocalArray["sResult"]
   
   -- Execute the JavaScript (asynchronously)
   do sJavascript in me
   
   -- Wait for the result from JavaScript callback
   repeat until LocalArray["sResult"] is not empty
      wait 1 tick with messages
   end repeat
   
   -- Capture the result and clear the storage
   put LocalArray["sResult"] into sResult
   put empty into LocalArray["sResult"]
   return sResult
end _WaitJavascriptResult

private function _GetJavascriptResult sJavascript
   -- set the javascriptHandlers of me to "javascript_Result"
   --
   do sJavascript in me
   -- get the result
   put LocalArray ["sResult"] into sResult
   put empty into LocalArray ["sResult"] -- otherwise we can get last result returned when js fails
   return sResult
end _GetJavascriptResult

private command _SaveText sText, pShortFile
   put the browser_File of me into sFile
   --
   if pShortFile is not empty then
      set the itemdelimiter to slash
      put pShortFile into item -1 of sFile
   end if
   --
   text_Set sFile, sText
   return sFile
end _SaveText
