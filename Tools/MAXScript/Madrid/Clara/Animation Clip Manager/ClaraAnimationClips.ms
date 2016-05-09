try (destroyDialog DLG_CLARA_ANIMATION_CLIP_MANAGER)catch()
rollout DLG_CLARA_ANIMATION_CLIP_MANAGER "Animation Clip Manager"
(		
	local animationStart = (animationrange.start as integer)/TicksPerFrame
	local animationEnd = (animationrange.end as integer)/TicksPerFrame
	local theTempFile = getFilenamePath (getSourceFileName()) + "\\temp.ini"
	local PRE_OPEN_ANIMATIONRANGE = animationrange
		
	group "Properties"
	(
		edittext createAnimClipNameEditText "Name :" align:#left
		spinner createAnimClipStartTimeSpinner "Start :" range:[animationStart,animationEnd,animationStart] type:#integer align:#left across:2 width:140
		spinner createAnimClipEndTimeSpinner "End :" range:[animationStart,animationEnd,animationStart] type:#integer align:#left width:140
		button createNewClipButton "Enter" align:#left width:100 across:2
		button delete_clipButton "Delete" align:#right width:100
	)
	
	group "Animation Clips"
	(
		dotNetControl lv "ListView" width:280 height:200 align:#center
	)
	
	fn lv_to_ini =
	(
		deleteFile theTempFile
		(dotnetClass "System.IO.File").WriteAllLines theTempFile #("")
		for i=0 to (lv.Items.count - 1) do
		(
			local theName = lv.Items.Item[i].subitems.Item[0].text
			local theStart = lv.Items.Item[i].subitems.Item[1].text
			local theEnd = lv.Items.Item[i].subitems.Item[2].text
			setINIsetting theTempFile theName "Start" theStart
			setINIsetting theTempFile theName "End" theEnd
		)
	)
	
	fn ini_to_prop =
	(
		local theString = (dotnetClass "System.IO.File").ReadAllText theTempFile
		fileProperties.addProperty #custom "CLARA_ANIMATION_CLIPS_INI" theString
		deleteFile theTempFile
	)
	
	fn fill_lv =
	(
		lv.clear()
		lv.View = (dotNetClass "System.Windows.Forms.View").Details  
		lv.fullRowSelect = true  
		lv.Columns.add "Animation Clip" 150
		lv.Columns.add "Start" 50
		lv.Columns.add "End" 50
		
		local iniAsArray = (dotnetClass "System.IO.File").ReadAllLines theTempFile
		local theAnimationClipsArray = for n in iniAsArray where matchpattern n pattern:("[*]*") collect n
		
		for n in theAnimationClipsArray do
		(
			local theName = substring n 2 (n.count - 2)
			local theStart = getINIsetting theTempFile theName "Start"
			local theEnd = getINIsetting theTempFile theName "End"
			
			local newItem = dotNetObject "System.Windows.Forms.ListViewItem" theName
			newItem.subitems.add theStart
			newItem.subitems.add theEnd
			lv.items.add newItem
		)
		lv_to_ini()
	)
	
	fn prop_to_ini =
	(
		deleteFile theTempFile
		local theIndex = fileProperties.findProperty #custom "CLARA_ANIMATION_CLIPS_INI"
		if theIndex != 0 then
		(
			local theString = fileProperties.getPropertyValue #custom theIndex
			(dotnetClass "System.IO.File").WriteAllLines theTempFile #(theString)
		)
		else
		(
			(dotnetClass "System.IO.File").WriteAllLines theTempFile #("")
		)
	)
	
	on DLG_CLARA_ANIMATION_CLIP_MANAGER open do
	(
		prop_to_ini()
		fill_lv()
	)
	
	on createNewClipButton pressed do
	(
		if createAnimClipNameEditText != "" AND createAnimClipStartTimeSpinner.value != createAnimClipEndTimeSpinner.value do
		(
			setINIsetting theTempFile createAnimClipNameEditText.text "Start" (createAnimClipStartTimeSpinner.value as string)
			setINIsetting theTempFile createAnimClipNameEditText.text "End" (createAnimClipEndTimeSpinner.value as string)
			fill_lv()
		)
	)
	
	on delete_clipButton pressed do
	(
		--Clear temp file
		(dotnetClass "System.IO.File").WriteAllLines theTempFile #("")
		--Add only the ones that are not selected
		local SelectedNames = for i=0 to (lv.SelectedItems.count - 1) collect lv.SelectedItems.Item[i].subitems.Item[0].text
		for i=0 to (lv.Items.count - 1) where (finditem SelectedNames lv.Items.Item[i].subitems.Item[0].text) == 0 do
		(
			local theName = lv.Items.Item[i].subitems.Item[0].text
			local theStart = lv.Items.Item[i].subitems.Item[1].text
			local theEnd = lv.Items.Item[i].subitems.Item[2].text
			setINIsetting theTempFile theName "Start" theStart
			setINIsetting theTempFile theName "End" theEnd
			createAnimClipNameEditText.text = ""
		)
		--Fill LV
		fill_lv()
	)
	
	on DLG_CLARA_ANIMATION_CLIP_MANAGER close do
	(
		lv_to_ini()
		ini_to_prop()
		animationrange = PRE_OPEN_ANIMATIONRANGE
	)
	
	on lv mouseclick s e do
	(
		if e.Button == e.Button.left do
		(
			for i=0 to (lv.SelectedItems.count - 1) do
			(
				local theName = lv.SelectedItems.Item[i].subitems.Item[0].text
				local theStart = lv.SelectedItems.Item[i].subitems.Item[1].text
				local theEnd = lv.SelectedItems.Item[i].subitems.Item[2].text
				createAnimClipNameEditText.text = theName
				createAnimClipStartTimeSpinner.value = theStart as integer
				createAnimClipEndTimeSpinner.value = theEnd as integer
				if (theStart as integer) != (theEnd as integer) do
				(
					animationrange = interval (theStart as integer) (theEnd as integer)
				)
			)
		)
	)
)
createDialog DLG_CLARA_ANIMATION_CLIP_MANAGER width:300