try(destroyDialog GLL_SUBMIT_EFFECT_INST)catch()
filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"



rollout GLL_SUBMIT_EFFECT_INST "Submit Effect Instance"
(
	--Project
	label lbl_project "Current Project:" width:160 pos:[10,10]
	edittext et_project width:160 pos:[10,30] readonly:true

	--Material
	dropdownlist ddl_material "Select Material:" width:160 pos:[10,60]
	
	--BDAE file
	label lbl_bdae "BDAE File:" pos:[10,110]
	edittext et_bdae width:160 pos:[10,130] readonly:true
	
	--Files
	listbox lb_files "Files:" width:340 height:9 pos:[10,160] readonly:true
	
	--Material name
	label lbl_mat_name "Material Name:" pos:[10,310]
	edittext et_mat_name width:340 pos:[10,330]
	
	--Author
	label lbl_author "Author's E-Mail:" pos:[10,360]
	edittext et_author width:340 pos:[10,380]
	
	--Thumbnail
	local bm = bitmap 128 128 color:(color 0 0 0)
	imgtag it_thumb bitmap:bm width:128 height:128 pos:[206,5]
	radiobuttons rb_geo labels:#("Sphere", "Box") pos:[220,133]
	button btn_render_thumb "Render Thumbnail" width:128 pos:[206,148] enabled:false
	

	--Tags
	label lbl_tags "Select tags:" pos:[370,10]
	multilistbox mlb_tags pos:[370,30] width:160 height:25
	button btn_add_tag "Add New Tag" pos:[370,370] width:160
	button btn_refresh_tag "Refresh Tag List" pos:[370,390] width:160
	
	--Add Material
	button btn_add_effect "Add Effect Instance" align:#center height:40 width:180

	local THE_GL_EFFECT_MATS = for i=1 to meditmaterials.count where (classof meditmaterials[i]) == GL_Effect_Inst collect (meditmaterials[i])
	local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local PROJECT_SVN_URL = GET_PROJECT_URL()
	local THE_PROJECT_PATH = for d in getDirectories (DEPOT_PATH + "\\GL_EffectLibrary\\Projects\\*") where (getINIsetting (d + "\\info.ini") "Project" "SVN_URL") == PROJECT_SVN_URL do exit with (pathConfig.normalizepath d)
	

	fn GENERATE_THUMB material =
	(
		local UI_COLOR = GetUIColor 41
		SetUIColor 41 (color 0.0862745098039216 0.0862745098039216 0.0862745098039216)
		colorMan.repaintUI #repaintAll
		--Hold the Max File
		holdMaxFile()
		disablesceneredraw()

		local THE_GL_EFFECT_MATS = for i=1 to meditmaterials.count where (classof meditmaterials[i]) == GL_Effect_Inst collect (meditmaterials[i])

		local THE_MATERIAL = THE_GL_EFFECT_MATS[material]
		local THE_LIGHTS = #()
		local THE_LIGHT = undefined
		local TO_DELTE = #()

		for n in objects do
		(
			if (superclassof n)==light then
			(
				append THE_LIGHTS n
			)
			else
			(
				append TO_DELTE n
			)
		)
		
		for n in TO_DELTE do
		(
			try
			(
				delete n
			)
			catch()
		)
		
		if THE_LIGHTS.count != 0 do
		(
			THE_LIGHT = THE_LIGHTS[1]
		)

		--The Depot location
		local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
		--Merge the Template Max File
		RB_STATE = GLL_SUBMIT_EFFECT_INST.rb_geo.state
		if RB_STATE == 1 then
		(		
			mergeMaxFile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\THUMBNAIL_SPHERE.max") #AutoRenameDups #useMergedMtlDups #alwaysReparent
		)
		else
		(
			mergeMaxFile (DEPOT_PATH + "\\GL_EffectLibrary\\Resources\\THUMBNAIL_BOX.max") #AutoRenameDups #useMergedMtlDups #alwaysReparent
		)

		--Move the previous light to the new light's location and delete the new one.
		if THE_LIGHT != undefined do
		(
			try
			(
			THE_LIGHT.pos = ($THUMB_LIGHT).pos
			delete ($THUMB_LIGHT)
			)catch()
		)

		--Apply the material to the thumbnail geometry
		($THUMB_OBJECT).material = THE_MATERIAL
		
		--Reset viewport in order to get rid of statistics and other viewport settings that can't be changed through maxscript
		viewport.ResetAllViews()
		--Camera View
		actionMan.executeAction 0 "40068"
		--Maximize Viewport
		max tool maximize
		--Hide the grid
		actionMan.executeAction 0 "40077"
		--Enable scene redraw again
		enablesceneredraw()
		
		--Change path of GrabViewport profile
		setINIsetting "$userscripts\\GLL_Launcher\\Grabviewportpresets.ini" "MAT_THUMB" "savepath" (getDir #userscripts + "\\GLL_Launcher\\temp\\")
		setINIsetting "$userscripts\\GLL_Launcher\\Grabviewport.ini" "Settings" "savepath" (getDir #userscripts + "\\GLL_Launcher\\temp\\")
		
		--Change render size
		renderWidth = 128
		renderheight = 128

		--Run Modified GrabViewport Script
		filein (DEPOT_PATH + "\\GL_EffectLibrary\\MaxScript\\GLL_Grabviewport.ms")
		macros.run "Gameloft" "GLL_GrabViewport2"

		fetchMaxFile quiet:true

		SetUIColor 41 UI_COLOR
		colorMan.repaintUI #repaintAll
	)
		
	fn load_material material=
	(
		local THE_MATERIAL = THE_GL_EFFECT_MATS[material]

		try --This is for MaxScript API
		(
			local BDAE_FILE = (GET_EFFECTSLIBRARY_PATH()) + "\\" + (THE_MATERIAL.lib).effectFile
		)
		catch --This is if no MaxScript API is 
		(
			local BDAE_FILE = (GET_EFFECTSLIBRARY_PATH()) + "\\" + (GET_BDAE_FILE material)
		)
		
		local BDAE_FOLDER =  (THE_PROJECT_PATH + (pathconfig.stripPathToLeaf BDAE_FILE))

		if doesfileexist BDAE_FOLDER then
		(
			--Get dependency files
				--Hold max file
				holdMaxFile()
				disablesceneredraw()
				
				--Save material to temp library
				local THE_MAT_LIB = materialLibrary THE_GL_EFFECT_MATS[material]
				--Reset max file
				resetMaxFile #noprompt
				--Add material to first slot
				meditmaterials[1] = THE_MAT_LIB[1]
				--Refresh Asset Tracker
				atsops.refresh()
				--Retrieve list of files
				local filelist
				atsops.GetFiles &fileList
				local final_filelist = for n in filelist where (matchpattern n pattern:"*.glsl") == false AND (matchpattern n pattern:"*.cg") == false AND (matchpattern n pattern:"*.bdae") == false collect n
				
				lb_files.items = final_filelist
				
				enablesceneredraw()
				fetchMaxFile quiet:true
			
			--Bdae File
			et_bdae.text = pathconfig.stripPathToLeaf BDAE_FILE

			--UI Stuff
			ddl_material.selection = material
			et_mat_name.text = THE_MATERIAL.name
			
			btn_render_thumb.enabled = true
		)
		else
		(
			messagebox "Error: The GL_EFFECT of this instance is not in the library. Add the GL_Effect first before adding a instance."
		)
	)
	
	fn clear_values =
	(
		it_thumb.bitmap = bm
		deleteFile "$userscripts\\GLL_Launcher\\temp\\thumb.png"
		
		lb_files.items = #()
		ddl_material.selection = 0
		
		et_bdae.text = ""
		et_mat_name.text = ""
	)
	
	on ddl_material selected arg do
	(
		clear_values()
		load_material arg
	)
	
	on btn_render_thumb pressed do
	(
		it_thumb.bitmap = bm
		deleteFile "$userscripts\\GLL_Launcher\\temp\\thumb.png"
		GENERATE_THUMB ddl_material.selection
		it_thumb.bitmap = (openBitmap "$userscripts\\GLL_Launcher\\temp\\thumb.png")
	)
	
	on btn_add_tag pressed do
	(
		shellLaunch "explorer.exe" ("/e,/select," + "\"" + (pathconfig.normalizepath (DEPOT_PATH + "\\GL_EffectLibrary\\TAGS.txt")) + "\"")
	)
	
	on btn_refresh_tag pressed do
	(
		mlb_tags.items = (dotnetClass "System.IO.File").ReadAllLines (DEPOT_PATH + "\\GL_EffectLibrary\\TAGS.txt")
	)
	
	
	on btn_add_effect pressed do
	(
		local EXPORT_READY = true
		
		if ddl_material.selection == 0 do
		(
			EXPORT_READY = false
			messagebox "You need to select a material!"
		)
		
		if (for n in mlb_tags.selection collect mlb_tags.items[n]).count == 0 do
		(
			if querybox "No tags were selected. Are you sure you want to continue?" == false do
			(
				EXPORT_READY = false
			)
		)
		
		if (doesfileexist "$userscripts\\GLL_Launcher\\temp\\thumb.png") == false do
		(
			EXPORT_READY = false
			messagebox "You need to render a thumbnail!"
		)

		
		if EXPORT_READY == true do
		(
			local NEW_EFFECT_INST_FOLDER = THE_PROJECT_PATH + "\\" + et_bdae.text + "\\" + ddl_material.selected
			
			--Create Folder
			makedir NEW_EFFECT_INST_FOLDER
			
			--Copy thumb.png
			copyFile "$userscripts\\GLL_Launcher\\temp\\thumb.png" (NEW_EFFECT_INST_FOLDER + "\\thumb.png")
			
			--Copy GLSL and CG files
			for n in lb_files.items do
			(
				copyFile n (NEW_EFFECT_INST_FOLDER + "\\" + getFileNameFile n + getFileNameType n)
			)
			
			--Create Mat file
			local MAT_LIB = materialLibrary (THE_GL_EFFECT_MATS[ddl_material.selection])
			saveTempMaterialLibrary MAT_LIB (NEW_EFFECT_INST_FOLDER + "\\matlib.mat")
			
			
			
			--Create INI file
			local THE_INI = NEW_EFFECT_INST_FOLDER + "\\info.ini"
			setINIsetting THE_INI "Info" "Files" (lb_files.items as string)
			setINIsetting THE_INI "Info" "Tags" ((for n in mlb_tags.selection collect mlb_tags.items[n]) as string)
			setINIsetting THE_INI "Info" "Author" et_author.text
			setINIsetting THE_INI "Info" "Name" et_mat_name.text
			
			--Finished!
			messagebox "Material added!"
			
			shellLaunch NEW_EFFECT_INST_FOLDER ""
		)

	)

	on GLL_SUBMIT_EFFECT_INST open do
	(
		makedir (getDir #userscripts + "\\GLL_Launcher\\temp\\")
		if (THE_PROJECT_PATH as string) != "OK" then
		(
			et_project.text = substitutestring (pathconfig.stripPathToLeaf THE_PROJECT_PATH) "\\" ""
		)
		else
		(
			messagebox "The current project has no material library setup. TO DO: Help setup new library."
			destroyDialog GLL_SUBMIT_EFFECT_INST
		)
		
		et_author.text = sysInfo.username + "@gameloft.com"
		
		ddl_material.items = for n in THE_GL_EFFECT_MATS collect n.name
		ddl_material.selection = 0
		
		mlb_tags.items = (dotnetClass "System.IO.File").ReadAllLines (DEPOT_PATH + "\\GL_EffectLibrary\\TAGS.txt")
		it_thumb.transparent = (color 255 0 255)
	)
	
	on GLL_SUBMIT_EFFECT_INST close do
	(
		deleteFile "$userscripts\\GLL_Launcher\\temp\\thumb.png"
	)
)
createDialog GLL_SUBMIT_EFFECT_INST width:540 height:460