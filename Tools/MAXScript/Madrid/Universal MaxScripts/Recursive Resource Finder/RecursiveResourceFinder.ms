try(destroyDialog RecursiveResourceFinder)catch()
rollout RecursiveResourceFinder "Recursive Resource Finder"
(
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:400 pos:[0,0]
	button btn_fix "Fix paths!" width:200 height:30 pos:[0,500]-- enabled:false
	label lbl_root_drive "Root Drive:" width:100 pos:[25,425]
	progressBar pb_process width:600 pos:[0,470]
	
	fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
		(
			join dir_array (GetDirectories (d+"/*"))
		)
		my_files = #()
		for f in dir_array do
		(
			join my_files (getFiles (f + pattern))
		)
		my_files
	)
	
	fn get_wrong_files =
	(
		ATSOps.Visible = true
		ATSOps.Visible = false
		ATSOps.Silent = true
		
		local outputArray = #()
		atsops.GetDependentFiles (maxfilepath + maxfilename) false &fileList
		fileList = sort fileList
		for n in fileList do
		(
			if matchpattern n pattern:((pathConfig.stripPathToTopParent maxfilepath) + "*") == false OR (doesFileExist n) == false do
			(
				append outputArray n
			)
		)
		outputArray		
	)
	
	fn fill_lv =
	(
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Wrong & Missing paths" 600
		
		-- Get all files 
		local theFiles = get_wrong_files()

		local theRange = #()
		
		for n in theFiles do
		(
			local li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.text = n
			li.UseItemStyleForSubItems=false
			
			if doesFileExist n then
			(
				li.ForeColor = (dotNetClass "System.Drawing.Color").Green
			)
			else
			(
				li.ForeColor = (dotNetClass "System.Drawing.Color").Red
			)
			
			append theRange li
		)
		
		lv.Items.AddRange theRange
	)
	
	on btn_fix pressed do
	(
		local theWrongFiles = get_wrong_files()
		
		for k=1 to theWrongFiles.count do
		(
			pb_process.value = 100.*k/theWrongFiles.count
			(dotnetClass "Application").doEvents()
			local theFoundFileArray = getFilesRecursive (pathConfig.stripPathToTopParent maxfilepath) (getFileNameFile theWrongFiles[k] + getfileNameType theWrongFiles[k])
			if theFoundFileArray.count != 0 do
			(
				local theNewPath = (pathConfig.removePathLeaf theFoundFileArray[1]) + "\\"
				atsops.selectfiles #(theWrongFiles[k])
				atsops.setpathonselection theNewPath
			)
		)
		pb_process.value = 0
		
		fill_lv()
		atsops.refresh()
	)
	
	on RecursiveResourceFinder open do
	(
		fill_lv()
		lbl_root_drive.text = "Root Drive: " + (pathConfig.stripPathToTopParent maxfilepath)
	)
)
createDialog RecursiveResourceFinder width:600 height:530
