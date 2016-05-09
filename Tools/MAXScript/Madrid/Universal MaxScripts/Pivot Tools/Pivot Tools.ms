/*
	Pivot Tools
	
	- Snap to Vert
	- Snap to Center
*/
--by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog pivot_tools)catch()
rollout pivot_tools "Pivot Tools"
(
	button btn_snapTovert "Vert Snap" width:150
	button btn_snapToKnot "Knot Snap" width:150
	button btn_snapToCenter "Center" width:150
	button btn_snapToBottom "Bottom" width:150
	
	fn snapToKnot theShape =
	(
		if subobjectLevel == 1 do
		(
			local theKnots = #()
			local theCoordinates = [0,0,0]

			for nSpline = 1 to (numSplines TheShape) do
			(
				local theSelection = getKnotSelection TheShape nspline
				for n in theSelection do
				(
					local KnotCoord = getKnotPoint TheShape nspline n
					append theKnots KnotCoord
				)
			)
				
			if theKnots.count != 0 do
			(
				for n in theKnots do
				(
					theCoordinates += n
				)
			)

			local theFinalCoord = theCoordinates / theKnots.count
			TheShape.pivot = theFinalCoord
		)
	)
	
	fn SnapToVert theMesh =
	(
		local vArray = polyop.getvertselection theMesh as array
		if subobjectLevel == 1 do
		(
			local thePivotCoordinate = [0,0,0]
			for n in vArray do
			(
				thePivotCoordinate += (polyop.getVert theMesh n)
			)
			thePivotCoordinate = thePivotCoordinate / vArray.count
			theMesh.pivot = thePivotCoordinate
		)
	)
	
	on btn_snapTovert pressed do
	(
		if selection.count == 1 AND (classof selection[1]) == Editable_Poly do
		(
			SnapToVert selection[1]
		)
	)

	on btn_snapToKnot pressed do
	(
		if selection.count == 1 AND (classof selection[1]) == line OR (classof selection[1] == SplineShape) do
		(
			snapToKnot selection[1]
		)
	)
	
	on btn_snapToCenter pressed do
	(
		for o in selection do (o.pivot = o.center)
	)
	
	on btn_snapToBottom pressed do
	(
		for o in selection do (o.pivot = [o.pivot[1],o.pivot[2],o.min[3]])
	)
	
)
createDialog pivot_tools