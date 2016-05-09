/*
	Vray Converter
	
	This script will allow you to change a Vray Material to a Standard material and vice versa.
	Only Diffuse, SpecularLevel, Opacity and BumpMap slots are supported
*/
--by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog VRAY_STD_converter)catch()
rollout VRAY_STD_converter "Vray Converter"
(
	button btn_VRAY_to_STD "Vray -> Standard" width:150
	button btn_STD_to_VRAY "Standard -> Vray" width:150
	
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Convert VRAY to STD
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	fn ConvertVRAYtoSTD theMaterial=
	(
		local ExportMaterial = Standardmaterial()
		ExportMaterial.name = theMaterial.name
		
		--DiffuseMap
		if theMaterial.texmap_diffuse != undefined do
		(
			ExportMaterial.DiffuseMap = theMaterial.texmap_diffuse
		)

		--Specular
		if theMaterial.texmap_reflection != undefined do
		(
			ExportMaterial.SpecularLevelMap = theMaterial.texmap_reflection
		)
		
		--Opacity
		if theMaterial.texmap_opacity != undefined do
		(
			ExportMaterial.opacityMap = theMaterial.texmap_opacity
		)
		
		--NormalMap
		if theMaterial.texmap_bump != undefined do
		(
			local NormalMap = Normal_Bump()
			NormalMap.normal_map = theMaterial.texmap_bump
			ExportMaterial.bumpMap = NormalMap
			ExportMaterial.bumpMapAmount = 100
		)
		return ExportMaterial
	)

	fn FN_Convert_VRAY_TO_STD nodes =
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
					if classof n.materialList[i] == VRayMtl do
					(
						replaceInstances n.materialList[i] (ConvertVRAYtoSTD n.materialList[i])
					)
				)
			)
			else
			(
				if classof n == VRayMtl do
				(
					replaceInstances n (ConvertVRAYtoSTD n)
				)
			)
			freeSceneBitmaps(); gc light:true
		)
		progressEnd()
		enablesceneredraw()
	)
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Convert STD to VRAY
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	-- Converts a StandartMaterial to Vray
	fn ConvertSTDtoVray theMaterial=
	(
		local theVray = VRayMtl()
		theVray.name = theMaterial.name

		--Diffuse
		if theMaterial.DiffuseMap != undefined do
		(
			theVray.texmap_diffuse = theMaterial.DiffuseMap
		)
		--Specular
		if theMaterial.specularLevelMap != undefined do
		(
			theVray.texmap_reflection = theMaterial.specularLevelMap
		)
		--Opacity
		if theMaterial.opacityMap != undefined do
		(
			theVray.texmap_opacity = theMaterial.opacityMap
		)
		--NormalMap
		if theMaterial.bumpMap == bitmapTexture do
		(
			theVray.texmap_bump = theMaterial.bumpMap
		)
		if theMaterial.bumpMap == Normal_Bump do
		(
			if theMaterial.bumpMap.normal_map != undefined do
			(
				theVray.texmap_bump = theMaterial.bumpMap.normal_map
			)
		)
		theVray.texmap_bump_multiplier = 100.0
		
		return theVray
	)


	
	fn FN_Convert_STD_TO_VRAY nodes=
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
						replaceInstances n.materialList[i] (ConvertSTDtoVray n.materialList[i])
					)
				)
			)
			else
			(
				if classof n == Standardmaterial do
				(
					replaceInstances n (ConvertSTDtoVray n)
				)
			)
			freeSceneBitmaps(); gc light:true
		)
		progressEnd()
		enablesceneredraw()
	)
	
	
	on btn_VRAY_to_STD pressed do
	(
		with undo off
		(
			FN_Convert_VRAY_TO_STD selection
		)
	)
	
	on btn_STD_to_VRAY pressed do
	(
		with undo off
		(
			FN_Convert_STD_TO_VRAY selection
		)
	)
)
createDialog VRAY_STD_converter