--
--	\Title 		Vray Light Subdivider
--	
--	\Description	Ajouter subdivisions de lumières Vray sélectionnés ou à toutes les lumières de la scène Vray.
--	\Description	
--	\Description	Add subdivisions to selected Vray lights or to all the Vray lights in the scene..
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 12/7/2011
try(destroydialog dlg_light_subdivisions) catch()
dlg_light_subdivisions
(
	local working_dir = getFilenamePath (getThisScriptFilename())
	local ini_file = (working_dir + "tool.ini")
	local ini_pos = filterString (getINISetting ini_file "cur_tool"  "cur_coords") "[,],\,"
	local tool_coords = [ini_pos[1] as integer, ini_pos[2] as integer]
	
	rollout dlg_light_subdivisions "Settings"
	(	
		spinner spn_lightSubD "Light Subdivision:" range:[1,200,8] type:#integer fieldwidth:20 across:2 
		checkbox cbx_SelLights  "Selected Lights" checked:false offset:[10,0]
		button btn_SetLightSub "Set Light Subdivision" width:235 

		on btn_SetLightSub pressed do 
		(
			if  (cbx_SelLights.state == true)then
			(
				undo on
				(
					for zz in selection do
					(
						if ( classof zz == VRayLight or classof zz == VRaySun ) then
						(
							if (hasProperty zz "subdivs") == true then
							(
								zz.subdivs = spn_lightSubD.value
							)
							if (hasProperty zz "shadow_subdivs") == true then
							(
								zz.shadow_subdivs = spn_lightSubD.value
							)
						)
					)
				)
			)
			else
			(
				undo on
				(
					for zz in lights do
					(
						if ( classof zz == VRayLight and (hasProperty zz "subdivs") == true ) then
						(
							zz.subdivs = spn_lightSubD.value
						)
						if classof zz == VRaySun and (hasProperty zz "shadow_subdivs") == true then
						(
							zz.shadow_subdivs = spn_lightSubD.value
						)
					)
				)
			)
		)
		on dlg_light_subdivisions moved pos do
		(
			tool_coords = GetDialogPos dlg_light_subdivisions
		)
		on dlg_light_subdivisions close do
		(
			setINISetting ini_file "cur_tool"  "cur_coords"  (tool_coords as string)
		)
	)
	
	on execute do
	(
		createDialog dlg_light_subdivisions width:250 height:50
		SetDialogPos  dlg_light_subdivisions tool_coords
	)
)