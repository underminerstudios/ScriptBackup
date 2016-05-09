try(destroyDialog DLG_REPATH_TOOL)catch()
rollout DLG_REPATH_TOOL "Repath Tool"
(
	local theMaxFiles
	local theFilteredMaxFiles = #()
	
	edittext et_path "Root Path:" readonly:true pos:[5,5] width:540
	button btn_browse "Browse" pos:[545,3]
	label lbl_fix "Fix Paths:" align:#left
	button btn_auto_fix_analyze "Analyze Auto-Fix" enabled:false align:#left width:100
	button btn_auto_fix "Run Auto-fix" enabled:false align:#left width:100
	checkbox cb_aggressive "Aggressive" pos:[120,50]
	edittext et_old_path "Old Path:" pos:[5,105] width:540
	button btn_old_path_Browse "Browse" pos:[545,103]
	edittext et_new_path "New Path:" pos:[5,125] width:540 readonly:true
	button btn_new_path_Browse "Browse" pos:[545,123]
	button btn_fix_old_new_path "Fix" pos:[545,143] width:50 enabled:false
	
-- 	edittext et_filter "Filter:"
	dotNetControl tv "system.windows.forms.treeView" width:600 height:730 pos:[0,170]
	
	fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
		join dir_array (GetDirectories (d+"/*"))
		 
		my_files = #()
		for f in dir_array do
		join my_files (getFiles (f + pattern))
		for f in getFiles (root + "\\" + pattern) do
			appendifunique my_files f
		my_files 
	)
	
	fn findNode theNodes theText =
	(
		for i=0 to theNodes.count - 1 do
		(
			if theNodes.item[i].text == theText do
			(
				return theNodes.item[i]
			)
		)
		return false
	)
	
	fn cleanpopulate =
	(
		tv.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 86 86 86
		tv.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 220 220 220
		tv.LineColor = (dotNetClass "System.Drawing.Color").fromARGB 150 150 150
		tv.nodes.clear()
	)
	
	fn populateTreeView theFiles =
	(
		local imglist = dotnetobject "System.Windows.Forms.ImageList"
		imglist.ColorDepth = imglist.ColorDepth.Depth32Bit
		imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
		local imageClass = dotNetClass "System.Drawing.Image"
		
		local ExtraBitmaps = #( \
		pathconfig.normalizePath (getFileNamePath (getSourceFileName()) + "\\icons\\3dsmax.png"), \
		pathconfig.normalizePath (getFileNamePath (getSourceFileName()) + "\\icons\\folder.png"), \
		pathconfig.normalizePath (getFileNamePath (getSourceFileName()) + "\\icons\\tga.png"))

		for n in ExtraBitmaps do
		(
			imgList.images.add (imageClass.fromFile n)
		)
		tv.ImageList = imglist
		
		local notfoundCount = 0
		
		tv.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 86 86 86
		tv.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 220 220 220
		tv.LineColor = (dotNetClass "System.Drawing.Color").fromARGB 150 150 150
		tv.nodes.clear()
-- 		local theFiltered = for n in theFiles collect (filterstring n "\\")
		
		for f in theFiles do
		(
			local theFiltered = filterstring f "\\"
			local theParentNode = findNode tv.nodes theFiltered[1]
			
			local already_exists = true
			if theParentNode == false do
			(
				theParentNode = dotNetObject  "System.Windows.Forms.TreeNode" theFiltered[1]
				theParentNode.ImageIndex = 1
				theParentNode.SelectedImageIndex = theParentNode.ImageIndex
				already_exists = false
			)

			local theNode = theParentNode
			for i=2 to theFiltered.count do
			(
				local theChildNode = findNode theNode.nodes theFiltered[i]
				local childalready_exists = true
				if theChildNode == false do
				(
					theChildNode = (dotNetObject  "System.Windows.Forms.TreeNode" theFiltered[i])
					if i!=theFiltered.count then
					(
						theChildNode.ImageIndex = 1
					)
					else
					(
						theChildNode.tag = f
						theChildNode.ImageIndex = 0
					)
					theChildNode.SelectedImageIndex = theChildNode.ImageIndex
					childalready_exists = false
				)
				if childalready_exists == false do
				(
					theNode.nodes.add theChildNode
				)
				theNode = findNode theNode.nodes theFiltered[i]

				
				if i== theFiltered.count do
				(
					local metaArray = getMAXFileAssetMetadata f
					local theBitmaps = #()
					for m in metaArray do (appendifunique theBitmaps m.filename)
					sort theBitmaps
					for m in theBitmaps do
					(
						local bitmapNode = dotNetObject  "System.Windows.Forms.TreeNode" (getFileNameFile m + getFilenameType m)
						bitmapNode.ImageIndex = 2
						bitmapNode.SelectedImageIndex = bitmapNode.ImageIndex
						if doesFileExist m then
						(
							bitmapNode.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 127 186 0
						)
						else
						(
							bitmapNode.ForeColor = (dotNetClass "System.Drawing.Color").Red
							notfoundCount += 1
						)
						theNode.nodes.add bitmapNode
					)
				)
			)
			if already_exists == false do
			(
				tv.nodes.add theParentNode
			)
		)
		
		tv.expandall()
		
		print (notfoundCount as string + " files not found!")
	)
	
	on tv NodeMouseClick arg do
	(
		local theNode = tv.GetNodeAt arg.x arg.y
		tv.SelectedNode = theNode
		--Mousebutton click? Right or Left?
		--Right click
		if (arg.Button).value__ == 2097152 then
		(
			
		)
		else
		(
			if tv.SelectedNode.nodes.count == 0 do
			(
				et_old_path.text = tv.SelectedNode.text
			)
		)
	)
	
	--Run the script on double-click
	on tv NodeMouseDoubleClick arg do
	(
		local theNode = tv.GetNodeAt arg.x arg.y
		if theNode.tag != undefined do
		(
			loadMaxFile theNode.tag useFileUnits:true quiet:false 
		)
	)
	
	on btn_browse pressed do
	(
		local thePath = getSavePath caption:"Root Path:" initialDir:"C:\\"
		if thePath != undefined do
		(
			et_path.text = thePath
			local theFiles = getFilesRecursive thePath "*.max"
			btn_auto_fix_analyze.enabled = true
			btn_auto_fix.enabled = true
			btn_fix_old_new_path.enabled = true
			populateTreeView theFiles
		)
	)
	
	on et_filter changed arg do
	(
		local theFiles = getFilesRecursive et_path.text "*.max"
		theFilteredMaxFiles = #()
		for n in theFiles do
		(
			local metaArray = getMAXFileAssetMetadata n
			for m in metaArray where matchpattern m.filename pattern:("*" + arg + "*") do appendifunique theFilteredMaxFiles n
		)
		populateTreeView theFilteredMaxFiles
	)

	on btn_auto_fix_analyze pressed do
	(
		local theFiles = getFilesRecursive et_path.text "*.max"
		
		local progresscount = 0
		local fix_count = 0
		progressStart "Analyzing..."
		for n in theFiles do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theFiles.count))
			(dotnetClass "Application").doEvents()
			local metaArray = getMAXFileAssetMetadata n
			local has_been_fixed = false
			local old_paths = #()
			local new_paths = #()
			for x = 1 to metaArray.count do
			(
				local fName = metaArray[x].filename
				if doesFileExist fName == false do
				(
					local theFoundFileArray
					if cb_aggressive.state == true then
					(
						theFoundFileArray = getFilesRecursive et_path.text (getFileNameFile fName + getfileNameType fName)
					)
					else
					(
						theFoundFileArray = getFilesRecursive (getFilenamePath n)  (getFileNameFile fName + getfileNameType fName)
					)
					if theFoundFileArray.count != 0 do
					(
						fix_count += 1
						has_been_fixed = true
						append old_paths fname
						append new_paths (pathconfig.normalizePath theFoundFileArray[1])
					)
				)
			)
			if has_been_fixed == true do
			(
				print ("To be Fixed for " + "\"" + getFileNameFile n + getFileNameType n + "\"" + ":")
				for i=1 to old_paths.count do
				(
					print ("OLD: " + old_paths[i])
					print ("NEW: " + new_paths[i])
				)
			)
		)
		progressEnd()
		print ("Summary: " + fix_count as string + " files will be fixed.")
	)
	
	on btn_auto_fix pressed do
	(
		local theFiles = getFilesRecursive et_path.text "*.max"
		local progresscount = 0
		progressStart "Fixing..."
		for n in theFiles do
		(
			progresscount += 1
			progressUpdate (100.0*progresscount/(theFiles.count))
			(dotnetClass "Application").doEvents()
			local metaArray = getMAXFileAssetMetadata n
			local has_been_fixed = false
			for x = 1 to metaArray.count do
			(
				local fName = metaArray[x].filename
				if doesFileExist fName == false do
				(
					local theFoundFileArray
					if cb_aggressive.state == true then
					(
						theFoundFileArray = getFilesRecursive et_path.text (getFileNameFile fName + getfileNameType fName)
					)
					else
					(
						theFoundFileArray = getFilesRecursive (getFilenamePath n)  (getFileNameFile fName + getfileNameType fName)
					)
					if theFoundFileArray.count != 0 do
					(
						has_been_fixed = true
						metaArray[x].filename = theFoundFileArray[1]
					)
				)
			)
			if has_been_fixed == true do (setMAXFileAssetMetadata n metaArray)
		)
		
		progressEnd()
		
		populateTreeView theFiles
	)
	
	on btn_old_path_Browse pressed do
	(
		local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Please Select One File" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "All Files (*.*)|*.*" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		local result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string

		if (result.Equals result.OK) == true do
		(
			et_old_path.text = theDialog.fileNames[1] --the selected filenames will be returned as an array
		)
	)
	
	on btn_new_path_Browse pressed do
	(
		local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Please Select One File" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "All Files (*.*)|*.*" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		local result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string

		if (result.Equals result.OK) == true do
		(
			et_new_path.text = theDialog.fileNames[1] --the selected filenames will be returned as an array
		)
	)
	
	on btn_fix_old_new_path pressed do
	(
		if et_old_path.text != "" AND et_new_path.text != "" do
		(
			local theFiles = getFilesRecursive et_path.text "*.max"
			local theOldPath = et_old_path.text
			local theNewPath = et_new_path.text
			
			for n in theFiles do
			(
				local metaArray = getMAXFileAssetMetadata n
				local has_been_fixed = false
				for x = 1 to metaArray.count do
				(
					local fName = metaArray[x].filename
					if matchpattern fname pattern:("*" + theOldPath) do
					(
						has_been_fixed = true
						metaArray[x].filename = theNewPath
					)
				)
				if has_been_fixed == true do (setMAXFileAssetMetadata n metaArray)
			)
			populateTreeView theFiles
		)
	)
	
	on DLG_REPATH_TOOL open do
	(
		cleanpopulate()
	)
	
	on DLG_REPATH_TOOL close do
	(
		--Dispose images in imagelist
		try
		(
			for i=0 to (tv.ImageList.Images.count - 1) do
			(
				tv.ImageList.Images.Item[i].Dispose()
			)
			tv.ImageList.Dispose()
			tv.Dispose()
		)catch()
		--Garbage Collection to unlock bitmaps
		gc light:true
		dgc = dotnetclass "system.gc"
		dgc.collect()
	)
)
createDialog DLG_REPATH_TOOL width:600 height:900