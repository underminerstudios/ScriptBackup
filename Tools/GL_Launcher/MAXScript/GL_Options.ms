try(destroyDialog GLL_Launcher_Options)catch()
filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"
rollout GLL_Launcher_Options "Gameloft Launcher Options"
(
	local theProfile = "$userscripts\\GLL_Launcher\\profile.ini"
	local theDepotPath = pathconfig.normalizepath (getINIsetting theProfile "Depot" "Path")
	
	checkbox chk_update_script_startup "Update Scripts on 3dsmax startup" checked:true
	checkbox chk_beta_scripts "Show BETA scripts"
	button btn_update_launcher "Check for Gameloft Launcher Update" width:220
	button btn_add_material_bttons "Add \"Submit-Effect\" Tools to Toolbar" width:220
	button btn_uninstall "Uninstall Gameloft Launcher" width:220
	button btn_open_depot_folder "Open Depot Folder"  across:2
	button btn_userscripts "Open $userscripts"

	fn loadSettings =
	(
		--Beta
		theProfile = "$userscripts\\GLL_Launcher\\profile.ini"
		try
		(
			chk_beta_scripts.state = (getINIsetting theProfile "Depot" "ShowBeta") as booleanclass
		)catch()
		try
		(
			local theState = (getINIsetting theProfile "GLL_Launcher" "UpdateScriptOnStartup")
			if theState == "false" do (chk_update_script_startup.state = false)
		)catch()
	)
	 
	fn saveSettings =
	(
		--Beta
		theProfile = "$userscripts\\GLL_Launcher\\profile.ini"
		setINIsetting theProfile "Depot" "ShowBeta" (chk_beta_scripts.state as string)
		setINIsetting theProfile "GLL_Launcher" "UpdateScriptOnStartup" (chk_update_script_startup.state as string)
	)
	
	on GLL_Launcher_Options open do
	(
		loadSettings()
	)
	
	on GLL_Launcher_Options close do
	(
		saveSettings()
		filein (theDepotPath + "\\GL_Launcher\\MAXScript\\GL_Launcher.ms")
	)
	
	on btn_add_material_bttons pressed do
	(
		add_icon_toolbar "GameloftSubmitEffect" "Gameloft" "Gameloft Submit Effect" "GL_Effect_Submit"
		add_icon_toolbar "GameloftSubmitEffectInst" "Gameloft" "Gameloft Submit Effect Instance" "GL_EffectInst_Submit"
	)
	
	on btn_open_depot_folder pressed do
	(
		shellLaunch "explorer.exe" ("\"" + theDepotPath + "\"")
	)
	
	on btn_userscripts pressed do
	(
		shellLaunch "explorer.exe" (getDir #userscripts)
	)
	
	on btn_update_launcher pressed do
	(
		try(cui.UnRegisterDialogBar GameloftScripts) catch()
		try(DestroyDialog GameloftScripts) catch()
		destroyDialog GLL_Launcher_Options
		filein "$userscripts\\startup\\GLL_startup.ms"
	)
	
	on btn_uninstall pressed do
	(
		filein "GL_uninstall.ms"
	)
)
createDialog GLL_Launcher_Options width:240 height:150