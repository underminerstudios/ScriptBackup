/*
	This tool allows you to transfer the normal orientation from one model to another based on the verts position
*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog NormalTransfer)catch()
rollout NormalTransfer "Normal Transfer"
(
	local ArrayPosition = #()
	local ArrayNormal = #()
	
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:450 pos:[0,0]
	button btn_save "Save" width:100
	button btn_load "Load" width:100
	progressBar pb_load value:0 color:green
	
	on btn_save pressed do
	(
		with undo off with redraw off
		(
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Position" 300
		lv.Columns.add "Normal" 300
		
		--Get selected Verts
		setCommandPanelTaskMode #modify
		local theMesh = selection[1]
		local theSelectedVerts = polyop.getVertSelection theMesh
		local theSelectedVertsArray = for n in theSelectedVerts collect n
		
		--Add the modifier to save the vert's normals
		addModifier theMesh (Edit_Normals())
		local theNormalsMod = modPanel.getCurrentObject()
			
		for n in theSelectedVertsArray do
		(
			local normalSelection = #{}
			theNormalsMod.ConvertVertexSelection #{n} &normalSelection
			local theNormalFromBitArray = for n in normalSelection collect n
			local theNormal = theNormalsMod.GetNormal theNormalFromBitArray[1]
			append ArrayNormal theNormal
			append ArrayPosition (polyop.GetVert theMesh n)
		)
		
		-- Get all files 
		local theRange = #()
		
		for i=1 to ArrayPosition.count do
		(
			local li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.text = (ArrayPosition[i]) as string
			li.UseItemStyleForSubItems=false
			li.SubItems.add (ArrayNormal[i] as string)
			
			append theRange li
		)
		deleteModifier theMesh theNormalsMod
		
		lv.Items.AddRange theRange
		)
	)
	
	on btn_load pressed do
	(
		
		local theSelection = for n in selection collect n
		with undo off with redraw off
		(
			for n in theSelection do
			(
				select n
				local theMesh = n
				if getCommandPanelTaskMode() != #modify do setCommandPanelTaskMode mode:#modify
				if theMesh.modifiers.count == 0 do (addModifier theMesh (Edit_Normals()))
				local theNormalsMod = theMesh.modifiers[1]
				
				local theSelectedVerts = polyop.getVertSelection theMesh.baseobject
					
				local LoopIndex = 0
				pb_load.value = 0
				
				local NumVerts = polyop.GetNumVerts theMesh
				local foundVertArray = #()
				local foundNormalArray = #()
				for i=1 to NumVerts do
				(
					local theVert = polyop.GetVert theMesh i
					local theIndex = finditem ArrayPosition theVert
					if theIndex != 0 do --It has been found, let's add the vert ID and the normal
					(
						append foundVertArray i
						append foundNormalArray (ArrayNormal[theIndex])
					)
				)
				for i=1 to foundVertArray.count do
				(
					pb_load.value = 100.0 * LoopIndex / foundVertArray.count
					LoopIndex += 1
					
					polyop.setVertSelection theMesh.baseObject foundVertArray[i]

					local normalSelection = #{}
					theNormalsMod.ConvertVertexSelection #{foundVertArray[i]} &normalSelection
					local theNormal = (for n in normalSelection collect n)[1]
					local CurrentNormal = theNormalsMod.GetNormal theNormal
					if CurrentNormal != foundNormalArray[i] do
					(
						theNormalsMod.MakeExplicit selection:#{theNormal}
						theNormalsMod.SetNormal theNormal foundNormalArray[i]
					)
				)
				polyop.setVertSelection theMesh.baseObject theSelectedVerts
				
				pb_load.value = 0
			)
		)
		select theSelection
	)
	
)
createDialog NormalTransfer width:600 height:530