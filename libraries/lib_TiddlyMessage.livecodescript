script "lib_TiddlyMessage"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_TiddlyMessage
type: library
version: 0.2

/*Some help*/


--> Working on
-

--> Tiddly | Button
-
command tiddly_UnhandledCommand sMessage, tiddlyView
   put "Unknown message: " & sMessage into sResult
   _UpdateAndPrepend sResult, tiddlyView
end tiddly_UnhandledCommand

command tiddly_RemoveGuideTools sMessage, tiddlyView
   put the menuBar_View of tiddlyView into mGroup
   
   # Delete mButtons
   set the menubar_Titles of mGroup to empty
   lcw_AnswerWarning "Deleted menus!", tiddlyView
   return the result
end tiddly_RemoveGuideTools

command tiddly_HkeyEdit sMessage
   _StripFirst sMessage
   --
   hkey_Edit sMessage
end tiddly_HkeyEdit

command tiddly_EditScript sMessage
   _StripFirst sMessage, quote
   --
   if exists (sMessage) then
      edit the script of sMessage
   else
      breakpoint
   end if
end tiddly_EditScript sMessage

function tiddly_AddPushButton
   put tiddly_ConstructButton ("Push", "git push") into btnText
   return btnText
end tiddly_AddPushButton

function tiddly_DiscardUntrackedButton
   put tiddly_ConstructButton ("Discard Untracked", "git discard untracked") into btnText
   return btnText
end tiddly_DiscardUntrackedButton

function tiddly_AddUntrackedButton
   put tiddly_ConstructButton ("Add Untracked", "git add untracked") into btnText
   return btnText
end tiddly_AddUntrackedButton

function tiddly_CommitChangesButton pAlsoAdd
   if pAlsoAdd is true then
      --  (use "git add" and/or "git commit -a")
      put tiddly_ConstructButton ("Commit and Add", "git commit and add") into btnText
   else
      put tiddly_ConstructButton ("Commit changes", "git commit") into btnText
   end if
   return btnText
end tiddly_CommitChangesButton

function tiddly_ConstructButton btnName, cMessage
   get "<$button>[[btnName]]<$callLivecode message='[[cMessage]]'/></$button>"
   replace "'" with quote in it
   put merge (it) into btnText
   return btnText
end tiddly_ConstructButton


--> Tidd;y | Git
-
command tiddly_Git sMessage, tiddlyView
   put the readme_Folder of tiddlyView into gitFolder
   switch
      case sMessage = "git push"
         _GitPush gitFolder, tiddlyView
         break
      case sMessage = "git commit and add"
         _GitCommitAnd gitFolder, tiddlyView
         break
      case sMessage = "git discard untracked"
         _GitDiscardUntracked gitFolder, tiddlyView
         break
      case sMessage = "git add untracked"
         _GitAddUntracked gitFolder, tiddlyView
         break
      case sMessage = "git status"
         _CreateGitStatus gitFolder, tiddlyView
         break
      default
         breakpoint
   end switch
end tiddly_Git


--> Private
-
private command _GitPush gitFolder, tObject
   git_PushBranch gitFolder
   --
   _CreateGitStatus gitFolder, tObject
end _GitPush

private command _GitCommitAnd gitFolder, tObject, pComment
   if pComment is empty then
      put "New commit" && the internet date into dComment
      ask "Commit comment..." with dComment as sheet
      if it is empty then exit to top
      put it into pComment
   end if
   git_CommitAll gitFolder, pComment, true
   --
   _CreateGitStatus gitFolder, tObject
end _GitCommitAnd

private command _GitDiscardUntracked gitFolder, tObject
   git_DiscardFolder gitFolder
   --
   _CreateGitStatus gitFolder, tObject
end _GitDiscardUntracked

private command _GitAddUntracked gitFolder, tObject
   git_AddFolder gitFolder
   --
   _CreateGitStatus gitFolder, tObject
end _GitAddUntracked

private command _CreateGitStatus pGitFolder, tObject
   # Get git status
   put git_FetchStatusTable (pGitFolder) into gitTable
   
   # Set "Git Status Buttons" tiddler
   switch
      case gitTable contains "no changes added to commit"
         --  (use "git add" and/or "git commit -a")
         put tiddly_CommitChangesButton(true) into btnText
         break
      case gitTable contains "Changes to be committed:"
         put tiddly_CommitChangesButton() into btnText
         break
      case gitTable contains "Changes not staged for commit:"
         put "There are changes not staged for commit. What would you like to do?" into sQuestion
         answer sQuestion with "Cancel" or "Discard" or "Add" as sheet
         if it is "Add" then
            -- (use "git add <file>..." to update what will be committed)
            put tiddly_AddUntrackedButton() into btnText
         else if it is "Discard" then
            -- (use "git restore <file>..." to discard changes in working directory)
            put tiddly_DiscardUntrackedButton() into btnText
         end if
         break
      case gitTable contains "Untracked files:"
         put tiddly_AddUntrackedButton() into btnText
         break
      case gitTable contains _ReKwote ("(use 'git push' to publish your local commits)")
         put tiddly_AddPushButton() into btnText
         break
         break
      case gitTable begins with "fatal: not a git repository"
      default
         put empty into btnText
   end switch
   set the tiddler_Text ["Git Status Buttons"] of tObject to btnText
   
   # Set Tiddler
   put "git status" into cArray ["title"]
   put "text" into cArray ["type"]
   put gitTable into cArray ["text"]
   --
   set the tiddler_ContentArray of tObject to cArray
end _CreateGitStatus

private function _ReKwote sText
   replace "'" with quote in sText
   return sText
end _ReKwote

private command _StripFirst @sMessage, sChar
   delete word 1 of sMessage
   -- stack 'LCW'
   replace "'" with sChar in sMessage
end _StripFirst

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


--> Deps
-
command text_StripEnclosing @sText, pChar
   if char 1 of sText = pChar then delete char 1 of sText 
   if char -1 of sText = pChar then delete char -1 of sText 
end text_StripEnclosing
