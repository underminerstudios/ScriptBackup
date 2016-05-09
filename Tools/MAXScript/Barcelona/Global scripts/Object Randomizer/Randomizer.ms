	rollout main "Randomizer" width:224 height:285
	(
		group "Properties:"
		(
			label lbl4 "Random:" align:#left		
			
			checkbox rotXChk "Random X Rotation" checked:false 
			checkbox rotYChk "Random Y Rotation" checked:false 
			checkbox rotZChk "Random Z Rotation" checked:true 
			spinner rotSpin "Rotation threshold:" range:[0,360,360] type:#integer
			
			checkbox scalChk "Random regular scale:" checked:true
			spinner scalSpin "Scale range (%):" range:[-1000,1000,30] type:#integer
		)
		
		group "Process:"
		(
			button actionBt "Randomize" enabled:true
		)
		
		group "Progress:"
		(
			progressBar prog "Progress:"
		)
		
		label author_lb "Created by: Marc Martí (Gameloft - 2010)" enabled:false
		
		on actionBt pressed do 
		( -- button
			--guarda la seleccio de elments actuals a "sel"
			sel = getcurrentselection()
			
			--guarda la seleccio dels objectes seleccionats actualment en un array (sel)
			
					
				for obj=1 to sel.count do 
				(
					
		
					--
					select sel[obj]					
					prog.value = 100.*obj/sel.count
					
					--ESCALA				
					if scalChk.checked then
					(
					spin=scalSpin.value
					scaleVar = ((random (100-spin) (100+spin)) as float)/100
					--messageBox scaleVar
					$.scale.x = scaleVar
					$.scale.y = scaleVar
					$.scale.z = scaleVar
					)
								
					--ROTACIO
					if rotXChk.checked then
					(
					rotationVar = (random (rotSpin.value*-1) rotSpin.value)as float
					$.rotation.x_rotation += rotationVar
					)
					
					if rotYChk.checked then
					(
					rotationVar = (random (rotSpin.value*-1) rotSpin.value)as float
					$.rotation.y_rotation += rotationVar
					)
					
					if rotZChk.checked then
					(
					rotationVar = (random (rotSpin.value*-1) rotSpin.value)as float
					$.rotation.z_rotation += rotationVar
					)
					
				)-- end for
		)-- close button
	)
	
	createdialog main
