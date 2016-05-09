for f in (getFiles ((pathconfig.removepathleaf (getSourceFileName()) + "\\fn\\*.ms"))) do (filein f)

try(destroyDialog DLG_Gladiators_ODS)catch()
try(destroyDialog DLG_Armors_ODS)catch()
try(destroyDialog DLG_HAIR_ODS)catch()
try(destroyDialog DLG_HELMETS_ODS)catch()
try(destroyDialog DLG_SHIELDS_ODS)catch()
try(destroyDialog DLG_WEAPONS_ODS)catch()

rollout DLG_Gladiators_ODS "Gladiators ODS"
(
	local theODS = "P:\\data\\lottery\\Art.ods"
	local theGladiator = #(undefined,undefined,undefined)
	local theXMLPath = "P:\\data\\lottery\\Art.xml"
	local theXML = undefined
	local theHair = undefined
	local theFacialHair = undefined
	
	dropdownlist ddl_visualID "VisualID:" across:7
	dropdownlist ddl_assetbase "AssetBase:" enabled:false
	dropdownlist ddl_mesh "Mesh:" enabled:false
	dropdownlist ddl_material0 "Material 0:" enabled:false
	dropdownlist ddl_diffuse_tex_0 "Diffuse Tex 0:" enabled:false
	dropdownlist ddl_bump_tex_0 "Bump Tex 0:" enabled:false
	dropdownlist ddl_musculature "Musculature ID:" enabled:false
	
	multilistbox mlb_hairs "Hairs:" pos:[580,50] width:150
	dropdownlist ddl_hairs "Preview Hair:" pos:[740,50] width:150 enabled:false
	
	button btn_delete "Delete" width:140 pos:[15,45] enabled:false
	edittext et_visualID "VisualID:" width:140 pos:[15,80] labelontop:true
	button btn_add "Add" width:140 pos:[15,118] enabled:false
	
	
	checkbox cb_saveOnExit "Save on exit" checked:true

	
	fn load_all theXMLPath=
	(
		btn_add.enabled = false
		btn_delete.enabled = false
		
		dotNet.loadAssembly "system.xml"
		local theXML = dotNetObject "system.xml.xmlDocument"
		theXML.load theXMLPath

		
		ddl_visualID.items = getList theXML "Gladiators" "VisualID"
		ddl_assetbase.items = getAssetBaseList_Gladiators()
		ddl_mesh.items = getGladiatorsListPIG()
		ddl_material0.items = getMaterialsGladiators()
		
		local theDFs = getGladiatorsList_DF_TGA()
		local sortedDFs = for n in theDFs collect (getFileNameFile n + ".tga")
		sort sortedDFs
		ddl_diffuse_tex_0.items =  sortedDFs
		
		local theNMs = getGladiatorsList_NM_TGA()
		local sortedNMs = for n in theNMs collect (getFileNameFile n + ".tga")
		sort sortedNMs
		ddl_bump_tex_0.items = sortedNMs
		
		ddl_musculature.items = #("M_01","M_02")
		
		mlb_hairs.items = #()
		ddl_hairs.items = #()
		
		ddl_visualID.selection = 0
		ddl_assetbase.selection = 0
		ddl_mesh.selection = 0
		ddl_material0.selection = 0
		ddl_diffuse_tex_0.selection = 0
		ddl_bump_tex_0.selection = 0
		ddl_musculature.selection = 0
		
		theXML
	)
	
	
	on DLG_Gladiators_ODS open do
	(
		-----------------------------------------------------------------------------------------------------------------------------
		-- EXTRACT XML FROM ODS
		-----------------------------------------------------------------------------------------------------------------------------
		extractODS theODS theXMLPath

		theXML = load_all theXMLPath
	)
	
	on ddl_visualID selected arg do
	(
		start = timeStamp()
		
		ddl_visualID.enabled = true
		ddl_assetbase.enabled = true
		ddl_mesh.enabled = true
		ddl_material0.enabled = true
		ddl_diffuse_tex_0.enabled = true
		ddl_bump_tex_0.enabled = true
		ddl_musculature.enabled = true
		
		local theAssetBase = getList theXML "Gladiators" "AssetBase"
		ddl_assetbase.selection = findItem ddl_assetbase.items theAssetBase[arg]
		
		local theMesh = getList theXML "Gladiators" "Mesh"
		ddl_mesh.selection = findItem ddl_mesh.items theMesh[arg]
		
		local theMaterial = getList theXML "Gladiators" "Material 0"
		ddl_material0.selection = findItem ddl_material0.items theMaterial[arg]

		local theDiffuse = getList theXML "Gladiators" "Diffuse Tex 0"
		for n in theDiffuse do
		ddl_diffuse_tex_0.selection = findItem ddl_diffuse_tex_0.items theDiffuse[arg]
		
		local theBump = getList theXML "Gladiators" "Bump Tex 0"
		ddl_bump_tex_0.selection = findItem ddl_bump_tex_0.items theBump[arg]
		
		local theMusculature = getList theXML "Gladiators" "MusculatureID"
		ddl_musculature.selection = findItem ddl_musculature.items theMusculature[arg]
		
		local theHairList = getList theXML "Hairs" "VisualID"
		local NameFilter = substring (getFileNameFile theMesh[arg]) 1 ((getFileNameFile theMesh[arg]).count - 2)
		local theFilteredHairList = for n in theHairList where (matchpattern n pattern:(NameFilter + "*")) == true collect n
		local theSelectedHairs = getList theXML "Gladiators" "HairID"
		local theSelectedHairNames = filterstring theSelectedHairs[arg] ";"
		local theSelectedHairIndexes = for n in theSelectedHairNames collect (findItem theFilteredHairList n)
			
		mlb_hairs.items = theFilteredHairList
		mlb_hairs.selection = theSelectedHairIndexes as bitarray
			
		ddl_hairs.enabled = true
		ddl_hairs.items = theSelectedHairNames
		ddl_hairs.selection = 0
		
		btn_add.enabled = true
		btn_delete.enabled = true
		

		------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Merge Hair 
		------------------------------------------------------------------------------------------------------------------------------------------------------
		
		local theMaxFile = getMaxFile "Q:\\gladiators\\" ((getFileNameFile theMesh[arg]) + "_head_LOD1")
		
		if theMaxFile != false then 
		(
			for n in theGladiator do
			(
				if n != undefined do
				(
					if (isdeleted n) == false do
						delete n
				)
			)
			mergeMAXFile theMaxFile #(((getFileNameFile theMesh[arg]) + "_head_LOD1"),((getFileNameFile theMesh[arg]) + "_legs_LOD1"),((getFileNameFile theMesh[arg]) + "_torso_LOD1")) #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theGladiator = #(objects[objects.count],objects[objects.count-1],objects[objects.count-2])
			for n in theGladiator do
			(
				n.layer.ishidden = false
				unhide n
			)
			selection = theGladiator
			actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected
			
			
			------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Armor Material
			------------------------------------------------------------------------------------------------------------------------------------------------------
			
			for n in theGladiator do
			(
				local theDX = DirectX_9_Shader()
				theDX.effectfile = "Q:\\shaders\\armor\\armor.fx"
				theDX.name = n.name
				
				local theDFs = getGladiatorsList_DF_TGA()
				for n in theDFs where (getFileNameFile (n as string)) == (getFileNameFile (theDiffuse[arg] as string)) do
				(
					local theDiffuseMap = bitmapTexture()
					theDiffuseMap.filename = n
					theDX.diffuseMap = theDiffuseMap.bitmap
				)
				
				local theNMs = getGladiatorsList_NM_TGA()
				for n in theNMs where (getFileNameFile (n as string)) == (getFileNameFile (theBump[arg] as string)) do
				(
					local theNormalMap = bitmapTexture()
					theNormalMap.filename = n
					theDx.normalMap = theNormalMap.bitmap
				)
				
				local theBarla = bitmapTexture()
				theBarla.filename = "Q:\\shaders\\textures\\BARLA.tga"
				theDX.barlaPalette = theBarla.bitmap
				
				local theSpec = bitmapTexture()
				theSpec.filename = "Q:\\shaders\\skin\\Fx_SPEC_skinHuman.tga"
				theDX.specPalette = theSpec.bitmap
				
				replaceInstances n.material theDX
			)
		)
		else
		(
			messagebox (" Sorry a preview is not availalbe." + " The mesh " + (getFileNameFile theMesh[arg]) + " was not found in any max file in the folder " + "\"" + "Q:\\gladiators\\" + "\"")
		)
		
		
		end = timeStamp()
		format "Processing took % seconds\n" ((end - start) / 1000.0)
		
	)
	
	on ddl_assetbase selected arg do
	(
		setValue theXML theXMLPath "Gladiators" "AssetBase" "VisualID" ddl_visualID.selected ddl_assetbase.items[arg]
	)
	
	on ddl_musculature selected arg do
	(
		setValue theXML theXMLPath "Gladiators" "MusculatureID" "VisualID" ddl_visualID.selected ddl_musculature.items[arg]
	)
	
	on ddl_mesh selected arg do
	(
		setValue theXML theXMLPath "Gladiators" "Mesh" "VisualID" ddl_visualID.selected ddl_mesh.items[arg]
		

		local theMaxFile = getMaxFile "Q:\\gladiators\\" ((getFileNameFile ddl_mesh.items[arg]) + "_LOD1")
		
		if theMaxFile != false then
		(
			local theMaterials = #(undefined,undefined,undefined)
			for i=1 to theGladiator.count do
			(
				if theGladiator[i] != undefined do
				(
					if (isdeleted theGladiator[i]) == false do
					(
						theMaterial[i] = theGladiator[i].material
						delete theGladiator[i]
					)
				)
			)
			mergeMAXFile theMaxFile #(((getFileNameFile ddl_mesh.items[arg]) + "_head_LOD1"),((getFileNameFile ddl_mesh.items[arg]) + "_legs_LOD1"),((getFileNameFile ddl_mesh.items[arg]) + "_torso_LOD1")) #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theGladiator = #(objects[objects.count],objects[objects.count-1],objects[objects.count-2])
			
			for i=1 to theGladiator.count do
			(
				if theMaterial[i] != undefined do
					theGladiator[i].material = theMaterials[i]
				theGladiator[i].layer.ishidden = false
				unhide theGladiator[i]
			)
			selection = theGladiator
			
			actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected
		)
		else
		(
			messagebox (" Sorry a preview is not availalbe." + " The mesh " + (getFileNameFile ddl_mesh.items[arg]) + " was not found in any max file in the folder " + "\"" + "Q:\\gladiators\\" + "\"")
		)
	)
	
	on ddl_material0 selected arg do
	(
		setValue theXML theXMLPath "Gladiators" "Material 0" "VisualID" ddl_visualID.selected ddl_material0.items[arg]
	)
	
	on ddl_diffuse_tex_0 selected arg do
	(
		setValue theXML theXMLPath "Gladiators" "Diffuse Tex 0" "VisualID" ddl_visualID.selected ddl_diffuse_tex_0.items[arg]

		local theDFs = getGladiatorsList_DF_TGA()
		for n in theDFs where (getFileNameFile n) == (getFileNameFile ddl_diffuse_tex_0.items[arg]) do
		(
			local theDiffuse = bitmapTexture()
			theDiffuse.filename = n
			for m in theGladiator do
				m.material.diffuseMap = theDiffuse.bitmap
		)
	)
	
	on ddl_bump_tex_0 selected arg do
	(
		setValue theXML theXMLPath "Gladiators" "Bump Tex 0" "VisualID" ddl_visualID.selected ddl_bump_tex_0.items[arg]

		local theNMs = getGladiatorsList_NM_TGA()
		for n in theNMs where (getFileNameFile n) == (getFileNameFile ddl_bump_tex_0.items[arg]) do
		(
			local theNormal = bitmapTexture()
			theNormal.filename = n
			for m in theGladiator do
				m.material.normalMap = theNormal.bitmap
		)
	)
	
	on mlb_hairs selectionEnd do
	(
		local theSelectedHairNames = for n in mlb_hairs.selection collect mlb_hairs.items[n]
		local theSelectedHairString = ""
		for i=1 to theSelectedHairNames.count do
		(
			theSelectedHairString += theSelectedHairNames[i]
			if i!=theSelectedHairNames.count do
				theSelectedHairString += ";"
		)
		
		ddl_hairs.items = theSelectedHairNames
		ddl_hairs.selection = 0
		
		setValue theXML theXMLPath "Gladiators" "HairID" "VisualID" ddl_visualID.selected theSelectedHairString
	)
	
	on ddl_hairs selected arg do
	(
		local HairVisualIDs = getList theXML "Hairs" "VisualID"
		local theRowIndex = (findItem HairVisualIDs ddl_hairs.items[arg])

		local hairMeshList = getList theXML "Hairs" "Mesh"
		local hairMesh = getFileNameFile hairMeshList[theRowIndex]
		
		local diffuseHairList = getList theXML "Hairs" "Diffuse Tex 0"
		local hairDiffuse = diffuseHairList[theRowIndex]
		
		local bumpHairList = getList theXML "Hairs" "Bump Tex 0"
		local hairBump = bumpHairList[theRowIndex]
		
		local theMaterialList = getList theXML "Hairs" "Material 0"
		local theMaterial = theMaterialList[theRowIndex]

		
		
		print hairMesh
		print hairDiffuse
		print hairBump
		print theMaterial
		
		------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Merge Hair 
		------------------------------------------------------------------------------------------------------------------------------------------------------
		
		local theMaxFile = getMaxFile "Q:\\gladiators\\" (getFileNameFile hairMesh)
		
		if theMaxFile != false then 
		(
			if theHair != undefined do
			(
				if (isdeleted theHair) == false do
					delete theHair
			)
			if theFacialHair != undefined do
			(
				if (isdeleted theFacialHair) == false do
					delete theFacialHair
			)
			mergeMAXFile theMaxFile #((getFileNameFile hairMesh)) #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theHair = objects[objects.count]
			theHair.layer.ishidden = false
			unhide theHair
			select theHair
			mergeMAXFile theMaxFile #(substitutestring (getFileNameFile hairMesh) "hair" "facialhair") #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theFacialHair = objects[objects.count]
			theFacialHair.layer.ishidden = false
			unhide theFacialHair
			select theFacialHair
			
			actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected
			
			
			------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Hair Material
			------------------------------------------------------------------------------------------------------------------------------------------------------
			theFacialHair.material = theHair.material
			hair_DX9_preview theHair.material
			
			--Diffuse
			local theDFs = getHairsList_DF_TGA()
			for n in theDFs where (getFileNameFile (n as string)) == (getFileNameFile hairDiffuse) do
			(
				local theDiffuse = bitmapTexture()
				theDiffuse.filename = n
				theHair.material.diffuseMap = theDiffuse.bitmap
			)
			
			--NormalMap
			local theNMs = getHairsList_NM_TGA()
			for n in theNMs where (getFileNameFile (n as string)) == (getFileNameFile hairBump) do
			(
				local theNormal = bitmapTexture()
				theNormal.filename = n
				theHair.material.normalMap = theNormal.bitmap
			)
			
			--tintColor
			local theColor = getHairColor theMaterial
			if theColor != false do
			(
				theHair.material.tintColor = theColor
			)
		)
		else
		(
			messagebox (" Sorry a preview is not availalbe." + " The mesh " + (getFileNameFile hairMesh) + " was not found in any max file in the folder " + "\"" + "Q:\\gladiators\\" + "\"")
		)
	)
	
	on btn_add pressed do
	(
		if et_visualID.text != "" then
		(
			if (findItem ddl_visualID.items et_visualID.text) == 0 then
			(
				addNode theXML theXMLPath "Gladiators" "VisualID" et_visualID.text
				theXML = load_all theXMLPath
			)
			else
			(
				messagebox "Duplicated name! Please choose another name!"
			)
		)
		else
		(
			messagebox "You need to specify a name"
		)
	)
	
	on btn_delete pressed do
	(
		local query_result = querybox "Are you sure you want to delete the current entry?"
		if query_result == true do
		(
			deleteNode theXML theXMLPath "Gladiators" "VisualID" ddl_visualID.items[ddl_visualID.selection]
			theXML = load_all theXMLPath
			for i=1 to theGladiator.count do
			(
				if theGladiator[i] != undefined do
				(
					if (isdeleted theGladiator[i]) == false do
					(
						delete theGladiator[i]
						theGladiator[i] = undefined
					)
				)
			)
		)
	)
	
	on DLG_Gladiators_ODS close do
	(
		-----------------------------------------------------------------------------------------------------------------------------
		-- ADD XLM TO ODS
		-----------------------------------------------------------------------------------------------------------------------------
		if cb_saveOnExit.checked == true do
			repackODS theODS theXMLPath
	)
)
createDialog DLG_Gladiators_ODS width:1000