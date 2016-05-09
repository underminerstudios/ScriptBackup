rollout main "Object_follows_FaceCenter" width:300
(
	local splineObj
	local obj
	local dummiesArray
	
	group "Clonation method:"
	(
		radiobuttons radioBt labels:#("Copy","Instance") default:1 --align:#left
		
	)
	
	group "Options:"
	(
		checkbox option_cb "Invert direction" checked:false 	 
	)
	
	group "Objects:"
	(
		label lbInfo "Select the grid/reference object:" --align:#left
		pickbutton pickBt "Selecciona Objecte Grid" width:175
	)
	
	label lbInfo2 "Select the object to clone and click the button:" enabled:false
	button actionBt "Obj to Face-centers" width:175 enabled:false
	
	group "Progrés:"
	(
		progressBar prog "Progress:"
		label author_lb "Marc Martí (Gameloft - 2013)" enabled:false align:#center
	)
	
	
	on pickBt picked refSpline do
	(
	    gridObj = refSpline
		pickBt.text = "ObjGrid -> " + gridObj.name
		actionBt.enabled = true
	)
	
	on actionBt pressed do 
	(
		obj = getcurrentselection()
		gridObj = pickBt.object
		
		if(superClassOf gridObj == geometryclass) then
		(
			arrayPos = #()
			arrayDir = #()
			dummiesArray = #()
			
			for f = 1 to (gridObj.GetNumFaces()) do
			(					
					pos = polyOp.getFaceCenter gridObj f
					arrayPos = append arrayPos pos					
			)
			
			for f = 1 to (gridObj.GetNumFaces()) do
			(					
				if radioBt.state == 1 then --COPIAT
				(
					objCopia = copy $	
				)
				
				if radioBt.state == 2 then --INSTANCIAT
				(
					objCopia = instance $				
				)
				
				prev = false
				next = false
				
				if f-1>0 then
				(
					prev = arrayPos[f-1]
				)
				
				if f+1<=gridObj.GetNumFaces() then
				(
					next = arrayPos[f+1]
				)
				
				if prev != false or next != false then
				(
					if prev != false then
					(
						prevCenter = polyop.getFaceCenter gridObj (f-1)
					)else(
						prevCenter = polyop.getFaceCenter gridObj (f)
					)

					if next != false then
					(
						nextCenter = polyop.getFaceCenter gridObj (f+1)
					)else(
						nextCenter = polyop.getFaceCenter gridObj (f)
					)
					
					dir = polyOp.getFaceNormal gridObj f
					
					normal = normalize(dir)
					tangent = normalize(nextCenter-prevCenter)
					bitangent = cross normal tangent
					
					myMatrix = matrix3 tangent bitangent normal [0,0,0]

					objCopia.transform = myMatrix
					objCopia.pos = arrayPos[f]
				)else(
					dir = polyOp.getFaceNormal gridObj f
					objCopia.pos = arrayPos[f]
					objCopia.dir = dir	
				)
				
				dummiesArray = append dummiesArray objCopia	
				
				prog.value = 100.*f/(gridObj.GetNumFaces())
			)
			
			clearselection()
			
			if option_cb.checked == false then
			(
				--select dummiesArray[1]
				for o = 1 to dummiesArray.count do
				(
					selectMore dummiesArray[o]
				)
			)else(
				--select dummiesArray[dummiesArray.count-1]
				for o = dummiesArray.count to 1 by -1 do
				(
					selectMore dummiesArray[o]
				)
			)
			
		)else(
			messageBox("ERROR: the selected grid object is not a spline.")
		)
		forceCompleteRedraw()
		
	)-- on pressed		
)
createdialog main
