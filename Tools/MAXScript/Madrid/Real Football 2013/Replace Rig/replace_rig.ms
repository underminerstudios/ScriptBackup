/*
	Batch Replace Biped and Face Rig - Real Football 2013
	
	This is a modified version of the Biped Replace script.
	This will also preserve the face rig of bipeds from Real Football 2012. This is probably a one-time usable script.
	
	by Norman Schaar - norman.schaar@gameloft.com
*/

try(destroyDialog RF_13_BATCH_REPLACE_BIPED)catch()


rollout RF_13_BATCH_REPLACE_BIPED "Batch Replace Biped and Face Rig"
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
		local theBiped = GET_BIPED()

		if theBiped != false do
		(
			
			local ctrl = theBiped.transform.controller
			--Delete Temp BIP file
			deleteFile (GetDir #userscripts + "\\tmp.bip")
			--Save active time segment animation to a BIP file
			biped.saveBipFileSegment ctrl (GetDir #userscripts + "\\tmp.bip") animationRange.start animationRange.end
			
			local FACE_RIG = false
			--Does the face rig exist?
			if $EyebrowL != undefined do
			(
				FACE_RIG = true
			)
			
			if FACE_RIG == true do
			(
				--Figure Mode
				(theBiped.controller).figureMode = true
				
				--The Face Rig
				local THE_FACE_RIG = #($EyebrowL, $EyebrowR, $MourhCornerL, $MourhCornerR, $UpperLipsL, $UpperLipsR, $LowerLipsL, $LowerLIpsR, $Jaw)
				
				--Export XAF of Face Rig
				LoadSaveAnimation.saveAnimation (GetDir #userscripts + "\\tmp.xaf") THE_FACE_RIG #() #() animatedTracks:true includeConstraints:false keyableTracks:false saveSegment:true segInterval:(interval animationRange.start animationRange.end) segKeyPerFrame:false
			)
			
				--Delete All objects
				delete objects
				--Merge max file
				mergeMaxFile et_maxfile.text #AutoRenameDups #useMergedMtlDups #alwaysReparent
			
			if FACE_RIG == true do
			(
				--Figure Mode ON
				local THE_NEW_BIPED = GET_BIPED()
				(THE_NEW_BIPED.controller).figureMode = true
				
				--Save New Face Rig position
				THE_NEW_FACE_RIG = #($EyebrowL, $EyebrowR, $MourhCornerL, $MourhCornerR, $UpperLipsL, $UpperLipsR, $LowerLipsL, $LowerLIpsR, $Jaw)
				THE_NEW_FACE_RIG_POS = for n in THE_NEW_FACE_RIG collect n.pos

				--Load Xaf File from old rig
				LoadSaveAnimation.loadAnimation (GetDir #userscripts + "\\tmp.xaf") THE_NEW_FACE_RIG relative:false insert:false stripLayers:false
				deleteFile (GetDir #userscripts + "\\tmp.xaf")

				--Change Position
				($EyebrowL).pos = THE_NEW_FACE_RIG_POS[1]
				($EyebrowR).pos = THE_NEW_FACE_RIG_POS[2]
				($MourhCornerL).pos = THE_NEW_FACE_RIG_POS[3]
				($MourhCornerR).pos = THE_NEW_FACE_RIG_POS[4]
				($UpperLipsL).pos = THE_NEW_FACE_RIG_POS[5]
				($UpperLipsR).pos = THE_NEW_FACE_RIG_POS[6]
				($LowerLipsL).pos = THE_NEW_FACE_RIG_POS[7]
				($LowerLIpsR).pos = THE_NEW_FACE_RIG_POS[8]
				($Jaw).pos =  THE_NEW_FACE_RIG_POS[9]
				
				--Figure Mode OFF
				(THE_NEW_BIPED.controller).figureMode = false
			)
			
			--Load BIP file
			local THE_NEW_BIPED_2 = GET_BIPED()
			local NEW_BIPED_CTRL = THE_NEW_BIPED_2.transform.controller
			biped.loadBipFile NEW_BIPED_CTRL (GetDir #userscripts + "\\tmp.bip")
			deleteFile (GetDir #userscripts + "\\tmp.bip")
			
			savemaxfile (maxfilepath + maxfilename)
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
			theArray = getFilesRecursive et_root.text "*.max"
		
			for j in theArray do
			(
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
createDialog RF_13_BATCH_REPLACE_BIPED width:500 height:120