macroScript materialAnimation category:"Gameloft" buttonText:"mAnim" toolTip:"Material Animation" Icon:#("PhysX_Main", 17) autoUndoEnabled:true
(
	--clearListener()
	
	struct CategoryData
	(
		category, data, material
	)
	
	struct UVData
	(
		name, uv
	)
	
	local settings
	local atlasSize
	
	rollout animateUVRollout "Animate UV's" width:162 height:300
	(
		listBox listBody "Category" height:6
		listBox listFrames "Frame" height:16
		button buttonKey "Key" height:20
		checkButton buttonAutoKey "Auto Key" height:20
		
		fn populateCategories =
		(
			items = #()
			for i = 1 to settings.count do
			(
				append items settings[i].category
			)
			
			listBody.items = items
		)
		
		fn populateFrames index =
		(
			selected = settings[index]
			
			items = #()
			for i = 1 to selected.data.count do
			(
				append items selected.data[i].name
			)
			
			listFrames.items = items
		)
		
		fn getSceneMaterialByName name =
		(
			for i = 1 to sceneMaterials.count do
			(
				if classOf sceneMaterials[i] == Multimaterial then
				(
					-- Search inside the multimaterial for the proper shader.
					multiMat = sceneMaterials[i]
					subMats = multiMat.materialList
					for j = 1 to subMats.count do
					(
						if subMats[j].name == name then
						(
							return subMats[j]
						)
					)
				)
				else
				(
					if sceneMaterials[i].name == name then
					(
						return sceneMaterials[i]
					)
				)
			)
			
			return undefined
		)
		
		fn GetKeyAtCurrentTime controllerKeys =
		(
			for i = 1 to controllerKeys.count do
			(
				if controllerKeys[i].time == currentTime then
				(
					return controllerKeys[i]
				)
			)
			return undefined
		)
		
		fn SetUniform mat uniformName value key tangent =
		(
			if classof mat != gl_effect_inst then
			(
				print ("Warning: " + mat.name + " is not a glitch material")
				return undefined
			)
			
			param = mat.params.GetEffectParamByName "Offset"
			
			if key == true then
			(
				maxops.getDefaultTangentType &inTangent &outTangent
				maxops.setDefaultTangentType #step #step
				with animate on
				(
					param.value = value
				)
				maxops.setDefaultTangentType inTangent outTangent
			)
			else
			(
				param.value = value
			)
			
		)
		
		fn SetUVOffsetTo num =
		(
			selected = settings[num]
			-- print ("Material name: " + selected.material as string)
			mat = getSceneMaterialByName selected.material

			if mat != undefined then
			(
				print selected.data[listFrames.selection] as string
				uvPixels = selected.data[listFrames.selection].uv
				uv = #(uvPixels[1] / atlasSize[1], uvPixels[2] / atlasSize[2])

				SetUniform mat "Offest" uv true #flat
			)
		)
		
		on animateUVRollout open do 
		(
			populateCategories()
			populateFrames 1
		)
		
		on listBody selected arg do
		(
			populateFrames arg
		)
		
		on listFrames selected arg do
		(
			SetUVOffsetTo listBody.selection
		)
		
		on buttonKey pressed do
		(
			print "pressed"
		)
	)
	
	-- Loops through a section of the ini file and collects similar results into an array.
	fn GetINIList filename category prefix =
	(
		ctr = 0
		iniString = "."
		result = #()
		
		while iniString != "" do
		(
			iniString = getINISetting filename category (prefix + ctr as string)
			ctr = ctr + 1
			
			if iniString != "" then
			(
				append result iniString
			)
		)
		
		return result
	)
	
	-- Takes a Category string, splits it and puts each section into the proper places
	fn ParseRawCategoryData rawString =
	(
		resultList = #()
		
		for i = 1 to rawString.count do
		(
			split = filterString rawString[i] ","
			frameName = split[1]
			deleteItem split 1
			split[1] = split[1] as float
			split[2] = split[2] as float
			result = UVData name:frameName uv:split
			append resultList result
		)
		
		return resultList
	)
	
	-- Parses the ini file and stores all of the information in structs.
	fn ReadSettings filename =
	(
		settings = #()
		categories = GetINIList filename "Categories" "Category"
		
		for i = 1 to categories.count do
		(
			rawData = GetINIList filename categories[i] ""
			data = ParseRawCategoryData rawData
			material = getINISetting filename categories[i] "Material"
			newCat = CategoryData category:categories[i] data:data material:material
			append settings newCat
		)
		
		width = (getINISetting filename "Atlas" "Width") as float
		height = (getINISetting filename "Atlas" "Height") as float
		atlasSize = #(width, height)
		
		-- print ("Settings " + settings as string)
		return settings
	)
	
    -- Returns the files filename.
	fn GetFilename =
	(
		fullFilename = maxFileName
		
		if fullFilename == undefined then
		(
			fullFilename = "Untitled.max"
		)
		
		return fullFilename
	)
	
	-- Returns the files filename minus the extension.
    fn GetFilenameNoExt =
    (
		fullFilename = GetFilename()
		return (getFilenameFile fullFilename)
    )
	
	fn Start =
	(
		filePath = maxFilePath
		filename = GetFilenameNoExt()
		iniFile = (filePath + filename + ".ini")
		
		exists = doesFileExist iniFile
		if exists == false then
		(
			messageBox ("Animated Material .ini file not found. " + iniFile)
			return ""
		)
		
		settings = ReadSettings iniFile -- "I:\characters\follower\wip\follower.ini"
		floater = newRolloutFloater "Texture Animator" 218 400
		addRollout animateUVRollout floater rolledUp:false border:true
		return ""
	)
	
	Start()
)