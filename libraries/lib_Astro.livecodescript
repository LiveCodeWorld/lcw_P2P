script "lib_Astro"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Astro
type: library
version: 0.1

/*
Some help
*/


--> Working on
-

--> Astro
-
command astro_InstallWithXterm aView, pTheme
   put the module_AssetFolder of aView into mFolder
   display_XtermAtFolder mFolder
   
   # Paste crreate shell
   put "npm create astro@latest" into sShell
   if pTheme is not empty then
      put space & "--template"  && pTheme after sShell
   end if
   
   put "npx create astro@latest --template eliancodes/brutal" into sShell
   --
   wait 10 ticks
   ttyd_Paste sShell, xView
   return xView
end astro_InstallWithXterm


--> Deps
-
