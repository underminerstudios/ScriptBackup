rollout main "Replacer" width:224 height:355
(
	group "Properties"
	(
		label lbl4 "Clonation mode" align:#left
		radiobuttons radioBt labels:#("Copy","Instance") default:1 align:#left
		
		label lbl5 "Clonation properties" align:#left
		checkbox rotXChk "Random X rotation" checked:false 
		checkbox rotYChk "Random Y rotation" checked:false 
		checkbox rotZChk "Random Z rotation" checked:true 
		spinner rotSpin "Rotation threshold:" range:[0,360,360] type:#integer
		
		checkbox scalChk "Random regular scale:" checked:false
		spinner scalSpin "Scale range (%):" range:[-1000,1000,0] type:#integer
	)
	
	group "Process:"
	(
		pickbutton pickBt "Sel. Master Object" --pos:[32,16] width:168 height:26
		button actionBt "Replace" enabled:false
	)
	
	group "Progress:"
	(
	progressBar prog "Progress:"
	)
	
	label author_lb "Created by: Marc Martí (Gameloft - 2010)" enabled:false
	
	on pickBt picked refmesh do
	(
	    pickBt.text = "Master -> " + refmesh.name
		actionBt.enabled = true
	)
	
	on actionBt pressed do 
	( -- button
		--guarda la seleccio de elments actuals a "sel"
		sel = getcurrentselection()
		
		--guarda la seleccio dels objectes seleccionats actualment en un array (sel)
		
				
			for obj=1 to sel.count do 
			(
				
				if radioBt.state == 1 then --COPIAT
				(
					select pickBt.object
					nuevoObjeto = copy $	
				)
				if radioBt.state == 2 then --INSTANCIAT
				(
					select pickBt.object
					nuevoObjeto = instance $				
				)				
				--
				select sel[obj]					
				prog.value = 100.*obj/sel.count
				--
				rotOrigX = $.rotation.x_rotation
				rotOrigY = $.rotation.y_rotation
				rotOrigZ = $.rotation.z_rotation
				--ESCALA				
				if scalChk.checked then
			    (
				spin=scalSpin.value
				scaleVar = ((random (100-spin) (100+spin)) as float)/100
				--messageBox scaleVar
				nuevoObjeto.scale.x = scaleVar
				nuevoObjeto.scale.y = scaleVar
				nuevoObjeto.scale.z = scaleVar
				)else(
				nuevoObjeto.scale.x = $.scale.x
				nuevoObjeto.scale.y =  $.scale.y
				nuevoObjeto.scale.z =  $.scale.z
				)
							
				--ROTACIO
				if(rotXChk.checked==true) then
			    (
					rotationVar = (random (rotSpin.value*-1) rotSpin.value)as float
					nuevoObjeto.rotation.x_rotation = rotationVar+rotOrigX
				)else(
					nuevoObjeto.rotation.x_rotation = rotOrigX
				)
				
				if (rotYChk.checked ==true)then
			    (
					rotationVar = (random (rotSpin.value*-1) rotSpin.value)as float
					nuevoObjeto.rotation.y_rotation = rotationVar+rotOrigY
				)else(
					nuevoObjeto.rotation.y_rotation = rotOrigY
				)
				
				if (rotZChk.checked ==true) then
			    (
					rotationVar = (random (rotSpin.value*-1) rotSpin.value)as float
					nuevoObjeto.rotation.z_rotation = rotationVar+rotOrigZ
				)else(
					nuevoObjeto.rotation.z_rotation = rotOrigZ
				)
				
				--TRANSLACIO
				nuevoObjeto.pos = $.pos
				
				
				--borra objectes seleccionats
				max delete 
			)-- end for

	)-- close button

)
createdialog main
