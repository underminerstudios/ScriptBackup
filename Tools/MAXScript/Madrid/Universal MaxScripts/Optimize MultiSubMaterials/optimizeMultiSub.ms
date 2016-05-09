/*
	Optimize Multi Sub Materials

*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog DLG_OPTIMIZE_MULTISUBMATERIALS)catch()
rollout DLG_OPTIMIZE_MULTISUBMATERIALS "Optimize MultiSubMaterials"
(
	
	fn GetInstances theMaterial =
	(
		local theArray = theMaterial.materialList
		local theInstancesString = #()
		for i=1 to theArray.count do
		(
			local theData = #(theArray[i] as string)
			for j=1 to theArray.count where theArray[j] == theArray[i] do appendifunique theData j
			if theData.count != 2 do
			(
				appendifunique theInstancesString (theData as string)
			)
		)
		
		local ReturnArray = #()
		
		for n in theInstancesString do
		(
			local theNewArray = execute n
			local finalArray = for i=2 to theNewArray.count collect theNewArray[i]
			append ReturnArray finalArray
		)
		
		ReturnArray
	)

	fn MergeInstances theMaterial theObjects =
	(
		local theResult = GetInstances theMaterial

		for o in theObjects do
		(
			for n in theResult do
			(
				local MASTER_ID = n[1]
				o.selectByMaterial MASTER_ID
				local faces = polyop.getFaceSelection o
				for i=2 to n.count do
				(
					o.selectByMaterial n[i]
					faces += polyop.getFaceSelection o
				)
				polyop.setFaceMatID o faces MASTER_ID
			)
		)
	)

	fn ID_IS_USED_MULTIPLE material ID theObjects=
	(
		for o in theObjects do
		(
			o.selectByMaterial ID
			local faces = polyop.getFaceSelection o
			if faces.numberSet != 0 do
			(
				return true
			)
		)
		false
	)

	fn needs_fix TheMaterial theObjects=
	(
		for n in TheMaterial.MaterialIDList do
		(
			local theResult = ID_IS_USED_MULTIPLE TheMaterial n theObjects
			if theResult == false do
			(
				return true
			)
		)
		return false
	)

	fn fixMat theMaterial theObjects=
	(
		local ReturnMaterial = theMaterial
		local FixNeeded = needs_fix ReturnMaterial theObjects
		if FixNeeded == true do
		(
			local theSubmaterials = for n in ReturnMaterial.MaterialList collect n

			local theNewSubMats = #()
			local theNewSubMatsIDs = #()
			for i=1 to theSubmaterials.count do
			(
				local DO_WE_ADD = (ID_IS_USED_MULTIPLE ReturnMaterial i theObjects)
				if DO_WE_ADD == true do
				(
					append theNewSubMats theSubmaterials[i]
					append theNewSubMatsIDs i
				)
			)
			
			local TheNewMaterial = multisubmaterial()
			TheNewMaterial.name = ReturnMaterial.name
			TheNewMaterial.numSubs = theNewSubMats.count
			
			for i=1 to TheNewMaterial.MaterialIDList.count do
			(
				TheNewMaterial.MaterialIDList[i] = theNewSubMatsIDs[i]
				TheNewMaterial.MaterialList[i] = theNewSubMats[i]
			)
			
			ReturnMaterial = TheNewMaterial
		)
		ReturnMaterial
	)


	fn sortSubMaterials theMaterial theObjects=
	(
		local ReturnMaterial = theMaterial
		--Get All the IDs used
		local theArray = for n in TheMaterial.materialIDList collect n
		--Are they sorted
		local SortedArray = for n in theArray collect n
		sort SortedArray
		--If it's not sorted proceed to sort, this will also create empty materials to fill in the blanks
		if (theArray as string) != (SortedArray as string) OR theArray.count != TheMaterial.numsubs do
		(
			local theNewMaterial = multisubmaterial()
			theNewMaterial.name  = TheMaterial.name
			for i=1 to TheMaterial.numsubs do
			(
				local found = finditem theArray i
				if found != 0 then
				(
					theNewMaterial.materialList[i] = TheMaterial.MaterialList[found]
				)
				else
				(
					theNewMaterial.materialList[i] = StandardMaterial()
					theNewMaterial.materialList[i].name = "NOT USED"
				)
			)
			
			ReturnMaterial = theNewMaterial
		)
		ReturnMaterial
	)
	
	button btn_optimize "OPTIMIZE!" height:30 width:100
	
	on btn_optimize pressed do
	(
		local theMaterials = #()
		for n in selection where (classof n.material) == multisubmaterial do appendifunique theMaterials n.material
		with undo off with redraw off
		(
			for m in theMaterials do
			(
				local OBJECTS_USED = for n in objects where n.material == m AND (n.baseObject as string) == "Editable Poly" collect n
				
				--Merge Instances
				MergeInstances m OBJECTS_USED
				--Sort
				local SORTED_MATERIAL = sortSubMaterials m OBJECTS_USED
				--Remove unused slots
				local FIXED_MATERIAL = fixMat SORTED_MATERIAL OBJECTS_USED
				
				--Re-assign IDs
				local theSubmaterials = for n in SORTED_MATERIAL.MaterialList collect n
				local theSubMats = for n in FIXED_MATERIAL.MaterialList collect n --Get the remaining materials
					
				--If the there are missing submats we need to re-assign ID
				if (theSubmaterials as string) != (theSubMats as string) then
				(
					--new multi mat
					local theNewMaterial = multisubmaterial()
					theNewMaterial.name = m.name
					theNewMaterial.MaterialIDList.count = theSubMats.count

					--Assign all the materials from the fixed material to the new material in the correct order
					for i=1 to FIXED_MATERIAL.MaterialList.count do
					(
						--Check if the IDs will be different, if so, change them in the objects
						local theMATID = finditem theSubmaterials theSubMats[i]
						if theMATID != i do
						(
-- 							print ("OLD ID:" + (theMATID as string))
-- 							print ("NEW ID:" + (i as string))
							for o in OBJECTS_USED do
							(
								o.selectByMaterial theMATID
								local faces = polyop.getFaceSelection o
								polyop.setFaceMatID o faces i
							)
						)
						theNewMaterial.MaterialList[i] = theSubMats[i]
					)
					replaceInstances m theNewMaterial
				)
				else
				(
					replaceInstances m FIXED_MATERIAL
				)
			)
		)
	)
)
createDialog DLG_OPTIMIZE_MULTISUBMATERIALS width:230
