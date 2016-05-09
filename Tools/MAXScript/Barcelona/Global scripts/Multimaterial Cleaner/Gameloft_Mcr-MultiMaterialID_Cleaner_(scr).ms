rollout main "MultiSubObject Material ID Cleaner" width:224
	(
		group "Process:"
		(
			button actionBt "Clean Multi. Material"
		)
		
		group "Progress:"
		(
			progressBar prog "Total:" color:Black
		)
		
		label author2_lb "Marc Martí (Gameloft - 2012)" enabled:false align:#center

		local cleanMat
		local cleanMatDfs
		local currentId
		local newId
		local currentId

		fn cleanMultiSubs df obj subMat =
		(
			df_found = false
			foundId = 0
			idi = 0
			
			for dfi in cleanMatDfs do
			(
				idi = idi+1
				if df == dfi then
				(
					df_found = true
					foundId = idi
				)
			)
			
			if df_found == false then
			(	
				cleanMatDfs = append cleanMatDfs df
				cleanMat.materialList[newId] = subMat
				obj.EditablePoly.selectByMaterial currentId
				faces = polyop.getFaceSelection obj
				polyop.setFaceMatID obj faces newId
				newId = newId+1
			)else(
				if foundId != 0 then
				(
					obj.EditablePoly.selectByMaterial currentId
					faces = polyop.getFaceSelection obj
					polyop.setFaceMatID obj faces foundId
				)else(
					messageBox("ERROR: Material found but there is no ID related to it in the current Multimat.")
				)
			)
		)
			
		
		on actionBt pressed do 
		(			
			if selection.count >0 then
			(
				for obj in selection do
				(
					if superclassof obj == GeometryClass then
					(
						if classOf obj.mat == Multimaterial then
						(
							if classOf obj == Editable_Poly then
							(
								cleanMat = Multimaterial()
								cleanMat.materialList = #()
								cleanMatDfs = #()
								currentId = 0
								newId = cleanMat.numsubs
								
								for subMat in obj.mat.materiallist do
								(
									 currentId = currentId+1
									if (classOf subMat == standardMaterial) then
									(
										if subMat.diffusemap != undefined then
										(
											df = filenameFromPath (subMat.diffusemap.FileName as string)
											cleanMultiSubs df obj subMat
										)else(
											messageBox("ERROR: The ["+subMat.name+"] sub-material has no diffuse.")
										)
										
									)else if (classOf subMat == VRayMtl) then
									(
										if subMat.texmap_diffuse != undefined then
										(
											df = filenameFromPath (subMat.texmap_diffuse.FileName as string)
											cleanMultiSubs df obj subMat
										)else(
											messageBox("ERROR: The ["+subMat.name+"] sub-material has no diffuse.")
										)
										
									)else(
										messageBox("ERROR: There is a non recognized material inside the: ["+obj.mat.name+"] multimaterial" as string)
									)
								)
								
								--obj.mat = cleanMat
								replaceInstances obj.mat cleanMat
							
							)else(
								messageBox("ERROR: The selected objec: ["+obj.name+"] si not an Editable_Poly (The rest of the editable_poly objects will be cleaned.)" as string)
							)
						)
					)
				)
			)else(
			messageBox("ERROR: Select some meshes first")
			)
		)
	)
	createdialog main
