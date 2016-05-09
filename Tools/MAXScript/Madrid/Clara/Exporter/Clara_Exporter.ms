/*
	Clara Exporter

*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog Clara_Exporter)catch()
rollout Clara_Exporter "Clara Exporter"
(
	local theColladaINI = (getDir #plugcfg) + "\\IrrColladaMax.ini"
	
	edittext et_output "Output Folder:" labelOnTop:true readonly:true
	button btn_browse "Browse..." width:140
	
	checkbox cb_move_000 "Move to 0/0/0"
	checkbox cb_normals "Normals" checked:true
	
	button btn_export "Export" width:140 --enabled:false
	
	fn CompatibleShader theFile =
	(
		local theDX = DirectX_9_Shader()
		theDX.effectFile = (substitutestring theFile "\\" "\\\\")
		local status = true
		try
		(
			theDX.DiffuseMap
			theDX.LightMap
			theDX.SpecularMap
			theDX.NormalMap
		)
		catch
		(
			status = false
		)
		status
	)
	
	fn ConvertDXtoSTD theMaterial=
	(
		local CompatibleStatus = CompatibleShader (substitutestring theMaterial.effectFile "\\" "\\\\")
		
		if CompatibleStatus == true then
		(
			local ExportMaterial = Standardmaterial()
			ExportMaterial.name = theMaterial.name
			
			--New DiffuseMap
			if theMaterial.DiffuseMap != undefined do
			(
				local theDiffuse = bitmaptexture()
				theDiffuse.filename = theMaterial.DiffuseMap.filename
				ExportMaterial.DiffuseMap = theDiffuse
			)
			
			--New Lightmap
			if theMaterial.LightMap != undefined do
			(
				local theLightmap = bitmaptexture()
				theLightmap.filename = theMaterial.LightMap.filename
				ExportMaterial.ambientMap = theLightmap
			)

			--New Specular
			if theMaterial.SpecularMap != undefined do
			(
				local theSpecular = bitmaptexture()
				theSpecular.filename = theMaterial.SpecularMap.filename
				ExportMaterial.specularLevelMap = theSpecular
			)
			--New Normal
			if theMaterial.NormalMap != undefined do
			(
				local theNormal = bitmaptexture()
				theNormal.filename = theMaterial.NormalMap.filename
				ExportMaterial.bumpMap = theNormal
				ExportMaterial.bumpMapAmount = 100
			)
			return ExportMaterial
		)
		else
		(
			print (theMaterial.name + " is not compatible with this converter.")
			return theMaterial
		)
	)

	fn ConvertDXtoSTD_Multi theMaterial = 
	(
		local NewMultiMat = multimaterial()
		NewMultiMat.count = theMaterial.count
		NewMultiMat.name = theMaterial.name
		
		for i=1 to theMaterial.materialList.count do
		(
			if (classof theMaterial.materialList[i]) == DirectX_9_Shader then
			(
				NewMultiMat.materialList[i] = ConvertDXtoSTD theMaterial.materialList[i]
			)
			else
			(
				NewMultiMat.materialList[i] = theMaterial.materialList[i]
			)
		)
		return NewMultiMat
	)
	
	fn Export_Mesh node thePath =
	(
		local theMaterial = node.material
		local NewMaterial = node.material
		
		if classof theMaterial == multimaterial do
		(
			NewMaterial = ConvertDXtoSTD_Multi theMaterial
		)
		if classof theMaterial == DirectX_9_Shader do
		(
			NewMaterial = ConvertDXtoSTD theMaterial
		)
		
		node.material = NewMaterial
		
		--Export
		local theFile = (ThePath + node.name + ".dae")
		deleteFile theFile
		
		local theSnapshot = snapshot node
		theSnapshot.name = node.name
		select theSnapshot
		if cb_move_000.state == true do	(theSnapshot.pos = [0,0,0])
		exportFile theFile #noPrompt selectedOnly:true using:IrrColladaExporter
		delete theSnapshot
		node.material = theMaterial
	)
	

	on btn_browse pressed do
	(
		local thePath = getSavePath caption:"Select an output folder" --initialDir:maxpath  
		if thePath != undefined then
		(
			btn_export.enabled = true
			et_output.text = thePath
			fileProperties.addProperty #custom "COLLADA_EXPORT_PATH" thePath
		)
		else
		(
			btn_export.enabled = false
		)
	)
	
	on btn_export pressed do
	(
		if et_output.text != "" then
		(
			with undo off with redraw off
			(
				local theMeshes = for n in selection collect n
				
				for n in theMeshes do
				(
					Export_Mesh n ((substitutestring et_output.text "\\" "\\\\") + "\\")
				)

				select theMeshes
			)
		)
		else
		(
			messagebox "You have to select an output path"
		)
	)
	

	on Clara_Exporter open do
	(
		setInisetting theColladaINI "ColladaMax" "normals" "1"
		
		local theIndex = fileProperties.findProperty #custom "COLLADA_EXPORT_PATH"
		if theIndex != 0 do
		(
			local thePath = fileProperties.getPropertyValue #custom theIndex
			et_output.text = thePath
			btn_export.enabled = true
		)
	)
	
	on cb_normals changed theState do
	(
		if theState == true then
		(
			setInisetting theColladaINI "ColladaMax" "normals" "1"
		)
		else
		(
			setInisetting theColladaINI "ColladaMax" "normals" "0"
		)
	)
	
)
createDialog Clara_Exporter