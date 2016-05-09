try(destroyDialog DLG_FIX_VERT_COLOR)catch()
rollout DLG_FIX_VERT_COLOR "Fix Vert Color"
(
	fn getMapVerts obj channel theVertex = (
		local vertexFaces = polyOp.getFacesUsingVert obj #{theVertex}
		local mapVertsArray = #()
		for currentFace in vertexFaces do (
			local polyFace = polyOp.getFaceVerts obj currentFace
			local mapFace = polyOp.getMapFace obj channel currentFace
			local mapVertex = mapFace[findItem polyFace theVertex]
			append mapVertsArray mapVertex
			)
		return mapVertsArray
	)

	fn fix_vertcolor theMesh =
	(
		if classof theMesh == Editable_poly do
		(
			local numVerts = polyop.getNumVerts theMesh
			local theColors = #()
			
			for j=1 to numVerts do
			(
				local theVerts = getMapVerts selection[1] 0 j
				local theVert = [0,0,0]
				for i=1 to theVerts.count do
					theVert += polyOp.GetMapVert theMesh 0 theVerts[i]
								
				theVert = theVert / theVerts.count
				
				append theColors theVert
			)
			polyop.setMapSupport theMesh 0 false
			polyop.setMapSupport theMesh 0 true
			for j=1 to numVerts do
				polyOp.setMapVert theMesh 0 j theColors[j]
		)
	)
	
	button btn_fix "Fix selected"
	
	on btn_fix pressed do
	(
		for n in selection do
			fix_vertcolor n
	)
)
createDialog DLG_FIX_VERT_COLOR