/*
	Assign Texture
	
	This script will allow you to assign a texture to a specific slot for multiple objects

*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog ASSIGN_TEXTURE)catch()
rollout ASSIGN_TEXTURE "Assign Texture"
(
	edittext et_path "Texture:" readonly:true labelontop:true width:450 across:2
	button btn_browse "..." align:#right pos:[465,20]
	
	dropdownlist ddl_slots "Slot:" items:#("Ambient Color", "Diffuse", "Specular Color", "Specular Level", "Glossiness", "Self-Illumination", "Opacity", "Filter Color", "Bump", "Reflection", "Refraction", "Displacement")
	
	button btn_assign "Assign" width:100
	
	
	on btn_browse pressed do
	(
		local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select Image File" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "Image Files (*.BMP, *.JPG, *.PNG, *.TIF, *.TGA, *.PSD)|*.bmp;*.jpg;*.png;*.tif;*.tga;*.psd" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		local theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
		
		if theFilenames[1] != undefined do (et_path.text = theFilenames[1])
	)
	
	on btn_assign pressed do
	(
		if et_path.text != "" do
		(
			local theMaterials = #()
			for n in selection where classof n.material == StandardMaterial OR classof n.material == MultiSubMaterial do
			(
				appendifunique theMaterials n.material
			)
			
			for m in theMaterials do
			(
				if classof m == StandardMaterial do
				(
					local theBitmap = BitmapTexture()
					theBitmap.filename = et_path.text
					m.maps[ddl_slots.selection] = theBitmap
				)
				if classof m == MultiSubMaterial do
				(
					for i=1 to m.materialList.count do
					(
						if (classof m.materialList[i]) == StandardMaterial do
						(
							local theBitmap = BitmapTexture()
							theBitmap.filename = et_path.text
							m.materialList[i].maps[ddl_slots.selection] = theBitmap
						)
					)
				)
			)
		)
	)
)
createDialog ASSIGN_TEXTURE width:500