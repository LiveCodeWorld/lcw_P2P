script "behavior_ViewKeepass" with behavior "behavior_ViewBrowser"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewKeepass
type: behavior
version: 0.2

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Working on
-

--> Events
-
on preOpenControl
   -- only sent to groups (s we use preOpenCard and dispatch view_Init)
   breakpoint
   view_Init
   pass preOpenControl
end preOpenControl

command view_Init
   set the behavior_StackNames of me to "behavior_ViewKeepass,behavior_ViewBrowser"
   --
   _FixLayout
   --
   lcw_Notify the behavior_StackNames of me
end view_Init

command _FixLayout
   put the rect of this cd into cardRect
   put the view_RectOnCard of me into viewRect
   
   lock screen
   set the rect of me to cardRect -- tryng to fix menubar position bug
   LayoutControl viewRect
   unlock screen
   
   lcw_Notify the params
end _FixLayout
