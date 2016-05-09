--	\Title 			UV Quad UV Layout 
--	
--	\Description	Déplace coquilles uv sur la base de ce qui est actuellement sélectionné. L'outil se déplace uv à quadrants correspondants dans l'atlas.
--	\Description	
--	\Description	Moves uv shells based on what is currently selected. The tool moves uv to corresponding quadrants in the atlas.
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 08/7/2012
try(destroyDialog dlg_QuadWallUV )catch()
dlg_QuadWallUV
(
	fn GL_UV_Move_Elements _quartal _modifier = 
	(
		local oUVData = #()
		local _modifier = modPanel.getCurrentObject() 
		--convert selection to vertex mode
		local get_submode = subobjectLevel
		undo on
		(
			if get_submode == 2 then
			(
				_modifier.edgeToVertSelect() 
				subobjectLevel = 1
			)
			if get_submode == 3 then
			(
				_modifier.faceToVertSelect() 
				subobjectLevel = 1
			)
			oUVSelection = _modifier.getSelectedVertices() as array
			--first we filter out and get a single vert of each element 
			oFiltered_UV_Verts = #()
			for vv=1 to oUVSelection.count do 
				(
					_modifier.selectVerticesByNode #{oUVSelection[vv]} $
					_modifier.selectElement() 
					oElment_Verts = _modifier.getSelectedVertices() as array
					--get the first UV vert of the element
					appendIfUnique oFiltered_UV_Verts (oElment_Verts[1])
				)

			for vv=1 to oFiltered_UV_Verts.count do
			(
				oUV_Vert_Pos_X = #()
				oUV_Vert_Pos_Y = #()
				_modifier.selectVerticesByNode #{oFiltered_UV_Verts [vv] } $
				_modifier.selectElement() 
				oSel_UV_Verts = _modifier.getSelectedVertices() as array
				for i=1 to oSel_UV_Verts.count do 
				(
					selVerts = (_modifier.getVertexPosition 0  oSel_UV_Verts[i])
					append oUV_Vert_Pos_X (selVerts.x)
					append oUV_Vert_Pos_Y (selVerts.y)
				)
				sort oUV_Vert_Pos_X
				sort oUV_Vert_Pos_Y
				local max_x = oUV_Vert_Pos_X[oUV_Vert_Pos_X.count]
				local max_y = oUV_Vert_Pos_Y[oUV_Vert_Pos_Y.count]
				local min_x =  oUV_Vert_Pos_X[1]
				local min_y = oUV_Vert_Pos_Y[1]
				local center_x =(max_x + min_x)/2
				local center_y = (max_y + min_y)/2
				local UVcenter  = [center_x, center_y, 0]
				local scaleX  = (.499/((min_x - (min_x*2)) + max_x))
				local scaleY = (.499/((min_y - (min_y*2)) + max_y))
				local UV_Move_TL =  ((UVcenter - [0.25, 0.25, 0]) - ((UVcenter - [0.25, 0.5, 0]) *2) )
				local UV_Move_TR =  ((UVcenter - [0.25, 0.25, 0]) - ((UVcenter - [0.50, 0.5, 0]) *2) )
				local UV_Move_BL =  ((UVcenter - [0.25, 0.75, 0]) - ((UVcenter - [0.25, 0.5, 0]) *2) )
				local UV_Move_BR =  ((UVcenter - [0.25, 0.75, 0]) - ((UVcenter - [0.5, 0.5, 0]) *2) )
				_modifier.ScaleSelectedXY scaleX scaleY [center_x,center_y ,0]
				if _quartal == "TL" then
				(
					_modifier.MoveSelected UV_Move_TL
				)
				if _quartal == "TR" then
				(
					_modifier.MoveSelected UV_Move_TR 
				)
				if _quartal == "BL" then
				(
					_modifier.MoveSelected UV_Move_BL
				)
				if _quartal == "BR" then
				(
					_modifier.MoveSelected UV_Move_BR
				)
			)
		)
	)

	fn GL_UV_Move_Selection _quartal _modifier = 
	(
		local oUVData = #()
		local oUV_Vert_Pos_X = #()
		local oUV_Vert_Pos_Y = #()
		local get_submode = subobjectLevel
		undo on
		(
			if get_submode == 2 then
			(
				_modifier.edgeToVertSelect() 
				subobjectLevel = 1
			)
			if get_submode == 3 then
			(
				_modifier.faceToVertSelect() 
				subobjectLevel = 1
			)
			_modifier.selectElement() 
			oSel_UV_Verts = _modifier.getSelectedVertices() as array
			for i=1 to oSel_UV_Verts.count do 
			(
				selVerts = (_modifier.getVertexPosition 0  oSel_UV_Verts[i])
				--print (selVerts)
				append oUV_Vert_Pos_X (selVerts.x)
				append oUV_Vert_Pos_Y (selVerts.y)
			)
			sort oUV_Vert_Pos_X
			sort oUV_Vert_Pos_Y
			local max_x = oUV_Vert_Pos_X[oUV_Vert_Pos_X.count]
			local max_y = oUV_Vert_Pos_Y[oUV_Vert_Pos_Y.count]
			local min_x =  oUV_Vert_Pos_X[1]
			local min_y = oUV_Vert_Pos_Y[1]
			local center_x =(max_x + min_x)/2
			local center_y = (max_y + min_y)/2
			local UVcenter  = [center_x, center_y, 0]
			local scaleX  = (.499/((min_x - (min_x*2)) + max_x))
			local scaleY = (.499/((min_y - (min_y*2)) + max_y))
			local UV_Move_TL =  ((UVcenter - [0.25, 0.25, 0]) - ((UVcenter - [0.25, 0.5, 0]) *2) )
			local UV_Move_TR =  ((UVcenter - [0.25, 0.25, 0]) - ((UVcenter - [0.50, 0.5, 0]) *2) )
			local UV_Move_BL =  ((UVcenter - [0.25, 0.75, 0]) - ((UVcenter - [0.25, 0.5, 0]) *2) )
			local UV_Move_BR =  ((UVcenter - [0.25, 0.75, 0]) - ((UVcenter - [0.5, 0.5, 0]) *2) )
			_modifier.ScaleSelectedXY scaleX scaleY [center_x,center_y ,0]
			if _quartal == "TL" then
			(
				_modifier.MoveSelected UV_Move_TL
			)
			if _quartal == "TR" then
			(
				_modifier.MoveSelected UV_Move_TR 
			)
			if _quartal == "BL" then
			(
				_modifier.MoveSelected UV_Move_BL
			)
			if _quartal == "BR" then
			(
				_modifier.MoveSelected UV_Move_BR
			)
		)
	)
	local working_dir = getFilenamePath (getThisScriptFilename())
	local ini_file = (working_dir + "tool.ini")
	local ini_pos = filterString (getINISetting ini_file "cur_tool"  "cur_coords") "[,],\,"
	local tool_coords = [ini_pos[1] as integer, ini_pos[2] as integer]
	local ini_cbx_elements = (getINISetting ini_file "cur_tool"  "cbx_elements") as booleanclass
	local ini_cbtn_persistence = (getINISetting ini_file "cur_tool"  "cbtn_persistence") as booleanclass
	local cur_modifier = modPanel.getCurrentObject() 
	local get_submode
	rollout dlg_QuadWallUV "Quad Wall UVs"
	(
		checkbox cbx_Elements	"Elements" checked:ini_cbx_elements offset:[2,0]  tooltip:"Checked works on each UV element"
		button btn_topLeft		"TL" width:35 height:35 border:false across:2
		button btn_topRight 	"TR" width:35 height:35 border:false 
		button btn_botLeft 		"BL" width:35 height:35 border:false offset:[0,-7] across:2
		button btn_botRight 	"BR" width:35 height:35 border:false offset:[0,-7] 
		checkbutton cbtn_persistence "PERSISTANT" width:69  offset:[4,-5] checked:ini_cbtn_persistence tooltip:"Makes the tools stay"
		

		on btn_topLeft pressed do
		(
			if cbx_Elements.state == true then
			(
				local submode = subobjectLevel
				GL_UV_Move_Elements  "TL" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)
			else
			(
				local submode = subobjectLevel
				GL_UV_Move_Selection  "TL" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)
		)
		on btn_topRight pressed do
		(
			if cbx_Elements.state == true then
			(
				local submode = subobjectLevel
				GL_UV_Move_Elements  "TR" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)
			else
			(
				local submode = subobjectLevel
				GL_UV_Move_Selection  "TR" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)
		)			
		on btn_botLeft pressed do
		(
			if cbx_Elements.state == true then
			(
				local submode = subobjectLevel
				GL_UV_Move_Elements  "BL" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)
			else
			(
				local submode = subobjectLevel
				GL_UV_Move_Selection  "BL" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)			
		) 
		on btn_botRight pressed do
		(
			if cbx_Elements.state == true then
			(
				local submode = subobjectLevel
				GL_UV_Move_Elements "BR" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)
			else
			(
				local submode = subobjectLevel
				GL_UV_Move_Selection "BR" cur_modifier
				subobjectLevel = submode
				if ( cbtn_persistence.state != true ) then
				(
					try(destroyDialog dlg_QuadWallUV )catch()
				)
			)			
		) 
		on dlg_QuadWallUV moved pos do
		(
			tool_coords = GetDialogPos dlg_QuadWallUV
		)
		on dlg_QuadWallUV close do
		(
			setINISetting ini_file "cur_tool" "cur_coords"  (tool_coords as string)
			setINISetting ini_file "cur_tool" "cbx_elements" (cbx_Elements.state as string)
			setINISetting ini_file "cur_tool" "cbtn_persistence" (cbtn_persistence.state as string)
		)
	)
	
	if ( classof cur_modifier == Unwrap_UVW ) then 
	(
		get_submode = subobjectLevel
		if get_submode == 2 then
		(
			cur_modifier.edgeToVertSelect() 
			subobjectLevel = 1
		)
		if get_submode == 3 then
		(
			cur_modifier.faceToVertSelect() 
			subobjectLevel = 1
		)
		createDialog dlg_QuadWallUV 85 120 -- style:#(#style_sunkenedge)
		SetDialogPos dlg_QuadWallUV tool_coords
		
		local icon_file = working_dir + "img\\ico.bmp"
		local icon_bitmap = openBitmap (icon_file)
		local icon_count = case icon_bitmap.height of
											 (
												  32: icon_bitmap.width/32
												  default: icon_bitmap.width/16
											 )
		dlg_QuadWallUV.btn_topLeft.images 		= #(icon_file, undefined, icon_count,1,1,1,1, false, true)
		dlg_QuadWallUV.btn_topRight.images 		= #(icon_file, undefined, icon_count,2,2,1,1, false, true)
		dlg_QuadWallUV.btn_botLeft.images 		= #(icon_file, undefined, icon_count,3,3,1,1, false, true)
		dlg_QuadWallUV.btn_botRight.images 		= #(icon_file, undefined, icon_count,4,4,1,1, false, true)
	)
	else
	(
		messagebox("Select an object with a UVUnwrap Modifier")
	)	
)