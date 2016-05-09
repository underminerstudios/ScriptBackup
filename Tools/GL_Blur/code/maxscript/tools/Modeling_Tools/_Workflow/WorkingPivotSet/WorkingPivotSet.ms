--
--	\Title			Working Pivot Set	
--	
--	\Description	Définit un pivot de travail temporaire.
--	\Description	
--	\Description	Sets a temporary working pivot.
--	
--	\author		anisim.kalugin@gameloft.com - Gameloft - 06/11/2012


(
	max modify mode
	local oSel  = selection as array
	local subMode = subobjectLevel
	local transformType = toolmode.commandmode
	
	if oSel.count == 1 then
	(
		local oMod = modPanel.getCurrentObject()

		if (classof oMod  != PolyMeshObject or classof oMod !=  Editable_Poly ) then 
		(
			if (superclassof oMod == GeometryClass) then
			(
				convertTo oSel[1] PolyMeshObject
			)
		)
		if (classof oMod == PolyMeshObject or classof oMod == Editable_Poly )then 
		(
			local obj = oSel[1]
			if (subMode == 0 ) then
			(
				local bb_max = obj.max
				local bb_min = obj.min
				local x_pos = (bb_max.x + bb_min.x) / 2
				local y_pos =(bb_max.y + bb_min.y) / 2
				local z_pos =(bb_max.z + bb_min.z) / 2
				with redraw off
				(
					local _center = [x_pos, y_pos, z_pos]
					WorkingPivot.EditMode = true
					move $ (_center - $.position )
					WorkingPivot.UseMode = true 
					WorkingPivot.EditMode = false
					toolmode.commandmode = transformType 
				)
			)
			else
			(
				obj.ConvertSelection subMode  #Vertex
				selVerts = obj.selectedVerts
				local vertCount = obj.selectedVerts.count
				sumPos = 0
				for S=1 to selVerts.count do
				(
					sumPos = sumPos + selVerts[S].pos 
				)
				_center = sumPos/vertCount
				WorkingPivot.EditMode = true
				move $ (_center - $.position )
				WorkingPivot.UseMode = true 
				WorkingPivot.EditMode = false
				toolmode.commandmode = transformType 
			)
		)
		else
		(
			print ("Need atleast one object or object is not a ")
		)
	)
	if oSel.count > 1 then
	(
		print ("Not implemented");
	)
	if oSel.count == 0 then
	(
		print ("select something");
	)
)