rollout main "Show diffuse on viewport:" width:320
(
		group "Procés:"
		(
			radiobuttons visibility_rb "Difuso:" labels:#("Standard", "DirectX")
			Button visibiliza_bt "Show Diffuses on Viewport"
		)
		
		group "Progreso:"
		(
			label matLabel_lb "Material:" align:#left
			progressBar prog "Progreso:"
		)
		
		label author_lb "Created by: Marc Martí (Gameloft - 2012)" enabled:false
		
		fn visualizaMapaMat m =
		(
			if((classOf m)==standardMaterial and m.diffuseMap != undefined) then 
			(	
				if(visibility_rb.state == 1)then
				(
					--standard
					enableHardwareMaterial m off 
					showTextureMap m m.diffuseMap on
				)else(
					enableHardwareMaterial m on
					showHWTextureMap m on
				)
			)
			
			if((classOf m)==VRayMtl and m.texmap_diffuse != undefined) then 
			(	
				if(visibility_rb.state == 1)then
				(
					--standard
					enableHardwareMaterial m off 
					showTextureMap m m.texmap_diffuse on
				)else(
					enableHardwareMaterial m on
					showHWTextureMap m on
				)
			)
			
			--multisubobjeto
			if((classOf m)== multimaterial)then
			(
				for n=1 to m.materialList.count do
				(
					visualizaMapaMat m.materialList[n]	
				)
			)
		)
		
		on visibiliza_bt pressed do
		(
			prog.color = red
			counter = 0
			counterMax = sceneMaterials.count
			
			for m in sceneMaterials do
			(
				counter = counter+1
				prog.value = 100*counter/counterMax
				matLabel_lb.caption = ("Material:"+m.name) as string
				
				visualizaMapaMat m				
			)
			prog.value = 0
		)
)--end rollout
createdialog main
