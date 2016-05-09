/*
	Assign Lightmaps

	This script will allow you to add lightmaps to multiple DirectX9 materials at the same time.
	These DirectX materials need a LightMap slot.
	
	Use "Select" to select a list of lightmaps.
	Use the drop down list to select one of these.
	Click "Assign" to add this lightmap to the materials of the current selected objects.
*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog assign_lightmap)catch()
rollout assign_lightmap "Assign Lightmap"
(
	local theFullPaths = #()
	dropdownlist ddl_lightmaps "Lightmaps:"
	button btn_select "Select" width:140
	button btn_assign "Assign" width:140
	
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
	
	fn fn_assign_lightmap nodes theLightmapPath =
	(
		progressStart "Assigning Lightmaps..."
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		
		local progresscount = 0
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			local theMaterial = n
			if classof theMaterial == DirectX_9_Shader do
			(
				if (CompatibleShader theMaterial.effectFile) == true do
				(
					local theLightmapBitmap = bitmaptexture()
					theLightmapBitmap.filename = theLightmapPath
					theMaterial.LightMap = theLightmapBitmap.bitmap
				)				
			)

			if classof theMaterial == multimaterial do
			(
				for i=1 to theMaterial.materialList.count do
				(
					if (classof theMaterial.materialList[i]) == DirectX_9_Shader do
					(
						if (CompatibleShader theMaterial.materialList[i].effectFile) == true do
						(
							local theLightmapBitmap = bitmaptexture()
							theLightmapBitmap.filename = theLightmapPath
							theMaterial.materialList[i].LightMap = theLightmapBitmap.bitmap
						)	
					)
				)
			)
		)
		progressEnd()
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
		fn_assign_lightmap selection theFullPaths[ddl_lightmaps.selection]
	)
)
createDialog assign_lightmap