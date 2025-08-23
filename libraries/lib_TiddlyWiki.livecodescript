script "lib_TiddlyWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_TiddlyWiki
type: library
version: 0.1

/*
A library to help organise multiple TiddlyWiki's
*/

--> Variables
-
constant TiddlyModuleName = "View|TiddlyWiki"
constant DefaultShortTemplate = "empty.html"
local LocalArray


--> Working on
-


--> Props
-
getprop guide_Array
   put the module_Array of the target into moduleArray
   if moduleArray is not an array then
      put module_ConstructArray (moduleFolder) into moduleArray
      breakpoint
   end if
   --
   put moduleArray ["stackFileArray"] into stackFileArray
   return stackFileArray
end guide_Array

setprop tiddly_Behavior sBoolean
   put module_GetBehavior (TiddlyModuleName) into bObject
   if exists (bObject) is false then return empty
   
   if sBoolean is true then
      set the behavior_Add of the target to TiddlyModuleName
   else
      set the behavior_Remove of the target to TiddlyModuleName
   end if
end tiddly_Behavior


--> Props | Readme
-
getprop readMe_Html
   put the readMe_File of the target into readMeFile
   return url ("file:" & readMeFile)
end readMe_Html

getprop readMe_File
   put the readme_Folder of the target into moduleFolder
   --
   if there is a folder moduleFolder then
      put moduleFolder & "README.html" into readMeFile
   else
      return the project_ReadmeFile of the target
   end if
   return readMeFile
end readMe_File

getprop module_ReadMeFile
   put the readme_Folder of the target into moduleFolder
   --
   put moduleFolder & "README.html" into readMeFile
   return readMeFile
end module_ReadMeFile

getprop project_ReadmeFile
   put the project_Name of the target into projectName
   if projectName is empty then return empty
   
   put project_ConstructReadMeFile (projectName) into readMeFile
   if there is a file readMeFile then
      return readMeFile
   else
      return empty
   end if
end project_ReadmeFile

getprop readme_Folder
   put the module_Folder of the target into readmeFolder
   if there is not a folder readmeFolder then
      put the project_Folder of the target into readmeFolder
   end if
   return readmeFolder
end readme_Folder


--> Module
-
function module_ConstructMarkdown stackFileArray
   repeat for each key stackName in stackFileArray
      put "#" && stackName after mdText
      put stackFileArray [stackName] into relPath
      --
      put the handlerLine_Bullets of stack stackName into mdSection
      put CR & mdSection after mdText
      put CR&CR after mdText
   end repeat
   put word 1 to -1 of mdText into mdText
   return mdText
end module_ConstructMarkdown

function module_ConstructReadMeFile moduleName
   if there is not a stack moduleName then
      return "Error, module does not exists:" && moduleName
   end if
   
   put the module_ReadMeFile of stack moduleName into readMeFile
   return readMeFile
end module_ConstructReadMeFile

function project_ConstructReadMeFile projectName
   put project_GetFolder (projectName) into projectFolder
   put projectFolder & "README.html" into readMeFile
   return readMeFile
end project_ConstructReadMeFile


--> TiddlyHtml
-
command tiddlyHtml_AddJson @tHtml, newJSON
   -- {"created":"20250120202856098","text":"show","title":"$:/config/PageControlButtons/Visibility/$:/core/ui/Buttons/home","modified":"20250120202856098"},
   
end tiddlyHtml_AddJson


--> TiddlyReadme
-
function tiddlyReadme_GetJson rName
   put tiddlyReadme_GetHtml(rName) into tHtml
   put tiddlyHtml_GetSection (tHtml, pHeader) into oSection
   put tiddlyHtml_JsonFromSection (oSection) into tJSON
   return tJSON
end tiddlyReadme_GetJson

function tiddlyReadme_GetHtml rName
   put tiddlyReadme_File (rName) into tiddlyFile
   put text_Get (tiddlyFile) into tiddlyHtml
   return tiddlyHtml
end tiddlyReadme_GetHtml

function tiddlyReadme_File rName
   put env_ReadmeNameArray() into nameArray
   put nameArray [rName] into tiddlyFile
   return tiddlyFile
end tiddlyReadme_File


--> TiddlyMenu
-
function tiddlyMenu_GetData mTitle
   put tiddlyMenu_GetJson (mTitle) into tJSON
   
   # Very slow
   -- put json_ToArray (tJSON) into tData
   try
      put jsonImport (tJSON) into tArray
      return tData
   catch e
      return empty
   end try
end tiddlyMenu_GetData

function tiddlyMenu_GetJson mTitle, pHeader
   put tiddlyMenu_GetHelp (mTitle) into tHtml
   put tiddlyHtml_GetSection (tHtml, pHeader) into oSection
   put tiddlyHtml_JsonFromSection (oSection) into tJSON
   return tJSON
end tiddlyMenu_GetJson

function tiddlyMenu_GetHelp mTitle
   put help_TiddlyMenuFile (mTitle) into tiddlyFile
   put text_Get (tiddlyFile) into tiddlyHtml
   return tiddlyHtml
end tiddlyMenu_GetHelp

command tiddlyMenu_SetHelp mTitle, tiddlyHtml
   put help_TiddlyMenuFile (mTitle) into tiddlyFile
   text_Set tiddlyFile, tiddlyHtml
   return tiddlyFile
end tiddlyMenu_SetHelp


--> Tiddler
-
function tiddly_DateItems tiddlyDate, pFormat
   -- put tiddly_DateItems ("20250719093701")
   -- YYYYMMDDHHMMSSmmm (in UTC)
   
   # Year
   get char 1 to 4 of tiddlyDate
   put it into item 1 of sDate
   
   # Months
   get char 5 to 6 of tiddlyDate
   put it into item 2 of sDate
   
   # Days
   get char 7 to 8 of tiddlyDate
   put it into item 3 of sDate
   
   # Hours
   get char 9 to 10 of tiddlyDate
   put it into item 4 of sDate
   
   # Minutes
   get char 11 to 12 of tiddlyDate
   put it into item 5 of sDate
   
   # Seconds
   get char 13 to 14 of tiddlyDate
   put it into item 6 of sDate
   
   # Hack
   put 0 into item 7 of sDate -- ugly hack for Livecode
   
   -- Format
   switch pFormat
      case "dateitems"
         convert sDate to dateitems
         break
      case "seconds"
         convert sDate to seconds
         break
      case empty
      default
         convert sDate to internet date
   end switch
   --
   return sDate
end tiddly_DateItems

function tiddly_Date pDate
   -- YYYYMMDDHHMMSSmmm (in UTC)
   if pDate is empty then
      put the seconds into pDate
   end if
   convert pDate to dateitems
   
   # Year
   put item 1 of pDate into tDate
   
   # Months
   get item 2 of pDate
   number_PadLeft it, 2
   put it after tDate
   
   # Days
   get item 3 of pDate
   number_PadLeft it, 2
   put it after tDate
   
   # Hours
   get item 4 of pDate
   number_PadLeft it, 2
   put it after tDate
   
   # Minutes
   get item 5 of pDate
   number_PadLeft it, 2
   put it after tDate
   
   # Seconds
   get item 6 of pDate
   number_PadLeft it, 2
   put it after tDate
   
   return tDate
end tiddly_Date

function tiddler_ConstructItemJson sTitle, sText, pTags, pType
   if pType is empty then put "text/markdown" into pType
   
   put tiddler_ConstructItemArray (sTitle, sText, pTags, pType) into iArray
   put jsonExport (iArray) into iJSON
   return iJSON
end tiddler_ConstructItemJson

function tiddler_ConstructItemArray sTitle, sText, pTags, pType, mDate, cDate
   # Add basics
   put sText into iArray ["text"]
   put sTitle into iArray ["title"]
   
   # Add created
   if cDate is empty then
      put tiddly_Date() into cDate
   end if
   put cDate into iArray ["created"]
   
   # If tags
   if pTags is not empty then
      put pTags into iArray ["tags"]
   end if
   
   # If type
   if pType is not empty then
      put pType into iArray ["type"]
   end if
   
   # Add modified
   if mDate is empty then
      put tiddly_Date() into mDate
   end if
   put mDate into iArray ["modified"]
   return iArray
end tiddler_ConstructItemArray

function tiddlyHtml_ListSections tHtml
   filter tHtml with "<!--~~ * ~~-->"
   return tHtml
end tiddlyHtml_ListSections

function tiddlyHtml_JsonFromSection oSection
   -- quick hack
   
   -- <script class="tiddlywiki-tiddler-store" type="application/json">
   put offset (">", oSection) into endNum
   delete char 1 to endNum of oSection
   
   # Not robust?
   -- </script><div id="storeArea" style="display:none;"></div>
   put offset ("</script>", oSection) into startNum
   delete char startNum to -1 of oSection
   
   return oSection
end tiddlyHtml_JsonFromSection

function tiddlyHtml_OrdinaryEndNum tHtml
   get tiddlyHtml_ConstructSection ("Ordinary tiddlers")
   put offset (it, tHtml) into startNum
   get offset ("</script>", tHtml, startNum)
   put it + startNum - 1 into endNum
   return endNum
end tiddlyHtml_OrdinaryEndNum

function tiddlyHtml_GetSection tHtml, pHeader
   -- get "<!--~~ Ordinary tiddlers ~~-->"
   if pHeader is empty then
      put "Ordinary tiddlers" into pHeader
   end if
   get tiddlyHtml_ConstructSection (pHeader)
   
   put lineOffset (it, tHtml) + 1 into startNum
   ---
   get "<!--~~ Library modules ~~-->"
   put lineOffset (it, tHtml) - 1 into endNum
   --
   get line startNum to endNum of tHtml
   return it
end tiddlyHtml_GetSection

function tiddlyHtml_ConstructSection sHeader
   --  put "<!--" && commentKey && "-->" into htmlComment
   return "<!--~~ " & sHeader & " ~~-->"
end tiddlyHtml_ConstructSection


--> Tiddly | Create
-
command tiddly_Create tFile, pShortTemplate
   if there is a file tFile then
      return "Error, tiddly file already exists:" && tFile
   end if
   if pShortTemplate is empty then
      put "projectify.html" into pShortTemplate
   end if
   
   put tiddly_DefaultFile (pShortTemplate) into tiddlyTemplateFile
   if there is not a file tiddlyTemplateFile then
      breakpoint
      put tiddly_DefaultFile() into tiddlyTemplateFile
   end if
   --
   revCopyFile tiddlyTemplateFile, tFile
   if the result is empty then
      return tFile
   else
      return "Error, failed to create file:" && tFile
   end if
end tiddly_Create

command tiddly_CreateModuleReadMe moduleName, pShortFile
   put tiddly_DefaultFile (pShortFile) into tiddlyDefaultFile
   if there is not a file tiddlyDefaultFile then
      breakpoint
      put tiddly_DefaultFile() into tiddlyDefaultFile
   end if
   put module_ConstructReadMeFile (moduleName) into readMeFile
   --
   revCopyFile tiddlyDefaultFile, readMeFile
   if the result is empty then
      return readMeFile
   else
      return "Error, failed to create file:" && readMeFile
   end if
end tiddly_CreateModuleReadMe

command tiddly_CreateProjectReadMe projectName, pShortFile
   put tiddly_DefaultFile (pShortFile) into tiddlyDefaultFile
   if there is not a file tiddlyDefaultFile then
      breakpoint
      put tiddly_DefaultFile() into tiddlyDefaultFile
   end if
   put project_ConstructReadMeFile (projectName) into readMeFile
   --
   revCopyFile tiddlyDefaultFile, readMeFile
   if the result is empty then
      return readMeFile
   else
      return "Error, failed to create file:" && readMeFile
   end if
end tiddly_CreateProjectReadMe


--> TiddlyWiki
-
command tiddly_ReplacePipe @sContent
   -- not sure best way to standardise this?
   -- thinking that we don;t use pipes in anes anymore
   -- instead words with CamelCase
   replace "|" with space in sContent
   -- replace "|" with empty in sContent -- maybe do this as well
   -- replace "|" with "-" in sContent -- Correctly escape the pipe
end tiddly_ReplacePipe

command tiddler_ReplaceQuotes @sContent
   -- not sure best way to standardise this?
   replace "\" with "\\\" in sContent  -- ???
   replace "'" with "\\'" in sContent   -- Escape single quotes properly
end tiddler_ReplaceQuotes

function tiddly_Bullets sIndex
   repeat for each line someLine in sIndex
      if someLine contains "_" then
         put "- [[" & someLine & "|" & someLine & "]]" & CR after sBullets
      else
         put "- [[" & someLine & "]]" & CR after sBullets
      end if
   end repeat
   delete char -1 of sBullets
   return sBullets
end tiddly_Bullets

function tiddly_HandlerBullets hTable, pFilter
   sort numeric lines of hTable by word 3 of each
   if pFilter is not empty then filter hTable with pFilter
   --
   repeat for each line someLine in hTable
      -- put word 1 to 2 of someLine into shortHkey
      put hkeyLine_ToHandlerLine (someLine) into handlerLine
      if handlerLine contains "_" then
         put "- [[" & handlerLine & "|" & handlerLine & "]]" & CR after handlerLineBullets
      else
         put "- [[" & handlerLine & "]]" & CR after handlerLineBullets
      end if
   end repeat
   delete char -1 of handlerLineBullets
   return handlerLineBullets
end tiddly_HandlerBullets


--> TiddlyWiki | ReadMe | Module
-
command tiddly_EditModuleReadme moduleName
   put module_ConstructReadMeFile (moduleName) into readMeFile
   --
   code_EditFile readMeFile
   return readMeFile
end tiddly_EditModuleReadme


--> TiddlyWiki | ReadMe | Project
-
command tiddly_EditReadme projectName
   put project_ConstructReadMeFile (projectName) into readMeFile
   --
   code_EditFile readMeFile
   return readMeFile
end tiddly_EditReadme


--> Tiddly | File
-
function tiddly_File shortFile
   put tiddly_ConstructFile (shortFile) into tiddlyFile
   if there is not a file tiddlyFile then
      # Use a default
      put tiddly_ConstructFile ("index.html") into defaultTiddlyFile
      return defaultTiddlyFile
   else
      return tiddlyFile
   end if
end tiddly_File

function tiddly_TemplateFile shortTemplateFile
   put "template/" & shortTemplateFile into relPath
   return tiddly_File (relPath)
end tiddly_TemplateFile

function tiddly_ConstructFile sFilePath
   put the module_HtmlFile [sFilePath] of stack TiddlyModuleName into tiddlyFile
   return tiddlyFile
end tiddly_ConstructFile

function tiddly_DefaultFile pShortFile
   -- put "projectify.html" into readmeDefault
   if pShortFile is empty then put DefaultShortTemplate into pShortFile
   --
   put tiddly_DefaultFolder() & pShortFile into dFile
   return dFile
end tiddly_DefaultFile

function tiddly_DefaultFolder
   put the module_AssetFolder ["template"] of stack "View|TiddlyWiki" into dFolder
   folder_CreateNested dFolder
   return dFolder
end tiddly_DefaultFolder


--> Private
-
