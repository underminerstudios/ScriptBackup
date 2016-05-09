
try(destroyDialog DLG_VERTEX_COLOR_SWAP)catch()
rollout DLG_VERTEX_COLOR_SWAP "Vertex Color Swap"
(
	radiobuttons rb_color_source "Source:" labels:#("Red", "Green", "Blue") across:2
	radiobuttons rb_color_target "Target:" labels:#("Red", "Green", "Blue")
	
	button btn_process "Process" width:140
	
	on btn_process pressed do
	(

		local theMesh = selection[1]
		local numVerts = polyop.getnumVerts theMesh
		for i=1 to numVerts do
		(
			local theColor = polyOp.GetMapVert theMesh 0 i
			swap theColor[rb_color_target.state] theColor[rb_color_source.state]
			polyOp.setMapVert theMesh 0 i theColor
		)
		converttopoly themesh
	)
)
createDialog DLG_VERTEX_COLOR_SWAP