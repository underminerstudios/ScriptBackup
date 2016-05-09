for f in (getFiles ((pathconfig.removepathleaf (getSourceFileName()) + "\\fn\\*.ms"))) do (filein f)

try(destroyDialog DLG_Gladiators_ODS)catch()
try(destroyDialog DLG_Armors_ODS)catch()
try(destroyDialog DLG_HAIR_ODS)catch()
try(destroyDialog DLG_HELMETS_ODS)catch()
try(destroyDialog DLG_SHIELDS_ODS)catch()
try(destroyDialog DLG_WEAPONS_ODS)catch()
rollout DLG_WEAPONS_ODS "WEAPONS ODS"
(
	local theODS = "P:\\data\\lottery\\Art.ods"
	local theWeapon = undefined
	local theXMLPath = "P:\\data\\lottery\\Art.xml"
	local theXML = undefined
	
	dropdownlist ddl_visualID "VisualID:" across:6
	dropdownlist ddl_assetbase "AssetBase:" enabled:false
	dropdownlist ddl_mesh "Mesh:" enabled:false
	dropdownlist ddl_material0 "Material 0:" enabled:false
	dropdownlist ddl_diffuse_tex_0 "Diffuse Tex 0:" enabled:false
	dropdownlist ddl_bump_tex_0 "Bump Tex 0:" enabled:false
	
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

		
		ddl_visualID.items = getList theXML "Weapons" "VisualID"
		ddl_assetbase.items = getAssetBaseList()
		ddl_mesh.items = getWeaponsListPIG()
		ddl_material0.items = getMaterialsCustomParts()
		
		local theDFs = getWeaponsList_DF_TGA()
		local sortedDFs = for n in theDFs collect (getFileNameFile n + ".tga")
		sort sortedDFs
		ddl_diffuse_tex_0.items =  sortedDFs
		
		local theNMs = getWeaponsList_NM_TGA()
		local sortedNMs = for n in theNMs collect (getFileNameFile n + ".tga")
		sort sortedNMs
		ddl_bump_tex_0.items = sortedNMs
		
		ddl_visualID.selection = 0
		ddl_assetbase.selection = 0
		ddl_mesh.selection = 0
		ddl_material0.selection = 0
		ddl_diffuse_tex_0.selection = 0
		ddl_bump_tex_0.selection = 0
		
		theXML
	)
	
	
	on DLG_WEAPONS_ODS open do
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
		
		local theAssetBase = getList theXML "Weapons" "AssetBase"
		ddl_assetbase.selection = findItem ddl_assetbase.items theAssetBase[arg]
		
		local theMesh = getList theXML "Weapons" "Mesh"
		ddl_mesh.selection = findItem ddl_mesh.items theMesh[arg]
		
		local theMaterial = getList theXML "Weapons" "Material 0"
		ddl_material0.selection = findItem ddl_material0.items theMaterial[arg]

		local theDiffuse = getList theXML "Weapons" "Diffuse Tex 0"
		ddl_diffuse_tex_0.selection = findItem ddl_diffuse_tex_0.items theDiffuse[arg]
		
		local theBump = getList theXML "Weapons" "Bump Tex 0"
		ddl_bump_tex_0.selection = findItem ddl_bump_tex_0.items theBump[arg]
		
		btn_add.enabled = true
		btn_delete.enabled = true
		

		------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Merge Hair 
		------------------------------------------------------------------------------------------------------------------------------------------------------
		
		local theMaxFile = getMaxFile "Q:\\gladiators\\" ((getFileNameFile theMesh[arg]) + "_LOD1")
		
		if theMaxFile != false then 
		(
			if theWeapon != undefined do
			(
				if (isdeleted theWeapon) == false do
					delete theWeapon
			)
			mergeMAXFile theMaxFile #(((getFileNameFile theMesh[arg]) + "_LOD1")) #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theWeapon = objects[objects.count]
			theWeapon.layer.ishidden = false
			unhide theWeapon
			select theWeapon
			actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected
			
			
			------------------------------------------------------------------------------------------------------------------------------------------------------
			-- Armor Material
			------------------------------------------------------------------------------------------------------------------------------------------------------
			
			local theDX = DirectX_9_Shader()
			theDX.effectfile = "Q:\\shaders\\armor\\armor.fx"
			theDX.name = theWeapon.name
			
			local theDFs = getWeaponsList_DF_TGA()
			for n in theDFs where (getFileNameFile (n as string)) == (getFileNameFile (theDiffuse[arg] as string)) do
			(
				local theDiffuse = bitmapTexture()
				theDiffuse.filename = n
				theDX.diffuseMap = theDiffuse.bitmap
			)
			
			local theNMs = getWeaponsList_NM_TGA()
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
			theSpec.filename = "Q:\\shaders\\armor\\Fx_SPEC_00_asset.tga"
			theDX.specPalette = theSpec.bitmap
			
			replaceInstances theWeapon.material theDX
		)
		else
		(
			messagebox (" Sorry a preview is not availalbe." + " The mesh " + (getFileNameFile ddl_mesh.items[arg]) + " was not found in any max file in the folder " + "\"" + "Q:\\gladiators\\" + "\"")
		)
		
		
		end = timeStamp()
		format "Processing took % seconds\n" ((end - start) / 1000.0)
		
	)
	
	on ddl_assetbase selected arg do
	(
		setValue theXML theXMLPath "Weapons" "AssetBase" "VisualID" ddl_visualID.selected ddl_assetbase.items[arg]
	)
	
	on ddl_mesh selected arg do
	(
		setValue theXML theXMLPath "Weapons" "Mesh" "VisualID" ddl_visualID.selected ddl_mesh.items[arg]
		

		local theMaxFile = getMaxFile "Q:\\gladiators\\" ((getFileNameFile ddl_mesh.items[arg]) + "_LOD1")
		
		if theMaxFile != false then
		(
			local theMaterial = undefined
			if theWeapon != undefined do
			(
				if (isdeleted theWeapon) == false do
				(
					theMaterial = theWeapon.material
					delete theWeapon
				)
			)
			mergeMAXFile theMaxFile #((getFileNameFile ddl_mesh.items[arg]) + "_LOD1") #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theWeapon = objects[objects.count]
			theWeapon.material = theMaterial
			theWeapon.layer.ishidden = false
			unhide theWeapon
			select theWeapon
			actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected
		)
		else
		(
			messagebox (" Sorry a preview is not availalbe." + " The mesh " + (getFileNameFile ddl_mesh.items[arg]) + " was not found in any max file in the folder " + "\"" + "Q:\\gladiators\\" + "\"")
		)
	)
	
	on ddl_material0 selected arg do
	(
		setValue theXML theXMLPath "Weapons" "Material 0" "VisualID" ddl_visualID.selected ddl_material0.items[arg]
	)
	
	on ddl_diffuse_tex_0 selected arg do
	(
		setValue theXML theXMLPath "Weapons" "Diffuse Tex 0" "VisualID" ddl_visualID.selected ddl_diffuse_tex_0.items[arg]

		local theDFs = getWeaponsList_DF_TGA()
		for n in theDFs where (getFileNameFile n) == (getFileNameFile ddl_diffuse_tex_0.items[arg]) do
		(
			local theDiffuse = bitmapTexture()
			theDiffuse.filename = n
			theWeapon.material.diffuseMap = theDiffuse.bitmap
		)
	)
	
	on ddl_bump_tex_0 selected arg do
	(
		setValue theXML theXMLPath "Weapons" "Bump Tex 0" "VisualID" ddl_visualID.selected ddl_bump_tex_0.items[arg]

		local theNMs = getWeaponsList_NM_TGA()
		for n in theNMs where (getFileNameFile n) == (getFileNameFile ddl_bump_tex_0.items[arg]) do
		(
			local theNormal = bitmapTexture()
			theNormal.filename = n
			theWeapon.material.normalMap = theNormal.bitmap
		)
	)
	
	on btn_add pressed do
	(
		if et_visualID.text != "" then
		(
			if (findItem ddl_visualID.items et_visualID.text) == 0 then
			(
				addNode theXML theXMLPath "Weapons" "VisualID" et_visualID.text
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
			deleteNode theXML theXMLPath "Weapons" "VisualID" ddl_visualID.items[ddl_visualID.selection]
			theXML = load_all theXMLPath
			if theWeapon != undefined do
			(
				if (isdeleted theWeapon) == false do
				(
					delete theWeapon
					theWeapon = undefined
				)
			)
		)
	)
	
	on DLG_WEAPONS_ODS close do
	(
		-----------------------------------------------------------------------------------------------------------------------------
		-- ADD XLM TO ODS
		-----------------------------------------------------------------------------------------------------------------------------
		if cb_saveOnExit.checked == true do
			repackODS theODS theXMLPath
		
	)
)
createDialog DLG_WEAPONS_ODS width:900