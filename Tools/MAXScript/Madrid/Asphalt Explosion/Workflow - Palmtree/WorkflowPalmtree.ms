try(destroyDialog DLG_WORKFLOW_PALMTREE)catch()
rollout DLG_WORKFLOW_PALMTREE "Palmtree Workflow"
(
	local theMadridPath = pathConfig.removePathLeaf(pathConfig.removePathLeaf(getFileNamePath (getSourceFileName())))
	
	button btn_xref_to_mat "Xref Material --> Standard Material" width:200
	button btn_convertToPoly "Convert to Poly" width:200
	button btn_xform "xForm" width:200
	button btn_phase "Randomize Phase" width:200
	button btn_AttachAll "Attach Selected" width:200
	button btn_multimaterialCleaner "MultiMaterial Cleaner" width:200
	button btn_renameMaterial "Rename Material" width:200
	button btn_submatrename "Rename SubMaterials" width:200

	
	on btn_xref_to_mat pressed do
	(
		local theScript = theMadridPath + "\\Universal MaxScripts\\Xref Material Converter\\xrefmatconverter.ms"
		filein theScript
	)
	
	on btn_convertToPoly pressed do
	(
		for n in selection do
		(
			convertToPoly n
		)
	)
	
	on btn_xform pressed do
	(
		for n in selection do
		(
			resetxform n
			convertToPoly n
		)
	)
	
	on btn_phase pressed do
	(
		for n in selection do
		(
			local theMesh = n
			local theMeshVertNum = polyop.getNumVerts theMesh
			local theValue = random 0.0 1.0
			
			local myUnwrap= unwrap_UVW()
			myUnwrap.unwrap.setMapChannel 3
			addmodifier theMesh myUnwrap
			
			converttopoly n
			
			for i=1 to theMeshVertNum do
			(
				local theVert = polyOp.getMapVert theMesh 3 i
				theVert[2] = theValue
				polyOp.setMapVert theMesh 3 i theVert
			)
		)
	)
	
	on btn_AttachAll pressed do
	(
		local theScript = theMadridPath + "\\Universal MaxScripts\\AttachAll\\AttachAll.ms"
		filein theScript
	)
	
	on btn_multimaterialCleaner pressed do
	(
		local theScript = (pathConfig.removePathLeaf(theMadridPath)) + "\\Barcelona\\Global scripts\\Multimaterial Cleaner\\Gameloft_Mcr-MultiMaterialID_Cleaner_(scr).ms"
		filein theScript
	)
	
	on btn_renameMaterial pressed do
	(
		for n in selection do
		(
			n.material.name = n.name + "_MAT"
		)
	)
	
	on btn_submatrename pressed do
	(
		for n in selection do
		(
			local theMaterial = n.material
			for i=1 to theMaterial.materialList.count do
			(
				if (classof theMaterial.materialList[i]) == Standardmaterial do
				(
					if theMaterial.materialList[i].diffuseMap != undefined do
					(
						local theFilename = theMaterial.materialList[i].diffuseMap.filename
						if theFilename != "" do
						(
							local theName = getFileNameFile theFilename
							theMaterial.materialList[i].name = theName
						)
					)
				)
			)
		)
	)
)
createDialog DLG_WORKFLOW_PALMTREE width:220 height:220