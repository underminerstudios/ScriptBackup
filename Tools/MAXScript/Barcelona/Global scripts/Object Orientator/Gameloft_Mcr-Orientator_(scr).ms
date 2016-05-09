	rollout main "Gameloft Orientator" width:224
	(
	
		group "Process:"
		(
		pickbutton pickBt "Select the TARGET object:" 
		button actionBt "Orientator" enabled:false
		)
		
		group "Progress:"
		(
		progressBar prog "Progress:"
		)
		
		label author_lb "Created by: Marc Martí (Gameloft - 2010)" enabled:false
		
		on pickBt picked refmesh do
		(
		    pickBt.text = "Target -> " + refmesh.name
			actionBt.enabled = true
			--messageBox "ATTENTION: All the objects will be translated into editable meshes"				
		)
		
		on actionBt pressed do 
		( -- button
			--guarda la seleccio de elments actuals a "sel"
			sel = getcurrentselection()
			targetObj = pickBt.object
			targetX = targetObj.pos.x
			targetY = targetObj.pos.y
			
			for obj=1 to sel.count do 
			(
				--select pickBt.object
				--nuevoObjeto = copy $
				prog.value = 100.*obj/sel.count
				
				select sel[obj]
					
				vectorX = targetX-$.pos.x
				vectorY = targetY-$.pos.y
				hipotenusa = sqrt ((vectorX*vectorX)+(vectorY*vectorY))
				
				anguloObjetivo = asin(vectorX/hipotenusa);
				--anguloObjetivo = (anguloObjetivo*180)/pi
				
				$.rotation.z_rotation = 0
				$.rotation.x_rotation = -90
				
				if(targetY>$.pos.Y)then
				(
					$.rotation.z_rotation -= 180+anguloObjetivo
				)else(
					$.rotation.z_rotation = anguloObjetivo
				)
			)
		)
	
	)
	
createdialog main
