--	\Title UV To Corner
--	
--	\Description	Déplace le canal 2 UVW dans le coin supérieur droit de tous les objets sélectionnés.
--	\Description	
--	\Description	Moves channel 2 UVW to the top right corner on all selected objects.
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 08/7/2011

(
	undo on
	(
		local uv_mod = Unwrap_UVW ()
		uv_mod.unwrap.setMapChannel 2
		
		local oSel = selection as array
		uv = modPanel.getCurrentObject()
		SuspendEditing();
		if ( classof uv != Unwrap_UVW ) then
		( 
			for n in oSel do (addmodifier n uv_mod)
			uv_mod.settvsubobjectmode 3
		)
		for ob in selection do
		(
			ob.modifiers[1].unwrap2.selectFaces (ob.faces as bitarray)
			ob.modifiers[1].unwrap2.ScaleSelectedXY 0.0 0.0 [0.999,0.999,0]
			maxOps.CollapseNodeTo ob 1 off
		)
		ResumeEditing();
	)
 )

