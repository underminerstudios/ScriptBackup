/*
Gameloft Live Object Properties

What is it?
This dialog allows you to view/set the settings that are otherwise written manually in the object's User Defined Properties.

Details:
-"Selected" will show you the currently selected object's name
-"Keystring" will show you the keystrings that are currently set to the object. If you click them you'll see it's Value bellow the listbox. Other listboxes will be available depending on which keystring is selected.
-"Delete Keystring" will delete the currently selected keystring

-"Value" will show you the value of the selected keystring. By clicking on any of the listbox items the value will automatically be changed.
-"Type" will be available when the keystring "type" is selected. It will allow you to choose between two states.

-"Add Parameter" will add any of the provided parameters to the object. After adding it, you can change its value.
-"Open Parameter File" will open Windows Explorer and point you to the "GLL_paramters.ini" file. If it's not created, create it yourself and add the parameters you want for quick access in the tool.

-"Load Presets" will remove any data in the User Defined Properties and load a preset. The presets can easily be written in the "GLL_presets.ini"
-"Open Presets File" will open Windows Explorer and point you to the "GLL_presets.ini" file. If it's not created, create it yourself and add the presets you want for quick access in the tool.

-"Customizable" checkbox set if the selected node is customizable or not.

-"Animation Clips from Bdae" will look for a bdae in the following folder \data\3d\"currently open max file name"_boy.bdae
-"Select File" will allow you to pick another bdae to scan

-"Sound Files" is a list of sound files in \data\3d\"currently open max file name"\sounds"

-"BDAE files" is a list of bdae files found in 		\data\3d\"currently open max file name"

-"SlotAnimated Nodes" is a list of nodes in your scene called "SlotAnimated*"
-"Scene Animation Clips" is a list of animation clips stored by MaxGlitch


--NOTE: This scripts needs a GLL_user_properties_OSCfn.ms file.

Example "GLL_paramters.ini" file:
node
objectToTest
type
anim
other_node
other_anim
sound
soundDelay
soundLoop
Default


Example "GLL_presets.ini" file:
SlotAnim=Default,
AvatarTrigger=node:avatar,type,anim
#note: example above shows "node" the keystring, "avatar" its value.
EnvironmentTrigger=node,type,anim

*/
-- by Norman Schaar - norman.schaar@gameloft.com

----------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------

--kill or launch a dialog
fn KillAndLaunchDialog theRollout kill launch=
(
	if kill do try (	DestroyDialog theRollout; ) catch();
	if launch do createDialog theRollout	
)

--Get Animation Clips from BDAE. Returns an array with the animation clip names.
fn getAnimationClipsfromBDAE theFile=
(
	--The temp folder
	theOutputFolder = GetDir #userscripts + "\\temp\\"
	makedir theOutputFolder

	--Rename to Zip
	renameFile theFile (pathConfig.removePathLeaf(theFile) + getFileNameFile theFile + ".zip")
	--Unzip the file
	unmaz (pathConfig.removePathLeaf(theFile) + getFileNameFile theFile + ".zip") theOutputFolder
	--Rename the file back to bdae
	renameFile (pathConfig.removePathLeaf(theFile) + getFileNameFile theFile + ".zip") theFile

	--The XML
	theSource = getDir #userscripts + "\\temp\\source.dae"

	--Get the "animantion_clip"s
	theArray = #()
	theSourceText = (dotnetClass "System.IO.File").ReadAllLines theSource --Put file into array
	for i=1 to theSourceText.count do
	(
		if matchpattern theSourceText[i] pattern:"*<animation_clip id=*" do
		(
			if matchpattern (theSourceText[i - 1 - theArray.count]) pattern:"*<animation_clips>*" do
			(
				theString = (trimleft theSourceText[i])
				theString = substituteString theString ("<animation_clip id=" + "\"") ""
				theString = (filterstring theString "\"")[1]
				append theArray theString
			)
		)
	)

	--Clean up temp files
	for f in getFiles "$userscripts\\temp\\*.*" do
	(
		deleteFile f
	)
	
	return theArray
)

--Put all the key (user properties) of a node in an array
fn load_obj_properties theNode =
(
	theKeys = #()
	for n in (filterstring (getUserPropBuffer theNode) "\n") do
	(
		if (matchpattern n pattern:"Customisable*") == false do
		(
			append theKeys (trimRight (filterstring n "=")[1])
		)
	)
	return theKeys
)

--Read the User Defined Properties and returns "true" if the node is "Customisable"
fn isCustomizable theNode =
(
	theString = (getUserPropBuffer theNode)
	theArray = (filterstring theString "\n")
	theState = for n in theArray where n == "Customisable;" do exit with true
	return theState
)



----------------------------------------------------------------------------------------------
-- The rollout
----------------------------------------------------------------------------------------------

--Close the Dialog in case it was already opened in order to avoid duplicate instances of the dialog
KillAndLaunchDialog GLL_ObjectProperties true false

rollout GLL_ObjectProperties "Gameloft:Live Obj Properties" width:200 height:840
(
	--Selected node name
	label lbl_selected "Selected:" align:#left
	
	--Keystrin
	listbox lb_keys "Keystring:" height:6
	groupbox grp_value "Value" width:184 height:75 pos:[8,150]
	edittext edtxt_value enabled:false width:180 pos:[8,165]
	button btn_delete "Delete KeyString" height:25 width:180 enabled:false pos:[10,125]
	
	--Type
	groupbox grp_type_value "Type" width:175 height:35 pos:[13,185]
	radiobuttons rb_type_value labels:#("normal", "3state") pos:[15,200] enabled:false
	
	--Add parameter
	label lbl_add_param "Add Parameter:" pos:[8,237]
	dropdownlist ddl_add_param enabled:false pos:[100,235] width:92
	button btn_param_file "Open Parameter List File" width:180 pos:[10,260]
	
	--Presets
	label lbl_presets "Load Presets:" pos:[8,290]
	dropdownlist ddl_presets enabled:false pos:[100,288] width:92
	button brn_presets_file "Open Presets File" width:180 pos:[10,310]
	
	--Is customizable?
	checkbox chb_customisable "Customizable" checked:false
	
	--Animation clips from Bdae
	groupbox grp_box "Animation clips from BDAE" width:184 height:120 pos:[8,355]
	label lbl_animclips "No file found." pos:[14,370] align:#left
	button btn_select "Select File" align:#right pos:[12,385] width:175
	listbox lb_animclips pos:[12,410] height:4 enabled:false
	
	--Sound files
	groupbox grp_sound "Sound Files" width:184 height:90 pos:[8,475]
	listbox lb_soundfiles height:5 pos:[12,490] enabled:false
	
	--Bdae files
	groupbox grp_bdaes "BDAE Files" width:184 height:90 pos:[8,565]
	listbox lb_bdaes height:5 pos:[12,580] enabled:false
	
	--Slot Animated Nodes
	groupbox grp_slot_animated "SlotAnimated Nodes" width:184 height:90 pos:[8,655]
	listbox lb_slot_animated height:5 pos:[12,670] enabled:false
	
	--Scene Animation Clips
	groupbox grp_scene_anim_clips "Scene Animation Clips" width:184 height:90 pos:[8,745]
	listbox lb_scene_anim_clips height:5 pos:[12,760] enabled:false
	
----------------------------------------------------------------------------------------------
-- Event handlers
----------------------------------------------------------------------------------------------

	--On opening the dialog
	on GLL_ObjectProperties open do
	(
	
		--We clear the selection in order to avoid having to refresh all the parameters. User will simple have to pick a node after this.
		clearSelection()
		
		--Load the Gameloft Live Parameters from the list
		theGLLParamFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\GLL_paramters.ini"
		if doesFileExist theGLLParamFile do
		(
			ddl_add_param.items = (dotnetClass "System.IO.File").ReadAllLines theGLLParamFile
		)
		
		--Load the Gameloft Live Presets from the list
		theGLLPresetsFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\GLL_presets.ini"
		if doesFileExist theGLLPresetsFile do
		(
			thePresets = #()
			theText = (dotnetClass "System.IO.File").ReadAllLines theGLLPresetsFile
			for n in theText do
			(
				append thePresets ((filterstring n "=")[1])
			)
			ddl_presets.items = thePresets
		)
		
		--Find BDAE file
		thePath = maxFilePath
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = thePath + "\\data\\3d\\" + (getfileNameFile maxfilename) + "\\" + (getfileNameFile maxfilename) + "_boy.bdae"
		
		if doesFileExist thePath do
		(
			lbl_animclips.text = "\"" + (getfileNameFile maxfilename) + "_boy.bdae" + "\""
			lb_animclips.items = (getAnimationClipsfromBDAE thePath)
		)
		
		--Load sound Files
		thePath = maxFilePath
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = thePath + "\\data\\3d\\" + (getFileNameFile maxfilename) + "\\sounds"

		lb_soundfiles.items = for f in getFiles (thePath + "\\*.*") collect (getFileNameFile f + getFileNameType f)
		
		--Find BDAE files
		thePath = maxFilePath
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = thePath + "\\data\\3d\\" + (getFileNameFile maxfilename)

		lb_bdaes.items = for f in getFiles (thePath + "\\*.bdae") collect (getFileNameFile f + getFileNameType f)
		
		--The slot animated nodes in the scene
		theSlotAnimatedNodes = #("avatar")
		for i in $* where (matchpattern i.name pattern:"SlotAnimated*") == true do (append theSlotAnimatedNodes i.name)
		lb_slot_animated.items = theSlotAnimatedNodes
		
		--Load the Scene animation clips (uses MaxGlitch API)
		lb_scene_anim_clips.items = for i=1 to (CM_GetNumAnimationClips()) collect (CM_GetAnimationClipName i)
		
		--listbox selections to 0. Per default they are set to 1
		lb_keys.selection = 0
		lb_bdaes.selection = 0
		lb_soundfiles.selection = 0
		lb_animclips.selection = 0
		lb_slot_animated.selection = 0
		lb_scene_anim_clips.selection = 0
		rb_type_value.state = 0
			
		theFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\fn\\GLL_user_properties_OSCfn.ms"
		filein theFile
	)
	
	--On close of the dialog remove the on selection changed callback
	on GLL_ObjectProperties close do
	(
		callbacks.removeScripts id:#GLL_ObjectProperties
	)
	
	--On keystring listbox clicked do
	on lb_keys selected arg do
	(
		--Reset the UI
		lb_animclips.selection = 0
		lb_soundfiles.selection = 0
		lb_bdaes.selection = 0
		lb_slot_animated.selection = 0
		lb_scene_anim_clips.selection = 0
		--Disable elements
		lb_soundfiles.enabled = false
		lb_slot_animated.enabled = false
		lb_slot_animated.enabled = false
		lb_bdaes.enabled = false
		lb_animclips.enabled = false
		lb_scene_anim_clips.enabled = false
		lb_scene_anim_clips.enabled = false
		rb_type_value.enabled = false
		
		
		--get the value of the keystring and put it in the edittext
		theText = getUserProp selection[1] (lb_keys.items[arg])
		if matchpattern theText pattern:"*;" do
		(
			theText = trimRight theText ";"
		)
		edtxt_value.text = theText
		edtxt_value.enabled = true

		--"Sound" selected, allow to pick from the sound files
		if lb_keys.items[arg] == "sound" AND lb_soundfiles.items.count != 0 do
		(
			lb_soundfiles.enabled = true
			for i=1 to lb_soundfiles.items.count do
			(
				if lb_soundfiles.items[i] == edtxt_value.text do
				(
					lb_soundfiles.selection = i
				)
			)
		)
		
		--"node", "other_node" or "objectToTest" selected, allow to pick slotanimated nodes
		if lb_keys.items[arg] == "node" OR lb_keys.items[arg] == "other_node" OR lb_keys.items[arg] == "objectToTest" do
		(
			lb_slot_animated.enabled = true
			for i=1 to lb_slot_animated.items.count do
			(
				if lb_slot_animated.items[i] == edtxt_value.text do
				(
					lb_slot_animated.selection = i
				)
			)
		)
		
		--"Default" selected, pick bdaes
		if lb_keys.items[arg] == "Default" do
		(
			lb_bdaes.enabled = true
			for i=1 to lb_bdaes.items.count do
			(
				if lb_bdaes.items[i] == edtxt_value.text do
				(
					lb_bdaes.selection = i
				)
			)
		)
		
		--"anim" selected, pick animation clips in bdae and animation clips in scene
		if lb_keys.items[arg] == "anim" do
		(
			lb_animclips.enabled = true
			lb_scene_anim_clips.enabled = true
			for i=1 to lb_scene_anim_clips.items.count do
			(
				if lb_scene_anim_clips.items[i] == edtxt_value.text do
				(
					lb_scene_anim_clips.selection = i
				)
			)
			for i=1 to lb_animclips.items.count do
			(
				if lb_animclips.items[i] == edtxt_value.text do
				(
					lb_animclips.selection = i
				)
			)
		)
		
		
		--"other_anim" selected, pick scene animation clips
		if lb_keys.items[arg] == "other_anim" do
		(
			lb_scene_anim_clips.enabled = true
			for i=1 to lb_scene_anim_clips.items.count do
			(
				if lb_scene_anim_clips.items[i] == edtxt_value.text do
				(
					lb_scene_anim_clips.selection = i
				)
			)
		)
		
		--"type" selected, enable radiobuttons
		if lb_keys.items[arg] == "type" do
		(
			rb_type_value.enabled = true
			if edtxt_value.text == "normal" do
			(
				rb_type_value.state = 1
			)
			if edtxt_value.text == "3state" do
			(
				rb_type_value.state = 2
			)
		)
	)
	
	--Save the value when changed in the edittext
	on edtxt_value changed arg do
	(
		setUserProp selection[1] lb_keys.selected (arg + ";")
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
	)
	
	--Delete Keystring, deletes the keystring from the User Defined Properties
	on btn_delete pressed do
	(
		thePropBuffer =#()
		thePropBuffer = filterstring (getUserPropBuffer selection[1]) "\n"
		
		theNewPropBuffer = #()
		for n in thePropBuffer do
		(
			thePattern1= ((lb_keys.items[lb_keys.selection]) + "=*")
			thePattern2 = ((lb_keys.items[lb_keys.selection]) + " =*")
			
			thePattern1Found = undefined
			thePattern2Found = undefined
			if (matchpattern n pattern:thePattern1) == true do
			(
				thePattern1Found = true
			)
			if (matchpattern n pattern:thePattern2) == true do
			(
				thePattern2Found = true
			)
			if thePattern1Found != true AND thePattern2Found != true do
			(
				append theNewPropBuffer n
			)
		)
		
		thePropBufferString = ""
		for i=1 to theNewPropBuffer.count do
		(
			thePropBufferString = append thePropBufferString theNewPropBuffer[i]
			thePropBufferString = append thePropBufferString "\n"
		)
		setUserPropBuffer  selection[1] thePropBufferString
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
		
		lb_keys.items = load_obj_properties selection[1]
		edtxt_value.text = ""
	)
	
	--Adding a parameter from the drop down list
	on ddl_add_param selected arg do
	(
		if selection.count == 1 do
		(
			doesItExist = for n in lb_keys.items where (n == ddl_add_param.items[arg]) do exit with true
			if doesItExist != true then
			(
				setUserProp selection[1] ddl_add_param.items[arg] ";"
				setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
				GLL_ObjectProperties.lb_keys.items = load_obj_properties (selection)[1]
				GLL_ObjectProperties.edtxt_value.text = ""
				if ddl_add_param.items[arg] == "soundLoop" do
				(
					setUserProp selection[1] "soundLoop" "true;"
					setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
				)
			)
			else
			(
				messagebox "A Keystring with this name already exists!"
			)
			lb_keys.selection = 0
		)
	)
	
	--Open windows explorer and select the GLL_parameters.ini
	on btn_param_file pressed do
	(
		theGLLParamFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\GLL_paramters.ini"
		if doesFileExist theGLLParamFile then
		(
			shellLaunch "explorer.exe" ("/e,/select," + "\"" + theGLLParamFile + "\"")
		)
		else
		(
			messagebox "The file doens't exist yet. Create a file called GLL_paramters.ini"
			shellLaunch "explorer.exe" ("\"" + getDir #userscripts + "\"")
		)
	)
	
	--Load a preset and overwrite User Defined Properties
	on ddl_presets selected arg do
	(
		if selection.count == 1 do
		(
			if querybox "You are about to load a preset. All User Defined Properties will be reset. Are you sure you want to continue?" == true do
			(
				setUserPropBuffer selection[1] ""
				theGLLPresetsFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\GLL_presets.ini"
				theText = (dotnetClass "System.IO.File").ReadAllLines theGLLPresetsFile
				theString = for n in TheText where ((filterstring n "=")[1]) == (ddl_presets.items[arg])  do exit with ((filterstring n "=")[2])
				theTextArray = filterstring theString ","
				for n in theTextArray do
				(
					theValue = filterstring n ":"
					if theValue.count == 1 then
					(
						setUserProp selection[1] theValue[1] ";"
						setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
					)
					else
					(
						setUserProp selection[1] theValue[1] theValue[2]
						setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
					)
				)
				lb_keys.items = load_obj_properties (selection[1])
				edtxt_value.enabled = false
				lb_keys.selection = 0
			)
		)
	)
	
	--Open windows explorer and select the GLL_Presets.ini
	on brn_presets_file pressed do
	(
		theGLLPresetsFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\GLL_presets.ini"
		if doesFileExist theGLLPresetsFile then
		(
			shellLaunch "explorer.exe" ("/e,/select," + "\"" + theGLLPresetsFile + "\"")
		)
		else
		(
			messagebox "The file doens't exist yet. Create a file called GLL_Presets.ini"
			shellLaunch "explorer.exe" ("\"" + getDir #userscripts + "\"")
		)
	)
	
	--"Customizable" checkbox will add or remove "Customisable" from UDP
	on chb_customisable changed theState do
	(
		if theState == true then
		(
			--Change it to true, we need to add a "Customisable;" to the PropBuffer
			theString = (getUserPropBuffer selection[1])
			theString = append theString ("\n" + "Customisable;")
			setUserPropBuffer selection[1] theString
			setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
		)
		else
		(
			--Now we change it to false
			theString = substitutestring (getUserPropBuffer selection[1]) "Customisable;" ""
			setUserPropBuffer selection[1] theString
			setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
		)
	)
	
	--Select File button will open a Dotnet OpenFileDialog and let you pick a bdae file to scan for animation clips
	on btn_select pressed do
	(
		theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Choose Bdae file" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "BDAE files (*.bdae)|*.bdae" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		result = theDialog.showDialog() --display the dialog, get result into variable
		test = result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
		for f in theFilenames do
		(
			lbl_animclips.text = "\"" + (getfileNameFile f) + (getFileNameType f) + "\""
			lb_animclips.items = (getAnimationClipsfromBDAE f)
		)
	)
	
	--Animation clips listbox	
	on lb_animclips selected arg do 
	(
		edtxt_value.text = lb_animclips.items[arg]
		setUserProp selection[1] lb_keys.selected (lb_animclips.items[arg] + ";")
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
	)
	
	--Soundfiles listbox
	on lb_soundfiles selected arg do
	(
		edtxt_value.text = lb_soundfiles.items[arg]
		setUserProp selection[1] lb_keys.selected (lb_soundfiles.items[arg] + ";")
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
	)
	
	--bdae files listbox
	on lb_bdaes selected arg do
	(
		edtxt_value.text = lb_bdaes.items[arg]
		setUserProp selection[1] lb_keys.selected (lb_bdaes.items[arg] + ";")
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
	)
	
	--Animated slot nodes listbox
	on lb_slot_animated selected arg do
	(
		edtxt_value.text = lb_slot_animated.items[arg]
		setUserProp selection[1] lb_keys.selected (lb_slot_animated.items[arg] + ";")
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
	)
	
	--Scene animclips listbox
	on lb_scene_anim_clips selected arg do
	(
		edtxt_value.text = lb_scene_anim_clips.items[arg]
		setUserProp selection[1] lb_keys.selected (lb_scene_anim_clips.items[arg] + ";")
		setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
	)
	
	--Type Radiobuttons
	on rb_type_value changed theState do
	(
		if theState == 1 do
		(
			setUserProp selection[1] lb_keys.selected "normal;"
			setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
			edtxt_value.text = "normal"
		)
		if theState == 2 do
		(
			setUserProp selection[1] lb_keys.selected "3state;"
			setUserPropBuffer selection[1] (substitutestring (getUserPropBuffer selection[1]) " " "")
			edtxt_value.text = "3state"
		)
	)
)
createDialog GLL_ObjectProperties