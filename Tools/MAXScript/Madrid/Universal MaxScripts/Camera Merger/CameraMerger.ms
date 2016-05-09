/*
	Camera Merger
	
	This script will allow you to merge animation of multiple cameras along the active timerange into a new camera.
	
	- The user needs to specify a camera from the dropdownlist for each frame
	- Clicking on "Create Camera" button will create the final camera.

*/
--by Norman Schaar - Norman.schaar@gameloft.com
try(destroyDialog DLG_CAMERA_MERGER)catch()
rollout DLG_CAMERA_MERGER "Camera Merger"
(
	local theCameras = for n in cameras where (classof n == Targetcamera OR classof n == freecamera) collect n
	local AnimationStart = ((animationRange.start as integer)/ticksperframe)
	local AnimationEnd = ((animationRange.end as integer)/ticksperframe)
	local theCamerasAssignedFrames = for i=AnimationStart to AnimationEnd collect ""
	local theFrames = for i=AnimationStart to AnimationEnd collect i
	

	dotNetControl lv "ListView" width:200 height:510 align:#center pos:[0,0]
	dropdownlist ddl_cameras "Cameras:"
	button btn_create_camera "Create Camera" width:150
	
	fn fill_lv =
	(
		lv.clear()
		
		lv.View = (dotNetClass "System.Windows.Forms.View").Details  
		lv.fullRowSelect = true  
		lv.Columns.add "Frame" 50
		lv.Columns.add "Camera" 150
		
		for i=AnimationStart to AnimationEnd do
		(
			local newItem = dotNetObject "System.Windows.Forms.ListViewItem" (i as string)
			newItem.subitems.add ""
			lv.items.add newItem
		)
	)
		
	fn findInterval startIndex theArray =
	(
		local theIndexes = #()
		for i=startIndex to theArray.count do
		(
			if theArray[i] == theArray[startIndex] then
			(
				append theIndexes i
			)
			else
			(
				return #(startIndex - 1,theIndexes[theIndexes.count] - 1)
			)
		)
		return #(startIndex - 1,theIndexes[theIndexes.count] - 1)
	)

	fn GET_INTERVALS theArray =
	(
		local theIntervalArray = #()
		local theIndexArray = #(1)
		local theValue = theArray[1]
		for i=1 to theArray.count do
		(
			if (theArray[i] as string) != (theValue as string) do
			(
				append theIndexArray i
			)
			theValue = theArray[i]
		)

		for n in theIndexArray do
		(
			local TheInterval = findInterval n theArray
			append theIntervalArray theInterval
		)
		
		theIntervalArray
	)
	
	fn Transfer_Keys node1 node2 interval=
	(
		local theXafFile = "$userscripts\\temp.xaf"
		local theXMNfile = "$userscripts\\temp.xmn"
		LoadSaveAnimation.saveAnimation theXafFile #(node1) #() #() animatedTracks:true includeConstraints:true keyableTracks:false saveSegment:true segInterval:interval segKeyPerFrame:true
		LoadSaveAnimation.createMapFile theXMNfile #(node2) theXafFile #() #() #() nodeMapType:#matchClosestNodeName matchControllerExactName:true matchControllerType:false stripLayers:false
		LoadSaveAnimation.loadAnimation theXafFile #(node2) relative:false insert:true insertTime:interval.start stripLayers:false useMapFile:true mapFileName:theXMNfile
		deleteFile theXafFile
		deleteFile theXMNfile
	)
	
	on ddl_cameras selected arg do
	(
		local theArray = for x=0 to lv.selectedIndices.count-1 collect lv.selectedIndices.item[x]
		for n in theArray do
		(
			theCamerasAssignedFrames[n+1] = theCameras[arg]
			lv.items.Item[n].subItems.Item[1].Text = ddl_cameras.items[arg]
		)
	)
	
	on DLG_CAMERA_MERGER open do
	(
		fill_lv()
		ddl_cameras.items = for n in theCameras collect n.name
		ddl_cameras.selection = 0
	)
	
	on btn_create_camera pressed do
	(
		local CurrentStatus = finditem theCamerasAssignedFrames ""
		if CurrentStatus == 0 then
		(
			local theResult = GET_INTERVALS theCamerasAssignedFrames
			
			local theNewCamera = freecamera()
			for n in theResult do
			(
				local theOldCamera = theCamerasAssignedFrames[n[1] + 1]
				local theStartingFrame = lv.items.Item[n[1]].Text as time
				local theEndingFrame = lv.Items.Item[n[2]].Text as time
				local theInterval = interval theStartingFrame theEndingFrame
				Transfer_Keys theOldCamera theNewCamera theInterval
				
			)
			select theNewCamera
		)
		else
		(
			messagebox "ERROR: There is one ore more frames without a camera assigned!"
		)
	)
	
)
createDialog DLG_CAMERA_MERGER width:200 height:600
