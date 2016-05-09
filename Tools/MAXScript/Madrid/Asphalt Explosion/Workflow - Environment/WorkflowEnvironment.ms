try(destroyDialog DLG_WORKFLOW_ENVIRONMENT)catch()
rollout DLG_WORKFLOW_ENVIRONMENT "Workflow - Environment"
(
	local theMadridPath = pathConfig.removePathLeaf(pathConfig.removePathLeaf(getFileNamePath (getSourceFileName())))
	
	button btn_xref_to_mat "Xref Material --> Standard Material" width:200
	button btn_convertToPoly "Convert to Poly" width:200
	button btn_AttachAll "Attach Selected" width:200
	button btn_rename "Rename" width:200
	button btn_multimaterialCleaner "MultiMaterial Cleaner" width:200
	button btn_renameMaterial "Rename Material" width:200
	button btn_submatrename "Rename SubMaterials" width:200
	button btn_channelInfo "Channel Info (Clear Channels)" width:200
	button btn_pack2ndUVs "Repack 2nd UVs" width:200 enabled:false

	
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
	
	on btn_AttachAll pressed do
	(
		local theScript = theMadridPath + "\\Universal MaxScripts\\AttachAll\\AttachAll.ms"
		filein theScript
	)
	
	on btn_rename pressed do
	(
		for n in selection do
		(
			n.name = getFileNameFile maxfilename
		)
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
	
	on btn_channelInfo pressed do
	(
		macros.run "Tools" "Channel_Info"
	)
	
	on btn_pack2ndUVs pressed do
	(
		
	)
)
createDialog DLG_WORKFLOW_ENVIRONMENT width:220 height:240