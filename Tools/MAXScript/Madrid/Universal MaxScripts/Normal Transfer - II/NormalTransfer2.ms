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
	button btn_copy "Copy" width:100
	button btn_paste "Paste" width:100
	progressBar pb_load value:0 color:green 	 
	
	on btn_copy pressed do
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
	
	on btn_paste pressed do
	(
		local theSelection = for n in selection collect n
		with undo off with redraw off
		(
			for n in theSelection do
			(
				select n
				local theMesh = n
				collapseStack theMesh
				if getCommandPanelTaskMode() != #modify do setCommandPanelTaskMode mode:#modify
				
				if theMesh.modifiers.count == 0 do (addModifier theMesh (Edit_Normals()))
				local theNormalsMod = theMesh.modifiers[1]
				local theSelectedVerts = polyop.getVertSelection theMesh.baseobject
				
				local LoopIndex = 0
				pb_load.value = 0
				
				local selectedvertscount = for n in theSelectedVerts collect n
				
				for m in theSelectedVerts do
				(
					pb_load.value = 100.0 * LoopIndex / selectedvertscount.count
					LoopIndex += 1
					
					local theVert = (polyop.getvert theMesh.baseObject m) + theMesh.pos
					local ArrayDistance = for o in ArrayPosition collect (distance theVert o)
					local theDistance = ArrayDistance[1]
					local theIndex = 1
					for i=1 to ArrayDistance.count do
					(
						if ArrayDistance[i] < theDistance do
						(
							theDistance = ArrayDistance[i]
							theIndex = i
						)
					)
					
-- 					tape pos:theVert target:(targetObject pos:ArrayPosition[theIndex])
					
					local theNewNormal = ArrayNormal[theIndex]
					
					polyop.setVertSelection theMesh.baseObject #{m}
					local normalSelection = #{}
					theNormalsMod.ConvertVertexSelection #{m} &normalSelection
					local theNormal = (for n in normalSelection collect n)[1]
					local theCurrentNormal = theNormalsMod.GetNormal theNormal
					if theCurrentNormal != theNewNormal do
					(
						theNormalsMod.MakeExplicit selection:#{theNormal}
						theNormalsMod.SetNormal theNormal theNewNormal
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