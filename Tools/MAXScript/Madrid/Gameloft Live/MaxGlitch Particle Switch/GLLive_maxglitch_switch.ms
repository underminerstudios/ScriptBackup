/*
Gameloft Live MaxGlitch Particle Switch
This script will close 3dsMax and load the particle-ready MaxGlitch version.
If the Particle-ready version is loaded, it will switch back to the original one.

The original version has a broken particle system.
For more information ask Pedro Pablo Fernandez Moya
pedro.fernandez@gameloft.com
*/

-- by Norman Schaar - norman.schaar@gameloft.com


--Plugin INI path
thePluginINI = getDir #maxroot + "\\plugin.ini"
doesMaxGlitchExist = (getINIsetting thePluginINI "Directories" "MaxGlitch")
if doesMaxGlitchExist != "" do
(
	--MaxGlitch DLE path
	MaxGlitchFile = (getINIsetting thePluginINI "Directories" "MaxGlitch") + "\\MaxGlitch.dle"
	--MaxGlitch Particles DLE
	MaxGlitch_particles_File = (pathConfig.removePathLeaf (pathConfig.removePathLeaf MaxGlitchFile)) + "\\Particles " + (pathConfig.stripPathToLeaf (getINIsetting thePluginINI "Directories" "MaxGlitch")) + "\\MaxGlitch.dle"
	--BackUp File 
	MaxGltich_backup = (getINIsetting thePluginINI "Directories" "MaxGlitch") + "\\MaxGlitch.original"
	--Temp file
	MaxGltich_temp = (getINIsetting thePluginINI "Directories" "MaxGlitch") + "\\MaxGlitch.temp"


	--Check if the current MaxGlitch DLE is a "particle-ready" one or not
	if doesFileExist MaxGltich_backup then
	(
		if querybox ("The " + "\"" + "particle-ready" + "\"" + " MaxGlitch version is installed. Do you want to switch to the original version? 3dsMax will be restarted after this.") do
		(
			--Delete temp file if it exists
			deleteFile MaxGltich_temp
			--Rename loaded (particle) dle to "temp"
			renameFile MaxGlitchFile MaxGltich_temp
			--Rename backup to "loaded" particle dle
			renameFile MaxGltich_backup MaxGlitchFile
			--Delete temp file if it exists
			deleteFile MaxGltich_temp
			
			--Close 3dsMax and launch new 3dsMax instance
			shellLaunch (GetDir #maxroot + "\\3dsmax.exe") ""
			
			theHWND = for n in (windows.getChildrenHWND 0) where n[4] == "3DSMAX" do exit with n[1]
			Windows.sendMessage theHWND (WM_CLOSE = 0x00000010) (wParam = 0x00000000) (lparam = 0x00000000)
		)
	)
	else
	(
		if querybox ("The regular MaxGlitch version is installed. Do you want to switch to the " + "\"" + "particle-ready" + "\"" + " version? 3dsMax will be restarted after this.") do
		(
			--Delete temp file if it exists
			deleteFile MaxGltich_temp
			--Rename loaded dle to backup
			renameFile MaxGlitchFile MaxGltich_backup
			--Copy the particle dle and paste it as the loaded one
			copyFile MaxGlitch_particles_File MaxGlitchFile
			--Delete temp file if it exists
			deleteFile MaxGltich_temp
			
			--Close 3dsMax and launch new 3dsMax instance
			shellLaunch (GetDir #maxroot + "\\3dsmax.exe") ""
			quitMAX()
		)	
	)
)