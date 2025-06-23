script "behavior_ViewTiddlyWiki" with behavior "behavior_ViewBrowser"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTiddlyWiki
type: behavior
version: 0.7
deps: none

/*
This is the behavior for a browser widget that is customised to host a TiddlyWiki file.
*/

local LocalArray
constant NotificationTemplate = "$:/temp/NotificationTemplate"


--> Working on
-
getprop tiddly_Title
   get the tiddler_Text ["$:/SiteTitle"] of me
   if it is empty then
      beep
      get the tiddler_Text ["$:/SiteTitle"] of me
      return it
   else
      return it
   end if
end tiddly_Title

getprop tiddly_SubTitle
   get the tiddler_Text ["$:/SiteSubtitle"] of me
   if it is empty then
      beep
      get the tiddler_Text ["$:/SiteSubtitle"] of me
      return it
   else
      return it
   end if
end tiddly_SubTitle


--> Init
-
command behavior_SetStackNames stackNames, tObject
   replace comma with CR in stackNames
   
   repeat for each line stackName in stackNames
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName into bObject
      if tObject = bObject then next repeat
      
      # Clear bObject behavior to prevent possible recurssion
      put the behavior of tObject into tBehavior
      put the behavior of bObject into bBehavior
      set the behavior of bObject to empty
      --
      set the behavior of tObject to bObject
      put bObject & CR after bObjects
      --
      put bObject into tObject
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_SetStackNames


--> Init
-
command init_Module
   # Module Init 
   put the view_BehaviorStackNames of me into bStackNames
   if the shiftKey is "up" then
      put the long id of me into tObject
      behavior_SetStackNames bStackNames, tObject
      -- set the behavior_StackNames of me to bStackNames
   end if
   
   # Tiddly Init 
   _SetJavascriptHandlers
   
   # Fancy Init
   -- init_Titles
   -- init_Menus
   
   # Display Init
   set the card_Colour of me to "random" -- so we know behavior is active
end init_Module

getprop view_BehaviorStackNames
   put the uOPN ["view_BehaviorStackNames"] of me into mBehaviorStackNames
   return mBehaviorStackNames
end view_BehaviorStackNames

setprop view_BehaviorStackNames mBehaviorStackNames
   set the uOPN ["view_BehaviorStackNames"] of me to mBehaviorStackNames
   
   # Send-in-time to prevent behavior setting behavior
   send "init_Module" to me in 2 ticks
end view_BehaviorStackNames


--> Working on
-
command text_Set someFile, someText
   put someFile into scriptFolder
   set the itemdelimiter to slash
   put empty into item -1 of scriptFolder
   folder_CreateNested scriptFolder
   
   # Can be slow?
   put textEncode (word 1 to -1 of someText, "UTF-8") into binText
   put binText into url ("binfile:" & someFile)
   return the result
end text_Set

private function _CheckTiddlyHtml sContent
   get line 1 to 10 of sContent -- for debugging
   if it is empty then return false
   
   # Should do some chekcs
   return true
end _CheckTiddlyHtml

private function _CheckJsonFile sContent
   put "jsonlint --quiet <" && jsonFile into sShell
   put shell (sShell) into sResult
   return sResult is empty
end _CheckJsonFile

private function _CheckJson tiddlyJSON
   return true
   
   -- put json_ToArray (tiddlyJSON) into tiddlyArray
   -- put jsonImport (tiddlyJSON) into tiddlyArray -- can crash
   -- put tiddlyArray is an array into isJSON
   
   # This is slow
   put the tempname & ".json" into jsonFile
   text_Set jsonFile, tiddlyJSON
   put _CheckJsonFile (jsonFile) into isJSON
   
   if isJSON is false then
      breakpoint -- often an issue with complex json
      set the tiddly_Notification of me to "Cannot encode JSON for export! Hopefully html export is good."
   end if
   return isJSON
end _CheckJson

private command _ExportFullTiddlyHtml sContent
   if _CheckTiddlyHtml (sContent) is true then
      _SaveText sContent
   end if
   
   # Also Export all content JSON
   put the tiddly_JSON of me into tiddlyJSON
   _ExportTiddlyJson tiddlyJSON
   if item 1 of the result is "Error" then
      lcw_Notify the result
      -- breakpoint
   else
      
   end if
end _ExportFullTiddlyHtml

private command _ExportTiddlyJson tiddlyJSON
   if char 1 to 2 of tiddlyJSON is not "[{" then
      breakpoint -- often an issue with complex json
      return "Error, not a json file"
   end if
   
   # Check JSON
   if _CheckJson (tiddlyJSON) is false then
      breakpoint -- often an issue with complex json
      set the tiddly_Notification of me to "Cannot encode JSON for export! Hopefully html export is good."
      return "Error, could not parse a json file"
   end if
   
   # Export Json
   put the browser_File of me into jsonFile
   set the itemdelimiter to "."
   put "json" into item -1 of jsonFile
   
   put jsonFile into scriptFolder
   set the itemdelimiter to slash
   put empty into item -1 of scriptFolder
   folder_CreateNested scriptFolder
   
   # Save JOSN
   -- put textEncode (word 1 to -1 of someText, "UTF-8") into binText -- slow for json?
   put tiddlyJSON into url ("binfile:" & jsonFile) -- assume it is binary?
   
   return jsonFile
end _ExportTiddlyJson

setprop tiddly_Notification alertText
   switch the tiddly_NofificationStyle of me
      case "lcw_Notify"
         lcw_Notify alertText
         break
      case "stack_Label"
         put the stack_Label of me into oLabel
         set the stack_Label of me to alertText
         wait 30 ticks with messages
         set the stack_Label of me to oLabel
         break
      case false
      default
         _AddNotificationTiddler alertText
         _DisplayNotificationTiddler
   end switch
   return the result
end tiddly_Notification

getprop tiddly_NofificationStyle
   return the uOPN ["tiddly_NofificationStyle"] of me
end tiddly_NofificationStyle
   
setprop tiddly_NofificationStyle sStyle
   set the uOPN ["tiddly_NofificationStyle"] of me to sStyle
end tiddly_NofificationStyle
   

--> Events
-
on preOpenControl
   init_Module
   pass preOpenControl
end preOpenControl

on browserUnhandledLoadRequest blobUrl
   -- Check if the URL is a Blob URL
   switch
      case blobUrl begins with "blob:null/"
      case blobUrl begins with "blob:"
         _HandleTiddlyWikiSave blobUrl
         break
      default
         -- tiddler:%20%3CtiddlerTitle%3E
         put "URL not recognized as a Blob URL:" && urldecode (blobUrl)
         -- breakpoint
   end switch
end browserUnhandledLoadRequest

on browserDocumentLoadComplete pUrl
   -- called when url loading ends
   _InjectExternalJavascript 
end browserDocumentLoadComplete


--> Tiddly | Javascript
-
on tiddlyButton_Call sMessage
   if sMessage is empty then
      return empty
   end if
   
   local sResult
   put the long id of me into tiddlyView -- more reliable if in behavior
   
   # Strip enclosing quotes (should fix javascript)
   text_StripEnclosing sMessage, quote
   put "tiddly_" & word 1 of sMessage into tiddlyCommand
   dispatch tiddlyCommand with sMessage,tiddlyView
   --
   switch it
      case "handled" -- the message was handled and not passed
         break
      case "unhandled" -- no matching handlers were found
         tiddly_UnhandledCommand sMessage, tiddlyView
         break
      case "passed"
         breakpoint
   end switch
end tiddlyButton_Call

command guide_ExternalLink sUrl
   put the long id of the target into dView
   --
   put merge ("How would you like to open [[sUrl]]") into someQuestion
   -- answer someQuestion with "Cancel" or "LiveBrowser" or "Firefox" as sheet
   answer someQuestion with "Cancel" or "Firefox" as sheet
   switch it
      case "Cancel"
         exit to top
         break
      default
         launch url sUrl -- Opens the link in the default browser
         set the clipboardData to sUrl
         break
   end switch
end guide_ExternalLink

command guide_Go sUrl
   put item 3 to -1 of sUrl into guideName
   if exists (stack guideName) then
      go to stack guideName
   else
      put the long id of the target into dView
      lcw_Answer "Launch guide '[[guideName]]'?", dView, guideName
   end if
end guide_Go


--> Props
-
getprop readme_Folder
   put the browser_File of the target into readmeFolder
   set the itemdelimiter to slash
   put empty into item -1 of readmeFolder
   return readmeFolder
end readme_Folder


--> Tiddly | Title
-
getprop tiddler_Text [pTiddlerTitle]
   # JavaScript to safely retrieve the tiddler text or return an empty string if it doesn't exist
   put merge("var tiddlerText = $tw.wiki.getTiddlerText('[[pTiddlerTitle]]') || ''; liveCode.javascript_Result(tiddlerText);") into sJavascript
   
   # Execute the JavaScript and get the result
   put tw_JavascriptResult(sJavascript) into tiddlerText
   return tiddlerText
end tiddler_Text

setprop tiddly_SubTitle subTitle
   set the tiddler_Text ["$:/SiteSubtitle"] of me to subTitle
   return empty
end tiddly_SubTitle

setprop tiddly_Title [pStrapline] pTitle
   if pTitle is empty then  return "Error: The title cannot be empty."
   
   set the tiddler_Text ["$:/SiteTitle"] of me to pTitle
   --
   if pStrapline is not empty then
      set the tiddler_Text ["$:/SiteSubtitle"] of me to pStrapline
   end if
   return empty
end tiddly_Title


--> Tiddly | Save
-
getprop tiddly_Saved
   # JavaScript to check if the wiki has unsaved changes and return the exact message
   put "var isDirty = $tw.saverHandler.isDirty();" & \
         "var message = 'Wiki save state: ' + (isDirty ? 'Unsaved changes' : 'No changes');" & \
         "liveCode.javascript_Result(message);" into sJavascript
   
   # Execute the JavaScript and get the result
   put tw_JavascriptResult(sJavascript) into tSaveState
   if tSaveState = "Wiki save state: No changes" then
      return true
   else
      return false
   end if
end tiddly_Saved

getprop blob_Html
   -- _SaveText tHtmlContent
   put the blob_URl of me into blobURL
   put _GetBlobData (blobURL) into sHTML
   return sHTML
end blob_Html

getprop blob_URl
   put the uOPN["blobUrl"] of me into blobUrl
   return blobUrl
end blob_URl

setprop blob_URl blobUrl
   set the uOPN["blobUrl"] of me to blobUrl
end blob_URl

getprop tiddler_Html [pTiddlerName]
   # JavaScript to render the tiddler
   -- parseAsInline: true seems t create errors  
   put "var renderedContent = $tw.wiki.renderText('text/html', 'text/vnd.tiddlywiki', $tw.wiki.getTiddlerText('" & pTiddlerName & "'), {parseAsInline: false});" & \
         "liveCode.javascript_Result(renderedContent);" into livecodeJavascript
   --
   put tw_JavascriptResult (livecodeJavascript) into jsResult
   return jsResult
end tiddler_Html


--> Tiddler | Array
-
getprop tiddler_Array [pTiddlerTitle]
   -- JavaScript to get all fields from a tiddler as a JSON object
   put merge ("liveCode.javascript_Result(" & \
         "JSON.stringify($tw.wiki.getTiddler('[[pTiddlerTitle]]')?.fields || {}));") into sJavascript
   
   -- Execute JavaScript and get the result (JSON)
   put tw_JavascriptResult (sJavascript) into jsResult
   
   -- Convert JSON result into a LiveCode associative array
   local tTiddlerArray
   if jsResult is not empty then
      put JSONToArray (jsResult) into tTiddlerArray
   end if
   
   -- Return the associative array
   return tTiddlerArray
end tiddler_Array

setprop tiddler_Array tArray
   put ArrayToJSON (tArray) into tJSON
   set the tiddler_JSON of me to tJSON
   return tJSON
end tiddler_Array

setprop tiddler_JSON tJSON
   -- Escape the JSON string safely
   tw_Normalize tJSON
   
   -- Ensure JSON is safely escaped for JavaScript compatibility
   replace quote with "\u0022" in tJSON
   replace CR with "\n" in tJSON
   replace linefeed with "\n" in tJSON
   
   -- Send the full tiddler object to TiddlyWiki via JavaScript
   put "try {" & \
         "var tiddlerData = JSON.parse(`" & tJSON & "`);" & \
         "$tw.wiki.addTiddler(new $tw.Tiddler(tiddlerData));" & \
         "$tw.rootWidget.refresh();" & \
         "liveCode.javascript_Result('Success');" & \
         "} catch(e) { liveCode.javascript_Result('Error: ' + e.message); }" into sJavascript
   
   -- Execute JavaScript in the browser widget
   do sJavascript in me
   put the result into sResult
   return sResult
end tiddler_JSON


--> Events | Unhandled
-
getprop tiddly_JSON [sTag]
   if sTag is empty then
      -- JavaScript to get user-authored tiddlers as JSON
      put "liveCode.javascript_Result(JSON.stringify($tw.wiki.filterTiddlers('[!is[system]]').map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   else
      -- JavaScript to get user-authored tiddlers with a specific tag
      put "liveCode.javascript_Result(JSON.stringify($tw.wiki.filterTiddlers('[tag[" & sTag & "]]').map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   end if
   
   -- Execute JavaScript and retrieve the result
   put tw_JavascriptResult(sJavascript) into tSerialized
   
   -- Return the serialized user content
   return tSerialized
end tiddly_JSON

setprop tiddly_JSON exportedTiddlyJSON
   -- set the javascriptHandlers of me to "javascript_Result"
   
   -- Ensure the input is valid JSON
   if exportedTiddlyJSON is empty then
      return "Error, no JSON data provided."
   end if
   
   -- JavaScript to parse and import Tiddlers
   put "try {" & \
         "var importedData = JSON.parse('" & exportedTiddlyJSON & "');" & \
         "importedData.forEach(function(tiddler) {" & \
         "$tw.wiki.addTiddler(new $tw.Tiddler(tiddler));" & \
         "});" & \
         "$tw.rootWidget.refresh();" & \
         "liveCode.javascript_Result('Success');" & \
         "} catch(e) { liveCode.javascript_Result('Error: ' + e.message); }" into sJavascript
   
   -- Execute JavaScript
   do sJavascript in me
end tiddly_JSON

getprop blob_Data
   put the blob_URl of me into blobUrl
   if blobUrl is empty then return empty
   put _GetBlobData (blobUrl) into blobData -- tHtmlContent
   return blobData
end blob_Data

getprop browser_File [pUseShort]
   put the url of me into sURL
   put file_FromUrl (sURL, pUseShort) into sFile
   if there is a file sFile then
      return sFile
   else
      return empty -- empty or a url (not a file)
   end if
end browser_File

setprop browser_File sFile
   put "file:///" & sFile into sURL
   set the url of me to sURL
   return sURL
end browser_File


--> Save
-
getprop tiddly_HTML
   # Use TiddlyWiki's built-in export function to get full HTML including state
   put "liveCode.javascript_Result($tw.saveChanges());" into sJavascript
   put tw_JavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddly_HTML

getprop tiddly_Data [sTag]
   put the tiddly_JSON [sTag] of me into tJSON
   put jsonImport (tJSON) into tData
   -- put json_ToArray (tJSON) into tData
   return tData
end tiddly_Data

getprop tiddlyWiki_JSON
   -- JavaScript to get all tiddlers as JSON
   put "liveCode.javascript_Result(JSON.stringify($tw.wiki.allTitles().map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   put tw_JavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddlyWiki_JSON


--> Pretty
-
setprop show_Tiddler pTitle
   # JavaScript to update $:/StoryList and display the tiddler
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: ['" & pTitle & "']}, modificationFields);" into sJavascript
   
   # Execute the JavaScript in the browser widget
   do sJavascript in me
   return the result
end show_Tiddler

setprop hide_Tiddler pTitle
   # JavaScript to remove the tiddler from $:/StoryList
   put "var storyList = $tw.wiki.getTiddlerList('$:/StoryList');" & \
         "var index = storyList.indexOf('" & pTitle & "');" & \
         "if (index > -1) {" & \
         "    storyList.splice(index, 1);" & \
         "    var modificationFields = $tw.wiki.getModificationFields();" & \
         "    $tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: storyList}, modificationFields);" & \
         "}" into sJavascript
   
   # Execute the JavaScript in the browser widget
   do sJavascript in me
   return the result
end hide_Tiddler

setprop show_Tiddlers pTitles
   # Convert the comma-separated list into a JavaScript array
   put "[" & quote & replaceText(pTitles, ",", quote & "," & quote) & quote & "]" into tList
   
   # JavaScript to update $:/StoryList with the list of tiddlers
   put "var modificationFields = $tw.wiki.getModificationFields();" & \
         "$tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: " & tList & "}, modificationFields);" into sJavascript
   
   # Execute the JavaScript in the browser widget
   do sJavascript in me
   put the result into jResult
   return jResult
end show_Tiddlers

setprop prepend_Tiddler pTitle
   # JavaScript to prepend the tiddler to the existing $:/StoryList
   put "var storyList = $tw.wiki.getTiddlerList('$:/StoryList');" & \
         "if (!storyList.includes('" & pTitle & "')) {" & \
         "    storyList.unshift('" & pTitle & "');" & \
         "    var modificationFields = $tw.wiki.getModificationFields();" & \
         "    $tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: storyList}, modificationFields);" & \
         "}" into sJavascript
   
   # Execute the JavaScript in the browser widget
   do sJavascript in me
   put the result into jResult
   return jResult
end prepend_Tiddler

setprop append_Tiddler pTitle
   # JavaScript to append the tiddler to the existing $:/StoryList
   put "var storyList = $tw.wiki.getTiddlerList('$:/StoryList');" & \
         "if (!storyList.includes('" & pTitle & "')) {" & \
         "    storyList.push('" & pTitle & "');" & \
         "    var modificationFields = $tw.wiki.getModificationFields();" & \
         "    $tw.wiki.addTiddler({title: '$:/StoryList', text: '', list: storyList}, modificationFields);" & \
         "}" into sJavascript
   
   # Execute the JavaScript in the browser widget
   do sJavascript in me
   put the result into jResult
   return jResult
end append_Tiddler

setprop delete_Tiddler tiddlerTitle
   _NormalizeTitle tiddlerTitle
   get "$tw.wiki.deleteTiddler('" & tiddlerTitle & "');"
   do it in me
end delete_Tiddler


--> Tiddler
-
getprop tiddler_Visible [pTitle]
   get the tiddly_StoryTitles of me
   return sTiddler is among the lines of it
end tiddler_Visible

setprop tiddler_Visible [sTitle] sBoolean
   if sBoolean is true then
      set the show_Tiddler of me to sTitle
   else
      set the hide_Tiddler of me to sTitle
   end if
end tiddler_Visible

getprop tiddler_Exists [tiddlerTitle]
   put merge("liveCode.javascript_Result($tw.wiki.tiddlerExists('[[tiddlerTitle]]'));") into livecodeJavascript
   put tw_JavascriptResult(livecodeJavascript) into jsResult
   return jsResult is "true"
end tiddler_Exists

setprop tiddler_Text [pTitle] sContent
   if pTitle is empty then put the ticks into pTitle
   
   # Normalize to ensure safe JavaScript string handling but preserve line breaks
   tw_Normalize sContent
   
   # Send the content with actual newlines directly (no escaping)
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
   _NormalizeTitle pTitle
   tw_Normalize sContent
   
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


--> Tiddly
-
getprop tiddly_Layout
   -- JavaScript to read the current layout setting from TiddlyWiki
   put "liveCode.javascript_Result($tw.wiki.getTiddlerText('$:/config/PageLayout'));" into sJavascript
   put tw_JavascriptResult(sJavascript) into jsResult
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

getprop tiddly_Tags
   -- JavaScript to filter and list all unique user-defined tags
   put "$tw.wiki.filterTiddlers('[all[tiddlers]!is[system]tags[]!duplicates[]sort[]]').join(';')" into sJavascript  
   --
   put merge("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put tw_JavascriptResult(livecodeJavascript) into jsResult
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
   put tw_JavascriptResult(sJavascript) into tSerialized
   
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
   put tw_JavascriptResult(sJavascript) into tSerialized
   
   -- Replace semicolons with commas for a cleaner LiveCode list
   replace ";" with CR in tSerialized
   
   -- Return the serialized story list
   return tSerialized
end tiddly_StoryTitles


--> Browser
-
getprop browser_HTML
   -- JavaScript to get the entire HTML of the wiki
   put "liveCode.javascript_Result(document.documentElement.outerHTML);" into sJavascript
   put tw_JavascriptResult(sJavascript) into tSerialized
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


--> Objects
-
getprop tiddly_View
   return the long id of me
end tiddly_View

getprop view_Object
   return the long id of me
end view_Object

getprop browser_View
   return the long id of me
end browser_View


--> TW
-
function tw_JavascriptResult sJavascript
   do sJavascript in me
   --
   put LocalArray ["sResult"] into sResult
   put empty into LocalArray ["sResult"] -- otherwise we can get last result returned when js fails
   return sResult
end tw_JavascriptResult

command tw_Normalize @sContent   
   # Escape only quotes that break JavaScript strings
   tiddler_ReplaceQuotes sContent
   
   # Preserve real line breaks as actual CR for TiddlyWiki compatibility (do last)
   replace CR with "\n" in sContent  -- Use single \n without escaping for JavaScript strings
   
   -- Do not escape square brackets or any TiddlyWiki syntax
   -- Not possible to escape the pipe character
   tiddly_ReplacePipe sContent
   -- replace "_" with "-" in pContent
end tw_Normalize


--> Deps | Notify
-
command lcw_Answer someQuestion, pDisplayView, pQVar, pQVar2, pQVar3
   put param (4) into pQVar2
   put param (5) into pQVar3
   --
   if exists (pDisplayView) then
      dispatch "lcw_Answer" to pDisplayView with someQuestion, empty, pQVar, pQVar2, pQVar3
      return the result
   end if
   put lcw_Question (someQuestion, pQVar, pQVar2, pQVar3) into someQuestion
   --
   answer someQuestion with "Cancel" or "OK" as sheet
   if it is "Cancel" then exit to top
   return it
end lcw_Answer

function lcw_Question someQuestion, pQVar, pQVar2, pQVar3
   -- put param (4) into pQVar2
   -- put param (5) into pQVar3
   --
   put _ConstructDoScript (someQuestion, pQVar, pQVar2, pQVar3) into doScript
   if doScript is not empty then
      do doScript
      put merge (someQuestion) into someQuestion
   end if
   text_ReQuote someQuestion
   return someQuestion
end lcw_Question

command lcw_Notify someMessage, pTitle, pMergeValue
   -- needs to work cross platform
   replace quote with empty in someMessage
   replace "'" with empty in someMessage
   text_ReQuote someMessage, pMergeValue
   --
   try
      if pTitle is empty then put "LiveCode World Notification" into pTitle
      put "osascript -e" && "'" & "display notification" && quote & someMessage & quote into someShell
      put "with title" && quote & pTitle & quote after someShell
      put "'" after someShell
      put shell (someShell) into shellResult
   catch e
      put someMessage
   end try
end lcw_Notify

getprop card_Colour
   -- put the card_Object of me into cObject
   put my_CardObject() into cObject
   if exists (cObject) is false then return empty
   --
   put the backgroundColor of cObject into sColour
   return sColour
end card_Colour

setprop card_Colour sColour
   -- put the card_Object of me into cObject
   put my_CardObject() into cObject
   if exists (cObject) is false then return empty
   --
   switch sColour
      case "random"
         put colour_GetRandom() into sColour
         break
      default
         -- can check for stuff
   end switch
   set the backgroundColor of cObject to sColour
   return sColour
end card_Colour


--> Deps
-
function my_CardObject
   -- ideCoreCardOfcontrol
   put the long id of me into myObject
   put wordOffset ("card", myObject) into wNum
   if wNum = 0 then return empty
   return word wNum to -1 of myObject
end my_CardObject

getprop stack_Label
   put the stack_Object of the target into stackObject
   put the label of stackObject into someLabel
   return someLabel
end stack_Label

setprop stack_Label someLabel
   put the stack_Object of the target into stackObject
   set the label of stackObject to someLabel
   return stackObject
end stack_Label

getprop stack_Object
   -- revTargetStack
   return the defaultstack
end stack_Object

function colour_GetRandom
   -- was "randomColour"
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom

command folder_CreateNested someFolder
   if there is a folder someFolder then return empty   
   set the itemdelimiter to "/"
   repeat with itemNum = 2 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
   text_AddTrailing someFolder, slash
   return someFolder
end folder_CreateNested

command text_StripEnclosing @sText, pChar
   if char 1 of sText = pChar then delete char 1 of sText 
   if char -1 of sText = pChar then delete char -1 of sText 
end text_StripEnclosing

command tiddler_ReplaceQuotes @sContent
   -- not sure best way to standardise this?
   replace "\" with "\\\" in sContent  -- ???
   replace "'" with "\\'" in sContent   -- Escape single quotes properly
end tiddler_ReplaceQuotes

command tiddly_ReplacePipe @sContent
   -- not sure best way to standardise this?
   -- thinking that we don;t use pipes in anes anymore
   -- instead words with CamelCase
   replace "|" with space in sContent
   -- replace "|" with empty in sContent -- maybe do this as well
   -- replace "|" with "-" in sContent -- Correctly escape the pipe
end tiddly_ReplacePipe

command tiddly_UnhandledCommand sMessage, tiddlyView
   put "Unknown message: " & sMessage into sResult
   _UpdateAndPrepend sResult, tiddlyView
end tiddly_UnhandledCommand

function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

function text_GetMergeVars mergeText
   -- put text_GetBetween ("[[", "]]", someText, startAfterCharNum)
   put "\[\[" into someReg
   put "[^\]]*" into notaSquareClosingBracket
   put "(" & notaSquareClosingBracket & ")" after someReg
   put "\]\]" after someReg
   --
   repeat 100 -- for safety
      if matchChunk (mergeText, someReg , startMatch, endMatch) is true then
         put char startMatch to endMatch of mergeText into varName
         put varName & CR after varNames
         delete char 1 to (endMatch + 2) of mergeText
      else
         delete char -1 of varNames
         return varNames
      end if
   end repeat
end text_GetMergeVars

command text_ReQuote @someText, pMergeValue
   replace "'" with quote in someText
   if pMergeValue is not empty then
      put pMergeValue into var
      put merge (someText) into someText
   end if
end text_ReQuote


--> Events | Javascript
-
on externalLinkHandler sUrl
   -- url_Deconstruct sUrl, someProtocol, urlDomain, urlPath, shortName, fileExtension, uName, pWord
   set the itemdelimiter to slash
   switch item 1 of sUrl
      case "guide:"
         dispatch "guide_Go" to me with sUrl
         break
      default
         dispatch "guide_ExternalLink" to me with sUrl
   end switch
end externalLinkHandler

on javascript_Result sResult
   -- requires "javascript_Result" to be among the lines of the javascripthandlers of me
   -- Generic handler used to return result to "getprop"
   -- Not called when js fails to return text
   
   put sResult into LocalArray ["sResult"]
   return sResult
end javascript_Result


--> Deps | Private
-
private function _ConstructDoScript someQuestion, pQVar, pQVar2, pQVar3
   put text_GetMergeVars (someQuestion) into mergeVars
   repeat with lineNum = 1 to the number of lines of mergeVars
      put line lineNum of mergeVars into varName
      put lineNum + 1 into pNum
      put param (pNum) into pValue
      replace quote with "'" in pValue
      --
      if pValue is not empty then
         put "put" && kwote (pValue) && "into" && varName & CR after doScript
      end if
   end repeat
   delete char -1 of doScript
   return doScript
end _ConstructDoScript

private command _UpdateAndPrepend sResult, tObject
   # Tidy
   replace "'" with empty in sResult
   replace quote with empty in sResult
   
   # Update the "test" tiddler with the result
   put "var tiddler = new $tw.Tiddler({title: 'test', text: '" & sResult & "', type: 'text/plain'});" & \
         "$tw.wiki.addTiddler(tiddler);" into sJavascript
   do sJavascript in tObject
   
   # Show test tiddler
   -- set the show_Tiddler of me to "test"
   set the prepend_Tiddler of tObject to "test"
end _UpdateAndPrepend


--> Private
-
private command _DisplayNotificationTiddler
   put merge ("$tw.notifier.display('[[NotificationTemplate]]');") into sJavascript
   
   # Execute the JavaScript in the browser widget
   do sJavascript in me
   return the result
end _DisplayNotificationTiddler

private command _AddNotificationTiddler sMessage
   -- put "Don't Panic!" into sMessage
   put "Template Notification Hitchhikers" into tagWords
   get "$tw.wiki.addTiddler(new $tw.Tiddler({title: '[[NotificationTemplate]]',text: '[[sMessage]]',tags: '[[tagWords]]'}));"
   put merge (it) into sJavascript
   
   -- Execute JavaScript
   do sJavascript in me
   return the result -- Livecode returns nothing here
end _AddNotificationTiddler

private function _WaitJavascriptResult sJavascript
   -- Ensure the result storage is cleared before execution
   put empty into LocalArray["sResult"]
   
   -- Execute the JavaScript (asynchronously)
   do sJavascript in me
   
   -- Wait for the result from JavaScript callback
   repeat 30
      if LocalArray["sResult"] is not empty then
         # Capture the result and clear the storage
         put LocalArray["sResult"] into sResult
         put empty into LocalArray["sResult"]
         return sResult
      else
         wait 1 tick with messages
      end if
   end repeat
   return empty
end _WaitJavascriptResult

private function _GetBlobData pUrl
   -- requires "liveCode.javascript_Result"
   if blobUrl is empty then return empty
   
   # Use TiddlyWiki's built-in export function to get full HTML including state
   # Corrected JavaScript to properly use fetch and return the result via callback
   put "fetch('" & pUrl & "')" & \
         ".then(function(response) { return response.text(); })" & \
         ".then(function(data) { liveCode.javascript_Result(data); })" & \
         ".catch(function(error) { liveCode.javascript_Result('Error: ' + error); });" into sJavascript
   
   # Call the JavaScript and wait for the result using the utility handler
   put _WaitJavascriptResult (sJavascript) into tHtmlContent
   return tHtmlContent
end _GetBlobData

private command _SaveText sText, pShortFile
   if sText is empty then
      return "Error, not saving empty text."
   end if
   
   # File to save to?
   put the url of me into sURL
   put file_FromUrl (sURL) into tiddlyFile
   
   # Check
   switch
      case tiddlyFile is empty
         breakpoint
         break
      case there is not a file tiddlyFile
         -- we will create one
         break
      default
         -- we will overwrite
   end switch
   
   # Customise path with pShortFile
   set the itemdelimiter to slash
   if pShortFile is not empty then
      put pShortFile into item -1 of tiddlyFile
   end if
   put item -1 of tiddlyFile into shortFile
   
   # Save
   text_Set tiddlyFile, sText
   
   # Notify
   put "Saved Tiddler" && shortFile into sNotification
   set the tiddly_Notification of me to sNotification
   return tiddlyFile
end _SaveText

private function file_FromUrl sURL, pUseShort
   -- file:///Users/david/Documents/git-repos/LiveCodeWorld/lcw_Wiki/modules/View_Guide/README.html#User%20&%20Identity%20Management
   if sURL begins with "file:///" then
      put char 8 to -1 of sURL into sFile
      
      set the itemdelimiter to slash
      --
      get item -1 of sFile
      set the itemdelimiter to "#"
      put item 1 of it into shortFile
      
      if pUseShort is true then
         return shortFile
      else
         set the itemdelimiter to slash
         put shortFile into item -1 of sFile
         return sFile
      end if
   else
      return empty
   end if
end file_FromUrl

private command _SetJavascriptHandlers
   put "javascript_Result,tiddlyButton_Call,externalLinkHandler" into jHandlers
   replace comma with CR in jHandlers
   --
   set the javascriptHandlers of me to jHandlers
   --
   lcw_Notify (the params & CR & jHandlers)
end _SetJavascriptHandlers

command _InjectExternalJavascript
   -- Set the handler for JavaScript to call back into LiveCode
   -- set the javascriptHandlers of me to "externalLinkHandler"
   
   -- Construct the JavaScript as a multiline string (no backslashes)
   put "document.addEventListener('click', function(event) {" & cr & \
         "    if (event.target.tagName === 'A' && event.target.target === '_blank') {" & CR & \
         "        event.preventDefault();" & CR & \
         "        liveCode.externalLinkHandler(event.target.href);" & CR & \
         "    }" & CR & "});" into tScript
   
   -- Inject the JavaScript into the browser widget
   do tScript in me
   --
   set the tiddly_Notification of me to the params
end _InjectExternalJavascript

private command _HandleTiddlyWikiSave blobUrl
   set the blob_URl of me to blobUrl
   
   # Export HTML
   put _GetBlobData (blobUrl) into sContent
   --
   get line 1 to 10 of sContent
   switch
      -- case the number of chars of tHtmlContent <200
      case sContent is "[]"
      case sContent is empty
         init_Module
         
         # Try saving again after init_Module
         put _GetBlobData (blobUrl) into sContent
         if sContent is empty then
            # Export JSON
            put the tiddly_JSON of me into tiddlyJSON
            put the browser_File of me into sFile
            breakpoint
            --
            _ExportTiddlyJson tiddlyJSON -- when it is robust
            return "Error, saving html file:" && sFile
         end if
         
         breakpoint
         -- continue to export
      case char 1 of sContent = "["
         _ExportTiddlerJson sContent
         break
      case item 1 of it = kwote ("title")
         _ExportCsvTiddler sContent
         break
      case it contains "<!-- The following comment is called a MOTW comment and is necessary for the TiddlyIE Internet Explorer extension -->"
         _ExportFullTiddlyHtml sContent
         break
      case it contains "<!doctype html>"
         _ExportHtmlTiddler sContent
         break
      case it contains "Error: TypeError: Load failed"
         -- eg tldraw export (look at tldraw api?)
         break
      default
         breakpoint
   end switch
end _HandleTiddlyWikiSave

private command _ExportHtmlTiddler sContent
   -- tw is exporting json
   put "tiddler.html" into dPath
   ask file "Let's export plain html tiddler?" with dPath as sheet
   if it is empty then return empty
   --
   put it into sFile
   text_Set sFile, sContent
   --
   put "Exported HTML Tiddler" && dPath into sNotification
   set the tiddly_Notification of me to sNotification
end _ExportHtmlTiddler

private command _ExportCsvTiddler sContent
   -- tw is exporting csv
   put "tiddler.csv" into dPath
   ask file "Let's export csv tiddler?" with dPath as sheet
   if it is empty then return empty
   --
   put it into sFile
   text_Set sFile, sContent
   --
   put "Exported CSV Tiddler" && dPath into sNotification
   set the tiddly_Notification of me to sNotification
end _ExportCsvTiddler

private command _ExportTiddlerJson sContent
   -- tw is exporting json
   put "tiddler.json" into dPath
   ask file "Let's export some json?" with dPath as sheet
   if it is empty then return empty
   --
   put it into sFile
   text_Set sFile, sContent
   --
   put "Exported json Tiddler" && dPath into sNotification
   set the tiddly_Notification of me to sNotification
end _ExportTiddlerJson

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

private command _NormalizeTitle @pTitle
   # Ensure title is not empty
   if pTitle is empty then put "Untitled Tiddler" into pTitle
   
   # Trim whitespace
   put word 1 to -1 of pTitle into pTitle
   
   # Replace problematic characters in titles
   replace "[" with "{" in pTitle
   replace "]" with "}" in pTitle
   replace "\" with "\\" in pTitle
   
   # Wrap if more than one word
   -- if the number of words of pTitle > 1 then put "[[" & pTitle & "]]" into pTitle
   
   return pTitle
end _NormalizeTitle
