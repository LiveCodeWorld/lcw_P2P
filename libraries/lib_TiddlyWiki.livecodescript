script "lib_TiddlyWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_TiddlyWiki
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_ModuleReadme moduleName, pBrowserView
   put module_ConstructReadMeFile (moduleName) into readMeFile
   if there is not a file readMeFile then
      tiddly_CreateReadMe moduleName
      put the result into readMeFile
      if there is not a file readMeFile then
         breakpoint
         return "Error, could not create readme.html:" && readMeFile
      end if
   end if
   --
   put "file:///" & readMeFile into someURL
   put moduleName && "Readme" into stackLabel
   --
   display_Browser someURL, pBrowserView, stackLabel, "toplevel", "View|TiddlyWiki"
   put the result into tiddlyView
   --
   -- set the readMe_File of tiddlyView to readMeFile
   return tiddlyView
end display_ModuleReadme

command display_Readme projectName, pBrowserView
   put project_ReadMeFile (projectName) into readMeFile
   if there is not a file readMeFile then
      tiddly_CreateReadMe projectName
      put the result into readMeFile
      if there is not a file readMeFile then
         breakpoint
         return "Error, could not create readme.html:" && readMeFile
      end if
   end if
   --
   put "file:///" & readMeFile into someURL
   put projectName && "Readme" into stackLabel
   --
   display_Browser someURL, pBrowserView, stackLabel, "toplevel", "View|TiddlyWiki"
   put the result into tiddlyView
   --
   -- set the readMe_File of tiddlyView to readMeFile
   return tiddlyView
end display_Readme


--> Module
-
getprop module_ReadMeFile
   put the module_Folder of the target into moduleFolder
   --
   put moduleFolder & "readme.html" into readMeFile
   return readMeFile
end module_ReadMeFile

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

command tiddly_CreateModuleReadMe moduleName, pShortFile
   put tiddly_DefaultFile (pShortFile) into tiddlyDefaultFile
   put module_ConstructReadMeFile (moduleName) into readMeFile
   --
   revCopyFile tiddlyDefaultFile, readMeFile
   if the result is empty then
      return readMeFile
   else
      return "Error, failed to create file:" && readMeFile
   end if
end tiddly_CreateModuleReadMe

command tiddly_CreateReadMe projectName, pShortFile
   put tiddly_DefaultFile (pShortFile) into tiddlyDefaultFile
   put project_ReadMeFile (projectName) into readMeFile
   --
   revCopyFile tiddlyDefaultFile, readMeFile
   if the result is empty then
      return readMeFile
   else
      return "Error, failed to create file:" && readMeFile
   end if
end tiddly_CreateReadMe


--> TiddlyWiki | ReadMe | Project
-
command tiddly_EditReadme projectName
   put project_ReadMeFile (projectName) into readMeFile
   --
   code_EditFile readMeFile
   return readMeFile
end tiddly_EditReadme

command tiddly_CreateReadMe projectName, pShortFile
   put tiddly_DefaultFile (pShortFile) into tiddlyDefaultFile
   put project_ReadMeFile (projectName) into readMeFile
   --
   revCopyFile tiddlyDefaultFile, readMeFile
   if the result is empty then
      return readMeFile
   else
      return "Error, failed to create file:" && readMeFile
   end if
end tiddly_CreateReadMe

function project_ReadMeFile projectName
   put project_GetFolder (projectName) into projectFolder
   put projectFolder & "readme.html" into readMeFile
   return readMeFile
end project_ReadMeFile

function tiddly_DefaultFile pShortFile
   if pShortFile is empty then put "empty.html" into pShortFile
   --
   put tiddly_DefaultFolder() & pShortFile into dFile
   return dFile
end tiddly_DefaultFile

function tiddly_DefaultFolder
   put the module_AssetFolder ["template"] of stack "View|TiddlyWiki" into dFolder
   folder_CreateNested dFolder
   return dFolder
end tiddly_DefaultFolder


--> Deps
-
