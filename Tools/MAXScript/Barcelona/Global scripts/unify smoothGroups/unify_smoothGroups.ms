if selection.count != 0 then
(
	for obj in selection do
	(
		if classOf obj == Editable_Poly then
		(
			objFaces = obj.faces
			polyop.setFaceSmoothGroup obj objFaces 1 add:false
		)else(
			messageBox("ATTENTION: ["+obj.name+"] is not an editable poly object.")
		)
	)
	redrawViews()
	messagebox("Process finished!")
)else(
	messageBox("ATTENTION: Please, select some objects first")
)