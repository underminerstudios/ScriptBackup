rollout main "Vertex color randomizer" 
	(
		group "Options"
		(
			spinner rComp_sp "Max. R Val." range:[0,255,255] type:#integer
			spinner gComp_sp "Max. G Val." range:[0,255,255] type:#integer
			spinner bComp_sp "Max. B Val." range:[0,255,255] type:#integer
			label empty_lb ""
			spinner blend_sp "Blend Ratio:" range:[0,10,0] type:#integer
		)
		
		button colorize_bt "Colorize" width:100
		
		
		on colorize_bt pressed  do
		(
			if(classOf $ == Editable_mesh) then
			(
				
				setNumCPVVerts $ $.numverts
				defaultVCFaces $
				
				local step = blend_sp.value + 1
				local colr = color 0 0 0;
				
				for i = 1 to $.numVerts do(
					
					r = ((random 0 step) as float/step) * rComp_sp.value
					g = ((random 0 step) as float/step) * gComp_sp.value
					b = ((random 0 step) as float/step) * bComp_sp.value
					
					colr = color r g b;
					setvertcolor $ i colr
				)
				
				$.showVertexColors = true;
				$.vertexColorsShaded = false;	
				
				update $;		
			)else(
				messageBox("ERROR: Select an editable_MESH object first.")
			)
		)--end pressed
	)--end rollout
	
createdialog main