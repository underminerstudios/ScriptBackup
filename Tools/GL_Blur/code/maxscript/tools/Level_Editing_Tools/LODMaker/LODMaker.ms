--
--	\Title			LOD Maker	
--	
--	\Description	Creates LODS from selected objects.
--	
--	\author		anisim.kalugin@gameloft.com - Gameloft - 01/11/2012


fn make_LODs LOD_Count:3 =
(
	oDivs = #()
	oAdd = 100/(LOD_Count+1)
	lodObjs = #()
	oSum = 0
	for i=1 to LOD_Count do
	(
		oSum += oAdd
		append oDivs oSum
	)

	for ob in selection do 
	(
		if ( superclassof ob == GeometryClass ) then
		(
			opti = MultiRes ()
			addmodifier ob opti
			opti.reqGenerate = off
 			suspendEditing();
			for i =1 to oDivs.count do
			(
				opti.VertexPercent = oDivs[i]
				lodObj = snapshot ob
				lodObj.name = (ob.name + "(LOD_" + i as string +  ")")
				lodObj.wirecolor = (color 28 28 28)
				append lodObjs (lodObj)
			)
			ResumeEditing();
			deleteModifier ob 1
		)
		for i = 1 to (lodObjs.count)  do
		(
			if  (lodObjs[i+1]!= undefined) then
			(
				lodObjs[i].parent = lodObjs[i+1]
			)
			else
			(
				lodObjs[i].parent =  ob
			)
		)
	)
)
make_LODs LOD_Count:3
