/*
	Gameloft Path Fixer

	In most of our projects we download a svn repo to a folder in our PCs. This folder can be everywhere, that's why we map it to a specific letter.
	The idea is that everybody works inside this mapped drive, so that all paths point to a specific letter.

	Unfortunately sometimes paths have been specified to the svn folder instead of the mapped folder. This results in paths missing
	when a max file is opened in another PC. :(
	
	This script gathers all the missing or incorrect paths and attempts to fix them so that they point to the mapped drive. It also works with GL_Effect materials.
	Those paths that have not been fixed automatically can be fixed manually through the "Asset Tracker" dialog.

*/
-- by Norman Schaar - norman.schaar@gameloft.com



filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"

try
(
	destroyDialog Gameloft_Path_Fixer
)
catch()


fn Gameloft_Path_Fixer_close =
(
	try
	(
		destroyDialog Gameloft_Path_Fixer
	)catch()
)

rollout Gameloft_Path_Fixer "Gameloft Path Fixer"
(
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:200 pos:[0,0]
	dotNetControl lv_correct "System.Windows.Forms.ListView" width:600 height:200 pos:[0,200]
	button btn_fix "Fix paths!" width:200 height:30 pos:[0,500] enabled:false
	button btn_asset_tracker "Open Asset Tracker" width:200 height:30 pos:[200,500]
	
	label lbl_root_drive "Root Drive:" width:100 pos:[25,425]
	label lbl_svn_url "SVN URL: " width:600 pos:[25,450]
	
	progressBar pb_process width:600 pos:[0,470]
	
	
	
	fn listFolders theURL=
	(
		theSVN = getDir #userscripts + "\\GLL_Launcher\\svn-win32-1.7.2\\bin\\svn.exe"
		TheDosCommandOutput = (HiddenDotNetCommand theSVN (" list " + theURL) "")
		AsArray = (filterstring TheDosCommandOutput "\n")
		theArray = for n in AsArray where (getFileNameType n) == "" collect (substitutestring n "/" "")
		return theArray
	)
	
	fn fix_paths =
	(
		ATSOps.Visible = true
		ATSOps.Visible = false
		ATSOps.Silent = true
		
		/*
			Here we get the depot URL of the root drive of the currently opened maxfile.
			Example:
				File: "X:\\subfolder\\maxfile.max"
				RootDrive: "X:\\"
				SVN Url: https://svn-master01.mdc.gameloft.org/vc/gameloft_live_3d/trunk
		*/
		theUrl = getDepotURL (pathConfig.stripPathToTopParent maxfilepath)


		/*
			Here we get an array of the folders in the SVN path provided above.
			Example:
				URL: https://svn-master01.mdc.gameloft.org/vc/gameloft_live_3d/trunk
				Array: #("Android", "art", "data",...)
		*/
		theSVNFolderArray = (listFolders theUrl)

		/*
			Here we get an array with all the files that dont have the proper path. (To the mapped drive)
			Example:
				"C:\\gameloft_live_3d\\trunk\\art\\..."
			instead of:
				"X:\\art\\..."
		*/
		-- Get all files 
		atsops.GetFiles &fileList
		filelist = sort filelist
		theRoot = pathConfig.stripPathToTopParent maxfilepath

		theFileList = for n in filelist where (matchpattern n pattern:(theRoot + "*")) == false AND (pathConfig.stripPathToTopParent n) != n collect n

		for k=1 to theFileList.count do
		(
			pb_process.value = 100.*k/theFileList.count
			(dotnetClass "Application").doEvents()

			thePaths = filterstring theFileList[k] "\\"
			for i=1 to thePaths.count do
			(
				for o in theSVNFolderArray do
				(
					if o == thePaths[i] do
					(
						local theFinalPath = theRoot + "\\" + o
						for j=(i+1) to thePaths.count do
						(
							theFinalPath = theFinalPath + "\\" + thePaths[j]
						)
						theFinalPath = pathConfig.normalizePath theFinalPath
						--print ("Path: " + theFileList[k])
						--print ("Path: " + theFinalPath)
						if doesFileExist theFinalPath then
						(
						--	print "Status: Found \n"
							local theNewPath = (pathConfig.removePathLeaf theFinalPath) + "\\"
							atsops.selectfiles #(theFileList[k])
							atsops.setpathonselection theNewPath
						)
						else
						(
							--print "Status: Not Found \n"
						)
						exit
					)
				)
			)
		)
		pb_process.value = 0

		atsops.refresh()
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
		atsops.GetFiles &fileList
		fileList = sort fileList

		theRange = #()
		
		for n in fileList do
		(
			if matchpattern n pattern:((pathConfig.stripPathToTopParent maxfilepath) + "*") == false do
			(
				li = dotNetObject "System.Windows.Forms.ListViewItem"
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
		)
		
		lv.Items.AddRange theRange
	)
	
	fn fill_lv_correct =
	(
		lv_correct.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv_correct.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv_correct.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv_correct.gridLines = true-- turn off the grid lines
		lv_correct.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv_correct.BorderStyle=lv_correct.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv_correct.HeaderStyle=lv_correct.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv_correct.Columns.add "Correct Paths" 600
		
		-- Get all files 
		atsops.GetFiles &fileList
		fileList = sort fileList

		theRange = #()
		
		for n in fileList do
		(
			if matchpattern n pattern:((pathConfig.stripPathToTopParent maxfilepath) + "*") do
			(
				li = dotNetObject "System.Windows.Forms.ListViewItem"
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
		)
		
		lv_correct.Items.AddRange theRange
		
		
	)
	
	on btn_fix pressed do
	(
		fix_paths()
		
		fill_lv()
		fill_lv_correct()
	)
	
	on btn_asset_tracker pressed do
	(
		ATSOps.Visible = true
	)
	
	on Gameloft_Path_Fixer open do
	(
		callbacks.removeScripts id:#GLPFixer
		callbacks.addScript #filePreOpenProcess "Gameloft_Path_Fixer_close()" id:#GLPFixer
		
		
		fill_lv()
		fill_lv_correct()
		
		--Root Drive
		lbl_root_drive.text = "Root Drive: " + (pathConfig.stripPathToTopParent maxfilepath)
		--SVN URL
		filein "$userscripts\\GLL_Launcher\\GLL_Functions.ms"
		theUrl = getDepotURL (pathConfig.stripPathToTopParent maxfilepath)
		if theUrl == false then
		(
			lbl_svn_url.text = "SVN URL: ERROR: " + (pathConfig.stripPathToTopParent maxfilepath) + " is not a mapped drive!"
		)
		else
		(
			lbl_svn_url.text = "SVN URL: " + theUrl 
			btn_fix.enabled = true
		)
	)
	
	on Gameloft_Path_Fixer close do
	(
		callbacks.removeScripts id:#GLPFixer
	)
)
createDialog Gameloft_Path_Fixer width:600 height:530