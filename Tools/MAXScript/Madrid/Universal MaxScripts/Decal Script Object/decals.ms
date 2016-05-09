plugin helper DecalObject2
	name:"DecalObject2"
	classID:#(0x73e8aa9d, 0x6d2f9400)
	extends:dummy
(
	function BoxFromDecalObject MyDummy JustPlane:False BoxMat:undefined = 
	(
		DummyDimensions = MyDummy.dummy.boxsize
		MyBox = box lengthsegs:1 widthsegs:1 heightsegs:1 length:DummyDimensions.x width:DummyDimensions.y height:DummyDimensions.z realWorldMapSize:off isSelected:off mapcoords:on
		CenterPivot MyBox
		MyBox.transform = MyDummy.transform
		if JustPlane ==true  do
		(
			converttomesh MyBox
			FacesToTrash = MyBox.selectedfaces = #(3,4,5,6,7,8,9,10,11,12)
			delete MyBox.selectedfaces
		)
		if BoxMat != undefined  do
		(
			MyBox.material = BoxMat
		)
		MyBox
	)
	function DeleteBackFaces MyObj MyVec MyValue =
	(
		if ((classOf MyObj) != Editable_Mesh) then 
		(
			convertTo MyObj TriMeshGeometry
		)
		toDelete = #()
		for i =1 to meshop.getnumfaces MyObj do 
		(
		
			if (dot MyVec (getFaceNormal MyObj i)) > MyValue then
			(
				continue
			)
			append toDelete i
		)
		meshop.deletefaces MyObj toDelete
	)

	local decalOnObjs = #()
	local decalObjNames = #()
	parameters DecalParams rollout:Roll_DecalParams
	(
		DecalMaterial type:#material ui:DecalMaterial
		PushAmount type:#float default:0.01 ui:PushAmount
		BackFaceAmount type:#float default:0.000 ui:BackFaceAmount
	)
	rollout Roll_DecalParams "Decal Parameters"
	(
		group "Step 1"
		(
			label lbMaterial "Decal Material:"
			materialbutton DecalMaterial "Decal Material" type:#material
			button CreateDecal "Create Decal"
		)
		group "Step 2"
		(
			
			listbox AssObjs "Associated Objects" items:decalObjNames
			PickButton PickAssObj "Pick Object"
			button ClearAssObjs "Clear Objects"
			spinner PushAmount "Push Amount" value:this.PushAmount range:[0.0, 1.0, 0.01] type:#float scale:0.01
			spinner BackFaceAmount "Backface" value:this.BackFaceAmount range:[-1.0, 1.0, 0.001] type:#float scale:0.001

		)
		button DoDecal "Make Decal" width:150
		on DecalMaterial picked mat do
		(
			if $.children[1] != undefined do
			(
				$.children[1].material = mat
			)
		)
		on CreateDecal pressed do
		(
			if $.children.count == 0 then
			(
				MyDecObj = $
				ShowObj = BoxFromDecalObject MyDecObj JustPlane:true BoxMat:this.DecalMaterial
				ShowObj.pos.controller = Position_Constraint()
				ShowObj.pos.controller.appendTarget MyDecObj 100
				ShowObj.rotation.controller = Orientation_Constraint()
				ShowObj.rotation.controller.appendTarget MyDecObj 100
				ShowObj.scale.controller = SlaveScale ()
				ShowObj.parent = MyDecObj
				ShowObj.name = ("DecalSurface_"+ MyDecObj.name)
				addModifier ShowObj (uvwmap())
				select MyDecObj
			)
		)
		on PickAssObj picked obj do
		(
			if obj != $ then
			(
				if (appendIfUnique decalOnObjs obj) then
				(
					decalObjNames = #()
					for o in decalOnObjs do
					(
						append decalObjNames o.name
					)
					AssObjs.items = decalObjNames
				)
				
			)
		)
		on AssObjs rightClick index do
		(
			local objName = AssObjs.items[index]
			local objs = #()
			decalObjNames = #()
			for o in decalOnObjs do
			(
				if o.name != objName then
				(
					append objs o
					append decalObjNames o.name
				)
			)
			decalOnObjs = objs
			AssObjs.items = decalObjNames
			
		)
		on ClearAssObjs pressed do
		(
			decalOnObjs = #()
			AssObjs.items = #()
		)
		on DoDecal pressed do
		(
			disableSceneRedraw()
			try (
				
			local theDecalObj = $
			local objs = decalOnObjs
			local mergedObj
			if (objs.count == 0) then
			(
				messageBox "Plz pick objects to be decaled."
				enableSceneRedraw()
				redrawViews()
				return false
			)
			if (objs.count > 1) then
			(
				-- merge them
				mergedObj = copy objs[1]
				convertToPoly mergedObj
				for i = 2 to objs.count do
				(
					local tmp = copy objs[i]
					convertToPoly tmp
					polyOp.attach mergedObj tmp
				)
			)
			else
			(
				mergedObj = copy objs[1]
				
			)
			mergedObj.name = "Merged Object to be decaled"
			decalBox = BoxFromDecalObject theDecalObj BoxMat:this.DecalMaterial
			decalBox.name = "Decal Project Box"
			
			-- create boolean obj
			theDecal = boolObj.createBooleanObject decalBox mergedObj 4 4
			boolObj.setBoolOp theDecal 2
			theDecal.name = uniqueName "Decal_" numDigits:3
			convertToMesh theDecal
	
			-- push out
			addModifier theDecal (push())
			theDecal.modifiers[1].push_value = this.PushAmount
			collapseStack theDecal
			
			-- delete backfaces
			DeleteBackFaces theDecal (-1*theDecalObj.dir) this.BackFaceAmount
			meshOps.removeIsolatedVerts theDecal
				
			convertToPoly theDecal
				
			-- uvwmap
			if (theDecalObj.children.count == 1) then
			(
				local ProjectPlane = theDecalObj.children[1]
				local m = projectPlane.modifiers[1]
				addModifier theDecal (copy m)
			)
				
			theDecal.material = this.DecalMaterial
			
			) catch ()
			
			
			
			select theDecalObj
			enableSceneRedraw()
			redrawviews()
		)
	)
)