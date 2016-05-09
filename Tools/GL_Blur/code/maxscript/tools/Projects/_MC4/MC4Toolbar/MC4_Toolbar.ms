--
--	\MC4 Toolbar	
--	
--	\Description	Collection d'outils pour MC4.
--	\Description	
--	\Description	A collection of tools for MC4.
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 01/11/2011



if ( ( preFabArr == undefined) == true) then 
( 
	global preFabArr
	preFabArr = #() 
)

global MC4_Toolbar_Path  = getFilenamePath (getThisScriptFilename())
global GL_Art_Path 

--creates shadow caster	
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
-- 	print ("Setting User Defined Scene Confromer to: " + oStr)
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
			messagebox "WARNING: Mixed parenting\n Making prefab with no parenting.\n Prefab will need to be reparented to a room"
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
	roomLayers = #()
	LockedLayers = 0
	unLockedLayers = 0

	for i =  1 to LayerManager.count do 
	(
 		oLayer = LayerManager.getLayer (i-1)
 		tokens = filterstring oLayer.name "_"
		--format "% is locked: %\n"oLayer.name  oLayer.lock 
 		if tokens[1] == oStr then
 		(
			append roomLayers oLayer.name
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
		for i in roomLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.lock = true
		)
	)
	else
	(
		format ("Unfreezing % layers") oStr
		for i in roomLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.lock = false
		)
	)
)

fn Toggle_Layers oStr= 
(
	roomLayers = #()
	hiddenLayers = 0
	unhidLayers = 0
	for i =  1 to LayerManager.count do 
	(
		oLayer = LayerManager.getLayer (i-1)
		tokens = filterstring oLayer.name "_"
		if tokens[1] == oStr then
		(
			append roomLayers oLayer.name
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
		for i in roomLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.ishidden = true
		)
	)
	else
	(
		format ("Unhiding % layers") oStr
		for i in roomLayers do
		(
		oLayer = LayerManager.getLayerFromName i 
		oLayer.ishidden = false
		)
	)
)

fn Delete_Empty_Layers = 
(
	print ("Removing empty layers")
	local DelArr = #()
	for i =  1 to LayerManager.count do 
	(
		local curLayer = LayerManager.getLayerFromName "0" 
		curLayer.current = true
		local oLayer = LayerManager.getLayer (i-1)
		local layerRT = oLayer.layerAsRefTarg
		
		if (refs.dependents layerRT).count == 2 then
		(
			if oLayer.name != "0" then
			(
				
				append DelArr oLayer.name
			)
		)
	)
	
	for ll in DelArr do
	(
	LayerManager.deleteLayerByName  ll
	)
) -- fn Delete_Empty_Layers

fn Clean_Scene =
(
	global irrLayer  	= undefined
	global portalLayer 	= undefined
	global floorLayer 	= undefined
	global dynLayer 	= undefined
	global lightsLayer	= undefined
	global helperLayer	= undefined
	global refLayer		= undefined
	global dtlLayer		= undefined
	global goodLayers 	= #("irradiance", "portals", "floor", "dynamic", "lights", "helpers", "ref", "detail", "shadow_caster")
	
	print ("Setting up base layers")
	if LayerManager.getLayerFromName "irradiance" == undefined then
	(
		irrLayer  = LayerManager.newLayerFromName "irradiance"
	)
	else
	(
		irrLayer  = LayerManager.getLayerFromName "irradiance"
	)
	
	if LayerManager.getLayerFromName "portals" == undefined then
	(
		portalLayer = LayerManager.newLayerFromName "portals"
	)
	else
	(
		portalLayer = LayerManager.getLayerFromName "portals"
	)
	
	
	if LayerManager.getLayerFromName "floor" == undefined then
	(
		floorLayer = LayerManager.newLayerFromName "floor"
	)
	else
	(
		floorLayer = LayerManager.getLayerFromName "floor"
	)
	
	if LayerManager.getLayerFromName "dynamic" == undefined then
	(
		dynLayer = LayerManager.newLayerFromName "dynamic"
	)
	else
	(
		dynLayer = LayerManager.getLayerFromName "dynamic"
	)
	
	if LayerManager.getLayerFromName "lights" == undefined then
	(
		lightsLayer = LayerManager.newLayerFromName "lights"
	)
	else
	(
		lightsLayer = LayerManager.getLayerFromName "lights"
	)
	
	if LayerManager.getLayerFromName "helpers" == undefined then
	(
		helperLayer = LayerManager.newLayerFromName "helpers"
	)
	else
	(
		helperLayer = LayerManager.getLayerFromName "helpers"
	)
	
	if LayerManager.getLayerFromName "ref" == undefined then
	(
		refLayer = LayerManager.newLayerFromName "ref"
	)
	else
	(
		refLayer = LayerManager.getLayerFromName "ref"
	)
	if LayerManager.getLayerFromName "lights" == undefined then
	(
		lightsLayer = LayerManager.newLayerFromName "lights"
	)
	else
	(
		lightsLayer = LayerManager.getLayerFromName "lights"
	)	
	
	if LayerManager.getLayerFromName "detail" == undefined then
	(
		dtlLayer = LayerManager.newLayerFromName "detail"
	)
	else
	(
		dtlLayer = LayerManager.getLayerFromName "detail"
	)
	
	if LayerManager.getLayerFromName "Bake_Mesh" == undefined then
	(
		bmLayer = LayerManager.newLayerFromName "Bake_Mesh"
	)
	else
	(
		bmLayer = LayerManager.getLayerFromName "Bake_Mesh"
	)
	
	print ("Working on Helpers and Particles")
	for hlpr in helpers do
	(
		helperLayer.addnode hlpr
	)
	print ("Working on Multi objecs and Rooms")
	noPolyObjects = #()
	rollout pbar "Progress Multi and Room Layers"
	(
	progressbar doit_prog color:red -- a red progress bar
	)
	createDialog pbar  -- create a dialog to test
	for geo in geometry do
	(
		--Delete empty objects
		meshObj = snapshotasmesh geo 
		numVerts = meshop.getNumVerts meshObj
		if numVerts  == 0 then
		(
			append noPolyObjects geo
		)
		tokens = filterString geo.name "_"
		if tokens[1] == "multi" then
		(
			if geo.children.count != 0 then
			(
				oLayer = undefined
				--print (geo.name)
				if LayerManager.getLayerFromName geo.name == undefined then
				(
					oLayer = LayerManager.newLayerFromName geo.name
				)
				else
				(
					oLayer  = LayerManager.getLayerFromName geo.name
				)
				oLayer.addnode geo 
				obj = getnodebyname (geo.name as string)
				select geo				
				for geo in selection do 
				(
					selectMore geo.children
				)
				for zz = 1 to selection.count do 
				(
					--leave the bake textures, shadowcasters and UserDefined ignore props alone
					local objTokens  = filterstring selection[zz].name "_"
					local oUDprops = getUserProp selection[zz] "#SceneConformer"
					if  (objTokens[1] != "LM1" and  objTokens[1] != "LM2" and  objTokens[1] != "LM3" and  objTokens[1] != "LM4" and  objTokens[1] != "sc" and oUDprops != "ignore") then
-- 					if (selection[zz].name != "LM1_" and selection[zz].name != "LM2_" and selection[zz].name != "LM3_"and selection[zz].name != "LM4_") then
					(
						oLayer.addnode selection[zz]
						pbar.doit_prog.value = 100.*zz/selection.count
					)
				)
			)
		)
		if tokens[1] == "room" then
		(
			if geo.children.count != 0 then
			(
				oLayer = undefined
				--print (geo.name)
				if LayerManager.getLayerFromName geo.name == undefined then
				(
					oLayer = LayerManager.newLayerFromName geo.name
				)
				else
				(
					oLayer  = LayerManager.getLayerFromName geo.name
				)
				-- add the room to its layer
				oLayer.addnode geo 
				pbar.doit_prog.value = 0
				select geo
				for geo in selection do 
				(
					selectMore geo.children
				)
				for zz=1 to  selection.count do 
				(
					local objTokens  = filterstring selection[zz].name "_"
					local oUDprops = getUserProp selection[zz] "#SceneConformer"
					if  (objTokens[1] != "LM1" and  objTokens[1] != "LM2" and  objTokens[1] != "LM3" and  objTokens[1] != "LM4" and  objTokens[1] != "sc" and oUDprops != "ignore") then
-- 					if (selection[zz].name != "LM1_" and selection[zz].name != "LM2_" and selection[zz].name != "LM3_"and selection[zz].name != "LM4_") then 
					(
 						oLayer.addnode selection[zz]
						pbar.doit_prog.value = 100.*zz/selection.count
					)
				)
				
			)
		)
	)

	destroyDialog pbar	
	print "Exploding Groups and Prefabs in rooms"
	RefObjs = #()
	refLayer = LayerManager.getLayerFromName "ref"
	refLayer.nodes &tempArr
	for jj in tempArr do
	(
		append RefObjs jj
	)
	for ob in objects do
	(
		if isGroupHead ob == true then 
		(
			--print ob
			if finditem RefObjs ob ==  0 then 
			(
				explodeGroup ob 
			)
		)
	)
	print ("Deleting empty objects")
	for obj in noPolyObjects do 
	(
	--print obj.name
	delete obj	
	)
	print ("Working on Irradiance")
	for ob in objects do
	(
		tokens = filterstring  ob.name "_"
		if tokens[1] == "irradiance" then 
		(
			irrLayer.addnode ob 
		)
	)
	print ("Working on Floor")
	for ob in objects do
	(
		tokens = filterstring  ob.name "_"
		if tokens[1] == "floor" then 
		(
			floorLayer.addnode ob
		)
	)
	print ("Working on Portals")
	for ob in objects do
	(
		tokens = filterstring  ob.name "_"
		if tokens[1] == "portal" then 
		(
			portalLayer.addnode ob
		)
	)
	print ("Working on Dynamics")
	for ob in objects do
	(
		tokens = filterstring  ob.name "_"
		if tokens[1] == "dynamic" or tokens[1] == "GL" then 
		(
			dynLayer.addnode ob
		)
	)

	print ("Working on Details")
	for ob in objects do
	(
		tokens = filterstring  ob.name "_"
		if tokens[1] == "dtl" then 
		(
			dtlLayer.addnode ob
		)
	)

	print ("Workign on Vray and Irradiance Lights")
	for ll in lights do
	(
		if (classof ll == VRayLight or classof ll == TargetDirectionallight)then 
		(
			lightsLayer.addnode ll 
		)
		if (classof ll == Omnilight ) then
		(
			irrLayer.addnode ll 
		)
	)

	print ("Working on ref content")
	for i =  1 to LayerManager.count do 
	(
		oLayer = LayerManager.getLayer (i-1)
		tokens = filterstring oLayer.name "_"
		if  ( tokens[1] == "multi" or tokens[1] == "room" ) then
		(
			append goodLayers olayer.name
		)
	)

	for  zz =1 to LayerManager.count do
	(
		oLayer = LayerManager.getLayer (zz-1)
		
		if (findItem goodLayers oLayer.name) == 0 then
		(
			--print (oLayer.name)
			clearselection()
			(layerManager.getLayerFromName oLayer.name).select true
			oLaySel = selection as array
			for lObj in oLaySel do
			(
				--leave bake meshes alone
				local objTokens  = filterstring lObj.name "_"
				local oUDprops = getUserProp lObj "#SceneConformer"
				if  (objTokens[1] != "LM1" and  objTokens[1] != "LM2" and  objTokens[1] != "LM3" and  objTokens[1] != "LM4" and  objTokens[1] != "sc" and oUDprops != "ignore") then
-- 				if (lObj.name != "LM1_" and lObj.name != "LM2_" and lObj.name != "LM3_" and lObj.name != "LM4_") then 
				(
					refLayer.addnode lObj
				)
			)
		)
	)	

	print ("Working on Shadow Caster")
	for ob in objects do
	(
		tokens = filterstring  ob.name "_"
		if tokens[1] == "sc" then 
		(
			bmLayer.addnode ob
		)
	)
clearselection()
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
	for ob in selection do 
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
fn Make_Multi oStr oOffSet = 
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
	if ( oBox == undefined ) then 
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
	)
	--add the box node to layer
	oLayer.addnode oBox	
	--make the selected object children of the  new multi object and put them into a multi layer
	for child in oSel do
	(
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
	button bMakeMulti "Make Multi"


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
		)
		--add the box node to layer
		oLayer.addnode oBox	
		--make the selected object children of the  new multi object and put them into a multi layer
		for child in oSel do
		(
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
			)
		)
		sort oRooms
		for rr in oRooms do
		(
			oName = oName +"_" + rr
		)
		return oName
	)
	
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
	on bMakeMulti pressed do
	(

		global oRooms = #()
		for i in  listObj.selection do
		(
			append oRooms (listObj.items[i]) 
		)
		DestroyDialog floatObject
		if oRooms.count != 0 then 
		(
			multiName = Make_Multi_Name oRooms 
			Make_Multi multiName ofsetAMT.value
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
			if obj.parent == undefined  and tokens[1] == "room" or tokens[1] == "multi" then
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
				oLayer = LayerManager.getLayerFromName oRooms[1]
				if oLayer == undefined then
				(
					try
					(
						oLayer = LayerManager.newLayerFromName  oStr
						oLayer.current =  true
					)
					catch()
				)
				--make the selected object children of the  of the selected object 
				local oSel = selection as array
				oRoom = oBox = getnodebyname oRooms[1]
				for child in oSel do
				(
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
		if ( oRooms.count != 1 ) then 
		(
			Messagebox "Select only one room"
		)
		if ( oRooms.count == 1 ) then 
		(
 			oLayer = LayerManager.getLayerFromName oRooms[1]
 			if ( oLayer == undefined ) then
			(
				try
				(
					oLayer = LayerManager.newLayerFromName  oStr
					oLayer.current =  true
				)
				catch()
			)
 			--make the selected object children of the  of the selected object 
			local oSel = selection as array
			oRoom = oBox = getnodebyname oRooms[1]
			for child in oSel do
			(
				--childSelected =  child
				append oRoom.children child
				if ( oLayer == undefined ) then
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

try(destroyDialog MC4_ToolsDiag )catch()
--get set up the main array for the prefab tool
(
	global MC4_ToolsDiag
	global oRooms = #()
	global oMDCoords
	global oHiddenState = false
	local bWidth = 120
	local working_dir = getFilenamePath (getThisScriptFilename())
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
			if ( state  == true  ) then
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
				Destroy_PreFabs();
				bGDestroy.state  = on
				clearselection();
			)			
		)

	)

--LAYER TOOLS 
	rollout subLayerTgl "Layer Toggles"
	(
		
		groupBox layersGroupBox "" width:144 height:35 offset:[-5,0]
		button bTogExp 		"Toggle Export" width:110 align:#center enabled:true offset:[-10,-30]
		checkbox cbPortal 	tooltip:"Sets to toggle Portals" offset:[113,-23]
		
		button bTogRooms 	"Toggle Rooms" width:bWidth align:#center enabled:true offset:[-10,5]
		button bFrzRooms  	"F" width:20 height:20 align:#center enabled:true offset:[65,-26] tooltip:"Freeze Rooms Layers"
		button bTogMulti 	"Toggle Multi" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzMulti	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Multi Layers"
		button bTogFlor 	"Toggle Floor" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzFlor    	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Floor Layer"
		button bTogPortal 	"Toggle Portals" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzPortal	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Portals Layer"
		button bTogDyn 		"Toggle Dynamic" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzDyn    	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Dynamic Layer"

		button bTogIrr 		"Toggle Irradiance" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzIrr    	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Irradiance Layer"
		button bTogRef 		"Toggle Ref" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzRef    	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Ref Layer"
		button bTogDTL 		"Toggle Details" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzDTL    	"F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Ref Layer"
		button bTogLghts 	"Toggle Lights" width:bWidth align:#center enabled:true offset:[-10,0]
		button bFrzLghts    "F" width:20 align:#center enabled:true offset:[65,-26]tooltip:"Freeze Ref Layer"
		on bTogExp rightclick do
		(
			Toggle_Layers "room"
			Toggle_Layers "multi"
			Toggle_Layers "detail"
			Toggle_Layers "helpers"
			if (cbPortal.checked == true) then
			(
				Toggle_Layers "portals"
			)
		)
		on bTogExp pressed do
		(
			unhide geometry doLayer:True
			Hide_MC_Layers ()
			Toggle_Layers "room"
			Toggle_Layers "multi"
			Toggle_Layers "detail"
			Toggle_Layers "helpers"
			if (cbPortal.checked == true) then
			(
				Toggle_Layers "portals"
			)
		)
		on bTogRooms pressed do
		(
			Toggle_Layers "room"
		)
		on bTogRooms rightclick do
		(
			Hide_MC_Layers ()		
			Toggle_Layers "room"
		)
		on bFrzRooms pressed do
		(
			Freeze_Layers "room"
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

		on bTogMulti pressed do
		(
			Toggle_Layers "multi"
		)
		on bTogMulti rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "multi"
		)
		on bFrzMulti pressed do
		(
			Freeze_Layers "multi"
		)
		
		on bTogPortal pressed do
		(
			Toggle_Layers "portals"
		)		
		
		on bTogPortal rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "portals"
		)
		on bFrzPortal pressed do
		(
			Freeze_Layers "portals"
		)
		
		on bTogDyn pressed do
		(
			Toggle_Layers "dynamic"
		)
		on bTogDyn rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "dynamic"
		)
		on bFrzDyn pressed do
		(
			Freeze_Layers "dynamic"
		)
		on bTogFlor pressed do
		(
			Toggle_Layers "floor"
		)
		on bTogFlor rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "floor"
		)
		on bFrzFlor pressed do
		(
			Freeze_Layers "floor"
		)
		on bTogIrr pressed do
		(
			Toggle_Layers "irradiance"
		)	
		on bTogIrr rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "irradiance"
		)	
		on bFrzIrr pressed do
		(
			Freeze_Layers "irradiance"
		)	
		on bTogRef pressed do
		(
			Toggle_Layers "ref"
			local oLayer = LayerManager.getLayerFromName "Bake_Mesh"
			oLayer.ishidden = false
		)	
		on bTogRef rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "ref"
			local oLayer = LayerManager.getLayerFromName "Bake_Mesh"
			oLayer.ishidden = false
		)	
		on bFrzRef pressed do
		(
			Freeze_Layers "ref"
			local oLayer = LayerManager.getLayerFromName "Bake_Mesh"
			oLayer.lock = true
		)
		on bTogDTL pressed do
		(
			Toggle_Layers "detail"
		)
		on bTogDTL rightclick do
		(
			Hide_MC_Layers ()
			Toggle_Layers "detail"
		)
		on bFrzDTL pressed do
		(
			Freeze_Layers "detail"
		)		
	)
	
--SUB SCENE CONFORMER
	rollout subSceneConform "Scene Conformer"
	(
		button bCleanScene "Conform Scene" width:24 height: 24  offset: [25,0]across: 5 tooltip:"Conform Scene"
		button bSetIgnore "IGN" width:24 height: 24  offset: [0,0] tooltip:"Set to ignore during Scene Conformer"
		button bRemoveUD "rIGN" width:24 height: 24  offset: [5,0] tooltip:"Do not ignore during Scene Conformer"
		button bMakeMulti "Make Multi" width:24 height: 24 offset: [20,0] Tooltip: "Make Multi"
		button bSuperLinker "Super Linker" width:24 height: 24  offset: [25,0] Tooltip:"Super Linker"
		on bCleanScene pressed do
		(
			Clean_Scene()
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
		on bMakeMulti pressed do 
		(
			createDialog floatObject 180 340
			SetDialogPos  floatObject [oMDCoords[1] + 180, oMDCoords[2] + 50]
			--SetDialogPos  floatObject [oMDCoords[1] + 5, oMDCoords[2] - 50 ]
		)
		on bSuperLinker pressed do 
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
		button bXform "X From Selected"  offset:[35,0] width:24 height:24 across:5 tooltip: "Xfrom"
		button bPivotBott "Pivot 2 Bottom" offset:[30,0]width:24 height:24 tooltip: "Pivot to Bottom"
		button bPivotSel "Pivot 2 Sel" offset:[20,0] width:24 height:24 tooltip: "Pivot to Selection"
		button bMergeSel "Merge Objs" offset:[23,0] width:24 height:24 tooltip: "Merge objects"
		button bExplode "Explode Objs" offset:[28,0]width:24 height:24  tooltip: "Explode Objects"

		
		button bIsolateLayer offset:[0,0]  width:24 height:24 tooltip: " Isolate Layer" across:5
		button bSetCollidable  offset:[0,0]width:24 height:24  tooltip: "Set object to Collidable"
		button bSetNonCollidable  offset:[0,0]width:24 height:24  tooltip: "Set object to non Collidable"
		button bFloored offset:[0,0] width:24 height:24  tooltip: "Move object to floor"
		button bDeleteEmpty offset:[0,0]width:24 height:24  tooltip: "Delete Empty nodes"
			
		 
		button bMake_Alpha offset:[0,0]  width:24 height:24 tooltip: " Make Alpha" across:5
		button bRemove_Alpha offset:[0,0]  width:24 height:24 tooltip: " Remove Alpha" 
		button bSel_Alpha offset:[0,0]  width:24 height:24 tooltip: " Select Alpha" 
		button bCreate_SC offset:[0,0]  width:24 height:24 tooltip: " Create Shadow Caster"
		button bSet_HD offset:[0,0]  width:24 height:24 tooltip: "Make Mesh HD" 
		button bSetBlueVColor offset:[0,0]  width:22 height:24 tooltip: "Set LM1_" across:6
		button bSetOrangeVColor offset:[0,0]  width:22 height:24 tooltip: "Set LM2_" 
		button bSetRedVColor offset:[0,0]  width:22 height:24 tooltip: "Set LM3 " 
		button bSelBlueVColor offset:[0,0]  width:22 height:24 tooltip: "Select Blue "
		button bSelOrangeVColor offset:[0,0]  width:22 height:24 tooltip: "Select Orange" 
		button bSelRedVColor offset:[0,0]  width:22 height:24 tooltip: "Select Red " 
		)
		button buvwSelected "Unwrap Selected " offset:[0,0]  width:150 tooltip: "" 
		group "Go to Bug"
		(
			edittext camTxt text:"" fieldWidth:120 offset: [-5,0]  across:2
			checkbox cb_LayerVis"" offset: [58,0] 
			button goToBugBttn "Go to the Bug"--across:2
		)
		group "Select Duplicats"
		(
			button bSelectDups "Select Dups" width:75 across:2
			checkbox cbSelected "Selection"  offset:[10,0]  checked:true 
		)

-- 		button bInsertAlpha "Insert \"alpha\" to Selected" width:(150) offset:[-5,0] 
-- 		button bSelAlpha "Select Alpha Objects" width:(150) offset:[-5,0] 
		button bimpObj "Import OBJ" width:(145/2)  offset:[-6,0] across:2
		button bexpObj "Export OBJ" width:(145/2)  offset:[7,0]
		


		on bXform pressed do 
		(	
			fileIn (MC4_Toolbar_Path + "Lib/fn_Reset_Xforms.ms")
		)		
		on bPivotSel pressed do 
		(	
			fileIn (MC4_Toolbar_Path + "Lib/fn_Pivot_To_Selected.ms")
		)
		on bPivotBott pressed do 
		(	
			fileIn (MC4_Toolbar_Path + "Lib/fn_Pivot_To_Bottom.ms")
		)
		on bIsolateLayer pressed do 
		(	
			fileIn (MC4_Toolbar_Path + "Lib/fn_isolate_room.ms")
		)		
		on  bSetCollidable pressed do 
		(	
			fileIn (MC4_Toolbar_Path + "Lib/fn_set_collidable.ms")
		)		
		on bSetNonCollidable pressed do 
		(	
			fileIn (MC4_Toolbar_Path + "Lib/fn_set_non_collidable.ms")
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
				try (
					oLayer = LayerManager.getLayerFromName unhideRoom
					oLayer.ishidden = false
				)
				catch ()

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
					fileIn (MC4_Toolbar_Path + "Lib/fn_Select_Duplicates.ms")
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
				fileIn (MC4_Toolbar_Path + "Lib/fn_Select_Duplicates.ms")
			)
		)
		on bMergeSel pressed do 
		(
			fileIn (MC4_Toolbar_Path + "Lib/fn_Snapshot_Selected.ms") 
		)
		on bExplode pressed do 
		(
			fileIn (MC4_Toolbar_Path + "Lib/fn_Explode_Selected.ms")
		)
		on bFloored pressed do
		(
			fileIn (MC4_Toolbar_Path + "Lib/fn_Selected_To_Floor.ms")
		)
		on bDeleteEmpty pressed do 
		(
			fileIn (MC4_Toolbar_Path + "Lib/fn_Delete_Empty_Nodes.ms")
		)		
		
		on bCreate_SC pressed do 
		(
			Make_Shadow_Caster()
			Set_UserDefined_Props "none"
		)
		
		on  bMake_Alpha pressed do 
		(
			Insert_Name "alpha"
		)
		on  bSet_HD pressed do 
		(
			Insert_Name "HD"
		)
		on  bSel_Alpha pressed do 
		(
			select $*alpha*
			local oSel = selection as array
			for obj in oSel do
			(
				if (obj.ishidden ==  true)  then
				(
					deselect obj
				)
			)

		)		
		on  bRemove_Alpha pressed do 
		(
			Del_Prefix  "alpha"
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
			
			fileIn (MC4_Toolbar_Path + "/Lib/multi_unwrap.ms")

		)
		on bvcBlack pressed do
		(
			Set_Vertex_Color (color 0 0 0)
		)
		on bimpObj pressed do 
		(
			fileIn (MC4_Toolbar_Path + "Lib/fn_Import_Obj.ms")
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
		on bexpObj pressed do 
		(
			fileIn (MC4_Toolbar_Path + "Lib/fn_Export_Obj.ms")
		)
	)
-- VERTEX COLORING TOOLS
	rollout VertexColorTools "Vertex Color Tools"
	(
		bitmap the_bmp fileName:(working_dir  + "img/GL_gradient.bmp") offset:[-5,0]
		slider BW_Slider "" orient:#horizontal type:#integer ticks:0 range:[0,255,128]  
		colorpicker clr_PickedColor color:[250, 245, 230] modal:false width:100 height:24 across:2
		button btn_ColorPicker offset:[20,0]  width:22 height:24 tooltip: "Set Vertex Color" 
		Button vColorist "Vertex Colorist" width:128
		
		on btn_ColorPicker pressed do
		(
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
		)
		on vColorist pressed  do
		(
			fileIn (MC4_Toolbar_Path + "Lib/LM2VC.ms")
		)
		on VertexColorTools close do
		(
			clearSelection()
		)
	)
	--EXPORT TOOL
	rollout subExportTools "Game Object Export"
	(
				
		on chk_Light changed checked do ( chk_Light_checked = checked )
		on chk_Dynamic changed checked do ( chk_Dynamic_checked = checked )
		on chk_Irradiance changed checked do ( chk_Irradiance_checked = checked )
		
-- 		button exportDecor  "Export To Game" width:110 across:2 offset:[5,0]
-- 		button bBuildGui "GUI" width:30 offset:[23,0]

		button exportBase  "Export Base" width:70 offset:[10,0] across:2
		checkbox chk_Make "Make" checked:false offset:[20,5]
		button exportFloor "Export Floor" width:120

		checkbox chk_Light checked:false offset:[15,0]across:3
		checkbox chk_Dynamic checked:false offset:[15,0]
		checkbox chk_Irradiance checked:false offset:[15,0]
		label lab1 "Light" offset:[0,-5] across:3
		label lab2 "Dynamic" offset:[0,-5]
		label lab3 "Irrad" offset:[0,-5]
-- 	
		button exportChkd "Export Checked" width:120
		
		on exportBase pressed do
		(	

			chk_Base_checked = true
			chk_Floor_checked = false
			chk_Light_checked = false
			chk_Dynamic_checked = false
			chk_Irradiance_checked = false
			
			
			oLayerVis = Get_Layer_Visibility()
			unhide geometry doLayer:True
			for i =  1 to LayerManager.count do 
			(
				layerM = LayerManager.getLayer (i-1)-- The only right thing about maxscript
				tokens = filterString layerM.name "_"
				if tokens[1] != "room" and tokens[1] != "portals" and tokens[1] != "multi"and tokens[1] != "detail"and tokens[1] != "@"  then 
				(
					layerM.ishidden = true
				)
				else
				(
					layerM.ishidden = false
				)
			)
			doSaveFile()
			doExport false false

			Set_Layer_Visibility oLayerVis[1] oLayerVis[2] 
 			 if chk_Make.state == true then 
			(
			local scrDir = "M:\\make\\"
			local maxName = maxFileName 
			local  tokens  = filterstring maxName "."
			DOSCommand ("cd " + scrDir  + "&& make.bat")
			DOSCommand ("cd M:\\_builds\\" + "&& iFPSD.exe " + (tokens[1] + "_lvl") + " -nogp")
			 )

		)	
			
		on exportFloor pressed do
		(	
			chk_Base_checked = false
			chk_Floor_checked = true
			chk_Light_checked = false
			chk_Dynamic_checked = false
			chk_Irradiance_checked = false
			
			
			oLayerVis = Get_Layer_Visibility()
			unhide geometry doLayer:True
			
			for i =  1 to LayerManager.count do 
			(
				layerM = LayerManager.getLayer (i-1)-- The only right thing about maxscript
				tokens = filterString layerM.name "_"
				if tokens[1] != "floor" then 
				(
					layerM.ishidden = true
				)
				else
				(
					layerM.ishidden = false
				)
			)
			doSaveFile()
			doExport false false
			Set_Layer_Visibility oLayerVis[1] oLayerVis[2] 
			
			 if ( chk_Make.state == true ) then 
 			(
				-- doExport true true --will make bat and run the game
				local scrDir = "M:\\make\\"
				local maxName = maxFileName 
				local  tokens  = filterstring maxName "."
				DOSCommand ("cd " + scrDir  + "&& make.bat")
				DOSCommand ("cd M:\\_builds\\" + "&& iFPSD.exe " + (tokens[1] + "_lvl") + " -nogp")
 			 )

		)

		on exportChkd pressed do
		(
			clearlistener()
			chk_Base_checked = false
			chk_Floor_checked = false
			chk_Light_checked = false
			chk_Dynamic_checked = false
			chk_Irradiance_checked = false
			-- get states			
			if ( chk_Light.state == true ) then 
			(
				chk_Light_checked = true
			)
			if ( chk_Dynamic.state == true ) then
			(
				chk_Dynamic_checked = true
			)
			if ( chk_Irradiance.state == true) then
			(
				chk_Irradiance_checked = true
			)
			if ( chk_Light.state == false and chk_Dynamic.state == false and chk_Irradiance.state == false  ) then 
			(
				Messagebox "Select at least one of the checkboxes to export"
			)
			else
			(
				
				-- get layer state
				oLayerVis = Get_Layer_Visibility()
				-- hide all layers
				for i =  1 to LayerManager.count do 
				(
					layerM = LayerManager.getLayer (i-1)-- The only right thing about maxscript
					layerM.ishidden = true
				)

				if chk_Light_checked == true then
				(
					LL = LayerManager.getLayerFromName "irradiance"
					if LL != undefined then 
					(
						LL.ishidden = false
					)
					else
					(
						chk_Light_checked = false
						print  ("\nLIGHTS\nNo layer by the name of irradiance exists.\nThis is where all the export lights go.\nPlease run scene conformer or check your layers.\nNot exporting Lights");
					)
				)
				
				if chk_Dynamic_checked == true then
				(
					LatDyn =LayerManager.getLayerFromName "dynamic"
					--LatLight =LayerManager.getLayerFromName "lights"

					if LatDyn == undefined  then 
					(
						chk_Dynamic_checked = false
						print ("\nDYNAMICS\nNo layer by the name of dynamic exists\nNot exporting  Dynamics");
					)
					else
					(
						LatDyn.ishidden = false
	-- 						LatLight.ishidden = false	
					)
				)
				
				if chk_Irradiance_checked == true then
				(
					LL =LayerManager.getLayerFromName "irradiance"
					if LL != undefined then 
					(
						LL.ishidden = false
					)
					else
					(
						chk_Irradiance_checked = false
						print ("\nIRRADIANCE\nNo layer by the name of irradiance in layer manager.\nRun scene conformer\nNot exporting Irradiance\n");
					)
				)
				if  ( chk_Light_checked == false and chk_Dynamic_checked == false and chk_Irradiance_checked == false ) then
				(
					doSaveFile()
					doExport false false
					messagebox "Nothing to export \n See Listener"
					Set_Layer_Visibility oLayerVis[1] oLayerVis[2] 
				)
				else
				(

				doSaveFile()
				doExport false false
				Set_Layer_Visibility oLayerVis[1] oLayerVis[2] 
				)
			)
		)
	)
	--MAIN DIALOG
	rollout MC4_ToolsDiag "Gameloft Tools"
	(
		SubRollout mySubRollout width:170 height:900 align:#center
		
		on MC4_ToolsDiag open do
		(
			oPosStr = filterString (getINISetting iniFile "GL_Tools"  "LMD_Position") "[,],\,"
			oMDCoords = [oPosStr[1] as integer, oPosStr[2] as integer]
			global RO_Prefab = (getINISetting iniFile "GL_Tools"  "RO_Prefab") 
			global RO_Toggle_Layer = (getINISetting iniFile "GL_Tools"  "RO_Toggle_Layer")
			global RO_Scene_Conform = (getINISetting iniFile "GL_Tools"  "RO_Scene_Conform") 
			global RO_LevelEd_Tools = (getINISetting iniFile "GL_Tools"  "RO_LevelEd_Tools") 
			global RO_VertexColor_Tools = (getINISetting iniFile "GL_Tools"  "RO_VertexColor_Tools") 
			global RO_Exporter_Tools = (getINISetting iniFile "GL_Tools"  "RO_Exporter_Tools") 
			-- users can adjust these setting manually as well by editing the 
			--%UserProfile%\AppData\Local\Autodesk\3dsMax\2012 - 64bit\enu\plugcfg\Game_Loft_Tools.ini
			MC4_Toolbar_Path = getINISetting iniFile "GL_Tools"  "MC4_Toolbar_Path"
			GL_Art_Path    = getINISetting iniFile "GL_Tools"  "GL_Art_Path"	
-- 			MC4_Toolbar_Path = getINISetting iniFile "GL_Tools"  "MC4_Toolbar_Path"
-- 			GL_Art_Path    = getINISetting iniFile "GL_Tools"  "GL_Art_Path"	
			
		)
		on MC4_ToolsDiag moved pos do
		(
			oMDCoords = GetDialogPos MC4_ToolsDiag
		)
		on MC4_ToolsDiag close do
		(
			sysInfo.username
			setINISetting iniFile "GL_Tools"  "LMD_Position"  (oMDCoords as string)
			
-- 			MC4_Toolbar_Path		= subToolSettings.GL_Tools_TXT.text
-- 			GL_Art_Path			= subToolSettings.GL_Art_TXT.text
			setINISetting iniFile "GL_Tools"  "MC4_Toolbar_Path"  (MC4_Toolbar_Path as string)
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

		createDialog MC4_ToolsDiag width:170  style:#(#style_sysmenu,#style_titlebar,#style_minimizebox,#style_resizing) 
		SetDialogPos  MC4_ToolsDiag [oMDCoords[1] , oMDCoords[2]]
-- 		cui.RegisterDialogBar MC4_ToolsDiag style:#(#cui_handles,#cui_floatable,#cui_dock_all )
-- 		cui.DockDialogBar MC4_ToolsDiag #cui_dock_left
-- 		if MC4_Toolbar_Path  == "" then
-- 		(
-- 			MC4_Toolbar_Path = getSavePath caption:"Tools Directory" initialDir:"C:\\Program Files\\Autodesk\\3ds Max 2012\\Scripts\\"
-- 			MC4_Toolbar_Path =  "M:\\"
-- 		)
		-- Gets the Set_UserDefined_Props function from Lightmap tool
-- 		fileIn ("M:/tools/3dsmax/LightMapper/Lib/fn_Set_UserDefined_Props.ms")
		
		iconFile = MC4_Toolbar_Path + "img/MC4_Toolbar_24i.bmp"
-- 		clearlistener()
-- 		print iconFile
		icoBitmap = openBitmap iconFile
		icoCount = case icoBitmap.height of
									 (
										  24: icoBitmap.width/24
										  default: icoBitmap.width/16
									 ) 
		
-- 		AddSubRollout MC4_ToolsDiag.mySubRollout subToolSettings rolledUp: (true)
		AddSubRollout MC4_ToolsDiag.mySubRollout subPrefabs rolledUp: (RO_Prefab as booleanClass )
-- 			subToolSettings.GL_Tools_TXT.text = MC4_Toolbar_Path
-- 			subToolSettings.GL_Art_TXT.text = GL_Art_Path
		AddSubRollout MC4_ToolsDiag.mySubRollout subLayerTgl 			rolledUp: (RO_Toggle_Layer as booleanClass)
		AddSubRollout MC4_ToolsDiag.mySubRollout subSceneConform rolledUp: (RO_Scene_Conform as booleanClass)
		AddSubRollout MC4_ToolsDiag.mySubRollout subLevelEdTools rolledUp: (RO_LevelEd_Tools as booleanClass )
		AddSubRollout MC4_ToolsDiag.mySubRollout VertexColorTools rolledUp: (RO_VertexColor_Tools as booleanClass)
		AddSubRollout MC4_ToolsDiag.mySubRollout subExportTools rolledUp: (RO_Exporter_Tools as booleanClass )
		--add icons to buttons
		subSceneConform.bCleanScene.images 			= #(iconFile, undefined, icoCount,11,11,1,1, false, true)
		subSceneConform.bSetIgnore.images 			= #(iconFile, undefined, icoCount,25,25,1,1, false, true)
		subSceneConform.bRemoveUD.images 			= #(iconFile, undefined, icoCount,26,26,1,1, false, true)
 		subSceneConform.bMakeMulti.images 			= #(iconFile, undefined, icoCount,14,14,1,1, false, true)
		subSceneConform.bSuperLinker.images 		= #(iconFile, undefined, icoCount,13,13,1,1, false, true)

		subLevelEdTools.bXform.images 				= #(iconFile, undefined, icoCount,4,4,1,1, false, true)
		subLevelEdTools.bPivotBott.images 			= #(iconFile, undefined, icoCount,2,2,1,1, false, true)
		subLevelEdTools.bPivotSel.images 			= #(iconFile, undefined, icoCount,3,3,1,1, false, true)
		subLevelEdTools.bMergeSel.images 			= #(iconFile, undefined, icoCount,5,5,1,1, false, true)
		subLevelEdTools.bExplode.images 			= #(iconFile, undefined, icoCount,6,6,1,1, false, true)
		subLevelEdTools.bIsolateLayer.images 		= #(iconFile, undefined, icoCount,1,1,1,1, false, true)
		subLevelEdTools.bSetCollidable.images 		= #(iconFile, undefined, icoCount,7,7,1,1, false, true)
		subLevelEdTools.bSetNonCollidable.images 	= #(iconFile, undefined, icoCount,8,8,1,1, false, true)
		subLevelEdTools.bFloored.images 				= #(iconFile, undefined, icoCount,10,10,1,1, false, true)
		subLevelEdTools.bDeleteEmpty.images 		= #(iconFile, undefined, icoCount,9,9,1,1, false, true)
		subLevelEdTools.bCreate_SC.images 			= #(iconFile, undefined, icoCount,18,18,1,1, false, true)
		subLevelEdTools.bMake_Alpha.images 			= #(iconFile, undefined, icoCount,15,15,1,1, false, true)
		subLevelEdTools.bRemove_Alpha.images 		= #(iconFile, undefined, icoCount,17,17,1,1, false, true)
		subLevelEdTools.bSel_Alpha.images 			= #(iconFile, undefined, icoCount,16,16,1,1, false, true)
		subLevelEdTools.bSet_HD.images 				= #(iconFile, undefined, icoCount,27,27,1,1, false, true)
		subLevelEdTools.bSetBlueVColor.images 		= #(iconFile, undefined, icoCount,19,19,1,1, false, true)
		subLevelEdTools.bSetOrangeVColor.images 	= #(iconFile, undefined, icoCount,20,20,1,1, false, true)
		subLevelEdTools.bSetRedVColor.images 		= #(iconFile, undefined, icoCount,21,21,1,1, false, true)
		subLevelEdTools.bSelBlueVColor.images 		= #(iconFile, undefined, icoCount,22,22,1,1, false, true)
		subLevelEdTools.bSelOrangeVColor.images 	= #(iconFile, undefined, icoCount,23,23,1,1, false, true)
		subLevelEdTools.bSelRedVColor.images 		= #(iconFile, undefined, icoCount,24,24,1,1, false, true)
		
		VertexColorTools.btn_ColorPicker.images 	= #(iconFile, undefined, icoCount,28,28,1,1, false, true)
		
		subLayerTgl.bFrzRooms.images 				= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzMulti.images 				= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzPortal.images 				= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzDyn.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzFlor.images 				= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzIrr.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzRef.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzDTL.images 					= #(iconFile, undefined, icoCount,12,12,1,1, false, true)
		subLayerTgl.bFrzLghts.images 				= #(iconFile, undefined, icoCount,12,12,1,1, false, true)

	)
)


