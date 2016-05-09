--====================================================================================================================--
-- 	Archive and Check UVs v0.0.1 
--====================================================================================================================--
-- 
-- Gabriel Coriiu (gabriel.coriiu@gameloft.com)
--
-- Moves UV clusters as close to origin as possible and check for bad UV ranges (range length souldn't be > 32)
--====================================================================================================================--

struct UVInfo ( objName="", maxU=0, maxV=0, minU=0, minV=0 )

global RandUVOffs
global RANGE_VALUE = 32
global selectionArray = #()

try(destroyDialog  RandUVOffs)catch()
rollout RandUVOffs "Archive and Check UVs"
(
	progressbar load_bar width:135 height:20 color:[0,120,255] value:0
	label prc "0%"
	
	button btnOffset "Archive and Check UVs"
	on btnOffset pressed do
	(
		local OutOfRangeElems = #()
		local obj
		local objectID = 0
		selectionArray = selection
		
		
		load_bar.value = 0
		load_bar.color = color 0 120 255
		prc.text = (load_bar.value as string) + " %"
		
		if ( selectionArray.count > 0 ) then
		for obj in selectionArray where (superClassOf obj == GeometryClass and RandUVOffs.isDisplayed) do
		(
			if ( heapCheck() != OK ) then heapsize += 50000000
			objectID += 1
			
			convertToPoly obj
			if ( (try(obj.unwrapuvw)catch(undefined)) == undefined ) then addModifier obj (Unwrap_UVW ())

			local moduvw = obj.modifiers[#unwrap_uvw]
			local vcnt=polyop.getNumMapVerts obj 1  --moduvw.unwrap.numbervertices()
			moduvw.unwrap.selectVertices #{1..vcnt}

			-- count uv elements
			local vertelemarray=#()
			for i=1 to vcnt do vertelemarray[i]=0
			local elem=0
			--modPanel.setCurrentObject moduvw
			subobjectlevel = 1
			
			---------------------------------------------------
			for v=1 to vcnt do
			(
				if(vertelemarray[v]==0)then
				(	-- vertex v is not in array yet
					moduvw.unwrap.selectVertices #{v}
					moduvw.unwrap2.SelectElement()
					elem+=1
					elemverts=moduvw.unwrap.getselectedvertices()

					for i in elemverts do
					(	-- which vertices go to which element, vert[1]=vert[2]= ... =1 , vert[7]=vert[8]= ... =2 , ...
						vertelemarray[i]=elem
					)
				)
			)
			--subobjectlevel = 0
			--amount of elements
			--print elem as string
			-----------------------------------------------------
			local elemarray=#()
			for e=1 to elem do
			(
				local notFound = true
				for v=1 to vertelemarray.count while notFound do
				(
					if vertelemarray[v]==e then
					(	-- found vertex index 
						elemarray[e]=v
						notFound = false
					)
				)
			)
			--with this we get element from vertex
			--print elemarray as string
			---------------------------------------------------
			--modPanel.setCurrentObject moduvw
			--subobjectlevel = 1

			for i=1 to elemarray.count do
			(	-- go through all elements
				moduvw.unwrap.selectVertices #{elemarray[i]}
				moduvw.unwrap2.SelectElement()
				elemPivot = [0,0,0]
				elemverts=moduvw.unwrap.getselectedvertices()
			
				maxU = -9999.0
				maxV = -9999.0
				minU = 9999.0
				minV = 9999.0
			
				for v in elemverts do
				(	-- go through all vertices and calculate selection center
					uvwpos = moduvw.unwrap.getVertexPosition 0 v
					if ( uvwpos.x > maxU ) then maxU = uvwpos.x
					if ( uvwpos.x < minU ) then minU = uvwpos.x
					if ( uvwpos.y > maxV ) then maxV = uvwpos.y
					if ( uvwpos.y < minV ) then minV = uvwpos.y
				)
				elemPivot.x = (maxU + minU)/2
				elemPivot.y = (maxV + minV)/2
			
				for v in elemverts do
				(	-- go through all vertices in element and offset them
					uvwpos = moduvw.unwrap.getVertexPosition 0 v
					fixValueX = 0
					fixValueY = 0
					if ( elemPivot.x < 0 ) then fixValueX = 1.0
					if ( elemPivot.y < 0 ) then fixValueY = 1.0
					uvwpos.x -= (elemPivot.x as integer) - fixValueX
					uvwpos.y -= (elemPivot.y as integer) - fixValueY
					moduvw.unwrap.setVertexPosition 0 v uvwpos
				)
			)
			--subobjectlevel = 0
			
			---------------------------------------------------
			local OutOfRangeElem = UVInfo "" 0 0 0 0
			maxU = -9999.0
			maxV = -9999.0
			minU = 9999.0
			minV = 9999.0
			for v=1 to vcnt do
			(
				uvwpos = moduvw.unwrap.getVertexPosition 0 v
				if ( uvwpos.x > maxU ) then maxU = uvwpos.x
				if ( uvwpos.x < minU ) then minU = uvwpos.x
				if ( uvwpos.y > maxV ) then maxV = uvwpos.y
				if ( uvwpos.y < minV ) then minV = uvwpos.y
			)
			if ( abs (maxU - minU) >= RANGE_VALUE ) then
			(
				OutOfRangeElem.objName = obj.name
				OutOfRangeElem.maxU = maxU
				OutOfRangeElem.minU = minU
			)
			if ( abs (maxV - minV) >= RANGE_VALUE ) then
			(
				OutOfRangeElem.objName = obj.name
				OutOfRangeElem.maxV = maxV
				OutOfRangeElem.minV = minV
			)
			if ( OutOfRangeElem.objName != "" ) then join OutOfRangeElems #(OutOfRangeElem)
			--check whether the vertexes are 32x32 area or not
			-----------------------------------------------------
			
			convertToPoly obj
			windows.processPostedMessages()
			load_bar.value = (100 * objectID / selectionArray.count)
			prc.text = (load_bar.value as string) + " %"
		)--for loop
		
		local message = "Some objects have UVs out of 32x32 range."
		if ( OutOfRangeElems.count > 0 ) then
		(
			for OutOfRangeElem in OutOfRangeElems do
			(
				append message ("\n\n" + OutOfRangeElem.objName)
				if ( OutOfRangeElem.minU != 0 and OutOfRangeElem.maxU != 0 ) then append message ("\n\t U: Bad range [ " + (OutOfRangeElem.minU as string) + " , "  + (OutOfRangeElem.maxU as string) + " ];")
				if ( OutOfRangeElem.minV != 0 and OutOfRangeElem.maxV != 0 ) then append message ("\n\t V: Bad range [ " + (OutOfRangeElem.minV as string) + " , "  + (OutOfRangeElem.maxV as string) + " ];")
			)
			load_bar.color = color 255 50 0
			messageBox message title:"Warning"
			clearListener()
			format message
		)
		else
		(
			load_bar.color = color 100 210 0
			--messageBox "All selected objects have valid UV ranges." title:"Complete"
		)
	)--button

)--rollout
gc()
CreateDialog RandUVOffs


