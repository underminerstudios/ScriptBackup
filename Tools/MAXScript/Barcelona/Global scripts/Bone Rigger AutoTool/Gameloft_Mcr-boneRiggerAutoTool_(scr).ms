	rollout main "Bone Rigger AutoTool" width:300
	--Created by Marc Martí (Gameloft - 2012)    
	(
		group "Instructions:"
		(
			label lab1 "1) Select the massFx objects." align:#left --enabled:false
			label lab2 "2) Transformthem into editable poly." align:#left --enabled:false
			label lab3 "3) Press the RIG button" align:#left --enabled:false
		)
		
		group "Rig:"
		(
			checkbox freezeCb "Freeze Base Obj" checked:true
			checkbox hideCb "Hide Base Obj" checked:true
			button rigBt1 "Rig MassFx Objects" width:220
			button rigBt2 "Rig Cloth Simulation" width:220
		)
		
		group "Progress:"
		(
		progressBar prog "Progreso:"
		)
		
		label author_lb "Marc Martí (Gameloft - 2012)" enabled:false align:#center
		
		fn objVerification elemArray =
		(
			if selection.count > 0 then
			(
				verifOk = true
				for obj in selection do
				(
					if (superClassOf obj != GeometryClass) then
					(
						verifOk = false
					)
				)			
			)else(
				verifOk = false
			)
			
			return verifOk
		)
		
		on rigBt1 pressed do
		(
			if objVerification selection == true then
			(
				usedFaces = #()
				elementsFaces = #()
				elementsVertices = #()
				bonesArray = #()
				
				ep = editable_mesh name:(uniquename"skinedMesh")
				convertTo ep Editable_Poly
				
				for obj in selection do
				(
					oCopy = copy obj
					polyop.attach ep oCopy
					
					b = BoneSys.createBone [0,0,0] [0,1,0] [0,0,1]
					t = obj.transform
					b.transform = t
					b.parent = obj
					
					bonesArray = append bonesArray b
					
					obj.scale = [0.1, 0.1, 0.1]
					
					if(freezeCb.checked == true)then
					(
						freeze obj
					)
					
					if(hideCb.checked == true)then
					(
						hide obj
					)
					
					numFaces = polyOp.getNumFaces ep
					
					for f=1 to numFaces do
					(
						
						faceUnused = findItem usedFaces f
						
						if(faceUnused == 0) then
						(
							element = polyOp.getElementsUsingFace ep #{f}
							
							elementVerts = polyop.getVertsUsingFace ep element
							
							elementVerts = elementVerts as array
							elemFaces = element as array
							
							join usedFaces elemFaces
							
							elementsVertices = append elementsVertices elementVerts
							elementsFaces = append elementsFaces elemFaces
							--NOTE: attachar al bone b
						)
						
					)
				)
				
				select ep
				modPanel.addModToSelection (Skin ()) ui:on
				
				skn = ep.skin
				
				for boneIndex=1 to bonesArray.count do
				(
					skinOps.addBone skn bonesArray[boneIndex] 1
					
					skinOps.setInnerRadius skn boneIndex 1 0.0005
					skinOps.setInnerRadius skn boneIndex 2 0.0005
					
					skinOps.SetOuterRadius skn boneIndex 1 0.001
					skinOps.SetOuterRadius skn boneIndex 2 0.001						
				)
				
				for bi=1 to bonesArray.count do
				(
					--presuposem que hi han tans bones com elements (hauria de ser aixi!)
					for vert = 1 to elementsVertices[bi].count do
					(
						skinOps.SelectBone skn bi
						skinOps.SelectVertices skn elementsVertices[bi][vert]
						skinOps.SetWeight skn 1
					)
					
					prog.value = 100 * bi/bonesArray.count
					
				)
				
				skinOps.RemoveZeroWeights skn
				skn.bone_Limit = 1
				
				prog.value = 0
				
			)else(
				messagebox ("ERROR: Select the massfx objects first.")
			)
		)

		on rigBt2 pressed do
		(
			if objVerification selection == true then
			(
				bonesArray = #()
				dummiesArray = #()

				ep = editable_mesh name:(uniquename"skinedMesh")
				--convertTo ep Editable_Poly
				
				if selection.count == 1 then
				(
					oCopy = copy $
					--polyop.attach ep oCopy --creamos una copia del objeto actual
					attach ep oCopy
					--loopeamos las caras y colocamos un dummy enc ada uno de sus vertices (habran dummys duplicados)
					
					for f=0 to getNumFaces ep do
					--for f=1 to getNumVerts ep do
					(
						for v=1 to 3 do
						(
							d = dummy()
							d.boxsize = [0.2,0.2,0.2]
							
							dummiesArray = append dummiesArray d
							
							actrl = Attachment()
							d.position.controller = actrl
							actrl.node = $
							
							addNewKey actrl 0f --atachem a la posicio en el frame 0
							theAKey = AttachCtrl.getKey actrl 1
							theAKey.face = f
							
							if(v==1)then
							(
								theAKey.coord = [0,0]
							)
							if(v==2)then
							(
								theAKey.coord = [1,0]
							)
							if(v==3)then
							(
								theAKey.coord = [0,1]
							)
						)	
					)							
					--purgamos los dummys duplicados
					for i=1 to dummiesArray.count do
					(
						dummyBase = dummiesArray[i]
						
						for j=1 to dummiesArray.count do
						(
							if(i != j)then
							(
								dummyCompare = dummiesArray[j]
								
								if(dummyCompare != 0 and dummyBase != 0)then
								(
									if(dummyBase.pos == dummyCompare.pos)then
									(
										duplicatedDummy = dummiesArray[j]
										delete duplicatedDummy
										dummiesArray[j] = 0
									)
								)
							)
						)
					)
					
					
					--purgamos los dummys duplicados
					cleanDummyArray = #()
					for m=1 to dummiesArray.count do
					(
						if(dummiesArray[m] != 0) then
						(
							cleanDummyArray = append cleanDummyArray dummiesArray[m]
						)
					)
					
					--congelamos y escondemos la malla de origen
					if(freezeCb.checked == true)then
					(
						freeze $
					)
					
					if(hideCb.checked == true)then
					(
						hide $
					)
					
					--skineamos el nuevo objeto
					convertTo ep Editable_Poly
					select ep
					modPanel.addModToSelection (Skin ()) ui:on
					skn = ep.skin
						
					for n=1 to cleanDummyArray.count do
					(
						currentDummy = cleanDummyArray[n]

						b = BoneSys.createBone [0,0,0] [0,1,0] [0,0,1]
						b.width = 0.5
						b.height = 0.5
						b.pos = currentDummy.pos	
						b.parent = currentDummy
						
						bonesArray = append bonesArray b					
					)
					
					for boneIndex=1 to bonesArray.count do
					(
						skinOps.addBone skn bonesArray[boneIndex] 1
						
						skinOps.setInnerRadius skn boneIndex 1 0.0005
						skinOps.setInnerRadius skn boneIndex 2 0.0005
						
						skinOps.SetOuterRadius skn boneIndex 1 0.001
						skinOps.SetOuterRadius skn boneIndex 2 0.001						
					)
					
					--presuposem que hi han tans bones com vertexos (hauria de ser aixi!)
					--linkem cada bone al seu vertex segons posicio...
					
					for b=1 to bonesArray.count do
					(
						for v=1 to getNumVerts ep do
						(
							vertexPos = ep.getVertex v
							
							if bonesArray[b].pos == vertexPos then
							(
								skinOps.SelectBone skn b
								skinOps.SelectVertices skn v
								skinOps.SetWeight skn 1
								
								prog.value = 100 * b/bonesArray.count
							)
						)
					)
					
					skinOps.RemoveZeroWeights skn
					skn.bone_Limit = 1
					
					prog.value = 0
					
				)else(
					messagebox "ERROR: Select only on cloth simulated object."
				)
			)
		)
	)
createdialog main