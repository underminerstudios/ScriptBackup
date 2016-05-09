	rollout mainRollout "textTool_globalChecker" width:360
	(
		-- INI - UI ===================================================
		group "Project folders to parse:" 
		(
			label lb_A "-> C:\SVN\ProjectName\data\gfx3D" enabled:false align:#left
			edittext et_folder "gfx3D:   " fieldWidth:250 across:2
			button bt_folder "..." width: 32 align:#right offset:[0,-2]
			
			label lb_B "-> C:\SVN\ProjectName\data\levels" enabled:false align:#left
			edittext et_folder2 "Levels:   " fieldWidth:250 across:2
			button bt_folder2 "..." width: 32 align:#right offset:[0,-2]
			
			label lb_C "-> C:\SVN\ProjectName\data\AnimixerStates" enabled:false align:#left
			edittext et_folder3 "States:   " fieldWidth:250 across:2
			button bt_folder3 "..." width: 32 align:#right offset:[0,-2]
		)
		label lb_info "STATUS: ..." align:#left
		button bt_checkTextures "Search unused assets"
		-- END - UI ==================================================
		
		-- INI - FN ===================================================
		fn getFilesRecursive root pattern =
		(
			
			dir_array = #()
			append dir_array (root+"/")
			
			for d in dir_array do
			(
				join dir_array (GetDirectories (d+"/*"))
			)
			
			my_files = #()
			
			for f in dir_array do
			(
				join my_files (getFiles (f + pattern))
			)
			
			return my_files
		)
		
		fn extractFromFiles filesArray wildcard =
		(
			extractedFiles = #()
			
			for m in filesArray do
			(
				lb_info.text = "STATUS: Extracting from: "+(getFilenameFile m)+(getFilenameType m) as string
				myfilestream = openFile m
				
				while eof myfilestream == false do
				(
					lineString = readLine myfilestream
					endIndex = findString lineString (wildcard+"\"" as string)
					endIndex2 = findString lineString (wildcard+"," as string)
					
					if(endIndex2  != undefined)then
					(
						endIndex = endIndex2
					)
					
					--si trobem un dels fileformats dins l'arxiu...
					if(endIndex  != undefined)then
					(
						iniIndex = endIndex
						iniIndexFound = false
						
						--busquem l'inici del nom de l'arxiu amb el fileformat
						while iniIndexFound==false do
						(
							if (lineString[iniIndex] == "\"" or lineString[iniIndex] == "@" )then
							(
								iniIndexFound=true
								iniIndex =  iniIndex+1
							)else(
								iniIndex	= iniIndex-1
								if(iniIndex == 0)then
								(
									iniIndexFound=true
									messageBox("ERROR: no se encontro inicio de fileformat.")
								)
							)--end if 
						)--end while
						
						stringlength = ((endIndex) - (iniIndex))+((wildcard).count)
						extractedFile = substring lineString iniIndex stringlength
						appendIfUnique extractedFiles extractedFile
					)--end if
				)--end while
			)--end for
			return extractedFiles
		)--end function
		-- END - FN ==================================================
		
		
		-- INI - HANDLERS ===================================================
		on bt_folder pressed do
		(
			compareFolder = getSavePath()
			if(compareFolder!= undefined)then
			(
				et_folder.text = compareFolder
			)
		)
		
		on bt_folder2 pressed do
		(
			compareFolder = getSavePath()
			if(compareFolder!= undefined)then
			(
				et_folder2.text = compareFolder
			)
		)

		on bt_folder3 pressed do
		(
			compareFolder = getSavePath()
			if(compareFolder!= undefined)then
			(
				et_folder3.text = compareFolder
			)
		)
		
		on bt_checkTextures pressed do
		(
			models = getFilesRecursive et_folder.text "*.dae"
			models_files = #()
			lb_info.text = "STATUS: Parsing models"
			for m in models do
			(
				append models_files (getFilenameFile m)
			)
			
			textures = getFilesRecursive et_folder.text "*.tga"
			textures_files = #()
			
			lb_info.text = "STATUS: Parsing textures"
			for t in textures do
			(
				append textures_files (getFilenameFile t)
			)
			
			libs = getFilesRecursive et_folder2.text "*.libclara"
			claras	= getFilesRecursive et_folder2.text "*.clara"
			join claras libs
			
			states	= getFilesRecursive et_folder3.text "*.stt"
			
			texturesFromModels = extractFromFiles models ".TGA"
			texturesFromClaras = extractFromFiles claras ".TGA"
			
			statesAnims = extractFromFiles states ".ANIM"
			claraAnims = extractFromFiles claras ".ANIM"
			claraModels = extractFromFiles claras ".PIG"
			
			lb_info.text = "STATUS: Joining texture arrays"
			usedModels = #()
			join usedModels claraAnims
			join usedModels claraModels
			join usedModels statesAnims

			usedTextures = #()
			join usedTextures texturesFromModels
			join usedTextures texturesFromClaras
			
			lb_info.text = "STATUS: Making texture arrays unique"
			usedModels = makeUniqueArray usedModels
			usedTextures = makeUniqueArray usedTextures
			
			lb_info.text = "STATUS: Matching textures..."
			
			notUsedTextures = #()
			
			for t in textures_files do
			(
				found = false
				
				for tt in usedTextures do
				(
					if (getFilenameFile t) == (getFilenameFile tt) then
					(
						found= true
					)
				)
				
				if found == false then
				(
					append notUsedTextures t
				)
			)
			
			lb_info.text = "STATUS: Matching models..."
			
			notUsedModels = #()
			
			for m in models_files do
			(
				found = false
				
				for mm in usedModels do
				(
					if (getFilenameFile m) == (getFilenameFile mm) then
					(
						found= true
					)
				)
				
				if found == false then
				(
					append notUsedModels m
				)
			)
			
			lb_info.text = "STATUS: Printing..."
			logFile = "C:\\svn\\tooText_globalCheck.txt"
			out_file = createfile logFile
			
			format "POTENTIALLY UNUSED  TEXTURES:\n" to:out_file
			format "---------------------------------\n" to:out_file
			format "\n" to:out_file
			
			for i=1 to notUsedTextures.count do
			(
				format "%.tga\n" notUsedTextures[i] to:out_file		
			)

			format "\n\n\n" to:out_file
			format "POTENTIALLY UNUSED  MODELS:\n" to:out_file
			format "-------------------------------\n" to:out_file
			format "\n" to:out_file
			
			for i=1 to notUsedModels.count do
			(
				format "%.dae\n" notUsedModels[i] to:out_file		
			)					
			close out_file
			edit logFile
			
		)
		-- END - HANDLERS ===================================================
	)
	
	createdialog mainRollout