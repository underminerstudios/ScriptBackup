if ( ( preFabArr == undefined) == true) then 
( 
	global preFabArr
	preFabArr = #() 
)

global GL_Tools_Path 
global GL_Art_Path 

--creates shadow caster	
fn GenerateMapConfig =
(
	global exportFolder = getSavePath caption:"Select folder to export" initialDir:(if (exportFolder == undefined) then (getDir #maxroot) else exportFolder)		
	global mapcfg = maxFilePath + ( (Filterstring maxFileName ".")[1] ) + ".cfg"
	
	setINISetting mapcfg "GL_Export" "GL_Visual" (exportFolder + "\\Visual\\" + "GL_Visual" + ".bdae")
	setINISetting mapcfg "GL_Export" "GL_GameLayers" (exportFolder + "\\Visual\\")
	setINISetting mapcfg "GL_Export" "GL_MapPath" (exportFolder)


	setINISetting mapcfg "A9_MapInfo" "GL_MatLib" (maxFilePath + ( (Filterstring maxFileName ".")[1] ) + ".mat")
		lmpath = ""
		m = GL_Effect_Inst()
		if m != undefined then
		(
			for m in scenematerials do
			(
			if classof m != standardMaterial then
				(
					if classof m == Multimaterial then
					(
						for i in m.materialList do
						(
							if classof i != standardMaterial then
							(
								lmparam = i.params.GetEffectParamByName "LightMap"
								lmpath = lmparam.texturePath
							)
						)
					)
				)
			)
		)
	
	setINISetting mapcfg "A9_Lightmaps" "default_lightmap" (lmpath)
	setINISetting mapcfg "A9_Lightmaps" "road_lightmap" ("")
)

fn BatchGameData dType=
(
	mapcfg = maxFilePath + ( (Filterstring maxFileName ".")[1] ) + ".cfg"
	batchFolder = (getINISetting mapcfg "GL_Export" "GL_MapPath")
	mapFolder = filterstring batchFolder "\\"
	ReleasePath = ("T:\\projects\\win\\Release\\Asphalt9.exe")
	DebugPath = ("T:\\projects\\win\\Debug\\Asphalt9.exe")
	
	if (doesFileExist ReleasePath) == false and (doesFileExist DebugPath) then
	(
		MessageBox "Asphalt Project must be built for export!"
	) else
	(

			DOSCommand ("python T:\\scripts\\BatchStreamData.py -mname " + mapFolder[4] + " -mtype " + dType)
	)
)

			
fn Make_Shadow_Caster = 
(
	oObj = $
	oMod = modPanel.getCurrentObject() 
	-- 			print oMod
	if superclassof oMod != modifier then
	(
		selFace = polyop.getFaceSelection oObj
		oObjNewName = (uniqueName ("sc_" + oObj.Name) )
		polyop.detachFaces oObj selFace asNode:true name:oObjNewName
		subobjectLevel = 0
		newObj = select (getnodebyname oObjNewName)
		try(setUserProp newObj "#LightMap" "none")catch()
		maxops.pivotmode = #pivotonly
		CenterPivot $
		maxops.pivotmode = #none
	)

	oLayer = LayerManager.getLayerFromName "Bake_Mesh"
	if oLayer == undefined then
	(
		oLayer = LayerManager.newLayerFromName  "Bake_Mesh"
		oLayer.current =  true
		--oLayer.ishidden = true
	)
	--add the box node to layer
	oLayer.addnode $
)


fn Set_UserDefined_Props oStr=
(
	print ("Setting User Defined Lightmap to: " + oStr)
	local oSel = selection as array
	
	for zz = 1 to  oSel.count do
	(
		--print oSel[zz]
		if (getUserPropBuffer oSel[zz]).count == 0 then 
		(
			setUserProp oSel[zz] "#LightMap" oStr
		)
		if (getUserProp oSel[zz] "#LightMap") == undefined then 
		(
			oldUD = getUserPropBuffer oSel[zz]
			oldUD= oldUD + "\n#LightMap=" + oStr 
			setUserPropBuffer oSel[zz] oldUD 
		)
		else
		(
			setUserProp oSel[zz] "#LightMap" oStr
		)
	)
)

fn Hide_MC_Layers = 
(
	for i =  1 to LayerManager.count do 
		(
			oLayer = LayerManager.getLayer (i-1)
			oLayer.ishidden = true
		)			
)	
	
fn Set_SceneConf_Props oStr =
(
	print ("Setting User Defined Scene Confromer to: " + oStr)
	local oSel = selection as array
	
	for zz = 1 to  oSel.count do
	(
		print oSel[zz]
		if  (getUserProp oSel[zz] "#SceneConformer" == undefined ) then
		(
			setUserProp oSel[zz] "#SceneConformer" oStr
		)
		else
		(
			setUserProp oSel[zz] "#SceneConformer" oStr
		)
	)
)
	
fn Create_Prefab oStr =
(
	if selection.count > 1 then
	(
		local ParentTest = #()
		local GroupsToDestroy = #()
		local NewGroupArr = #()
		local ArraysToDelete = #()
		
		oSel = selection as array
		--filter out existing object out of the array so the script doesn't mix up
		for jj=1 to oSel.count do
		(
				--Clean up the main array based on what is selected in the scene
			for i = 1 to preFabArr.count do
			(
				oItem = finditem preFabArr[i] oSel[jj]
				if oItem != 0 then
				(
					deleteItem (preFabArr[i]) oItem
				)
			)
			if(isGroupHead oSel[jj] == true )then
			(
				append GroupsToDestroy oSel[jj]
			)
		)
		--search for empty group arrays and later delete them
		for i = 1 to preFabArr.count do
		(
			if preFabArr[i].count == 1 then
			(
				append ArraysToDelete i
			)
		)
		--delete that pesky array with a single entry.
		for oItem in ArraysToDelete do (	deleteItem preFabArr oItem )
		--explode groups that were taken out of the main array
		for grp in GroupsToDestroy do ( explodeGroup grp )
		
		--Done cleaning the array  now proceed to figuring out what is mixed parent or groupings
		--Get parenting mixture and if mixed set true
		local oSel = selection as array --so we don't stumble on any funky gone groups and break the script
		for zz =1 to oSel.count do
		(
			if ( (findItem ParentTest oSel[zz].parent) == 0 )then
			(
				append ParentTest oSel[zz].parent
			)
		)
		-- if mixed parenting unparent all the ubjects
		if ParentTest.count > 1 then
		(
			messagebox "WARNING: Mixed parenting\n Making prefab with no parenting.\n Prefab will need to be reparented to a zone"
			for  obj in selection do
			(
				obj.parent = undefined
			)
		)
		
		local oSel = selection as array
		(for o in oSel do o.wirecolor = (color 200 20 20 ) )
		local groupName = (uniquename (oStr + "_prefab_"  ) )
		group oSel  name:groupName --create the group
		--adds the newly created prefab
		local gSubArr = #()
		append gSubArr groupName
		for zz =1 to oSel.count do
		(
			append gSubArr NewGroupArr[zz]
		)
		append preFabArr gSubArr
		
		clearlistener()
		local selectNewGroup =  ("select $" + groupName as string)
		execute selectNewGroup
	)
	else
	(
		print "Select two or more objects"
	)
	--clearselection()
)

fn Destroy_PreFabs = 
(
	undo on
	(
		oSel  = selection as array
		for xx in oSel do
		(
			if isGroupHead xx  == true then
			(
				 oGroup = xx.name
				 for yy in  preFabArr do
				 (
				 	if yy[1] == oGroup then
					(
					locInArr = findItem preFabArr yy
					deleteItem preFabArr locInArr 
					)
				 )
				for i in xx.children do
				(
					i.wirecolor = (color 170 30 150 )
				)
				explodeGroup  xx
			)
		)
	)
)

fn pivotToBottomCenter = 
(
	oSelection = selection as array
	if oSelection.count == 0 then (print "select an object!")
	else(	
		for obj in  oSelection do (
			obj.pivot = [ obj.center[1], obj.center[2], obj.min[3] ] 	
			)
		)
)		

fn Get_Group_Members =
(
	undo on
	(
		if oHiddenState == true then 
		(
			
			for obj in objects do
			(
				if isGroupHead obj then
				(
					tempArr = #()
					append tempArr obj.name
					for zz in obj.children do
					(
					 	append tempArr zz
						zz.wirecolor = (color 200 20 20 )
					)
					append preFabArr tempArr 
				)
			)
			
		)
		else
		(
			
			for obj in objects do
			(
				
				if isGroupHead obj and obj.ishidden != true then
				(	
					tempArr = #()
					append tempArr obj.name
					for zz in obj.children do
					(
					 	append tempArr zz
						zz.wirecolor = (color 200 20 20 )
					)
					append preFabArr tempArr 
				)
				
			)
			
		)
	clearselection()
	)
)

fn Explode_Groups oArr = 
(  
	undo on
	(
		clearselection ()
		for jj in oArr do
		(
			local oGroup = getnodebyname jj[1]
			--print oGroup
			if oGroup != undefined then
			(
				for oCh in oGroup.children do
				(
					oCh.wirecolor = (color 20 200 20 )
				)
				explodeGroup  oGroup 
			)
		)
	) 	
)

fn Restore_Groups oArr = 
(
	--disableSceneRedraw(); 
	undo on
	(	
		for gRp in oArr do
		(
			ogRpName = gRp[1]
			clearselection()
			local gObj = getnodebyname ogRpName
			-- see if group exist in scene
			if gObj != undefined then 
			(
				format  "group \"%\" exists           ----------- skipping " gObj.name
			)
			else
			(
				for ii = 2 to gRp.count do
				(
					try(gRp[ii].wirecolor = (color 200 20 20 )) catch()
					try(selectmore gRp[ii]) catch()
				)
				oSel = selection as array
				--print oSel
				group oSel  name:ogRpName
				local obj = getnodebyname ogRpName
				if obj != undefined then
				(
					try (select obj)catch()
					pivotToBottomCenter 
				)
				if obj == undefined then
				(
					clearlistener()
					print ("Something went wrong, it could be a new scene \nand I don't remember the group sets\n Running Get_Group_Members()")
					
				)
	
			)
			clearselection()
		)
	)
	clearselection()
	 --enableSceneRedraw();
)

fn Freeze_Layers oStr= 
(
	zoneLayers = #()
	LockedLayers = 0
	unLockedLayers = 0

	for i =  1 to LayerManager.count do 
	(
 		oLayer = LayerManager.getLayer (i-1)
 		tokens = filterstring oLayer.name "_"
		--format "% is locked: %\n"oLayer.name  oLayer.lock 
 		if tokens[1] == oStr then
 		(
			append zoneLayers oLayer.name
-- 			print oLayer.lock
			if oLayer.lock == true then
			(
				LockedLayers += 1
			)
			if oLayer.lock != true then
			(
				unLockedLayers += 1
 			)	
		)
	)
	if LockedLayers < unLockedLayers  then
	(
		format ("Freezing $ layers") oStr
		for i in zoneLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.lock = true
		)
	)
	else
	(
		format ("Unfreezing % layers") oStr
		for i in zoneLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.lock = false
		)
	)
)

fn Toggle_Layers oStr= 
(
	zoneLayers = #()
	hiddenLayers = 0
	unhidLayers = 0
	for i =  1 to LayerManager.count do 
	(
		oLayer = LayerManager.getLayer (i-1)
		tokens = filterstring oLayer.name "_"
		if tokens[1] == oStr then
		(
			append zoneLayers oLayer.name
			if oLayer.ishidden == true then
			(
				hiddenLayers = hiddenLayers + 1
			)
			if oLayer.ishidden != true then
			(
				unhidLayers = unhidLayers + 1
			)	
		)
	)
	
	if hiddenLayers < unhidLayers  then
	(
		format ("Hiding % layers") oStr
		for i in zoneLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.ishidden = true
		)
	)
	else
	(
		format ("Unhiding % layers") oStr
		for i in zoneLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.ishidden = false
		)
	)
	redrawviews()
)

fn ToggleCOLSPL oStr=
(
	zoneLayers = #()
	hiddenLayers = 0
	unhidLayers = 0
	for i =  1 to LayerManager.count do 
	(
		oLayer = LayerManager.getLayer (i-1)
		tokens = filterstring oLayer.name "_"
		if tokens[1] == oStr then
		(
			if tokens[2] == "COL" then
				(
					append zoneLayers oLayer.name
					if oLayer.ishidden == true then
					(
						hiddenLayers = hiddenLayers + 1
					)
					if oLayer.ishidden != true then
					(
						unhidLayers = unhidLayers + 1
					)
				)
			if tokens[2] == "SPL" then
				(
					append zoneLayers oLayer.name
					if oLayer.ishidden == true then
					(
						hiddenLayers = hiddenLayers + 1
					)
					if oLayer.ishidden != true then
					(
						unhidLayers = unhidLayers + 1
					)
				)
		)
	)
	
	if hiddenLayers < unhidLayers  then
	(
		format ("Hiding % layers") oStr
		for i in zoneLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.ishidden = true
		)
	)
	else
	(
		format ("Unhiding % layers") oStr
		for i in zoneLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.ishidden = false
		)
	)
	redrawviews()
)




fn Delete_Empty_Layers = 
(
	fileIn (GL_Tools_Path + "Lib/fn_Delete_Empty_Layers.ms")
) -- fn Delete_Empty_Layers

fn Clean_Scene =
(
	fileIn (GL_Tools_Path + "Lib/fn_Conform_Scene.ms")
)--end fn Clean_Scene

fn Get_Layer_Visibility = 
(
	layerStatusArr = #( #(), #() )
	print ("Getting layer visibility snapshot")
		for i =  1 to LayerManager.count do 
		(
		layerM = LayerManager.getLayer (i-1)-- The only right thing about maxscript
		if layerM.ishidden != True then
			(
			--print ("layer is visible " + 	layerM.name)
			append layerStatusArr[1] layerM.name
			)
		if layerM.ishidden == True then
			(
			--print ("layer is hidden " + 	layerM.name)
			append layerStatusArr[2] layerM.name
			)
		)
	return layerStatusArr
)--end fn Get_Layer_Visibility 

fn Set_Layer_Visibility visibleLayersArr hiddenLayersArr =
(
		print ("Setting layers back to original visibility state")
		if visibleLayersArr.count != 0 then
		(
			for oLay in visibleLayersArr do
			(
				layer = LayerManager.getLayerFromName oLay 
				layer.ishidden = false
			)
		)
		--print "\n"
		if hiddenLayersArr.count != 0 then
		(
			--print hiddenLayersArr.count
			for oLay in hiddenLayersArr do
			(
				layer = LayerManager.getLayerFromName oLay 
				layer.ishidden = true
			)
		)
)--end fn Set_Layer_Visibility 
fn Insert_Name oStr =
(
	oSel =  selection as array
	for obj = 1 to oSel.count do
	(
		newName = ""
		oCheck = false
		tokens = filterString oSel[obj].name "_"
		--check to see if the string exsists within the name
		for jj in tokens do
		(
			if jj == oStr then 
			(
 				oCheck = true
			)
		)
		--if the name doesn't exist within the name insert it after the first col or dtl esle just prepend it.
		if oCheck == false then 
		(
			if tokens[1] == "col" or tokens[1] == "dtl" then
				(	
					newName = tokens[1] +"_" + oStr
					for zz = 2 to tokens.count do 
					(
						newName = newName + "_" + tokens[zz] 
					)
				)
				else
				(
					newName = oStr + "_" + oSel[obj].name
				)
				oSel[obj].name = newName
		)
	)
)
fn Set_Vertex_Color oColor = 
(
	max modify mode
	if selection.count > 1 then (
		print "Script only works on a single object"
		)-- end selection count test
	else 
		(
		s = $
		if s != undefined then 
		(
			oObjLevel = subobjectLevel
			if Classof s != Editable_Poly  then 
			(
				convertTo s PolyMeshObject
				subobjectLevel = oObjLevel
				
			)
			oSelLevel = s.GetMeshSelLevel()
			if oSelLevel == #Face then(
				selVerts = s.GetSelection #Face
				for i in selVerts do (
						polyop.SetFaceColor s 0 i (oColor)
					)--end i loop
				)--end if decision on SetfaceColor
			if oSelLevel != #Face then(
				s.ConvertSelection oSelLevel  #Vertex	
				selVerts = s.GetSelection #Vertex
				for i in selVerts do (
						polyop.setvertcolor s 0 i (oColor)
					)--end i loop
				)
			subobjectLevel = oObjLevel 
			s.showVertexColors = true
			s.vertexColorType = #color
		)

		redrawViews()
		)--end if decision
	
)--end fn
	-- Function for Creating a Bit Array from Selected Objects
fn CreateBitArrSelectedObject =
(
	SelectedObject = getCurrentSelection() -- Getting the objects selected in the viewport.
	objArr = #()
	for obj in geometry do
	(
		tokens = filterstring obj.name "_"
		if obj.parent == undefined  and tokens[1] == "zone" then
		(
			append objArr obj.name
		)
	)
	sort objArr
	listObj.items = objArr
)
fn Del_Prefix  oStr =
(
	for ob in oSel do 
	(
		tokens  = filterstring ob.name "_"
		if tokens[1] == oStr then
		(
			newName = ""
			for i = 2 to  tokens.count do
			(
				newName += tokens[i]
			)
			ob.name = newName
		)
	)
)
fn Make_Multi oStr oOffSet= 
(
	oOffSet  = oOffSet * 30
	oSel = selection as array
	posX = 0
	posY = 0
	posZ = 0
	posZArr = #()
	for obj in oSel do 
	(
		posX += obj.pos.x
		posY += obj.pos.y
		append posZArr obj.pos.z
	)	
	sort posZArr 

	negTest = posZArr[1] == abs(posZArr[1])
	if negTest == false then
	(
		posZ = (abs(posZArr[1]) + (oOffSet) ) * -1
	)
	else
	(
		posZ = posZArr[1] - (oOffSet)
	)
	--Test to see if objects exister and make one if doesn't or use that exists
	oBox = getnodebyname oStr
	if oBox == undefined then 
	(
		print ("multi doesn't exist making multi")
		oBox = box length:100 width:100 height:100
		oBox.pos  = [(posX/oSel.count), (posY/oSel.count), posZ ]
		oBox.name = oStr
		oBox.wirecolor = color 255 75 75
	)
	else
	(
		print ("multi exists - using existing multi")
	)
	
	--Make the layer
	oLayer = LayerManager.getLayerFromName oStr
	if oLayer == undefined then
	(
		oLayer = LayerManager.newLayerFromName  oStr
		oLayer.current =  true
		--oLayer.ishidden = true
	)
	--add the box node to layer
	oLayer.addnode oBox	
	--make the selected object children of the  new multi object and put them into a multi layer
	for child in oSel do
	(
		--childSelected =  child
		append oBox.children child
		oLayer.addnode child	
		child.wirecolor = color 255 75 75
	)	
)
--Make_Multi "mult_01"
fn Make_Multi_Name oArr = 
(
	oName = "multi"
	oRooms = #()
	for obj in oArr do
	(
		tokens = filterstring obj "_"
		if tokens.count > 1 then
		(
			append oRooms tokens[2]
			--oName = oName +"_" + tokens[2] 
		)
	)
	sort oRooms
	for rr in oRooms do
	(
		oName = oName +"_" + rr
	)
	--print oName
	return oName
)
rollout floatObject "Rooms List" 
(

	Multilistbox listObj "Objects in scene:" height:20
	spinner ofsetAMT "Offset:" range:[0,20,4] type:#integer across: 2
	button bCnfMat "CnfMat"


	Timer floatObjectclock "floatObjectClock" interval:200
	
	local SelectedObject = #()
	local SelectedObjectNames = #()
	local AllObjectsInScene = #()
	
	-- Function for Creating a Bit Array from Selected Objects
	fn CreateBitArrSelectedObject =
	(
		SelectedObject = getCurrentSelection() -- Getting the objects selected in the viewport.
		objArr = #()
		for obj in geometry do
		(
			tokens = filterstring obj.name "_"
			if obj.parent == undefined  and tokens[1] == "room" then
			(
				append objArr obj.name
			)
		)
		sort objArr
		listObj.items = objArr
	)
	fn Del_Prefix  oStr = 
	(
		for ob in oSel do 
		(
			tokens  = filterstring ob.name "_"
			if tokens[1] == oStr then
			(
				newName = ""
				for i = 2 to  tokens.count do
				(
					newName += tokens[i]
				)
				ob.name = newName
			)
		)
	)

	fn Make_Multi oStr oOffSet= 
	(
		oOffSet  = oOffSet * 30
		oSel = selection as array
		posX = 0
		posY = 0
		posZ = 0
		posZArr = #()
		for obj in oSel do 
		(
			posX += obj.pos.x
			posY += obj.pos.y
			append posZArr obj.pos.z
		)	
		sort posZArr 
	
		negTest = posZArr[1] == abs(posZArr[1])
		if negTest == false then
		(
			posZ = (abs(posZArr[1]) + (oOffSet) ) * -1
		)
		else
		(
			posZ = posZArr[1] - (oOffSet)
		)
		--Test to see if objects exister and make one if doesn't or use that exists
		oBox = getnodebyname oStr
		if oBox == undefined then 
		(
			print ("multi doesn't exist making multi")
			oBox = box length:100 width:100 height:100
			oBox.pos  = [(posX/oSel.count), (posY/oSel.count), posZ ]
			oBox.name = oStr
			oBox.wirecolor = color 255 75 75
		)
		else
		(
			print ("multi exists - using existing multi")
		)
		
		--Make the layer
		oLayer = LayerManager.getLayerFromName oStr
		if oLayer == undefined then
		(
			oLayer = LayerManager.newLayerFromName  oStr
			oLayer.current =  true
			--oLayer.ishidden = true
		)
		--add the box node to layer
		oLayer.addnode oBox	
		--make the selected object children of the  new multi object and put them into a multi layer
		for child in oSel do
		(
			--childSelected =  child
			append oBox.children child
			oLayer.addnode child	
			child.wirecolor = color 255 75 75
		)	
		--remove empty multis
		select $multi*
		multSel  = selection as array
		emptyMults = #()
		for ob in multSel do 
		(
			if ob.children.count == 0 then
			(
				append emptyMults (ob)
			)
		)
		delete emptyMults
		select oSel
	)
	--Make_Multi "mult_01"
		
	on floatObjectclock tick do
	(
		CurrentSelectedObject = getCurrentSelection()
	)
	
	on floatObject open do 
	(
		CreateBitArrSelectedObject()
	)
	
	on floatObject resized size do
	(
		-- Set the new Size to the list
		floatObject_size = size
		listObj.width = size[1] - 25
		listObj.height = size[2] - 34
	)
	
	on floatObject moved pos do
	(
		-- Reposition the rollout according to the Test rollout
		try(SetDialogPos  floatObject [oMDCoords[1] + 180, oMDCoords[2] + 50])catch()

	)
	on listObj selected val do 
	(
		
		for i = 1 to (listObj.items.count) do
		(	
			if listObj.selection[i] == true then
			(
				append oRooms (listObj.items[i]) 
			)
		)

	)

)
rollout floatLinker "Super Linker" 
(

	Multilistbox listObj "Objects in scene:" height:20
	--spinner ofsetAMT "Offset:" range:[0,20,4] type:#integer across: 2
	button bSuperLinker "Link Objects"
	
	Timer floatLinkerclock "floatLinkerClock" interval:200
	
	local SelectedObject = #()
	local SelectedObjectNames = #()
	local AllObjectsInScene = #()
	
	-- Function for Creating a Bit Array from Selected Objects
	fn CreateBitArrSelectedObject =
	(
		SelectedObject = getCurrentSelection() -- Getting the objects selected in the viewport.
		objArr = #()
		for obj in geometry do
		(
			tokens = filterstring obj.name "_"
			if tokens[1] == "zone" then
			(
				append objArr obj.name
			)
		)
		sort objArr
		listObj.items = objArr
	)
	
	on floatLinkerclock tick do
	(
		CurrentSelectedObject = getCurrentSelection()
	)
	
	on floatLinker open do 
	(
		CreateBitArrSelectedObject()
	)
	
	on floatLinker resized size do
	(
		-- Set the new Size to the list
		floatLinker_size = size
		listObj.width = size[1] - 25
		listObj.height = size[2] - 34
	)
	
	on floatLinker moved pos do
	(
		-- Reposition the rollout according to the Test rollout
		try(SetDialogPos  floatLinker [oMDCoords[1] + 180, oMDCoords[2] + 50])catch()

	)
	--need to put the superlinker into a function

	on listObj doubleclicked roomValue do
	(			
		global oRooms = #()
			for i in  listObj.selection do
			(
				append oRooms (listObj.items[i]) 
			)
			if oRooms.count != 1 then 
			(
				Messagebox "Select only one room"
			)
			if oRooms.count == 1 then 
			(
				--print oRooms[1]
				oLayer = LayerManager.getLayerFromName oRooms[1]
				if oLayer == undefined then
				(
					try
					(
						oLayer = LayerManager.newLayerFromName  oStr
						oLayer.current =  true
					)
					catch()
					--oLayer.ishidden = true
				)
				--make the selected object children of the  of the selected object 
				local oSel = selection as array
				oRoom = oBox = getnodebyname oRooms[1]
				for child in oSel do
				(
					--childSelected =  child
					append oRoom.children child
					if oLayer == undefined then
					(
						MessageBox ("Layer name is not the same as room name. Run Scene Conformer or rename layer")
					)
					else
					(
						oLayer.addnode child	
					)
				)	
				DestroyDialog floatLinker
			)	
		)
	on bSuperLinker pressed do
	(

		global oRooms = #()
		for i in  listObj.selection do
		(
			append oRooms (listObj.items[i]) 
		)
		if oRooms.count != 1 then 
		(
			Messagebox "Select only one room"
		)
		if oRooms.count == 1 then 
		(
			--print oRooms[1]
 			oLayer = LayerManager.getLayerFromName oRooms[1]
 			if oLayer == undefined then
			(
				try
				(
					oLayer = LayerManager.newLayerFromName  oStr
					oLayer.current =  true
				)
				catch()
				--oLayer.ishidden = true
			)
 			--make the selected object children of the  of the selected object 
			local oSel = selection as array
			oRoom = oBox = getnodebyname oRooms[1]
			for child in oSel do
			(
				--childSelected =  child
				append oRoom.children child
				if oLayer == undefined then
				(
					MessageBox ("Layer name is not the same as room name. Run Scene Conformer or rename layer")
				)
				else
				(
					oLayer.addnode child	
				)
			)	
			DestroyDialog floatLinker
		)	
	)
)

try(destroyDialog MainToolsDiag )catch()
--get set up the main array for the prefab tool
(
	global MainToolsDiag
	global oRooms = #()
	global oMDCoords
	global oHiddenState = false
	local bWidth = 120
	global iniFile = (GetDir #plugcfg) + "/Game_Loft_Tools.ini"




	if ((getfiles iniFile).count  == 0  ) then 
	(
		setINISetting iniFile "GL_Tools"  "LMD_Position"  "[555,286]"
		setINISetting iniFile "GL_Tools"  "RO_Prefab"  "true"
		setINISetting iniFile "GL_Tools"  "RO_Toggle_Layer"  "true"
		setINISetting iniFile "GL_Tools"  "RO_Scene_Conform"  "true"
		setINISetting iniFile "GL_Tools"  "RO_LevelEd_Tools"  "true"
		setINISetting iniFile "GL_Tools"  "RO_Exporter_Tools"  "true"

		

	
		
	)
--PREFABS TOOLS
	rollout subPrefabs "Prefab Tools"
	(
		
		checkbutton bRefreshPrefabs "Refesh PreFabs" width:90 offset:[-30,0] clr_PickedColorColor:(color 197 197 197) tooltip: "Get the prefab groups in scene"\
		checkbox cbHidden "Hidden" offset:[85,-20] tooltip: "Find hidden prefab groups"
		checkbutton bToggleGroups "Toggle Prefabs" width:150 clr_PickedColorColor:(color 160 139 163)  tooltip: "Explode and return groups to original state"
		
		group "Prefab Maker"
		(
			edittext prefix_txt  fieldWidth:98 offset:[-6,0] 
			button bPreFabMk "Make" width: 35 height:17  offset:[53,-22] tooltip: "Adds \"prefab_\" at the end automatically"
		)
		checkbutton bGDestroy "Destroy Selected Prefabs" offset:[-6,0] checked:true width:150 clr_PickedColorColor:(color 160 128 128)
		
		on bRefreshPrefabs changed state do  
		(
			if bToggleGroups.state  != true then
			(
				--print (cbHidden.state)
				preFabArr = #()
				oGroupTgl = false 
				Get_Group_Members ()
				clearselection();	
				bRefreshPrefabs.state = off
			)
			else
			(
				print ("Exit Prefab Groups Toggle mode");
			)
		)
		on cbHidden changed theState do 
		(
			oHiddenState  = theState 
		)
		on bToggleGroups changed state do
		(
			if state  == true  then
			(
				bRefreshPrefabs.state = on
				bRefreshPrefabs.text = ""
				bGDestroy.text = ""
				
				if preFabArr.count == 0 then
				(
					Get_Group_Members() ;
				)	
		 		Explode_Groups preFabArr 
			)
			else
			(
				bRefreshPrefabs.state = off
				bRefreshPrefabs.text = "Refesh PreFabs"
				bGDestroy.text = "Destroy Selected Prefabs"
				Restore_Groups preFabArr
			)
		)
		on bPreFabMk pressed do 
		(
			if preFabArr.count == 0 then
			(	
				--print "Noting in  "
				Create_Prefab prefix_txt.text 
				Get_Group_Members() ;				
			)
			Create_Prefab prefix_txt.text 
		)
		on bGDestroy changed state do
		(
			bGDestroy.state = on
			if bToggleGroups.checked != true then
			(
				print ("Destroying Fabs");
				Destroy_PreFabs()
				bGDestroy.state  = on
				clearselection()
			)			
		)

	)
/*
	rollout subToolSettings "Tool Settings"
	(
	
	)
*/	

	
--LEVEL LOADER

	rollout subLevelLoader "Level Loader"
	(
	button bLevelLoader "Hog Level Loader" width:110 align:#center
	
	on bLevelLoader pressed do
	(
	
		local blurdev 	= python.import "blurdev"
		blurdev.runTool "LevelGrunt" macro:""
	
	)
	)

	
--LAYER TOOLS 
	rollout subLayerTgl "Layer Toggles"
	(
		
		groupBox layersGroupBox "" width:144 height:35 offset:[-5,0]
		button bTogExp "Toggle Export" width:110 align:#center enabled:true offset:[-10,-30]
--		checkbox cbPortal tooltip:"Sets to toggle Portals" offset:[113,-23]
		
		button bTogZones "Toggle Zones" width:bWidth align:#center enabled:true offset:[-10,5]
		button bFrzZones "F" width:20 height:20 align:#center enabled:true offset:[65,-26] tooltip:"Freeze Zone Layers"
		button bTogGL	 "Toggle GL" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzGL	 "F" width:20 height:20 align:#center enabled:true offset:[65,-26] tooltip:"Freeze GL Layers"
		button bTogTrack "Toggle Track" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzTrack "F" width:20 height:20 align:#center enabled:true offset:[65,-26] tooltip:"Freeze Track Layers"
		button bTogRef	 "Toggle Ref" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzRef   "F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Ref Layer"
		button bTogLghts "Toggle Lights" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzLghts "F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Lights Layer"
		button bHidBlue	 "B" width:40 align:#left enabled:true across:3 offset:[0,-0]tooltip:"Hide Blue"
		button bHidYelw	 "Y" width:40 align:#left enabled:true across:3 offset:[0,-0]tooltip:"Hide Yellow"
		button bHidPink	 "P" width:40 align:#left enabled:true across:3 offset:[0,-0]tooltip:"Hide Pink"


		on bTogExp rightclick do
		(
			Toggle_Layers "zone"
		)
		on bTogExp pressed do
		(
			unhide geometry doLayer:True
			Hide_MC_Layers ()
			Toggle_Layers "zone"
		)
		on bTogZones pressed do
		(
			Toggle_Layers "zone"
		)
		on bTogZones rightclick do
		(
			Hide_MC_Layers ()		
			Toggle_Layers "zone"
		)
		on bFrzZones pressed do
		(
			Freeze_Layers "zone"
		)
		on bTogGL pressed do
		(
			Toggle_Layers "GL"
		)
		on bTogGL rightclick do
		(
			Hide_MC_Layers ()		
			Toggle_Layers "GL"
		)
		on bFrzGL pressed do
		(
			Freeze_Layers "GL"
		)
		--
		
		on bTogTrack pressed do
		(
			ToggleCOLSPL "GL"
		)
		on bTogTrack rightclick do
		(
			Hide_MC_Layers ()		
			ToggleCOLSPL "GL"
		)
		on bFrzTrack pressed do
		(
--			Freeze_Layers "Track"
		)
		
		on bTogLghts pressed do
		(
			Toggle_Layers "lights"
		)
		on bTogLghts rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "lights"
		)
		
		on bFrzLghts pressed do
		(
			Freeze_Layers "lights"
		)

		on bTogRef pressed do
		(
			Toggle_Layers "ref"
			local oLayer = LayerManager.getLayerFromName "Bake_Mesh"
--			oLayer.ishidden = false
		)	
		on bTogRef rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "ref"
			local oLayer = LayerManager.getLayerFromName "Bake_Mesh"
--			oLayer.ishidden = false
		)	
		on bFrzRef pressed do
		(
			Freeze_Layers "ref"
			local oLayer = LayerManager.getLayerFromName "Bake_Mesh"
--			oLayer.lock = true
		)	

		on bHidBlue pressed do
		(
			max select none
			select (for obj in geometry where (obj.wirecolor == (color 0 0 255)  and obj.ishidden == false) collect obj)
			hide selection
			max select none
			redrawViews()
		)
		on bHidYelw pressed do
		(
			max select none
			select (for obj in geometry where (obj.wirecolor == (color 255 176 0) and obj.ishidden == false) collect obj)
			hide selection
			max select none
			redrawViews()
		)
		on bHidPink pressed do
		(
			max select none
			select (for obj in geometry where (obj.wirecolor == (color 200 0 100) and obj.ishidden == false ) collect obj)
			hide selection
			max select none
			redrawViews()
			
		)
	)	
--SUB SCENE CONFORMER
	rollout subSceneConform "Scene Conformer"
	(
		button bCleanScene "Conform Scene" width:24 height: 24  offset: [25,0]across: 5 tooltip:"Conform Scene"
		button bSetIgnore "IGN" width:24 height: 24  offset: [0,0] tooltip:"Set to ignore during Scene Conformer"
		button bRemoveUD "rIGN" width:24 height: 24  offset: [5,0] tooltip:"Do not ignore during Scene Conformer"
		button bCnfMat "CnfMat" width:24 height: 24 offset: [15,0] Tooltip: "Conform Materials"
		button bZoneLinker "Zone Linker" width:24 height: 24  offset: [25,0] Tooltip:"Zone Linker"
		on bCleanScene pressed do
		(
			
			Clean_Scene()
			fileIn (GL_Tools_Path + "Lib/fn_TrackViewCleaner.ms")
			Delete_Empty_Layers()
		)
		on bSetIgnore pressed do
		(
			Set_SceneConf_Props "ignore"
		)
		on bRemoveUD pressed do
		(
			Set_SceneConf_Props ""
		)
		on bCnfMat pressed do 
		(
			fileIn (GL_Tools_Path + "Lib/fn_MaterialSwap.ms")
		)
		on bZoneLinker pressed do 
		(
			createDialog floatLinker 180 340
			SetDialogPos  floatLinker [oMDCoords[1] + 180, oMDCoords[2] + 50]
			--SetDialogPos  floatObject [oMDCoords[1] + 5, oMDCoords[2] - 50 ]
		)		
	)
	
--LEVEL EDITING TOOLS
	rollout subLevelEdTools "Level Editing Tools"	
	(
		on subLevelEdTools open do
		(
			toolPos = GetDialogPos subLevelEdTools
		)
		group "Level Editing Tools"
		(
		button bXform "X From Selected"  offset:[35,0] width:24 height:24 across:5 tooltip: "Xform"
		button bPivotBott "Pivot 2 Bottom" offset:[30,0]width:24 height:24 tooltip: "Pivot to Bottom"
		button bPivotSel "Pivot 2 Sel" offset:[20,0] width:24 height:24 tooltip: "Pivot to Selection"
		button bMergeSel "Merge Objs" offset:[23,0] width:24 height:24 tooltip: "Merge objects"
		button bExplode "Explode Objs" offset:[28,0]width:24 height:24  tooltip: "Explode Objects"

		
		button bIsolateLayer offset:[0,0]  width:24 height:24 tooltip: " Isolate Layer" across:5
		button bAddColVolume  offset:[0,0]width:24 height:24  tooltip: "Add colision volume"
		button bVTLitCorner  offset:[0,0]width:24 height:24  tooltip: "Vertex-lit Corner UV"
		button bFloored offset:[0,0] width:24 height:24  tooltip: "Move object to floor"
		button bChannelClear offset:[0,0]width:24 height:24  tooltip: "Clear Map Channels"
		
		button bSetRefProxy offset:[0,0]  width:24 height:24 tooltip: " Set Reflection Proxy" across:5
		button bNone1 offset:[0,0]  width:24 height:24 tooltip: " Disabled"
		button bNone2 offset:[0,0]  width:24 height:24 tooltip: " Disabled"
		button bNone3 offset:[0,0]  width:24 height:24 tooltip: " Disabled"
		button bNone4 offset:[0,0]  width:24 height:24 tooltip: " Disabled"
			
		button bSetBlueVColor offset:[0,0]  width:22 height:24 tooltip: "Set Blue" across:6
		button bSetOrangeVColor offset:[0,0]  width:22 height:24 tooltip: "Set Orange" 
		button bSetRedVColor offset:[0,0]  width:22 height:24 tooltip: "Set Red" 
		button bSelBlueVColor offset:[0,0]  width:22 height:24 tooltip: "Select Blue "
		button bSelOrangeVColor offset:[0,0]  width:22 height:24 tooltip: "Select Orange" 
		button bSelRedVColor offset:[0,0]  width:22 height:24 tooltip: "Select Red " 
		)
		button buvwSelected "Unwrap Selected " offset:[0,0]  width:150 tooltip: "" 

		group "Select Duplicates"
		(
			button bSelectDups "Select Dups" width:75 across:2
			checkbox cbSelected "Selection"  offset:[10,0]  checked:true 
		)

-- 		button bInsertAlpha "Insert \"alpha\" to Selected" width:(150) offset:[-5,0] 
-- 		button bSelAlpha "Select Alpha Objects" width:(150) offset:[-5,0] 

		


		on bXform pressed do 
		(	
			fileIn (GL_Tools_Path + "Lib/fn_Reset_Xforms.ms")
		)		
		on bPivotSel pressed do 
		(	
			fileIn (GL_Tools_Path + "Lib/fn_Pivot_To_Selected.ms")
		)
		on bPivotBott pressed do 
		(	
			fileIn (GL_Tools_Path + "Lib/fn_Pivot_To_Bottom.ms")
		)
		on bIsolateLayer pressed do 
		(	
			fileIn (GL_Tools_Path + "Lib/fn_isolate_room.ms")
		)		
		on  bAddColVolume pressed do 
		(	
			fileIn (GL_Tools_Path + "Lib/fn_colVolume.ms")
			
		)		
		on bVTLitCorner pressed do 
		(	
			if selection.count <= 10 then
				(
					fileIn (GL_Tools_Path + "Lib/fn_UV2Corner.ms")
				) else (
					fileIn (GL_Tools_Path + "Lib/fn_UV2BatchCrunch.ms")
				)
			
		)
		
		on bSetRefProxy pressed do
		(
			fileIn (GL_Tools_Path + "Lib/fn_setRefProxy.ms")
		)
		
		on goToBugBttn pressed do 
		(
			local thePos =[0,0,0]
			local oCamTokens = #()

			local oCamTokens= filterString camTxt.text " "
			local unhideRoom =  oCamTokens[3]
			local unhideRoomID
			if unhideRoom != undefined then
			(
				unhideRoomID = filterstring unhideRoom "_"
			)
			if oCamTokens.count == 11 then 
			(
				thePos = [oCamTokens[4]as float , (oCamTokens[6] as float * -1), oCamTokens[5] as float + 63]
				cam = freecamera rotation:(quat 0 -0.707107 -0.707107 0) --pos:thePos 
				 rotate cam (angleaxis (oCamTokens[9] as float * -1)  [1,0,0])
				 rotate cam (angleaxis (oCamTokens[8] as float * -1) [0,0,1])
				cam.pos  = thePos 
				cam.name = "Temp_Camera"
				cam.fov = 85
				viewport.setCamera cam
				forceCompleteRedraw()
				viewport.setType #view_persp_user
				delete cam
			)
			
			if cb_LayerVis.state == true then
			(
				for i =  1 to LayerManager.count do 
				(
					layerM = LayerManager.getLayer (i-1)
					layerM.ishidden = true
				)
				-- print unhideRoom
				try (
					oLayer = LayerManager.getLayerFromName unhideRoom
					oLayer.ishidden = false
				)
				catch ()

-- 				clearlistener()
				unhideMultisArr = #()
				if oCamTokens != undefined then 
					(
						if oCamTokens.count > 2 then 
						(
							roomID = (filterstring oCamTokens[3] "_" )[2] 
						)
					)
				for i = 1 to LayerManager.count do 
				(
					layerM = LayerManager.getLayer (i-1)
					local tokens  = filterstring layerM.name "_"
					if tokens[1] == "multi" then
					(
						multiTokens = filterstring layerM.name "_"
				-- 		print layerM.name
						for i in multiTokens do
						(

							if i == roomID then
							(
								
								append  unhideMultisArr  (layerM.name) --Array for later use. To crosscheck the rooms and open those rooms
								try (
									oLayer = LayerManager.getLayerFromName layerM.name
									oLayer.ishidden = false
									)
									catch ()
				-- 				print layerM.name
							)
						)
					)
				thePos = [0,0,0]
				camTxt.text = ""
				oCamTokens= #()				
				)
				append unhideMultisArr oCamTokens[3]
				for zz in unhideMultisArr do
				(
					try (
						oLayer = LayerManager.getLayerFromName zz
						oLayer.ishidden = false
					)
					catch ()
				)
					try (
						oLayer = LayerManager.getLayerFromName "detail"
						oLayer.ishidden = false
					)
					catch ()
			)
			camTxt.text = ""
		)
		on bSelectDups pressed do
		(
			if cbSelected.state == true then 
			(
				print ("working only on selected object");
				oSel = selection as array
				if oSel.count > 1 then
				(
					fileIn (GL_Tools_Path + "Lib/fn_Select_Duplicates.ms")
				)
			)
			else
			(
				print ("working on visible objects");
				clearselection()
				for obj in geometry do
				(
					if obj.ishidden == false then 
					(
						selectmore obj
					)
				)
				fileIn (GL_Tools_Path + "Lib/fn_Select_Duplicates.ms")
			)
		)
		on bMergeSel pressed do 
		(
			fileIn (GL_Tools_Path + "Lib/fn_Snapshot_Selected.ms") 
		)
		on bExplode pressed do 
		(
			fileIn (GL_Tools_Path + "Lib/fn_Explode_Selected.ms")
		)
		on bFloored pressed do
		(
			fileIn (GL_Tools_Path + "Lib/fn_Selected_To_Floor.ms")
		)
		on bChannelClear pressed do 
		(
			fileIn (GL_Tools_Path + "Lib/fn_MapChanClear.ms")
		)		

		on bSetBlueVColor pressed do 
		(	
			for obj in selection do
			(
				obj.wirecolor = color 0 0 255
			)
			Set_UserDefined_Props "LM1_"
		)
		on bSetOrangeVColor pressed do 
		(	
			for obj in selection do
			(
				obj.wirecolor = color 255 176 0
			)
			Set_UserDefined_Props "LM2_"
		)
		on bSetRedVColor pressed do 
		(	
			for obj in selection do
			(
				obj.wirecolor = color 200 0 100
			)
			Set_UserDefined_Props "LM3_"
			
		)
		on bSelBlueVColor pressed do 
		(	
			select (for obj in geometry where (obj.wirecolor == (color 0 0 255)  and obj.ishidden == false) collect obj)
		)
		on bSelOrangeVColor pressed do 
		(	
			select (for obj in geometry where (obj.wirecolor == (color 255 176 0) and obj.ishidden == false) collect obj)
		)
		on bSelRedVColor pressed do 
		(	
			select (for obj in geometry where (obj.wirecolor == (color 200 0 100) and obj.ishidden == false ) collect obj)
		)
		on buvwSelected pressed do
		(
			
			fileIn (GL_Tools_Path + "S:\\code\\maxscript\\tools\\Modeling_Tools\\_UV_Tools\\MultiObject_Unwrap\\MultiObject_Unwrap.ms")

		)
		on bvcBlack pressed do
		(
			Set_Vertex_Color (color 0 0 0)
		)

		on bSelAlpha pressed do 
		(
			select $*alpha*
			oSel = selection as array 
			for i in oSel do
			(
				if i.ishidden == true then
				(
					deselect i
				)
			)
		)		
	)
-- VERTEX COLORING TOOLS
	rollout VertexColorTools "Vertex Color Tools"
	(
		bitmap the_bmp fileName:("C:\\Program Files\\Autodesk\\3ds Max 2012\\Scripts\\Gameloft\\A9_Tools\\Icons\\GL_gradient.bmp") offset:[-5,0]
		slider BW_Slider "" orient:#horizontal type:#integer ticks:0 range:[0,255,128]  
		colorpicker clr_PickedColor color:[250, 245, 230] modal:false width:100 height:24 across:2
		button btn_ColorPicker offset:[20,0]  width:22 height:24 tooltip: "Set Vertex Color" 
		Button vColorist "Vertex Colorist" width:128
		
		on btn_ColorPicker pressed do
		(
-- 			clearlistener();
			colorF3 = spColorPick() 
			if colorF3  !=  [-1,-1,-1] then 
			(
				if ( colorF3[1] != 0 or colorF3[2] != 0 or colorF3[3] != 0 ) then
				(
					_color = (255.0 * colorF3) as color
					
					Set_Vertex_Color ( _color )
				)
			)

		)
		on BW_Slider changed val do 
		(
			Set_Vertex_Color (color val val val)
		)
			
		local dynamicColor = (color 250 245 230)
		on clr_PickedColor changed new_col do
		(
			Set_Vertex_Color (new_col)
			dynamicColor = new_col
		)-- end excution
		on vColorist pressed  do
		(
			fileIn (GL_Tools_Path + "Lib/LM2VC.ms")
		)
		on VertexColorTools close do
		(
			clearSelection()
		)
	)
	
	--EXPORT TOOL
	rollout subExportTools "Scene Export"
	(

		
		
		groupBox gExportDialog "Export Options" width:144 height:162 offset:[-5,5]
		checkbox cExVisual "Visual" checked: true offset:[5,-144]
		checkbox cExRoad "Road" checked: false offset:[5,-0]
		checkbox cExGLayers "Game Layers" checked: false offset:[5,-0]
		checkbox cExTextures "Textures" checked: false offset:[5,-0]
		checkbox cSyncShaders "Sync Shaders" checked: false offset:[5,-0]
		button bExport "Export" width:110 height:24 offset:[0,5] align:#center
--		checkbox cRun "" checked: false offset:[111,-24]
		
		button bMapTools "Map Tools" width:110 align:#center offset:[0,8]
		button bExportTextures "Export Textures" width:110 align:#center
		
		on bMapTools pressed do
		(
		fileIn ("T:\\tools\\MaxScripts\\MapTools.ms")
		)
		
		on bExportTextures pressed do
		(
			if (doesFileExist (maxFilePath + ( (Filterstring maxFileName ".")[1] ) + ".cfg")) == false then
			(
				GenerateMapConfig()
				fileIn (GL_Tools_Path + "Lib/fn_ddstexturecompress.ms")
			) else
			(
				fileIn (GL_Tools_Path + "Lib/fn_ddstexturecompress.ms")
			)
		)
		
		on bExport pressed do
		(
		
			if (doesFileExist (maxFilePath + ( (Filterstring maxFileName ".")[1] ) + ".cfg")) == false then
			(
				GenerateMapConfig()
				if cExTextures.checked == true then
				(
					print "Export Scene Textures"
					fileIn (GL_Tools_Path + "Lib/fn_ddstexturecompress.ms")
				)
				
				if cSyncShaders.checked == true then
				(
					print "Sync Glitch Shaders"
					m = GL_Effect()
					m.lib.ReloadAll()
				)

				if cExRoad.checked == true then
				(
					print "Export Road"
					fileIn (GL_Tools_Path + "Lib/fn_A9ExportRoadModule.ms")
				)
				
				if cExVisual.checked == true then
				(
					print "Export Visual"
					fileIn (GL_Tools_Path + "Lib/fn_A9ExportZoneModule.ms")
				)


				
				if cExGLayers.checked == true then
				(
					print "Export Game Layers"
					fileIn (GL_Tools_Path + "Lib/fn_A9ExportGLModule.ms")
				)
				
				
				--batch scene components
				
				if cExVisual.checked == true then
				(
--					print "Batch Visual"
--					BatchGameData ( "Visual" )
				)
				
				if cExGLayers.checked == true then
				(
--					print "Batch Game Layers"
--					BatchGameData ( "Road" )
				)
				
				
				fileIn ("S://code//maxscript//tools//Projects//_Asphalt//A9_Tools//Lib//fn_Conform_Scene.ms")
				fileIn ("S://code//maxscript//tools//Projects//_Asphalt//A9_Tools//Lib//fn_Delete_Empty_Layers.ms")
				Hide_MC_Layers ()
				Toggle_Layers "zone"
			) else
			(
				if cExTextures.checked == true then
				(
					print "Export Scene Textures"
					fileIn (GL_Tools_Path + "Lib/fn_ddstexturecompress.ms")
				)
				
				if cSyncShaders.checked == true then
				(
					print "Sync Glitch Shaders"
					m = GL_Effect()
					m.lib.ReloadAll()
				)

				if cExRoad.checked == true then
				(
					print "Export Road"
					fileIn (GL_Tools_Path + "Lib/fn_A9ExportRoadModule.ms")
				)
				
				if cExVisual.checked == true then
				(
					print "Export Visual"
					fileIn (GL_Tools_Path + "Lib/fn_A9ExportZoneModule.ms")
				)
				
				if cExGLayers.checked == true then
				(
					print "Export Game Layers"
					fileIn (GL_Tools_Path + "Lib/fn_A9ExportGLModule.ms")
				)
						
				if cExVisual.checked == true then
				(
--					print "Batch Visual"
--					BatchGameData ( "Visual" )
				)

				if cExGLayers.checked == true then
				(
--					print "Batch Game Layers"
--					BatchGameData ( "Road" )
				)
				
				fileIn ("S://code//maxscript//tools//Projects//_Asphalt//A9_Tools//Lib//fn_Conform_Scene.ms")
				fileIn ("S://code//maxscript//tools//Projects//_Asphalt//A9_Tools//Lib//fn_Delete_Empty_Layers.ms")
				Hide_MC_Layers ()
				Toggle_Layers "zone"
			)
			
		
		)	
	)
	
	--MAIN DIALOG
	rollout MainToolsDiag "Gameloft Tools"
	(
		SubRollout mySubRollout width:170 height:900 align:#center
		
		on MainToolsDiag open do
		(
			oPosStr = filterString (getINISetting iniFile "GL_Tools"  "LMD_Position") "[,],\,"
			oMDCoords = [oPosStr[1] as integer, oPosStr[2] as integer]
			global RO_Prefab = (getINISetting iniFile "GL_Tools"  "RO_Prefab") 
			global RO_Toggle_Layer = (getINISetting iniFile "GL_Tools"  "RO_Toggle_Layer")
			global RO_Scene_Conform = (getINISetting iniFile "GL_Tools"  "RO_Scene_Conform") 
			global RO_LevelEd_Tools = (getINISetting iniFile "GL_Tools"  "RO_LevelEd_Tools") 
			global RO_VertexColor_Tools = (getINISetting iniFile "GL_Tools"  "RO_VertexColor_Tools") 
			global RO_Exporter_Tools = (getINISetting iniFile "GL_Tools"  "RO_Exporter_Tools") 
			GL_Tools_Path = getINISetting iniFile "GL_Tools"  "GL_Tools_Path"
			GL_Art_Path    = getINISetting iniFile "GL_Tools"  "GL_Art_Path"	



			
		)
		on MainToolsDiag moved pos do
		(
			oMDCoords = GetDialogPos MainToolsDiag
			clearlistener()
			--print oMDCoords 
		)
		on MainToolsDiag close do
		(
			sysInfo.username
			setINISetting iniFile "GL_Tools"  "LMD_Position"  (oMDCoords as string)
			
--			GL_Tools_Path		= subToolSettings.GL_Tools_TXT.text
--			GL_Art_Path		= subToolSettings.GL_Art_TXT.text
			setINISetting iniFile "GL_Tools"  "GL_Tools_Path"  (GL_Tools_Path as string)
			setINISetting iniFile "GL_Tools"  "GL_Art_Path"  (GL_Art_Path as string)
			if subPrefabs.open == true then
			(
				setINISetting iniFile "GL_Tools"  "RO_Prefab" "false"
			)
			else 
			(
				setINISetting iniFile "GL_Tools"  "RO_Prefab"  "true"
			)
			
			if subLayerTgl.open == true then
			(
				setINISetting iniFile "GL_Tools"  "RO_Toggle_Layer"  "false"
			)
			else
			(
				setINISetting iniFile "GL_Tools"  "RO_Toggle_Layer"  "true"
			)
			if subSceneConform.open == true then
			(
				setINISetting iniFile "GL_Tools"  "RO_Scene_Conform"  "false"
			)
			else
			(
				setINISetting iniFile "GL_Tools"  "RO_Scene_Conform"  "true"
			)
			if subLevelEdTools.open == true then
			(
				setINISetting iniFile "GL_Tools"  "RO_LevelEd_Tools"  "false"
			)
			else
			(
				setINISetting iniFile "GL_Tools"  "RO_LevelEd_Tools"  "true"
			)
			if VertexColorTools.open == true then
			(
				setINISetting iniFile "GL_Tools"  "RO_VertexColor_Tools"  "false"
			)
			else
			(
				setINISetting iniFile "GL_Tools"  "RO_VertexColor_Tools"  "true"
			)
			
			if subExportTools.open == true then
			(
				setINISetting iniFile "GL_Tools"  "RO_Exporter_Tools"  "false"
			)
			else
			(
				setINISetting iniFile "GL_Tools"  "RO_Exporter_Tools"  "true"
			)
			
		)
	)

	on execute do
	(

		
--		if GL_Tools_Path  == undefined then
--		(
			GL_Tools_Path = "S:\\code\\maxscript\\tools\\Projects\\_Asphalt\\A9_Tools"
--			GL_Tools_Path =  "M:\\"
--		)
		createDialog MainToolsDiag width:170  style:#(#style_sysmenu,#style_titlebar,#style_minimizebox,#style_resizing) 
		SetDialogPos  MainToolsDiag [oMDCoords[1] , oMDCoords[2]]
		-- Gets the Set_UserDefined_Props function from Lightmap tool
-- 		fileIn ("M:/tools/3dsmax/LightMapper/Lib/fn_Set_UserDefined_Props.ms")

		
		iconFile = "S:\\code\\maxscript\\tools\\Projects\\_Asphalt\\A9_Tools\\Icons\\GL_Tools_24i.bmp"
		icoBitmap = openBitmap iconFile
		icoCount = case icoBitmap.height of
									 (
										  24: icoBitmap.width/24
										  default: icoBitmap.width/16
									 ) 
		

		AddSubRollout MainToolsDiag.mySubRollout subLevelLoader 		rolledUp: (true)
		AddSubRollout MainToolsDiag.mySubRollout subLayerTgl 			rolledUp: (RO_Toggle_Layer as booleanClass)
		AddSubRollout MainToolsDiag.mySubRollout subSceneConform rolledUp: (RO_Scene_Conform as booleanClass)
		AddSubRollout MainToolsDiag.mySubRollout subLevelEdTools rolledUp: (RO_LevelEd_Tools as booleanClass )
		AddSubRollout MainToolsDiag.mySubRollout VertexColorTools rolledUp: (RO_VertexColor_Tools as booleanClass)
		AddSubRollout MainToolsDiag.mySubRollout subExportTools rolledUp: (RO_Exporter_Tools as booleanClass )
		--add icons to buttons
		subSceneConform.bCleanScene.images 		= #(iconFile, undefined, icoCount,11,11,1,1, false, true)
		subSceneConform.bSetIgnore.images 			= #(iconFile, undefined, icoCount,25,25,1,1, false, true)
		subSceneConform.bRemoveUD.images 			= #(iconFile, undefined, icoCount,26,26,1,1, false, true)
		subSceneConform.bCnfMat.images 			= #(iconFile, undefined, icoCount,14,14,1,1, false, true)
		subSceneConform.bZoneLinker.images 		= #(iconFile, undefined, icoCount,13,13,1,1, false, true)

		subLevelEdTools.bXform.images 					= #(iconFile, undefined, icoCount,4,4,1,1, false, true)
		subLevelEdTools.bPivotBott.images 				= #(iconFile, undefined, icoCount,2,2,1,1, false, true)
		subLevelEdTools.bPivotSel.images 				= #(iconFile, undefined, icoCount,3,3,1,1, false, true)
		subLevelEdTools.bMergeSel.images 				= #(iconFile, undefined, icoCount,5,5,1,1, false, true)
		subLevelEdTools.bExplode.images 				= #(iconFile, undefined, icoCount,6,6,1,1, false, true)
		subLevelEdTools.bIsolateLayer.images 			= #(iconFile, undefined, icoCount,1,1,1,1, false, true)
		subLevelEdTools.bAddColVolume.images 			= #(iconFile, undefined, icoCount,7,7,1,1, false, true)
		subLevelEdTools.bVTLitCorner.images 			= #(iconFile, undefined, icoCount,8,8,1,1, false, true)
		subLevelEdTools.bFloored.images 				= #(iconFile, undefined, icoCount,10,10,1,1, false, true)
		subLevelEdTools.bChannelClear.images 		= #(iconFile, undefined, icoCount,9,9,1,1, false, true)
		
		subLevelEdTools.bSetRefProxy.images 			= #(iconFile, undefined, icoCount,27,27,1,1, false, true)
		
/*
		subLevelEdTools.bCreate_SC.images 			= #(iconFile, undefined, icoCount,18,18,1,1, false, true)
		subLevelEdTools.bMake_Alpha.images 			= #(iconFile, undefined, icoCount,15,15,1,1, false, true)
		subLevelEdTools.bRemove_Alpha.images 		= #(iconFile, undefined, icoCount,17,17,1,1, false, true)
		subLevelEdTools.bSel_Alpha.images 			= #(iconFile, undefined, icoCount,16,16,1,1, false, true)
		subLevelEdTools.bSet_HD.images 				= #(iconFile, undefined, icoCount,27,27,1,1, false, true)
*/
		subLevelEdTools.bSetBlueVColor.images 		= #(iconFile, undefined, icoCount,19,19,1,1, false, true)
		subLevelEdTools.bSetOrangeVColor.images 	= #(iconFile, undefined, icoCount,20,20,1,1, false, true)
		subLevelEdTools.bSetRedVColor.images 		= #(iconFile, undefined, icoCount,21,21,1,1, false, true)
		subLevelEdTools.bSelBlueVColor.images 		= #(iconFile, undefined, icoCount,22,22,1,1, false, true)
		subLevelEdTools.bSelOrangeVColor.images 	= #(iconFile, undefined, icoCount,23,23,1,1, false, true)
		subLevelEdTools.bSelRedVColor.images 		= #(iconFile, undefined, icoCount,24,24,1,1, false, true)
		
		VertexColorTools.btn_ColorPicker.images 		= #(iconFile, undefined, icoCount,28,28,1,1, false, true)
		
		subLayerTgl.bFrzZones.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzGL.images 						= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzTrack.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzLghts.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzRef.images 						= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bHidBlue.images 					= #(iconFile, undefined, icoCount,19,19,1,1, false, true)
		subLayerTgl.bHidYelw.images 					= #(iconFile, undefined, icoCount,20,20,1,1, false, true)
		subLayerTgl.bHidPink.images 					= #(iconFile, undefined, icoCount,21,21,1,1, false, true)
		
		


	)
)


