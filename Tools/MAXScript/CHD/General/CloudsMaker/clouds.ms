/*
  Bug report,
	xiaobin.huang@gameloft.com
*/


CloudMaker_FullOptions = true

-- common functions

struct Aabb
(
	minEdge, maxEdge,
	
	function correctMinMax A B = 
	(
		if classOf A == point3 and classOf B == point3 then
		(
			local t
			if B.x < A.x then
			(
				t = A.x
				A.x = B.x
				B.x = t
			)
			if B.y < A.y then
			(
				t = A.y
				A.y = B.y
				B.y = t
			)
			if B.z < A.z then
			(
				t = A.z
				A.z = B.z
				B.z = t
			)
			#(A, B)
		)
	),
	
	
	function getCenter =
	(
		(minEdge+maxEdge)*0.5
	),

	function getExtends = 
	(
		(maxEdge-minEdge)*0.5
	),
	
	function repair = 
	(
		correctMinMax this.minEdge this.maxEdge
		this
	),
	
	function addPoint p =
	(
		if classOf p == point3 then
		(
			if this.minEdge == undefined then this.minEdge = copy p
			if this.maxEdge == undefined then this.maxEdge = copy p
			correctMinMax this.minEdge (copy p)
			correctMinMax (copy p) this.maxEdge
			this
		)
	),
	
	function addAabb b =
	(
		if classOf b == classOf this then
		(
			this.addPoint b.minEdge
			this.addPoint b.maxEdge
		)
		this
	),
	
	on create do
	(
		this.repair()
	)
)

struct Utils
(

	function getAabbFrom obj = 
	(
		local b = copy obj
		local bbox = Aabb()
		try (
			convertToPoly b
			local vertCount = polyOp.getNumVerts b
			local bbox = Aabb()
			for i = 1 to vertCount do 
			(
				bbox.addPoint (polyOp.getVert b i)
			)
		) 
		catch 
		(
			messageBox "Cannot get Aabb from "+obj.name
			return undefined
		)
		delete b
		bbox
	),
	
	function fnUpdateGlitchParams_CloudsMaker mtl rlCM = 
	(
		
	)
	
)



rollout CloudsMaker "Clouds Maker v 0.11" width: 200
(
	local textureWidth, textureHeight, numOfAtlasedTextures
	local assignedArray
	local sizeChannel
	local atlasChannel
	local lightChannel
	
	group "Parameter - Material"
	(
		materialbutton btnMtl "Use Material" align:#left
		spinner spSubMtlId "Sub Mtl ID" type:#integer range:[1, 20, 1] enabled:false align:#left
		checkbox ckAtlasedTexture "Use Atlased Texture" checked:true enabled:CloudMaker_FullOptions
		mapbutton mbPickTexture "Pick Altased Texture" align:#left enabled:true
		checkbox ckAlsoSetTextureInMtl "Also replace texture in mtl" enabled:true checked:false
		edittext etTexSize "Texture Size" readonly:true enabled:true
		spinner spHorizGrid "Horiz Grid Size" type:#integer range:[1, 128, 4] enabled:true
		spinner spVertGrid "Vert Grid Size" type:#integer range:[1, 128, 4] enabled:true
		checkbox ckRandomAtlas "Random Select Textures in Altas" checked:true enabled:false
		button btnReassign "Reassign Textures" enabled:false
	)
	
	group "Parameter - Fog"
	(
		-- disable by now, can be tweaked in material
		checkbox ckFogEnable "Enable" checked:true enabled:false
		spinner spFogStart "Fog Start" range:[0, 10000, 0] enabled:false
		spinner spFogEnd "Fog End" range:[0, 10000, 500] enabled:false
		spinner spFogMaxDensity "Fog Max Density" range:[0, 1, 0.5] enabled:false
	)	
	
	group "Parameter - Lighting"
	(
		checkbox ckLightingSim "Enable Lighting Simulation" checked:true enabled:CloudMaker_FullOptions
		button btnResetCenter "Reset Group Center" enabled:true
		spinner spGroupCenterCh "Channel" type:#integer range:[2, 4, 4] enabled:CloudMaker_FullOptions
	)
	
	group "Parameter - Size"
	(
		checkbox ckSizeVariable "Size Store to Map Channel" checked:true enabled:CloudMaker_FullOptions
		checkbox ckTweakingSize "Tweaking" enabled:true
		spinner spResizeFactor "Resize Factor" type:#float range:[0.1, 10.0, 0.5] enabled:false
		slider slWidth "Width" range:[0, 10, 5] enabled:false
		slider slHeight "Height" range:[0, 10, 5] enabled:false
	)
	
	
	group "Create"
	(
		edittext etPrefix "Prefix" text:"CLOUD_"
		button btnCreate "Convert To Clouds"
	)
	
	on ckLightingSim changed val do
	(
		btnResetCenter.enabled = val
		spGroupCenterCh.enabled = val
	)
	
	on btnResetCenter pressed do
	(
		local sel = $
		if classOf sel != dummy then return undefined
		if undefined == findString sel.name ("dummy_"+etPrefix.text) then return undefined
		if sel.children.count != 1 then return undefined
		local cloudMesh = sel.children[1]
		if classOf cloudMesh != Editable_mesh then return undefined
			
		local support = meshOp.getMapSupport cloudMesh spGroupCenterCh.value
		if not support then
		(
			messageBox "Channel " + (spGroupCenterCh.value as string) + " has no infomation!"
			return false
		)
		
		undo "Reset Group Center" on
		(
			local bbox = Utils.getAabbFrom cloudMesh
			local c = bbox.getCenter() - sel.pivot
			local ch = spGroupCenterCh.value
			
			meshOp.setMapVert cloudMesh ch 1 c
			meshOp.setMapVert cloudMesh ch 2 c
			meshOp.setMapVert cloudMesh ch 3 c
			meshOp.setMapVert cloudMesh ch 4 c
			
		)		
	)
	
	on ckRandomAtlas changed val do
	(
		btnReassign.enabled = not val
	)
	
	function fnCheckAtlasChannel = 
	(
		local sel = $
		if classOf sel != dummy then return undefined
		if undefined == findString sel.name ("dummy_"+etPrefix.text) then return undefined
		if sel.children.count != 1 then return undefined
		local cloudMesh = sel.children[1]
		if classOf cloudMesh != Editable_mesh then return undefined
		local val = (meshop.getNumMaps cloudMesh) - 2
		if val == 0 then 
		(
			atlasChannel = undefined
			return undefined
		)
		if val == 1 then
		(
			local cnt = meshOp.getNumMapVerts cloudMesh 2
			for i = 1 to cnt do 
			(
				local v = meshOp.getMapVert cloudMesh 2 i
				if v.x > 1.0 or v.y > 1.0 then 
				(
					atlasChannel = undefined
					return undefined
				)
			)
		)
		if val >= 2 then
		(
			-- there must be atlas channel
			atlasChannel = 2
			return cloudMesh
		)
		undefined
	)
	
	on btnReassign pressed do
	(
		-- TODO
		/*
		local cloudMesh = fnCheckAtlasChannel()
		if cloudMesh != undefined then
		(
			
		)
		*/
		
	)
	
	on btnMtl picked mtl do
	(
		if classOf mtl == MultiSubMaterial then
		(
			spSubMtlId.range = [1, (getNumSubMtls mtl), 1]
			spSubMtlId.enabled = true
		)
		else
		(
			spSubMtlId.enabled = false
		)
		btnMtl.text = mtl.name
	)

	
	on ckSizeVariable changed val do
	(
		ckTweakingSize.enabled = val
	)
	
	on ckTweakingSize changed val do
	(
		spResizeFactor.enabled = val
		slWidth.enabled = val
		slHeight.enabled = val
	)
	
	on ckAtlasedTexture changed val do
	(
		mbPickTexture.enabled = val
		ckAlsoSetTextureInMtl.enabled = val
		etTexSize.enabled = val
		spVertGrid.enabled = val
		spHorizGrid.enabled = val
		ckRandomAtlas.enabled = false -- TODO
	)
	
	on spHorizGrid changed val do
	(
		if textureWidth != undefined and textureHeight != undefined then
		(
			numOfAtlasedTextures = spHorizGrid.value*spVertGrid.value
			etTexSize.text = (textureWidth as string) + "x" + (textureHeight as string) + ", " + (spHorizGrid.value as string) + "x" + (spVertGrid.value as string)
		)
	)
	
	on spVertGrid changed val do
	(
		if textureWidth != undefined and textureHeight != undefined then
		(
			numOfAtlasedTextures = spHorizGrid.value*spVertGrid.value
			etTexSize.text = (textureWidth as string) + "x" + (textureHeight as string) + ", " + (spHorizGrid.value as string) + "x" + (spVertGrid.value as string)
		)
	)
	
	on mbPickTexture picked map do
	(
		ckAlsoSetTextureInMtl.checked = false
		if classOf map != bitmaptexture do
		(
			messageBox "Bitmap requried"
			return false
		)
		if map != undefined then
		(
			local tks = filterString map.bitmap.filename "\\"
			mbPickTexture.text = tks[tks.count]
			textureWidth = map.bitmap.width
			textureHeight = map.bitmap.height
			etTexSize.text = (textureWidth as string) + "x" + (textureHeight as string) + ", " + (spHorizGrid.value as string) + "x" + (spVertGrid.value as string)
			numOfAtlasedTextures = spHorizGrid.value*spVertGrid.value
		)
	)
	
	function fnCheckSizeChannel = 
	(
		local sel = $
		if classOf sel != dummy then return undefined
		if undefined == findString sel.name ("dummy_"+etPrefix.text) then return undefined
		if sel.children.count != 1 then return undefined
		local cloudMesh = sel.children[1]
		if classOf cloudMesh != Editable_mesh then return undefined
		local val = (meshop.getNumMaps cloudMesh) - 2
		if val == 0 then 
		(
			sizeChannel = undefined
			return undefined
		)
		if val == 1 then
		(
			local cnt = meshOp.getNumMapVerts cloudMesh 2
			for i = 1 to cnt do 
			(
				local v = meshOp.getMapVert cloudMesh 2 i
				if v.x > 1.0 or v.y > 1.0 then 
				(
					sizeChannel = 2
					return cloudMesh
				)
			)
		)
		if val == 2 then
		(
			local cnt = meshOp.getNumMapVerts cloudMesh 3
			for i = 1 to cnt do 
			(
				local v = meshOp.getMapVert cloudMesh 3 i
				if v.x > 1.0 or v.y > 1.0 then 
				(
					sizeChannel = 3
					return cloudMesh
				)
			)			
		)
		if val == 3 then
		(
			-- we must have sizeChannel at slot 3
			sizeChannel = 3
			return cloudMesh
		)
		undefined
	)
	
	function fnChangeSize xstep ystep factor = 
	(
		if not ckTweakingSize.checked then return false
		local cloudMesh = fnCheckSizeChannel()
		if cloudMesh != undefined and sizeChannel != undefined then
		(
			local cnt = meshOp.getNumMapVerts cloudMesh sizeChannel
			for i = 1 to cnt do 
			(
				local v = meshOp.getMapVert cloudMesh sizeChannel i
				v.x += xstep*factor
				v.y += ystep*factor
				meshOp.setMapVert cloudMesh sizeChannel i v
			)
		)
	)
	
	on slWidth changed val do 
	(
		fnChangeSize (val-5) 0 spResizeFactor.value
	)
	on slWidth buttonup do 
	(
		slWidth.value = 5
	)
	
	on slHeight changed val do 
	(
		fnChangeSize 0 (val-5) spResizeFactor.value
	)
	on slHeight buttonup do 
	(
		slHeight.value = 5
	)
	

	
	function fnAssignTextures assigned = 
	(
		assignedArray = assigned
	)
	
	function fnCheckAndSet mtl what val = 
	(
		if hasProperty mtl what then
		(
			setProperty mtl what val
			return true
		)
		return false
	)
	
	function fnCheckMaterial cloudMesh = 
	(
		local mtl = cloudMesh.material
		if mtl == undefined then return false
		print "Check materila..."
		local subId = 0
		if spSubMtlId.enabled then
		(
			subId = spSubMtlId.value
		)
		if subId != 0 then
		(
			mtl = getSubMtl mtl subId
		)
		if classOf mtl == DxMaterial then
		(
			fnCheckAndSet mtl #SizeGetFromChannel (sizeChannel-1)
			fnCheckAndSet mtl #UseAtlasedTexture ckAtlasedTexture.checked
			fnCheckAndSet mtl #FogEnable ckFogEnable.checked
			fnCheckAndSet mtl #FogStart spFogStart.value
			fnCheckAndSet mtl #FogEnd spFogEnd.value
			fnCheckAndSet mtl #FogMaxDensity spFogMaxDensity.value
			if ckAlsoSetTextureInMtl.checked then 
			(
				fnCheckAndSet mtl #texture0 mbPickTexture.map.bitmap
			)
			fnCheckAndSet mtl #LightSimEnable ckLightingSim.checked
			if ckLightingSim.checked then
			(
				fnCheckAndSet mtl #GroupCenterGetFromChannel (lightChannel-1)
			)
		)
		else
		(
			if classOf mtl == Glitch_Effect or classOf mtl == Glitch_Effect_Inst then
			(
				Utils.fnUpdateGlitchParams_CloudsMaker mtl this
			)
		)
		
	)

	
	on btnCreate pressed do 
	(
		-- checks
		local selected = selection as array
		if selected.count == 0 then
		(
			messageBox "Nothing selected!"
			return false
		)
		

		if ckAtlasedTexture.checked then
		(
			if mbPickTexture.map == undefined then
			(
				messageBox "Altased selected but no texture selected."
				return false
			)
			
			if assignedArray == undefined then
			(
				if not ckRandomAtlas.checked then -- let user spec values
				(
					local rc = rolloutCreator "rlTextures" "Textures"
					rc.begin()
					local code = ""
					for obj in selected do
					(
						rc.addControl #spinner (("sp"+obj.name) as name) obj.name paramStr:("type:#integer range:[1,"+(numOfAtlasedTextures as string)+",1]")
						code = code + "append assigned sp"+obj.name+".value\n"
					)
					rc.addLocal "assigned" init:#()
					rc.addControl #button #btnAssign "Assign Textures"					
					code = code + "CloudsMaker.fnAssignTextures assigned"
					rc.addHandler #btnAssign #pressed codeStr:"code" -- callback to CloudsMaker
					createDialog (rc.end())
					return false
				)
				else
				(
					assignedArray = #()
					for obj in selected do
					(
						append assignedArray (random 1 numOfAtlasedTextures)
					)
				)
			)
		)

		
		

		-- generate billboard vertices
		local wholeAabb = Aabb()
		local boxPieces = #()
		local ignoreObjCount = 0
		for obj in selected do
		(
			local bbox = Utils.getAabbFrom obj
			append boxPieces bbox
			wholeAabb.addAabb bbox
		)
		
		local cloudMesh = undefined
		
		
		local numMaps = 2 -- initial is vc and map 1
		if ckAtlasedTexture.checked then numMaps = numMaps + 1
		if ckSizeVariable.checked then numMaps = numMaps + 1
		if ckLightingSim.checked then numMaps = numMaps + 1
		
		print assignedArray
		local cnt = 1
		for p in boxPieces do
		(
			local c = p.getCenter()
			local mtlId = 1
			if spSubMtlId.enabled then
			(
				mtlId = spSubMtlId.value
			)
			local createdOne = mesh vertices:#(c, c, c, c) faces:#([1, 2, 3], [3, 2, 4]) materialIDS:#(mtlId,mtlId)
			

			meshop.setNumMaps createdOne numMaps
			
			
			/*
				1    3
				
				2    4
			*/
						
			-- for generate billboard (also the texture coord)
			meshop.setMapSupport createdOne 1 true
			meshOp.setMapVert createdOne 1 1 [0, 1, 0]
			meshOp.setMapVert createdOne 1 2 [0, 0, 0]
			meshOp.setMapVert createdOne 1 3 [1, 1, 0]
			meshOp.setMapVert createdOne 1 4 [1, 0, 0]
			
			
			local ch2Taken = false
			-- use atlased cloud texture
			if ckAtlasedTexture.checked then
			(
				ch2Taken = true
				
				meshop.setMapSupport createdOne 2 true
				
				
				local wh = assignedArray[cnt] as integer
				local gx = mod wh spHorizGrid.value
				wh = wh - 1
				local gy = wh/spHorizGrid.value
				local txStep = (textureWidth as float)/(spHorizGrid.value as float)
				local tyStep = (textureHeight as float)/(spVertGrid.value as float)
				local tLU = [(gx*txStep)/textureWidth, (gy*tyStep)/textureHeight, 0]
				local tRU = [((gx+1)*txStep)/textureWidth, (gy*tyStep)/textureHeight, 0]
				local tLB = [(gx*txStep)/textureWidth, ((gy+1)*tyStep)/textureHeight, 0]
				local tRB = [((gx+1)*txStep)/textureWidth, ((gy+1)*tyStep)/textureHeight, 0]

		
				-- the origion is placed at left upper corner
				meshOp.setMapVert createdOne 2 1 tLB
				meshOp.setMapVert createdOne 2 2 tLU
				meshOp.setMapVert createdOne 2 3 tRB
				meshOp.setMapVert createdOne 2 4 tRU
			)
			
			
			-- initial size
			local ch3Taken = false
			if ckSizeVariable.checked then
			(
				local ch = 2
				if ch2Taken then ch = 3
				if ch == 3 then ch3Taken = true
				sizeChannel = ch
				meshop.setMapSupport createdOne ch true
				
				local extends = p.getExtends()
				local h = extends.z
				local w = extends.x
				if w < extends.y then w = extends.y
				local s = [w, h, 0]
				s = s*4
				meshOp.setMapVert createdOne ch 1 s
				meshOp.setMapVert createdOne ch 2 s
				meshOp.setMapVert createdOne ch 3 s
				meshOp.setMapVert createdOne ch 4 s
				
			)
			
			-- lighting sim
			if ckLightingSim.checked then
			(
				local ch = 2
				if ch2Taken then ch = 3
				if ch3Taken then ch = 4
				lightChannel = ch
				meshop.setMapSupport createdOne ch true
				local c = wholeAabb.getCenter()
				meshOp.setMapVert createdOne ch 1 c
				meshOp.setMapVert createdOne ch 2 c
				meshOp.setMapVert createdOne ch 3 c
				meshOp.setMapVert createdOne ch 4 c
			)
			
			
			
			
			if cloudMesh == undefined then cloudMesh = createdOne
			else meshOp.attach cloudMesh createdOne
			
			cnt = cnt + 1
		)
		
		
		
		
		cloudMesh.name = uniqueName etPrefix.text
		local extends = wholeAabb.getExtends()
		
		cloudMesh.pivot = wholeAabb.getCenter()
		cloudMesh.pivot.z -= extends.z
		
		
		local cloudDummy = dummy boxsize:[extends.x*2, extends.y*2, extends.z*2]
		cloudDummy.position = wholeAabb.getCenter()
		cloudDummy.pivot.z -= extends.z
		cloudDummy.name = uniqueName ("dummy_"+etPrefix.text)
		
		cloudMesh.parent = cloudDummy
		cloudMesh.pos.controller = Position_Constraint()
		cloudMesh.pos.controller.appendTarget cloudDummy 100
		cloudMesh.rotation.controller = Orientation_Constraint()
		cloudMesh.rotation.controller.appendTarget cloudDummy 100
		cloudMesh.scale.controller = SlaveScale ()
		
		if btnMtl.material != undefined then
		(
			cloudMesh.material = btnMtl.material
		)
		
		fnCheckMaterial cloudMesh
		
		-- clean up
		
		assignedArray = undefined 
		
		
		-- select target
		
		select cloudDummy
		
	)
)
try (destroyDialog CloudsMaker) catch ()
gc()
CreateDialog CloudsMaker



