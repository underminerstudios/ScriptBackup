(
	--
	-- Sorts the meshes in a scene in the Front viewport so that the alpha displays from back to front.
	--
	
	-- ClearListener()
	
	struct objData
	(
		obj,
		origParent
	)
	
	-- Used in the sort command to compare the depth on the Y-axis.
	fn CompareDepth v1 v2 =
	(
		local d = v1.obj.pos.y - v2.obj.pos.y
		case of
		(
			(d < 0.0): 1
			(d > 0.0): -1
			default: 0
		)
	)
	
	-- Takes an array of nodes, creates a new one with all the parents backed up in a struct.
	fn BackupParents selArray =
	(
		local objs = #()
		for o in selArray do
		(
			append objs (objData obj:o origParent:o.parent)
		)
		
		return objs
	)
	
	-- Loops through all of the objects in the array and restores the parents to what they were before the meshes were sorted.
	fn RestoreParents selArray =
	(
		for o in selArray do
		(
			o.obj.parent = o.origParent
		)
	)

	-- Sorts the objects from back to front so that the alpha works properly on the glitch shaders in the front viewport.
	fn SortObjects =
	(
		objs = BackupParents (selection as array)
		qsort objs CompareDepth
		local TempDummy = Dummy()
		
		for i = objs.count to 1 by -1 do
		(
			objs[i].obj.parent = TempDummy
		)
		
		delete TempDummy
		
		RestoreParents objs
	)
	
	SortObjects()
)