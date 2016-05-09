/*
	Sort Sub-Element Transparency
	
	This script changes the order of the faces in an object so that they are rendered properly.
	Select a dummy and select as many meshes as you want.
	
	The script will calculate the distance between the dummy and the meshes elements and will change the order so that the elements that are further away have the lowest
	ID number possible. Glitch will render them in this order as well.
	
	--by Norman Schaar - norman.schaar@gameloft.com
*/

try
(
	destroyDialog GL_sort_transparency
)catch()

fn Gameloft_Sort_Transparency_close =
(
	try(destroyDialog GL_sort_transparency)catch()
)


rollout GL_sort_transparency "Sort Transparency"
(
	listbox lb_dummy "Dummy:" height:1
	button btn_helper "Add selected Dummy" width:140
	listbox lb_objects "Objects:"
	button btn_add_selection "Add selected objects" width:140
	
	checkbox cb_invert "Invert"
	button btn_sort "Sort" width:140 height:40
	
	fn detachSeparate helper node = if iskindof node Editable_Poly do
	(
		with undo off with redraw off
		(
			local theNodes = #()
			local thePositions = #()
			local theNewPositions = #()
			
			local act = on
			local element = polyop.getElementsUsingFace
			local detach = polyop.detachfaces
			while node.numfaces > 0 and act do
			(
				elem = element node 1
				act = detach node elem delete:on asnode:on
				if act do 
				(
					obj = objects[objects.count]
					centerPivot obj -- or whatever you need
					append theNodes obj
				)
			)
			
			for n in theNodes do
			(
				append thePositions (distance helper n)
			)
			local thePositions = sort thePositions
			--Invert Array
			local theNewPositions = for i = thePositions.count to 1 by -1 collect thePositions[i]
			
			if cb_invert.checked == true then
			(
				for n in thePositions do
				(
					for m in theNodes do
					(
						try
						(
							if n == (distance helper m) do
							(
								polyop.attach node m
							)
						)
						catch()
					)
				)
			)
			else
			(
				for n in theNewPositions do
				(
					for m in theNodes do
					(
						try
						(
							if n == (distance helper m) do
							(
								polyop.attach node m
							)
						)
						catch()
					)
				)
			)
		)
	)
	
	on GL_sort_transparency open do
	(
		callbacks.removeScripts id:#GLST
		callbacks.addScript #filePreOpenProcess "Gameloft_Sort_Transparency_close()" id:#GLST
		global GL_sort_nodes = undefined
		global GL_sort_helper = undefined
	)
	
	on GL_sort_transparency close do
	(
		callbacks.removeScripts id:#GLST
	)
	
	on btn_helper pressed do
	(
		lb_dummy.items = #(Selection[1].name)
		global GL_sort_helper = Selection[1]
	)
	
	on btn_add_selection pressed do
	(
		lb_objects.items = for n in Selection collect n.name
		global GL_sort_nodes = for n in selection collect n
	)
	
	on btn_sort pressed do
	(
		if GL_sort_helper == undefined do
		(
			messagebox "You need to have a dummy"
		)
		if GL_sort_nodes == undefined do
		(
			messagebox "You need to have objects in the list!"
		)
		if GL_sort_helper != undefined AND GL_sort_nodes != undefined do
		(
			for o in GL_sort_nodes do
			(
				detachSeparate GL_sort_helper o
			)
		)
	)
)
createDialog GL_sort_transparency width:180