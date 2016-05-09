try(destroyDialog GLL_SUBMIT_EFFECT)catch()
filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"


rollout GLL_SUBMIT_EFFECT "Submit Effect"
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

	--SFX
	label lbl_SFX "SFX File:" pos:[10,310]
	edittext et_SFX_file width:340 pos:[10,330]
	button btn_SFX_browse "Browse SFX File..." width:160 pos:[10,350]
	
	--Material name
	label lbl_mat_name "Material Name:" pos:[10,380]
	edittext et_mat_name width:340 pos:[10,400]
	
	--Author
	label lbl_author "Author's E-Mail:" pos:[10,430]
	edittext et_author width:340 pos:[10,450] readonly:true
	
	--Thumbnail
	local bm = bitmap 128 128 color:(color 0 0 0)
	imgtag it_thumb bitmap:bm width:128 height:128 pos:[206,5]
	radiobuttons rb_geo labels:#("Sphere", "Box") pos:[220,133]
	button btn_render_thumb "Render Thumbnail" width:128 pos:[206,148] enabled:false
	
	--Description
	label lbl_description "Description:" pos:[370,10]
	edittext et_description pos:[370,30] width:160 height:120
	
	--Tags
	label lbl_tags "Select tags:" pos:[370,160]
	multilistbox mlb_tags pos:[370,180] width:160 height:19
	button btn_add_tag "Add New Tag" pos:[370,435] width:160
	button btn_refresh_tag "Refresh Tag List" pos:[370,455] width:160
	
	--Add Material
	button btn_add_effect "Add Effect" align:#center height:40 width:180
	
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
		RB_STATE = GLL_SUBMIT_EFFECT.rb_geo.state
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
		
		
	fn GET_AUTHOR xml =
	(
		local XML_ARRAY = (dotnetClass "System.IO.File").ReadAllLines xml
		for n in XML_ARRAY do
		(
			if matchpattern n pattern:("*<author>*</author>*") do
			(
				local THE_AUTHOR = trimleft n
				THE_AUTHOR = substitutestring THE_AUTHOR "<author>" ""
				THE_AUTHOR = substitutestring THE_AUTHOR "</author>" ""
				return THE_AUTHOR
			)
		)
		return false
	)
	
	fn GET_CG_GLSL_FILES xml =
	(
		local THE_DEPENDENCIES = #()
		local THE_SOURCE = (dotnetClass "System.IO.File").ReadAllLines xml
		for n in THE_SOURCE do
		(
			if matchpattern n pattern:("*.cg*") OR matchpattern n pattern:("*.glsl*") do
			(
				local THE_STRING = substitutestring n "\"" "."
				THE_STRING = substitutestring THE_STRING "<" "."
				THE_STRING = substitutestring THE_STRING ">" "."
				local THE_ARRAY = filterstring THE_STRING "."
				
				for i=1 to THE_ARRAY.count do
				(
					if matchpattern THE_ARRAY[i] pattern:"GLSL" OR matchpattern THE_ARRAY[i] pattern:"cg" do
					(
						appendifunique THE_DEPENDENCIES (THE_ARRAY[i-1] + "." + THE_ARRAY[i])
					)
				)
			)
		)
		return THE_DEPENDENCIES
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
		
		--Bdae File
		et_bdae.text = pathconfig.stripPathToLeaf BDAE_FILE

		--The temp folder
		local TEMP_FOLDER = GetDir #userscripts + "\\GLL_Launcher\\temp\\"
		makedir TEMP_FOLDER
		--Clean up temp files
		for f in getFiles (TEMP_FOLDER + "*.*") do (deleteFile f)

		--Copy BDAE file as ZIP file
		local ZIP_FILE = (TEMP_FOLDER + getFileNameFile BDAE_FILE + ".zip")
		copyFile BDAE_FILE ZIP_FILE
		
		--Unzip the file
		unmaz ZIP_FILE TEMP_FOLDER
		
		--Files
		lb_files.items = GET_CG_GLSL_FILES (TEMP_FOLDER + "\\source.dae")
		
		--Author
		et_author.text = (GET_AUTHOR (TEMP_FOLDER + "\\source.dae")) + "@gameloft.com"
		
		--Clean up temp files
		for f in getFiles (TEMP_FOLDER + "*.*") do (deleteFile f)
		
		--UI Stuff
		ddl_material.selection = material
		
		et_mat_name.text = THE_MATERIAL.name
	)
	
	fn clear_values =
	(
		it_thumb.bitmap = bm
		deleteFile "$userscripts\\GLL_Launcher\\temp\\thumb.png"
		
		lb_files.items = #()
		ddl_material.selection = 0
		
		et_bdae.text = ""
		et_SFX_file.text = ""
		et_mat_name.text = ""
		et_author.text = ""
		et_description.text = ""
	)
	
	on ddl_material selected arg do
	(
		clear_values()
		load_material arg
		btn_render_thumb.enabled = true
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
	
	on btn_SFX_browse pressed do
	(
		--user has to select file
		theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select SFX file" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "SFX files (*.sfx)|*.sfx" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		result = theDialog.showDialog() --display the dialog, get result into variable
		test = result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
		
		if theFilenames.count != 0 do
		(
			et_SFX_file.text = theFilenames[1]
		)
	)
	
	
	on btn_add_effect pressed do
	(
		local EXPORT_READY = true
		
		if ddl_material.selection == 0 do
		(
			EXPORT_READY = false
			messagebox "You need to select a material!"
		)
		
		if et_SFX_file.text == "" do
		(
			if querybox "No SFX file was selected. Are you sure you want to continue?" == false do
			(
				EXPORT_READY = false
			)
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
			local NEW_EFFECT_FOLDER = THE_PROJECT_PATH + "\\" + et_bdae.text
			
			--Create Folder
			makedir NEW_EFFECT_FOLDER
			
			--Copy thumb.png
			copyFile "$userscripts\\GLL_Launcher\\temp\\thumb.png" (NEW_EFFECT_FOLDER + "\\thumb.png")
			
			--Copy BDAE file
			copyFile ((GET_EFFECTSLIBRARY_PATH()) + "\\" + et_bdae.text) (NEW_EFFECT_FOLDER + "\\" + et_bdae.text)
			
			--Copy GLSL and CG files
			for n in lb_files.items do
			(
				local THE_FILE = (GET_SHADERLIBRARY_PATH()) + "\\" + n
				copyFile THE_FILE (NEW_EFFECT_FOLDER + "\\" + getFileNameFile n + getFileNameType n)
			)
			
			--Copy SFX file
			if et_SFX_file.text != "" do
			(
				copyFile et_SFX_file.text (NEW_EFFECT_FOLDER + "\\" + getFileNameFile et_SFX_file.text + getFileNameType et_SFX_file.text)
			)
			
			--Create INI file
			local THE_INI = NEW_EFFECT_FOLDER + "\\info.ini"
			
			if et_SFX_file.text != "" do
			(
				setINIsetting THE_INI "Info" "SFX" (pathConfig.stripPathToLeaf et_SFX_file.text)
			)
			setINIsetting THE_INI "Info" "Files" (lb_files.items as string)
			setINIsetting THE_INI "Info" "BDAE" (et_bdae.text)
			setINIsetting THE_INI "Info" "Tags" ((for n in mlb_tags.selection collect mlb_tags.items[n]) as string)
			setINIsetting THE_INI "Info" "Add Info" ((filterstring et_description.text "\n") as string)
			setINIsetting THE_INI "Info" "Author" et_author.text
			setINIsetting THE_INI "Info" "Name" et_mat_name.text
			
			messagebox "Material added!"
			
			shellLaunch NEW_EFFECT_FOLDER ""
		)

	)

	on GLL_SUBMIT_EFFECT open do
	(
		makedir (getDir #userscripts + "\\GLL_Launcher\\temp\\")
		deleteFile "$userscripts\\GLL_Launcher\\temp\\thumb.png"
		
		if (THE_PROJECT_PATH as string) != "OK" then
		(
			et_project.text = substitutestring (pathconfig.stripPathToLeaf THE_PROJECT_PATH) "\\" ""
		)
		else
		(
			messagebox "The current project has no material library setup. TO DO: Help setup new library."
			destroyDialog GLL_SUBMIT_EFFECT
		)
		
		--Material dropdownlist
		ddl_material.items = for n in THE_GL_EFFECT_MATS collect n.name
		ddl_material.selection = 0
		
		--Load Tags
		mlb_tags.items = (dotnetClass "System.IO.File").ReadAllLines (DEPOT_PATH + "\\GL_EffectLibrary\\TAGS.txt")
		
		--No thumbnail
		it_thumb.transparent = (color 255 0 255)
	)
	
	on GLL_SUBMIT_EFFECT close do
	(
		deleteFile "$userscripts\\GLL_Launcher\\temp\\thumb.png"
	)
	
)
createDialog GLL_SUBMIT_EFFECT width:540 height:530