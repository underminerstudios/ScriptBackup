---------------------------------------------------------------------------------------------------------------
-- Spherify Normals V1.5 macroScript																  		 --
-- script permettant de sphériser les normales d'un mesh sélectionné en fonction de la position d'un hotspot --
-- ©2005 Denis Mercier   version 3DSMAX7.0    projet: GhostRecon3   SAV : denis.mercier@ubisoft.com	         --
---------------------------------------------------------------------------------------------------------------
--Edited by Norman Schaar norman.schaar@gameloft.com to convert to regular dialog and not MAXScript Utility



try(destroydialog editBox)catch()
Global progbar , editBox 
progbar=0

fn spherifyNormals = 
(
	max modify mode
	---création ou sélection du modifier Editnormals---
	ModNrm=#() 
	ModSkn=#()
	
	if $.modifiers.count > 0 do 
			(
			for i in 1 to $.modifiers.count do
				(
				try (if $.modifiers[i]==$.Editnormals do append ModNrm i) --bug lorsque le modifier ne fait pas partie de la liste des modifier ne renvoit pas false. 
				catch ()
			
				try (if $.modifiers[i]==$.Skin do append ModSkn i)	--idem
				catch ()
				)
			)
	if ModNrm.count >0 do modPanel.setCurrentObject $.editnormals 	--s'il y a plus d'un modifier edit normal le selectionner
	if ModNrm.count==0 do addModifier $ (edit_normals()) -- s'il n'y a ni modifier skin ni edit nomal le créer en haut de la pile
	----------------------------------------------------							
	verts_list=#()
	numvertscount=0	
	progbar=0								
	modPanel.setCurrentObject $ ; faces=getfaceSelection $ ; modPanel.setCurrentObject $.editnormals
 	if classof $.baseobject == Editable_Poly do localverts=polyop.getVertsUsingFace $ faces	--array récupérant les faces selectionnées
	if classof $.baseobject == Editable_Mesh do localverts=meshop.getVertsUsingFace $ faces	--array récupérant les verts selectionnés											
	
	if localverts.numberset==0 	then verts_list = for i in 1 to $.NumVerts collect i	--s'il n'y a pas de sous selection traiter tous les verts
								else verts_list = for i in localverts collect i			--sinon uniquement ceux de la sous selection										
	
	global faces_list	--la faces_list est utilisée pour reseter les normales de la selection locale ou globale
	faces_list = #{}
		
	for g in verts_list do
		(
		numvertscount+=1
		verts_buffer = #{g}		--le point traité est le point G 
		normals_buffer = #{}  	--stocke les normales du point traité		
		$.Edit_Normals.ConvertVertexSelection &verts_buffer &normals_buffer --récupère les normales du point G
		faces_list += normals_buffer	--récupération des index de toutes les normales traitées
		
		if editBox.CapsuleMod.state do
			(
			if classof $.baseobject == Editable_Mesh do testVert=(meshop.getvert $ g)[editBox.axis.state]
			if classof $.baseobject == Editable_Poly do testVert=(polyop.getvert $ g)[editBox.axis.state]
			case of
				(
				(testVert > ($NormalsHotspotHi.pos[EditBox.axis.state])) :   computeVert = $NormalsHotspotHi.pos 
				(testVert < ($NormalsHotspotLo.pos[EditBox.axis.state])) :   computeVert = $NormalsHotspotLo.pos
				default: 	case EditBox.axis.state of 
								(
 									1: computeVert = [testVert,$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
									2: computeVert = [$NormalsHotspot.pos.x,testVert,$NormalsHotspot.pos.z] 
									3: computeVert = [$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,testVert]
				 				)
				)
			
			for k in normals_buffer do	--pour chaque normale 1, 2 ou 3 ...
				(						--set la normale en fonction du calcul du vecteur (point G - Hotspot)
				if classof $.baseobject == Editable_Poly do $.Edit_Normals.SetNormal k (normalize ((polyop.getvert $ g)-(computeVert)))
				if classof $.baseobject == Editable_Mesh do $.Edit_Normals.SetNormal k (normalize ((meshop.getvert $ g)-(computeVert)))
				)	
				
			)
			
		if editbox.SphereMod.state do
			(
			for k in normals_buffer do	--pour chaque normale 1, 2 ou 3 ...
				(						--set la normale en fonction du calcul du vecteur (point G - Hotspot)
				if classof $.baseobject == Editable_Poly do $.Edit_Normals.SetNormal k (normalize ((polyop.getvert $ g)-($NormalsHotspot.pos)))
				if classof $.baseobject == Editable_Mesh do $.Edit_Normals.SetNormal k (normalize ((meshop.getvert $ g)-($NormalsHotspot.pos)))
				)
			)
		progbar=ceil ((100/verts_list.count as float)*numvertscount) as integer  --percentage
		editBox.waiting.value=progbar
		editBox.waiting.color=(color 0 255 0)
		$.Edit_Normals.MakeExplicit selection:normals_buffer
		)
)


fn DisplayNormals =
(
	max modify mode	
	---création ou sélection du modifier Editnormals---
	ModNrm=#() 
	ModSkn=#()
						
	if $.modifiers.count > 0 do 
			(
			for i in 1 to $.modifiers.count do
				(
				try (if $.modifiers[i]==$.Editnormals do append ModNrm i) --bug lorsque le modifier ne fait pas partie de la liste des modifier ne renvoit pas false. 
				catch ()
							
				try (if $.modifiers[i]==$.Skin do append ModSkn i)	--idem
				catch ()
				)
			)
	if ModNrm.count >0 do modPanel.setCurrentObject $.editnormals 	--s'il y a plus d'un modifier edit normal le selectionner
	if ModNrm.count==0 do addModifier $ (edit_normals()) -- s'il n'y a ni modifier skin ni edit nomal le créer en haut de la pile
	----------------------------------------------------
	verts_list=#()	
	modPanel.setCurrentObject $ ; faces=getfaceSelection $ ; modPanel.setCurrentObject $.editnormals
						
	if classof $.baseobject == Editable_Poly do localverts=polyop.getVertsUsingFace $ faces	--array récupérant les faces selectionnées
	if classof $.baseobject == Editable_Mesh do localverts=meshop.getVertsUsingFace $ faces	--array récupérant les verts selectionnés											
						
	if localverts.numberset==0 	then verts_list = for i in 1 to $.NumVerts collect i	--s'il n'y a pas de sous selection traiter tous les verts
								else verts_list = for i in localverts collect i			--sinon uniquement ceux de la sous selection				
						
	global faces_list ,	numvertscount ,verts_list  --la faces_list est utilisée pour reseter les normales de la selection locale ou globale
	faces_list = #{}
	numvertscount=0
	numsplines=0
	progbar=0
	sizeHelper=50
	if $hlp!=undefined do delete $hlp
	NormalsHelper = SplineShape name:"hlp" pos:$.pos wirecolor:(color 255 144 0)
	
	for g in verts_list do
		(
		if editBox.CapsuleMod.state do
			(
			numvertscount+=1
			verts_buffer = #{g}		--le point traité est le point G 
			normals_buffer = #{}  	--stocke les normales du point traité		
			$.Edit_Normals.ConvertVertexSelection &verts_buffer &normals_buffer --récupère les normales du point G
			faces_list += normals_buffer	--récupération des index de toutes les normales traitées
			
			if classof $.baseobject == Editable_Mesh do testVert=(meshop.getvert $ g)[editBox.axis.state]
			if classof $.baseobject == Editable_Poly do testVert=(polyop.getvert $ g)[editBox.axis.state]
			case of
				(
				(testVert > ($NormalsHotspotHi.pos[EditBox.axis.state])) :   computeVert = $NormalsHotspotHi.pos 
				(testVert < ($NormalsHotspotLo.pos[EditBox.axis.state])) :   computeVert = $NormalsHotspotLo.pos
				default: 	case EditBox.axis.state of 
								(
 									1: computeVert = [testVert,$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
									2: computeVert = [$NormalsHotspot.pos.x,testVert,$NormalsHotspot.pos.z] 
									3: computeVert = [$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,testVert]
				 				)
				)

			for k in normals_buffer do	--pour chaque normale 1, 2 ou 3 ...
				(						--set la normale en fonction du calcul du vecteur (point G - Hotspot)
				numsplines+=1	--numero de chaque spline >  1 par normale
				addNewSpline NormalsHelper
				flagforeground NormalsHelper true
				if classof $.baseobject == Editable_Poly do
					(
					newNorm = (normalize ((polyop.getvert $ g)-(computeVert)))
					addKnot NormalsHelper numsplines #corner #line (polyop.getvert $ g)
					addKnot NormalsHelper numsplines #corner #line ((polyop.getvert $ g) + (sizeHelper*newNorm))
					updateShape NormalsHelper	
					close NormalsHelper numsplines
					)
				if classof $.baseobject == Editable_Mesh do
					(
					newNorm = (normalize ((meshop.getvert $ g)-(computeVert)))
					addKnot NormalsHelper numsplines #corner #line (meshop.getvert $ g)
					addKnot NormalsHelper numsplines #corner #line ((meshop.getvert $ g) + (sizeHelper*newNorm))
					updateShape NormalsHelper	
					close NormalsHelper numsplines
					)
				)
			flagforeground NormalsHelper false	
			progbar=ceil ((100/verts_list.count as float)*numvertscount) as integer  --percentage
			editBox.waiting.value=progbar
			editBox.waiting.color=(color 255 144 0)
			$.Edit_Normals.MakeExplicit selection:normals_buffer
			)

		if editbox.SphereMod.state do
			(
			numvertscount+=1
			verts_buffer = #{g}		--le point traité est le point G 
			normals_buffer = #{}  	--stocke les normales du point traité		
			$.Edit_Normals.ConvertVertexSelection &verts_buffer &normals_buffer --récupère les normales du point G
			faces_list += normals_buffer	--récupération des index de toutes les normales traitées
			for k in normals_buffer do	--pour chaque normale 1, 2 ou 3 ...
				(						--set la normale en fonction du calcul du vecteur (point G - Hotspot)
				numsplines+=1	--numero de chaque spline >  1 par normale
				addNewSpline NormalsHelper
				flagforeground NormalsHelper true
				if classof $.baseobject == Editable_Poly do
					(
					newNorm = (normalize ((polyop.getvert $ g)-($NormalsHotspot.pos)))
					addKnot NormalsHelper numsplines #corner #line (polyop.getvert $ g)
					addKnot NormalsHelper numsplines #corner #line ((polyop.getvert $ g) + (sizeHelper*newNorm))
					updateShape NormalsHelper	
					close NormalsHelper numsplines
					)
				if classof $.baseobject == Editable_Mesh do
					(
					newNorm = (normalize ((meshop.getvert $ g)-($NormalsHotspot.pos)))
					addKnot NormalsHelper numsplines #corner #line (meshop.getvert $ g)
					addKnot NormalsHelper numsplines #corner #line ((meshop.getvert $ g) + (sizeHelper*newNorm))
					updateShape NormalsHelper	
					close NormalsHelper numsplines
					)
				)
			flagforeground NormalsHelper false	
			progbar=ceil ((100/verts_list.count as float)*numvertscount) as integer  --percentage
			editBox.waiting.value=progbar
			editBox.waiting.color=(color 255 144 0)
			$.Edit_Normals.MakeExplicit selection:normals_buffer
			)	
		) --end for
		
)


fn resetNormals =
(
max modify mode	; modPanel.setCurrentObject $.editnormals ; subobjectLevel = 1 
$.Edit_Normals.setselection faces_list
$.modifiers[#Edit_Normals].EditNormalsMod.Reset (); subobjectLevel = 0
)

rollout editBox "Edit normals"
(
	button generate "Generate" offset:[0, 0] width:105 height:40 pos:[10,10]
	button reset "Reset" offset:[0, 0] width:40 height:40 pos:[121,10]
	groupBox grp1 "Hotspot position" pos:[10,56] width:151 height:100
	slider hotspotz "" ticks:20 range:[0,100,50] pos:[19,71]
	spinner edtx "Adjust X" range:[-1000,1000,0] type:#float pos:[20,108] width:120
	spinner edty "Adjust Y" range:[-1000,1000,0] type:#float pos:[20,128] width:120 
	progressbar waiting value:progbar pos:[10,155] width:151 height:10 color:green 
	checkbox sphereMod "Sphere" pos:[10,172] tristate:1
	checkbox capsuleMod "Capsule" pos:[100,172] tristate:0
	groupBox grp2 "Capsule parameters" pos:[10,190] width:151 height:70
	radiobuttons axis labels:#("X       ", "Y       ", "Z") pos:[20,207]
	spinner heightCaps "height" range:[1,5000,100] type:#float pos:[20,230] width:120 
	
	timer Zrange "" interval:250

	on editBox open do
		(
		--Gestion des Layers--
		Global refLayer
		refLayer=0
		
		for i in 0 to (layermanager.count - 1) do
			(
			layer = layermanager.getlayer i
			if layer.name=="ref" do refLayer = i
			if layer.name=="REF" do refLayer = i
			if layer.name=="Ref" do refLayer = i
			)
		if reflayer==0 do
			(
			refLayer=layermanager.count
			layermanager.newLayerFromName "ref"	
			)
	
		layer = layermanager.getlayer refLayer
		layer.current=true
		layer.on=true
			
		progbar=0
		editbox.axis.state=3
		if $NormalsHotspot==undefined and $ !=undefined 
		then point name:"NormalsHotspot" size:10 constantScreensize:true drawontop:true pos:[$.center.x,$.center.y,$.center.z/4] wirecolor:(color 255 0 0) ()
		if $ !=undefined do
			(
			EditBox.hotspotz.range=[$.min.z,$.max.z,editBox.hotspotz.range[3]]
			edtx.range=[$.min.x,$.max.x,$NormalsHotspot.pos.x]
			edty.range=[$.min.y,$.max.y,$NormalsHotspot.pos.y]
			)
			
		if $ !=undefined and classof $.baseobject == Editable_Mesh do	
			(
			if $ !=undefined and $.selectedfaces.count!=0 do --si la selection est locale > faut rechercher le nouveau centre de cette selection	
				( 
				localSel= editable_mesh () 
				localSel.pos = $.pos
				localSel.mesh = meshop.detachFaces $ $.selectedfaces delete:false asmesh:true
				SelectHotspot=(localSel.min + localSel.max)/2
				delete localSel 
				$NormalsHotspot.pos.x=SelectHotspot.x
				$NormalsHotspot.pos.y=SelectHotspot.y
				)
			)
				
		if $ !=undefined and classof $.baseobject == Editable_Poly do 	
			(
			if $ !=undefined do  --si la selection est locale > faut rechercher le nouveau centre de cette selection	
				(
				$.EditablePoly.getSelection #Face
				facesSel= $.getSelection #Face
				vertsel=polyop.getVertsUsingFace $ facesSel
				if vertSel.numberset!=0 do
					(
					coordSelX=for i in vertSel collect (polyop.getvert $ i)[1]
					sort coordSelX
					coordSelY=for i in vertSel collect (polyop.getvert $ i)[2]
					sort coordSelY
					SelectHotspotX=(coordSelX[1] + coordSelX[coordSelX.count])/2 
					SelectHotspotY=(coordSelY[1] + (coordSelY[coordSelY.count]))/2
					$NormalsHotspot.pos.x=SelectHotspotX
					$NormalsHotspot.pos.y=SelectHotspotY
					)
				)
			)
		)

	on Zrange tick do
		(
		--effacer le hotspot et les helpers si pas de selection
		if $==undefined and $NormalsHotspot != undefined do delete $NormalsHotspot 
		if $==undefined and $NormalsHotspotHi != undefined do delete $NormalsHotspotHi 
		if $==undefined and $NormalsHotspotLo != undefined do delete $NormalsHotspotLo
		if $==undefined and $Hlpcps != undefined do delete $Hlpcps
		if $==undefined and $hlp != undefined do delete $hlp
		if $==undefined and $dsp != undefined do delete $dsp
		
		--Ré-initialiser pour un nouvel objet selectionné 
		if $NormalsHotspot==undefined and $!=undefined do
			(
			if EditBox.open do 
				(
				MemPos=GetDialogPos EditBox
				destroydialog EditBox
				)
			if EditBox.open==false do 
				(
				createDialog EditBox width:170  height:270 pos:MemPos
				max modify mode
				)
			)	
		)
		
	on generate pressed do
		(
		if selection[1]==undefined 	then messagebox "select an object first please."
									else 
									(
									spherifyNormals()
									if $hlp != undefined do delete $hlp
									if $dsp != undefined do delete $dsp
									)						
		)
		
	on reset pressed do
		(
		 if selection[1]==undefined then messagebox "select an object first please."
									else 
									(
									resetNormals()
									if $hlp != undefined do delete $hlp
									)
		)

	on hotspotz changed val do
		(
		if $NormalsHotspot==undefined 	then messagebox "Select an object first please."
										else if val!= $NormalsHotspot.pos.z do 
										(
										$NormalsHotspot.pos.z=val
										if $hlpcps!= undefined do
											(
											setknotpoint $hlpcps 1 1 $NormalsHotspotHi.pos
											setknotpoint $hlpcps 1 2 $NormalsHotspot.pos
											setknotpoint $hlpcps 1 3 $NormalsHotspotLo.pos
											updateShape $hlpcps
											)
										)																		
		)
	
	on edtx changed val do 
		(
		if $NormalsHotspot==undefined 	then messagebox "Select an object first please."
										else if val!= $NormalsHotspot.pos.x do 
										(
										$NormalsHotspot.pos.x=val
										if $hlpcps!= undefined do
											(
											setknotpoint $hlpcps 1 1 $NormalsHotspotHi.pos
											setknotpoint $hlpcps 1 2 $NormalsHotspot.pos
											setknotpoint $hlpcps 1 3 $NormalsHotspotLo.pos
											updateShape $hlpcps
											)
										)
		)
		
	on edty changed val do
		( 
		if $NormalsHotspot==undefined 	then messagebox "Select an object first please."
										else if val!= $NormalsHotspot.pos.y do
										( 
										$NormalsHotspot.pos.y=val
										if $hlpcps!= undefined do
											(
											setknotpoint $hlpcps 1 1 $NormalsHotspotHi.pos
											setknotpoint $hlpcps 1 2 $NormalsHotspot.pos
											setknotpoint $hlpcps 1 3 $NormalsHotspotLo.pos
											updateShape $hlpcps
											)
										)	
		)

	on sphereMod changed thestate do
		(
		if editbox.sphereMod.state
		then 
			(
			editbox.capsuleMod.state=false
			editbox.sphereMod.state=true
			if $hlpcps!=undefined do delete $hlpcps
			if $NormalsHotspotHi!=undefined do delete $NormalsHotspotHi
			if $NormalsHotspotLo!=undefined do delete $NormalsHotspotLo
			$NormalsHotspot.ishidden=false
			)
		else
			(
			editbox.capsuleMod.state=true
			editbox.sphereMod.state=false
			)
		DisplayNormals()
		)
		
	on capsuleMod changed thestate do	
		(
		if editbox.capsuleMod.state
		then 
			(
			editbox.sphereMod.state=false
			editbox.capsuleMod.state=true
			if $NormalsHotspotHi==undefined and $NormalsHotspotLo==undefined do
				(
				point name:"NormalsHotspotHi" size:10 constantScreensize:true drawontop:true pos:[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,$NormalsHotspot.pos.z] wirecolor:(color 255 0 0) ()
				point name:"NormalsHotspotLo" size:10 constantScreensize:true drawontop:true pos:[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,$NormalsHotspot.pos.z] wirecolor:(color 255 0 0) ()
				$NormalsHotspotHi.parent = $NormalsHotspot ; $NormalsHotspotLo.parent = $NormalsHotspot
				NormalsCapsHelper = SplineShape name:"hlpCps" pos:$NormalsHotspot.pos wirecolor:(color 255 0 0)
				case axis.state of 
						(
							1 : $NormalsHotspotHi.pos=[($NormalsHotspot.pos.x+(editbox.heightcaps.value/2)),$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
							2 : $NormalsHotspotHi.pos=[$NormalsHotspot.pos.x,($NormalsHotspot.pos.y+(editbox.heightcaps.value/2)),$NormalsHotspot.pos.z]
							3 : $NormalsHotspotHi.pos=[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,($NormalsHotspot.pos.z+(editbox.heightcaps.value/2))] 
							default:[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
						)
				case axis.state of 
						(
							1 : $NormalsHotspotLo.pos=[($NormalsHotspot.pos.x-(editbox.heightcaps.value/2)),$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
							2 : $NormalsHotspotLo.pos=[$NormalsHotspot.pos.x,($NormalsHotspot.pos.y-(editbox.heightcaps.value/2)),$NormalsHotspot.pos.z]
							3 : $NormalsHotspotLo.pos=[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,($NormalsHotspot.pos.z-(editbox.heightcaps.value/2))] 
							default:[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
						)
				addNewSpline NormalsCapsHelper
				addKnot NormalsCapsHelper 1 #corner #line $NormalsHotspotHi.pos
				addKnot NormalsCapsHelper 1 #corner #line $NormalsHotspot.pos
				addKnot NormalsCapsHelper 1 #corner #line $NormalsHotspotLo.pos
				updateShape NormalsCapsHelper	
				close NormalsCapsHelper 1
				$NormalsHotspot.ishidden=true
				DisplayNormals()
				)
			)
		else
			(
			editbox.sphereMod.state=true
			editbox.capsuleMod.state=false
			)
		)

	on heightCaps changed val do
		( 
		if $NormalsHotspotHi==undefined 	then messagebox "Valid only in Capsule mode."
											else if $NormalsHotspot!=undefined do 
											case axis.state of
											(
											1 : $NormalsHotspotHi.pos=[($NormalsHotspot.pos.x+(editbox.heightcaps.value/2)),$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
											2 : $NormalsHotspotHi.pos=[$NormalsHotspot.pos.x,($NormalsHotspot.pos.y+(editbox.heightcaps.value/2)),$NormalsHotspot.pos.z]
											3 : $NormalsHotspotHi.pos=[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,($NormalsHotspot.pos.z+(editbox.heightcaps.value/2))] 
											)
											
		if $NormalsHotspotLo==undefined 	then messagebox "Valid only in Capsule mode."
											else if $NormalsHotspot!=undefined do 
											case axis.state of
											(
											1 : $NormalsHotspotLo.pos=[($NormalsHotspot.pos.x-(editbox.heightcaps.value/2)),$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
											2 : $NormalsHotspotLo.pos=[$NormalsHotspot.pos.x,($NormalsHotspot.pos.y-(editbox.heightcaps.value/2)),$NormalsHotspot.pos.z]
											3 : $NormalsHotspotLo.pos=[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,($NormalsHotspot.pos.z-(editbox.heightcaps.value/2))] 
											)
		setknotpoint $hlpcps 1 1 $NormalsHotspotHi.pos
		setknotpoint $hlpcps 1 3 $NormalsHotspotLo.pos
		updateShape $hlpcps
		DisplayNormals()
		)
		
	on axis changed state do
		(
		if $NormalsHotspotHi!=undefined and $NormalsHotspot!=undefined do 
			(
			case axis.state of 
					(
					1 : $NormalsHotspotHi.pos=[($NormalsHotspot.pos.x+(editbox.heightcaps.value/2)),$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
					2 : $NormalsHotspotHi.pos=[$NormalsHotspot.pos.x,($NormalsHotspot.pos.y+(editbox.heightcaps.value/2)),$NormalsHotspot.pos.z]
					3 : $NormalsHotspotHi.pos=[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,($NormalsHotspot.pos.z+(editbox.heightcaps.value/2))] 
					)
			)
		if $NormalsHotspotLo!=undefined and $NormalsHotspot!=undefined do 
			(
			case axis.state of 
					(
					1 : $NormalsHotspotLo.pos=[($NormalsHotspot.pos.x-(editbox.heightcaps.value/2)),$NormalsHotspot.pos.y,$NormalsHotspot.pos.z]
					2 : $NormalsHotspotLo.pos=[$NormalsHotspot.pos.x,($NormalsHotspot.pos.y-(editbox.heightcaps.value/2)),$NormalsHotspot.pos.z]
					3 : $NormalsHotspotLo.pos=[$NormalsHotspot.pos.x,$NormalsHotspot.pos.y,($NormalsHotspot.pos.z-(editbox.heightcaps.value/2))] 
					)
			)
		setknotpoint $hlpcps 1 1 $NormalsHotspotHi.pos
		setknotpoint $hlpcps 1 3 $NormalsHotspotLo.pos
		updateShape $hlpcps
		DisplayNormals()
		)

	--refresh green helper normals
	on edtx entered do DisplayNormals()
	on edty entered do DisplayNormals()
	on edtx buttonup do DisplayNormals()
	on edty buttonup do DisplayNormals()
	on hotspotz buttonup do DisplayNormals()
						
	--close
	on editBox close do
	(
	if $hlp != undefined do delete $hlp
	if $hlpcps != undefined do delete $hlpcps
	if $dsp != undefined do delete $dsp
	if $NormalsHotspot != undefined do delete $NormalsHotspot
	if $NormalsHotspotHi != undefined do delete $NormalsHotspotHi
	if $NormalsHotspotLo != undefined do delete $NormalsHotspotLo

	)
	
)
createDialog EditBox width:170  height:270


/*
utility ut_spherify "Spherify Normals"	
(
	button openBox "Edit" offset:[0, 0] width:100

	on openBox pressed do
		(
		--Gestion des Layers--
		Global refLayer
		refLayer=0
		
		for i in 0 to (layermanager.count - 1) do
			(
			layer = layermanager.getlayer i
			if layer.name=="ref" do refLayer = i
			if layer.name=="REF" do refLayer = i
			if layer.name=="Ref" do refLayer = i
			)
		if reflayer==0 do
			(
			refLayer=layermanager.count
			layermanager.newLayerFromName "ref"	
			)
	
		layer = layermanager.getlayer refLayer
		layer.current=true
		layer.on=true
		----------------------

		createDialog EditBox width:170  height:270
		max modify mode
		)
		
	on ut_spherify close do
		(
		if $hlp != undefined do delete $hlp
		if $hlpcps != undefined do delete $hlpcps
		if $dsp != undefined do delete $dsp
		if $NormalsHotspot != undefined do delete $NormalsHotspot
		if $NormalsHotspotHi != undefined do delete $NormalsHotspotHi
		if $NormalsHotspotLo != undefined do delete $NormalsHotspotLo
		if EditBox.open do destroydialog EditBox
		--max modify mode
		)
)
