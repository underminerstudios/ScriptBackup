	rollout mainRollout "Select faces by angle" width:230
	(
		-- // UI =============================================================================================================
		
		group "Options:"
		(
			spinner angleMin_sp "Angle Min:" range:[0,90,0]
			spinner angleMax_sp "Angle Max:" range:[0,90,90]
			button actionBt "Select"
		)
		
		group "Porcess:"
		(
			progressBar prog "Progreso:"
		)
		
		label author_lb "Created by: Marc Martí (Gameloft - 2011)" enabled:false
		
		-- // HANDLERS =============================================================================================================
		
		on angleMin_sp changed arg do 
		(
			if(angleMin_sp.value>angleMax_sp.value)then(
				angleMax_sp.value = arg
			)
		)
		
		-- // -------------------------------------------------------------------------------
		
		on angleMax_sp changed arg do 
		(
			if(angleMax_sp.value<angleMin_sp.value)then(
				angleMin_sp.value = arg
			)
		)
		
		-- // -------------------------------------------------------------------------------
		
		on actionBt pressed do 
		( -- button
			--guarda la seleccio de elments actuals a "sel"
			obj = $ 
			
			if(obj!= undefined and ClassOf obj == Editable_Poly )then
			(
			
				numFaces = polyop.getNumFaces obj
				coincidentAngleFaces = #()
				vectorZ = [0,0,1]
				face_selection = #{}
				
				for i=1 to numFaces do
				(
					prog.value = 100.*i/numFaces
					
					normalDir = polyop.getFaceNormal obj i node: obj
					theAngle = acos(dot (normalize vectorZ) (normalize normalDir))
					
					if(theAngle <= angleMax_sp.value and theAngle >= angleMin_sp.value )then
					(
						coincidentAngleFaces  = append coincidentAngleFaces i
						face_selection[i] = true
					)else(
						face_selection[i] = false
					)				
				)
				polyop.setFaceSelection obj face_selection			
			
			)else(
				
				messageBox("ERROR: Select an editable poly object first.")
			)
		)
		-- // -------------------------------------------------------------------------------
	)--END ROLLOUT	
	createdialog mainRollout