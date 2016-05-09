(
	global SpriteGen
	try (destroyDialog SpriteGen) catch ()

	GC()
	fn rePopulate AssetList  = 
	(
		--why would they have the same name...
		
		if (assetList.count > 0 ) then 
		(
			local ReplacedNodes = #()
			Local SceneObjects = objects as array
			
			for i = 1 to AssetList.count do 
			(
				for obj in SceneObjects do 
				(
					if (obj.name == AssetList[i].name) and (obj != AssetList[i]) then 
					(
						
						NewSprite = copy Assetlist[i]
						NewSprite.name = Assetlist[i].name
						NewSprite.transform = obj.transform
						append ReplacedNodes obj
						
					)
				)
			)
			if (ReplacedNodes.count > 0 ) then (delete AssetList)
			delete ReplacedNodes
			
		)
	
	)--fn end
	
	fn CreateUI 
	
	fn CreateSprites SpriteList AtlasDimensions AtlasFile  = 
	(
		Local CreatedSprites = #()
		for i = 1 to SpriteList.count do 
		(
		/*
			#(#("DS_Layer_Blue_Card", "png"), #("539", "2", "535", "830"), "false")
			#(#("DS_Layer_Bronze_Card", "png"), #("2", "2", "535", "830"), "false")
		*/
			
			SpriteName = SpriteList[i][1][1]
			SpriteDimensions = #((SpriteList[i][2][3] as integer), (SpriteList[i][2][4] as integer))
						--Image size relation within atlas
			ScaleV = 1.0 / (AtlasDimensions[2] / (SpriteList[i][2][4] as integer))
			ScaleU = 1.0 / (AtlasDimensions[1] /(SpriteList[i][2][3] as integer)) 
			ImagePosU = SpriteList[i][2][1] as Float
			ImagePosV = SpriteList[i][2][2] as Float
			SpriteAtlasPosU =1 - (ImagePosU / (atlasDimensions[1]))
			SpriteAtlasPosV =  (ImagePosV / (atlasDimensions[2])) 
			
			SpriteRotation = SpriteList[i][3] as BooleanClass
			
			--BELOW: Creates the UI for each sprite
	Fn CreateButtons Atlaspath = 
	(
			
	previewMap = bitmap 535 830  color:white
	Bmap= openbitmap Atlaspath 
	--box2  atlasX AtlasY imageX ImageY   [destXorginOffset, destYorginOffset]
	pasteBitMap  Bmap previewMap (box2 2 2 535 830) [0, 0]
	display previewMap
	
	--create working Copies  of images for UI Icons
	pName = (getdir #temp) + "\\" + filename + ".png" 
	previewMap.filename = pName
	if (doesFileExist pName) then (deletefile pName) --removes old files in case of image changes
	save previewMap quiet: true
	IconImage = bitmap 50 50 color: gray 
	Imap = openBitmap (pName as string)
	copy Imap IconImage 
	display IconImage
	)
			
			theBmp = bitmap width_btn Height_btn Color: white
				
			previewMap = bitmap 50 50  color:white
			mapPath = "C:\Users\karl.kent\Documents\IMG_01082012_135712.png"
			Bmap= openbitmap mapPath 
			copy bMap previewMap
			display previewMap
				
				/*
				
			--BELOW: Creates Polygons for each sprite
				
			Sprite = plane length: SpriteDimensions[1] width: SpriteDimensions[2] lengthsegs: 1 widthsegs: 1
			Sprite.name = SpriteName
			
			--Uv mod settings
			UvMod = UVW_Xform ()
			UVMod.Map_Channel = SpriteGen.mapChan_btn.value
			uVMod.U_Tile = ScaleU -- UV Coord scale
			uvMod.V_Tile = ScaleV -- UV Coord scale
			uVMod.U_Offset = SpriteAtlasPosU  -- UV Coord U
			uvMod.V_Offset = SpriteAtlasPosV -- UV Coord W
			uVMod.U_Tile = ScaleU -- UV Coord scale
			uvMod.V_Tile = ScaleV -- UV Coord scale 
			addmodifier Sprite UvMod
			
			
			-- UV rotation
			if (SpriteRotation == false) then 
			(
				--UvMod.Rotation_Center =  1
				UvMod.Rotation_Angle =  90
			)
			PivotTo_btn  = 	false
			if (SpriteGen.Pivot_rdo.state == 1) then (PivotTo_btn = true)	else	(PivotTo_btn =  false)
			
			If PivotTo_btn then 
			(
				Sprite.Pivot  = [(((sprite.min.x) + (sprite.max.x))*0.5), sprite.min.y , 0]
			)
			else
			(
				centerPivot Sprite
			)
			append CreatedSprites Sprite
		)
			UvXMod = UVW_Xform ()
			--UvXMod.Map_Channel = SpriteGen.mapChan_btn.value
			UvXMod.U_Flip = 1
			UvXMod.V_Flip = 1
			addmodifier CreatedSprites  UvXMod
			CollapseStack CreatedSprites
			converttopoly CreatedSprites
				
			if (CreatedSprites.count > 0) then 
			(
				if (doesFileExist AtlasFile) then 
				(
					
					bmap =  openbitmap atlasFile 
					 HasAlpha = bmap.hasAlpha
					close bmap
					
					assigned = false 
					"assigning material"
					--Check if map is alrady used
					for i = 1 to meditmaterials.count do 
					(
						if ((classof meditmaterials[i]) == standardmaterial ) then 
						(
							if (meditmaterials[i].diffusemap != undefined)  then 
							(
								if (meditmaterials[i].diffusemap.filename == atlasfile ) then 
								(
									meditmaterials[i].name = getfilenamefile atlasFile 
									meditMaterials[i].diffuseMap = Bitmaptexture fileName:AtlasFile
									if hasAlpha then 
									(
									meditMaterials[i].OpacityMap = Bitmaptexture fileName:AtlasFile monoOutput: 1 alphasource: 0
									meditMaterials[i].opacityMapAmount  = 100
									)
									meditMaterials[i].showInViewport = true
									CreatedSprites.material = meditmaterials[i]
									assigned = true
									"assigned"
								)
							)
						)
					)
					
					-- if not used Create a new material and place it in first available slot in material editor
					if Not assigned then 
						(
						for i = 1 to meditmaterials.count do 
						(
							if Not assigned then 
							( 
					
								if  ((classof meditmaterials[i] ) == standardmaterial )then 
								(
									if (meditmaterials[i].diffusemap == undefined) and (meditmaterials[i].opacityMap == undefined) then 
									(
									meditmaterials[i].name = getfilenamefile atlasFile 
									meditMaterials[i].diffuseMap = Bitmaptexture fileName:AtlasFile 
									if HasAlpha then 
									(
										
									meditMaterials[i].OpacityMap = Bitmaptexture fileName:AtlasFile monoOutput: 1 alphasource: 0
									meditMaterials[i].opacityMapAmount  = 100
									)
									
										
									meditMaterials[i].showInViewport = true
									CreatedSprites.material = meditmaterials[i]
									assigned = true
									"assigned"
									)
								)
							)
						)
					)
					--if no slots available in material Editor then place in last slot
					if Not assigned then 
					(
						meditmaterials[24].name = getfilenamefile atlasFile 
						meditMaterials[24].diffuseMap = Bitmaptexture fileName:AtlasFile
						meditMaterials[24].OpacityMap = Bitmaptexture fileName:AtlasFile monoOutput: 1 alphasource: 0
						meditMaterials[i].showInViewport = true
						CreatedSprites.material = meditmaterials[24]
					)
				)
				*/
			)
			if SpriteGen.DeleteOld_chk.checked then 
			(
				"Replacing Sprites"
			--	rePopulate CreatedSprites  
				"Sprites Replaced"
			)
	) --fn end

	fn ParseFile filePath =
	(
		if (doesfileexist filepath) then 
		(
		Local SpriteCollection = #()
		local AtlasSize = #()
		Local AtlasImage   =#()
		"parsing file"
		File = openfile filepath mode: "r"
		while not eof file do 
		(
			fileString = readline file
			if ((findstring fileString "png") != undefined) or ((findstring fileString "tga") != undefined) then 
			(
				if ((findstring fileString "image") == undefined) then 
				(
					local spriteInfo = #()
					
					texturetokens = filterString fileString ",  : \" . \t "
					
					TextureName = ""
					for i = 1 to TextureTokens.count-1 do 
					(
						TextureName += TextureTokens[i]
					)
					append spriteInfo #(TextureName, texturetokens[texturetokens.count])
					skipToNextLine file
					dimensionLine = readline file
					-- atlas width pos / atlas Height pos / orginal image width /  orginal image hieght
					dimensionTokens = filterString  dimensionLine " \" : { } , \t framexywh"
					append spriteInfo dimensionTokens
					rotatedLine = readLine file
					rotatedTokens = FilterString rotatedLine "\t \" : ,  "
					isRotated  = rotatedTokens[2] --as booleanClass 
					append spriteInfo isRotated
					append SpriteCollection spriteInfo
				)
			)
			
			if ((findstring fileString "size") != undefined) then 
			(
				if ((findstring fileString "spriteSourceSize") == undefined) and ((findstring fileString "sourceSize") == undefined) then 
				(
				SizeTokens = FilterString fileString "\t \" : , {} sizewh "
				
					for r = 1 to sizeTokens.count do 
					(
					append AtlasSize (SizeTokens[r] as Float)
					)
				)
			)
			
			if ((findstring fileString "image") != undefined) then 
			(
				Atlastokens = filterString fileString ",  : \"  \t "
				
				AtlasName = getFilenamePath  filepath
				for i = 2 to Atlastokens.count do 
				(
					AtlasName += Atlastokens[i]
				)
				append AtlasImage AtlasName
			)
		)
		close file
		"File Parsed"
		CreateSprites SpriteCollection AtlasSize AtlasName 
		)
	) --fn end

	rollout SpriteGen "Generate Sprites"
	(
		group "File" (
		button browse_btn "Browse" align: #left across: 2
		edittext edit_txt text: "" align: #left Offset: [-24,2] fieldWidth:100 tooltip: "Meh")
		group "Update Scene Assets"(
		checkbox DeleteOld_chk "Replace Old" checked: true  align: #left  )
		group "Select Channel"(
		Spinner mapChan_btn "Map Channel:" range:[0,4,1] type:#integer align: #left  )
		group "Set Sprite Pivots"(
		RadioButtons Pivot_rdo labels: #("PivotToBottom","CenterPivot")   align:#left )
	Button replaceRig_btn "replaceRig"
		Button Start_btn "Start" width: 170 height: 40 
		
		on browse_btn Pressed do 
		(
			ofile = getOpenFileName caption: "Open A Sprite Text File" \
			types: "All|*.*|Json(*.Json)|*.Json|Text(*.txt)|*.txt|"\
			filename:(getDir #scene)\
			historyCategory:"RTTObjectPresets"
			if (ofile != undefined) then 
			(
			edit_txt.text = oFile
			)
		)
		
		On Start_Btn pressed do 
		(

			if (edit_txt.text != undefined) then 
			(
				if (doesfileexist edit_txt.text  == true)  then
				(
					if ((getFilenameType   edit_txt.text ) == ".json") or ((getFilenameType   edit_txt.text ) == ".txt") then 
					(
						
					parseFile edit_txt.text 
						completeRedraw()
					)
					else
					(
						MessageBox "File format is Incorrect\nPlease Select a Json or Txt file"
					)
				)
				else
				(
					MessageBox "File Does Not exist"
				)
			)
			else
			(
				MessageBox "please Select a file"
			)
		
		)
	)--rollout end
		
	
	
	CreateDialog SpriteGen width: 180 height: 255 pos: [16, 160]
		Clearlistener ()
)--Macro End