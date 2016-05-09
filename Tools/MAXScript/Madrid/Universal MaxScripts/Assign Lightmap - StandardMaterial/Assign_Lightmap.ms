try(destroyDialog DLG_ASSIGN_LIGHTMAP_STD)catch()
rollout DLG_ASSIGN_LIGHTMAP_STD "Assign Lightmap - Standard"
(
	local theFullPaths = #()
	dropdownlist ddl_lightmaps "Lightmaps:"
	button btn_select "Select" width:140
	button btn_assign "Assign" width:140
	
	
	fn fn_assign_LM theMaterial theLightMapFile =
	(
		if theMaterial.diffuseMap != undefined do
		(
			if (classof theMaterial.diffuseMap) == bitmapTexture then
			(
				local theDiffuseTexture = theMaterial.diffuseMap
				local theComposite = CompositeTexturemap()
				theComposite.mapList[1] = theDiffuseTexture
				local theLightMap = bitmapTexture()
				theLightMap.filename = theLightMapFile
				theLightMap.Coordinates.mapChannel = 2
				theLightMap.alphaSource = 2
				theComposite.mapList[2] = theLightMap
				theComposite.blendMode[2] = 5
				
				theMaterial.diffuseMap = theComposite
			)
			else
			(
				if (classof theMaterial.diffuseMap) == CompositeTextureMap do
				(
					theMaterial.diffuseMap.mapList[2].filename = theLightMapFile
				)
			)
		)
	)
	
	on btn_select pressed do
	(
		local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select a lightmap" --set the title
		theDialog.Multiselect = true --allow multiple files to be selected
		theDialog.Filter = "Targa Image File (*.tga)|*.tga" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		local result = (theDialog.showDialog()).ToString() --display the dialog, get result into variable
		local theFilenames = theDialog.fileNames --the selected filenames will be returned as an array

		if result != "Cancel" do
		(
			for n in theFilenames do (appendifunique theFullPaths n)
			ddl_lightmaps.items = for n in theFullPaths collect (filenamefrompath n)
		)
	)
	
	on btn_assign pressed do
	(
		for n in selection do
		(
			local theMaterial = n.material
			if classof theMaterial == multimaterial do
			(
				for i=1 to theMaterial.materialList.count do
				(	
					if classof theMaterial.materialList[i] == standardmaterial do
					(
						fn_assign_LM theMaterial.materialList[i] theFullPaths[ddl_lightmaps.selection]
					)
				)
			)
			if classof theMaterial == standardmaterial do
			(
				fn_assign_LM theMaterial theFullPaths[ddl_lightmaps.selection]
			)
		)
	)
)
createDialog DLG_ASSIGN_LIGHTMAP_STD