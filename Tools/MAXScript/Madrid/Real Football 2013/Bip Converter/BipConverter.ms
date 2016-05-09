/*
	Bip Exporter - RF2013

	-by Norman Schaar norman.schaar@gameloft.com
*/

--Edit, commented out "regular" export since we only use the streamed version now


try(destroyDialog rf13_bip_converter)catch()

fn RF2013_BC_function =
(
	try(destroyDialog rf13_bip_converter)catch()
)


--Define Vars
global curRot = 0f
global offsetRotZ
global offsetPos
rollout rf13_bip_converter "RF13 BipConverter" width:168 height:210
(
	-- Biped Listbox
	listbox lb_bipeds "Bipeds:" height:3
	--- TURN KeyS
  	spinner turnStartKey_spinner "StartTurnKey" width:152 height:16 range:[0,100,0] type:#integer align:#right
  	spinner turnEndKey_spinner "EndTurnKey  " width:152 height:16 range:[0,100,0] type:#integer align:#right
	--- TURN ANGLE
  	spinner turnAngle_spinner "TurnAngle" width:144 height:16 range:[-180,180,0] type:#float align:#right
	
	-- Export Options
	radiobuttons rb_export labels:#("Regular Export", "Export Movement Dummies") default:1
	
	--- LAUNCH
  	button btnSourceDir "Export" width:112 height:24 enabled:true
	
	
	-- cancel translation XY on biped, transfer it to Dummy
	fn CancelTranslation theBiped theDummy=
	(
		corPos = biped.getTransform theBiped #pos

		-- Copy the biped position to the dummy
		theDummy.controller.position = [corPos.x, corPos.y, 0]
		
		-- Cancel the biped position
		biped.setTransform theBiped #pos [0, 0, corPos.z] true
	)

	-- cancel rotation around Z on biped, transfer it to Dummy
	fn CancelRotation theBiped theDummy=
	(
		orgQuatRot = biped.getTransform theBiped #rotation	
		
		-- Copy the biped Z axis rotation to the dummy
		corDummyEulerRot = orgQuatRot as eulerAngles
		corDummyEulerRot.x = 0
		corDummyEulerRot.y = 0
		corDummyEulerRot.z += 90 - offsetRotZ
		corDummyQuatRot = corDummyEulerRot as quat
		theDummy.controller.rotation = corDummyQuatRot
		
		-- Cancel the biped Z axis rotation
		corBipEulerRot = orgQuatRot as eulerAngles
		corBipEulerRot .z = -90 + offsetRotZ
		corBipQuatRot = corBipEulerRot as quat
		biped.setTransform theBiped #rotation corBipQuatRot true
	)

	
	-- FixAnimation: Create the dummy, put XY translation & Z rotation on it (remove them from the biped)
	fn FixAnimation theBiped theDummy=
	(
		-- save biped to "filename" then load "filename"
		ctrl = theBiped.transform.controller
		start = animationRange.start
		end = animationRange.end
		
		biped.saveBipFileSegment ctrl (GetDir #userscripts + "\\tmp.bip") start end #keyPerFrame #saveMaxObjects 
		biped.loadBipFile ctrl (GetDir #userscripts + "\\tmp.bip")
		
		at time 0f
		(
			offsetPos = biped.getTransform theBiped #pos
			offsetPos.z = 0
		
			rot_quat = biped.getTransform theBiped #rotation	
			rot_euler = rot_quat as eulerAngles
			offsetRotZ = rot_euler.z + 90
		)

		disableSceneRedraw()
		animate on
		(
			sa = theBiped.transform.controller.turning
			for key in sa.keys do
			(
				t = key.time
				at time t
				(
					addNewKey theDummy.controller t
					CancelTranslation theBiped theDummy
					CancelRotation theBiped theDummy
				)
			)
		)
		enableSceneRedraw()
	)
	
	--Mirror biped function
	fn MirrorBip theBiped=
	(
		ctrl = theBiped.transform.controller
		
		--Store inPlaceMode
		inPlaceMode = ctrl.inPlaceMode
		
		--Set inPlaceMode to false
		ctrl.inPlaceMode = false
	
		-- mirror
		biped.mirror ctrl
	
		-- Get your biped root node
		biped.getNode theBiped 13

		-- Turn on Move All Mode
		ctrl.moveAllMode = true

		--  Then you can rotate the biped doing something like this
		rotate theBiped (angleaxis 180.0 [0,0,1])

		-- Make sure you collapse Move All Mode if you need to
		biped.collapseMoveAllMode ctrl
	
		ctrl.moveAllMode = false

		--Restore inPlaceMode
		ctrl.inPlaceMode = inPlaceMode
	)
	
	--Export with dummies
	fn doExportCubeAnimAndPlayerAnim dirName_suffix theBiped=
	(
		curFileNameNoExt = getFilenameFile maxFileName
		
		-- create the dummy, put XY translation & Z rotation on it (remove them from the biped)
		theDummy = dummy()
		FixAnimation theBiped theDummy
		
		--Dummy Export
			-- select theDummy
			select theDummy
		
			--regular
			--exportPathCube = "W:\\export\\animation\\RF13_Anims_Mvmts" + dirName_suffix + "\\" + curFileNameNoExt + ".bdae"
			--CM_ExportFile(exportPathCube) show_prompt:false selected_preset:"Player_Anim_NoStream" animation_clip_options:"AUTO_Current_Range"
			
			--streamed
			exportPathCube = "W:\\export\\animation\\Anims_Streaming\\RF13_Anims_Mvmts" + dirName_suffix + "\\" + curFileNameNoExt + ".bdae"
			CM_ExportFile(exportPathCube) show_prompt:false selected_preset:"RF13_Streamed_Anim" animation_clip_options:"AUTO_Current_Range"
		
		delete theDummy
		
		--IN PLACE MODE TRUE --- Norman Test
		local ctrl = theBiped.transform.controller
		ctrl.inPlaceMode = true
		
		--Biped Export
			--select theBiped
			select theBiped
			
			--regular	
			--exportPath = "W:\\export\\animation\\RF13_Anims" + dirName_suffix + "\\" + curFileNameNoExt + ".bdae"
			--CM_ExportFile(exportPath) show_prompt:false selected_preset:"Player_Anim_NoStream" animation_clip_options:"AUTO_Current_Range"

			--streamed
			exportPath = "W:\\export\\animation\\Anims_Streaming\\RF13_Anims" + dirName_suffix + "\\" + curFileNameNoExt + ".bdae"
			CM_ExportFile(exportPath) show_prompt:false selected_preset:"RF13_Streamed_Anim" animation_clip_options:"AUTO_Current_Range"
	)
	
	-- remove rotations from anim if needed based on TurnStartkey and TurnEndKey values
	fn fn_RemoveRotTurnKeys theBiped =
	(
		if ((turnAngle_spinner.value!=0) and (turnEndKey_spinner.value>= turnStartKey_spinner.value)) do
		(
			disableSceneRedraw()
			animate on
			(
				-- get biped controller
				ctrl = theBiped.transform.controller
				sa = ctrl.turning
				curKey = 0
				for key in sa.keys do
				(
					t = key.time
					if t >= 0 do
					(					
						at time t
						(
							mybip = (biped.getNode theBiped 13)
							rot_quat = biped.getTransform mybip #rotation
							rot_euler = rot_quat as eulerAngles
						
							turnDuration = turnEndKey_spinner.value-turnStartKey_spinner.value
							
							--- ROTATION
							if (curKey <= turnStartKey_spinner.value) then
							(
								curRot = 0f
							)
							else
							(
								if (curKey >= turnEndKey_spinner.value) then
								(
									curRot = turnAngle_spinner.value
								)
								else
								(
									curRot = (turnAngle_spinner.value*1f*(curKey-turnStartKey_spinner.value))/(turnDuration*1f)
								)
							)
							rot_euler.z -= curRot
							
							biped.setTransform mybip #rotation (eulerToQuat rot_euler) true			
							
							curKey = curKey + 1
						)
					)
				)
			)
			enableSceneRedraw()
		)
	)
	
	--Start export function
	fn doExport theBiped=
	(	
		holdMaxFile()
		
		--uiAccessor function to press the "OK" button in the Glitch BDAE Warning Log
		dialogMonitorOps.unRegisterNotification id:#GlitchWarningLogOK
		   
		fn fn_GlitchWarningLogOK =
		(
			local hwnd = dialogMonitorOps.getWindowHandle()
		  
			if (uiAccessor.getWindowText hwnd == "Warning Log") do
			(
				UIAccessor.PressButtonByName hwnd "OK"
			)
		)

		dialogMonitorOps.enabled = true
		dialogMonitorOps.interactive = false
		dialogMonitorOps.registerNotification fn_GlitchWarningLogOK id:#GlitchWarningLogOK
		
		--Set slidertime to 0
		slidertime = 0
		
		--Select the biped
		select theBiped
			
		--remove rotations from anim if needed based on TurnStartkey and TurnEndKey values
		fn_RemoveRotTurnKeys theBiped
		
		curFileNameNoExt = getFilenameFile maxFileName
		
		-- Export Movement Dummies
		if rb_export.state == 2 then 
		(
			--ensure that biped is not in "in place mode"
			ctrl = theBiped.transform.controller
			ctrl.inPlaceMode = false
			
			doExportCubeAnimAndPlayerAnim "" theBiped
			MirrorBip theBiped
			doExportCubeAnimAndPlayerAnim "_Flip" theBiped
		)
		--Regular Export
		else
		(
			
			ctrl = theBiped.transform.controller
			ctrl.inPlaceMode = true
			
			-- export non flipped model	
				-- regular
				exportPath = "W:\\export\\animation\\RF13_Anims\\" + curFileNameNoExt + ".bdae"
				CM_ExportFile(exportPath) show_prompt:false selected_preset:"Player_Anim_NoStream" animation_clip_options:"AUTO_Current_Range"
				
				-- streamed
				exportPath = "W:\\export\\animation\\Anims_Streaming\\RF13_Anims\\" + curFileNameNoExt + ".bdae"
				CM_ExportFile(exportPath) show_prompt:false selected_preset:"RF13_Streamed_Anim" animation_clip_options:"AUTO_Current_Range"
			
			-- export flipped model
			MirrorBip theBiped
				-- regular
				exportPathFlip = "W:\\export\\animation\\RF13_Anims_Flip\\" + curFileNameNoExt + ".bdae"
				CM_ExportFile(exportPathFlip) show_prompt:false selected_preset:"Player_Anim_NoStream" animation_clip_options:"AUTO_Current_Range"

				-- streamed
				exportPathFlip = "W:\\export\\animation\\Anims_Streaming\\RF13_Anims_Flip\\" + curFileNameNoExt + ".bdae"
				CM_ExportFile(exportPathFlip) show_prompt:false selected_preset:"RF13_Streamed_Anim" animation_clip_options:"AUTO_Current_Range"
		)
		
		--Unregister DialogMonitorOps
		DialogMonitorOPS.UnRegisterNotification id:#GlitchWarningLogOK
		dialogMonitorOps.enabled = false
		
		fetchMaxFile quiet:true
	)

	-- Eventhandlers
  	on btnSourceDir pressed do
	(
		doExport (for o in objects where o.name == lb_bipeds.selected do exit with o)
	)
	
	on rf13_bip_converter open do
	(
		callbacks.removeScripts id:#RF2013_BC
		callbacks.addScript #filePreOpenProcess "RF2013_BC_function()" id:#RF2013_BC
		
		
		--Fill the listbox
		theBipeds = #()
		for o in objects where (classof o) == Biped_object do appendifUnique theBipeds (o.controller.rootName)
		lb_bipeds.items = theBipeds
		
		--Get StartTurnKey
		theStartTurnKey = undefiend
		for i=1 to (CM_GetNumEventGroups()) do
		(
			for j=1 to (CM_GetNumEventGroupEvents i) do
			(
				if (CM_GetEventGroupEvent i j)=="START_TURN" do
				(
					theStartTurnKey = (CM_GetEventGroupTime i)
					exit
				)
			)
		)
		
		if theStartTurnKey != undefined do
		(
			turnStartKey_spinner.value = theStartTurnKey as integer
		)
		
		--Get EndTurnKey
		theEndTurnKey = undefiend
		for i=1 to (CM_GetNumEventGroups()) do
		(
			for j=1 to (CM_GetNumEventGroupEvents i) do
			(
				if (CM_GetEventGroupEvent i j)=="END_TURN" do
				(
					theEndTurnKey = (CM_GetEventGroupTime i)
					exit
				)
			)
		)
		
		if theEndTurnKey != undefined do
		(
			turnEndKey_spinner.value = theEndTurnKey as integer
		)
		
		--Get Turn Angle
		theTurnAngle = undefined
		for i=1 to (CM_GetNumEventGroups()) do
		(
			for j=1 to (CM_GetNumEventGroupEvents i) do
			(
				if matchpattern (CM_GetEventGroupEvent i j) pattern:"TURN_INFO*" do
				(
					theTurnAngle = (CM_GetEventGroupEvent i j)
					theTurnAngle = substitutestring theTurnAngle "TURN_INFO_" ""
					theTurnAngle = substitutestring theTurnAngle "_" "."
					theTurnAngle = theTurnAngle as float
				)
			)
		)
		if theTurnAngle != undefined do
		(
			turnAngle_spinner.value = theTurnAngle
		)
		--The Export radiobuttons
		theExportList = (dotnetClass "System.IO.File").ReadAllLines "W:\\sources\\animation\\Doc_animations\\MaxFiles_need_dummy_export.txt"
		for n in theExportList do
		(
			if n == maxFileName do
			(
				rb_export.state = 2
			)
		)
		
		--Batch Export
		doExport (for o in objects where o.name == lb_bipeds.selected do exit with o)
	)
	
	on rf13_bip_converter close do
	(
		callbacks.removeScripts id:#RF2013_BC
	)
)
createDialog rf13_bip_converter