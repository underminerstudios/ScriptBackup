	rollout main "Object Conformer" width:224 height:210
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
			vertexOut=0
			sel = getcurrentselection()
			
			
			for obj=1 to sel.count do 
			(
				surf = pickBt.object	
				select sel[obj]
				convertToMesh $ --collapse to EditableMesh
				numeroVertices=getNumVerts $
				prog.value=0

				for i = 1 to numeroVertices do --loop through all vertices
				(
					vert = getVert $ i --get the v-th vertex 
					rtrace = ray vert [0,0,-1]
					intpoint = intersectray surf rtrace
					
					if(intpoint!=undefined)then
					(
						vert = intpoint.pos
						prog.value = 100.*i/numeroVertices
					)else(
						--existeix algun vertex fora de superficie
						vertexOut=vertexOut+1
					)
					
					setVert $ i vert --assign back to the v-th vertex
				)

				update $
				if( vertexOut!=0) then
				(
					--messageBox ("Alerta: "+vertexOut+" vertice fuera de superficie!") as string
				)
			)
		)
	)
	
createdialog main
