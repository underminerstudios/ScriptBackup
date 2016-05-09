try(cui.UnRegisterDialogBar GameloftScripts) catch()
try(DestroyDialog GameloftScripts) catch()
rollout GameloftScripts "Gameloft Launcher" width:200 height:300
(
	
	local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local theSubscriptionFile = getDir #userscripts  + "\\GLL_Launcher\\subscriptions.ini"
	local theStartupList = getDir #userscripts + "\\GLL_Launcher\\startup_scripts.ini"
	local theIcons = #()
	
	--Show Beta?
	local theProfile = "$userscripts\\GLL_Launcher\\profile.ini"
	local showBeta = getINIsetting theProfile "Depot" "ShowBeta"
			
	--Startup Scripts array
	local theStartupList = getDir #userscripts + "\\GLL_Launcher\\startup_scripts.ini"
			
	--Subscriptions
	local theSubscriptionFile = getDir #userscripts  + "\\GLL_Launcher\\subscriptions.ini"
			
	--Installed scripts
	local theInstalledScriptFile = getDir #userscripts  + "\\GLL_Launcher\\installed_scripts.ini"
	
	-- UI
	imgtag it_settings "Settings" bitmap:(openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Settings.png")) width:20 height:20 pos:[0,0]
	imgtag it_update "Update" bitmap:(openBitmap (theDepotPath + "\\GL_Launcher\\Resources\\update.png")) width:20 height:20 pos:[20,0]
	label lbl_update "" width:120 pos:[50,2]
	imgtag it_close "x" bitmap:(openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Close.png")) width:20 height:20 pos:[160,0]
	imgtag it_info "Info" bitmap:(openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\InfoPanel_unpressed.png")) width:20 height:20 pos:[180,0]
	dotNetControl tv "system.windows.forms.treeView" width:200 height:260 pos:[0,20]
	dotNetControl wb "System.Windows.Forms.WebBrowser" pos:[201,0] width:600 height:260

	--Save collapse state of the nodes in the treeview
	fn saveCollapseState =
	(
		local theTreeviewText = "$userscripts\\GLL_Launcher\\tv_collapse_state.ini"
		deleteFile theTreeviewText
		for i=0 to (tv.nodes.count - 1) do
		(
			--Studios
			setINIsetting theTreeviewText tv.nodes.item[i].text "State" (tv.nodes.item[i].IsExpanded as string)
			if tv.nodes.item[i].Nodes.Count != 0 do
			(
				--Projects
				for j=0 to (tv.nodes.item[i].Nodes.Count - 1) do
				(
					setINIsetting theTreeviewText tv.nodes.item[i].text tv.nodes.item[i].nodes.item[j].text (tv.nodes.item[i].nodes.item[j].IsExpanded as string)
				)
			)
		)
	)
	
	--Load collapse state of the nodes in the treeview
	fn loadCollapseState =
	(
		theTreeviewText = "$userscripts\\GLL_Launcher\\tv_collapse_state.ini"
		for i=0 to (tv.nodes.count - 1) do
		(
			--Studios
			theStudioState = getINIsetting theTreeviewText tv.nodes.item[i].text "State"
			if theStudioState == "true" do
			(
				tv.nodes.item[i].Expand()
				
				if tv.nodes.item[i].Nodes.Count != 0 do
				(
					--Projects
					for j=0 to (tv.nodes.item[i].Nodes.Count - 1) do
					(
						theProjectState = getINIsetting theTreeviewText tv.nodes.item[i].text tv.nodes.item[i].nodes.item[j].text
						if theProjectState == "true" do
						(
							tv.nodes.item[i].nodes.item[j].Expand()
						)
					)
				)
			)
		)
	)
	
	--Adds root nodes to treeView.
	fn populateTreeView=
	(
		local theStartupArray = (dotnetClass "System.IO.File").ReadAllLines theStartupList
		local theSubscriptionArray = (dotnetClass "System.IO.File").ReadAllLines theSubscriptionFile
		local theInstalledScriptArray = (dotnetClass "System.IO.File").ReadAllLines theInstalledScriptFile
		
		--Color
		tv.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 86 86 86
		tv.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 220 220 220
		tv.LineColor = (dotNetClass "System.Drawing.Color").fromARGB 150 150 150
		--Studio root lines
		tv.ShowRootLines = false
		--Clear the nodes
		tv.nodes.clear()
		--Fonts
		local UnderlineFont = dotNetObject "System.Drawing.Font" \
			"Microsoft Sans Serif" \ -- font name
			8 \ -- font size (in piels)
			(dotNetClass "System.Drawing.FontStyle").Underline \
		
		local BoldFont = dotNetObject "System.Drawing.Font" \
			"Microsoft Sans Serif" \ -- font name
			8 \ -- font size (in piels)
			(dotNetClass "System.Drawing.FontStyle").Bold \ 
		
		
		--Image list (project icons, etc)
		local imglist = dotnetobject "System.Windows.Forms.ImageList"
		imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
		imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
		local imageClass = dotNetClass "System.Drawing.Image"
		theIcons = #()
		
		for c in getDirectories (theDepotPath + "\\MAXScript\\*") do
		(
			for d in getDirectories (c + "\\*") do
			(
				local theFoldername = (substituteString (pathConfig.stripPathToLeaf d) "\\" "")
				if theFoldername != "_CommandLineTools" AND theFoldername != "_MAXScriptFunctions" AND theFoldername != ".svn" do
				(
					--Category Icons
					for f in getFiles (d + "icon.png") do
					(
						local theBitmap = (imageClass.Fromfile f)
						imgList.images.add theBitmap
						append theIcons f
					)
					--Script icons
					for g in getDirectories (d + "\\*") do
					(
						for h in getFiles (g + "icon.png") do
						(
							local theBitmap = imageClass.FromFile h
							imgList.images.add theBitmap
							append theIcons h
						)
					)
				)
			)
		)
		
		local ExtraBitmaps = #( \
		pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\thirdparty.png"), \
		pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\maxscript.png"), \
		pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\gameloft.ico"), \
		pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\installed.png"), \
		pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\uninstalled.png"), \
		pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\subscribed.png"))

		for n in ExtraBitmaps do
		(
			imgList.images.add (imageClass.fromFile n)
			append theIcons n
		)
		
		--These are the indexes of the additional icons. These variable will be used later on when populating the treeview
		local ThirdPartyIcoIndex = theIcons.count - 6
		local MaxScriptIcoIndex = theIcons.count - 5
		local GameloftIcoIndex = theIcons.count - 4
		local InstalledIcoIndex = theIcons.count - 3
		local UninstalledIcoIndex = theIcons.count - 2
		local SubscribedIcoIndex = theIcons.count - 1
		
		tv.ImageList = imglist
		
		
		--LOAD THE NODES
		--Studios
		for a in getDirectories (theDepotPath + "\\MAXScript\\*") do 
		(
			local TheStudioName = (substituteString (pathConfig.stripPathToLeaf a) "\\" "")
			if TheStudioName != ".svn" do
			(
				local n= (dotNetObject "System.Windows.Forms.TreeNode" TheStudioName)
				--Gameloft Icon
				n.ImageIndex = GameloftIcoIndex
				n.SelectedImageIndex = n.ImageIndex
				tv.nodes.add n
				
				--Projects nodes
				for b in getDirectories (a + "\\*") do
				(
					--Project Name
					local theProjectName = (substituteString (pathConfig.stripPathToLeaf b) "\\" "")
					--Avoid certain folders
					if theProjectName != "_CommandLineTools" AND theProjectName != "_MAXScriptFunctions" AND theProjectName != ".svn" do
					(
						local m=(dotNetObject "System.Windows.Forms.TreeNode" theProjectName)
						--Project Icons
						--We add a default icon to the node
						m.ImageIndex = MaxScriptIcoIndex
						m.SelectedImageIndex = m.ImageIndex
						
						-- Third Party Scripts
						if theProjectName == "Third Party" do
						(
							m.ImageIndex = ThirdPartyIcoIndex
							m.SelectedImageIndex = m.ImageIndex
						)

						--Now we check if there is actually a specfic one
						for i=1 to theIcons.count do
						(
							--We compare the paths of the icons with the path of the folder, if they match we assign it.
							local theFolder = pathConfig.stripPathToLeaf (pathConfig.removePathLeaf theIcons[i])
							if theFolder == theProjectName do
							(
								m.ImageIndex = (i - 1)
								m.SelectedImageIndex = m.ImageIndex
							)
						)
						
						--Finally we add the node
						n.nodes.add m
						--Scripts nodes
						for c in getDirectories (b + "\\*") do
						(
							--Script Name
							local theScriptName = (substituteString (pathConfig.stripPathToLeaf c) "\\" "")
							if theScriptName != ".svn" do --avoid .svn folders
							(
								--Check info.ini if availalbe
								--Define vars
								local betaState = undefined
								local statusupdate = undefined
								local install_script = undefined
								local uninstall_script = undefined
								--Get vars
								if doesFileExist (c + "\\info.ini") == true do
								(
									betaState = getINIsetting (c + "\\info.ini") "Script" "beta"
									statusupdate = getINIsetting (c + "\\info.ini") "Script" "startup"
									install_script = getINIsetting (c + "\\info.ini") "Script" "install"
									uninstall_script = getINIsetting (c + "\\info.ini") "Script" "uninstall" 
								)
								if betaState == "true" AND showBeta != "true" then
								(
									--Don't add the script if the script is beta but the showBeta flag is not true
								)
								else
								(
									--Add script
									local o=(dotNetObject "System.Windows.Forms.TreeNode" theScriptName)
									
									--Default project icon for script
									o.ImageIndex = m.ImageIndex
									o.SelectedImageIndex = o.ImageIndex
									
									--Check if there is a specific icon
									for l=1 to theIcons.count do
									(
										local theFolder = pathConfig.stripPathToLeaf (pathConfig.removePathLeaf theIcons[l])
										if theFolder == theScriptName do
										(
											o.ImageIndex = (l - 1)
											o.SelectedImageIndex = o.ImageIndex
										)
									)
									
									--If BETA
									if betaState == "true" do
									(
										o.text =  ("[BETA]" + theScriptName)
										o.NodeFont = BoldFont
									)
									
									--Installed script icon (startup script)
									if statusupdate == "true" do
									(
										o.ImageIndex = UninstalledIcoIndex
										o.SelectedImageIndex = o.ImageIndex
									)
									
									--Installed script icon (installed scripts)
									if install_script != undefined AND install_script != "" AND uninstall_script != undefined AND uninstall_script != "" do
									(
										o.ImageIndex = UninstalledIcoIndex
										o.SelectedImageIndex = o.ImageIndex
									)
									
									--If it's isntalled -> label it green and add appropiate icon
									
									--Check startup scripts first
									for n in theStartupArray do
									(
										if n ==(theStudioName + "\\" + theProjectName + "\\" + theScriptName) do
										(
											o.ForeColor = (dotNetClass "System.Drawing.Color").Green
											o.ImageIndex = InstalledIcoIndex
											o.SelectedImageIndex = o.ImageIndex
										)
									)
									--Now installed scripts
									for n in theInstalledScriptArray do
									(
										if n ==(theStudioName + "\\" + theProjectName + "\\" + theScriptName) do
										(
											o.ForeColor = (dotNetClass "System.Drawing.Color").Green
											o.ImageIndex = InstalledIcoIndex
											o.SelectedImageIndex = o.ImageIndex
										)
									)
									m.nodes.add o
								)
							)
						)
							

						--Is there a info.ini in the project folder?
						--Check if there is information regarding a MaxGlitch Installer
						if doesFileExist (b + "\\info.ini") do
						(
							local MaxGlitch_url = getINIsetting (b + "\\info.ini") "MaxGlitch" "Url"
							local MaxGlitch_path = getINIsetting (b + "\\info.ini") "MaxGlitch" "Path"
							
							if MaxGlitch_url != "" AND MaxGlitch_path != "" do
							(
								o=(dotNetObject "System.Windows.Forms.TreeNode" "MaxGlitch")
								o.ImageIndex = GameloftIcoIndex
								o.SelectedImageIndex = o.ImageIndex
								m.nodes.add o
							)
						)
						
						--Check if the project is subscribed, change the icon and color
						for n in theSubscriptionArray do
						(
							if theProjectName == (pathConfig.stripPathToLeaf n) do
							(
								m.ImageIndex = SubscribedIcoIndex
								m.SelectedImageIndex = m.ImageIndex
								m.ForeColor = (dotNetClass "System.Drawing.Color").Yellow
								m.NodeFont = BoldFont
								for i=0 to (m.nodes.count - 1) do
								(
									m.nodes.item[i].ForeColor = (dotNetClass "System.Drawing.Color").Yellow
									m.nodes.item[i].NodeFont = BoldFont
								)
							)
						)
					)
				)
			)
		)
		--Finally load the collapse state
		loadCollapseState()
	)
	
	
	fn dock_left =
	(
		cui.DockDialogBar GameloftScripts #cui_dock_left 
		tv.height = GameloftScripts.height - 20
		setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState" (cui.getDockState GameloftScripts)
	)
	
	fn dock_right =
	(
		cui.DockDialogBar GameloftScripts #cui_dock_right
		tv.height = GameloftScripts.height - 20
		setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState" (cui.getDockState GameloftScripts)
	)
	
	fn float_window =
	(
		cui.DockDialogBar GameloftScripts #cui_floatable
		tv.height = GameloftScripts.height - 20
		setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState" (cui.getDockState GameloftScripts)
	)
	
	fn close_dialog =
	(
		--Save Collapse State
		saveCollapseState()
		--Dispose images in imagelist
		try
		(
			for i=0 to (tv.ImageList.Images.count - 1) do
			(
				tv.ImageList.Images.Item[i].Dispose()
			)
			tv.ImageList.Dispose()
			tv.Dispose()
		)catch()
		--Garbage Collection to unlock bitmaps
		gc light:true
		dgc = dotnetclass "system.gc"
		dgc.collect()
		--Unregister Dialog in case it's docked
		try(cui.UnRegisterDialogBar GameloftScripts) catch()
		--Save Dialog height
		setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "Height" (GameloftScripts.height as string)
		setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "Width" (GameloftScripts.width as string)
		--Destroy the Dialog
		try(DestroyDialog GameloftScripts) catch()
	)
	
	on GameloftScripts resized theSize do
	(
		tv.height = theSize[2] - 20
		wb.height = theSize[2]
		if theSize[1] <= 200 then
		(
			tv.width = theSize[1]
		)
		else
		(
			tv.width = 200
		)
	)
	
	on GameloftScripts open do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		
		it_settings.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Settings.png")
		it_update.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\update.png")
		it_close.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Close.png")
		it_info.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\InfoPanel_unpressed.png")	
		
		--Populate treeview
		populateTreeView()
		
		local dockState = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState"
		local GLL_Launcher_height = (getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "Height")
		local GLL_Launcher_width = 200 --(getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "Width")
		if GLL_Launcher_height != "" do
		(
			GameloftScripts.height = GLL_Launcher_height as integer
			GameloftScripts.width = GLL_Launcher_width as integer
		)
		
		cui.RegisterDialogBar GameloftScripts minSize:[200,400] maxSize:[200,1676] style:#(#cui_dock_left,#cui_dock_right,#cui_floatable,#cui_handles)
		
		if dockState == "cui_dock_left" do
		(
			dock_left()
		)
		if dockState == "cui_dock_right" do
		(
			dock_right()
		)
		if dockState == "cui_floatable" do
		(
			float_window()
		)
		
		--Restore values
		fileIngamma = storeGamma
	)
	
	on it_close mouseup v1 v2 do
	(
		setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState" (cui.getDockState GameloftScripts)
		cui.UnRegisterDialogBar GameloftScripts
		DestroyDialog GameloftScripts
	)

	
	on GameloftScripts close do
	(
		try(setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState" (cui.getDockState GameloftScripts)
		cui.UnRegisterDialogBar GameloftScripts)catch()
		close_dialog()
	)
	
	on tv NodeMouseClick arg do
	(
		local theNode = tv.GetNodeAt arg.x arg.y
		tv.SelectedNode = theNode
		--Mousebutton click? Right or Left?
		--Right click
		if (arg.Button).value__ == 2097152 then
		(
			--Since we have a couple of nodes we need to make sure the last child is clicked, the script.
			if theNode.parent != undefined AND (theNode.parent).parent != undefined do
			(
				local theStudio = (theNode.parent).parent.text
				local theProject = theNode.parent.text
				local theScript = substituteString theNode.text "[BETA]" "" --We strip the BETA if found, in order to get to the path
				
				--Check if it's MaxGlitch, if not it's a script, continue.
				if theScript != "MaxGlitch" then
				(
					local thePath = (theDepotPath + "\\" + "MAXScript" + "\\\\" + theStudio + "\\\\" + theProject + "\\\\"+ theScript)
					local theSubscriptionArray = (dotnetClass "System.IO.File").ReadAllLines theSubscriptionFile
					local isSubscribed = for n in theSubscriptionArray where n == (theStudio + "\\\\" + theProject) do exit with true
					local theINI = (thePath + "\\info.ini")
					
					global GLL_context_menu_path = (theStudio + "\\" + theProject + "\\"+ theScript)

					--Define context menu
					contextMenu = dotNetObject "System.Windows.Forms.ContextMenu"
					contextMenu = dotNetObject "System.Windows.Forms.ContextMenuStrip"	

					--Define the imagelist
					imglist = dotnetobject "System.Windows.Forms.ImageList"
					imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
					imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
					imageClass = dotNetClass "System.Drawing.Image"
					
					--Add the bitmaps to the imagelist
					local ExtraIcons = #( \
					pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\readme.png"), \
					pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\contact.png"), \
					pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\uninstall.png"), \
					pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\install.png"), \
					pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\open_folder.png"), \
					pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\get_revision.png"))
					for n in ExtraIcons do (imgList.images.add (imageClass.fromFile n))
					
					--Add imagelist to context menu
					contextmenu.imagelist = imglist
					--Add strip to show images
					contextMenu.ShowImageMargin = true
					
					--Here we need to add a context menu and give the option to install/uninstall the startup script
					arrFavtmp = #("Show Readme", "Contact Author","Install start-up script", "Uninstall start-up script", "Open Script Folder", "Get Revision...", "Install Script", "Uninstall Script")
					fn fff sender args=
					(
						--Variables
						local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
						local theStartupList = getDir #userscripts + "\\GLL_Launcher\\startup_scripts.ini"
						local theSubscriptionFile = getDir #userscripts  + "\\GLL_Launcher\\subscriptions.ini"
						local theInstalledScriptFile = getDir #userscripts  + "\\GLL_Launcher\\installed_scripts.ini"
						local thePath = pathconfig.normalizePath (theDepotPath + "\\\\" + "MAXScript" + "\\\\" + GLL_context_menu_path)
						local theScript = pathconfig.normalizePath (for f in getFiles (thePath + "\\*.*") where (matchpattern f pattern:"*.ms*")==true do exit with f)
						local theINI = thePath + "\\info.ini"
						
						if sender.text == "Show Readme" do
						(
							local theHelpFile = thePath + "\\readme.html"
							if doesFileExist theHelpFile then
							(
								--Open the help file
								shellLaunch theHelpFile ""
							)
							else
							(
								if doesFileExist theScript do
								(
									--No help file available
									messagebox "Sorry there is no help file available at this time! The script will be opened in notepad. A description could be available inside."
									shellLaunch "notepad.exe" theScript
								)
							)
						)
						if sender.text == "Contact Author" do
						(
							--Open Email
							local theSubject = "subject=" + (substituteString (pathConfig.stripPathToLeaf GLL_context_menu_path) "\\" "")
							local theEmail = ""
							if doesFileExist (thePath + "\\info.ini") do
							(
								theEmail = getINIsetting (thePath + "\\info.ini") "Info" "Email"
							)
							if theEmail == "" do
							(
								theEmail = SVN_getEmail theScript
							)
							shellLaunch ("mailto:"+ theEmail + "?" + theSubject) ""
						)
						if sender.text == "Install start-up script" do
						(
							--Put Startup scripts to array
							local theStartupArray = (dotnetClass "System.IO.File").ReadAllLines theStartupList
							--Add startup script
							append theStartupArray GLL_context_menu_path
							--Write file
							(dotnetClass "System.IO.File").WriteAllLines theStartupList theStartupArray
							
							--Run script
							filein theScript
						
							--Populate Treeview
							saveCollapseState()
							populateTreeView()
						)
						if sender.text == "Uninstall start-up script" do
						(
							--Remove the string to the script_startup ini
							local theStartupArray = (dotnetClass "System.IO.File").ReadAllLines theStartupList
							for i=1 to theStartupArray.count do
							(
								if theStartupArray[i] == GLL_context_menu_path do
								(
									deleteItem theStartupArray i
								)
							)
							(dotnetClass "System.IO.File").WriteAllLines theStartupList theStartupArray
							
							--Populate Treeview
							saveCollapseState()
							populateTreeView()
							
							messagebox "Be advised: Some scripts require 3dsMax to restart to be successfully uninstalled."
						)
						if sender.text == "Open Script Folder" do
						(
							shellLaunch "explorer.exe" ("/e,/select," + theScript)
						)
						if sender.text == "Get Revision..." do
						(
							global GLL_theFile_revision = thePath
							filein "GL_Revisions.ms"
						)
						if sender.text == "Install Script" do
						(
							local theInstallMS = thePath + "\\" + (getINIsetting theINI "Script" "Install")
							if doesFileExist theInstallMS then
							(
								--Scripts array
								local theInstalledScriptArray = (dotnetClass "System.IO.File").ReadAllLines theInstalledScriptFile
								
								--Add script
								append theInstalledScriptArray GLL_context_menu_path
								--Write file
								(dotnetClass "System.IO.File").WriteAllLines theInstalledScriptFile theInstalledScriptArray
								
								--Populate Treeview
								saveCollapseState()
								populateTreeView()
								
								--Launch the script
								filein theInstallMS
							)
							else
							(
								messagebox "ERROR: The install script was not found!"
								shellLaunch thePath
							)
						)
						if sender.text == "Uninstall Script" do
						(
							local theUninstallMS = thePath + "\\" + (getINIsetting theINI "Script" "Uninstall")
							if doesFileExist theUninstallMS then
							(
								--Run Uninstaller
								filein theUninstallMS
								
								--Remove the string to the script_startup ini
								local theInstalledScriptArray = (dotnetClass "System.IO.File").ReadAllLines theInstalledScriptFile
								for i=1 to theInstalledScriptArray.count do
								(
									if theInstalledScriptArray[i] == GLL_context_menu_path do
									(
										deleteItem theInstalledScriptArray i
									)
								)
								(dotnetClass "System.IO.File").WriteAllLines theInstalledScriptFile theInstalledScriptArray
								
								--Populate Treeview
								saveCollapseState()
								populateTreeView()						
							)
							else
							(
								messagebox "ERROR: No uninstaller script found!"
								shellLaunch thePath
							)
						)
					)
					
					--Is it subscribed? If not go ahead and display the install/uninstall options
					if isSubscribed != true AND (doesFileExist theINI) == true do
					(
						local startupState = (getINIsetting (thePath + "\\info.ini") "Script" "startup")
						local install_script = (getINIsetting (thePath + "\\info.ini") "Script" "install")
							
						if startupState == "true" do
						(
							--Startup Scripts array
							local theStartupList = getDir #userscripts + "\\GLL_Launcher\\startup_scripts.ini"
							local theStartupArray = (dotnetClass "System.IO.File").ReadAllLines theStartupList
							local installState = for n in theStartupArray where n == (theStudio + "\\" + theProject + "\\"+ theScript) do exit with true
							
							--Put the path to a global value so that the context menu can catch it.
							global GLL_context_menu_path = (theStudio + "\\" + theProject + "\\"+ theScript)
							--What Items to add to the context menu
							if installState == true then
							(
								--Uninstall
								menuItem_1 = contextMenu.Items.Add(arrFavtmp[4])
								menuItem_1.ImageIndex = 2
								dotnet.addeventhandler menuItem_1 "Click" fff
							)
							else
							(
								--Install
								menuItem_1 = contextMenu.Items.Add(arrFavtmp[3])
								menuItem_1.ImageIndex = 3
								dotnet.addeventhandler menuItem_1 "Click" fff
							)
						)
						
						if install_script != "" do
						(
							--Startup Scripts array
							local theInstalledScriptFile = getDir #userscripts  + "\\GLL_Launcher\\installed_scripts.ini"
							local theInstalledScriptArray = (dotnetClass "System.IO.File").ReadAllLines theInstalledScriptFile
							local installed_ = for n in theInstalledScriptArray where n == (theStudio + "\\" + theProject + "\\"+ theScript) do exit with true
							
							--Put the path to a global value so that the context menu can catch it.
							global GLL_context_menu_path = (theStudio + "\\" + theProject + "\\"+ theScript)
							--What Items to add to the context menu
							if installed_ == true then
							(
								--Uninstall
								menuItem_1 = contextMenu.Items.Add(arrFavtmp[8])
								menuItem_1.ImageIndex = 2
								dotnet.addeventhandler menuItem_1 "Click" fff
							)
							else
							(
								--Install
								menuItem_1 = contextMenu.Items.Add(arrFavtmp[7])
								menuItem_1.ImageIndex = 3
								dotnet.addeventhandler menuItem_1 "Click" fff
							)
						)
					)
					
					--Show Readme
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[1])
					menuItem_1.ImageIndex = 0
					dotnet.addeventhandler menuItem_1 "Click" fff
					--Contact Author
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[2])
					menuItem_1.ImageIndex = 1
					dotnet.addeventhandler menuItem_1 "Click" fff
					--Open folder
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[5])
					menuItem_1.ImageIndex = 4
					dotnet.addeventhandler menuItem_1 "Click" fff
					--Get Revision
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[6])
					menuItem_1.ImageIndex = 5
					dotnet.addeventhandler menuItem_1 "Click" fff
					
					--Show the contextmenu
					contextmenu.Show mouse.screenpos[1] mouse.screenpos[2]
				)
				else
				(
					local thePath = (theDepotPath + "\\" + "MAXScript" + "\\\\" + theStudio + "\\\\" + theProject + "\\\\"+ "info.ini")
					
					global GLL_context_menu_path = thePath
					
					--Define context menu
					contextMenu = dotNetObject "System.Windows.Forms.ContextMenu"
					contextMenu = dotNetObject "System.Windows.Forms.ContextMenuStrip"	

					--Define the imagelist
					imglist = dotnetobject "System.Windows.Forms.ImageList"
					imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
					imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
					imageClass = dotNetClass "System.Drawing.Image"
					
					--Add the bitmaps to the imagelist
					imgList.images.add (imageClass.Fromfile (theDepotPath + "\\GL_Launcher\\Resources\\install.png"))
						
					--Add imagelist to context menu
					contextmenu.imagelist = imglist
					--Add strip to show images
					contextMenu.ShowImageMargin = true
					
					--Here we need to add a context menu and give the option to install MaxGlitch
					arrFavtmp = #("Launch MaxGlitch Installer")
					fn fff sender args=
					(
						if sender.text == "Launch MaxGlitch Installer" do
						(
							--Define fucntion first: This will return the Unmapped directory of the provided URL. eg D:\SVN\gameloft_live_3d\trunk
							fn get_unmapped_dir THE_PATH=
							(
								local TheDosCommandOutput = (HiddenDotNetCommand "SUBST" "" "")
								local theMappedDrives = filterstring TheDosCommandOutput "\n"
								for n in theMappedDrives do
								(
									local theUnmappedDir = (filterstring n " => ")[2]
									if (getDepotURL theUnmappedDir) == THE_PATH do
									(
										return theUnmappedDir
									)
								)
								return false
							)
							
							local MaxGlitch_URL = getINIsetting GLL_context_menu_path "MaxGlitch" "Url"
							local MaxGlitch_Path = getINIsetting GLL_context_menu_path "MaxGlitch" "Path"
							local theUnmappedDir = (get_unmapped_dir MaxGlitch_URL)
							
							--If theUnmappedDir is false, let's try to find it recursevly throuh C, D, E or whatever.
							if theUnmappedDir == false do(theUnmappedDir = findDepotPathFromURL MaxGlitch_URL)
							
							--If the Unmapped Dir has been found, launch the Installer
							if theUnmappedDir != false then
							(
								if doesFileExist (theUnmappedDir + "\\" + MaxGlitch_Path) then
								(
									if querybox "Glitch will be installed. 3dsMax will be forcibly closed. Are you sure you want to continue?" do
									(
										local theMaxGlitchInstaller = pathConfig.normalizePath (theUnmappedDir + "\\" + MaxGlitch_Path)
										quitMax #noprompt
										shellLaunch theMaxGlitchInstaller ""
									)
								)
								else
								(
									messagebox "The mapped drive was found. But the Installer isn't there. Make sure the path in the info.ini is correct!"
								)
							)
							--If it is still false, give an error
							else
							(
								messagebox "The mapped drive could not be found"
							)
						)
					)
					
					--Open folder
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[1])
					menuItem_1.ImageIndex = 0
					dotnet.addeventhandler menuItem_1 "Click" fff
					
					--Show the contextmenu
					contextmenu.Show mouse.screenpos[1] mouse.screenpos[2]
				)
			)
			--The Project right click
			if theNode.parent != undefined AND (theNode.parent).parent == undefined AND theNode.text != "Universal MaxScripts" AND theNode.text != "Third Party" do
			(
				--Subscriptions
				local theSubscriptionArray = (dotnetClass "System.IO.File").ReadAllLines theSubscriptionFile
				
				global GLL_ProjectNode = (theNode.Parent.text + "\\\\" + theNode.text)

				--Define context menu
				contextMenu = dotNetObject "System.Windows.Forms.ContextMenu"
				contextMenu = dotNetObject "System.Windows.Forms.ContextMenuStrip"	

				--Define the imagelist
				local imglist = dotnetobject "System.Windows.Forms.ImageList"
				imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
				imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
				local imageClass = dotNetClass "System.Drawing.Image"
				
				--Add the bitmaps to the imagelist
				imgList.images.add (imageClass.Fromfile (theDepotPath + "\\GL_Launcher\\Resources\\subscribed.png"))
				imgList.images.add (imageClass.Fromfile (theDepotPath + "\\GL_Launcher\\Resources\\unsubscribed.png"))
				
				--Add imagelist to context menu
				contextmenu.imagelist = imglist
				--Add strip to show images
				contextMenu.ShowImageMargin = true
				
				--Here we need to add a context menu and give the option to install/uninstall the startup script
				local arrFavtmp = #("Subscribe", "Unsubscribe")
				fn fff sender args=
				(
					if sender.text == "Subscribe" do
					(
						local thePath = (getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path") + "\\MAXScript\\" + "\\" + GLL_ProjectNode
						----SUBSCRIPTION
						--First we add the scripts to the subscription list
						local theSubscriptionFile = getDir #userscripts  + "\\GLL_Launcher\\subscriptions.ini"
						local theSubscriptionArray = (dotnetClass "System.IO.File").ReadAllLines theSubscriptionFile
						append theSubscriptionArray GLL_ProjectNode
						(dotnetClass "System.IO.File").WriteAllLines theSubscriptionFile theSubscriptionArray
						
						--Load Lists
						local theStartupList = getDir #userscripts + "\\GLL_Launcher\\startup_scripts.ini"
						local theStartupArray = (dotnetClass "System.IO.File").ReadAllLines theStartupList
						local theInstalledScriptFile = getDir #userscripts  + "\\GLL_Launcher\\installed_scripts.ini"
						local theInstalledScriptArray = (dotnetClass "System.IO.File").ReadAllLines theInstalledScriptFile
						
						--Add Startup Scripts and install, installable scripts.
						for f in getDirectories (thePath + "\\*") do
						(
							--If INI found they should be one of the two, installable or startup scripts.
							if doesFileExist (f + "\\info.ini") do
							(
								local theINI = (f + "\\info.ini")
								local install_script = getINIsetting theINI "Script" "install"
								local isStartup = getINIsetting theINI "Script" "startup"
								local isBeta = getINIsetting theINI "Script" "beta"
								local showBeta = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "ShowBeta"
								local theScriptName = (substituteString (pathConfig.stripPathToLeaf f) "\\" "")
								local theProjectName = (substituteString (pathConfig.stripPathToLeaf (pathConfig.removePathLeaf f)) "\\" "")
								local theStudioName = (substituteString (pathConfig.stripPathToLeaf (pathConfig.removePathLeaf (pathConfig.removePathLeaf f))) "\\" "")
								local theString = (theStudioName + "\\" + theProjectName + "\\" + theScriptName)
								
								if isStartup == "true" do
								(
									--Is it beta?
									if isBeta == "true" AND showBeta != "true" then
									(
										--Don't add the script if the script is beta but the showBeta flag is not true
									)
									else
									(
										--Startup script found!
										--Is it already "installed"? Only add the startup script if it's not found
										local isInstalled = for n in theStartupArray where n==theString do exit with true
										if isInstalled != true do
										(
											--Append to array
											append theStartupArray theString
											--Also need to run the script
											local theScript = for g in getFiles (f + "\\*.ms*") do exit with g
											filein theScript
										)
									)
								)
								
								if install_script != "" do
								(
									--Is it beta?
									if isBeta == "true" AND showBeta != "true" then
									(
										--Don't add the script if the script is beta but the showBeta flag is not true
									)
									else
									(
										--Is it already "installed"? Only add the startup script if it's not found
										local isInstalled = for n in theInstalledScriptArray where n==theString do exit with true
										if isInstalled != true do
										(
											--Append to array
											append theInstalledScriptArray theString
											--Also need to run the script
											filein (f + "\\" + install_script)
										)
									)
								)
							)
						)
						
						--Write startup array to file
						(dotnetClass "System.IO.File").WriteAllLines theStartupList theStartupArray
						--Write startup array to file
						(dotnetClass "System.IO.File").WriteAllLines theInstalledScriptFile theInstalledScriptArray
						
						--Delete Macros
						GL_DeleteMacros()
						--Create Macros
						GL_CreateMacros()
						
						--Populate Treeview
						saveCollapseState()
						populateTreeView()
					)
					
					if sender.text == "Unsubscribe" do
					(
						--Put subscriptions in array
						local theSubscriptionFile = getDir #userscripts  + "\\GLL_Launcher\\subscriptions.ini"
						local theSubscriptionArray = (dotnetClass "System.IO.File").ReadAllLines theSubscriptionFile
						--Find subscription and delete it
						for i=1 to theSubscriptionArray.count do
						(
							if theSubscriptionArray[i] == GLL_ProjectNode do
							(
								deleteItem theSubscriptionArray i
							)
						)
						--Write Array to File
						(dotnetClass "System.IO.File").WriteAllLines theSubscriptionFile theSubscriptionArray
						
						--Uninstall subscribed startup scripts
						local theStartupList = getDir #userscripts + "\\GLL_Launcher\\startup_scripts.ini"
						local theStartupArray = (dotnetClass "System.IO.File").ReadAllLines theStartupList
						local theNewStartupArray = #()
						
						for n in theStartupArray do
						(
							local theSubscribedProject = substituteString GLL_ProjectNode "\\\\" "\\"
							if (matchpattern n pattern:(theSubscribedProject + "*" )) == false do
							(
								append theNewStartupArray n
							)
						)
						--Write Array to file
						(dotnetClass "System.IO.File").WriteAllLines theStartupList theNewStartupArray
						
						
						
						--Uninstall installed scripts
						local theInstalledScriptFile = getDir #userscripts  + "\\GLL_Launcher\\installed_scripts.ini"
						local theInstalledScriptArray = (dotnetClass "System.IO.File").ReadAllLines theInstalledScriptFile
						
						local theNewInstallArray = #()
						
						for n in theInstalledScriptArray do
						(
							local theSubscribedProject = substituteString GLL_ProjectNode "\\\\" "\\"
							if (matchpattern n pattern:(theSubscribedProject + "*" )) == true then
							(
								local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
								local thePath = (theDepotPath + "\\\\" + "MAXScript" + "\\\\" + n)
								
								local theINI = thePath + "\\info.ini"
								
								local uninstallMS = getINIsetting theINI "Script" "uninstall"
								
								if doesFileExist (thePath + "\\" + uninstallMS) then
								(
									filein (thePath + "\\" + uninstallMS)
								)
								else
								(
									messagebox "ERROR: No uninstaller was found! Try to install and uninstall again!"
								)
							)
							else
							(
								append theNewInstallArray n
							)
						)
						--Write Array to file
						(dotnetClass "System.IO.File").WriteAllLines theInstalledScriptFile theNewInstallArray
						
						
						--Delete Macros
						GL_DeleteMacros()
						--Create Macros
						GL_CreateMacros()
						
						--Populate Treeview
						saveCollapseState()
						populateTreeView()
						
						messagebox "Be advised: Some scripts require 3dsMax to restart to be successfully uninstalled."
					)
				)
				
				--Is the Project subscribed?
				isSubscribed = for n in theSubscriptionArray where n == (theNode.Parent.text + "\\\\" + theNode.text) do exit with true
				
				if isSubscribed == true then
				(
					--Unsusbscribe
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[2])
					menuItem_1.ImageIndex = 1
					dotnet.addeventhandler menuItem_1 "Click" fff
				)
				else
				(
					--Subscribe
					menuItem_1 = contextMenu.Items.Add(arrFavtmp[1])
					menuItem_1.ImageIndex = 0
					dotnet.addeventhandler menuItem_1 "Click" fff
				)
				
				--Show the contextmenu
				contextmenu.Show mouse.screenpos[1] mouse.screenpos[2]
			)
		)
		else
		(
			--DISPLAY THE README.HTML in the WebBrowser
			--Since we have a couple of nodes we need to make sure the last child is clicked, the script.
			if theNode.parent != undefined AND (theNode.parent).parent != undefined do
			(
				local theStudio = (theNode.parent).parent.text
				local theProject = theNode.parent.text
				local theScript = substituteString theNode.text "[BETA]" "" --We strip the BETA if found, in order to get to the path
				
				--Check if it's MaxGlitch, if not it's a script, continue.
				if theScript != "MaxGlitch" then
				(
					local the_structure_path = (theStudio + "\\" + theProject + "\\"+ theScript)
					local thePath = (theDepotPath + "\\\\" + "MAXScript" + "\\\\" + the_structure_path)
					local theHelpFile = thePath + "\\readme.html"
					--Load the HTML
					if doesFileExist theHelpFile then
					(
						GameloftScripts.wb.url = dotNetObject "System.Uri" (pathconfig.normalizePath theHelpFile)
					)
					--If no HTML load about:blank
					else
					(
						GameloftScripts.wb.url = dotNetObject "System.Uri" "about:blank"
					)
				)
			)
		)
	)
	
	--Run the script on double-click
	on tv NodeMouseDoubleClick arg do
	(
		local theNode = tv.GetNodeAt arg.x arg.y
		--Since we have a couple of nodes we need to make sure the last child is clicked, the script.
		if theNode.parent != undefined AND (theNode.parent).parent != undefined do
		(
			local theStudio = (theNode.parent).parent.text
			local theProject = theNode.parent.text
			local theScript = substitutestring theNode.text "[BETA]" ""
			local thePath = (theDepotPath + "\\\\" + "MAXScript" + "\\\\" + theStudio + "\\\\" + theProject + "\\\\"+ theScript)
			
			--If it's not MaxGlitch continue
			if theScript != "MaxGlitch" do
			(
				--Check if there is a info ini file. If it's a startup script we won't launch it.
				if doesFileExist (thePath + "\\info.ini") then
				(
					local startupState = (getINIsetting (thePath + "\\info.ini") "Script" "startup")
					local install_script = (getINIsetting (thePath + "\\info.ini") "Script" "install")
					local run_script = (getINIsetting (thePath + "\\info.ini") "Script" "run")
			
					--If it's a startup script
					if startupState == "true" do
					(
						messagebox "This is a startup script. Right click in order to install/uninstall"
					)
					
					--If it's an install-able script with NO "run file" specified
					if install_script != "" AND run_script == "" do
					(
						messagebox "This is an install-able script. Right click in order to install/uninstall"
					)
					
					--If it's an install-able script _with_ a "run file" specified
					if install_script != "" AND run_script != "" do
					(
						if doesFileExist run_script then
						(
							filein run_script
						)
						else
						(
							messagebox "ERROR: No run file was found for this script! Try to re-install."
						)
					)
					
					--If there is an info.ini but tags just run it
					if startupState == "" AND install_script == "" do
					(
						for f in getFiles (thePath + "\\*.ms*") do
						(
							filein f
						)
					)
				)
				else
				(
					--Regular script with no info.in, just ron it.
					for f in getFiles (thePath + "\\*.ms*") do
					(
						filein f
					)
				)
			)
		)
	)
	
	--Settings button
	on it_settings mouseup v1 v2 do (filein "GL_Options.ms")
	
	--Update button
	on it_update mouseup v1 v2 do
	(
		lbl_update.text = "Updating..."
		--Dispose Imagelist before updating, new icons could be available and need to be overwritten
		for i=0 to (tv.ImageList.Images.count - 1) do
		(
			tv.ImageList.Images.Item[i].Dispose()
		)
		tv.ImageList.Dispose()
		try
		(
			--Dispose Images Context Menu
			for i=0 to (contextMenu.ImageList.Images.count - 1) do
			(
				contextMenu.ImageList.Images.Item[i].Dispose()
			)
			contextMenu.ImageList.Dispose()
		)catch()
		
		--Change web browser to about:blank to avoid locking a html file
		wb.url = dotNetObject "System.Uri" "about:blank"
		
		--Garbage Collection to unlock bitmaps
		gc light:true
		dgc = dotnetclass "system.gc"
		dgc.collect()
		
		--Update and show message
		local theMAXScriptFolder = theDepotPath + "\\MAXScript\\"
		local theOutput = (UpdateDepotPath theMAXScriptFolder)
		local theString = ""
		for n in theOutput do (theString += n + "\n")
		messagebox theString
		
		--Add startup scripts from subscriptions (FROM STARTUP.MS)
		local theSubscriptionArray = (dotnetClass "System.IO.File").ReadAllLines theSubscriptionFile
		local theStartupScripts = (dotnetClass "System.IO.File").ReadAllLines theStartuplist
		
		for n in theSubscriptionArray do
		(
			local theFolder = theDepotPath + "\\MAXScript\\" + n
			for f in getDirectories (theFolder + "\\*") do
			(
				if doesFileExist (f + "\\info.ini") do
				(
					local isStartup = getINIsetting (f + "\\info.ini") "Script" "startup"
					if isStartup == "true" do
					(
						local theString = ((pathConfig.removePathLeaf n) +"\\" + (pathConfig.stripPathToLeaf n) + "\\" + substituteString (pathConfig.stripPathToLeaf f) "\\" "")
						local alreadyInstalled = undefined
						alreadyInstalled = for n in theStartupScripts where n==TheString do exit with true
						if alreadyInstalled != true do
						(
							append theStartupScripts theString
							(dotnetClass "System.IO.File").WriteAllLines theStartupList theStartupScripts
						)
					)
				)
			)
		)
		
		--Run startup scripts
		for n in theStartupScripts do
		(
			for f in getFiles (theDepotPath + "\\MAXScript\\" + n + "\\*.ms") do
			(
				filein f
			)
		)
		
		
		--Delete Macros
		GL_DeleteMacros()
		--Create Macros
		GL_CreateMacros()
		
		--Populate Treeview
		saveCollapseState()
		populateTreeView()
		lbl_update.text = ""
	)
	
	--Info Button
	on it_info mouseup v1 v2 do
	(
		try(setINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState" (cui.getDockState GameloftScripts))catch()
		cui.UnRegisterDialogBar GameloftScripts
		
		--Load button images
		if (pathconfig.normalizePath (theDepotPath + "\\GL_Launcher\\Resources\\InfoPanel_unpressed.png")) == it_info.bitmap.filename then
		(
			local storeGamma = fileIngamma
			fileIngamma = 1.0 --set the gamma
			it_info.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\InfoPanel_pressed.png")
			fileInGamma = storeGamma

			GameloftScripts.width = 800
			cui.RegisterDialogBar GameloftScripts minSize:[200,400] maxSize:[800,1676] style:#(#cui_dock_left,#cui_dock_right,#cui_floatable,#cui_handles)
		)
		else
		(
			local storeGamma = fileIngamma
			fileIngamma = 1.0 --set the gamma
			it_info.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\InfoPanel_unpressed.png")
			fileInGamma = storeGamma
			
			GameloftScripts.width = 200
			cui.RegisterDialogBar GameloftScripts minSize:[200,400] maxSize:[200,1676] style:#(#cui_dock_left,#cui_dock_right,#cui_floatable,#cui_handles)
		)
		
		local dockState = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "GLL_Launcher" "DockState"
		if dockState == "cui_dock_left" do
		(
			dock_left()
		)
		if dockState == "cui_dock_right" do
		(
			dock_right()
		)
		if dockState == "cui_floatable" do
		(
			float_window()
		)
	)
	
	--UI MOUSEOVER STUFF
	
	on it_close mouseover do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		it_close.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Close_hover.png")
		fileIngamma = storeGamma
	)
	
	on it_close mouseout do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		it_close.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Close.png")
		fileIngamma = storeGamma
	)
	
	on it_settings mouseover do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		it_settings.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Settings_hover.png")
		fileIngamma = storeGamma
	)
	on it_settings mouseout do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		it_settings.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\Settings.png")
		fileIngamma = storeGamma
	)
	
	on it_update mouseover do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		it_update.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\update_hover.png")
		fileIngamma = storeGamma
	)
	on it_update mouseout do
	(
		local storeGamma = fileIngamma
		fileIngamma = 1.0 --set the gamma
		it_update.bitmap = openBitmap  (theDepotPath + "\\GL_Launcher\\Resources\\update.png")
		fileIngamma = storeGamma
	)

)
createDialog GameloftScripts style:#(#style_resizing,#style_titlebar,#style_sysmenu)