script "behavior_ViewTiddlyWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTiddlyWiki
type: behavior
version: 0.5

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/

local LocalArray
constant NotificationTemplate = "$:/temp/NotificationTemplate"

--> Working on
-
setprop tiddler_Plugin [pluginTitle] scaffoldName
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
   _Normalize tiddlerJavascript
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

on tiddlyButton_Call sMessage
   local sResult
   switch sMessage
      case "Destroy"
         put "Careful, this is dangerous" into sResult
         break
      case "Hello, Livecode!"
         put "Hello from Livecode!" into sResult
         break
      default
         put "Unknown message: " & sMessage into sResult
   end switch
   
   # Update the "test" tiddler with the result
   put "var tiddler = new $tw.Tiddler({title: 'test', text: '" & sResult & "', type: 'text/plain'});" & \
         "$tw.wiki.addTiddler(tiddler);" into sJavascript
   do sJavascript in me
   
   # Show test tiddler
   set the show_Tiddler of me to "test"
end tiddlyButton_Call


--> JS
-
getprop js_Result
   return LocalArray ["sResult"]
end js_Result

setprop js_Result sResult
   javascript_Result sResult
end js_Result

getprop card_Colour
   put the card_Object of me to cObject
   put the backgroundColor of cObject into sColour
   return sColour
end card_Colour

setprop card_Colour sColour
   put the card_Object of me into cObject
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


--> Events | Javascript
-
on javascript_Result sResult
   -- requires "javascript_Result" to be among the lines of the javascripthandlers of me
   -- Generic handler used to return result to "getprop"
   -- Not called when js fails to return text
   
   put sResult into LocalArray ["sResult"]
   return sResult
end javascript_Result

on externalLinkHandler sUrl
   -- url_Deconstruct sUrl, someProtocol, urlDomain, urlPath, shortName, fileExtension, uName, pWord
   set the itemdelimiter to slash
   switch item 1 of sUrl
      case "guide:"
         put item 3 to -1 of sUrl into guideName
         if exists (stack guideName) then
            go to stack guideName
         else
            put the long id of me into dView
            lcw_Answer "Launch guide '[[guideName]]'?", dView, guideName
         end if
         break
      default
         put the long id of me into dView
         --
         put merge ("How would you like to open [[pUrl]]") into someQuestion
         answer someQuestion with "Cancel" or "LiveBrowser" or "Firefox" as sheet
         switch it
            case "Cancel"
               exit to top
               break
            case "LiveBrowser"
               display_Browser sUrl
               break
            default
               launch url sUrl -- Opens the link in the default browser
               set the clipboardData to sUrl
               break
         end switch
   end switch
end externalLinkHandler

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


--> Events
-
on preOpenControl
   -- does not seem to _SetJavascriptHandlers
   tiddly_Init
   pass preOpenControl
end preOpenControl

on tiddly_Init
   _SetJavascriptHandlers
   --
   put the browser_File of me into tiddlyFile
   if there is a file tiddlyFile then
      set the itemdelimiter to slash
      put item -1 of tiddlyFile into shortFile
      if shortFile = "readme.html" then
         put item -2 to -1 of tiddlyFile into shortFile
      end if
      set the stack_Label of me to shortFile
   else
      put the browser_URL of me into tiddlyURL
      set the stack_Label of me to tiddlyURL
   end if
end tiddly_Init

on browserUnhandledLoadRequest blobUrl
   -- Check if the URL is a Blob URL
   if blobUrl begins with "blob:" then
      set the blob_URl of me to blobUrl
      
      # Export HTML
      put _GetBlobData (blobUrl) into sContent
      --
      get line 1 to 10 of sContent
      switch
         -- case the number of chars of tHtmlContent <200
         case sContent is "[]"
         case sContent is empty
            breakpoint
            tiddly_Init
            
            # Export JSON
            put the tiddly_JSON of me into tiddlyJSON
            -- _ExportTiddlyJson tiddlyJSON -- when it is robust
            --
            put the browser_File of me into sFile
            return "Error, saving html file:" && sFile
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
         default
            breakpoint
      end switch
   else
      -- Handle normal URLs
      put "URL not recognized as a Blob URL"
      breakpoint
   end if
end browserUnhandledLoadRequest

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

private command _ExportFullTiddlyHtml sContent
   # Also Export all content JSON
   put the tiddly_JSON of me into tiddlyJSON
   _ExportTiddlyJson tiddlyJSON
   if item 1 of the result is "Error" then
      lcw_Notify the result
      -- breakpoint
   end if
   
   get line 1 to 10 of sContent -- for debugging
   _SaveText sContent
end _ExportFullTiddlyHtml

private command _ExportTiddlyJson tiddlyJSON
   if char 1 to 2 of tiddlyJSON is not "[{" then
      return "Error, not a json file"
   end if
   put json_ToArray (tiddlyJSON) into tiddlyArray
   if tiddlyArray is not an array then
      breakpoint
      return "Error, could not parse a json file"
   end if
   
   put the browser_File of me into sFile
   set the itemdelimiter to slash
   put item -1 of sFile into shortFile
   set the itemdelimiter to "."
   put item 1 of shortFile & ".json" into jsonShortFile
   
   _SaveText tiddlyJSON, jsonShortFile
   return the result
end _ExportTiddlyJson


--> Tiddler
-
getprop tiddler_Text [pTiddlerTitle]
   get the tiddler_Exists [tTitle] of me -- otherwise crashes
   if it is false then return empty -- fix
   
   put merge("$tw.wiki.getTiddlerText('[[pTiddlerTitle]]')") into sJavascript
   put merge("liveCode.javascript_Result([[sJavascript]]);") into livecodeJavascript
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   return jsResult
end tiddler_Text

getprop tiddly_Saved
   # JavaScript to check if the wiki has unsaved changes and return the exact message
   put "var isDirty = $tw.saverHandler.isDirty();" & \
         "var message = 'Wiki save state: ' + (isDirty ? 'Unsaved changes' : 'No changes');" & \
         "liveCode.javascript_Result(message);" into sJavascript
   
   # Execute the JavaScript and get the result
   put _GetJavascriptResult(sJavascript) into tSaveState
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
   put the 'uOPN["blobUrl"] of me into blobUrl
   return blobUrl
end blob_URl

setprop blob_URl blobUrl
   set the 'uOPN["blobUrl"] of me to blobUrl
end blob_URl


--> Events | Unhandled
-
getprop tiddler_Html [pTiddlerName]
   # JavaScript to render the tiddler
   -- parseAsInline: true seems t create errors  
   put "var renderedContent = $tw.wiki.renderText('text/html', 'text/vnd.tiddlywiki', $tw.wiki.getTiddlerText('" & pTiddlerName & "'), {parseAsInline: false});" & \
         "liveCode.javascript_Result(renderedContent);" into livecodeJavascript
   --
   put _GetJavascriptResult (livecodeJavascript) into jsResult
   return jsResult
end tiddler_Html

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

getprop blob_Data
   put the blob_URl of me into blobUrl
   if blobUrl is empty then return empty
   put _GetBlobData (blobUrl) into blobData -- tHtmlContent
   return blobData
end blob_Data

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
   
   set the itemdelimiter to slash
   put the browser_File of me into tiddlyFile
   if pShortFile is not empty then
      put pShortFile into item -1 of tiddlyFile
   end if
   put item -1 of tiddlyFile into shortFile
   --
   text_Set tiddlyFile, sText
   --
   put "Saved Tiddler" && shortFile into sNotification
   set the tiddly_Notification of me to sNotification
   --
   return sFile
end _SaveText

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

private function _GetJavascriptResult sJavascript
   do sJavascript in me
   --
   put LocalArray ["sResult"] into sResult
   put empty into LocalArray ["sResult"] -- otherwise we can get last result returned when js fails
   return sResult
end _GetJavascriptResult


--> Save
-
getprop tiddly_HTML
   # Use TiddlyWiki's built-in export function to get full HTML including state
   put "liveCode.javascript_Result($tw.saveChanges());" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddly_HTML

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

setprop tiddly_ImportJSON exportedTiddlyJSON
   -- Ensure the input JSON is valid and not empty
   if exportedTiddlyJSON is empty then
      answer "Error: No JSON data provided."
      exit to top
   end if
   
   # JavaScript to trigger TiddlyWiki's import tiddler UI with the JSON data
   put "try {" & \
         "var exportedTiddlyJSON = `" & exportedTiddlyJSON & "`;" & \
         "var jsonBlob = new Blob([exportedTiddlyJSON], {type: 'application/json'});" & \
         "var jsonFile = new File([jsonBlob], 'imported-tiddlers.json');" & \
         "if (typeof $tw !== 'undefined') {" & \
         "$tw.wiki.importTiddlers([jsonFile]);" & \
         "$tw.rootWidget.dispatchEvent({type: 'tm-import-tiddlers'});" & \
         "liveCode.javascript_Result('Success');" & \
         "} else { throw new Error('TiddlyWiki not loaded'); }" & \
         "} catch(e) { liveCode.javascript_Result('Error: ' + e.message); }" into sJavascript
   
   # Execute the JavaScript in the correct context
   do sJavascript in me
   put the result into sResult
   return sResult
end tiddly_ImportJSON

getprop tiddlyWiki_JSON
   -- JavaScript to get all tiddlers as JSON
   put "liveCode.javascript_Result(JSON.stringify($tw.wiki.allTitles().map(function(title) { var t = $tw.wiki.getTiddler(title); return t.fields; })));" into sJavascript
   put _GetJavascriptResult(sJavascript) into tSerialized
   return tSerialized
end tiddlyWiki_JSON


--> Pretty
-
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

setprop tiddler_Array tArray
   put ArrayToJSON (tArray) into tJSON
   set the tiddler_JSON of me to tJSON
   return tJSON
end tiddler_Array

setprop tiddler_JSON tJSON
   -- Escape the JSON string safely
   _Normalize tJSON
   
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


--> Tiddler
-
getprop tiddler_Visible [pTitle]
   breakpoint
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
   put _GetJavascriptResult(livecodeJavascript) into jsResult
   return jsResult is "true"
end tiddler_Exists

setprop tiddler_Text [pTitle] sContent
   if pTitle is empty then put the ticks into pTitle
   
   # Normalize to ensure safe JavaScript string handling but preserve line breaks
   _Normalize sContent
   
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

getprop tiddler_IsShowing [sTiddler]
   get the tiddly_StoryTitles of me
   return sTiddler is among the lines of it
end tiddler_IsShowing


--> Tiddly
-
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


--> Browser
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

getprop browser_File [pUseShort]
   put the url of me into sURL
   put char 9 to -1 of sURL into sFile
   if pUseShort is true then
      set the itemdelimiter to slash
      return item -1 of sFile
   else
      return sFile
   end if
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


--> Events | Document | Load
-
on browserDocumentLoadBegin pUrl
   -- called when url loads (after browserNavigateBegin)
end browserDocumentLoadBegin

on browserDocumentLoadComplete pUrl
   -- called when url loading ends
   _InjectExternalJavascript 
end browserDocumentLoadComplete

on browserDocumentLoadFailed pUrl, pError
   lcw_Answer pError
end browserDocumentLoadFailed


--> Events | Frame
-
on browserFrameDocumentLoadBegin pUrl
   breakpoint -- does not seem to be called 
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
   -- called when url loads (not when loading external links for a new tab)
end browserNavigateBegin

on browserNavigateFailed pUrl, pError
   lcw_Notify pError
end browserNavigateFailed


--> Private
-
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


--> Deps
-
private function colour_GetRandom
   -- was "randomColour"
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom
