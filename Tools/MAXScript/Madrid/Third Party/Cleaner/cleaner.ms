(
clearListener()
	
	try destroyDialog cCleanerRollout catch()
	
	global lTasks_4648134686 =
	#(
		(struct s( tName = "--Scene--Notetracks",
			
			tTooltip = "\
			3ds Max tends to automaticly save notetracks in your scenes that are comments for animationtracks. \
			However these notetracks can become quite numerous and dramatically increase the size of your scene and make saving process extremly slow. \
			So it is a good idea to keep an eye on these automaticly created notetracks and clean them from time to time. \
			Remember that you will import notetracks from other files if you are using xrefs. \
			Cleaning just the scene doesn't solve the problem, you got to clean the xref aswell or you will import the notetracks everytime you load the xref.
			",
			
			fn autocount =
			(
				try (numNoteTracks TrackViewNodes.Max_MotionClip_Manager) catch ("-")
			),
			
			fn clean =
			(
				try 
				(
					trackViewNodes[#Max_MotionClip_Manager].track = copy trackViewNodes[#Max_MotionClip_Manager].track
					gc()
				)
				catch()
			)
			
		);)(),
		
		(struct s( tName = "Reactor Collisions",
			
			tTooltip = "\
			3ds Max tends to save reactor collisions in your scene. \
			Just as notetracks this can increase the filesize, ram usage, savetime for your scene. \
			However Reactor is not part of 3ds Max anymore from version 2012 on.\
			",
			
			fn autocount =
			(
				if reactor != undefined
					then reactor.getNumStoredCollisions()
					else "-"
			),
			
			fn clean =
			(
				if reactor != undefined then reactor.clearStoredCollisions()
			)
			
		);)(),
		
		(struct s( tName = "Empty Layers",
			
			tTooltip = "Deletes layers that don't contain any objects. Note that the default layer 0 can not be deleted.",
			
			fn autocount =
			(
				local nEmptyLayers = 0
				
				for nLayer = layerManager.count to 2 by -1 do
				(
					local layer = layerManager.getLayer (nLayer - 1)
					
					local lNodes = undefined
					layer.nodes &lNodes
					
					if lNodes.count == 0 do nEmptyLayers += 1
				)
				
				return nEmptyLayers
			),
			
			fn clean =
			(
				-- active layer = layer 0
				(layerManager.getLayer 0).current = true
				
				for nLayer = layerManager.count to 2 by -1 do
				(
					local layer = layerManager.getLayer (nLayer - 1)
					
					local lNodes = undefined
					layer.nodes &lNodes
					
					if lNodes.count == 0 do layerManager.deleteLayerByName layer.name
				)
			)
			
		);)(),
		
		(struct s( tName = "Materialeditor",
			
			tTooltip = "Resets the materialeditor to default materials with enabled background.",
			
			fn autocount =
			(
				"-"
			),
			
			fn clean =
			(
				for nMat = 2 to meditMaterials.count do
				(
					local tMat = "mat"+(sceneMaterials.count + nMat) as string
					local mat = if matchpattern (renderers.current as string) pattern:"v_ray*"
						then vraymtl name:tMat
						else standardmaterial name:tMat
					
					mat.diffuse = (color 30 30 30)
					setMTLMEditFlags mat #{2..3}
					setMeditMaterial nMat mat
				)
			)
			
		);)(),
		
		(struct s( tName = "Missing Plugins",
			
			tTooltip = "To display your scene correctly all plugins must exist that have been used to create this scene, some might be missing which causes an error when loading the scene.",
			
			fn autocount =
			(
				""
			),
			
			fn usercount =
			(
				local nCount = 0
				
				local t = stringstream ""
				apropos "*missing*" to:t
				t = t as string
				
				local l = filterstring t "\n "
				local lMissingClasses = #()
				for t in l do
				(
					if matchpattern t pattern:"missing*" then
					(
						local cls = execute t
						if matchpattern (cls as string) pattern:"missing*" then
						(
							local lInst = getclassinstances cls
							nCount += lInst.count
						)
					)
				)
				
				nCount
			),
			
			fn clean =
			(
				local t = stringstream ""
				apropos "*missing*" to:t
				t = t as string
				
				local l = filterstring t "\n "
				local lMissingClasses = #()
				for t in l do
				(
					if matchpattern t pattern:"missing*" then
					(
						local cls = execute t
						if matchpattern (cls as string) pattern:"missing*" then
						(
							local lInst = getclassinstances cls
							print lInst
						)
					)
				)
			)
			
		);)(),
		
		(struct s( tName = "Missing Custom Attributes",
			
			tTooltip = "Some weird chinese bug? Select the treeitem that has a 'Custom Attribute' as the last childitem. Do NOT pick the 'Custom Attribute' directly, the script needs you to select the parent-track.",
			
			fn autocount =
			(
				"-"
			),
			
			fn clean =
			(
				local pickedTrack = trackView.pickTrackDlg()
				if pickedTrack != undefined then deleteItem pickedTrack.anim.CustAttributes 1
			)
			
		);)(),
		
		(struct s( tName = "Scene States",
			
			tTooltip = "Some weird chinese bug? Select the treeitem that has a 'Custom Attribute' as the last childitem. Do NOT pick the 'Custom Attribute' directly, the script needs you to select the parent-track.",
			
			fn autocount =
			(
				sceneStateMgr.GetCount()   
			),
			
			fn clean =
			(
				for n=sceneStateMgr.GetCount() to 1 by -1 do sceneStateMgr.Delete (sceneStateMgr.GetSceneState n)
			)
			
		);)(),
		
		(struct s( tName = "Selection Sets",
			
			tTooltip = "Some weird chinese bug? Select the treeitem that has a 'Custom Attribute' as the last childitem. Do NOT pick the 'Custom Attribute' directly, the script needs you to select the parent-track.",
			
			fn autocount =
			(
				selectionSets.count
			),
			
			fn clean =
			(
				for n=selectionSets.count to 1 by -1 do deleteItem selectionSets selectionSets[n]
			)
			
		);)(),
		
		(struct s( tName = "Retimers",
			
			tTooltip = "The Retimer Controller was introduced in 3ds Max 2013 as an alternative procedural EaseCurve controller. It can be used in the EaseCurve track of any controller or as a Global Retirmer Controller affecting the whole scene.",
			
			fn autocount =
			(
				if RetimerMan == undefined then "-" else RetimerMan.numRetimers 
			),
			
			fn clean =
			(
				-- for hamletik by Artyom, suggested by TexeL
				nrt=RetimerMan.numRetimers
				for i = 1 to nrt do
				(
					j=nrt-i+1
					n=RetimerMan.GetNthRetimer j
					if n!=undefined then
					(
						if n.nummarkers==0 then
						(
							RetimerMan.DeleteRetimer j
						)
					)
				)
			)
			
		);)(),
		
		(struct s( tName = "--IDs--Object IDs",
			
			tTooltip = "Sets all object ids in the scene to 0.",
			
			fn autocount =
			(
				local lObjIds = #()
				
				for obj in objects where obj.gbufferchannel != 0 do appendIfUnique lObjIds obj.gbufferchannel
				
				print "object ids:"
				print ((sort lObjIds) as string)
				
				return lObjIds.count
			),
			
			fn clean =
			(
				for obj in objects do obj.gbufferchannel = 0
			),
			
			fn selectObjects =
			(
				local lObjs = #()
				for obj in objects where obj.gbufferchannel != 0 do append lObjs obj
				
				select lObjs
				
				local bRefreshSel = false
				for obj in selection do
				(
					if isGroupHead obj and not isOpenGroupHead obj then
					(
						bRefreshSel = true
						setGroupOpen obj true
					)
				)
				if bRefreshSel then select lObjs
			)
			
		);)(),
		
		(struct s( tName = "Material ID Channels",
			
			tTooltip = "Sets all material id channels in the scene to 0.",
			
			fn autocount =
			(
				local lMatIds = #()
				
				for mat in scenematerials do
				(
					try
					(
						if classof mat == multimaterial
							then for subMat in mat.materialList where subMat.effectsChannel != 0 do appendIfUnique lMatIds subMat.effectsChannel 
							else if mat.effectsChannel != 0 then appendIfUnique lMatIds mat.effectsChannel
					)
					catch ()
				)
				
				print "material ids:"
				print ((sort lMatIds) as string)
				
				return lMatIds.count
			),
			
			fn clean =
			(
				for mat in scenematerials do
				(
					try
					(
						if classof mat == multimaterial
							then for subMat in mat.materialList where subMat.effectsChannel != 0 do subMat.effectsChannel = 0
							else if mat.effectsChannel != 0 then mat.effectsChannel = 0
					)
					catch ()
				)
			),
			
			fn selectObjects =
			(
				local lMats = #()
				
				for mat in scenematerials do
				(
					try
					(
						if classof mat == multimaterial
							then for subMat in mat.materialList where subMat.effectsChannel != 0 do appendIfUnique lMats subMat
							else if mat.effectsChannel != 0 then appendIfUnique lMats mat
					)
					catch ()
				)
				
				local lObjs = #()
				for mat in lMats do for obj in (refs.dependents mat) where classof (superclassof obj) == node do appendIfUnique lObjs obj
				
				select lObjs
				
				local bRefreshSel = false
				for obj in selection do
				(
					if isGroupHead obj and not isOpenGroupHead obj then
					(
						bRefreshSel = true
						setGroupOpen obj true
					)
				)
				if bRefreshSel then select lObjs
			),
			
			fn selectMaterials =
			(
				local lMats = #()
				
				for mat in scenematerials do
				(
					try
					(
						if classof mat == multimaterial
							then for subMat in mat.materialList where subMat.effectsChannel != 0 do appendIfUnique lMats subMat
							else if mat.effectsChannel != 0 then appendIfUnique lMats mat
					)
					catch ()
				)
				
				for nMat = 1 to lMats.count where nMat <= meditMaterials.count do setMeditMaterial nMat lMats[nMat]
			)
			
		);)(),
		
		(struct s( tName = "--Geometry--Shell Mod. No Straight Corners",
			
			tTooltip = "Always useful to have the option 'straighten corners' enabled in shell-modifiers to avoid skewed edges.",
			
			fn autocount =
			(
				local nCount = 0
				
				for modObj in getclassinstances shell where not modObj.straightenCorners do nCount += 1
				
				nCount
			),
			
			fn clean =
			(
				for modObj in getclassinstances shell where not modObj.straightenCorners do modObj.straightenCorners = true
			),
			
			fn selectObjects =
			(
				local lmodInst = getclassinstances shell
				
				local lObjs = #()
				for modObj in lmodInst do for obj in (refs.dependents modObj) where classof (superclassof obj) == node do appendIfUnique lObjs obj
				
				select lObjs
				
				local bRefreshSel = false
				for obj in selection do
				(
					if isGroupHead obj and not isOpenGroupHead obj then
					(
						bRefreshSel = true
						setGroupOpen obj true
					)
				)
				if bRefreshSel then select lObjs
			)
			
		);)(),
		
		(struct s( tName = "Flipped IES",
			
			tTooltip = "IES Scale must be positive, or their normal is flipped and they point upwards.",
			
			fn autocount =
			(
				local nCount = 0
				
				for iesLight in lights where classof iesLight == VRayIES do
				(
					if iesLight.transform[3].z < 0 and iesLight.center.z > iesLight.target.pos.z then nCount += 1
				)
				
				nCount
			),
			
			fn clean =
			(
				for iesLight in lights where classof iesLight == VRayIES do
				(
					if iesLight.transform[3].z < 0 and iesLight.center.z > iesLight.target.pos.z then
					(
						-- unlink
						local lChilds = for child in iesLight.children collect child
						local parent = iesLight.parent
						for child in lChilds do child.parent = undefined
						iesLight.parent = undefined
						
						iesLight.scale = [1,1,1]
						
						-- relink
						for child in lChilds do child.parent = iesLight
						iesLight.parent = parent
					)
				)
			)
			
		);)(),
		
		(struct s( tName = "Link Composite",
			
			tTooltip = "Somtimes when you import AutoCad models (with windows, doors, ...) in max, you will find a lot invisible objects of type LinkComposite.",
			
			fn autocount =
			(
				(getclassinstances LinkComposite).count
			),
			
			fn clean =
			(
				delete (for o in (getclassinstances LinkComposite astrackviewpick:true) collect o.client)
			)
			
		);)(),
		
		(struct s( tName = "Missing Geometry Objects",
			
			tTooltip = "Missing plugins to display objects in your scene.",
			
			fn autocount =
			(
				local nCount = 0
				
				for obj in objects where matchpattern ((classof obj) as string) pattern:"*miss*" do nCount += 1
				
				nCount
			),
			
			fn clean =
			(
				for obj in objects where matchpattern ((classof obj) as string) pattern:"*miss*" do delete obj
			),
			
			fn selectObjects =
			(
				local lObjs = #()
				for obj in objects where matchpattern ((classof obj) as string) pattern:"*miss*" do append lObjs obj
				
				select lObjs
				local bRefreshSel = false
				for obj in selection do
				(
					if isGroupHead obj and not isOpenGroupHead obj then
					(
						bRefreshSel = true
						setGroupOpen obj true
					)
				)
				if bRefreshSel then select lObjs
			)
			
		);)(),
		
		(struct s( tName = "--Materials--Missing Texturemap Classes",
			
			tTooltip = "Missing Texturemap Classes in your scene generally indicate that the scene you opened is using plugins you don't got installed on your computer.",
			
			fn autocount =
			(
				(getclassinstances missing_texturemap).count
			),
			
			fn clean =
			(
				local lTvps = #()
				for tvp in (getclassinstances missing_texturemap asTrackViewPick:true) do appendIfUnique lTvps tvp.client
				for tvp in lTvps do 
				(
					local lPropNames = getPropNames tvp
					for propName in lPropNames do
					(
						local prop = getproperty tvp propName
						if classof prop == missing_texturemap then try setProperty tvp propName undefined catch()
					)
				)
			),
			
			fn selectObjects =
			(
				local lObjs = #()
				for mat in (getclassinstances missing_texturemap) do
				(
					for obj in (refs.dependents mat) where classof (superclassof obj) == node do appendIfUnique lObjs obj
				)
				
				select lObjs
				local bRefreshSel = false
				for obj in selection do
				(
					if isGroupHead obj and not isOpenGroupHead obj then
					(
						bRefreshSel = true
						setGroupOpen obj true
					)
				)
				if bRefreshSel then select lObjs
			),
			
			fn selectMaterials =
			(
				local lMats = #()
				
				for mat in (getclassinstances missing_texturemap) do appendIfUnique lMats mat
				
				for nMat = 1 to lMats.count where nMat <= meditMaterials.count do setMeditMaterial nMat lMats[nMat]
			)
			
		);)(),
		
		(struct s( tName = "Bercon Noise",
			
			tTooltip = "Cleans Thinking Particles TP Variation Texmap in ColorCorrects, Vray-Materials and Multisubmaterials.",
			
			fn autocount =
			(
				if berconnoise != undefined
					then (getclassinstances berconnoise).count
					else "-"
			),
			
			fn clean =
			(
				if berconnoise != undefined then 
				(
					local lMaps = makeUniqueArray (getclassinstances berconnoise)
					
					for map in lMaps do
					(
						local lDeps = refs.dependents map
						local parent = lDeps[1]
						local replaceMap = noise \
							color1:map.color1 \
							color2:map.color2 \
							map1:map.map1 \
							map2:map.map2 \
							map1Enabled:map.map1Enabled \
							map2Enabled:map.map2Enabled \
							size:map.size \
							phase:map.phase \
							levels:map.levels \
							thresholdLow:map.thresholdLow \
							thresholdHigh:map.thresholdHigh \
							coords:map.coords \
							output:map.output
						
						if map.fractalType <= 2 then replaceMap.type = map.fractalType
						
						case classof parent of
						(
							ColorCorrect: parent.src_tex = replaceMap
							VrayMtl: parent.texmap_diffuse = replaceMap
							Standardmaterial: parent.diffuseMap = replaceMap
						)
					)
				)
			),
			
			fn selectObjects =
			(
				if berconnoise != undefined then 
				(
					local lObjs = #()
					for mat in (getclassinstances berconnoise) do
					(
						for obj in (refs.dependents mat) where classof (superclassof obj) == node do appendIfUnique lObjs obj
					)
					
					select lObjs
					local bRefreshSel = false
					for obj in selection do
					(
						if isGroupHead obj and not isOpenGroupHead obj then
						(
							bRefreshSel = true
							setGroupOpen obj true
						)
					)
					if bRefreshSel then select lObjs
				)
			),
			
			fn selectMaterials =
			(
				if berconnoise != undefined then 
				(
					local lMats = #()
					
					for mat in (getclassinstances berconnoise) do appendIfUnique lMats mat
					
					for nMat = 1 to lMats.count where nMat <= meditMaterials.count do setMeditMaterial nMat lMats[nMat]
				)
			)
			
		);)(),
		
		(struct s( tName = "TP Variation Texmap",
			
			tTooltip = "Cleans Thinking Particles TP Variation Texmap in ColorCorrects, Vray-Materials and Multisubmaterials.",
			
			fn autocount =
			(
				if tp_variation_texmap != undefined
					then (getclassinstances tp_variation_texmap).count
					else "-"
			),
			
			fn clean =
			(
				if tp_variation_texmap != undefined then 
				(
					local lMaps = makeUniqueArray (getclassinstances tp_variation_texmap)
					
					-- 
					for map in lMaps do
					(
						local lDeps = refs.dependents map
						local parent = lDeps[1]
						
						case classof parent of
						(
							ColorCorrect:
							(
								parent.src_color = parent.src_tex.color
								parent.src_tex = undefined
							)
							VrayMtl:
							(
								parent.diffuse = parent.texmap_diffuse.color
								parent.texmap_diffuse = undefined
							)
							Standardmaterial:
							(
								parent.diffuse = parent.diffuseMap.color
								parent.diffuseMap = undefined
							)
						)
					)
				)
			),
			
			fn selectObjects =
			(
				if tp_variation_texmap != undefined then 
				(
					local lObjs = #()
					for mat in (getclassinstances tp_variation_texmap) do
					(
						for obj in (refs.dependents mat) where classof (superclassof obj) == node do appendIfUnique lObjs obj
					)
					
					select lObjs
					local bRefreshSel = false
					for obj in selection do
					(
						if isGroupHead obj and not isOpenGroupHead obj then
						(
							bRefreshSel = true
							setGroupOpen obj true
						)
					)
					if bRefreshSel then select lObjs
				)
			),
			
			fn selectMaterials =
			(
				if tp_variation_texmap != undefined then 
				(
					local lMats = #()
					
					for mat in (getclassinstances tp_variation_texmap) do appendIfUnique lMats mat
					
					for nMat = 1 to lMats.count where nMat <= meditMaterials.count do setMeditMaterial nMat lMats[nMat]
				)
			)
			
		);)(),
		
		(struct s( tName = "VrayMtl GI Lightmaterials",
			
			tTooltip = "Lightmaterials must be in VrayWrapperMaterials with Generate GI off, otherwise can cause problems with Xrefs.",
			
			fn autocount =
			(
				local nCount = 0
				
				local lLightMtlTvps = getclassinstances VRayLightMtl astrackviewpick:true
				for lightMtlTvp in lLightMtlTvps do
				(
					local lightMtl = lightMtlTvp.anim
					local parent = lightMtlTvp.client
					local wrapperMtl = vraymtlwrapper generateGI:false basemtl:lightMtl
					
					if (classof (superclassof parent)) == node then
					(
						nCount += 1
					)
					
					else if classof parent == multimaterial then
					(
						for nMat = 1 to parent.MaterialList.count do
						(
							if parent.MaterialList[nMat] == lightMtl then nCount += 1
						)
					)
					
					else if classof parent == vraymtlwrapper and parent.generateGI == true then
					(
						nCount += 1
					)
				)
				
				nCount
			),
			
			fn clean =
			(
				-- lights need to be in wrappers
				local lLightMtlTvps = getclassinstances VRayLightMtl astrackviewpick:true
				for lightMtlTvp in lLightMtlTvps do
				(
					local lightMtl = lightMtlTvp.anim
					local parent = lightMtlTvp.client
					local wrapperMtl = vraymtlwrapper generateGI:false basemtl:lightMtl
					
					if (classof (superclassof parent)) == node then
					(
						parent.mat = wrapperMtl
					)
					
					else if classof parent == multimaterial then
					(
						for nMat = 1 to parent.MaterialList.count do
						(
							if parent.MaterialList[nMat] == lightMtl then parent.MaterialList[nMat] = wrapperMtl
						)
					)
					
					else if classof parent == vraymtlwrapper then
					(
						parent.generateGI = false
					)
				)
			)
			
		);)(),
		
		(struct s( tName = "VrayMtl ClampTex Disabled",
			
			tTooltip = "Can kill renderings. Light calculation takes forever.",
			
			fn autocount =
			(
				local nCount = 0
				
				for mtl in getclassinstances vraymtl where mtl.option_clampTextures != true do nCount += 1
				
				nCount
			),
			
			fn clean =
			(
				for mtl in getclassinstances vraymtl where mtl.option_clampTextures != true do mtl.option_clampTextures = true
			)
			
		);)(),
		
		(struct s( tName = "VrayMtl Refl/Refr SubDivs > 16",
			
			tTooltip = "Too high subdivs in vray materials can slow down your rendering.",
			
			fn autocount =
			(
				local nCount = 0
				
				local nMaxSubdivs = 16
				
				for mat in (getclassinstances VrayMtl)
					where mat.reflection_subdivs > nMaxSubdivs or mat.refraction_subdivs > nMaxSubdivs
					do nCount += 1
				
				nCount
			),
			
			fn clean =
			(
				local nMaxSubdivs = 16
				
				for mat in (getclassinstances VrayMtl) do
				(
					if mat.reflection_subdivs > nMaxSubdivs then mat.reflection_subdivs = nMaxSubdivs
					if mat.refraction_subdivs > nMaxSubdivs then mat.refraction_subdivs = nMaxSubdivs
				)
			)
			
		);)(),
		
		(struct s( tName = "VrayMtl Refl/Refr SubDivs > 24",
			
			tTooltip = "Too high subdivs in vray materials can slow down your rendering.",
			
			fn autocount =
			(
				local nCount = 0
				
				local nMaxSubdivs = 24
				
				for mat in (getclassinstances VrayMtl)
					where mat.reflection_subdivs > nMaxSubdivs or mat.refraction_subdivs > nMaxSubdivs
					do nCount += 1
				
				nCount
			),
			
			fn clean =
			(
				local nMaxSubdivs = 24
				
				for mat in (getclassinstances VrayMtl) do
				(
					if mat.reflection_subdivs > nMaxSubdivs then mat.reflection_subdivs = nMaxSubdivs
					if mat.refraction_subdivs > nMaxSubdivs then mat.refraction_subdivs = nMaxSubdivs
				)
			)
			
		);)(),
			

		(struct s( tName = "VrayMtl Refl/Refr SubDivs > 32",
			
			tTooltip = "Too high subdivs in vray materials can slow down your rendering.",
			
			fn autocount =
			(
				local nCount = 0
				
				local nMaxSubdivs = 32
				
				for mat in (getclassinstances VrayMtl)
					where mat.reflection_subdivs > nMaxSubdivs or mat.refraction_subdivs > nMaxSubdivs
					do nCount += 1
				
				nCount
			),
			
			fn clean =
			(
				local nMaxSubdivs = 32
				
				for mat in (getclassinstances VrayMtl) do
				(
					if mat.reflection_subdivs > nMaxSubdivs then mat.reflection_subdivs = nMaxSubdivs
					if mat.refraction_subdivs > nMaxSubdivs then mat.refraction_subdivs = nMaxSubdivs
				)
			)
			
		);)(),
			

		(struct s( tName = "VrayMtl Refl/Refr SubDivs > 48",
			
			tTooltip = "Too high subdivs in vray materials can slow down your rendering.",
			
			fn autocount =
			(
				local nCount = 0
				
				local nMaxSubdivs = 48
				
				for mat in (getclassinstances VrayMtl)
					where mat.reflection_subdivs > nMaxSubdivs or mat.refraction_subdivs > nMaxSubdivs
					do nCount += 1
				
				nCount
			),

			fn clean =
			(
				local nMaxSubdivs = 48
				
				for mat in (getclassinstances VrayMtl) do
				(
					if mat.reflection_subdivs > nMaxSubdivs then mat.reflection_subdivs = nMaxSubdivs
					if mat.refraction_subdivs > nMaxSubdivs then mat.refraction_subdivs = nMaxSubdivs
				)
			)
			
		);)(),
			
			-- by Simon
		(struct s( tName = "Texture Filtering",
			
			tTooltip = "Filtering will be set to Pyramidal for all bitmaps and to None if the bitmap belongs to a leaf or model+model book",
			
			fn autocount =
			(
				local nCount = 0
				
				for curr_map in (getclassinstances bitmaptexture) do
				(
					if
						curr_map.filename != undefined and
						curr_map.filtering != 2 and
						(
							matchpattern (getfilenamefile curr_map.filename) pattern:"*leaf*" or
							matchpattern (curr_map.filename) pattern:"*model+model*maps_high*" or
							matchpattern (getfilenamefile curr_map.filename) pattern:"*flower*"
						)
					then nCount += 1
					else if(curr_map.filtering == 1) then
						nCount += 1
				)
				
				nCount
			),
			
			fn clean =
			(
				for curr_map in (getclassinstances bitmaptexture) do
				(
					-- auto-detect plants
					if
						curr_map.filename != undefined and
						(
							matchpattern (getfilenamefile curr_map.filename) pattern:"*leaf*" or
							matchpattern (curr_map.filename) pattern:"*model+model*maps_high*" or
							matchpattern (getfilenamefile curr_map.filename) pattern:"*flower*"
						)
					then curr_map.filtering = 2
					else curr_map.filtering = 0
				)
			)
			
		);)()
			-- /by Simon
		
	)
	
	function getTooltip task =
	(
		local t = task.tTooltip
		
		t = substituteString t "\\" ""
		t = substituteString t "\t" ""
		t = substituteString t "\n" ""
	)
	
	local tCode = ""
	tCode += "global cCleanerRollout = rollout cCleanerRollout \"Cleaner by Andreas Meissner\" ("
	tCode += "label cLabCount \"Count:\" width:160 height:24 pos:[200,7];"
	tCode += "label cLabSelect \"Select from Scene:\" width:160 height:24 pos:[265,7];"
		
		-- vertical control position
		local nPosY = 5
		
		-- add tasks
		for nTask = 1 to lTasks_4648134686.count do
		(
			local task = lTasks_4648134686[nTask]
			local tTask = nTask as string
			
			if not (vray == undefined and matchpattern task.tName pattern:"*vray*") then
			(
				-- groups
				if matchpattern task.tName pattern:"--*--*" then
				(
					local tGroup = (filterstring task.tName "--")[1]
					task.tName = (filterstring task.tName "--")[2]
					
					tCode += "label cLab_group"+ nPosY as string +" \""+ tGroup +":\" width:100 height:24 pos:[10,"+ (nPosY+2) as string +"];"
					nPosY += 24
				)
				
				-- clean
				tCode += "button cBut_clean"+ tTask +" \""+ task.tName +"\" tooltip:\""+ getTooltip task +"\" width:160 height:24 pos:[5,"+ nPosY as string +"];"
				tCode += "on cBut_clean"+ tTask +" pressed do ("
				tCode += "lTasks_4648134686["+ tTask +"].clean();"
				tCode += "cCleanerRollout.cLab"+ tTask +".text = lTasks_4648134686["+ tTask +"].autocount() as string;"
				tCode += ");"
				
				if try (task.usercount; true) catch false then
				(
					-- usercount
					tCode += "button cBut_count"+ tTask +" \"count\" tooltip:\"This tasks takes longer to count, so you have to start the count manually.\" width:50 height:24 pos:[189,"+ nPosY as string +"];"
					tCode += "on cBut_count"+ tTask +" pressed do ("
					tCode += "cCleanerRollout.cBut_count"+ tTask +".text = lTasks_4648134686["+ tTask +"].usercount() as string;"
					tCode += ");"
				)
				else
				(
					-- autocount
					tCode += "label cLab"+ tTask +" \"counting..\" pos:[190,"+ (nPosY+5) as string +"];"
				)
				
				-- objects
				if try (task.selectObjects; true) catch false then
				(
					tCode += "button cBut_objects"+ tTask +" \"objects\" tooltip:\"select objects (opens groups)\" width:50 height:24 pos:[260,"+ nPosY as string +"];"
					tCode += "on cBut_objects"+ tTask +" pressed do lTasks_4648134686["+ tTask +"].selectObjects();"
				)
				
				-- materials
				if try (task.selectMaterials; true) catch false then
				(
					tCode += "button cBut_materials"+ tTask +" \"materials\" tooltip:\"select materials (in materialeditor)\" width:50 height:24 pos:[315,"+ nPosY as string +"];"
					tCode += "on cBut_materials"+ tTask +" pressed do lTasks_4648134686["+ tTask +"].selectMaterials();"
				)
				
				nPosY += 28
			)
		)
		
		-- on rollout open
		tCode += "on cCleanerRollout open do ("
		for nTask = 1 to lTasks_4648134686.count do
		(
			if not (vray == undefined and matchpattern lTasks_4648134686[nTask].tName pattern:"*vray*") then
			(
				if try (lTasks_4648134686[nTask].usercount; false) catch true then
				(
					local tTask = nTask as string
					tCode += "cLab"+ tTask +".text = lTasks_4648134686["+ tTask +"].autocount() as string;"
				)
			)
		)
		tCode += ");"
		
	tCode += ")"
	local cCleanerRollout = execute tCode
	createDialog cCleanerRollout 370 (nPosY+2)
	)