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


--> Init
-
command tiddly_InitMenuCache
   tiddly_LoadReadmeData
   tiddly_LoadOpenWikiMenu
   --
   tiddly_LoadShortTemplates
end tiddly_InitMenuCache

command tiddly_LoadShortFiles
   # Default asset Files of View|TiddlyWiki Template
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles of tiddlyTemplate into mFiles
   --
   put mFiles into LocalArray ["tiddly_ListShortFiles"]
end tiddly_LoadShortFiles

command tiddly_LoadShortTemplates
   # Default asset Files of View|TiddlyWiki Template
   put view_GetTemplateObject ("View|TiddlyWiki") into tiddlyTemplate
   put the module_ShortHtmlFiles ["template"] of tiddlyTemplate into tFiles
   
   put tFiles into LocalArray ["tiddly_ShortTemplates"]
end tiddly_LoadShortTemplates

command tiddly_LoadReadmeData
   put _ListReadmeData() into readmeData
   put readmeData into LocalArray ["tiddly_ReadmeData"]
end tiddly_LoadReadmeData

command tiddly_LoadOpenWikiMenu
   put tiddly_ConstructOpenWikiMenu() into LocalArray ["tiddly_OpenWikiMenu"]
end tiddly_LoadOpenWikiMenu

function tiddly_GetReadmeData pForce
   if pForce is true then tiddly_LoadReadmeData
   --
   put LocalArray ["tiddly_ReadmeData"] into readmeData
   return readmeData
end tiddly_GetReadmeData

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


--> Working on
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

getprop readme_Folder
   put the module_Folder of the target into readmeFolder
   if there is not a folder readmeFolder then
      put the project_Folder of the target into readmeFolder
   end if
   return readmeFolder
end readme_Folder

function tiddly_OpenReadmeNames
   put tiddly_ReadmeNameArray() into nameArray
   put keys (nameArray) into rNames
   sort rNames
   return rNames
end tiddly_OpenReadmeNames

function tiddly_ReadmeNameArray
   return LocalArray ["tiddly_ReadmeNameArray"]
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

function readme_GetColour readMeFile
   -- we want to use the flag colour
   put "random" into sColour
   return sColour
end readme_GetColour

command display_TiddlyURL tiddlyURL, pTiddlyView, pFullScreen
   if pFullScreen is empty then put the shiftKey is "Down" into pFullScreen
   --
   put tiddly_ReadmeLabelFromUrl (tiddlyURL) into readmeLabel
   --
   put readme_GetColour (tiddlyURL) into cardColour
   --
   set the itemdelimiter to slash   
   put item -2 to -1 of tiddlyURL into subTitle
   put word 1 to -2 of readmeLabel into tiddlyTitle
   
   # Display
   switch
      case exists (pTiddlyView)
         put pTiddlyView into tiddlyView
         tiddly_SetBehavior tiddlyView
         
         set the browser_URL of tiddlyView to tiddlyURL
         break
      case exists (stack readmeLabel)
         go to stack readmeLabel
         put the tiddly_View of this cd into tiddlyView
         break
      default
         display_CloneModule TiddlyModuleName, tiddlyURL, subTitle, "browser_URL", "toplevel", readmeLabel, 20, cardColour
         put the result into tiddlyView
   end switch
   
   put the stack_Name of tiddlyView into stackName -- should already be set
   --- put tiddly_StackNameToLabel (stackName) into tiddlyLabel
   set the tiddly_Title [subTitle] of tiddlyView to tiddlyTitle
   if pFullScreen is true then
      set the fullscreen of stack stackName to true
   end if
   
   return tiddlyView
end display_TiddlyURL

command tiddly_SetBehavior tiddlyView, pWhich
   switch pWhich
      case "Wiki"
         put the name of stack "behavior_ViewWikiBrowser" into bObject
         break
      default
         put the name of stack "behavior_ViewTiddlyWiki" into bObject
   end switch
   --
   set the behavior of tiddlyView to bObject
end tiddly_SetBehavior

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


--> Props
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

setprop tiddly_Behavior sBoolean
   put module_GetBehavior (TiddlyModuleName) into bObject
   if exists (bObject) is false then return empty
   
   if sBoolean is true then
      set the behavior_Add of the target to TiddlyModuleName
   else
      set the behavior_Remove of the target to TiddlyModuleName
   end if
end tiddly_Behavior


--> Display
-
command edit_TiddlyHtml
   -- put the tempname & ".html" into sPath
   put the browser_File [true] of the target into sFile
   put trash_File (sFile) into sPath
   --
   put the tiddly_Html of the target into tHTML
   text_Set sPath, tHTML
   code_EditFile sPath
end edit_TiddlyHtml

command display_TiddlyWiki sFileOrUrl, pTiddlyView, pFullScreen
   set the itemdelimiter to slash
   put url_GetProtocol (sFileOrUrl) into sProtocol
   switch
      case sProtocol is among the items of "http/https"
         put sFileOrUrl into tiddlyURL
         display_TiddlyURL tiddlyURL, pTiddlyView, pFullScreen
         break
      case the number of items of sFileOrUrl = 1
         put tiddly_File (sFileOrUrl) into tiddlyFile
         display_TiddlyFile tiddlyFile, pTiddlyView, pFullScreen
         break
      default
         put sFileOrUrl into tiddlyFile
         display_TiddlyFile tiddlyFile, pTiddlyView, pFullScreen
   end switch
   put the result into tiddlyView
   return tiddlyView
end display_TiddlyWiki

command display_TiddlyTemplate shortTemplateFile, pTiddlyView, pFullScreen
   put tiddly_TemplateFile (shortTemplateFile) into tFile
   
   # Display tiddlyView create if it doesn't exist
   display_TiddlyFile tFile, pTiddlyView, pFullScreen
   put the result into tiddlyView
   return tiddlyView
end display_TiddlyTemplate

command display_ProjectReadme projectName, pTiddlyView, pFullScreen
   if pFullScreen is empty then put the shiftKey is "Down" into pFullScreen
   --
   put project_ConstructReadMeFile (projectName) into readMeFile
   
   # Create README if needed
   put there is not a file readMeFile into needToCreate
   if needToCreate then
      tiddly_CreateProjectReadMe projectName, "projectify.html"
      put the result into readMeFile
      if there is not a file readMeFile then
         breakpoint
         return "Error, could not create README.html:" && readMeFile
      end if
   end if
   --
   -- put label_FromProjectName (projectName) into tiddlyLabel
   --
   display_TiddlyFile readMeFile, pTiddlyView, pFullScreen
   put the result into tiddlyView
   return tiddlyView
end display_ProjectReadme

command display_ModuleReadme moduleName, pTiddlyView, pFullScreen
   if pFullScreen is empty then put the shiftKey is "Down" into pFullScreen
   --
   # Create README
   put module_ConstructReadMeFile (moduleName) into readMeFile
   put there is not a file readMeFile into needToCreate
   if needToCreate then
      tiddly_CreateModuleReadMe moduleName, "projectify.html"
      put the result into readMeFile
      if there is not a file readMeFile then
         breakpoint
         return "Error, could not create README.html:" && readMeFile
      end if
   end if
   
   -- put label_FromModuleName (moduleName) into tiddlyLabel
   --
   display_TiddlyFile readMeFile, pTiddlyView, pFullScreen
   put the result into tiddlyView
   return tiddlyView
end display_ModuleReadme

command display_TiddlyFile readMeFile, pTiddlyView, pFullScreen
   put "file://" & readMeFile into tiddlyURL
   display_TiddlyURL tiddlyURL, pTiddlyView, pFullScreen
   put the result into tiddlyView
   return tiddlyView
end display_TiddlyFile

function project_ConstructReadMeFile projectName
   put project_GetFolder (projectName) into projectFolder
   put projectFolder & "README.html" into readMeFile
   return readMeFile
end project_ConstructReadMeFile


--> Module
-
function module_ConstructReadMeFile moduleName
   if there is not a stack moduleName then
      return "Error, module does not exists:" && moduleName
   end if
   
   put the module_ReadMeFile of stack moduleName into readMeFile
   return readMeFile
end module_ConstructReadMeFile

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
