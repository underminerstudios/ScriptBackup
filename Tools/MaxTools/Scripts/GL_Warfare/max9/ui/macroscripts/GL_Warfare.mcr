macroScript GL_Warfare
	category:"GL Scripts"
	toolTip:"GL Warfare"
	buttonText:"GL Warfare"
	Icon:#("GL_Warfare",1)

(

-- global
global GLWarfareDialog
global ref_obj
global GameCamera

-- local
local bt_cam_frame_state
local ui_ts_state 
local ui_tb_state 
local ui_sp_state 
local ui_cp_state

if displaySafeFrames == true then
	(bt_cam_frame_state = true) else
	(bt_cam_frame_state = false)

if timeSlider.isVisible() == true then
	(ui_ts_state = true) else
	(ui_ts_state = false)

if trackbar.visible == true then
	(ui_tb_state = true) else
	(ui_tb_state = false)

if statusPanel.visible == true then
	(ui_sp_state = true) else
	(ui_sp_state = false)
	
if cui.commandPanelOpen == true then
	(ui_cp_state = true) else
	(ui_cp_state = false)

-- Duplicate Material Name Dialog Remover
dialogMonitorOps.unRegisterNotification id:#test
fn checkDialog = (
	local WindowHandle = dialogMonitorOps.getWindowHandle()
	if (uiAccessor.getWindowText WindowHandle == "Duplicate Material Name") then (
		uiAccessor.pressButtonByName WindowHandle "Use Scene Material"
		)
	true
	)

rollout GLWarfareDialog "GL Warfare"
(
	group "Camera"
		(
		button bt_cam_iso "Game Camera" height:20 align:#left toolTip:"Select 1 Object Only"
		)

	on bt_cam_iso pressed do 
		(
		if selection.count == 1 then (
			module = $
			cam_game_pivot = module.pivot
			if $Camera_InGame != undefined do delete $Camera_InGame
			GameCamera = Freecamera fov:52.6386 targetDistance:10000 nearclip:1 farclip:1000 nearrange:0 farrange:1000 mpassEnabled:off mpassRenderPerPass:off pos:cam_game_pivot isSelected
			GameCamera.name = "Camera_InGame"
			rotate GameCamera (eulerAngles 45 0 45)
			in coordsys local move GameCamera [0,0,5000]
			viewport.setCamera GameCamera
			)
			else (
			messagebox "Select 1 Object Only"
			)
		)

	group "Alpha"
	(
		checkbutton alpha_vc_display    "Display Alpha"   height:20 align:#left checked:false
		button alpha_fix_sort_object    "Sort Object"     height:20 align:#left
		button alpha_fix_sort_subobject "Sort Sub-Object" height:20 align:#left
	)
		
	on alpha_vc_display changed state do (
		if selection.count != 0 then (
			if state == on
			then (
				$.showVertexColors = false
				)
			else (
				$.showVertexColors = true
				)
			)
			else (
			messagebox "Select at least one object"
			if state == on then (
				alpha_vc_display.state = off
				)
				else (
				alpha_vc_display.state = on
				)
			)
		)

	on alpha_fix_sort_object pressed do 
		(
		obj = selection as array
		if obj.count == 0 then (
			messagebox "Select one or more objects"
			)
		if obj.count == 1 then (
			maxops.clonenodes obj[1] newNodes:&objcopy
			objcopy[1].name = obj[1].name
			delete obj[1]
			select objcopy
			)
		if obj.count >= 2 then (
			if $Camera_InGame != undefined then (
				cam = GameCamera
				objdislist = for i = 1 to ( obj.count ) collect Face m_id:i m_distance:(length ( cam.pos - obj[i].pivot ))
				qsort objdislist CompareFaces
				for i = 1 to ( objdislist.count ) do (
					maxops.clonenodes obj[objdislist[(1+objdislist.count)-i].m_id] newNodes:&objcopy
					objcopy[1].name = obj[objdislist[(1+objdislist.count)-i].m_id].name
					delete            obj[objdislist[(1+objdislist.count)-i].m_id]
					)
				)
			else (
				messagebox "Create a Game Camera First"
				)
			)
		)
	
	on alpha_fix_sort_subobject pressed do 
		(
		if selection.count == 1 then (
			if $Camera_InGame != undefined then (
				obj = $
				cam = GameCamera
				facedislist = for i = 1 to ( polyOp.getNumFaces obj ) collect Face m_id:i m_distance:(length ( cam.pos - polyOp.getFaceCenter obj i ))
				qsort facedislist CompareFaces
				for i = 1 to ( facedislist.count ) do (
					polyOp.setFaceSelection obj facedislist[(1+facedislist.count)-i].m_id
					obj.detachToElement #Face keepOriginal:true
					)
				for i = 1 to ( facedislist.count ) do (
					polyop.DeleteFaces obj 1
					)
				polyOp.weldVertsByThreshold obj #all
				)
			else (
				messagebox "Create a Game Camera First"
				)
			)
		else (
			messagebox "Select one object only"
			)
		)
		
	group "Clear Map Channel"
	(
		button bt_del_chun "Bad (-2, -1, 3-9)" height:20 align:#left
		button bt_del_chlm "LightMap      (2)" height:20 align:#left
		button bt_del_chvc "VertexColor   (0)" height:20 align:#left
	)

	on bt_del_chun pressed do
	(
		obj = selection as array
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 9
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 8
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 7
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 6
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 5
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 4
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 3
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = -1
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = -2
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
	)

	on bt_del_chlm pressed do
	(
		obj = selection as array
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 2
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
	)

	on bt_del_chvc pressed do
	(
		obj = selection as array
		modPanel.addModToSelection (UVW_Mapping_Clear())
		obj[1].modifiers[#UVW_Mapping_Clear].mapID = 0
		for i = 1 to obj.count do
		(
			maxOps.CollapseNode obj[i] off
		)
	)

	group "Material"
		(
		button  bt_cleareditor "Clear Editor"    height:20 align:#left toolTip:"Clear All Slots from the Material Editor"
		button  bt_scene2mat   "Scene 2 Editor"  height:20 align:#left toolTip:"Add all scene materials to the Material Editor"
		)

	on bt_cleareditor pressed do
		(
		i=0
		while i< 24 do
			(
			i=i+1
			meditMaterials[i]=standard() 
			)
		)

	on bt_scene2mat pressed do
		(
		i=0
		numberOfMaterials = sceneMaterials.count
		if numberOfMaterials > 24 then numberOfMaterials = 24
		while i< numberOfMaterials do
			(
			i=i+1
			meditMaterials[i]=sceneMaterials[i]
			)
		)

	group "Reference"
	(
		button bt_ref_add  "Show"           height:20 align:#center across:2
		button bt_ref_del  "Hide"           height:20 align:#center
		button bt_ref_list "Print Obj List" height:20 align:#center
	)

	on bt_ref_list pressed do (
		list = #()
		intArray = selection as array
		for i = 1 to intArray.count do (
			append list intArray[i].name
			)
		print list #noMap
		)
		
	on bt_ref_add pressed do (
		if selection.count == 1 then (
			obj_gmapref = $
			if obj_gmapref.children.count == 0 then (
				xml_3d_data = openFile "M:\\tools\\maxscripts\\warfare_data_3d.xml"
				name_gmapref = obj_gmapref.name
				name_gmapref_xml = readDelimitedString (stringStream name_gmapref) "_"
				skipToString xml_3d_data "folder=\""
				folder_root = readDelimitedString xml_3d_data "\""
				skipToString xml_3d_data name_gmapref_xml
				skipToString xml_3d_data "folder=\""
				folder_gmapref = readDelimitedString xml_3d_data "\""
				skipToString xml_3d_data "maxscene=\""
				maxscene_name = readDelimitedString xml_3d_data "\""
				name_file = (folder_root + folder_gmapref + maxscene_name)
				skipToString xml_3d_data "reflist=\""
				ref_list_obj = readDelimitedString xml_3d_data "\""
				ref_list = filterString ref_list_obj ","
				all_gmapref = for objOn in objects where MatchPattern objOn.name pattern:(name_gmapref_xml+"*") collect objOn

				--Duplicate Material Name Remover
				dialogMonitorOps.enabled = true
				dialogMonitorOps.interactive = false
				dialogMonitorOps.registerNotification checkDialog id:#test
				with redraw off (
					for i = 1 to all_gmapref.count do (
						ref_obj = xrefs.addNewXRefObject name_file ref_list
						for r = 1 to ref_obj.count do 
							(
							if ref_obj[r].name == ref_list[1] do (
								root_obj = ref_obj[r]
								freeze ref_obj
								hide root_obj
								root_obj.position.controller[1].value = all_gmapref[i].position.controller[1].value
								root_obj.position.controller[2].value = all_gmapref[i].position.controller[2].value
								root_obj.position.controller[3].value = all_gmapref[i].position.controller[3].value
								root_obj.rotation.controller[1].value = all_gmapref[i].rotation.controller[1].value
								root_obj.rotation.controller[2].value = all_gmapref[i].rotation.controller[2].value
								root_obj.rotation.controller[3].value = all_gmapref[i].rotation.controller[3].value
								root_obj.parent = all_gmapref[i]
								)
							)
						)
					)
				dialogMonitorOps.enabled = false

				flush xml_3d_data
				close xml_3d_data
				)
			else (
				messagebox "Thoses instance dummy already have their reference on it"
				)
			)
		else (
			messagebox "Select 1 instance dummy"
			)
		)

	on bt_ref_del pressed do (
		if selection.count == 1 then (
			obj_gmapref = $
			if obj_gmapref.children.count != 0 then (
				xml_3d_data = openFile "M:\\tools\\maxscripts\\warfare_data_3d.xml"
				name_gmapref = obj_gmapref.name
				name_gmapref_xml = readDelimitedString (stringStream name_gmapref) "_"
				skipToString xml_3d_data "folder=\""
				folder_root = readDelimitedString xml_3d_data "\""
				skipToString xml_3d_data name_gmapref_xml
				skipToString xml_3d_data "folder=\""
				folder_gmapref = readDelimitedString xml_3d_data "\""
				skipToString xml_3d_data "maxscene=\""
				maxscene_name = readDelimitedString xml_3d_data "\""
				name_file = (folder_root + folder_gmapref + maxscene_name)
				skipToString xml_3d_data "reflist=\""
				ref_list_obj = readDelimitedString xml_3d_data "\""
				ref_list = filterString ref_list_obj ","
				with redraw off (
					for i = 1 to ref_list.count do (
						delete (GetNodeByName ref_list[i] all:true)
						)
					)
				flush xml_3d_data
				close xml_3d_data
				)
			else (
				messagebox "Thoses instance dummy doesn't have their reference on it"
				)
			)
		else (
			messagebox "Select only 1 instance dummy"
			)
		)
		
	group "Export"
	(
	button bt_exp       ">> Export <<" height:20 align:#center
	button bt_exp_light "Scene Lights" height:20 align:#center
	)

	on bt_exp pressed do
	(
		SceneName       = maxFileName
		if SceneName   == "" then messagebox "Nothing to Export" else
		(
			SceneNameArray  = filterString SceneName "."
			bdaeName        = SceneNameArray[1]
			bdaePath        = maxFilePath + bdaeName
			bdaeNameArray   = filterString bdaeName "_"
			if bdaeNameArray[1] == "US" or bdaeNameArray[1] == "Weap" then
			(
				select $*
				sceneobj = selection as array
				for obj in geometry do
				(
					if ( not isKindOf obj BoneGeometry ) and ( not isKindOf obj Biped_Object ) then
					(
						hide obj
					)
				)
				CM_ExportFile bdaePath export_selected:false selected_preset:"_ANIM_"
				unhide sceneobj
			) else 
			(
				FolderNameArray = filterString maxFilePath "\\"
				AssetPath = #()
				for i = 1 to FolderNameArray.count do
					(
					if FolderNameArray[i] == "3d" do append AssetPath FolderNameArray[i+1]
					)
				if AssetPath.count == 0 then ( messagebox "Your Max Scene don't came from the warfare project folder \"data/3d\"" )
				else (
					PresetName = AssetPath[1] + "__" + bdaeName
					CM_ExportFile bdaePath export_selected:false selected_preset:PresetName
				)
			)
		)
	)
	
	on bt_exp_light pressed do
	(
		SceneName       = maxFileName
		if SceneName   == "" then messagebox "Nothing to Export" else
		(
			SceneNameArray  = filterString SceneName "."
			bdaeName        = SceneNameArray[1]
			bdaePath        = maxFilePath + bdaeName + "_light"
			CM_ExportFile bdaePath export_selected:false selected_preset:"_LIGHTS_"
		)
	)
	
	group "UI Setting"
	(
		colorpicker cp_bc "    BG Color   "      color:[128,128,128] modal:false fieldWidth:16 height:16
		checkbutton ui_ts "   Time Slider     "  width:90 height:20 align:#right checked:ui_ts_state
		checkbutton ui_tb "   Track Bar      "	 width:90 height:20 align:#right checked:ui_tb_state
		checkbutton ui_sp "  Status Panel   "	 width:90 height:20 align:#right checked:ui_sp_state
		checkbutton ui_cp "Command Panel "		 width:90 height:20 align:#right checked:ui_cp_state
	)

	on cp_bc changed new_col do
			setVPortBGColor(cp_bc.color)

	on ui_ts changed state do
		if state == on
		then timeslider.setvisible true
		else timeslider.setvisible false

	on ui_tb changed state do
		if state == on
		then trackbar.visible = true
		else trackbar.visible = false

	on ui_sp changed state do
		if state == on
		then statusPanel.visible = true
		else statusPanel.visible = false

	on ui_cp changed state do
		if state == on
		then cui.commandPanelOpen = true
		else cui.commandPanelOpen = false

) --rollout

createDialog GLWarfareDialog 116 620
cui.RegisterDialogBar GLWarfareDialog style:#(#cui_floatable,#cui_dock_left,#cui_dock_right,#cui_handles)

) --macro