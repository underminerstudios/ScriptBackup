-- This script looks for objects called Layer* and then animates them according to the Zdepth of the asset
--Updated by: Karl Kent


(
	Global  ParallaxSettings
	try(destroyDialog ParallaxSettings)catch()
	
Rollout ParallaxSettings "Parallax Tools"
(
	--filter selection for Layer assets or gets them
	fn GetAssetArray =
	(
			--gets Xref nodes
		refObjs = for o in objects where ((classof o ) == XRefObject) collect o
		local refParents = #()
		
		for refObj in refObjs do  --go through each noode in a loop and check conditionals
		(
			if (refObj.parent == undefined) then --checks there is a parent
			(
				MessageBox ("The following Obj doesnt have a layer Parent: " + refObj.name)
			)
			else
			(
				if ((superClassof refObj.parent)  == helper) then --checks parent is a helper
				(
					if (matchpattern refObj.parent.name Pattern: "Layer*" ignoreCase: true) then  --checks parent is Named correctly
					(
						if (findstring  (tolower refObj.parent.name) "end" == undefined ) then --filters helpers so it is not a "end" by mistake
						(
						append refParents refobj.Parent
						)
						else 
						(
							MessageBox ("you have a " + refObj.parent.name + " as a parent node")
						)
					)
					else
					(
						messagebox ("There is a Layer helper named incorrectly: " + refObj.parent.name)
					)
				)
				else
				(
				messagebox ("This Layer helper, is not a helper object: " + refObj.parent.name)
				)
			)
		)
		thenodes = makeUniqueArray refParents
		return thenodes
	)
	
		
	-- Parses the layer objects name and returns the speed from it.
	fn GetLayerSpeed obj maxDepth=
	(
		--Speed derived by screen Length by obj Y position
		Local speedVal 
		objPos = (in coordsys world obj.pos.y)
		if (objPos  > maxDepth) then 
		(
			speedVal = 0
		)
		else
		(
		speedVal = (maxDepth - objPos ) * -1 
		)
		return speedVal
	)

	fn removeAnimation = 
	(
		slidertime = 0
		deleteKeys $Layer* #allKeys
	)
	
	fn writeTransformUserProp userNode =
	(

		if (isvalidNode userNode) then 
		(
			setuserProp userNode "position" (userNode.pos / 10)
			setuserProp userNode "rotation" (userNode.rotation as eulerangles)
			setuserProp userNode "scale" (userNode.scale)
		)
		
	)
	
userNode = $
	fn AnimateLayers	AnimNodeList =
	(

		local maxY = 1536
		
		select Objects
		maxY = selection.max.y
		max select none
		
		for i =1 to AnimNodeList.Count do
		(
			speed = GetLayerSpeed AnimNodeList[i] maxY
			startPos = AnimNodeList[i].pos
			endPos = AnimNodeList[i].pos
			endPos.x =  endPos.x + speed -- (animationRange.end - animationRange.start)
			
			with animate on
			( 
				at time animationRange.start AnimNodeList[i].pos = startPos
				at time animationRange.end AnimNodeList[i].pos = endPos
			)
			
			keyList = AnimNodeList[i].track[1].pos.x_position.controller.keys
			

			-- Make all of the animation keys linear
			for j = 1 to keyList.count do
			(
				keyList[j].inTangentType = #linear
				keyList[j].outTangentType = #linear
			)
			
			--set animation curve to repeat past current timeLine based on current speed
			setbeforeORT AnimNodeList[i].pos.x_position.controller #relativeRepeat
			setafterORT AnimNodeList[i].pos.x_position.controller #relativeRepeat
		)
	)
		
	Fn GetEndpoint NodeArray = 
	(
		--get children bounds and mark end Point
		local hasEnd = false
		for i = 1 to NodeArray.count do (
			for r = 1 to Nodearray[i].children.count do 
			(
				if (iskindof Nodearray[i].Children[r]  helper) and ((findstring (tolower Nodearray[i].children[r].name ) "end") != undefined) then 
				(
					hasEnd = true
				)
			)
		)
		return hasEnd
	)
	
	fn SetEndpoint NodesParents = 
	(
		for NodesParent in NodesParents do 
		(
			if (NodesParent.children.count > 1) then 
			(
				local LastChild =  NodesParent.children[1]
			
				for l = 1 to  NodesParent.children.count  do 
				(
					if (NodesParent.children[l].pos.x > LastChild.pos.x) then
					(
						LastChild =  NodesParent.children[l]
					)
				)
			Endpoint = point pos: [LastChild.max.x,0,0]  parent: NodesParent name: (NodesParent.Name +"End")
			)
			else
			(
				MessageBox ("This Asset has no children: " + NodesParent.name)
			)
		)
	)
	
	Fn TagGroundLayer ground =
	(
		AllLayers = GetAssetArray ()
		for i = 1 to AllLayers.count do --lopp through all layer nodes and Tag ground as false
		(
			SetUserProp AllLayers[i] "isGround" false
		)
		SetUserProp Ground "isGround" true -- rewrite ground layer node's Tag as true
	)
	
	Fn GetGroundLayer =
	(
		if selection.count > 0 then 
		(
			if Selection.count < 2 then 
			(
				if ((superClassof Selection[1]) == Helper ) and (matchpattern Selection[1].name Pattern: "Layer*" ignoreCase: true) then  --In case they grab the ground layer Helper 
				(
					TagGroundLayer Selection[1]
				)
				else 
				(	
					theGround = For obj in selection where ((Superclassof obj == GeometryClass) and (classof obj != BoneGeometry)) collect obj --in case the grab the gorund layer Mesh
					if (theGround.count > 0 ) then 
					(
						if (isvalidnode theGround[1]) then 
						(
						
							if (theGround[1].parent != undefined ) and ((superClassof theGround[1].parent ) == Helper ) and (matchpattern theGround[1].parent.name Pattern: "Layer*" ignoreCase: true) then 
							(
							TagGroundLayer theGround[1].parent
							)
							else
							(
								MessageBox "Current Selected Object has an invalid Layer Node parent. \n Please Check parenting of Node and node parents name/type."
							)
						)
					)
					else
					(
						MessageBox "Current Selected Object is an Invalid type of asset"
					)
				)
			)
			else
			(
				MessageBox "Too many Objects currently selected"
			)
		
		)
		else
		(
			MessageBox "Please Select a Mesh to tag as the Ground Layer"
		)
	)
	
	Fn WriteNodeInfo Nodelist  = 
	(
		Local childrenNodes = #() --deletion nodes
		Local maxY = 1536 --scene depth default
		
		select Objects
		maxY = selection.max.y -- set scene Depth
		max select none
		
		--filter  throughthe layer objects and place nodes wher ethey are located with the specific xref obj info in the user props
		for i = 1 to nodeList.count do 
		(
			speed = GetLayerSpeed nodeList[i] maxY
			setUserProp nodeList[i] "Speed" Speed
			writeTransformUserProp nodeList[i]
			--set asset/texture info for each node
			 for c = 1 to nodelist[i].children.count do 
			 (
				 if ((ClassOf  nodelist[i].children[c] ) == XRefObject ) then
				 (
				SpawnNode = Point pos: nodelist[i].children[c].pos
				 SpawnNode.parent = NodeList[i]
				 --SpawnNode.Name =  NodeList[i].name
				 
				 SetUserProp (SpawnNode) "File"  (getfilenamefile nodelist[i].children[c].fileName)
				writeTransformUserProp nodelist[i].children[c]
				append ChildrenNodes nodelist[i].children[c]
				)
				else
				(
					if ((superclassof NodeList[i].Children[c]) != helper ) then --skips the "layer##end node
					(
						Messaage ("A layer has a child that is not an Xreference: " + nodelist[i].children[c].name)
					)
				)
			)	
		)
		
		for n = 1 to ChildrenNodes.count do 
		(
			print (ChildrenNodes[n].name  +" Was Deleted for export") as string
			delete ChildrenNodes[n]
		)
		
	)


	Button animateLayers_btn "Animate Layers" width: 110 height: 20 align: #Center
	Button ClearUserProps_btn "Clear User Props" width: 110 height: 20 align: #Center
	Button IsGround_btn "Tag Ground Layer" width: 110 height: 20 align: #Center
	Button CreateExportNodes_btn "Export Setup" width: 110 height: 20 align: #Center
	Button FetchScene_btn "Fetch Scene" width: 110 height: 20 align: #Center



	
	On animateLayers_btn pressed do
	(
	nodeList = GetAssetArray()
	AnimateLayers nodelist
	)
	
	on ClearUserProps_btn pressed do 
	(
		if (queryBox  "Are you sure you want to Clear the User Properties?" beep: true) then 
		(
			for obj in objects do 
			(
				if ((getuserpropBuffer obj ) != undefined ) then 
				(
					setUserPropBuffer obj ""
				)
			)
		)
	)
	
	On IsGround_btn pressed  do 
	(
		GetGroundLayer ()
	)
	
	On CreateExportNodes_btn pressed do
	(
		HoldMaxfile ()
		nodeExportList = GetAssetArray()
		removeAnimation ()
		WriteNodeInfo nodeExportList

	)
	
	On FetchScene_btn pressed do
	(
		fetchMaxfile quiet: false
	)
)--rollout end
	createDialog ParallaxSettings width: 120
)