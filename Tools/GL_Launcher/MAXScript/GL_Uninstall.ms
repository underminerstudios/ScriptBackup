if querybox "Are you sure you want to uninstall Gameloft Launcher?" do
(
	--Destroy dialogs
	try(cui.UnRegisterDialogBar GameloftScripts) catch()
	try(destroyDialog GLL_Launcher_Options)catch()
	try(destroyDialog GLL_select_drive)catch()
	try(destroyDialog GameloftScripts)catch()

	filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"
	HiddenDotNetCommand "cmd.exe" ("/K rmDir " + "\"" + (getDir #userscripts + "\\GLL_Launcher\\") + "\"" + " /s /q") ""
	for n in getFiles ("$usericons" + "\\Gameloft*.*") do(deleteFile n)
	deleteFile "$userscripts\\startup\\GLL_startup.ms"
)