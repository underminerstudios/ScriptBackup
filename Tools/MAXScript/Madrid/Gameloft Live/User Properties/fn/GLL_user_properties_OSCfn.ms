/*
This is a On selection changed callback for GLL_user_properties.ms
It needs to be on a separate ms file.
*/
-- by Norman Schaar - norman.schaar@gameloft.com

--On "selection Changed" callback function. This will "reset" the UI.
fn onSelectionChanged =
(
	GLL_ObjectProperties.lb_animclips.enabled = false
	GLL_ObjectProperties.lb_animclips.selection = 0
	GLL_ObjectProperties.lb_soundfiles.enabled = false
	GLL_ObjectProperties.lb_soundfiles.selection = 0
	GLL_ObjectProperties.lb_slot_animated.enabled = false
	GLL_ObjectProperties.lb_slot_animated.selection = 0
	GLL_ObjectProperties.lb_bdaes.enabled = false
	GLL_ObjectProperties.lb_bdaes.selection = 0
	GLL_ObjectProperties.lb_scene_anim_clips.enabled = false
	GLL_ObjectProperties.lb_scene_anim_clips.selection = 0
	GLL_ObjectProperties.edtxt_value.enabled = false

	if selection.count == 1 then
	(
		--Remove "\n" in User Defined Properties.
		theBuffer_no_enter = for n in (filterstring (getUserPropBuffer selection[1]) "\n") where (matchpattern n pattern:"*=*") == true OR (matchpattern n pattern:"Customisable;") == true collect n
		theString = ""
		for n in theBuffer_no_enter do (append theString (n + "\n"))
		setUserPropBuffer selection[1] theString
		
		--Add a "\n" at the end of the User Prop Buffer if not found
		theBuffer = getUserPropBuffer selection[1]
		if theBuffer[theBuffer.count] != "\n" do (	setUserPropBuffer selection[1] (theBuffer + "\n"))
			
		--Remove " "
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
			
		GLL_ObjectProperties.lb_keys.items = load_obj_properties (selection)[1]
		GLL_ObjectProperties.lbl_selected.text = "Selected: " + ((selection)[1]).name
		GLL_ObjectProperties.edtxt_value.text = ""
		GLL_ObjectProperties.btn_delete.enabled = true
		GLL_ObjectProperties.ddl_add_param.enabled = true
		GLL_ObjectProperties.ddl_presets.enabled = true
		GLL_ObjectProperties.lb_keys.enabled = true
		GLL_ObjectProperties.chb_customisable.enabled = true
		GLL_ObjectProperties.lb_keys.selection = 0
		GLL_ObjectProperties.lb_bdaes.selection = 0
		GLL_ObjectProperties.lb_soundfiles.selection = 0
		GLL_ObjectProperties.lb_animclips.selection = 0
		
		if (isCustomizable selection[1]) == true then
		(
			GLL_ObjectProperties.chb_customisable.checked = true
		)
		else
		(
			GLL_ObjectProperties.chb_customisable.checked = false
		)
	)
	else
	(
		GLL_ObjectProperties.btn_delete.enabled = false
		GLL_ObjectProperties.ddl_add_param.enabled = false
		GLL_ObjectProperties.ddl_presets.enabled = false
		GLL_ObjectProperties.lb_keys.enabled = false
		GLL_ObjectProperties.edtxt_value.text = ""
		GLL_ObjectProperties.lb_keys.items = #()
		GLL_ObjectProperties.chb_customisable.enabled = false
		GLL_ObjectProperties.chb_customisable.checked = false
	)
)

--Call back script that will run the "onSelectionChanged" function after the selection has changed in order to update the UI
callbacks.removeScripts id:#GLL_ObjectProperties
callbacks.addScript #selectionSetChanged "onSelectionChanged()" id:#GLL_ObjectProperties