try(destroyDialog dlg_camera_cycle_playback)catch()
rollout dlg_camera_cycle_playback "Camera Cycle Playback"
(
	local theCameras = for n in cameras where superclassof n == camera collect n
	
	multilistbox mlb_cameras "Select Cameras:" items:(for n in theCameras collect n.name)
	button btn_play "Play"
	
	on btn_play pressed do
	(
		local storeLoop = timeConfiguration.PlaybackLoop
		timeConfiguration.PlaybackLoop = false
		for n in mlb_cameras.selection do
		(
			viewport.setCamera theCameras[n]
			max time play
		)
		timeConfiguration.PlaybackLoop = storeLoop
	)
	
)
createDialog dlg_camera_cycle_playback

