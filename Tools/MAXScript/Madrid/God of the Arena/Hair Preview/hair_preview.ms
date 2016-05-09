
fn hair_DX9_preview theMaterial =
(
	if (classof theMaterial) == Standardmaterial do
	(
		local theDX = DirectX_9_Shader()
		theDX.effectfile = getFileNamePath (getSourceFileName()) +  "\\hair_preview.fx"
		theDX.name = theMaterial.name

		--Diffuse
		if (classof theMaterial.DiffuseMap) == bitmapTexture AND (doesFileExist theMaterial.DiffuseMap.filename) do
		(
			local theFileName = theMaterial.DiffuseMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theDiffuse = bitmapTexture()
				theDiffuse.filename = theFileName
				theDx.diffuseMap = theDiffuse.bitmap
			)
		)
		
		--Normal
		if classof theMaterial.BumpMap == bitmapTexture do
		(
			local theFileName = theMaterial.BumpMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormalMap = bitmapTexture()
				theNormalMap.filename = theFileName
				theDx.normalMap = theNormalMap.bitmap
			)
		)
		if (classof theMaterial.BumpMap) == Normal_Bump do
		(
			local theFileName = theMaterial.BumpMap.normal_map.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormalMap = bitmapTexture()
				theNormalMap.filename = theFileName
				theDx.normalMap = theNormalMap.bitmap
			)
		)
		
		local theSpecMap = bitmapTexture()
		theSpecMap.filename = getFileNamePath (getSourceFileName()) +  "\\SPEC.tga"
		theDX.specPalette = theSpecMap.bitmap
		
		local theBarlaMap = bitmapTexture()
		theBarlaMap.filename = getFileNamePath (getSourceFileName()) +  "\\BARLA.tga"
		theDX.barlaPalette = theBarlaMap.bitmap
		
		theDX.tintColor = color (0.745 * 255.0)	(0.392 * 255.0) (0.188 * 255.0) 0.0
		
		replaceInstances theMaterial theDX
	)
	if (classof theMaterial) == DirectX_9_Shader do
	(
		local theSTD = Standardmaterial()
		theSTD.name = theMaterial.name
		
		--New DiffuseMap
		if theMaterial.diffuseMap != undefined do
		(
			local theFileName = theMaterial.diffuseMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theDiffuse = bitmaptexture()
				theDiffuse.filename = theFileName
				theSTD.DiffuseMap = theDiffuse
			)
		)
		
		--New Normal
		if theMaterial.normalMap != undefined do
		(
			local theFileName = theMaterial.normalMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormal = bitmaptexture()
				theNormal.filename = theMaterial.normalMap.filename
				theSTD.bumpMap = theNormal
				theSTD.bumpMapAmount = 100
			)
		)
		showTextureMap theSTD true
		
		replaceInstances theMaterial theSTD
	)
)

try(destroyDialog DLG_CONVERT_HAIR_MATERIAL)catch()
rollout DLG_CONVERT_HAIR_MATERIAL "Convert Hair Material"
(
	button btn_convert "Convert Selected" width:100 height:40
	button btn_hair_01 "Black" width:80
	button btn_hair_02 "Brown" width:80
	button btn_hair_03 "Blond" width:80
	button btn_hair_04 "Red" width:80
	
	
	on btn_convert pressed do
	(
		local theMaterials = #()
		for n in selection do (appendifunique theMaterials n.material)

		for n in theMaterials do
		(
			hair_DX9_preview n
		)
	)
	
	on btn_hair_01 pressed do
	(
		local theMaterials = #()
		for n in selection do (appendifunique theMaterials n.material)
		
		for n in theMaterials do
		(
			if (classof n) == DirectX_9_Shader do (n.tintColor = color (0.086 * 255.0)	(0.086 * 255.0) (0.086 * 255.0) 0.0	)
		)
	)
	
	on btn_hair_02 pressed do
	(
		local theMaterials = #()
		for n in selection do (appendifunique theMaterials n.material)
		
		for n in theMaterials do
		(
			if (classof n) == DirectX_9_Shader do (n.tintColor = color (0.745 * 255.0)	(0.392 * 255.0) (0.188 * 255.0) 0.0)
		)
	)
	
	on btn_hair_03 pressed do
	(
		local theMaterials = #()
		for n in selection do (appendifunique theMaterials n.material)
		
		for n in theMaterials do
		(
			if (classof n) == DirectX_9_Shader do (n.tintColor = color (1.000 * 255.0)	(0.867 * 255.0) (0.529 * 255.0) 0.0)
		)
	)
	
	on btn_hair_04 pressed do
	(
		local theMaterials = #()
		for n in selection do (appendifunique theMaterials n.material)
		
		for n in theMaterials do
		(
			if (classof n) == DirectX_9_Shader do (n.tintColor = color (0.953 * 255.0)	(0.251 * 255.0) (0.075 * 255.0) 0.0)
		)
	)
)
createDialog DLG_CONVERT_HAIR_MATERIAL