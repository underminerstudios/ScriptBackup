/*
	Sprite Renderer
	
	This script will render sprite for the Gangstar City Project
	It will loop through the layers and find layers that have renderable objects. It will then render them separatly through the whole active animation range.

	- The user will be able to select the angles he wants to render.
	- The user has to define an animation name.
	- The max scene must contain materials named "characters_render" and "characters_alpha"
	- The "characters_alpha" material is applied to all the other objects in order to "hide" them from the render. This way they will still cast shadows.
	- The files will be saved to the output path folder with the following name:
		objectName_AnimationName_Angle_Frame.png
*/
--by Norman Schaar norman.schaar@gameloft.com



try(destroyDialog Gangstar_sprite_render)catch()
rollout Gangstar_sprite_render "Sprite Renderer"
(
	edittext et_animationname "Animation Name:" labelOnTop:true
	multilistbox mlb_angles "Angles:" items:#("Down","Up","Left","Right","DownLeft","DownRight","UpLeft","UpRight") height:8
	edittext et_outputpath "Output Path:" labelOnTop:true readonly:true
	button btn_render "Render" width:140

	on Gangstar_sprite_render open do
	(
		et_outputpath.text = (pathConfig.removePathLeaf rendOutputFilename)		
	)
	
	fn GetAngleController =
	(
		for n in objects do
		(
			if n.name == "Camera_angle_controller" do	(return n)
		)
		return false
	)
	
	fn GetCamera =
	(
		for c in cameras do
		(
			return c
		)
		return false
	)

	fn HideAllLayers =
	(
		for i=0 to LayerManager.count-1 do
		(
			local theLayer = LayerManager.getlayer i
			theLayer.on = false
		)
	)

	fn ShowLayer Index =
	(
		local theLayer = LayerManager.getlayer Index
		theLayer.on = true
	)

	fn findLayersWthObjectsToRender =
	(
		local theReturnArray = #()
		
		for i=0 to LayerManager.count-1 do
		(
			local theLayer = LayerManager.getlayer i
			if theLayer.on == true AND theLayer.name != "biped" AND theLayer.name != "renderer" do
			(
				appendifunique theReturnArray i
			)
		)
		return theReturnArray
	)

	fn GetLayerVisibility =
	(
		local theVisibilityArray = #()
		for i=0 to LayerManager.count-1 do
		(
			local theLayer = LayerManager.getlayer i
			append theVisibilityArray (theLayer.on)
		)
		return theVisibilityArray
	)

	fn GetCharactersRender =
	(
		for i=1 to 24 do
		(
			if meditMaterials[i].name == "characters_render" do
			(
				return meditMaterials[i]
			)
		) 
		return false
	)

	fn GetCharactersAlpha =
	(
		for i=1 to 24 do
		(
			if meditMaterials[i].name == "characters_alpha" do
			(
				return meditMaterials[i]
			)
		) 
		return false
	)
	

	on btn_render pressed do
	(
		--PNG settings
		pngio.setType #paletted
		pngio.setAlpha false
		
		--Create Output Path
		local CreatePath = makeDir ((pathConfig.removePathLeaf rendOutputFilename) + "\\")
		
		--TheCharacterMaterial
		local TheCharacterMaterial = GetCharactersRender()
		
		--TheAlphaMaterial
		local TheAlphaMaterial = GetCharactersAlpha()
		
		--Get the Layers that need to be rendered
		local TheLayers = findLayersWthObjectsToRender()
		
		--The Angle Controller
		local AngleController = GetAngleController()
		
		--Store Values
		local QuietModeState = GetQuietMode()
		local CurrentSliderTime = slidertime
		local theLayersVisibility = GetLayerVisibility()
		local AngleControllerRotation = AngleController.rotation
		
		if CreatePath != false OR TheCharacterMaterial != false OR TheAlphaMaterial != false OR TheLayers.count != 0 OR et_animationname.text == "" OR AngleController != false then
		(
			--Close Render Dialog
			renderSceneDialog.close()
			
			--Set active viewport to camera
			viewport.setType #view_camera
			
			--Set Quiet Mode to avoid render errors
			SetQuietMode true

			--Loop through the selected angles
			for n in mlb_angles.selection do
			(
				--Get the Angle Name
				local theAngle =  mlb_angles.items[n]
				
				--Move the Camera dummy according to the angle
				if theAngle == "Down" do
				(
					AngleController.rotation = (quat 0 0 0 1)
				)
				if theAngle == "Up" do
				(
					AngleController.rotation = (quat 0 0 -1 -1.62921e-007)
				)
				if theAngle == "Left" do
				(
					AngleController.rotation = (quat 0 0 0.707107 0.707107)
				)
				if theAngle == "Right" do
				(
					AngleController.rotation = (quat 0 0 -0.707107 0.707107)
				)
				if theAngle == "DownLeft" do
				(
					AngleController.rotation = (quat 0 0 0.382683 0.92388)
				)
				if theAngle == "DownRight" do
				(
					AngleController.rotation = (quat 0 0 -0.382683 0.92388)
				)
				if theAngle == "UpLeft" do
				(
					AngleController.rotation = (quat 0 0 -0.923879 -0.382684)
				)
				if theAngle == "UpRight" do
				(
					AngleController.rotation = (quat 0 0 -0.92388 0.382683)
				)
				
				
				--Loop through the layers and render
				for m in theLayers do
				(
					--First hide all the layers
					HideAllLayers()
					--Show only the layer we are currently looping through
					ShowLayer m
					
					--Get the Nodes of this layer
					local thenodes
					local theLayer = LayerManager.getlayer m
					theLayer.nodes &thenodes
					
					--Loop through the nodes and render...
					for k in thenodes do
					(
						--Apply alpha material to all the nodes in the layer
						for j in thenodes do (j.material = TheAlphaMaterial)
							
					
						if k.isHidden == false do
						(
							--Apply default material to the node we are currently looping through
							k.material = TheCharacterMaterial
							--Loop through the animationRange
							for i=animationRange.start to animationRange.end do
							(
								--Set Slidertime
								slidertime = i
								--TheName
								local theName = k.name
								--The CurrentTimeFrame
								local CurrentTimeFrame = substitutestring (CurrentTime as string) "f" ""
								if (CurrentTimeFrame as integer) < 10 do
								(
									CurrentTimeFrame = "0" + CurrentTimeFrame
								)
								--The outputFile
								local thePath = (substitutestring (pathConfig.removePathLeaf rendOutputFilename) "\\" "\\\\") + "\\" + theLayer.name + et_animationname.text + theAngle + "_" + CurrentTimeFrame + "_" + theName + ".png"
								deleteFile thePath
								--Render!
								render (GetCamera()) outputFile:(thePath) vfb:off
							)
						)
					)
				)
			)
			--Restore all the values
			SetQuietMode QuietModeState
			slidertime = CurrentSliderTime
			
			--Set the Default materials
			for m in theLayers do
			(
				local thenodes
				local theLayer = LayerManager.getlayer m
				theLayer.nodes &thenodes
				for k in thenodes do
				(
					k.material = TheCharacterMaterial
				)
			)
			
			--Restore visibility
			for i=0 to LayerManager.count-1 do
			(
				local theLayer = LayerManager.getlayer i
				theLayer.on = theLayersVisibility[i+1]
			)
			
			--Restore Angle Controller rotation
			AngleController.rotation = AngleControllerRotation
		)
		else
		(
			if CreatePath == false do
			(
				messagebox "Unable to create output path"
			)
			if TheCharacterMaterial == false do
			(
				messagebox "Unable to find characterMaterial"
			)
			if TheAlphaMaterial == false do
			(
				messagebox "Unable to find the alphaMaterial"
			)
			if theLayers.count == 0 do
			(
				messagebox "Unable to find any layers with objects ready to render"
			)
			if et_animationname.text = "" do
			(
				messagebox "You need to specify an animation name"
			)
			if AngleController == false do
			(
				messagebox "The Camera Angle Dummy was not found in the scene"
			)
		)
	)
)
createDialog Gangstar_sprite_render