--	\Title			Align UVs
--	
--	\Description	Aligner les UV à la moyenne des uvs sélectionnés.
--	\Description	
--	\Description	Align UVs to average of the selected uvs.
--	
--	\author		anisim.kalugin@gameloft.com - Gameloft - 06/11/2012

(
	oMainArr = #()
	oMod = modPanel.getCurrentObject() 
	--convert selection to vertex mode
	getSubMode = subobjectLevel
	if getSubMode == 2 then
	(
		oMod.edgeToVertSelect() 
		subobjectLevel = 1
	)
	if getSubMode == 3 then
	(
		oMod.faceToVertSelect() 
		subobjectLevel = 1
	)
	oUVSelection = oMod.getSelectedVertices() as array
	--first we filter out and get a single vert of each element 
	oFiltered_UV_Verts = #()
	for vv=1 to oUVSelection.count do 
		(
			oMod.selectVerticesByNode #{oUVSelection[vv]} $
			oMod.selectElement() 
			oElment_Verts = oMod.getSelectedVertices() as array
			--get the first UV vert of the element
			appendIfUnique oFiltered_UV_Verts (oElment_Verts[1])
		)
		
	--Now we get the information about the position of the UV elements.
	for vv=1 to oFiltered_UV_Verts.count do 
		(
			oTempArr = #()
			oMod.selectVerticesByNode #{oFiltered_UV_Verts[vv]} $
			oMod.selectElement() 
			oSelElement = oMod.getSelectedVertices() as array
			--Number_of_Verts += oSelElement.count
			sumUVPos = 0
			for zz=1 to oSelElement.count do 
			(
				oVert = oSelElement[zz]
				selVerts = (oMod.getVertexPosition 0 oVert)
				sumUVPos = sumUVPos + selVerts	
			)
			append oTempArr (sumUVPos/oSelElement.count)
			append oTempArr (oSelElement)
			append oMainArr (oTempArr )
			
		)
	UV_Destination = 0
	if oMainArr.count != 0 then
	(
		for item in oMainArr do
		(
			--print (item[1])
			UV_Destination += (item[1])
		)

		UV_Destination =  (UV_Destination/oMainArr.count)
	)

	for item in oMainArr do
	(
		print (item[2][1] )
		oMod.selectVerticesByNode #{item[2][1]} $
		oMod.selectElement() 
		oMod.MoveSelected (UV_Destination - item[1])
	)
	subobjectLevel = getSubMode
)