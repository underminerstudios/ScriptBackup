/*
	Fragment Skinner

	This script will create a single mesh from the current selection, add a skin modifier and add a point with the animation of each object. 
*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog FragmentSkinner)catch()
rollout FragmentSkinner "Fragment Skinner"
(

	spinner sp_start "Start:" type:#integer range:[animationrange.start,animationrange.end,animationrange.start]
	spinner sp_end "End:" type:#integer range:[animationrange.start,animationrange.end,animationrange.end]
	button btn_process "Process"
	
	on btn_process pressed do
	(
		setCommandPanelTaskMode #modify

		local theObjects = for n in selection collect n
		local thePoints = #()
		local thePolyCounts = #()
		local theCurrentSlidertime = slidertime
		
		--Create Points for each fragment
		for n in theObjects do
		(
			local thePoint = Point()
			thePoint.size = 1
			thePoint.wirecolor = n.wirecolor
			append thePoints thePoint
		)
		slidertime = sp_start.value
		
		--Align points to fragments and bake transform
		animate on
		(
			with redraw off with undo off
			(
				for j = sp_start.value to sp_end.value do
				(
					slidertime = j
					for i=1 to theObjects.count do
					(
						thePoints[i].transform = theObjects[i].transform
						addNewKey thePoints[i].position.controller slidertime
					)
				)
			)
		)

		slidertime = sp_start.value

		--We create the new mesh
		local theMesh = editable_mesh name:(uniquename"skinedMesh")
		convertTo theMesh Editable_Poly

		--Attach copies of the fragments to the new mesh. Save polycount to array.
		for n in theObjects do
		(
			local theCount = polyop.getNumVerts theMesh
			append thePolyCounts theCount
			local theObject = copy n
			convertTo theObject Editable_Poly
			polyop.attach theMesh theObject
		)
		append thePolyCounts (polyop.getNumVerts theMesh)
			
		--Add Skin mod and add all the bones
		addModifier theMesh (Skin())
		select theMesh
		theSkin = modPanel.getCurrentObject()
		theSkin.rigid_vertices = true
		theSkin.bone_Limit = 1
		for n in thePoints do
		(
			skinOps.addBone theSkin n -1
		)

		--Hack: Refresh skin mod
		classof theMesh

		--Assign vertex weight to each bone based on polycounts array
		for i=1 to theObjects.count do
		(
			for j=((thePolyCounts[i]) + 1) to (thePolyCounts[i + 1]) do
			(
				skinOps.SetVertexWeights theSkin j i 1.0
			)	
		)
		slidertime = theCurrentSlidertime
	)
	
)
createDialog FragmentSkinner