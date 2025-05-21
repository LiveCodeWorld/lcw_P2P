script "lib_DisplayTiddlyWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayTiddlyWiki
type: library
version: 0.2


--> Varaibles
-
local LocalArray


--> Working on
-
function readme_GetColour readMeFile
   -- we want to use the flag colour
   put "random" into sColour
   return sColour
end readme_GetColour


--> Display | Tiddly | Wiki
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

command display_TiddlyFile readMeFile, pTiddlyView, pFullScreen
   put "file://" & readMeFile into tiddlyURL
   display_TiddlyURL tiddlyURL, pTiddlyView, pFullScreen
   put the result into tiddlyView
   return tiddlyView
end display_TiddlyFile

command display_TiddlyURL tiddlyURL, pTiddlyView, pFullScreen
   put "View|TiddlyWiki" into moduleName
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
         display_CloneModule moduleName, tiddlyURL, subTitle, "browser_URL", "toplevel", readmeLabel, 20, cardColour
         put the result into tiddlyView
   end switch
   
   --- put tiddly_StackNameToLabel (stackName) into tiddlyLabel
   -- set the tiddly_Title [subTitle] of tiddlyView to tiddlyTitle
   if pFullScreen is true then
      put the stack_Name of tiddlyView into stackName -- should already be set
      set the fullscreen of stack stackName to true
   end if
   
   return tiddlyView
end display_TiddlyURL

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


--> Tiddly
-
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
