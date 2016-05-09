/*
	Biped Replace
	
	This script allows you repalce a biped in a max scene and preserve the animation.
	
	Select "The Root Folder". All Max files found in this folder and its subfolders will be processed.
	
	Select the "Max File:". This is where the new biped should be.
	
	
	Hit "Process Batch" in order to process all the max files found.
	
	You can also hit "Process Opened Max file only". This will only process the currently opened max file. 
	
	
	by Norman Schaar - norman.schaar@gameloft.com 03/2012


*/





try(destroyDialog BATCH_REPLACE_BIPED)catch()

rollout BATCH_REPLACE_BIPED "Batch Replace Biped"
(
	edittext et_root "Root folder:" width:460 pos:[10,10] readonly:true
	button btn_root_browse "..." width:20 pos:[470,8]
	edittext et_maxfile "Max File:" width:460 pos:[10,40] readonly:true
	button btn_maxfile_browse "..." width:20 pos:[470,38]
	button btn_start "Process Batch" width:160 height:30
	button btn_start_open "Process Opened Max file Only" width:160 height:20

	fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
		join dir_array (GetDirectories (d+"/*"))
		 
		my_files = #()
		for f in dir_array do
		join my_files (getFiles (f + pattern))
		my_files 
	)
	
	fn GET_BIPED =
	(
		for n in objects do
		(
			if (classof n)==Biped_Object do
			(
				return n
			)
		)
		return false
	)
	
	fn process =
	(
		theBiped = GET_BIPED()

		if theBiped != false then
		(
			ctrl = theBiped.transform.controller
			--Delete Temp BIP file
			deleteFile (GetDir #userscripts + "\\tmp.bip")
			--Save active time segment animation to a BIP file
			biped.saveBipFileSegment ctrl (GetDir #userscripts + "\\tmp.bip") animationRange.start animationRange.end
			--Delete the biped
			delete theBiped
			
			sleep 1
			--Delete lights
			delete lights
			delete objects
			--Delete Meshes
			--Merge Max file with new biped
			mergeMaxFile et_maxfile.text #AutoRenameDups #useMergedMtlDups #alwaysReparent 
			
			--Get the new merged biped
			NEW_BIPED = GET_BIPED()
			NEW_CTRL = NEW_BIPED.transform.controller
			
			--Turn "OFF" figure mode
			NEW_CTRL.figureMode = false
			--Load Temp BIP file
			biped.loadBipFile NEW_CTRL (GetDir #userscripts + "\\tmp.bip")
			--Delete temp bip file
			deleteFile (GetDir #userscripts + "\\tmp.bip")
					
			savemaxfile (maxfilepath + maxfilename)
		)
		else
		(
			print ("ERROR: " + maxfilename + " has no Biped!")
		)
	)

	on btn_root_browse pressed do
	(
		GET_SAVE_PATH = (getSavePath caption:"Select a root folder")
		if GET_SAVE_PATH != undefined do
		(
			et_root.text = GET_SAVE_PATH
		)		
	)
	
	on btn_maxfile_browse pressed do
	(
		filename = getOpenFileName \ 
		caption:"Open a 3dsMax Scene file with the new Biped" \
		types:"3dsMax Scenes(*.max)|*.max" \
		if filename != undefined do
		(
			et_maxfile.text =filename
		)
	)
	
	on btn_start pressed do
	(
		if et_maxfile.text != "" AND et_root.text != "" do
		(
			theArray = getFilesRecursive (et_root.text + "\\") "*.max"
		
			for j in theArray do
			(
				if (((heapsize - heapfree) / 1000000) as integer) > 60 do
				(
					gc light:true
				)
				LoadMaxFile j quiet:true useFileUnits:true
				process()
			)
		)
	)
	
	on btn_start_open pressed do
	(
		process()
	)
)
createDialog BATCH_REPLACE_BIPED width:500 height:120