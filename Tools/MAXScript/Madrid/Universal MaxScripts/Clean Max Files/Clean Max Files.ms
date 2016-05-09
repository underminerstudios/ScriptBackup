
try(destroyDialog CleanMaxFiles)catch()
rollout CleanMaxFiles "Clean Max Files..."
(
	fn GetFilesReferenced =
	(
		atsops.refresh()
		ATSOps.ExcludeOutputFiles
		atsops.silent = true
		local fileList
		local finalList = #()
		atsops.GetFiles &fileList
		for f in fileList do (appendifunique finalList f)
		finalList
	)
	
	fn CleanMaterials =
	(
		for i=1 to meditMaterials.count do (meditMaterials[i] = standard())
		local theMaterials = #()
		for n in objects do
		(
			if n.material != undefined do (appendifunique theMaterials n.material)
		)

		if theMaterials.count > 24 then
		(
			for i=1 to 24 do (meditMaterials[i] = theMaterials[i])
		)
		else
		(
			for i=1 to theMaterials.count do (meditMaterials[i] = theMaterials[i])
		)
	)
	
	
	fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
		join dir_array (GetDirectories (d+"/*"))
		 
		my_files = #()
		for f in dir_array do
		join my_files (getFiles (f + pattern))
		for f in (getFiles (root + "\\" + pattern)) do (append my_files f)
		my_files 
	)
	
	fn rescurseMultipleFolders folders pattern =
	(
		for f in folders do
		(
			local theFiles = getFilesRecursive f pattern
			if theFiles.count != 0 do
			(
				return theFiles[1]
			)
		)
		return 0		
	)
	
	fn FixPaths AdditionalPaths= 
	(
		atsops.refresh()
		atsops.silent = true
		local theFiles = GetFilesReferenced()
		for f in theFiles do
		(
			if not doesFileExist f do
			(
				local theNewFile = undefined
				
				--First recurse inside max file folder
				local theFoundFiles = getFilesRecursive (maxfilepath + "\\") (filenameFromPath f)
				if theFoundFiles.count == 0 then
				(
					--If not found try to find in additional paths
					local theResult = rescurseMultipleFolders AdditionalPaths (filenameFromPath f)
					if theResult != 0 do
					(
						theNewFile = theResult
					)
				)
				else
				(
					theNewFile = theFoundFiles[1]
				)
				
				if theNewfile != undefined do
				(
					local theNewFolder = getFilenamePath theNewFile
					
					print "Missing:"
					print f
					print "Found:"
					print theNewFile
					atsops.selectfiles #(f)
					atsops.setpathonselection theNewFolder
				)

			)
		)
		atsops.refresh()
	)
	
	edittext et_root "Root:" width:350 align:#left
	button btn_browseRoot "Browse Root" width:150 align:#left

	checkbox cb_deleteMats "Delete Unused Materials:" checked:true
	checkbox cb_fixPaths "Attempt to fix paths by recursivly searching in subfolders" checked:true
	
	multilistbox mlb_additionalPaths "Additional Paths to look for missing files:" height:3
	button btn_addPath "Add Path" width:150
	
	button btn_process "Batch Process" width:150 align:#left
	
	on cb_fixPaths changed theState do
	(
		mlb_additionalPaths.enabled = theState
		btn_addPath.enabled = theState
	)
	
	on btn_browseRoot pressed do
	(
		local newPath = getSavePath caption:"Select a folder:" maxfilepath
		if newPath != undefined do
		(
			et_root.text = newPath
		)
	)
	
	on btn_addPath pressed do
	(
		local theFolders = mlb_additionalPaths.items
		local theFolder = getSavePath caption:"Select a folder:" maxfilepath
		if theFolder != undefined do
		(
			append theFolders theFolder
		)
		mlb_additionalPaths.items = theFolders
	)
		
	
	on btn_process pressed do
	(
		local theRoot = (substitutestring et_root.text "\\" "\\\\" ) + "\\"
		local MaxFiles = getFilesRecursive theRoot "*.max"
		
		if cb_fixPaths.state == true OR cb_deleteMats.state == true do
		(
			with undo off with redraw off
			(
				atsops.visible = true
				atsops.visible = false
				for f in MaxFiles do
				(
					loadMaxFile f useFileUnits:true quiet:true
					if cb_deleteMats.state == true do (CleanMaterials())
					if cb_fixPaths.state = true do (FixPaths mlb_additionalPaths.items)
					saveMaxFile f clearNeedSaveFlag:false saveAsVersion:2011 useNewFile:false quiet:true
				)
			)
		)
	)
	
)
createDialog CleanMaxFiles width:400