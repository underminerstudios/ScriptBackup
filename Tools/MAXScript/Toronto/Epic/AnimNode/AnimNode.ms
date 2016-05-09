(
	clearListener()
	local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	
	libDir = (DEPOT_PATH + "MAXScript\\Toronto\\_MAXScriptFunctions\\LibGLSpriteTools\\LibGLSpriteTools.ms")
	fileIn libDir
	
	try(glSpriteTool2.init)catch(messageBox "The Sprite Tools were not found.")
	try(DestroyDialog animNodeObjAttributes) catch()

	/*VARIABLE*/
	nodeObjStatusColour = [255,0,0]
	myNode = undefined
	areAnimating = false

	animationUIoffset = 175

	nodeName = #("")
	animName = #("")
	startFrame = #("")
	endFrame = #("")
	nthFrame = #("")
	animObjs = #()


	rollout animNodeObjAttributes "Static Object Tool" width:410 height:550
	(
		progressBar nodeObjStatusDisplay "ProgressBar" pos:[5,10] width:391 height:10 value:100 color:nodeObjStatusColour
		
		button makeNodeObj "Make Animation Node Object" pos:[5,28] width:160 height:30
		button updateNodeAttributes "U" pos:[167,28] width:30 height:30
		
		--dropdownlist selectObjCatagory "Sprite Catagory:" width:180 items:glSpriteTool.catagories visable:false
		
		checkbox nodeObjRenderEnabled "Render Enabled" pos:[5,110] 
		checkbox nodeObjAnimationEnabled "Animation Enabled" pos:[5,130]
		
		groupBox grp5 "" pos:[200,20] width:1 height:505				-- Center Line
		
		button addSelectedObj "Add Selected Objects" pos:[205,28] width:190 height:30
		
		button selectAnimObjects "select all 'Objects to Render'" pos:[205,63] width:190 height:30
		
		label lbl1 "Objects to Render:" pos:[205,100]
		listbox animObjOutput  pos:[205,120] width:190 height:26 items:animObjs
			
		--
		-- Remove things buttons
		--
		button removeSelectedObj "Remove Selected Object" pos:[205,475] width:190 height:30
		button removeAllObj " Remove All Objects" pos:[205,510] width:190 height:30
		
		groupBox grp2 "Object Name" pos:[5,172] width:190 height:84
		listbox nodeObjNameOutput "" pos:[12,190] width:170 height:1 items:nodeName readOnly:true
		editText nodeObjNameInput "Enter Name:" pos:[12,210] width:170 height:17 labelOnTop:true bold:true
		
		checkbox useMSmatteShadow "Use Master Scenes Matte Shadow" pos:[5,150] 
		checkbox useOverRideSceneAA "Don't Use Scene AA settings" pos:[5,210] visible:false
		
		/***** Animation stuff *****/
		
		groupBox grp1 "Animation Name" pos:[5,(90 + animationUIoffset)] width:190 height:81 visible:areAnimating
		listbox animNameOutput "" pos:[12,(110 + animationUIoffset)] width:170 height:1 items:animName readOnly:true visible:areAnimating
		editText animNameInput "Enter Name:" pos:[12,(130 + animationUIoffset)] width:170 height:17 labelOnTop:true visible:areAnimating

		
		groupBox grp3 "Start Frame" pos:[5,(175 + animationUIoffset)] width:93 height:80 visible:areAnimating
		listbox startFrameOutput "" pos:[12,(189 + animationUIoffset)] width:80 height:1 items:startFrame readOnly:true visible:areAnimating
		editText startFrameInput "Enter frame:" pos:[12,(209 + animationUIoffset)] width:80 height:17 labelOnTop:true bold:true visible:areAnimating
			
		groupBox grp4 "End Frame" pos:[102,(175 + animationUIoffset)] width:93 height:80 visible:areAnimating
		listbox endFrameOutput "" pos:[109,(189 + animationUIoffset)] width:80 height:1 items:endFrame readOnly:true visible:areAnimating
		editText endFrameInput "Enter frame:" pos:[109,(209 + animationUIoffset)] width:80 height:17 labelOnTop:true bold:true visible:areAnimating
		
		groupBox grp6 "Render every Nth frame" pos:[5,(260 + animationUIoffset)] width:150 height:80 visible:areAnimating
		listbox nthFrameOutput "" pos:[12,(274 + animationUIoffset)] width:85 height:1 readOnly:true items:nthFrame visible:areAnimating
		editText nthFrameInput "Enter Frame"  pos:[12,(294 + animationUIoffset)] width:85 height:17 labelOnTop:true visible:areAnimating

		fn updateAnimRollout areAnimating =
		(	
			
			grp1.visible = areAnimating	
			animNameOutput.visible = areAnimating	
			animNameInput.visible = areAnimating	
			grp3.visible = areAnimating	
			startFrameOutput.visible = areAnimating	
			startFrameInput.visible = areAnimating	
			grp4.visible = areAnimating	
			endFrameOutput.visible = areAnimating	
			endFrameInput.visible = areAnimating	
			grp6.visible = areAnimating
			nthFrameOutput.visible = areAnimating
			nthFrameInput.visible = areAnimating
			
			if areAnimating then
			(
				animNodeObjAttributes.title = "Animated Object Tool"
			)
			else 
			(
				animNodeObjAttributes.title = "Static Object Tool"
			)
			
		)
		

		/************************/
		/***** CheckBox *****/
		/***********************/
		on nodeObjRenderEnabled changed theState do
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					$.renderEnabled = theState
				)
			)
		)
		
		on nodeObjAnimationEnabled changed theState do
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					$.isAnimating = theState
					updateAnimRollout ($.isAnimating)									
				)
			)
		)
		
		on useMSmatteShadow changed theState do
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					$.useMSmatteShadow = theState								
				)
			)
		)
		
		on useOverRideSceneAA changed theState do
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					$.overRideSceneAA = theState								
				)
			)
		)
		
		/*********************/
		/***** Buttons *****/
		/*********************/
		
		on makeNodeObj pressed do
		(
			
			--Makes a new node object with the objNodeAttributesCA added
			myNode = Dummy pos:[0,0,0]
			if selection.count == 1 then myNode.pos = $.pos			
			myNode.name = "_Node"
			scale myNode [20,20,20] -- scales the dummy node to 2 meters 
			custAttributes.add myNode animNodeAttributesCA		

			myNode.objNodeName = ""
			myNode.renderEnabled = true
			myNode.useMSmatteShadow = true
			myNode.overRideSceneAA = false		
			myNode.isAnimating = false		
			myNode.animationName = ""
			myNode.startFrame = 0
			myNode.endFrame = 0
			myNode.animObjects = #()	
			select myNode
		)
		
		on updateNodeAttributes pressed do 						-- Checks if the object has a Animation CA
		(														-- and fills the listboxes with them	
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					/***** checks if the animNodeAttributesCA is the latest version and updates it if not *****/
					try
					(
						if $.glstVersion < glSpriteTool.animUIVersion then
						(
							glSpriteTool.updateAnimNode $
						)
					)
					catch
					(
						glSpriteTool.updateAnimNode $
					)	
					
					myNode = $
					nodeName[1] = $.objNodeName as string
					nodeObjNameOutput.items = nodeName
									
					animName[1] = $.animationName as string
					animNameOutput.items = animName	
					
					startFrame[1] = $.startFrame as string				
					startFrameOutput.items = startFrame
					
					endFrame[1] = $.endFrame as string				
					endFrameOutput.items = endFrame
					
					nodeObjRenderEnabled.checked = $.renderEnabled
					nodeObjAnimationEnabled.checked = $.isAnimating
					
					useMSmatteShadow.checked = $.useMSmatteShadow
					
					useOverRideSceneAA.checked = $.overRideSceneAA
					
					nthFrame[1] = $.nthFrameRender as string
					nthFrameOutput.items = nthFrame
					
					tempArray = #()
					for o in $.animObjects do (append tempArray o)				
					animObjs = #()
					$.animObjects = #()
					for o = 1 to tempArray.count do 
					(
						if IsValidNode tempArray[o] then
						(
							append animObjs tempArray[o].name	
							append $.animObjects tempArray[o]	
						)					
					)
					
					
					animObjOutput.items = animObjs
					
					
					
					if $.isAnimating then			-- If the object is set to animated then check if it has a valid animation node
					(
						if (glSpriteTool.hasValidAnimNodeCA $) then
						(					
							nodeObjStatusColour = [0,255,0]
							nodeObjStatusDisplay.color = nodeObjStatusColour					
						)
						else													-- anything else and its back to red
						(
							nodeObjStatusColour = [255,0,0]
							nodeObjStatusDisplay.color = nodeObjStatusColour
						)
					)
					else							-- If its not animated check if it has a valid static node
					(1
						if (glSpriteTool.hasValidStaticNodeCA $) then
						(					
							nodeObjStatusColour = [0,255,0]
							nodeObjStatusDisplay.color = nodeObjStatusColour					
						)
						else													-- anything else and its back to red
						(
							nodeObjStatusColour = [255,0,0]
							nodeObjStatusDisplay.color = nodeObjStatusColour
						)
					)				

					updateAnimRollout ($.isAnimating)	
				)			
			)
			else
			(		-- If no object is selected then clear all the fields and turn the status colour red
				nodeName[1] = ""
				nodeObjNameOutput.items = nodeName
				--nodeObjNameInput.text = nodeName[1]
				animName[1] = ""
				animNameOutput.items = animName	
				startFrame[1] = ""
				startFrameOutput.items = startFrame
				endFrame[1] = ""
				endFrameOutput.items = endFrame
				nodeObjRenderEnabled.checked = false
				animObjs = #()
				animObjOutput.items = animObjs
				
				updateAnimRollout (false)
				
				nodeObjStatusColour = [255,0,0]
				nodeObjStatusDisplay.color = nodeObjStatusColour
			)
		)
		
		on addSelectedObj pressed do
		(
			if myNode != undefined then
			(
				if selection.count > 0 then
				(
					for i in selection do
					(
						if (superClassOf i == GeometryClass) or (superClassOf i == shape) or (superClassOf i == SpacewarpObject) then
						(
							print i
							appendIfUnique myNode.animObjects i
						)
					)
					animObjs = #()
					for o in myNode.animObjects do (append animObjs o.name)
					animObjOutput.items = animObjs	
				)
				
				select myNode
			)
		)
		
		on selectAnimObjects pressed do 
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					theObjects = $.animObjects as Array
					select theObjects
				)
			)
		)
		
		on removeAllObj pressed do 
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					$.animObjects = #()
					animObjs = #()
					animObjOutput.items = animObjs
				)
			)
		)
			
		
		
		/***** the selected object name in the list gets removed from the obj.animObjects *****/
		on removeSelectedObj pressed do
		(
			if selection.count == 1 then
			(
				if (glSpriteTool.hasAnimNodeCA $) then
				(
					if animObjOutput.selection > 0 then
					(
						deleteItem $.animObjects (animObjOutput.selection)
						animObjs = #()
						for o in $.animObjects do (append animObjs o.name)
						animObjOutput.items = animObjs				
					)	
				)
			)
		)
		
		/******************************/
		/***** Edit Text Fields *****/
		/******************************/
		
		on nodeObjNameInput entered txt do 
		(
			if txt != undefined do 
			(
				if selection.count == 1 then
				(
					if (glSpriteTool.hasAnimNodeCA $) then
					(
						$.objNodeName = txt
						nodeName[1] = $.objNodeName as string
						nodeObjNameOutput.items = nodeName
						nodeObjNameInput.text = ""
						--nodeObjNameInput.text = nodeName[1]
					)
				)
			)	
		)
		
		on animNameInput entered txt do 
		(
			if txt != undefined do 
			(
				if selection.count == 1 then
				(
					if (glSpriteTool.hasAnimNodeCA $) then
					(
						$.animationName = txt
						animName[1] = $.animationName as string
					animNameOutput.items = animName	
						animNameInput.text = ""
					)
				)
			)	
		)
		
		on startFrameInput entered txt do 
		(
			if txt != undefined do 
			(
				if selection.count == 1 then
				(
					if (glSpriteTool.hasAnimNodeCA $) then
					(
						startFrameNum = txt as integer
						if startFrameNum != undefined then
						(					
							$.startFrame = startFrameNum
							startFrame[1] = $.startFrame as string
							startFrameOutput.items = startFrame
							startFrameInput.text = ""
						)
					)
				)
			)	
		)
		
		on endFrameInput entered txt do 
		(
			if txt != undefined do 
			(
				if selection.count == 1 then
				(
					if (glSpriteTool.hasAnimNodeCA $) then
					(
						endFrameNum = txt as integer
						if endFrameNum != undefined then
						(					
							$.endFrame = endFrameNum
							endFrame[1] = $.endFrame as string
							endFrameOutput.items = endFrame
							endFrameInput.text = ""
						)
					)
				)
			)	
		)
		
		on nthFrameInput entered txt do 
		(
			if txt != undefined do 
			(
				if selection.count == 1 then
				(
					if (glSpriteTool.hasAnimNodeCA $) then
					(
						nthFrameNum = txt as integer
						if nthFrameNum != undefined then
						(					
							$.nthFrameRender = nthFrameNum
							nthFrame[1] = $.nthFrameRender as string
							nthFrameOutput.items = nthFrame 
							nthFrameInput.text = ""
						)
					)
				)
			)	
		)

	)
	CreateDialog animNodeObjAttributes
)