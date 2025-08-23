script "model_TiddlyHtml"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_TiddlyHtml
type: model
version: 0.1

/*
This model is all about reading and writing directly to tw html directly (without using the browser widget).
*/

--> Variables
--
local LocalArray


--> Working on
-
function tiddly_ListAssetFiles
   
end tiddly_ListAssetFiles

function testToken
   -- {"created":"20250715155337466","title":"$:/SiteSubtitle","text":"","modified":"20250715155337466"},
   get "{'created':'20250715155330650','title':'$:/SiteTitle','text':'Test Title','modified':'20250719133135819'},"
   replace "'" with quote in it
   --
   put _ItemArrayText(it) into oldTitle
   return dfsa
end testToken


--> Tiddly | Htmls
-
function tiddlyHtml_GetSiteTitle tHtml
   put tiddlyHtml_GetSection (tHtml) into oSection
   put tiddlyHtml_JsonFromSection (oSection) into tJSON
   --
   put _Match (tJSON) into siteTitleLine
   -- put _Filter (tJSON) into siteTitleLine
   return siteTitleLine
end tiddlyHtml_GetSiteTitle

command tiddlyHtml_SetSiteTitle @tHtml, newTitle
   put tiddlyHtml_GetSection (tHtml) into oSection
   put tiddlyHtml_JsonFromSection (oSection) into tJSON
   --
   -- put _Match (tJSON) into siteTitleLine
   put _Filter (tJSON) into siteTitleLine
   put lineOffset (siteTitleLine, tHtml) into lineNum
   -- put line lineNum of tHtml into siteTitleLine
   
   # Replace $SiteTitle line in tw html
   put tiddlerJson_ConstructSiteTitle (newTitle, siteTitleLine) into siteTitleLine
   put siteTitleLine into line lineNum of tHtml
   --
   return lineNum
end tiddlyHtml_SetSiteTitle

function tiddler_SiteTitleItemJson newTitle, oldLine
   put "{'created':'*','title':'$:/SiteTitle','text':'*','modified':'*'}," into sFilter
   replace "'" with quote in sFilter
end tiddler_SiteTitleItemJson

function tiddlerJson_ConstructSiteTitle newTitle, pOldJsonLine
   get tiddlerJson_Construct ("$:/SiteTitle", newTitle, pOldJsonLine)
   return it
end tiddlerJson_ConstructSiteTitle

function tiddlerJson_Construct sTitle, sText, jBit
   -- get "{'created':'" & cDate & "','title':" & kwote (sTitle) & ",'text':" & kwote (sText) & ",'modified':'" & mDate & "'},"
   -- replace "'" with quote in it
   
   put _JsonItemArray (jBit) into itemArray
   
   # cDate
   put itemArray ["created"] into cDate
   if cDate is empty then
      put tiddly_Date() into cDate
   end if
   
   # mDate
   put tiddly_Date() into mDate
   
   # Construct
   put "{" into jsonLine
   _AddToLine jsonLine, "created", cDate
   put comma after jsonLine
   _AddToLine jsonLine, "title", sTitle
   put comma after jsonLine
   _AddToLine jsonLine, "text", sText
   put comma after jsonLine
   _AddToLine jsonLine, "modified", mDate
   put "}," after jsonLine
   --
   return jsonLine & CR & it
end tiddlerJson_Construct


--> Private
-
private function _ItemArrayText jBit
   put _JsonItemArray (jBit) into itemArray
   put itemArray ["text"] into sText
   -- put itemArray ["title"] into twTitle
   return sText
end _ItemArrayText

private function _JsonItemArray jsonLine
   -- put token 12 of jsonLine into oldTitle
   replace quote with empty in jsonLine
   --
   delete char 1 of jsonLine
   delete char -1 of jsonLine
   split jsonLine using comma and ":"
   return jsonLine
end _JsonItemArray

private command _AddToLine @jsonLine, sKey, sValue
   put kwote (sKey) after jsonLine
   put ":" after jsonLine
   put kwote (sValue) after jsonLine
end _AddToLine

private function _Match tJSON
   put _SiteTitleRegExp() into rExp
   try
      if matchText (tJSON, rExp, siteTitle) then
         return siteTitle
      else
         return empty
      end if
   catch e
      return e
   end try
end _Match

private function _SiteTitleRegExp
   put "\{.*?'title':'\$:/SiteTitle','text':'(.*?)'.*?\}" into rExp
   replace "'" with quote in rExp
   return rExp
end _SiteTitleRegExp

function _Filter tJSON
   put "{'created':'*','title':'$:/SiteTitle','text':'*','modified':'*'}," into sFilter
   replace "'" with quote in sFilter
   filter tJSON with sFilter
   return tJSON
end _Filter

private function _Offset
   get ",\'$:/SiteTitle\':{\'title\':\'$:/SiteTitle\',\'text\':\'" into sPattern
   -- put sTitle & "\'}," after sPattern
   replace "'" with quote in sPattern
   --
   put offset (sPattern, tHtml) into startNum
   put offset ("\'},", tHtml, startNum) into afterNum
   put startNum + afterNum into endNum
   --
   put char startNum to endNum of tHtml into titleBit
end _Offset


--> Help
-
function tiddlyFile_Construct shortFile, wDomain, pShortFolder
   put tiddlyFolder_Get (wDomain, pShortFolder) into tiddlyFolder
   put tiddlyFolder & shortFile into mFile
   return mFile
end tiddlyFile_Construct

function tiddlyFile_ListShort wDomain, pShortFolder
   put tiddlyFolder_Get (wDomain, pShortFolder) into tiddlyFolder
   put files (tiddlyFolder) into shortFiles
   filter shortFiles with "*.html"
   return shortFiles
end tiddlyFile_ListShort

function tiddlyFolder_Get wDomain, pShortFolder
   -- was tiddly_WikiFolder
   if pShortFolder is empty then put "tiddly-wikis" into pShortFolder
   --
   put wikiFolder_ConstructAssets (wDomain, pShortFolder) into tiddlyFolder
   folder_CreateNested tiddlyFolder
   return tiddlyFolder
end tiddlyFolder_Get


--> Tiddly | List
-
function tiddly_ListShortTemplates pForce
   if pForce is true then tiddly_LoadShortTemplates
   --
   put LocalArray ["tiddly_ShortTemplates"] into tFiles
   return tFiles
end tiddly_ListShortTemplates

function tiddly_ListShortFiles pForce
   if pForce is true then tiddly_LoadShortFiles
   --
   put LocalArray ["tiddly_ListShortFiles"] into mFiles
   return mFiles
end tiddly_ListShortFiles

function tiddly_GetReadmeData pForce
   if pForce is true then tiddly_LoadReadmeData
   --
   put LocalArray ["tiddly_ReadmeData"] into readmeData
   return readmeData
end tiddly_GetReadmeData


--> Tiddly
-
function tiddly_OpenReadmeNames
   put tiddly_ReadmeNameArray() into nameArray
   put keys (nameArray) into rNames
   sort rNames
   return rNames
end tiddly_OpenReadmeNames

function tiddly_ReadmeNameArray
   return LocalArray ["tiddly_ReadmeData"]["nameArray"]
end tiddly_ReadmeNameArray

function tiddly_OpenWikiMenu pForce
   put LocalArray ["tiddly_OpenWikiMenu"] into openWikiMenu
   return openWikiMenu
end tiddly_OpenWikiMenu

function tiddly_ConstructOpenWikiMenu
   put stack_ListNames("Project *") into myMenu
   get stack_ListNames("Module *")
   if it is empty then
      return myMenu
   else if myMenu is empty then
      return it
   else
      put CR & "-" after myMenu
      put CR & it after myMenu
      return myMenu
   end if
end tiddly_ConstructOpenWikiMenu


--> Tiddly | Init
-
command tiddly_InitMenuCache
   tiddly_LoadReadmeData
   tiddly_LoadOpenWikiMenu
   --
   tiddly_LoadShortTemplates
end tiddly_InitMenuCache

command tiddly_LoadShortFiles
   # Default asset Files of View|TiddlyWiki Template
   put default_FirstStackControl ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles of tiddlyTemplate into mFiles
   --
   put mFiles into LocalArray ["tiddly_ListShortFiles"]
end tiddly_LoadShortFiles

command tiddly_LoadShortTemplates
   # Default asset Files of View|TiddlyWiki Template
   put default_FirstStackControl ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles ["template"] of tiddlyTemplate into tFiles
   
   put tFiles into LocalArray ["tiddly_ShortTemplates"]
end tiddly_LoadShortTemplates

command tiddly_LoadReadmeData
   put _ListReadmeData() into readmeData
   put readmeData into LocalArray ["tiddly_ReadmeData"]
end tiddly_LoadReadmeData

command tiddly_DeleteOpenWikiMenu stackName
   get LocalArray ["tiddly_OpenWikiMenu"]
   line_Delete stackName, it
   put it into LocalArray ["tiddly_OpenWikiMenu"]
end tiddly_DeleteOpenWikiMenu

command tiddly_LoadOpenWikiMenu
   put tiddly_ConstructOpenWikiMenu() into LocalArray ["tiddly_OpenWikiMenu"]
end tiddly_LoadOpenWikiMenu


--> Env
-
function env_ListReadmePaths pForce
   put tiddly_GetReadmeData (pForce) into readmeData
   --
   put readmeData ["projectReadmeFiles"] into projectReadmeFiles
   put readmeData ["moduleReadmeFiles"] into moduleReadmeFiles
   return word 1 to -1 of moduleReadmeFiles & CR & projectReadmeFiles
end env_ListReadmePaths

function env_ListReadmeNames pForce
   put tiddly_GetReadmeData (pForce) into readmeData
   --
   put readmeData ["projectReadmeNames"] into projectReadmeNames
   put readmeData ["moduleReadmeNames"] into moduleReadmeNames
   return word 1 to -1 of moduleReadmeNames & CR & projectReadmeNames
end env_ListReadmeNames

function env_ReadmeNameArray pForce
   put tiddly_GetReadmeData (pForce) into readmeData
   put readmeData ["nameArray"] into nameArray
   return nameArray
end env_ReadmeNameArray


--> Private
-
private function _ListReadmeData
   put env_GetRepoFolder() into repoFolder
   put folders (repoFolder) into shortFolders
   set the itemdelimiter to slash
   repeat for each line projectName in shortFolders
      if char 1 of projectName = "." then next repeat
      --
      -- set the cursor to busy
      put repoFolder & projectName & "/README.html" into sFile
      if there is a file sFile then
         put sFile & CR after projectReadmeFiles
         put projectName & CR after projectReadmeNames
         put sFile into readmeData ["nameArray"][projectName]
      end if
      
      put project_ListModuleFolders (projectName) into moduleFolders
      repeat for each line moduleFolder in moduleFolders
         -- set the cursor to busy
         --
         put moduleFolder & "README.html" into sFile
         if there is a file sFile then
            put sFile & CR after moduleReadmeFiles
            --
            put item -1 of moduleFolder into moduleName
            replace "_" with "|" in moduleName
            put moduleName & CR after moduleReadmeNames
            --
            put sFile into readmeData ["nameArray"][moduleName]
         end if
      end repeat
   end repeat
   --
   delete char -1 of projectReadmeNames
   delete char -1 of projectReadmeFiles
   delete char -1 of moduleReadmeNames
   delete char -1 of moduleReadmeFiles
   --
   put projectReadmeNames into readmeData ["projectReadmeNames"]
   put projectReadmeFiles into readmeData ["projectReadmeFiles"]
   put moduleReadmeNames into readmeData ["moduleReadmeNames"]
   put moduleReadmeFiles into readmeData ["moduleReadmeFiles"]
   --
   return readmeData
end _ListReadmeData
