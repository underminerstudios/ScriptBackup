try destroyDialog sceneList catch()
filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"


Rollout sceneList "Material Library" width:713 height:512
(
	dropdownlist ddl_projects "Projects:" pos:[10,5] width:165
		
	label lbl_mat_name "Material Name:" pos:[10,50]
	edittext et_mat_name pos:[5,70] width:165 readonly:true
	
	listbox lb_tags "Tags:" pos:[10,90] width:160 height:5
	
	label lbl_add_info "Additional Info:" pos:[10,185]
	edittext et_add_info pos:[5,200] width:165 height:100 readonly:true
	
	label lbl_author "Author:" pos:[10,310]
	edittext et_author pos:[5,325] width:165 readonly:true
	
	label lbl_bdae "BDAE:" pos:[10,350]
	edittext et_bdae pos:[5,365] width:165 readonly:true
	
	local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local PROJECT_SVN_URL = GET_PROJECT_URL()
	local THE_PROJECT_PATH = for d in getDirectories (DEPOT_PATH + "\\GL_EffectLibrary\\Projects\\*") where (getINIsetting (d + "\\info.ini") "Project" "SVN_URL") == PROJECT_SVN_URL do exit with (pathConfig.normalizepath d)
	
	local bm_up = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_up.png"))
	local bm_down = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_down.png"))
	local bm_middle = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf.png"))
	local bm_clear = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_clear.png"))
	
	local bm_up_active = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_active_up.png"))
	local bm_down_active = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_active_down.png"))
	local bm_middle_active = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_active.png"))
	local bm_clear_active = (openBitmap (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\" + "sf_clear_active.png"))
	
	imgtag it_search_up bitmap:bm_up width:496 pos:[184,0] height:6
	imgtag it_search_down bitmap:bm_down width:496 pos:[184,23] height:7
	imgtag it_search_left bitmap:bm_middle width:4 height:30 pos:[180,0]
	imgtag it_search_right bitmap:bm_middle width:4 height:30 pos:[680,0]
	edittext et_search pos:[180,6] width:500
	imgtag it_clear bitmap:bm_clear width:30 height:30 pos:[684,0]
	
	dotNetControl lv "System.Windows.Forms.ListView" width:533 height:185 pos:[180,30]
	dotNetControl lv_2 "System.Windows.Forms.ListView" width:533 height:312 pos:[180,215]
	
	fn ADV_USR =
	(
		local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
		local USERS = (dotnetClass "System.IO.File").ReadAllLines (DEPOT_PATH + "\\GL_EffectLibrary\\AdvUsers.txt")
		
		for n in USERS do 
		(
			if n == sysInfo.username do
			(
				return true
			)
		)
		
		return false
	)
	
	local ADV_USER_STATUS = ADV_USR()
		
	fn ui_clear =
	(
		et_mat_name.text = ""
		lb_tags.items = #()
		et_add_info.text = ""
		et_author.text = ""
		et_bdae.text = ""
	)
	
	fn filllv2_clear =
	(
		lv_2.View = (dotNetClass "System.Windows.Forms.View").LargeIcon
		lv_2.Multiselect = false
		lv_2.Scrollable = true
		lv_2.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 22 22 22
		lv_2.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 117 117 117
		lv_2.Clear()
		lv_2.items.Clear()	
		lv_2.Refresh()
	)
	
	fn fillLv string=
	(
		local THE_PATH = (DEPOT_PATH + "\\GL_EffectLibrary\\Projects\\" + scenelist.ddl_projects.selected + "\\")
		lv.View = (dotNetClass "System.Windows.Forms.View").LargeIcon
		lv.Multiselect = false
		lv.Scrollable = true
		lv.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 22 22 22
		lv.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 117 117 117
		lv.Clear()
		lv.items.Clear()	
		lv.Refresh()
		
		local imageList = dotnetobject "System.Windows.Forms.ImageList"
		imageList.images.Clear()
		imageList.Dispose()
		imageList.imagesize =  dotnetobject "System.Drawing.Size" 128 128
		imageList.ColorDepth = imageList.ColorDepth.Depth32Bit
		
		local thumbs = #()
		local items = #()
  			
		local MAT_FOLDERS = getDirectories (THE_PATH + "\\*")
 		for s = 1 to MAT_FOLDERS.count do
 		(
 			append thumbs ((dotNetClass "System.Drawing.Image").fromFile (MAT_FOLDERS[s] + "\\thumb.png"))
			local INFO_INI = (MAT_FOLDERS[s] + "\\info.ini")
			local mat_name = (substitutestring (pathConfig.stripPathToLeaf MAT_FOLDERS[s]) "\\" "")
			local mat_tags = getINIsetting INFO_INI "Info" "TAGS"
			local mat_author = getINIsetting INFO_INI "Info" "Author"
			
			if (matchpattern mat_tags pattern:("*" + string + "*")) OR (matchpattern mat_name pattern:("*" + string + "*")) OR (matchpattern mat_author pattern:("*" + string + "*")) do
			(
				local THE_NAME = (substitutestring (pathConfig.stripPathToLeaf MAT_FOLDERS[s]) "\\" "")
				local item = dotNetObject "System.Windows.Forms.ListViewItem" THE_NAME
				
				--Green text if parent material in current project
				if doesFileExist (THE_PROJECT_PATH + THE_NAME + "\\") do
				(
					item.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 88 153 81
				)
				
				item.name = MAT_FOLDERS[s]
				item.imageIndex = s - 1
				lv.items.add item
			)
 		)
		
 		imageList.images.addrange thumbs
 		lv.LargeImageList = imageList
 		lv.SmallImageList = imageList
		lv.Alignment = (dotNetClass "System.Windows.Forms.ListViewAlignment").Left
		
 		for t in thumbs do t.dispose()
		
		local LV_DLG = for n in (windows.getChildrenhwnd 0) where n[4]=="MAXScriptDialog" AND n[5]==sceneList.title do exit with n[1]
		for n in (windows.getChildrenhwnd LV_DLG) where matchpattern n[4] pattern:"*SysListView32*" do (Windows.sendMessage n[1] (LVM_SETICONSPACING = 0x00001035) (wParam = 0x00000000) (lparam = 0x00990080))
	)
	
	fn fillLv2 path =
	(
		lv_2.View = (dotNetClass "System.Windows.Forms.View").LargeIcon
		lv_2.Multiselect = false
		lv_2.Scrollable = true
		lv_2.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 22 22 22
		lv_2.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 117 117 117
		lv_2.Clear()
		lv_2.items.Clear()	
		lv_2.Refresh()
		
		local imageList_2 = dotnetobject "System.Windows.Forms.ImageList"
		imageList_2.images.Clear()
		imageList_2.Dispose()
		imageList_2.imagesize =  dotnetobject "System.Drawing.Size" 128 128
		imageList_2.ColorDepth = imageList_2.ColorDepth.Depth32Bit
		
		local thumbs = #()
		local items = #()
		
		local MAT_FOLDERS = getDirectories (path + "\\*")
 		for s = 1 to MAT_FOLDERS.count do
 		(
 			append thumbs ((dotNetClass "System.Drawing.Image").fromFile (MAT_FOLDERS[s] + "\\thumb.png"))
			local INFO_INI = (MAT_FOLDERS[s] + "\\info.ini")
			local mat_name = (substitutestring (pathConfig.stripPathToLeaf MAT_FOLDERS[s]) "\\" "")

			local item = dotNetObject "System.Windows.Forms.ListViewItem" (substitutestring (pathConfig.stripPathToLeaf MAT_FOLDERS[s]) "\\" "")
			item.name = MAT_FOLDERS[s]
			item.imageIndex = s - 1
			lv_2.items.add item
 		)
		
 		imageList_2.images.addrange thumbs
 		lv_2.LargeImageList = imageList_2
		
		local LV_DLG = for n in (windows.getChildrenhwnd 0) where n[4]=="MAXScriptDialog" AND n[5]==sceneList.title do exit with n[1]
		for n in (windows.getChildrenhwnd LV_DLG) where matchpattern n[4] pattern:"*SysListView32*" do (Windows.sendMessage n[1] (LVM_SETICONSPACING = 0x00001035) (wParam = 0x00000000) (lparam = 0x00990080))
	)
	
  	on lv mouseUp arg do
  	(
  		hit=(lv.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
  		if(hit != undefined AND hit.item != undefined) then
  		(
			local THE_COLOR = color hit.item.ForeColor.R hit.item.ForeColor.G hit.item.ForeColor.B
			local GREEN_COLOR = (color 88 153 81)
			local MAT_FOLDER = hit.item.name
			local INFO_INI = MAT_FOLDER + "\\info.ini"
			et_bdae.text = getINIsetting INFO_INI "Info" "BDAE"
			--Load name
			et_mat_name.text = getINIsetting INFO_INI "Info" "Name"
			--Load Tags
			lb_tags.items = execute (getINIsetting INFO_INI "Info" "Tags")
			lb_tags.selection = 0
			--Load Additional Info
			local THE_DESCRIPTION = ""
			local THE_DESCRIPTION_ARRAY = execute (getINIsetting INFO_INI "Info" "Add Info")
			for n in THE_DESCRIPTION_ARRAY do
			(
				THE_DESCRIPTION += n + "\n"
			)
			et_add_info.text = THE_DESCRIPTION
			et_author.text = getINIsetting INFO_INI "Info" "Author"
			
			if (arg.Button).value__ == 2097152 do
			(
				local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
				
				--Define context menu
				local contextMenu1 = dotNetObject "System.Windows.Forms.ContextMenu"
				local contextMenu1 = dotNetObject "System.Windows.Forms.ContextMenuStrip"
				
				local arrFavtmp1 = #("Create Instance in Active Material Editor Slot", "Open Folder", "Copy Material to current Project Folder")
				
				
				--Define the imagelist
				local imglist = dotnetobject "System.Windows.Forms.ImageList"
				imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
				imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
				local imageClass = dotNetClass "System.Drawing.Image"
				
				--Add the bitmaps to the imagelist
				local theBitmap = (imageClass.Fromfile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\Instance.png"))
				imgList.images.add theBitmap
				local theBitmap = (imageClass.Fromfile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\open_folder.png"))
				imgList.images.add theBitmap
				local theBitmap = (imageClass.Fromfile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\copy_folder.png"))
				imgList.images.add theBitmap
				
				--Add imagelist to context menu
				contextmenu1.imagelist = imglist
				--Add strip to show images
				contextMenu1.ShowImageMargin = true
				
				
				global GLL_MAT_CURRENT_EFFECT = hit.item.name
				
				fn fff1 sender args=
				(
					if sender.text == "Create Instance in Active Material Editor Slot" do
					(

						MatEditor.Open()
						local NEW_INSTANCE = GL_Effect_Inst()
						
						--Newer glitch version with MAXSCRIPT API
						try
						(
							NEW_INSTANCE.lib.load et_bdae.text
							meditmaterials[activemeditslot] = NEW_INSTANCE
						)
						--Older versions
						catch
						(
							meditmaterials[activemeditslot] = NEW_INSTANCE
							LOAD_BDAE et_bdae.text
						)

					)
					if sender.text == "Open Folder" do
					(
						ShellLaunch GLL_MAT_CURRENT_EFFECT ""
					)
					if sender.text == "Copy Material to current Project Folder" do
					(
						local MAT_FOLDER_NAME = substitutestring (pathConfig.stripPathToLeaf GLL_MAT_CURRENT_EFFECT) "\\" ""
						local MAT_FOLDER_PATH = pathConfig.normalizepath (THE_PROJECT_PATH + "\\" + MAT_FOLDER_NAME)
						--Get the Path from the registry
						local EFFECTS_LIB = GET_EFFECTSLIBRARY_PATH()
						local SHADERS_LIB = GET_SHADERLIBRARY_PATH()
						
						clearlistener()
						
						--Create Folder in ART_DEPOT//PROJECT// for the material. Copy all the files
						makeDir MAT_FOLDER_PATH
						for n in (getFiles (GLL_MAT_CURRENT_EFFECT + "\\*.*")) do
						(
							local THE_FILE = (MAT_FOLDER_PATH + "\\" + getFileNameFile n + getFileNameType n)
							if doesFileExist THE_FILE then
							(
								deleteFile THE_FILE
								copyFile n THE_FILE
								print ("Overwrite file: " + THE_FILE)
							)
							else
							(
								copyFile n THE_FILE
								print ("Copied file to: " + THE_FILE)
							)
					
						)

						--Copy BDAE files
						if EFFECTS_LIB != false do
						(
							for n in (getFiles (GLL_MAT_CURRENT_EFFECT + "\\*.bdae")) do
							(
								local THE_FILE = (EFFECTS_LIB + "\\" + getFileNameFile n + getFileNameType n)
								if doesFileExist THE_FILE then
								(
									deleteFile THE_FILE
									copyFile n THE_FILE
									print ("Overwrite file: " + THE_FILE)
								)
								else
								(
									copyFile n THE_FILE
									print ("Copied file to: " + THE_FILE)
								)
							)
						)
						--Coyp GLSL and CG files
						if SHADERS_LIB != false do
						(
							for n in (getFiles (GLL_MAT_CURRENT_EFFECT + "\\*.cg")) do
							(
								local THE_FILE = (SHADERS_LIB + "\\" + getFileNameFile n + getFileNameType n)
								if doesFileExist THE_FILE then
								(
									deleteFile THE_FILE
									copyFile n THE_FILE
									print ("Overwrite file: " + THE_FILE)
								)
								else
								(
									copyFile n THE_FILE
									print ("Copied file to: " + THE_FILE)
								)
							)
							for n in (getFiles (GLL_MAT_CURRENT_EFFECT + "\\*.glsl")) do
							(
								local THE_FILE = (SHADERS_LIB + "\\" + getFileNameFile n + getFileNameType n)
								if doesFileExist THE_FILE then
								(
									deleteFile THE_FILE
									copyFile n THE_FILE
									print ("Overwrite file: " + THE_FILE)
								)
								else
								(
									copyFile n THE_FILE
									print ("Copied file to: " + THE_FILE)
								)
							)
						)
						actionMan.executeAction 0 "40472"  -- MAX Script: MAXScript Listener
						fillLv et_search.text
						filllv2_clear()
						ui_clear()
					)
				)
				
				--Open Folder
				local menuItem1_2 = contextMenu1.Items.Add(arrFavtmp1[2])
				menuItem1_2.ImageIndex = 1
				dotnet.addeventhandler menuItem1_2 "Click" fff1
				
				--If Advanced User show this:
				if ADV_USER_STATUS == true do
				(
					if (substitutestring (pathConfig.stripPathToLeaf THE_PROJECT_PATH) "\\" "") != ddl_projects.selected do
					(
						local menuItem1_3 = contextMenu1.Items.Add(arrFavtmp1[3])
						menuItem1_3.ImageIndex = 2
						dotnet.addeventhandler menuItem1_3 "Click" fff1
					)
				)
				
				--If Parent material is availalbe allow to create instance
				if THE_COLOR == GREEN_COLOR do
				(
					menuItem1_1 = contextMenu1.Items.Add(arrFavtmp1[1])
					menuItem1_1.ImageIndex = 0
					dotnet.addeventhandler menuItem1_1 "Click" fff1
				)
				
				--Show the contextmenu
				contextmenu1.Show mouse.screenpos[1] mouse.screenpos[2]
				
				--Dispose images in imagelist
				try
				(
					for i=0 to (contextmenu1.ImageList.Images.count - 1) do
					(
						contextmenu1.ImageList.Images.Item[i].Dispose()
					)
					contextmenu1.ImageList.Dispose()
					--contextmenu2.Dispose()
				)catch()
				--Garbage Collection to unlock bitmaps
				gc light:true
				dgc = dotnetclass "system.gc"
				dgc.collect()
			)
			
			--Fill secondary listview
			fillLv2 MAT_FOLDER
  		)
		else
		(
			filllv2_clear()
			ui_clear()
		)
  	)
	
	on lv_2 mouseUp arg do
	(
  		hit=(lv_2.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
  		if(hit != undefined AND hit.item != undefined) then
  		(
			local PARENT_MATERIAL_COLOR = color scenelist.lv.SelectedItems.Item[0].ForeColor.R scenelist.lv.SelectedItems.Item[0].ForeColor.G scenelist.lv.SelectedItems.Item[0].ForeColor.B
			local GREEN_COLOR = (color 88 153 81)
			local PROJECT_PATH_NAME = (substitutestring (pathConfig.stripPathToLeaf THE_PROJECT_PATH) "\\" "")
			local THE_INI = pathConfig.normalizepath (hit.item.name + "\\info.ini")
			et_mat_name.text = getINIsetting THE_INI "Info" "Name"
			lb_tags.items = execute (getINIsetting THE_INI "Info" "Tags")
			et_add_info.text = ""
			et_author.text = getINIsetting THE_INI "Info" "Author"
			
			
			if (arg.Button).value__ == 2097152 do
			(
				--Define context menu
				local contextMenu2 = dotNetObject "System.Windows.Forms.ContextMenu"
				local contextMenu2 = dotNetObject "System.Windows.Forms.ContextMenuStrip"
				
				local arrFavtmp2 = #("Copy Instance to Active Material Editor Slot", "Open Folder", "Copy Instance to current Project Folder")
				
				--Define the imagelist
				local imglist = dotnetobject "System.Windows.Forms.ImageList"
				imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
				imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
				local imageClass = dotNetClass "System.Drawing.Image"
				
				--Add the bitmaps to the imagelist
				local theBitmap = (imageClass.Fromfile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\Instance.png"))
				imgList.images.add theBitmap
				local theBitmap = (imageClass.Fromfile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\open_folder.png"))
				imgList.images.add theBitmap
				local theBitmap = (imageClass.Fromfile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\copy_folder.png"))
				imgList.images.add theBitmap
				
				--Add imagelist to context menu
				contextmenu2.imagelist = imglist
				--Add strip to show images
				contextMenu2.ShowImageMargin = true
				
				
				global GLL_MAT_CURRENT_INSTANCE = hit.item.name
				
				fn fff2 sender args=
				(
					if sender.text == "Copy Instance to Active Material Editor Slot" do
					(
						local MAT_FOLDER = GLL_MAT_CURRENT_INSTANCE
						local NEW_MAT_LIB = loadMaterialLibrary (MAT_FOLDER + "\\matlib.mat")
						meditmaterials[activemeditslot] = currentMaterialLibrary[1]

						local THE_FILE_LIST = execute(substitutestring (getINIsetting (MAT_FOLDER + "\\info.ini") "Info" "Files") "\\" "\\\\")
						local fileList
						atsops.refresh()
						atsops.GetFiles &fileList
						fileList = sort fileList

						for i=1 to filelist.count do 
						(
							local new_path = pathConfig.normalizepath (MAT_FOLDER + "\\" + getFileNameFile fileList[i] + getFileNameType fileList[i])
							if (doesFileExist fileList[i]) == false AND (doesFileExist new_path) == true do
							(
								atsops.selectfiles #(fileList[i])
								atsops.setpathonselection (pathConfig.removePathLeaf new_path)
							)
						)

						atsops.refresh()
					)
					if sender.text == "Open Folder" do
					(
						ShellLaunch GLL_MAT_CURRENT_INSTANCE ""
					)
					if sender.text == "Copy Instance to current Project Folder" do 
					(
						clearlistener()
						
						local NEW_FOLDER = (THE_PROJECT_PATH + sceneList.et_bdae.text + "\\" + pathConfig.stripPathToLeaf GLL_MAT_CURRENT_INSTANCE)
						
						makeDir NEW_FOLDER
						
						for n in (getFiles (GLL_MAT_CURRENT_INSTANCE + "\\*.*")) do
						(
							local THE_FILE = (NEW_FOLDER + getFileNameFile n + getFileNameType n)
							if doesFileExist THE_FILE then
							(
								deleteFile THE_FILE
								copyFile n THE_FILE
								print ("Overwrite file: " + THE_FILE)
							)
							else
							(
								copyFile n THE_FILE
								print ("Copied file to: " + THE_FILE)
							)
						)
						actionMan.executeAction 0 "40472"  -- MAX Script: MAXScript Listener
					)					
				)
				
				menuItem2_2 = contextMenu2.Items.Add(arrFavtmp2[2])
				menuItem2_2.ImageIndex = 1
				dotnet.addeventhandler menuItem2_2 "Click" fff2
				
				if PARENT_MATERIAL_COLOR == GREEN_COLOR AND PROJECT_PATH_NAME != ddl_projects.selected do
				(
					menuItem2_3 = contextMenu2.Items.Add(arrFavtmp2[3])
					menuItem2_3.ImageIndex = 2
					dotnet.addeventhandler menuItem2_3 "Click" fff2
				)
				
				--If Selected Parent Material is installed add the option to create an instance
				if PARENT_MATERIAL_COLOR == GREEN_COLOR do
				(	
					menuItem2_1 = contextMenu2.Items.Add(arrFavtmp2[1])
					menuItem2_1.ImageIndex = 0
					dotnet.addeventhandler menuItem2_1 "Click" fff2
				)
				
				--Show the contextmenu
				contextmenu2.Show mouse.screenpos[1] mouse.screenpos[2]
				
				--Dispose images in imagelist
				try
				(
					for i=0 to (contextmenu2.ImageList.Images.count - 1) do
					(
						contextmenu2.ImageList.Images.Item[i].Dispose()
					)
					contextmenu2.ImageList.Dispose()
				)catch()
				--Garbage Collection to unlock bitmaps
				gc light:true
				dgc = dotnetclass "system.gc"
				dgc.collect()
			)
		)
	)
  	
  	on et_search changed THE_STRING do
	(
		filllv2_clear()
		ui_clear()
		
		if THE_STRING == "" then
		(
			it_search_up.bitmap = bm_up
			it_search_down.bitmap = bm_down
			it_search_left.bitmap = bm_middle
			it_search_right.bitmap = bm_middle
			it_clear.bitmap = bm_clear
		)
		else
		(
			it_search_up.bitmap = bm_up_active
			it_search_down.bitmap = bm_down_active
			it_search_left.bitmap = bm_middle_active
			it_search_right.bitmap = bm_middle_active
			it_clear.bitmap = bm_clear_active
		)
		
		fillLv THE_STRING
	)
	
	on it_clear click do
	(
		et_search.text = ""
		it_search_up.bitmap = bm_up
		it_search_down.bitmap = bm_down
		it_search_left.bitmap = bm_middle
		it_search_right.bitmap = bm_middle
		it_clear.bitmap = bm_clear
		
		fillLv ""
	)

	on sceneList open do
	(
		ddl_projects.items = for n in getDirectories (DEPOT_PATH + "\\GL_EffectLibrary\\Projects\\*") collect (substitutestring (pathConfig.stripPathToLeaf n) "\\" "")
		ddl_projects.selection = 0
		
		if (THE_PROJECT_PATH as string) != "OK" then
		(
			for i=1 to ddl_projects.items.count do
			(
				if (substitutestring (pathConfig.stripPathToLeaf THE_PROJECT_PATH) "\\" "") == ddl_projects.items[i] do
				(
					ddl_projects.selection = i
				)
			)
			setFocus et_search
			fillLv et_search.text
			filllv2_clear()
		)
		else
		(
			messagebox "The current project has no material library. Please setup a new library."			
		)
		
		if ADV_USER_STATUS == false do
		(
			ddl_projects.enabled = false
		)
	)
	
	on ddl_projects selected arg do
	(
		fillLv et_search.text
		filllv2_clear()
		ui_clear()
	)
		
	on scenelist resized theSize do
	(
		lv.width = theSize[1] - 180
		lv_2.width = theSize[1] - 180
		lv_2.height = theSize[2] - 215
		et_search.width = theSize[1] - 218
		it_search_up.width = theSize[1] - 180 - 30 - 8
		it_search_down.width = theSize[1] - 180 - 30 - 8
		it_search_right.pos = [theSize[1] - 34,0]
		it_clear.pos = [theSize[1] - 30, 0]
	)
 		
	on sceneList close do
	(
		--Dispose images in imagelist
		try
		(
			for i=0 to (lv.ImageList.Images.count - 1) do
			(
				lv.ImageList.Images.Item[i].Dispose()
			)
			lv.ImageList.Dispose()
			lv.Dispose()
		)catch()
		--Dispose images in imagelist
		try
		(
			for i=0 to (lv_2.ImageList.Images.count - 1) do
			(
				lv_2.ImageList.Images.Item[i].Dispose()
			)
			lv_2.ImageList.Dispose()
			lv_2.Dispose()
		)catch()
		--Garbage Collection to unlock bitmaps
		gc light:true
		dgc = dotnetclass "system.gc"
		dgc.collect()
	)
)
createDialog sceneList style:#(#style_resizing,#style_titlebar,#style_sysmenu)