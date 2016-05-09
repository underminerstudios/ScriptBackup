/*
	DR Spawner Settings
*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog DLG_SPAWNER_CONFIG)catch()
rollout DLG_SPAWNER_CONFIG "Spawner Settings"
(
	fn GET_MAX_2012_FOLDER =
	(
		local MAX2012_FOLDER_KEY
		local MAX2012_FOLDER_VALNAME
		local MAX2012_FOLDER_VALUE
		local MAX2012_FOLDER_TYPE
		local THE_KEY = registry.openKey HKEY_LOCAL_MACHINE "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Autodesk 3ds Max 2012 64-bit - English\\" accessRights:#readOnly key:&MAX2012_FOLDER_KEY
		
		if THE_KEY == true do
		(
			registry.queryValue MAX2012_FOLDER_KEY "InstallLocation" type:&MAX2012_FOLDER_TYPE value:&MAX2012_FOLDER_VALUE
			registry.closeKey MAX2012_FOLDER_KEY
			if MAX2012_FOLDER_VALUE != undefined do
			(
				return MAX2012_FOLDER_VALUE
			)
		)
		return false
	)

	fn GET_STARTUP_FOLDER =
	(
		local STARTUP_FOLDER_KEY
		local STARTUP_FOLDER_VALNAME
		local STARTUP_FOLDER_VALUE
		local STARTUP_FOLDER_TYPE
		local THE_KEY = registry.openKey HKEY_CURRENT_USER "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\\" accessRights:#readOnly key:&STARTUP_FOLDER_KEY
		
		if THE_KEY == true do
		(
			registry.queryValue STARTUP_FOLDER_KEY "Startup" type:&STARTUP_FOLDER_TYPE value:&STARTUP_FOLDER_VALUE
			registry.closeKey STARTUP_FOLDER_KEY
			if STARTUP_FOLDER_VALUE != undefined do
			(
				return STARTUP_FOLDER_VALUE
			)
		)
		return false
	)
	
	fn GET_VRAY_SPAWNER_EXE =
	(
		local thePath = GET_MAX_2012_FOLDER()
		local theFile = thePath + "\\vrayspawner2012.exe"
		if not doesFileExist theFile do (return false)
		theFile	
	)
	
	fn GET_NIRCMDCX64_EXE =
	(
		local DepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
		local thePath = pathconfig.normalizepath (DepotPath + "MAXScript\\Madrid\\_CommandLineTools\\NirCmd_x64\\nircmdc.exe")
		if not doesfileexist thePath do (return false)
		thePath	
	)
	
	fn CREATE_STARTUP_BAT theTextFile =
	(
		local VRAY_SPAWNER = GET_VRAY_SPAWNER_EXE()
		if VRAY_SPAWNER == false do (return false)
		
		local NIRCMDCX64_EXE = GET_NIRCMDCX64_EXE()
		if NIRCMDCX64_EXE == false do (return false)
		
		local theTextArray = #()
		append theTextArray "taskkill.exe /F /IM vrayspawner2012.exe"
		append theTextArray ("\"" + NIRCMDCX64_EXE + "\"" + " elevate " + "\"" + VRAY_SPAWNER + "\"")
		
		(dotnetClass "System.IO.File").WriteAllLines theTextFile theTextArray
	)
	
	fn CREATE_STARTUP_SCRIPT THE_TEMPLATE theCores low_priority=
	(
		local theArray = (dotnetClass "System.IO.File").ReadAllLines THE_TEMPLATE
		local NewFile = #()
		for n in theArray do
		(
			local theString = n
			if matchpattern theString pattern:("*theCores*") do
			(
				theString = substitutestring theString "theCores" ("(" + (theCores as string) + ")")
			)
			append NewFile theString
		)
		
		if low_priority == true do
		(
			append NewFile "sysinfo.MAXPriority = #low"
		)
			
		(dotnetClass "System.IO.File").WriteAllLines ((getDir #userscripts) + "\\startup\\" + getFileNameFile THE_TEMPLATE + ".ms") NewFile
	)
	
	
	local StartupBat = (GET_STARTUP_FOLDER()) + "\\VraySpawner2012.bat"
	local THE_TEMPLATE_MS = (getFilenamePath  (getSourceFileName()) )+ "\\set_affinity_vray.txt"
	
	label lbl_when "When:" align:#left
	checkbox cb_on_startup "Run on Windows Startup"
	label lbl_process "Process Settings:" align:#left
	checkbox cb_low_prio "Low Priority"
	checkbox cb_Change_Affinity "Change Affinity:"
	checkbox cb_core_0 "Core 0" checked:true enabled:false across:2
	checkbox cb_core_1 "Core 1" enabled:false
	checkbox cb_core_2 "Core 2" enabled:false across:2
	checkbox cb_core_3 "Core 3" enabled:false
	checkbox cb_core_4 "Core 4" enabled:false across:2
	checkbox cb_core_5 "Core 5" enabled:false
	checkbox cb_core_6 "Core 6" enabled:false across:2
	checkbox cb_core_7 "Core 7" enabled:false
	button btn_save "Save" width:150
	
	on DLG_SPAWNER_CONFIG open do
	(
		if doesFileExist StartupBat do
		(
			cb_on_startup.checked = true
		)
		
		local theStartupMS = ((getDir #userscripts) + "\\startup\\" + getFileNameFile THE_TEMPLATE_MS + ".ms")
		if doesFileExist theStartupMS do
		(
			local theArray =  (dotnetClass "System.IO.File").ReadAllLines theStartupMS
			for n in theArray do
			(
				if matchpattern n pattern:"*addScript*" do
				(
					cb_Change_Affinity.checked = true
				)
				
				if matchpattern n pattern:"*for n in *" do
				(
					local theString = substitutestring n "		for n in " ""
					theString = substitutestring theString " do" ""

					local theCores = execute theString
					for n in theCores do
					(
						execute ("DLG_SPAWNER_CONFIG.cb_core_" + (n as string) + ".checked = true")
					)
				)
				
				if matchpattern n pattern:"*sysinfo.MAXPriority*" do
				(
					cb_low_prio.checked = true
				)
			)				
		)
		
		--Enable checkboxes
		for i=2 to sysinfo.cpucount do
		(
			execute ("DLG_SPAWNER_CONFIG.cb_core_" + (i - 1) as string + ".enabled = true")
		)
	)
	
	on cb_Change_Affinity changed theState do
	(
		if theState == true then
		(
			for i=2 to sysinfo.cpucount do
			(
				local theString = "DLG_SPAWNER_CONFIG.cb_core_" + (i - 1) as string + ".enabled = true"
				local theString02 = "DLG_SPAWNER_CONFIG.cb_core_" + (i - 1) as string + ".checked = true"
				execute theString
				execute theString02
			)
		)
		else
		(
			for i=1 to 7 do
			(
				local theString = "DLG_SPAWNER_CONFIG.cb_core_" + (i as string) + ".enabled = false"
				execute theString
			)
		)
	)
	
	on btn_save pressed do
	(
		fileingamma = 1.0
		--Which cores should be used
		local theCores = #()
		
		if cb_Change_Affinity.checked == false then
		(
			--All of them
			for i=1 to sysinfo.cpucount do
			(
				append theCores (i-1)
			)
		)
		else
		(
			--The selected ones
			if cb_core_0.checked == true do (append theCores 0)
			if cb_core_1.checked == true do (append theCores 1)
			if cb_core_2.checked == true do (append theCores 2)
			if cb_core_3.checked == true do (append theCores 3)
			if cb_core_4.checked == true do (append theCores 4)
			if cb_core_5.checked == true do (append theCores 5)
			if cb_core_6.checked == true do (append theCores 6)
			if cb_core_7.checked == true do (append theCores 7)
		)
		
		if cb_on_startup.checked == true then
		(
			--Create the Bat that does that runs all the needed commands
			CREATE_STARTUP_BAT StartupBat
			CREATE_STARTUP_SCRIPT THE_TEMPLATE_MS theCores cb_low_prio.state
			--Create The StartupBat
			shellLaunch StartupBat ""
		)
		else
		(
			deleteFile StartupBat
			deletefile ((getDir #userscripts) + "\\startup\\" + getFileNameFile THE_TEMPLATE_MS + ".ms")
		)
		destroyDialog DLG_SPAWNER_CONFIG
	)
)
createDialog DLG_SPAWNER_CONFIG