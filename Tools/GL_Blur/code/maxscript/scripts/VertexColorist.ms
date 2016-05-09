--
--	\Title 		Vertex Colorist
--	
--	\Description	Génère des couleurs de vertex sur un des objets de maillage en utilisant une image bitmap et le canal UV2
--	\Description	
--	\Description	Generates vertex colors on a mesh object(s) using a bitmap and uv channel 2. 
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 8/17/2012
try(destroydialog dlg_vcolorist) catch()
dlg_vcolorist
(
	fn _main_vcolorist img_path =
	(
		local map_to_vcolor = MapToVColor ()
		map_to_vcolor.mapChannel = 2
		map_to_vcolor.MapBlur = 0
		map_to_vcolor.map = Bitmaptexture fileName:img_path

		local uv_mod = Unwrap_UVW ()
		uv_mod.unwrap.setMapChannel 2
		uv_mod.settvsubobjectmode 3

		local oSel = selection as array
		with redraw off
		
		SuspendEditing()
		for obj in oSel do
		(
		-- 	select obj
			if classof obj != Editable_Poly then
			(
				convertToPoly obj
			)
			obj.showVertexColors = true
			obj.EditablePoly.SetSelection #Edge #{1.. polyop.getNumEdges(obj) }
			obj.EditablePoly.splitEdges ();
			addmodifier obj map_to_vcolor
			maxOps.CollapseNodeTo obj 1 off
			
			obj.EditablePoly.SetSelection #Vertex #{1.. polyop.getNumVerts (obj)}
			obj.EditablePoly.weldFlaggedVertices ()
			
			addmodifier obj uv_mod
			obj.modifiers[1].unwrap2.selectFaces (obj.faces as bitarray)
			obj.modifiers[1].unwrap2.ScaleSelectedXY 0.0 0.0 [0.999,0.999,0]
			maxOps.CollapseNodeTo obj 1 off
		)
		ResumeEditing()
		select oSel
	)
-- SET UP THE ROLLOUT	
	local working_dir = getFilenamePath (getThisScriptFilename())
	local ini_file = (working_dir + "VertexColoristTool.ini")
	local ini_pos = filterString (getINISetting ini_file "cur_tool"  "cur_coords") "[,],\,"
	local tool_coords = [ini_pos[1] as integer, ini_pos[2] as integer]
	local vcolorist_path = getINISetting ini_file "cur_tool"  "img_path"
	local oPosStr = filterString (getINISetting ini_file "cur_tool"  "cur_coords") "[,],\,"
	
	if oPosStr.count > 0 then
	(
		vcolorist_coords = [oPosStr[1] as integer, oPosStr[2] as integer]
	)
	else
	(
		vcolorist_coords = [100, 100]	
	)

	rollout dlg_vcolorist "Vertex Colorist"
	(
		edittext edt_ImagePath "" text: "" fieldWidth:180 across:2
		button btn_browse  "..." width:20 offset:[50,0]
		button btn_convertToVC  "Convert to Vetex Color"
		on btn_browse pressed do
		(
			local oPhile
			--tests to see if the path in the dialog box is valid 
			if edt_ImagePath.text != "" or edt_ImagePath.text != undefined then
			(
				testPath = getFilenamePath edt_ImagePath.text
				if (doesFileExist testPath) == false then
				(
					oPhile = getOpenFileName filename:("C:\\") caption:"Render To Texture Object Presets Open" types:"Targa(*.TGA)|*.tga"
				)
				else
				(
					oPhile = getOpenFileName filename:(edt_ImagePath.text) caption:"Render To Texture Object Presets Open" types:"Targa(*.TGA)|*.tga"
				)
			)
			if oPhile == undefined then 
			(
				Print ("Image is required for this tool to work")
			)
			else
			(
				edt_ImagePath.text = oPhile as string
			)
		)
		on btn_convertToVC pressed do 
		(
			if edt_ImagePath.text == "" then 
			(
				Messagebox ("Need an image to work")
			)
			else
			(
				if (doesFileExist (edt_ImagePath.text) == false ) then
				(
					Messagebox ("File doesn't appear to exist in the given path")
				)
				else
				(
					Max Modify Mode
					_main_vcolorist edt_ImagePath.text
				)
			)
		)
		on dlg_vcolorist close do
		(
			vcolorist_path  = edt_ImagePath.text
			vcolorist_coords  = GetDialogPos dlg_vcolorist
			print vcolorist_path
			setINISetting ini_file "cur_tool"  "img_path"  (edt_ImagePath.text)
			setINISetting ini_file "cur_tool"  "cur_coords"  (vcolorist_coords as string)
		)
	)
	
	local working_dir  = getFilenamePath (getThisScriptFilename())
	local mxs_global_lib =  GL_Get_GLBlurMXS working_dir
	if (is64bitapplication() == true ) then 
	(		
		local plugin_check = (GetDir #maxroot ) + "stdplugs\MapToVColor_64.dlm"
		if ( (getfiles plugin_check).count == 0 ) then 
		(
			Messagebox ("\"MapToVColor_64.dlm\" doesn't exist! \n Please install the 64bit plugin. \nOpening library link")
-- 			shellLaunch "http://www.rpmanager.com/plugins/MapToVColor.htm" ""
			shellLaunch (mxs_global_lib  + "\\common\\MapToVColor\\")  ""
		)
		else
		(
			createDialog dlg_vcolorist 225 75 style:#(#style_sysmenu,#style_titlebar) 
			SetDialogPos  dlg_vcolorist vcolorist_coords
			dlg_vcolorist.edt_ImagePath.text = vcolorist_path
		)
	)
	else
	(
		local plugin_check = (GetDir #maxroot ) + "stdplugs\MapToVColor.dlm"
		if ( (getfiles plugin_check).count == 0 ) then 
		(
			Messagebox ("\"MapToVColor.dlm\" doesn't exist! \n Please install the 32bit plugin. \nOpening library link")
			shellLaunch (mxs_global_lib  + "\\common\\MapToVColor\\")  ""
		)
		else
		(

			createDialog dlg_vcolorist 225 75 style:#(#style_sysmenu,#style_titlebar) 
			SetDialogPos  dlg_vcolorist vcolorist_coords
			dlg_vcolorist.edt_ImagePath.text = vcolorist_path
		)
	)

)
