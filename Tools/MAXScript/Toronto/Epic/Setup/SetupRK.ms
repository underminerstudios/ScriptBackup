(
	-- By neil.marshall@gameloft.com
	-- Sets the plugin path to the RK Exporter.
	
	fn SetPath = 
	(
		result = getSavePath caption:"Where is the trunk folder?"
		if result != undefined then
		(
			rkPath = result + "\\tools\\RKMaxExporter\\4.7\\x64\\Release"
			if is64bitApplication() == false then
			(
				rkPath = result + "\\tools\\RKMaxExporter\\4.7\\x32\\Release"
			)
			
			if doesFileExist rkPath == false then
			(
				messageBox ("The plugin was not found in " + rkPath + ".\n\nUnable to continue.")
				return ""
			)
		
			maxIni = getMaxINIFile()
			iniPath = getFilenamePath maxIni
			settingIniFile = iniPath + "Plugin.UserSettings.ini"
		
			setINISetting settingIniFile "Directories" "RK Exporter" rkPath
			messageBox "Installation complete.  Please restart Max."
		)
	)
	
	SetPath()
)
