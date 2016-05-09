/*
	RT DR Spawner Settings
*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog RT_SPAWNER_CONFIG)catch()
rollout RT_SPAWNER_CONFIG "RT Spawner Settings"
(
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
	
	fn GET_VRAY_RT_VRAY_RT_MAX2012_FOLDER =
	(
		local VRAY_RT_MAX2012_FOLDER_KEY
		local VRAY_RT_MAX2012_FOLDER_VALNAME
		local VRAY_RT_MAX2012_FOLDER_VALUE
		local VRAY_RT_MAX2012_FOLDER_TYPE
		local THE_KEY = registry.openKey HKEY_LOCAL_MACHINE "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\" accessRights:#readOnly key:&VRAY_RT_MAX2012_FOLDER_KEY
		
		if THE_KEY == true do
		(
			registry.queryValue VRAY_RT_MAX2012_FOLDER_KEY "VRAY_RT_FOR_3DSMAX2012_MAIN_x64" type:&VRAY_RT_MAX2012_FOLDER_TYPE value:&VRAY_RT_MAX2012_FOLDER_VALUE
			registry.closeKey VRAY_RT_MAX2012_FOLDER_KEY
			if VRAY_RT_MAX2012_FOLDER_VALUE != undefined do
			(
				local thePath = pathconfig.normalizePath VRAY_RT_MAX2012_FOLDER_VALUE
				return thePath
			)
		)
		return false
	)
	
	fn GET_VRAY_RT_SPAWNER_EXE =
	(
		local thePath = GET_VRAY_RT_VRAY_RT_MAX2012_FOLDER()
		local theFile = thePath + "\\vrayrtspawner.exe"
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
	
	fn CREATE_BAT theTextFile low_priority process_affinity=
	(
		local VRAY_SPAWNER = GET_VRAY_RT_SPAWNER_EXE()
		if VRAY_SPAWNER == false do (return false)
		
		local NIRCMDCX64_EXE = GET_NIRCMDCX64_EXE()
		if NIRCMDCX64_EXE == false do (return false)
		
		local theTextArray = #()
		append theTextArray "taskkill.exe /F /IM vrayrtspawner.exe"
		append theTextArray "taskkill.exe /F /IM vray.exe"
		append theTextArray ("start " + "\"" + "\"" + " " + "\"" + VRAY_SPAWNER + "\"")
		append theTextArray "timeout 2"
		if low_priority == true do
		(
			append theTextArray ("\"" + NIRCMDCX64_EXE + "\"" + " setprocesspriority vray.exe low")
		)
		local theString = "\"" + NIRCMDCX64_EXE + "\"" + " setprocessaffinity vray.exe"
		for n in process_affinity do
		(
			theString += " " + (n as string)
		)
		append theTextArray theString
		
		(dotnetClass "System.IO.File").WriteAllLines theTextFile theTextArray
	)
	
	local theBat = (getFilenamePath (getSourceFileName())) + "\\VRAY_RT_SPAWNER.BAT"
	local StartupBat = (GET_STARTUP_FOLDER()) + "\\VrayRTSpawner2012.bat"

	label lbl_when "When:" align:#left
	checkbox cb_on_startup "Run on Windows Startup"
-- 	checkbox cb_on_idle "Run on Idle" enabled:false
-- 	checkbox cb_close_when_active "Close when active" enabled:false
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
	
	on RT_SPAWNER_CONFIG open do
	(
		if doesFileExist StartupBat do
		(
			cb_on_startup.checked = true
			local theArray = (dotnetClass "System.IO.File").ReadAllLines StartupBat
			for n in theArray do
			(
				--Priority
				if matchpattern n pattern:("*low") do
				(
					cb_low_prio.checked = true
				)
				if matchpattern n pattern:("*setprocessaffinity*") do
				(
					cb_Change_Affinity.checked = true
					local theData = filterstring n " " 
					local StartIndex = finditem theData "vray.exe"
					for i=(StartIndex + 1) to theData.count do
					(
						if theData[i] != "0" do
						(
							execute ("RT_SPAWNER_CONFIG.cb_core_" + theData[i] + ".checked = true")
						)
					)
				)
				
			)
		)
		--Enable checkboxes
		for i=2 to sysinfo.cpucount do
		(
			execute ("RT_SPAWNER_CONFIG.cb_core_" + (i - 1) as string + ".enabled = true")
		)
	)
	
	on cb_on_idle changed theState do
	(
		if theState == true then
		(
			cb_close_when_active.enabled = true
		)
		else
		(
			cb_close_when_active.enabled = false
		)
	)
	
	on cb_Change_Affinity changed theState do
	(
		if theState == true then
		(
			for i=2 to sysinfo.cpucount do
			(
				local theString = "RT_SPAWNER_CONFIG.cb_core_" + (i - 1) as string + ".enabled = true"
				local theString02 = "RT_SPAWNER_CONFIG.cb_core_" + (i - 1) as string + ".checked = true"
				execute theString
				execute theString02
			)
		)
		else
		(
			for i=1 to 7 do
			(
				local theString = "RT_SPAWNER_CONFIG.cb_core_" + (i as string) + ".enabled = false"
				execute theString
			)
			
		)
	)
	
	on btn_save pressed do
	(
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
			CREATE_BAT StartupBat cb_low_prio.state theCores
			--Create The StartupBat
			shellLaunch StartupBat ""
		)
		else
		(
			deleteFile StartupBat
		)
		destroyDialog RT_SPAWNER_CONFIG
	)
)
createDialog RT_SPAWNER_CONFIG