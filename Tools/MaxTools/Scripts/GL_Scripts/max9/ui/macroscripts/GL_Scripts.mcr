macroScript GL_Scripts
	category:"GL Scripts"
	toolTip:"GL Scripts"
	buttonText:"GL Scripts"
	Icon:#("GL_Scripts",1)
(

global GLScriptsDialog
global UIRollout
global GameCamera

local bt_cam_frame_state
local ui_ts_state 
local ui_tb_state 
local ui_sp_state 
local ui_cp_state

-- Structure
	struct Face
	(
		m_id = -1,
		m_distance = 0
	)
	
-- Function
	function CompareFaces face0 face1 =
	(
		local returnValue = 0
		if face0.m_distance < face1.m_distance then
		(
			returnValue = -1
		)
		else if face0.m_distance > face1.m_distance then
		(
			returnValue = 1
		)
		return returnValue
	)


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

 -- UI & Action
	rollout GLScriptsDialog "GL Scripts"
	(
		group "Camera"
			(
			button bt_cam_iso "Game Camera"	align:#left toolTip:"Select 1 Mobule Root Box"
			checkbutton bt_cam_frame "Game Safe Frame"	checked:bt_cam_frame_state align:#left
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
				messagebox "Select 1 Module Root Only"
				)
			)
	
		on bt_cam_frame changed state do (
			renderHeight = 576
			renderWidth = 1024
			max safeframe toggle
			)
	
			group "Alpha"
			(
				checkbutton alpha_vc_display "Display Alpha"	checked:false align:#left
				button alpha_fix_sort_object "Sort Object"	align:#left
				button alpha_fix_sort_subobject "Sort Sub-Object"	align:#left
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
		
		group "Map Channel"
			(
			spinner sp_mapchannel "#"      align:#center across:2 width:42 height:16 type:#integer range:[-2,64,2] scale:1
			button  bt_del_mapchn "Delete" align:#center toolTip:"Delete On Selected Objects"
			)
	
		on bt_del_mapchn pressed do
			(
			obj = selection as array
			modPanel.addModToSelection (UVW_Mapping_Clear()) ui:on
			obj[1].modifiers[#UVW_Mapping_Clear].mapID = sp_mapchannel.value
			for i = 1 to obj.count do
				(
				maxOps.CollapseNode obj[i] off
				)
			)
	
		group "Material"
			(
			button  bt_cleareditor "Clear Editor" align:#left toolTip:"Clear All Slots from the Material Editor"
			button  bt_scene2mat "Scene 2 Editor" align:#left toolTip:"Add all scene materials to the Material Editor"
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
	
		group "UI Setting"
			(
			colorpicker cp_bc "     BG Color   " color:[128,128,128] modal:false fieldWidth:16 height:16
			checkbutton ui_ts "    Time Slider     "checked:ui_ts_state align:#center
			checkbutton ui_tb "    Track Bar      "	checked:ui_tb_state align:#center
			checkbutton ui_sp "   Status Panel   "	checked:ui_sp_state align:#center
			checkbutton ui_cp "Command Panel "		checked:ui_cp_state align:#center
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
	
	) -- rollout

	createDialog GLScriptsDialog 126 460
	cui.RegisterDialogBar GLScriptsDialog style:#(#cui_floatable,#cui_dock_left,#cui_dock_right,#cui_handles)

)