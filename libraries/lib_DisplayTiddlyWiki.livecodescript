script "lib_DisplayTiddlyWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayTiddlyWiki
type: library
version: 0.4


--> Working on
-
function readme_GetColour readMeFile
   -- we want to use the flag colour
   put "random" into sColour
   return sColour
end readme_GetColour

command edit_TiddlyHtml
   -- put the tempname & ".html" into sPath
   put the browser_File [true] of the target into sFile
   put trash_File (sFile) into sPath
   --
   put the tiddly_Html of the target into tHTML
   text_Set sPath, tHTML
   code_EditFile sPath
end edit_TiddlyHtml

command display_TiddlyTool
   ecoData_SetFarmAndGardens
   put wikiGarden_ListShortFolders() into gardenFolders
   url_SortDomainIndex gardenFolders
   --
   display_Tool gardenFolders, "Nextcloud", "Tiddly Tool"
   put the result into dView
   set the tool_Context of dView to "lcw_P2P"
   return dView
end display_TiddlyTool

command display_CreateMenuDoc mTitle
   put label_FromMenuTitle (mTitle) into mLabel
   put help_TiddlyMenuFile (mTitle) into mFile
   --
   tiddly_Create mFile
   put the result into mFile
   if item 1 of mFile is "Error" then return mFile
   --
   display_TiddlyWikiFile mFile, mLabel
   put the result into tiddlyView
   return tiddlyView
end display_CreateMenuDoc

command display_TiddlyWikiFile mFile, pLabel
   if pLabel is empty then
      set the itemdelimiter to slash
      get item -1 of mFile 
      set the itemdelimiter to "."
      put item 1 of it into pLabel
   end if
   
   # Display
   display_TiddlyWiki mFile
   put the result into tiddlyView
   
   # Label
   put empty into strapline
   set the stack_Label of tiddlyView to pLabel
   
   wait 20 ticks
   -- set the tiddly_Title [strapline] of tiddlyView to pLabel
   
   -- put the tiddler_Exists ["About"] of tiddlyView into tExists
   -- set the tiddler_Markdown ["About"]  of tiddlyView to "Hello [[world]]!"
   --
   put the menuBar_View of tiddlyView into mBarView
   set the menuButton_Title of btn 2 of mBarView to "Global | Help | Tiddly | Menu"
   return tiddlyView
end display_TiddlyWikiFile

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


--> Display | Tiddly | Wiki
-
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
   -- put label_FromModuleName (moduleName) into readmeLabel
   -- put stack_CloneName (moduleName) into readmeLabel
   put tiddly_ReadmeLabelFromUrl (tiddlyURL) into readmeLabel
   --
   set the itemdelimiter to slash   
   put item -2 to -1 of tiddlyURL into subTitle
   put word 1 to -2 of readmeLabel into tiddlyTitle
   
   # Display
   switch
      case exists (pTiddlyView)
         put pTiddlyView into tiddlyView
         set the tiddly_URL of tiddlyView to tiddlyURL
         break
      case exists (stack readmeLabel)
         go to stack readmeLabel
         show stack readmeLabel
         put the tiddly_View of this cd into tiddlyView
         set the tiddly_URL of tiddlyView to tiddlyURL
         break
      default
         put readme_GetColour (tiddlyURL) into cardColour
         --
         put default_FirstStackControl (moduleName) into moduleObject
         display_CloneModuleObject moduleObject, tiddlyURL, readmeLabel, "tiddly_URL", "random"
         put the result into tiddlyView
   end switch
   
   if pFullScreen is true then
      put the stack_Name of tiddlyView into stackName -- should already be set
      set the fullscreen of stack stackName to true
   end if
   
   return tiddlyView
end display_TiddlyURL

command display_CloneModuleObject moduleObject, pData, pStackLabel, pDataProp, pColour, pStackStyle
   # Check moduleObject
   if exists (moduleObject) is false then
      put "Error, no template object found for:" && moduleObject into sError
      return sError -- throw sError -- bug: hangs with supress messages true
   end if  
   
   # Check moduleName
   put the view_Name of moduleObject into moduleName
   if moduleName is empty then return "Error, not a view:" && moduleObject
   put the stack_Name of moduleObject into cloneStackName
   
   # Set Defaults
   if pStackLabel is empty then
      put label_FromModuleName (moduleName) into pStackLabel
   end if
   
   # Set Defaults
   if pDataProp is empty then put "displayed_Data" into pDataProp
   if pStackStyle is empty then put "toplevel" into pStackStyle
   
   if exists (stack pStackLabel) then
      go to stack pStackLabel
   else
      # Clone
      clone invisible stack cloneStackName
      put it into clonedStack
      set the name of clonedStack to pStackLabel
   end if
   --
   put the name of stack pStackLabel into labeledStack
   
   # Set props
   put the module_View of cd 1 of stack labeledStack into clonedViewObject
   if exists (clonedViewObject) then
      # Set the data to display
      set the pDataProp of clonedViewObject to pData
      set the card_Colour of clonedViewObject to pColour
      --
      put the globalloc of the mouseLoc into gLoc
      set the topleft of stack labeledStack to gLoc
      --
      set the label of stack labeledStack to empty
   end if
   --
   set the visible of stack labeledStack to true
   --
   return clonedViewObject
end display_CloneModuleObject

command display_TiddlyTemplate shortTemplateFile, pTiddlyView, pFullScreen
   put tiddly_TemplateFile (shortTemplateFile) into tFile
   
   # Display tiddlyView create if it doesn't exist
   display_TiddlyFile tFile, pTiddlyView, pFullScreen
   put the result into tiddlyView
   --
   set the stack_Label of tiddlyView to ("Template:" && shortTemplateFile)
   --
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

command display_Readme rName, pTiddlyView, pFullScreen
   put tiddlyReadme_File (rName) into readMeFile
   --
   display_TiddlyFile readMeFile, pTiddlyView, pFullScreen
   put the result into tiddlyView
   return tiddlyView
end display_Readme
