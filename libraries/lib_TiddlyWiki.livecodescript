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


--> Tiddly | Create
-
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


--> Project
-
function project_ConstructReadMeFile projectName
   put project_GetFolder (projectName) into projectFolder
   put projectFolder & "README.html" into readMeFile
   return readMeFile
end project_ConstructReadMeFile
