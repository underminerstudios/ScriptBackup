-- CV - LOD generator
-- Auto LOD generator - For 3D artists lacking time to do it themselves
-- By Gwen Heliou - gwenael.heliou@gameloft.com
-- Edited by Norman Schaar - norman.schaar@gameloft.com
-- Edited by Xiaobin Huang - xiaobin.huang@gameloft.com
/*
	Changes:
	- Uses ProOptimizer instead of MultiRes
	- Create LODs for multiple objects at the same time
	- LODs are created in the same layer
	- LODs are created in the same position as the source object
	- Streamlined UI
*/

try(destroydialog MA2_CV_LODGen)catch()

fn MA2_CV_LODGen_Create theMesh LODval LODSufx KeepTexture OptMode =
(
	--Copy Mesh
	newObj = copy theMesh
	--Add to layer
	theLayer = theMesh.layer
	theLayer.addnode newObj
	--Name
	newObj.name = (theMesh.name + LODSufx) as string
	--ProOptimizer
	addmodifier newObj (ProOptimizer())
	newObj.ProOptimizer.Calculate = true
	newObj.ProOptimizer.VertexPercent = LODval
	newObj.ProOptimizer.KeepUV = KeepTexture
	newObj.ProOptimizer.OptimizationMode = OptMode - 1
	--3dsMax 2010/2011 bug, we need to add a smooth modifier and then delete it in order for the ProOptimizer "Calculate" value to work
	addmodifier newObj (smooth()) 
	deleteModifier newObj 1
	newObj.ProOptimizer.Calculate = true
--	converttomesh newObj
	case of
	(
		(LODSufx=="_LOD01"):(newObj.pos.x = theMesh.pos.x)
		(LODSufx=="_LOD02"):(newObj.pos.x = theMesh.pos.x)
		(LODSufx=="_LOD03"):(newObj.pos.x = theMesh.pos.x)
		default:()
	)
	-- redrawViews()
	completeRedraw()
	
	newObj
)

rollout MA2_CV_LODGen "CV - LOD generator" width:250 height:360
(
	group ""
	(
		spinner spn1 "% LOD01 " width:126 height:16 range:[5,100,100] type:#integer scale:5
		spinner spn2 "% LOD02 " width:126 height:16 range:[5,100,75] type:#integer scale:5
		spinner spn3 "% LOD03 " width:126 height:16 range:[5,100,50] type:#integer scale:5
		spinner spLodCount "LOD Count" type:#integer range:[2, 3, 3]
		dropdownlist dlOptimizeMode "Optimization Mode" items:#("Crunch Borders", "Protect Borders", "Exclude Borders") selection:3
		checkbox ckTexture "Keep Textures" checked:false
		checkbox ckConnectParent "Connect to parent node" checked:false
		edittext edParentPrefix "Parent Name Prefix" text:"objlod_" enabled:false
	)
	button btn1 "Generate LODs" width:100 height:37
	edittext et_description height:65 readonly:true
	
	on spLodCount changed val do
	(
		local ss = #(spn1, spn2, spn3)
		for s in ss do
		(
			s.enabled = false
		)
		for i = 1 to val do
		(
			ss[i].enabled = true
		)
		
	)
	
	on ckConnectParent changed val do
	(
		edParentPrefix.enabled = val
	)

	on btn1 pressed do
	(
		undo "create lod" on
		(
			
		if selection.count == 0 then
		(
			messagebox "Select a mesh first"
		)
		else
		(
			for n in selection do
			(
				
				LOD01Val = spn1.value
				LOD01Sufx = "_LOD01"
				LOD02Val = spn2.value
				LOD02Sufx = "_LOD02"
				LOD03Val = spn3.value 
				LOD03Sufx = "_LOD03"
				
				newObjs = #()
				
				if spn1.enabled then 
				(
					append newObjs (MA2_CV_LODGen_Create n LOD01Val LOD01Sufx ckTexture.checked dlOptimizeMode.selection)
				)
				if spn2.enabled then 
				(
					append newObjs (MA2_CV_LODGen_Create n LOD02Val LOD02Sufx ckTexture.checked dlOptimizeMode.selection)
				)
				if spn3.enabled then 
				(
					append newObjs (MA2_CV_LODGen_Create n LOD03Val LOD03Sufx ckTexture.checked dlOptimizeMode.selection)
				)
				
				if ckConnectParent.checked and newObjs.count > 0 then
				(
					local parentName = uniqueName edParentPrefix.text
					local p = (Dummy boxsize:[1, 1, 1])
					p.name = parentName
					p.position = newObjs[1].position
					for s in newObjs do 
					(
						s.parent = p
					)
					
				)
			)
		)
		
		)
	)
	
	on MA2_CV_LODGen open do
	(
		theDescription = ""
		theDescription += "In order to change the ProOptimizer options" 	+ "\n"
		theDescription += "apply a ProOptimizer modifier to any object" 	+ "\n"
		theDescription += "in the scene and change the values."			    + "\n"
		theDescription += "These values will be used by the script."		
		et_description.text = theDescription
	)
)

createdialog MA2_CV_LODGen
