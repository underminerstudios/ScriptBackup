(

	fn DrawLine pointA pointB =
	(
		ss = SplineShape pos:pointA
		addNewSpline ss
		addKnot ss 1 #corner #line PointA
		addKnot ss 1 #corner #line PointB
		updateShape ss
	)

	fn getObjectsRadius oSel =
	(
		xPosArr = #()
		yPosArr = #()
		zPosArr = #()
		for obj in oSel do
		(
			if (classof obj != Editable_mesh) then
			(
				convertTo obj TriMeshGeometry

			)
			
			verts = meshop.getNumVerts obj;
			for vert=1 to verts do
			(
				vertPos = meshop.getVert obj vert
				append xPosArr ((vertPos[1]))
				append yPosArr ((vertPos[2]))
				append zPosArr ((vertPos[3]))
			)
		)
		xPosArr = sort(xPosArr)
		yPosArr = sort(yPosArr)
		zPosArr = sort(zPosArr)
		
		xAverage = (xPosArr[1] + xPosArr[xPosArr.count])/2
		yAverage = (yPosArr[1] + yPosArr[yPosArr.count])/2
		zAverage = (zPosArr[1] + zPosArr[zPosArr.count])/2

		_center = [xAverage, yAverage, zAverage]
		_min = [xPosArr[1], yPosArr[1], zPosArr[1] ] 
		_length = distance _center _min
		radius = _length - (_length * 0.2)
		return #(radius, _center)

	)
	
	rollout SpherizeNormals "Spherize Normals" width:160
	(

		
		button bnt_SpherizeNormals "Spherize Normals" width:140 align:#left

		label sntCurrentVertLabel "[Idle]" align:#left
		progressbar sntCurrentVertProgress color:(color 0 100 240) 

		
		on bnt_SpherizeNormals pressed  do
		(
			
			oSel = selection as array
			max modify mode
			subObjectLevel = 0
			xStart = timestamp()

			-- Setup the reference object
-- 			thisPickObject = refPick.object
			volumeData = getObjectsRadius oSel
			volumeSphere = Sphere radius:volumeData[1] segs:12 pos:volumeData[2]
			editNormalsMod = Edit_Normals()
			editNormalsMod.ignoreBackfacing = on
			addmodifier volumeSphere editNormalsMod
			
			thisPickObject = volumeSphere

			
			refTransform = thisPickObject.objecttransform
			select thisPickObject
			thisPickObjectEditNormals = thisPickObject.modifiers[#Edit_Normals].EditNormalsMod
			thisPickObjectEditNormals.Unify()
			thisPickObjectEditNormals.MakeExplicit()
			refNumVerts = thisPickObjectEditNormals.GetNumVertices()
			
-- 			format "Ref object : % (numVerts : %)\n" thisPickObject.name refNumVerts

			-- Create lookup tables for the reference object
			sntCurrentVertLabel.caption = "Creating ref object LUT"
			sntCurrentVertProgress.value = 0
			refVertIDtoPos = #()
			refVertIDtoNormID = #()
			refNormIDtoNorm = #()
			for vert = 1 to refNumVerts do
			(
				-- Map vertID to vert position
				refVertIDtoPos[vert] = (thisPickObjectEditNormals.GetVertex vert) * refTransform

				-- Map vertID to normalID
				normal_array = #{}
				thisPickObjectEditNormals.ConvertVertexSelection #{vert} normal_array
				normal_result = normal_array as array
				normID = normal_result[1]
				refVertIDtoNormID[vert] = normID
				
				-- Map normalID to normal
				refNormIDtoNorm[normID] = thisPickObjectEditNormals.Getnormal normID
				
				-- Update progress
				sntCurrentVertProgress.value = 100.*vert/refNumVerts
			)
-- 			suspendediting()
			for obj in oSel do
			(
				-- Setup the current selection object
				addmodifier obj editNormalsMod
				thisSelObject = obj
				objTransform = thisSelObject.objecttransform
				select thisSelObject
				thisSelObjectEditNormals = thisSelObject.modifiers[#Edit_Normals].EditNormalsMod
				thisSelObjectEditNormals.Unify()
				thisSelObjectEditNormals.MakeExplicit()
				objNumVerts = thisSelObjectEditNormals.GetNumVertices()
				
-- 				format "Sel object : % (numVerts : %)\n" thisSelObject.name objNumVerts

				-- Create lookup tables for the selected object
				sntCurrentVertLabel.caption = "Creating target obj LUT"
				sntCurrentVertProgress.value = 0
				objVertIDtoPos = #()
				objVertIDtoNormID = #()
				objNormIDtoNorm = #()
				for vert = 1 to objNumVerts do
				(
					-- Map vertID to vert position
					objVertIDtoPos[vert] = (thisSelObjectEditNormals.GetVertex vert) * objTransform

					-- Map vertID to normalID
					normal_array = #{}
					thisSelObjectEditNormals.ConvertVertexSelection #{vert} normal_array
					normal_result = normal_array as array
					normID = normal_result[1]
					objVertIDtoNormID[vert] = normID
					
					-- Map normalID to normal
					objNormIDtoNorm[normID] = thisSelObjectEditNormals.Getnormal normID
					
					-- Update progress
					sntCurrentVertProgress.value = 100.*vert/objNumVerts
				)
				
				-- Loop through the verts in the selected object
				sntCurrentVertLabel.caption = "Current Vert:"
				sntCurrentVertProgress.value = 0
				for x=1 to objNumVerts do
				(
					-- Get the position of the vert in the selected mesh
					cb = objVertIDtoPos[x]

					menordist = 9999999999
					-- Initialise a couple of things
					normalt = [0,0,0]
					
					saveI = 0
					
					-- Loop through the verts in the reference object
					for vert=1 to refNumVerts do
					(
						-- Get the position of the vert in the reference mesh
						ct = refVertIDtoPos[vert]
						
						-- Calculate its distance from the vert in the selected mesh
						offset = cb - ct
						dist = length offset

						-- Is it closer than the last closest one?
						if dist < menordist then
						(
							menordist = dist
							
							-- Get the NormalID corresponding to this reference vert, and use it to look up the actual normal
							normID = refVertIDtoNormID[vert] 
							normalt = refNormIDtoNorm[normID]
							saveI = vert
						)
					)
					
					-- Draw a debug line
					--DrawLine objVertIDtoPos[x] refVertIDtoPos[saveI]
					
					-- Get the NormalID corresponding to this selecion vert, and use it to set the actual normal
					normID = objVertIDtoNormID[x]
					thisSelObjectEditNormals.SetNormal normID normalt

					-- Update the progress bar
					sntCurrentVertLabel.caption = "Current Vert:" + (x as string) + "/" + (objNumVerts as string)
					sntCurrentVertProgress.value = 100.*x/objNumVerts
				)
				maxOps.CollapseNodeTo obj 1 off
			)
-- 			resumeediting()
			sntCurrentVertLabel.caption = "[Idle]"
			sntCurrentVertProgress.value = 0
			
			xEnd = timestamp()
			format "Spherized normals in % seconds\n" ((xEnd - xStart) / 1000.0)
			delete(volumeSphere)
			select (oSel)
		)
	)

	-- Kill any existing instances of the tool and make a new one
	try(destroyDialog SpherizeNormals)catch()
	createDialog SpherizeNormals style:#(#style_toolwindow, #style_sysmenu) 
)