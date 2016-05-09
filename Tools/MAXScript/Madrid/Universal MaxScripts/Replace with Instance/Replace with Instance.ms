/*
	Repalce with Instance
	
	This script will create instances of the picked master mesh. The objects specified will be replaced with instances of the master mesh.
*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog replaceInstance)catch()
rollout replaceInstance "Replace with Instance"
(
	--Function that will find a node in the layers
	fn findthenode theNode =
	(
		for i=0 to (LayerManager.count - 1) do
		(
			(LayerManager.getLayer i).nodes &thenodes
			for n in thenodes do
			(
				if n == theNode do
				(
					return i
				)
			)
		)
	)
	
	local theObjects = #()
	multilistbox mlb_objectList "Objects to Replace:"
	button btn_add "Add to list" width:150
	pickbutton btn_pick "Pick Master Mesh" width:150
	
	on btn_add pressed do
	(
		for n in selection do
		(
			appendifunique theObjects n
		)
		
		local theMLB_items = #()
		for n in theObjects do
		(
			append theMLB_items n.name
		)
		
		mlb_objectList.items = theMLB_items	
	)
	
	on btn_pick picked theObj do
	(
		with redraw off with undo off
		(
			for n in theObjects do
			(
				local theInstance = instance theObj
				theInstance.name = n.name
				theInstance.transform = n.transform
				(LayerManager.getLayer (findthenode n)).addnode theInstance
				delete n
			)
			theObjects = #()
			mlb_objectList.items = #()
		)
		clearUndoBuffer()   
	)
	
)
createDialog replaceInstance