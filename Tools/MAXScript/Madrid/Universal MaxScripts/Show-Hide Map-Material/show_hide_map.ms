/*
	Show/Hide Map/Material
	Show Map: Will show the Diffuse Map if found.
	Hide Map: Will hide the Diffuse Map if found.
	Show Material: Will turn on "Show Standard Map in Viewport" for all the selected object's materials.
	Hide Material: Will turn off "Show Standard Map in Viewport" for all the selected object's materials.
*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog dlg_ShowInViewport)catch()
rollout dlg_ShowInViewport "Show/Hide Map"
(
	button btn_show_map "Show Map" width:150
	button btn_hide_map "Hide Map" width:150
	button btn_show_mat "Show Material" width:150
	button btn_hide_mat "Hide Material" width:150
	
	fn TurnOnOff_MAT nodes state =
	(
		if state == on do
		(
			progressStart "Showing Material..."
		)
		if state == off do
		(
			progressStart "Hiding Material..."
		)
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		
		local progresscount = 0
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			if classof n == multimaterial then
			(
				for i=1 to n.materialList.count do
				(
					if (classof n.materialList[i]) == Standardmaterial OR (classof n.materialList[i]) == XRef_Material do
					(
						showTextureMap n.materialList[i] state
					)
				)
			)
			else
			(
				if classof n == Standardmaterial OR classof n == XRef_Material do
				(
					showTextureMap n state
				)
			)
		)
		progressEnd()
	)
	
	fn TurnOnOff_MAP_single material state =
	(
		if classof material == standardmaterial do
		(
			if material.diffuseMap != undefined do
			(
				if material.diffuseMap != undefined do
				(
					showTextureMap material material.diffuseMap state
				)
			)
		)
		if classof material == vraymtl do
		(
			if material.texmap_diffuse != undefined do
			(
				showTextureMap material material.texmap_diffuse state
			)
		)
	)
	
	fn TurnOnOff_MAP nodes state =
	(
		if state == on do
		(
			progressStart "Showing Map..."
		)
		if state == off do
		(
			progressStart "Hiding Map..."
		)
		
		local theMaterials = #()
		for n in nodes do (appendifunique theMaterials n.material)
		
		local progresscount = 0
		for n in theMaterials do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theMaterials.count))
			if classof n == multimaterial then
			(
				for i=1 to n.materialList.count do
				(
					if classof n.materialList[i] == Standardmaterial OR classof n.materialList[i] == vraymtl do
					(
						TurnOnOff_MAP_single n.materialList[i] state
					)
				)
			)
			else
			(
				if classof n == Standardmaterial OR classof n == vraymtl do
				(
					TurnOnOff_MAP_single n state
				)
			)
		)
		progressEnd()
	)
	

	
	on btn_show_map pressed do
	(
		with undo off with redraw off
		(
			TurnOnOff_Map selection on
		)
	)
	
	on btn_hide_map pressed do
	(
		with undo off with redraw off
		(
			TurnOnOff_Map selection off
		)
	)
	
	on btn_show_mat pressed do
	(
		with undo off with redraw off
		(
			TurnOnOff_Mat selection on
		)
	)
	
	on btn_hide_mat pressed do
	(
		with undo off with redraw off
		(
			TurnOnOff_Mat selection off
		)
	)
)
createDialog dlg_ShowInViewport