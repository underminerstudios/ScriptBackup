/*
	BumpMap Replacer
	
	This script will take the normal map in the Normal_bump slot and move it to the BumpMap Slot and vice versa.
*/
--by Norman Schaar - norman.schaar@gameloft.com




try(destroyDialog BumpMapReplacer)catch()

rollout BumpMapReplacer "BumpMap Replacer"
(	
	button btn_normalBump "-> Normal_Bump" width:150
	button btn_standardBump "-> Standard Bump" width:150
	
	fn ConvertToBump theMaterial =
	(
		local theBumpMap = theMaterial.bumpMap
		if (classof theMaterial.bumpMap) == Normal_Bump do
		(
			if (classof theMaterial.bumpMap.normal_map) == bitmaptexture do
			(
				theMaterial.bumpMap = theMaterial.bumpMap.normal_map
			)
		)
	)

	fn fn_ConverToBump nodes =
	(
		progressStart "Converting to Bump..."
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		
		local progresscount = 0
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			if classof n == Standardmaterial do
			(
				ConvertToBump n
			)
			if classof n == multimaterial do
			(
				for i=1 to n.materialList.count do
				(
					if classof n.materialList[i] == Standardmaterial do
					(
						ConvertToBump n.materialList[i]
					)
				)
			)
		)
		progressEnd()
	)


	fn ConverToNormalBump theMaterial =
	(
		local theBumpMap = theMaterial.BumpMap
		if classof theBumpMap == bitmaptexture do
		(
			local theNormalBump = Normal_Bump()
			theNormalBump.normal_map = theBumpMap
			theMaterial.bumpMap = theNormalBump			
		)
	)

	fn fn_ConverToNormalBump nodes =
	(
		progressStart "Converting to Normal_Bump..."
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		
		local progresscount = 0
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			if classof n == Standardmaterial do
			(
				ConverToNormalBump n
			)
			if classof n == multimaterial do
			(
				for i=1 to n.materialList.count do
				(
					if classof n.materialList[i] == Standardmaterial do
					(
						ConverToNormalBump n.materialList[i]
					)
				)
			)
		)
		progressEnd()
	)
	
	on btn_normalBump pressed do
	(
		with undo off with redraw off
		(
			fn_ConverToNormalBump selection
		)
	)
	
	on btn_standardBump pressed do
	(
		with undo off with redraw off
		(
			fn_ConverToBump selection
		)
	)
)
createDialog BumpMapReplacer
