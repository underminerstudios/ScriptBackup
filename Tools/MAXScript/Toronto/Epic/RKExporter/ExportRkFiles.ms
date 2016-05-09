(
	Clearlistener ()
	GC ()
		-----------------------------------------------------------------------------------------------------------------
	Local fileName = "" 
	local  filePath = ""
	local  AnimStartFrame = 0
	local  AnimEndFrame = 1
	local SavePath = ""
	local sceneName = ""
	
	fn getBoneFromSkin SkinMod boneID=
	(
		local boneArray=for o in objects where (refs.dependencyLoopTest SkinMod o) collect o
		local boneName=(skinOps.GetBoneName SkinMod boneID 1)
		local notFound=true
		local i=0
		while notFound and i<boneArray.count do
		(
			i+=1
			if boneArray[i].name==boneName then notFound=false
		)
		if notFound then undefined else boneArray[i]
	)
	
	-- use a callback to press the buttons
	-- I found this here: http://forums.cgsociety.org/showthread.php?t=485300
	fn LSW_EnvelopeCallbackFunction =
	(
		WindowHandle = DialogMonitorOPS.GetWindowHandle()
		theDialogName = UIAccessor.GetWindowText WindowHandle

		if theDialogName != undefined and matchpattern theDialogName pattern:"*Load Envelopes*" do
			UIAccessor.PressButtonByName WindowHandle "Match by Name"	
			
		if theDialogName != undefined and matchpattern theDialogName pattern:"*Load Envelopes*" do
			UIAccessor.PressButtonByName WindowHandle "OK"

		true
	)

	fn resetSkin Obj = 
	(
		if getCommandPanelTaskMode() != #modify then ( max modify mode)
		currAnimRangeStart = animationrange.Start 
		if (animationRange.start > 0 ) then (animationRange = interval 0 animationRange.end)
		if (sliderTime != 0 ) then (sliderTime = 0)
		theskin = Obj.modifiers[#skin]
		if (theskin != undefined) and (isvalidNode Obj) then
		(
			Select obj
			modpanel.setCurrentObject  theSkin
			NumBones = SkinOps.GetNumberBones theSkin
			if (numbones > 0 ) then 
			(
				local BoneList = #()
				for b = 1 to Numbones do
				 (
					currBone = getBoneFromSkin theSkin b
					append BoneList Currbone 
				 )
				--save Skin Envelope				
				 
				SkinFilepath = (maxfilepath  + obj.name  + "Skin.env")
				 if (doesFileExist SkinFilePath) then (deleteFile SkinFilePath)
				theSkin.bone_Limit = 3
				SkinOps.saveEnvelope theSkin SkinFilePath
				CollapseStack Obj
				newSkin = Skin ()								
				addmodifier Obj newSkin 
				select Obj
				modPanel.setCurrentObject newSkin
				--add new bones to new skin
				for i = 1 to (BoneList.count - 1 )do 
				(
				SkinOps.addbone newSkin BoneList[i] 0
				)
				SkinOps.addbone newSkin BoneList[BoneList.count] 1
				--LoadEnvelope Skin Envelope
				DialogMonitorOPS.RegisterNotification LSW_EnvelopeCallbackFunction ID:#GLSkin_Envelopes
				DialogMonitorOPS.Enabled = true
				completeRedraw()
				skinOps.loadEnvelope theSkin SkinFilePath
				
				DialogMonitorOPS.Enabled = false
				DialogMonitorOPS.UnRegisterNotification ID:#GLSkin_Envelopes
				
					--reset skin Modifier
				newskin.always_deform = false
				--newskin.enabled=true
				newskin.always_deform = true
				newskin.bone_Limit = 3
				
				--if (doesFileExist SkinFilePath) then (deleteFile SkinFilePath)
				AnimationRange.Start = currAnimRangeStart
				SliderTime = currAnimRangeStart
			)
		)
	)
	
	
	fn compareTimeFN v1 v2 = 
	(
		local d = (v1.time)-(v2.time)
		case of
		(
		(d < 0.): -1
		(d > 0.): 1
		default: 0
		)
	)		
	
	fn getMinMaxAnimationRange objController = 
	(
		local KeyArr = #()
		for i = 1 to objController.numsubs do 
		(
			if (objController[i].numsubs > 0 ) then 
			(
				KeyArr += getMinMaxAnimationRange objController[i]
			)
			else
			(
			if (objController[i].keys != undefined) and (objController[i].keys.count > 0 ) then  
				(
					KeyArr +=  objController[i].keys
				)
			)
		)
		return KeyArr
	)
	
	fn setMatNameToDiffuseMapName mat = 
	(
		case (Classof mat) of 
		(
		Standard: 
		(
			if (mat.diffusemap != undefined) and (doesFileExist mat.diffuseMap.filename) then (mat.name = (getFilenameFile mat.diffuseMap.filename))
		)
		Multimaterial: 
		(
			subMatList  = mat.MaterialList
			for i = 1 to subMatList.count do 
			(
				if (subMatList[i].diffusemap != undefined) and (doesFileExist subMatList[i].diffuseMap.filename) then (subMatList[i].name = (getFilenameFile subMatList[i].diffuseMap.filename))
			)
			if ( subMatList.count >  0 ) then ( mat.name= subMatList[1].name )
		)
		default: MessageBox "Error Re-Naming Material"
		)
	)
	
	fn ExportFbxToRkFile = 
	(
		savepath = getSaveFileName Filename:  (maxfilePath +(getfilenamefile maxfilename)) Caption:"Export Path" types:"RK (*.rk)|*.rk|All|*.*|"
		if (savepath != undefined) and ( doesfileexist (getfilenamePath savepath)) then 
		(
			format "%\n" "Exporting Fbx to Rk"
			ExClasses = ExporterPlugin.Classes 
			--for i = 1 to exclasses.count do (format "%\n" exclasses[i])

			if ((getFilenameType  savePath) != ".rk") then (savepath += ".rk")
			for RkExClass  in ExClasses do 
			(
				if (RkExClass == RKModel_Exporter ) then 
				(
					exportFile SavePath selectedonly: false using:RKExClass														
				)
			)
		)
	)
	
	fn PreRKexportsettings = 
	(
		format "%\n" "Initializing RK export Settings."
		objs = for geo in geometry where ((classof geo) != BoneGeometry ) collect geo
		
		for obj in objs do 
		(
			setMatNameToDiffuseMapName obj.material
			if getCommandPanelTaskMode() != #modify then ( max modify mode)
			
				if (obj.modifiers[#skin] != undefined) then 
				(
					resetSkin obj
				)
			
			for i = 1 to objs.count do 
			(

				if (obj != objs[i]) then 
				(
					if (obj.name == objs[i].name) then (obj.name = obj.name + "_duplicate")
				)
			)
		)
		AnimationRange = Interval AnimStartFrame AnimEndFrame
	)
		
	fn ImportFbxFile mFBXPath =
	(
		format "%\n" "Importing FBX file"
		imClasses = ImporterPlugin.Classes 
		
		for fbxImClass  in imClasses do 
		(
			if( fbxImClass == FBXIMP) then 
			(
				resetMaxFile #noPrompt
				FBXImporterSetParam "Cameras" false
				FBXImporterSetParam "Skin" true
				FBXImporterSetParam "SkinModifier" true
				FBXImporterSetParam "Cameras" false
				FBXImporterSetParam "Lights" false
				FBXImporterSetParam "Markers" false
				FBXImporterSetParam "Shape" false
				FBXImporterSetParam "Animations" true
				FBXImporterSetParam "FilterKeyReducer" false
				FBXImporterSetParam "filterUnroll" false
				FBXImporterSetParam  "FilterKeySync" false
				FBXImporterSetParam  "HumanIK" false
				FBXImporterSetParam  "AxisConversion" true
				FbxImporterSetParam "ImportBoneAsDummy" false
				importFile mFBXPath #noprompt using: fbxImClass
			)
		)			
		if (doesfileExist mFbxPath)  then 
		(
			PreRKexportsettings()
			print mFBXPath as string
			if ((doesfileexist mFBXpath) != true ) then (print "Error Exporting FBX file" as string)
		)
		else(Print  "Error Importing FBX file" as string)
		
	)
	
	Fn ExportToFBX FBXassets =
	(
		format "%\n" "Exporting FBX file."
		-- Exports selected 
		FBXExporterSetParam "Cameras" false
		FBXExporterSetParam "FilterKeyReducer" false
		FBXExporterSetParam "Lights" false
		FBXExporterSetParam "PointCache" false
		FBXExporterSetParam "ShowWarnings" false
		FBXExporterSetParam "Animation" true
		FBXExporterSetParam "BakeAnimation" true
		FBXExporterSetParam "Skin" true
		FbxExporterSetParam"GeomAsBone" true
		FbxExporterSetParam "EmbedTextures" false
		FbxPath = (FilePath + FileName + "Anim.fbx" ) 			
		if( doesfileExist Fbxpath ) then 	(deletefile Fbxpath) -- delete old
		exClasses = exporterPlugin.Classes
		for i = 1 to exClasses.count do 
		(
			if (exClasses[i] == FBXEXP ) then 
			(							
			exportFile FbxPath #noprompt selectedonly: true using:exClasses[i]  --export new
			)
		)
		--if exported correclty then continue
		if( doesfileExist Fbxpath ) then 
			(
				resetMaxFile #noPrompt 
				ImportFbxFile FbxPath
			)
			else ( print "FBX did not Export correctly" as string )
	)
		
	Fn exportassets exportnodes = 
	(
		--set Timeline to min and Max according to Obj.Controllers
		for obj in exportnodes do 
		 (
			 --set timeline to full aniamtion range of scene
			 
			 minMaxKeys = getMinMaxAnimationRange obj[3].controller  --object transform Index is 3
			qsort minMaxKeys compareTimeFN
			if (minMaxKeys.count > 0 ) then 
			 (
				if (minMaxKeys[1].time < AnimationRange.Start) then (AnimationRange.start = minMaxKeys[1].time)
				if (minMaxKeys[minMaxKeys.count].time > AnimationRange.end) then (AnimationRange.end = minMaxKeys[minMaxKeys.count].time)
				AnimStartFrame = animationRange.Start
				AnimEndFrame = animationRange.End
				print "Timeline Set" as string
			 )
		 )
		 Print "Timeline Min and Max Set" as string
		newFbxPath = ExportToFBX exportnodes 
		 
		 --if (doesfileexist Fbxpath) then deleteFile FbxPath 
		 
	)
		
	FileName = getFilenameFile  maxfilename
	if (fileName != "") then 
	(
		FilePath = maxfilepath 
		isSaved = checkForSave()
		if isSaved then 
		(				
			if ( maxfilepath != undefined) then 
			(
			filePath = getfilenamePath savepath
			fileName = tolower (getfilenamefile savepath)
			sceneName = (maxfilePath + maxfileName) 
				
			filePath = maxfilePath
			fileName = tolower (getfilenamefile maxfileName)
			
				holdMaxfile ()
				with redraw off 
				(
					Sel = #()
					if (selection.count < 1 ) then (Select  objects)
					Sel = Selection as array
					(
					--if a cat rig, set animation layer to active, so aniamtion exports
						for obj in Sel do 
						(
							 if ((classof obj) == hubObject) or ((classof obj) == CatBone ) then 
							 (
							 if (obj.TMcontroller.CATparent.CATMode != 1 ) then (obj.TMcontroller.CATparent.CATMode  = 1 )
							 )
						)
					exportassets Sel 
					)
				)
				redrawViews ()				
				--ClearListener ()
				MessageBox "File FBX Ready for RK export"
				--ExportFbxToRkFile ()
				/*
				if  (querybox "Do you want to load orginal file?" beep: false) then 
				(
					loadmaxFile sceneName useFileUnits: true quiet: true
				)
				else
				(
				MessageBox "Export Successful."
				)
				*/
			)
			else
			(
				MessageBox "You must choose a valid export file path before proceeding.\n"
				destroyDialog MasterRollout
			)
		)
		else
		(
			MessageBox "You must save the Current File before proceeding with export.\n"
			destroyDialog MasterRollout
		)
	
	)
	else
	(
		MessageBox "your file name is undefined"
	)
)