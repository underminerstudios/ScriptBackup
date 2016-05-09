--
--	\Title			MC4 Lightmapper	
--	
--	\Description	Un pipeline vray éclairage pour MC4. Voir "Help Document Rollout" pour voir comment l'utiliser.
--	\Description	
--	\Description	A vray lighting pipeline for MC4. See "Help Document Rollout " to see how to use it.
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 01/11/2012

oRootPath =	getFilenamePath (getThisScriptFilename())
ini_file = oRootPath + "lib\\Lightmapper.ini"

GetAllFunctionsArr = getFiles (oRootPath  + "lib\\*.ms")
for zz=1 to GetAllFunctionsArr.count do ( fileIn GetAllFunctionsArr[zz] )
	
(
	try(destroyDialog bakeDLG)catch()
	
	global oRootPath =	getFilenamePath (getThisScriptFilename())
	local ini_file = oRootPath + "lib\\Lightmapper.ini"

	local GetAllFunctionsArr = getFiles (oRootPath  + "lib\\*.ms")
	for zz=1 to GetAllFunctionsArr.count do ( fileIn GetAllFunctionsArr[zz] )
	
	global bakeDLG
	diagPos = filterstring (getINISetting ini_file "LightMap_Tool"  "LM_Coords") "[,],\,"
	global LM_Coords				= [diagPos[1]as integer, diagPos[2] as integer]
	global oNetPath 				= (getINISetting ini_file "LightMap_Tool"  "Network_Path" ) as string
	global Img_Size_Sel				= (getINISetting ini_file "LightMap_Tool"  "Texture_Size" ) as integer
	global tex_Size	
	global tex_Padding 				= (getINISetting ini_file "LightMap_Tool"  "Texture_Pad"  ) as integer
	global oUVChannel 				= (getINISetting ini_file "LightMap_Tool"  "UV_Channel"  ) as integer
	global oDialation 				= (getINISetting ini_file "LightMap_Tool"  "Bake_Dialation"  ) as integer
	global WBCamera 				= (getINISetting ini_file "LightMap_Tool"  "Use_WB_Camera"  ) as booleanClass
	global networkRender 			= (getINISetting ini_file "LightMap_Tool"  "Use_Network"  ) as booleanClass
	global deleteBakeMeshes			= (getINISetting ini_file "LightMap_Tool"  "Delete_Bake_Mesh"  ) as booleanClass
	global RO_Settings 				= (getINISetting ini_file "LightMap_Tool"  "RO_Settings"  ) as booleanClass
	global RO_Render_Preview 		= (getINISetting ini_file "LightMap_Tool"  "RO_Render_Preview"  ) as booleanClass
	global RO_Bake_Tools 			= (getINISetting ini_file "LightMap_Tool"  "RO_Bake_Tools"  ) as booleanClass
	global RO_Bake_Prep 			= (getINISetting ini_file "LightMap_Tool"  "RO_Bake_Prep"  ) as booleanClass
	global Bake_Path 				= undefined 
	--########## Render preset variables ##########
	global renPresets				= getFiles (oRootPath  + "presets/*.rps")
	global renderChoice 			= renPresets[1] --render preset selection takes the first one
	global presetArrName 			= #() --this one uses it in the drop down list in the Render Properties section
	local vr = renderers.current
	local DM
	local BM
	local renContrast
	local timeNode = $TimeNode
	if ( classof vr == V_Ray_Adv_1_50_SP6  )then
	(
		DM = vr.colorMapping_darkMult
		BM = vr.colorMapping_brightMult
		renContrast = 0.20
	)
	print (oRootPath)
	--copy over the nework render settings:
	source = oRootPath + "presets\\vray_dr.cfg"
	plugcfgPath =(GetDir #plugcfg )
	destination = plugcfgPath + "//" + getFilenameFile source + getFilenameType source
	if ((getFiles destination ).count ) == 0 then
	(
		copyFile source destination
	)


	rollout HelpMe "Help Document"
	(
		button btn_Help "Help" tooltip:"Help Document" width:(220)
		on btn_Help pressed do 
		(
			HelpDocument = oRootPath + "LightMapper.odt"
			shellLaunch HelpDocument ""
		)
	)
	rollout sSettings "Settings"
	(
		group "RTT Image Properties"
		(
			dropdownlist sSize "Render Image Size" items:#("256", "512", "1024", "2048", "4096") selection:Img_Size_Sel  width:275 enabled:true align:#right
			spinner sChannel "Channel:" 			range:[1,99,oUVChannel] type:#integer fieldwidth:30 enabled:true align:#right across:2 offset:[50,0]
			spinner sDilations "Dialations:" 			range:[1,100,oDialation] type:#integer fieldwidth:20 
		)
		group "Render Settings"
		(
			edittext txtaddress "Network Address:" text: (oNetPath as string ) fieldWidth:280 labelOnTop:true across:2
			checkbox cNetRen  "Network Render"	offset:[20, 0] align:#center checked:networkRender
			dropdownlist renderSetting_dd  		items:presetArrName width:285 enabled:true align:#right 
			checkbox cCamera  "Use White Balance Cam" 	align:#center checked:WBCamera across:2
			checkbox cDelBakeM  "Delete Bake Mesh" 	offset:[5, 0] align:#center checked:deleteBakeMeshes
			button brSettings "Set Preset" width:290 
		)
		group "Light Subdivisions"
		(
			spinner sLightSubD "Light Subdivision:" range:[1,200,8] type:#integer fieldwidth:20 across:2 
			checkbox cLSelected  "Selected Lights" checked:false offset:[10,0]
			button bLightSubD "Set Light Subdivision" width:290 
		)
		--This subdivides the VRay Lights in your scene
		on bLightSubD pressed do 
		(
			if  (cLSelected.state == true)then
			(
				undo on
				(
					for zz in selection do
					(
						if classof zz == VRayLight or classof zz == VRaySun then
						(
							if (hasProperty zz "subdivs") == true then
							(
								zz.subdivs = sLightSubD.value
							)
							if (hasProperty zz "shadow_subdivs") == true then
							(
								zz.shadow_subdivs = sLightSubD.value
							)
						)
					)
				)
			)
			else
			(
				undo on
				(
					for zz in lights do
					(
						if classof zz == VRayLight and (hasProperty zz "subdivs") == true then
						(
							zz.subdivs = sLightSubD.value
						)
						if classof zz == VRaySun and (hasProperty zz "shadow_subdivs") == true then
						(
							zz.shadow_subdivs = sLightSubD.value
						)
					)
				)
			)
		)
		on sChannel changed value do (oUVChannel = sChannel.Value )		

		on sSize  selected i do( tex_Size = (sSize.items[i] as integer) )		
		on sDilations changed value do (oDialation = sDilations.Value)		
		on sTexPadd changed value do (tex_Padding = sTexPadd.Value)	
		on sUVAngle changed value do (UV_Angle = sUVAngle.Value)	
		
		on cCamera changed theState do(WBCamera =  theState )
		on cDelBakeM changed theState do (deleteBakeMeshes =  theState )
		on cNetRen changed theState do (networkRender =  theState)
		on renderSetting_dd selected i do(renderChoice = renPresets [i]	)
		
		on brSettings pressed do 
		(
			if renderChoice ==  renPresets[4] then 
			(
				renderPresets.loadall  0 renderChoice 
				print ("setting outside render style")
				Set_Vray_Light ()
				vr = renderers.current
				vr.system_distributedRender = networkRender
				timeNode = $TimeNode
				
			)
			else
			(
				local oRender = renderers.current
				if (matchPattern (oRender  as string ) pattern:"*V_Ray*") then
				(
					local GIEState = #()
					local vr=renderers.current
					append  GIEState  vr.environment_gi_on
					append  GIEState  vr.environment_gi_map
					append  GIEState  vr.environment_gi_map_on
					append  GIEState  vr.environment_gi_color
					append  GIEState  vr.environment_gi_color_multiplier 
				)
				renderPresets.loadall  0 renderChoice 
				
				if (matchPattern (oRender  as string ) pattern:"*V_Ray*") then
				(
					vr=renderers.current
					vr.system_distributedRender = networkRender
					vr.environment_gi_on					= GIEState[1]
					vr.environment_gi_map					= GIEState[2] 
					vr.environment_gi_map_on				= GIEState[3] 
					vr.environment_gi_color				= GIEState[4]
					vr.environment_gi_color_multiplier	= GIEState[5]
				)
			)
		)
	)
	vrSun = for i in (lights) where classof i == VRaySun collect i
	rollout sRenPrev "Render Preview"
	(
		button btn_RenderWindow "Press To Preview Scene" width:300 height:225
		colorpicker cp_whiteBalance "WB"color:[191, 226, 255] offset:[215,0] modal:false width:70 height:15 offset:[75,0] tooltip:"White Balance of scene - Color is inverted"
		label labDwn 		"Dawn" offset:[-28,-20] across:3
		label labNoon 		"Noon" offset:[-34,-20]
		label labDsk 		"Dusk"offset:[-38,-20]
		slider spn_time 	ticks:0 range:[0,180,-20]  orient:#horizontal width:220 across:1
		label labE			"East" offset:[-20,0] across:5
		label labN			"N" offset:[-30,0]
		label labW 			"West" offset:[-34,0]
		label labS			"S" offset:[-40,0]
		label labEE 		"East" offset:[-55,0]
		slider spn_polars 		ticks:0 range:[0,360,0]  width:220 orient:#horizontal
-- 		checkbox cb_exposure "Exposure" checked:true offset:[20,0]
		
		spinner sp_ShutterS "Darken" range:[1,4000,160] type:#integer offset:[-20,0] width:110 across:5
		label lab1 			"Contrast"offset:[30,3]
		button btn_contrastAdd "+" offset:[10,0] 	tooltip:"Make scene more contrasty"
		button btn_contrastSub "-" offset:[-20,0] 	tooltip:"Make scene less contrasty"
		button btn_contrastNorm"Reset Contrast"offset:[-10,0] 			tooltip:"Set Contrast to 1.3"
		
		
		on btn_RenderWindow pressed do 
		(			
			
			fn renderPreview = 
			(
				if WBCamera == true then 
				(
					cam = Set_Vray_Camera ()
				)	
				
				Fix_Light_Layer() --makes sure the ligths layer is on
				
				theBmp = render outputsize:[300,225] vfb:on
				
				theMask = bitmap 16 16 color: black
				btn_RenderWindow.images = #(theBmp, theMask, 1,1,1,1,1 )
				
				if WBCamera == true then 
				(
					delete cam
				)	
			)

			oSel = selection as array
			if lights.count  == 0 then
			(
				q_answer = queryBox "No Lights in the scene! \n Do you still want to preview your render?" beep:false
				
				if  q_answer == true then 
				(
					print ("Still rendering even with no lights")
					renderPreview()
				)
				else(	print "Not Rendering scene")
			)
			else
			(	
				try ( blurManage.cleanFile() ) catch(print "You need to install Blur's tool set")
				renderPreview() 
			)
			for i in oSel do(selectmore i)
		)
		on spn_time changed val do
		(
			if timeNode != undefined then
			(
				timeNode.rotation.x_rotation = val
			)
		)
		on spn_polars changed val do
		(
			if timeNode != undefined then
			(
				timeNode.rotation.z_rotation = val
			)
		)
		
		on btn_contrastAdd pressed do
		(
			local vr=renderers.current
			if (classof vr == V_Ray_Adv_1_50_SP6) then 
			(
				DM = vr.colorMapping_darkMult
				BM = vr.colorMapping_brightMult
				vr.colorMapping_darkMult = DM - renContrast
				vr.colorMapping_brightMult = BM + renContrast
			)
		)  
		on btn_contrastSub pressed do
		(
			local vr=renderers.current
			if (classof vr == V_Ray_Adv_1_50_SP6) then 
			(
				DM = vr.colorMapping_darkMult
				BM = vr.colorMapping_brightMult
				vr.colorMapping_darkMult = DM + renContrast
				vr.colorMapping_brightMult = BM - renContrast
			)
		)		
		on btn_contrastNorm pressed do
		(
			local vr=renderers.current
			if (classof vr == V_Ray_Adv_1_50_SP6) then 
			(
				vr.colorMapping_darkMult = 1.3
				vr.colorMapping_brightMult = 1.3
			)
		)
	)
	
	rollout sBakePrep "Bake Tools"
	(
		checkbutton bPrepScene ".:: ENTER BAKING MODE ::." width:270 height:24 toolTip:"Prepares scene for baking. Creates materials base on current render." 
		group "Bake Maps"
		(
			checkbox cbPasses "Passes LM" across:3 offset:[3,0]
			checkbox cbAO "Ambient Occlusion" offset:[-10,0]
			checkbox cbDIR "Directional LM" offset:[10,0]
			dropdownlist ddBakeType items:#("", "LM1", "LM2", "LM3") across:2 width:(200) enabled:false
			button bBakeSel "Bake" tooltip:"Bake selected Objects"width:(80) offset:[35,0] enabled:false
		)
		group "File Management "
		(
			button bOpenLM1_ "Open LM1" width:(270/4)offset:[0, 0]across:4 tooltip: "Opens an existing LM1 Lightmap" 
			button bOpenLM2_ "Open LM2" width:(270/4)offset:[0, 0] tooltip: " Opens an existing LM2 Lightmap"
			button bOpenLM3_ "Open LM3" width:(270/4)offset:[0, 0] tooltip: " Opens an existing LM3 Lightmap"
			button bOpenImageDir "Open LM Dir" width:(270/4)offset:[3, 0]  tooltip: "Open the location of the temp lightmaps"
		) 
		
		on cbPasses changed state do
		(
			cbAO.state 		= false
			cbDIR.state 		= false
		)
		on cbAO changed state do
		(
			cbPasses.state 	= false
			cbDIR.state 		= false
		)
		on cbDIR changed state do
		(
			cbPasses.state 	= false
			cbAO.state 		= false
		)
--BAKE MODE
		on bPrepScene changed state do  
		(
			if bPrepScene.state  == true then
			(
				print ("Preparing scene for rendering ")
				global SceneLayerVisibility 	= Get_Layer_Visibility ()
				Prepare_Scene() 
				bPrepScene.text = ".:: EXIT BAKING MODE ::."
				sBakePrep.ddBakeType.enabled = true
				sBakePrep.bBakeSel.enabled = true

			)
			if bPrepScene.state  != true then
			(
				Set_Layer_Visibility SceneLayerVisibility[1] SceneLayerVisibility[2] 
				format "Hiding Bake Layer\n"
				oLayer = LayerManager.getLayerFromName "Bake_Mesh"
				oLayer.ishidden = true
				bPrepScene.text = ".:: ENTER BAKING MODE ::."
				sBakePrep.ddBakeType.enabled = false
				sBakePrep.bBakeSel.enabled = false
				
				if deleteBakeMeshes == true then
				(
					Delete_Bake_Layer_Objects ()
				)
			)

		)
--BAKING SECTION
		on bBakeSel pressed do 
		(
			if networkRender == false then
			(
				if ddBakeType.selection == 1 then	( Messagebox ("Nothing selected") )
				if ddBakeType.selection == 2 then
				(
					if cbPasses.state == true then 	( passImgs = Bake_Object_Passes Bake_Path $LM1_ )
					if  cbAO.state == true then 		( AOImg = Bake_Object_AO Bake_Path $LM1_ )
					if  cbDIR.state == true then 		( DLMImgs = Bake_Directional_Maps Bake_Path $LM1_ )
					if cbPasses.state != true and cbAO.state != true and cbDIR.state != true  then 
					(
						LM1_Comp =Bake_Object Bake_Path $LM1_
					)
				)
				if ddBakeType.selection == 3 then
				(
					if cbPasses.state == true then	( passImgs = Bake_Object_Passes Bake_Path $LM2_ )
					if  cbAO.state == true then 		( AOImg = Bake_Object_AO Bake_Path $LM2_ )
					if  cbDIR.state == true then 		( DLMImgs = Bake_Directional_Maps Bake_Path $LM2_ )
					if cbPasses.state != true and cbAO.state != true and cbDIR.state != true  then 
					(
						new_LM1 =Bake_Object Bake_Path $LM2_
					)
				)
				if ddBakeType.selection == 4 then
				(
					if cbPasses.state == true then 	( passImgs = Bake_Object_Passes Bake_Path $LM3_ )
					if  cbAO.state == true	then 		( AOImg = Bake_Object_AO Bake_Path $LM3_ )
					if  cbDIR.state == true then 		( DLMImgs = Bake_Directional_Maps Bake_Path $LM3_ )
					if cbPasses.state != true and cbAO.state != true and cbDIR.state != true  then 
					(
						new_LM1 =Bake_Object Bake_Path $LM3_
					)
				)
			)
--NETWORK BAKE SECTION
			if networkRender == true then
			(
				if ddBakeType.selection == 2 then
				(
					if cbPasses.state == true then 	( passImgs = Net_Bake_Object_Passes oNetPath $LM1_ )
					if  cbAO.state == true then			( AOImg = Net_Bake_AO oNetPath $LM1_ )
					if  cbDIR.state == true then		( DMImgs = Net_Bake_Directional_Maps oNetPath $LM1_ )
					if cbPasses.state != true and cbAO.state != true and cbDIR.state != true  then 
					(
						compImg = Net_Bake_Object oNetPath $LM1_
					)
				)
				if ddBakeType.selection == 3 then
				(
					if cbPasses.state == true then	( passImgs = Net_Bake_Object_Passes oNetPath $LM2_ )
					if  cbAO.state == true then 		( AOImg = Net_Bake_AO oNetPath $LM2_ )
					if  cbDIR.state == true then		( Net_Bake_Directional_Maps oNetPath $LM2_ )
					if cbPasses.state != true and cbAO.state != true and cbDIR.state != true  then 
					(
						compMap = Net_Bake_Object oNetPath $LM2_
					)
				)
				if ddBakeType.selection == 4 then
				(
					if cbPasses.state == true then 	( passImgs = Net_Bake_Object_Passes oNetPath $LM3_ )
					if  cbAO.state == true then 		( AOImg = Net_Bake_AO oNetPath $LM3_ )
					if  cbDIR.state == true then 		( Net_Bake_Directional_Maps oNetPath $LM3_ )
					if cbPasses.state != true and cbAO.state != true and cbDIR.state != true  then 
					(
						compMap = Net_Bake_Object oNetPath $LM3_
					)
				)
			)
		)
		on bOpenLM1_ pressed do (Open_Image Bake_Path "LM1_"	)
		on bOpenLM2_ pressed do (Open_Image Bake_Path "LM2_"	)
		on bOpenLM3_ pressed do (Open_Image Bake_Path "LM3_"	)		
		
		on bOpenImageDir pressed do 
		(
			if networkRender == true then
			(
				tokens = filterstring maxFilePath "\\"
				targetDir = oNetPath + tokens[tokens.count] 
				shellLaunch targetDir ""
			)
			else
			(
			print ("Opening Lightmap Directory")
			shellLaunch (Set_Bake_Path () ) ""
			)
		)
	)
--MAIN DIALOG
	rollout bakeDLG "Lightmap Tool"
	(
		SubRollout SubRO width:320 height:610 align:#center
		on bakeDLG open do
		(
			Bake_Path = Set_Bake_Path ()
-- 			print Bake_Path
			global SceneLayerVisibility = Get_Layer_Visibility ()

			for i=1 to renPresets.count do ( append presetArrName (getFilenameFile(renPresets[i])) )
 			Set_Bake_Layer ()
		)
		
		on bakeDLG moved pos do
		(
			LM_Coords = GetDialogPos bakeDLG
		)
		on bakeDLG close do
		(
			--SET THE ININ SETTINGS FOR THE TOOL
			setINISetting ini_file "LightMap_Tool"  "LM_Coords" 				(LM_Coords as string)
			setINISetting ini_file "LightMap_Tool"  "Network_Path" 			( sSettings.txtaddress.text as string)
			setINISetting ini_file "LightMap_Tool"  "Texture_Size"  			(sSettings.sSize.selection as string)
			setINISetting ini_file "LightMap_Tool"  "UV_Channel"  			(sSettings.sChannel.Value as string)
			setINISetting ini_file "LightMap_Tool"  "Bake_Dialation"  		(sSettings.sDilations.Value as string)
			setINISetting ini_file "LightMap_Tool"  "Use_WB_Camera"  	(sSettings.cCamera.state as string) 
			setINISetting ini_file "LightMap_Tool"  "Use_Network"  			(sSettings.cNetRen.state as string) 
			setINISetting ini_file "LightMap_Tool"  "Delete_Bake_Mesh"	(sSettings.cDelBakeM.state as string) 

			if sSettings.open == true then (setINISetting ini_file "LightMap_Tool"  "RO_Settings"  "false")
			else ( setINISetting ini_file "LightMap_Tool"  "RO_Settings"  "true")
			
			if sRenPrev.open == true then (setINISetting ini_file "LightMap_Tool"  "RO_Render_Preview"  "false"	)
			else ( setINISetting ini_file "LightMap_Tool"  "RO_Render_Preview"  "true")
			
			if sBakePrep.open == true then	(setINISetting ini_file "LightMap_Tool"  "RO_Bake_Prep"  "false")
			else ( setINISetting ini_file "LightMap_Tool"  "RO_Bake_Prep"  "true")
			
			if sBakePrep.open == true then	(setINISetting ini_file "LightMap_Tool"  "RO_Bake_Tools"  "false")
			else ( setINISetting ini_file "LightMap_Tool"  "RO_Bake_Tools"  "true")
		)			
	)
		
	on execute do
	(
		if maxFilePath != "" then 
		(	
			createDialog bakeDLG width:320 height:610 style:#(#style_sysmenu,#style_titlebar,#style_minimizebox,#style_resizing) 
			SetDialogPos  bakeDLG LM_Coords
			
			AddSubRollout bakeDLG.SubRO HelpMe rolledUp: true
			AddSubRollout bakeDLG.SubRO sSettings rolledUp: RO_Settings--true
			AddSubRollout bakeDLG.SubRO sRenPrev rolledUp:RO_Render_Preview--true	
			AddSubRollout bakeDLG.SubRO sBakePrep rolledUp:RO_Bake_Prep-- false
			global LMDiag = bakeDLG.SubRO.sBakePrep
			global LMDRender = bakeDLG.SubRO.sRenPrev
			tex_Size = sSettings.sSize.items[sSettings.sSize.selection]
			print "Started the Lightmap tool"
		)
		if maxFilePath == "" then(Messagebox "Open a saved Scene ")
	)

)
gc light()