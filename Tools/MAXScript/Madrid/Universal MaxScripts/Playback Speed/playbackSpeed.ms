/*
	Playback Speed

	Script to change the playback speed and turn inPlaceMode on and off
*/
--by Norman Schaar - norman.schaar@gameloft.com

try
(
	cui.UnRegisterDialogBar anim_change_speed
	destroyDialog anim_change_speed
)catch()


rollout anim_change_speed ""
(
	radiobuttons rb_speed labels:#("1/4x", "1/2x", "1x", "2x", "4x")
	button btn_inPlaceMode "In Place Mode"

	on rb_speed changed theState do
	(
		if (isAnimPlaying()) == true then
		(
			stopAnimation()
			timeConfiguration.playbackSpeed = theState
			playAnimation immediateReturn:true
		)
		else
		(
			timeConfiguration.playbackSpeed = theState
		)
	)
	
	on btn_inPlaceMode pressed do
	(
		for b in objects do
		(
			if (classof b) == Biped_Object do
			(
				try
				(
					biped_ctrl = b.transform.controller
					if biped_ctrl.inPlaceMode == false then
					(
						biped_ctrl.inPlaceMode = true
					)
					else
					(
						biped_ctrl.inPlaceMode = false
					)
				)catch()
			)
		)
	)
	
	on anim_change_speed open do
	(
		cui.RegisterDialogBar anim_change_speed minSize:[90,110] maxSize:[90,110] style:#(#cui_dock_all,#cui_floatable,#cui_handles)
		rb_speed.state = timeConfiguration.playbackSpeed
	)
)
createDialog anim_change_speed width:90 height:110