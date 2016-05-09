/*
	Object List
	
	Simply a list of all the objects in the scene with the current scale and position.
	Useful if you need to check what objects require a resetxform
	
*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog list_scales)catch()

rollout list_scales "Object List - Scale/Position" width:600 height:400
(
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:400 pos:[0,0]
	
	fn fill_lv =
	(
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Objects" 150
		lv.Columns.add "Scale" 170
		lv.Columns.add "Position" 220
		
		theRange = #()
		
		for n in objects do
		(
			li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.text = n.name
			li.UseItemStyleForSubItems=false
			sub_li1 = li.SubItems.add (n.scale as string)
			sub_li2 = li.SubItems.add (n.pos as string)
			append theRange li
		)
		
		lv.Items.AddRange theRange
	)
	
	on list_scales open do
	(
		fill_lv()
	)
	
	on list_scales resized theSize do
	(
		lv.width = theSize[1]
		lv.height = theSize[2]
	)
)
createDialog list_scales style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing)