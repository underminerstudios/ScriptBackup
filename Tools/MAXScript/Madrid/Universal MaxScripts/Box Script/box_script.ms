--Function that will find a node in the layers
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

(
	local theMesh = selection[1]
	local theBox = box()
	(LayerManager.getLayer (findthenode theMesh)).addnode theBox
	theBox.name = theMesh.name
	converttopoly theBox
	theBox.transform = theMesh.transform
	local theVerts = polyop.getNumVerts theBox
	polyop.attach theBox theMesh
	polyop.deleteVerts theBox #{1..theVerts}
	select theBox
)
