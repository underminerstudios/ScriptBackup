/*
	DirectX Converter
	
	This script will allow you to change a DirectX Material to a Standard material and vice versa.
	The DirectX Shader needs to have the following properties:
		- DiffuseMap
		- LightMap
		- SpecularMap
		- NormalMap
	They will be converted and moved to the following slots:
		-DiffuseMap
		-AmbientMap
		-SpecularLevel
		-BumpMap
*/


try(destroyDialog DX_STD_converter)catch()
rollout DX_STD_converter "DirectX Converter"
(
	edittext et_FX_Shader "FX Shader:" labelOnTop:true readonly:true
	button btn_browse "Select FX Shader" width:150
	button btn_DX_to_STD "DirectX -> Standard" width:150
	button btn_STD_to_DX "Standard -> DirectX" width:150 enabled:false 
	
	fn GetFxShader =
	(
		local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select FX file" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "FX file (*.fx)|*.fx" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		local result = (theDialog.showDialog()).ToString() --display the dialog, get result into variable
		local theFilenames = theDialog.fileNames --the selected filenames will be returned as an array

		if result != "Cancel" do
		(
			return theFilenames[1]
		)
		return false
	)
	
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
		true
	)
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Convert DX to STD
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	fn ConvertDXtoSTD theMaterial=
	(
		local CompatibleStatus = CompatibleShader (substitutestring theMaterial.effectFile "\\" "\\\\")
		
		if CompatibleStatus == true then
		(
			local ExportMaterial = Standardmaterial()
			ExportMaterial.name = theMaterial.name
			
			--New DiffuseMap
			try(
			if theMaterial.DiffuseMap != undefined do
			(
				local theFileName = theMaterial.DiffuseMap.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theDiffuse = bitmaptexture()
					theDiffuse.filename = theFileName
					ExportMaterial.DiffuseMap = theDiffuse
					
					--Alpha
					local bitmapCheck = openBitmap theFileName
					if bitmapCheck.hasAlpha == true do
					(
						local theAlpha = bitmaptexture()
						theAlpha.filename = theFileName
						theAlpha.monoOutput = 1
						ExportMaterial.OpacityMap = theAlpha					
					)
				)
			)
			)catch()
			
			--New Diffuse1
			try(
			if theMaterial.Diffuse1 != undefined do
			(
				local theFileName = theMaterial.Diffuse1.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theDiffuse = bitmaptexture()
					theDiffuse.filename = theFileName
					ExportMaterial.DiffuseMap = theDiffuse
				)
			)
			)catch()
			
			--New Diffuse2
			try(
			if theMaterial.Diffuse2 != undefined do
			(
				local theFileName = theMaterial.Diffuse2.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theDiffuse = bitmaptexture()
					theDiffuse.filename = theFileName
					ExportMaterial.specularLevelMap = theDiffuse
				)
			)
			)catch()
			
			--New Diffuse3
			try(
			if theMaterial.Diffuse3 != undefined do
			(
				local theFileName = theMaterial.Diffuse3.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theDiffuse = bitmaptexture()
					theDiffuse.filename = theFileName
					ExportMaterial.specularMap = theDiffuse
				)
			)
			)catch()
			
			--New Diffuse4
			try(
			if theMaterial.Diffuse4 != undefined do
			(
				local theFileName = theMaterial.Diffuse4.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theDiffuse = bitmaptexture()
					theDiffuse.filename = theFileName
					ExportMaterial.glossinessMap = theDiffuse
				)
			)
			)catch()
			
			--New MaskMap
			try(
			if theMaterial.maskMap != undefined do
			(
				local theFileName = theMaterial.Diffuse4.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theDiffuse = bitmaptexture()
					theDiffuse.filename = theFileName
					ExportMaterial.reflectionMap = theDiffuse
				)
			)
			)catch()
			
			--New Lightmap
			try(
			if theMaterial.LightMap != undefined do
			(
				local theFileName = theMaterial.LightMap.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theLightmap = bitmaptexture()
					theLightmap.filename = theFileName
					ExportMaterial.ambientMap = theLightmap
				)
			)
			)catch()

			--New Specular
			try(
			if theMaterial.SpecularMap != undefined do
			(
				local theFileName = theMaterial.SpecularMap.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theSpecular = bitmaptexture()
					theSpecular.filename = theFileName
					ExportMaterial.specularLevelMap = theSpecular
				)
			)
			)catch()
			--New Normal
			try(
			if theMaterial.NormalMap != undefined do
			(
				local theFileName = theMaterial.NormalMap.filename
				if theFileName != undefined AND (doesFileExist theFileName) == true do
				(
					local theNormal = bitmaptexture()
					theNormal.filename = theMaterial.NormalMap.filename
					ExportMaterial.bumpMap = theNormal
					ExportMaterial.bumpMapAmount = 100
				)
			)
			)catch()
			return ExportMaterial
		)
		else
		(
			print (theMaterial.name + " is not compatible with this converter.")
			return theMaterial
		)
	)

	fn FN_Convert_DX_TO_STD nodes =
	(
		disablesceneredraw()
		
		progressStart "Converting..."
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		local progresscount = 0
		
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			if classof n == multimaterial then
			(
				for i=1 to n.materialList.count do
				(
					if classof n.materialList[i] == DirectX_9_Shader do
					(
						replaceInstances n.materialList[i] (ConvertDXtoSTD n.materialList[i])
					)
				)
			)
			else
			(
				if classof n == DirectX_9_Shader do
				(
					replaceInstances n (ConvertDXtoSTD n)
				)
			)
			freeSceneBitmaps(); gc light:true
		)
		progressEnd()
		enablesceneredraw()
	)
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Convert STD to DX
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	-- Converts a StandartMaterial to DirectX_9_Shader
	fn ConvertSTDtoDX theMaterial theShader=
	(
		local theDX = DirectX_9_Shader()
		theDX.effectFile = theShader
		theDX.name = theMaterial.name
		
		--Diffuse
		if (classof theMaterial.DiffuseMap) == bitmapTexture AND (doesFileExist theMaterial.DiffuseMap.filename) do
		(
-- 			print theMaterial.DiffuseMap.filename
			local theFileName = theMaterial.DiffuseMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theDiffuse = bitmapTexture()
				theDiffuse.filename = theFileName
				theDx.DiffuseMap = theDiffuse.bitmap
			)
		)
		
		--LightMap
		if (classof theMaterial.ambientMap) == bitmapTexture do
		(
			local theFileName = theMaterial.ambientMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theLightmap = bitmapTexture()
				theLightmap.filename = theFileName
				theDx.LightMap = theLightmap.bitmap
			)
		)

		--Specular
		if (classof theMaterial.SpecularLevelMap) == bitmapTexture do
		(
			local theFileName = theMaterial.SpecularLevelMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theSpecular = bitmapTexture()
				theSpecular.filename = theFileName
				theDx.SpecularMap = theSpecular.bitmap
			)
		)

		--NormalMap
		if classof theMaterial.BumpMap == bitmapTexture do
		(
			local theFileName = theMaterial.BumpMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormalMap = bitmapTexture()
				theNormalMap.filename = theFileName
				theDx.NormalMap = theNormalMap.bitmap
			)
		)
		if (classof theMaterial.BumpMap) == Normal_Bump do
		(
			local theFileName = theMaterial.BumpMap.normal_map.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormalMap = bitmapTexture()
				theNormalMap.filename = theFileName
				theDx.NormalMap = theNormalMap.bitmap
			)
		)
		return theDX
	)

	fn FN_Convert_STD_TO_DX nodes theShader=
	(
		disablesceneredraw()
		progressStart "Converting..."
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		
		local progresscount = 0
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			if classof n == multimaterial then
			(
				for i=1 to n.materialList.count do
				(
					if classof n.materialList[i] == Standardmaterial do
					(
						replaceInstances n.materialList[i] (ConvertSTDtoDX n.materialList[i] theShader)
					)
				)
			)
			else
			(
				if classof n == Standardmaterial do
				(
					local theMaterial = (ConvertSTDtoDX n theShader)
					replaceInstances n theMaterial
				)
			)
			freeSceneBitmaps(); gc light:true
		)
		progressEnd()
		enablesceneredraw()
	)
	
	on btn_browse pressed do
	(
		local theShader = GetFxShader()
		if theShader != false do
		(
			local CompatibleStatus = CompatibleShader (substitutestring theShader "\\" "\\\\")
			if CompatibleStatus == true then
			(
				et_FX_Shader.text = theShader
				btn_STD_to_DX.enabled = true
			)
			else
			(
				messagebox "This shader is not compatible"
				et_FX_Shader.text = ""
				btn_STD_to_DX.enabled = false
			)
		)
	)
	
	
	on btn_DX_to_STD pressed do
	(
		with undo off
		(
			FN_Convert_DX_TO_STD selection
		)
	)
	
	on btn_STD_to_DX pressed do
	(
		with undo off
		(
			FN_Convert_STD_TO_DX selection (substitutestring et_FX_Shader.text "\\" "\\\\")
		)
	)
)
createDialog DX_STD_converter