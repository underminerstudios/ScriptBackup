	rollout main "Object Spline Conformer" width:224 height:210
	(
	
		group "Process:"
		(
		pickbutton pickBt "Pick the surface object" 
		button actionBt "Conform" enabled:false
		)
		
		group "Progress:"
		(
		progressBar prog "Progress:"
		)

		label author_lb "Marc Martí (Gameloft - 2013)" enabled:false align:#center

		
		on pickBt picked refmesh do
		(
		    pickBt.text = "Superficie -> " + refmesh.name
			actionBt.enabled = true
			messageBox "ATTENTION: The conformed object will be converted to 'Editable Mesh'"				
		)
		
		on actionBt pressed do 
		(
			--guarda la seleccio de elments actuals a "sel"
			if selection.count == 1 and (classof selection[1] == SplineShape or classof selection[1] == Line) and selection[1].modifiers.count == 0 then
			(
				vertexOut=0
				sel = getcurrentselection()
				
				spline = selection[1]
				
				surf = pickBt.object	
				
				prog.value=0
				
				new_z = spline.pos.z
				for s = 1 to (numSplines spline) do
				(
					for k = 1 to (numKnots spline s) do
					(
						knt = getKnotPoint spline s k
						vecVertical = point3 0 0 -1
						rtrace = ray knt vecVertical
						intpoint = intersectray surf rtrace

						if(intpoint != undefined)then
						(
							setKnotPoint spline s k intpoint.pos
							prog.value = 100.*k/ (numKnots spline s)
						)			
					)--end k loop
				)--end s loop
				updateshape spline
			)
		)
	)
	
createdialog main
