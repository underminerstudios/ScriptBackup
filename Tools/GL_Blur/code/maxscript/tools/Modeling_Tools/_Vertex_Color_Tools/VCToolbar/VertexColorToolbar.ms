--	\Title 		Vertex Color Tools 
--	
--	\Description	Un déploiement extrait de MC4 barre d'outils.
--	\Description	
--	\Description	A rollout extracted from MC4 Toolbar. 
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 01/22/2013

--IMPORT LIBRARIES
GL_Import_Lib #("GL_Get_GLBlurMXS", "GL_Set_Vertex_Color" )

try(destroydialog dlg_VertexColorTools)catch()
dlg_VertexColorTools --regirsters dialog

(
	local working_dir = getFilenamePath (getThisScriptFilename())
	-- Get_GLBlurMXS_Lib  function gets installed at startup
	local glblurMSX_scripts = (GL_Get_GLBlurMXS working_dir ) + "scripts\\"
	local ini_file = (working_dir + "tool.ini")
	local ini_pos = filterString (getINISetting ini_file "cur_tool"  "cur_coords") "[,],\,"
	local tool_coords = [ini_pos[1] as integer, ini_pos[2] as integer]

	
	rollout dlg_VertexColorTools "Vertex Color Tools"
	(
		bitmap the_bmp fileName:(working_dir  + "img/GL_gradient.bmp") offset:[-5,0]
		slider sld_black_white "" orient:#horizontal type:#integer ticks:0 range:[0,255,128]  
		Button btn_set_vcBlack "B"  width:24 across:3
		Button btn_set_vcWhite "W"  width:24 
		Button btn_color_picker "p"  width:24 
		Button btn_vertex_colorist "Vertex Colorist" width:128

		on sld_black_white changed val do 
		(
			GL_Set_Vertex_Color (color val val val)
		)
		on btn_color_picker pressed do
		(
			colorF3 = spColorPick() 
			if colorF3  !=  [-1,-1,-1] then 
			(
				if ( colorF3[1] != 0 or colorF3[2] != 0 or colorF3[3] != 0 ) then
				(
					_color = (255.0 * colorF3) as color
					GL_Set_Vertex_Color ( _color )
				)
			)
		)
		on btn_set_vcBlack pressed do
		(
			GL_Set_Vertex_Color ( color 0 0 0 )
		)
		on btn_set_vcWhite pressed do
		(
			GL_Set_Vertex_Color ( color 255 255 255 )
		)
		on btn_vertex_colorist pressed  do
		(
			fileIn (glblurMSX_scripts +  "VertexColorist.ms")
		)
	)
	on execute do
	(
		createDialog dlg_VertexColorTools width:170  --style:#(#style_sysmenu,#style_titlebar,#style_minimizebox,#style_resizing) 
		SetDialogPos dlg_VertexColorTools [tool_coords[1] , tool_coords[2]]
		
		icon_file = working_dir + "img/icons_24i.bmp"
		icon_bm = openBitmap icon_file
		icon_count = case icon_bm.height of
									 (
										  24: icon_bm.width/24
										  default: icon_bm.width/16
									 ) 
		dlg_VertexColorTools.btn_color_picker.images 		= #(icon_file, undefined, icon_count,1,1,1,1, false, true)
		dlg_VertexColorTools.btn_set_vcBlack.images 		= #(icon_file, undefined, icon_count,2,2,1,1, false, true)
		dlg_VertexColorTools.btn_set_vcWhite.images 		= #(icon_file, undefined, icon_count,3,3,1,1, false, true)

	)
)