--
--	\Tagger	
--	
--	\Description	Les outils ajoute ou supprime des balises à partir des objets sélectionnés. L'outil donne un coup de main dans le choix des objets avec un préfixe correspondant
--	\Description	
--	\Description	The tool appends or removes tags from selected objects. It lends a hand in selecting objects with the corresponding prefix.
--	
--	\author		anisim.kalugin@gameloft.com - Gameloft - 01/11/2012

--IMPORT LIBRARIES
fileIn ( GL_BLUR_MXS_LIB + "GL_Tag_Objects.ms" ) 
fileIn ( GL_BLUR_MXS_LIB + "GL_Untag_Objects.ms" )
fileIn ( GL_BLUR_MXS_LIB + "GL_Set_Wirecolor.ms" )
fileIn ( GL_BLUR_MXS_LIB + "GL_Set_User_Defined_Props.ms" )
fileIn ( GL_BLUR_MXS_LIB + "GL_Select_By_Wirecolor.ms" )

try (destroydialog dlg_tagger)catch()
dlg_tagger
--THE ROLL OUT OF tagger
(
	local working_dir = getFilenamePath (getThisScriptFilename())
	local ini_file = (working_dir + "tool.ini")
	local ini_pos = filterString (getINISetting ini_file "cur_tool"  "cur_coords") "[,],\,"
	local tool_coords = [ini_pos[1] as integer, ini_pos[2] as integer]
	
	rollout dlg_tagger "Tagger"
	(
		label  lbl_Title		"Tag Selected Objects or Select"
		button btn_TagAlpha 	width:24 height:24 tooltip: "Tag Mesh \"alpha\" " across:6
		button btn_UntagAlpha 	width:24 height:24 tooltip: "Untag Mesh \"alpha\"" 
		button btn_SelAlpha 	width:24 height:24 tooltip: "Select Mesh with \"alpha\" prefix" 
		button btn_TagCol		width:24 height:24 tooltip: "Tag Mesh with \"col\" prefix" 
		button btn_UntagCol		width:24 height:24 tooltip: "Untag Mesh \"col\" prefix" 
		button btn_SelCol		width:24 height:24 tooltip: "Select Mesh with \"col\" prefix" 
		
		button btn_TagHD 		width:24 height:24 tooltip: "Tag Mesh \"HD\"" across:6
		button btn_UntagHD 		width:24 height:24 tooltip: "Untag Mesh \"HD\""
		button btn_SelHD		width:24 height:24 tooltip: "Select Mesh \"HD\""
		button btn_TagDtl 		width:24 height:24 tooltip: "Tag Mesh \"dtl\""
		button btn_UntagDtl		width:24 height:24 tooltip: "Untag Mesh \"dtl\""
		button btn_SelDtl		width:24 height:24 tooltip: "Select Mesh \"dtl\""
		
		button btn_SetLM1		width:24 height:24 tooltip: "Set LM1" across:6
		button btn_SetLM2 		width:24 height:24 tooltip: "Set LM2" 
		button btn_SetLM3		width:24 height:24 tooltip: "Set LM3"
		button btn_SelLM1 		width:24 height:24 tooltip: "Select LM1" 
		button btn_SelLM2		width:24 height:24 tooltip: "Select LM2" 
		button btn_SelLM3		width:24 height:24 tooltip: "Select LM3"
		
		on btn_TagAlpha   pressed do (GL_Tag_Objects   "alpha")
		on btn_UntagAlpha pressed do (GL_Untag_Objects "alpha")
		on btn_SelAlpha	  pressed do 
		(
			select $*alpha_*
			local oSel = selection as array
			for obj in oSel do
			(
				if obj.ishidden ==  true then
				(
					deselect obj
				)
			)	
		)
	
		on btn_TagCol   pressed do (GL_Tag_Objects   "col")
		on btn_UntagCol pressed do (GL_Untag_Objects "col")
		on btn_SelCol	  pressed do 
		(
			select $*col_*
			local oSel = selection as array
			for obj in oSel do
			(
				if obj.ishidden ==  true then
				(
					deselect obj
				)
			)	
		)
		
		on btn_TagHD   pressed do (GL_Tag_Objects   "HD")
		on btn_UntagHD pressed do (GL_Untag_Objects "HD")
		on btn_SelHD   pressed do  
		(
			select $*HD_*
			local oSel = selection as array
			for obj in oSel do
			(
				if obj.ishidden ==  true then
				(
					deselect obj
				)
			)	
		)
		
		on btn_TagDtl   pressed do (GL_Tag_Objects   "dtl")
		on btn_UntagDtl pressed do (GL_Untag_Objects "dtl")
		on btn_SelDtl   pressed do  
		(
			select $*dtl_*
			local oSel = selection as array
			for obj in oSel do
			(
				if ( obj.ishidden ==  true ) then
				(
					deselect obj
				)
			)	
		)

		on btn_SetLM1 pressed do 
		( 
			GL_Set_Wirecolor (color 0 0 255)  
			GL_Set_User_Defined_Props "#LightMap" "LM1_"			
		)
		on btn_SetLM2 pressed do 
		( 
			GL_Set_Wirecolor (color 255 176 0)
			GL_Set_User_Defined_Props "#LightMap" "LM2_"			
		)
		on btn_SetLM3 pressed do 
		( 
			GL_Set_Wirecolor (color 200 0 100)
			GL_Set_User_Defined_Props "#LightMap" "LM3_"
		)
		on btn_SelLM1 pressed do ( GL_Select_By_Wirecolor (color 0 0 255)   )
		on btn_SelLM2 pressed do ( GL_Select_By_Wirecolor (color 255 176 0) )
		on btn_SelLM3 pressed do ( GL_Select_By_Wirecolor (color 200 0 100) )
		
		on dlg_tagger moved pos do
		(
			tool_coords = GetDialogPos dlg_tagger
		)
		on dlg_tagger close do
		(
			setINISetting ini_file "cur_tool"  "cur_coords"  (tool_coords as string)
		)
	)
	on execute do
	(
		createDialog dlg_tagger 180 120 
		SetDialogPos  dlg_tagger tool_coords
		--cui.RegisterDialogBar dlg_tagger style:#(#cui_handles,#cui_floatable,#cui_dock_all )
		--cui.DockDialogBar dlg_tagger #cui_dock_left
		icon_file = working_dir + "img\\tagger_ico.bmp"
		icon_bitmap = openBitmap (working_dir + "img\\tagger_ico.bmp")
		icon_count = case icon_bitmap.height of
											 (
												  24: icon_bitmap.width/24
												  default: icon_bitmap.width/16
											 ) 
		dlg_tagger.btn_TagAlpha.images 		= #(icon_file, undefined, icon_count,1,1,1,1, false, true)
		dlg_tagger.btn_UntagAlpha.images 	= #(icon_file, undefined, icon_count,2,2,1,1, false, true)
		dlg_tagger.btn_SelAlpha.images 		= #(icon_file, undefined, icon_count,3,3,1,1, false, true)
									 
		dlg_tagger.btn_TagCol.images 		= #(icon_file, undefined, icon_count,4,4,1,1, false, true)
		dlg_tagger.btn_UntagCol.images 		= #(icon_file, undefined, icon_count,5,5,1,1, false, true)
		dlg_tagger.btn_SelCol.images 		= #(icon_file, undefined, icon_count,6,6,1,1, false, true)	

		dlg_tagger.btn_TagHD.images 			= #(icon_file, undefined, icon_count,7,9,1,1, false, true)
		dlg_tagger.btn_UntagHD.images 		= #(icon_file, undefined, icon_count,8,9,1,1, false, true)
		dlg_tagger.btn_SelHD.images 			= #(icon_file, undefined, icon_count,9,9,1,1, false, true)										 

		dlg_tagger.btn_TagDtl.images 		= #(icon_file, undefined, icon_count,10,10,1,1, false, true)
		dlg_tagger.btn_UntagDtl.images 		= #(icon_file, undefined, icon_count,11,11,1,1, false, true)
		dlg_tagger.btn_SelDtl.images 		= #(icon_file, undefined, icon_count,12,12,1,1, false, true)
											 
		dlg_tagger.btn_SetLM1.images 		= #(icon_file, undefined, icon_count,13,13,1,1, false, true)
		dlg_tagger.btn_SetLM2.images 		= #(icon_file, undefined, icon_count,14,14,1,1, false, true)
		dlg_tagger.btn_SetLM3.images 		= #(icon_file, undefined, icon_count,15,15,1,1, false, true)

		dlg_tagger.btn_SelLM1.images 		= #(icon_file, undefined, icon_count,16,16,1,1, false, true)
		dlg_tagger.btn_SelLM2.images 		= #(icon_file, undefined, icon_count,17,17,1,1, false, true)
		dlg_tagger.btn_SelLM3.images 		= #(icon_file, undefined, icon_count,18,18,1,1, false, true)									 
	)
)
