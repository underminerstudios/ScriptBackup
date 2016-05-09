fn findthenode theNode =
(
	for i=0 to (LayerManager.count - 1) do
	(
		(LayerManager.getLayer i).nodes &thenodes
		for n in thenodes do
		(
			if n == theNode do
			(
				return i
			)
		)
	)
)

fn rotateToTarget obj targetObjPos =
(
	obj.dir = normalize (targetObjPos - obj.pos)
	local rotMatrix = (inverse (obj.rotation as matrix3))
	local newMatrix = obj.transform
		newMatrix.row1 = normalize rotMatrix.row3
		newMatrix.row2 = normalize rotMatrix.row1
		newMatrix.row3 = normalize rotMatrix.row2
	obj.transform = newMatrix
)

fn getNormalVert theMesh theVert =
(
	local vertFaces = polyOp.getFacesUsingVert theMesh theVert
	local tNormal = [0,0,0]; for i in vertFaces do tNormal += polyOp.getFaceNormal theMesh i
	local t01 = tNormal / vertFaces.numberSet
	return t01
)

try(destroyDialog dlg_net_anim)catch()
rollout dlg_net_anim "Net Anim"
(
	
	button btn_retarget "Retarget selected"
	
	on btn_retarget pressed do
	(
		local theSkinnedMesh = selection[1]
		local theSkin = theSkinnedMesh.modifiers[1]
		local theBones = for o in objects where (refs.dependencyLoopTest theSkin o) AND (classof o == Point) collect o
		
		local theLayer = findthenode theSkinnedMesh
		local thenodes
		(LayerManager.getLayer theLayer).nodes &thenodes
		local theMesh = for n in thenodes where n.name == "net_physicalized" do exit with n
			
		local theEditPolyMod = EditPolyMod()
		addModifier theMesh theEditPolyMod
		
			
		local thePointNames = #(;
		#("net_Point_02","net_Point_03","net_Point_04","net_Point_05","net_Point_06","net_Point_07"),;
		#("net_Point_08","net_Point_09","net_Point_10","net_Point_11","net_Point_12"),;
		#("net_Point_13","net_Point_14","net_Point_15","net_Point_16","net_Point_17","net_Point_18"),;
		#("net_Point_19","net_Point_20","net_Point_21","net_Point_22","net_Point_23"),;
		#("net_Point_24","net_Point_25","net_Point_26","net_Point_27","net_Point_28","net_Point_29");
		)
		
		local theUberPoint = theBones[1]
	
		
		for j=0 to animationrange.end do
		(
			at time j
			(
				with animate on
				(
					theUberPoint.rotation = theMesh.rotation
					theUberPoint.pos = polyop.getVert theMesh 1
				)
			)
		)
		
		for n in thePointNames do
		(
			for i=1 to n.count do
			(

				local thePoint = for m in theBones where (m.name == n[i]) do exit with m
				local theIndex = (filterstring thePoint.name "_")[3] as integer
				for j=0 to animationrange.end do
				(
					at time j
					(
						local theVert = polyop.getVert theMesh theIndex
						local theTargetVert = [0.0,0.0,0.0]
						if i==n.count then
						(
							theTargetVert = polyop.getVert theMesh (theIndex - 1)
						)
						else
						(
							theTargetVert = polyop.getVert theMesh (theIndex + 1)
						)
						with animate on
						(
							thePoint.pos = theVert
							rotateToTarget thePoint theTargetVert
						)
					)
				)
			)
		)
		
		deleteModifier theMesh theMesh.modifiers[1]
	)
	
)
createDialog dlg_net_anim

/*


(
	local theMesh = selection[1]
	
	local thePointNames = #(;
	#("net_Point_02","net_Point_03","net_Point_04","net_Point_05","net_Point_06","net_Point_07"),;
	#("net_Point_08","net_Point_09","net_Point_10","net_Point_11","net_Point_12"),;
	#("net_Point_13","net_Point_14","net_Point_15","net_Point_16","net_Point_17","net_Point_18"),;
	#("net_Point_19","net_Point_20","net_Point_21","net_Point_22","net_Point_23"),;
	#("net_Point_24","net_Point_25","net_Point_26","net_Point_27","net_Point_28","net_Point_29");
	)
	
	local theUberPoint = for m in helpers where (m.name == "net_Point_01") do exit with m
	
	for j=0 to animationrange.end do
	(
		at time j
		(
			with animate on
			(
				theUberPoint.rotation = theMesh.rotation
				theUberPoint.pos = polyop.getVert theMesh 1
			)
		)
	)
	
	for n in thePointNames do
	(
		for i=1 to n.count do
		(

			local thePoint = for m in helpers where (m.name == n[i]) do exit with m
			local theIndex = (filterstring thePoint.name "_")[3] as integer
			for j=0 to animationrange.end do
			(
				at time j
				(
					local theVert = polyop.getVert theMesh theIndex
					local theTargetVert = [0.0,0.0,0.0]
					if i==n.count then
					(
						theTargetVert = polyop.getVert theMesh (theIndex - 1)
					)
					else
					(
						theTargetVert = polyop.getVert theMesh (theIndex + 1)
					)
					with animate on
					(
						thePoint.pos = theVert
						rotateToTarget thePoint theTargetVert
					)
				)
			)
		)
	)
)