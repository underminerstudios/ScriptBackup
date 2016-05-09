try(destroyDialog DLG_ANIMATION_CLIP_EXPORTER)catch()
rollout DLG_ANIMATION_CLIP_EXPORTER "Animation Clip Exporter"
(
	local theTempFile = getFilenamePath (getSourceFileName()) + "\\temp.ini"
	
	group "Options"
	(
		edittext et_exportPath "Export Path:" labelontop:true align:#left readonly:true width:240
		button btn_exportPathBrowse "..." pos:[260,40]
	)
		
	group "Animation Clips"
	(
		dotNetControl lv "ListView" width:280 height:200 align:#center
	)
	
	button btn_export "Export" width:150 height:30 align:#center
	
	fn fn_IrrColladaExporter_AUTO =
	(
		local hWND = DialogMonitorOPS.GetWindowHandle()
		if ((UIAccessor.GetWindowText hWND) == "ColladaMax Export") do
		(
			UIAccessor.PressButtonByName hWND "..."
			UIAccessor.PressButtonByName hWND "OK"
		)
		if ((UIAccessor.GetWindowText hWND) == "Batch Export Option String") do
		(
			local theListboxes = for n in windows.getChildrenHwnd hWND where n[4] == "ListBox" collect n[1]
			windows.SendMessage theListboxes[1] (LB_SETCURSEL = 0x00000186) (wparam = 0x00000001) (lparam = 0x00000000)
			UIAccessor.PressButtonByName hWND "OK"
		)
		return true
	)
	
	on btn_export pressed do
	(
		local SelectedNames = for i=0 to (lv.SelectedItems.count - 1) collect lv.SelectedItems.Item[i].subitems.Item[0].text
		local theSelection = selection as array
		
		if SelectedNames.count != 0 AND theSelection.count != 0 AND doesFileExist et_exportPath.text then
		(
			with undo off with redraw off
			(
				local CurrentTimeRange = animationrange
				for i=0 to (lv.SelectedItems.count - 1) do
				(
					local DAE_NAME = lv.SelectedItems.Item[i].subitems.Item[0].text + ".dae"
					local NewTimeStart = lv.SelectedItems.Item[i].subitems.Item[1].text as integer
					local NewTimeEnd = lv.SelectedItems.Item[i].subitems.Item[2].text as integer
					local NewAnimationRange = interval NewTimeStart NewTimeEnd
					animationrange = NewAnimationRange
					local theFile = (et_exportPath.text + "\\" + DAE_NAME)
					deleteFile theFile
					DialogMonitorOPS.Enabled = true 
					DialogMonitorOPS.RegisterNotification fn_IrrColladaExporter_AUTO id:#IrrColladaExporter_AUTO
					DialogMonitorOPS.Interactive=false
					exportFile theFile selectedOnly:true using:IrrColladaExporter
					DialogMonitorOPS.unRegisterNotification id:#IrrColladaExporter_AUTO
					DialogMonitorOPS.Enabled = false
				)
				animationrange = CurrentTimeRange
			)
		)
		else
		(
			if doesFileExist et_exportPath.text == false do (messagebox "ERROR: The Output Path does not exist!") 
			if theSelection.count == 0 do (messagebox "ERROR: You have to select objects in the scene in order to export!")
			if SelectedNames.count == 0 do (messagebox "ERROR: You have to select the Animation Clips you want to export!")
		)
	)
	
	on btn_exportPathBrowse pressed do
	(
		local theResult = getSavepath caption:"Select Export Folder" initialDir:(maxfilepath)
		if theResult != undefined do (et_exportPath.text = theResult)
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
	)
	
	on DLG_ANIMATION_CLIP_EXPORTER open do
	(
		prop_to_ini()
		fill_lv()
		deleteFile theTempFile
	)
	
)
createDialog DLG_ANIMATION_CLIP_EXPORTER width:300 height:340