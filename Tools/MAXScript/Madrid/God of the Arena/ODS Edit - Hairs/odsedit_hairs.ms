for f in (getFiles ((pathconfig.removepathleaf (getSourceFileName()) + "\\fn\\*.ms"))) do (filein f)

try(destroyDialog DLG_Gladiators_ODS)catch()
try(destroyDialog DLG_Armors_ODS)catch()
try(destroyDialog DLG_HAIR_ODS)catch()
try(destroyDialog DLG_HELMETS_ODS)catch()
try(destroyDialog DLG_SHIELDS_ODS)catch()
try(destroyDialog DLG_WEAPONS_ODS)catch()
rollout DLG_HAIR_ODS "Hairs ODS"
(
	local theODS = "P:\\data\\lottery\\Art.ods"
	local theHair = undefined
	local theFacialHair = undefined
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

		
		ddl_visualID.items = getList theXML "Hairs" "VisualID"
		ddl_assetbase.items = getAssetBaseList()
		ddl_mesh.items = getHairsListPIG()
		ddl_material0.items = getMaterialsCustomParts()
		
		local theDFs = getHairsList_DF_TGA()
		local sortedDFs = for n in theDFs collect (getFileNameFile n + ".tga")
		sort sortedDFs
		ddl_diffuse_tex_0.items =  sortedDFs
		
		local theNMs = getHairsList_NM_TGA()
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
	
	
	on DLG_HAIR_ODS open do
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
		
		local theAssetBase = getList theXML "Hairs" "AssetBase"
		ddl_assetbase.selection = findItem ddl_assetbase.items theAssetBase[arg]
		
		local theMesh = getList theXML "Hairs" "Mesh"
		ddl_mesh.selection = findItem ddl_mesh.items theMesh[arg]
		
		local theMaterial = getList theXML "Hairs" "Material 0"
		ddl_material0.selection = findItem ddl_material0.items theMaterial[arg]

		local theDiffuse = getList theXML "Hairs" "Diffuse Tex 0"
		ddl_diffuse_tex_0.selection = findItem ddl_diffuse_tex_0.items theDiffuse[arg]
		
		local theBump = getList theXML "Hairs" "Bump Tex 0"
		ddl_bump_tex_0.selection = findItem ddl_bump_tex_0.items theBump[arg]
		
		btn_add.enabled = true
		btn_delete.enabled = true
		
		
		------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Merge Hair 
		------------------------------------------------------------------------------------------------------------------------------------------------------
		
		local theMaxFile = getMaxFile "Q:\\gladiators\\" (getFileNameFile theMesh[arg])
		
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
			mergeMAXFile theMaxFile #((getFileNameFile theMesh[arg])) #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theHair = objects[objects.count]
			theHair.layer.ishidden = false
			unhide theHair
			select theHair
			mergeMAXFile theMaxFile #(substitutestring (getFileNameFile theMesh[arg]) "hair" "facialhair") #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
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
			for n in theDFs where (getFileNameFile (n as string)) == (getFileNameFile (theDiffuse[arg] as string)) do
			(
				local theDiffuse = bitmapTexture()
				theDiffuse.filename = n
				theHair.material.diffuseMap = theDiffuse.bitmap
			)
			
			--NormalMap
			local theNMs = getHairsList_NM_TGA()
			for n in theNMs where (getFileNameFile (n as string)) == (getFileNameFile (theBump[arg] as string)) do
			(
				local theNormal = bitmapTexture()
				theNormal.filename = n
				theHair.material.normalMap = theNormal.bitmap
			)
			
			--tintColor
			local theColor = getHairColor theMaterial[arg]
			if theColor != false do
			(
				theHair.material.tintColor = theColor
			)
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
		setValue theXML theXMLPath "Hairs" "AssetBase" "VisualID" ddl_visualID.selected ddl_assetbase.items[arg]
	)
	
	on ddl_mesh selected arg do
	(
		setValue theXML theXMLPath "Hairs" "Mesh" "VisualID" ddl_visualID.selected ddl_mesh.items[arg]
		
		local theMaxFile = getMaxFile "Q:\\gladiators\\" (getFileNameFile ddl_mesh.items[arg])
		
		if theMaxFile != false then
		(
			local theMaterial = undefined
			if theHair != undefined do
			(
				if (isdeleted theHair) == false do
				(
					theMaterial = theHair.material
					delete theHair
				)
			)
			if theFacialHair != undefined do
			(
				if(isdeleted theFacialHair) == false do
				(
					delete theFacialHair
				)
			)
			
			mergeMAXFile theMaxFile #((getFileNameFile ddl_mesh.items[arg])) #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theHair = objects[objects.count]
			theHair.material = theMaterial
			theHair.layer.ishidden = false
			unhide theHair
			select theHair
			
			actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected
			
			mergeMAXFile theMaxFile #(substitutestring (getFileNameFile ddl_mesh.items[arg]) "hair" "facialhair") #noRedraw #select #deleteOldDups #useMergedMtlDups  quiet:true
			theFacialHair = objects[objects.count]
			theFacialHair.material = theMaterial
			theFacialHair.layer.ishidden = false
			unhide theFacialHair
			select theFacialHair
			
			
		)
		else
		(
			messagebox (" Sorry a preview is not availalbe." + " The mesh " + (getFileNameFile ddl_mesh.items[arg]) + " was not found in any max file in the folder " + "\"" + "Q:\\gladiators\\" + "\"")
		)
	)
	
	on ddl_material0 selected arg do
	(
		setValue theXML theXMLPath "Hairs" "Material 0" "VisualID" ddl_visualID.selected ddl_material0.items[arg]
		local theColor = getHairColor ddl_material0.items[arg]
		if theColor != false do
		(
			theHair.material.tintColor = theColor
			theFacialHair.material.tintColor = theColor
		)
	)
	
	on ddl_diffuse_tex_0 selected arg do
	(
		setValue theXML theXMLPath "Hairs" "Diffuse Tex 0" "VisualID" ddl_visualID.selected ddl_diffuse_tex_0.items[arg]
		local theDFs = getHairsList_DF_TGA()
		for n in theDFs where (getFileNameFile n) == (getFileNameFile ddl_diffuse_tex_0.items[arg]) do
		(
			local theDiffuse = bitmapTexture()
			theDiffuse.filename = n
			theHair.material.diffuseMap = theDiffuse.bitmap
			theFacialHair.material.diffuseMap = theDiffuse.bitmap
		)
	)
	
	on ddl_bump_tex_0 selected arg do
	(
		setValue theXML theXMLPath "Hairs" "Bump Tex 0" "VisualID" ddl_visualID.selected ddl_bump_tex_0.items[arg]
		local theNMs = getHairsList_NM_TGA()
		for n in theNMs where (getFileNameFile n) == (getFileNameFile ddl_bump_tex_0.items[arg]) do
		(
			local theNormal = bitmapTexture()
			theNormal.filename = n
			theHair.material.normalMap = theNormal.bitmap
			theFacialHair.material.normalMap = theNormal.bitmap
		)
	)
	
	on btn_add pressed do
	(
		if et_visualID.text != "" then
		(
			if (findItem ddl_visualID.items et_visualID.text) == 0 then
			(
				addNode theXML theXMLPath "Hairs" "VisualID" et_visualID.text
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
			deleteNode theXML theXMLPath "Hairs" "VisualID" ddl_visualID.items[ddl_visualID.selection]
			theXML = load_all theXMLPath
			if theHair != undefined do
			(
				if (isdeleted theHair) == false do
				(
					delete theHair
					theHair = undefined
				)
			)
			if theFacialHair != undefined do
			(
				if (isdeleted theFacialHair) == false do
				(
					delete theFacialHair
					theFacialHair = undefined
				)
			)
		)
	)
	
	on DLG_HAIR_ODS close do
	(
		-----------------------------------------------------------------------------------------------------------------------------
		-- ADD XLM TO ODS
		-----------------------------------------------------------------------------------------------------------------------------
		if cb_saveOnExit.checked == true do
			repackODS theODS theXMLPath
	)
)
createDialog DLG_HAIR_ODS width:900