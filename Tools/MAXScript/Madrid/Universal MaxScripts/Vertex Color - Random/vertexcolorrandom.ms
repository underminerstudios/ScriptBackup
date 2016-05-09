try(destroyDialog DLG_Random_VertexColor)catch() --try to destroy it if it already exists as a dialog
rollout DLG_Random_VertexColor "Random Vertex Color" --define the rollout 
(
	label lbl_color "Color:" align:#left
	spinner sp_min "Min:" align:#right type:#integer range:[0,255,0]
	spinner sp_max "Max:" align:#right type:#integer range:[0,255,255]
	
	checkbox cb_R "Red"
	checkbox cb_G "Green"
	checkbox cb_B "Blue"
	
	button btn_assing "Assing to Selected Verts"
	
	on btn_assing pressed do
	(
		if selection.count == 1 then
		(
			local theMesh = selection[1]
			if classof theMesh == Editable_poly then
			(
				local theSelectedVerts = polyop.getVertSelection theMesh
				local theRandomColor = random sp_min.value sp_max.value
				for n in theSelectedVerts do
				(
					theMesh.SetSelection #Vertex #{n}
					local GetColor = (theMesh.GetVertexColor #VertexColor) as point3
					if cb_R.state == true do (GetColor[1] = theRandomColor)
					if cb_G.state == true do (GetColor[2] = theRandomColor)
					if cb_B.state == true do (GetColor[3] = theRandomColor)
					local theFinalColor = GetColor as color
					polyop.SetVertColor theMesh 0 #{n} theFinalColor
				)
				theMesh.SetSelection #Vertex theSelectedVerts
			)
			else
			(
				messagebox "You must select an Editable Poly!"
			)
		)
		else
		(
			messagebox "You must select an object!"
		)
	)
)
createDialog DLG_Random_VertexColor