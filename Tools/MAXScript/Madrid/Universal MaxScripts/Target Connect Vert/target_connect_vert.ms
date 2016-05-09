(
	local theMesh = selection[1]
	local numVerts = polyop.getNumVerts theMesh
	local theVertSelection = polyop.getVertSelection theMesh
	local pp = pickpoint prompt:"Click to desired location." snap:#3d rubberBand:theMesh.pos
	if classof pp == Point3 do
	(
		local theTargetVert = undefined
		for i=1 to numVerts do
		(
			local theVert = polyop.getVert theMesh i
			if theVert == pp do
				theTargetVert = i
			
		)
		if theTargetVert != undefined do
		(
			for n in theVertSelection do
			(
				polyop.createEdge theMesh n theTargetVert
			)
		)
	)
)