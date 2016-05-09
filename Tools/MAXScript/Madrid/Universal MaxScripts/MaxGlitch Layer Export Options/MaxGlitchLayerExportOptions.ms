/*
	This script will allow you to batch export multiple layers.

	In the Layers listbox you will be able to select single layers and change their settings.
	In order to export the layers, select the ones you want to export and hit the "export!" button.

	-The Settings:

		-Preset: For each layer you'll be able to pick a preset. The presets are stored in the MaxGlitch.config file, and can be different for each project.
		-Animation Clips: You will be able to assign one or multiple animation clips for each layer. Simply select them.
		-Export Filename: Is the path to the BDAE file. Each layer will need an export filename.
		-Export Always: If turned ON, the elements inside this layer will be exported with any of the selected layers upon export.
		
	The settings will be saved in the max scene. Just make sure to save the max scene after changing the settings if you want to preserve them!
	
*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog MaxGlitch_Layer_Export_Options)catch()
fn MaxGlitch_Layer_Export_Options_close =
(
	try(destroyDialog MaxGlitch_Layer_Export_Options)catch()
)


rollout MaxGlitch_Layer_Export_Options "MaxGlitch Layer Export Options"
(
	multilistbox mlb_layers "Layers:" width:200 height:30 pos:[10,10]
	listbox lb_presets "Presets:" pos:[220,50] width:200 height:10 enabled:false
	multilistbox mlb_animationclips "Animation Clips:" pos:[220,210] width:200 height:6 enabled:false
	label lbl_export_filename "Export Filename:" pos:[220,315]
	edittext et_export_filename "" pos:[217,330] width:170 readonly:true
	button btn_browse "..." pos:[390,328] width:30 enabled:false
	checkbox cb_export_always "Export Always" pos:[220,360] enabled:false
	button btn_export "Export!" width:200 height:30 pos:[220,400]
	local INI_OPTIONS = getDir #userscripts + "\\MaxGlitchLayerExportOptions.ini"
	
	--Fill layers
	fn fill_mlb_layers =
	(
		--List all layers but the default layer
		mlb_layers.items = sort (for i=1 to (LayerManager.count - 1) collect ((LayerManager.getLayer i).name))
	)
	
	
	--Fill Presets
	fn fill_dll_Presets =
	(
		lb_presets.items = for i=1 to (try(CM_PSC_GetExportPresetCount())catch(CM_PSC_GetExportOptionPresetCount())) collect (try(CM_PSC_GetExportPresetName i)catch(CM_PSC_GetExportOptionPresetName i))
		lb_presets.selection = 0
	)
	
	--Fill Animation Clips
	fn fill_mlb_animationclips =
	(
		mlb_animationclips.items = sort(for i=1 to (CM_GetNumAnimationClips()) collect (CM_GetAnimationClipName i))
	)
	
	--Dump properties to file
	fn mlb_layers_properties_load =
	(
		local textIndex = fileProperties.findProperty #custom "MaxGlitchLayerExportOptions"
		if textIndex != 0 do
		(
			local INI_OPTIONS = getDir #userscripts + "\\MaxGlitchLayerExportOptions.ini"
			if doesFileExist INI_OPTIONS do deletefile INI_OPTIONS
			local theString = fileProperties.getPropertyValue #custom textIndex
			local theArray = filterString theString "\n"
			(dotnetClass "System.IO.File").WriteAllLines INI_OPTIONS theArray
		)
	)
	
	--Save file to property
	fn mlb_layers_properties_save =
	(
		local INI_OPTIONS = getDir #userscripts + "\\MaxGlitchLayerExportOptions.ini"
		if doesFileExist INI_OPTIONS do
		(
			local theString = (dotnetClass "System.IO.File").ReadAllText INI_OPTIONS
			fileProperties.addProperty #custom "MaxGlitchLayerExportOptions" theString
		)
	)
	
	--On layers click
	on mlb_layers selectionEnd do
	(
		--Reset values
		lb_presets.enabled = true
		mlb_animationclips.enabled = true
		btn_browse.enabled = true
		cb_export_always.enabled = true
		lb_presets.selection = 0
		et_export_filename.text = ""
		cb_export_always.state = false
		mlb_animationclips.selection = 0
		
		local theSelection = ((mlb_layers.selection) as array)

		--If we select a single layer, allow to change options
		if theSelection.count == 1 then
		(
			local theLayer = undefined
			theLayer = mlb_layers.items[theSelection[1]]

			--Vars
			local thePresetName = getINIsetting INI_OPTIONS theLayer "Preset"
			local theExportFile = getINIsetting INI_OPTIONS theLayer "ExportFile"
			local theExportAlwaysOption = getINIsetting INI_OPTIONS theLayer "ExportAlways"
			local theAnimationClips = getINIsetting INI_OPTIONS theLayer "AnimationClips"
			
			--Load Preset
			if thePresetName != "" do
			(
				theIndexArray = undefined
				theIndexArray = for i=1 to lb_presets.items.count where lb_presets.items[i]==thePresetName do exit with i
				if theIndexArray != undefined do
				(
					lb_presets.selection = theIndexArray
				)
			)
			
			--Load Animation Clips
			if theAnimationClips != "" do
			(
				theAnimationClipsArray = execute(theAnimationClips)
				theIndexes = #()
				for n in theAnimationClipsArray do
				(
					for i=1 to mlb_animationclips.items.count do
					(
						if mlb_animationclips.items[i]==n do
						(
							append theIndexes i
						)
					)
				)
				mlb_animationclips.selection = theIndexes
			)
			
			--Load Export File
			if theExportFile != "" do
			(
				et_export_filename.text = theExportFile
			)
			
			--Load "Export Always" option
			if theExportAlwaysOption == "true" do
			(
				cb_export_always.state = true
			)
		)
		--Disalbe the option to export
		else
		(
			lb_presets.enabled = false
			mlb_animationclips.enabled = false
			btn_browse.enabled = false
			cb_export_always.enabled = false
		)
	)
	
	on lb_presets selected arg do
	(
		theLayer = (mlb_layers.selection as array)[1]
		theLayer = mlb_layers.items[theLayer]
		thePresetName = lb_presets.selected

		setINIsetting INI_OPTIONS theLayer "Preset" thePresetName
		mlb_layers_properties_save()
	)
	
	
	--On selecting Animation clips
	on mlb_animationclips selectionEnd do
	(
		theSelectionIndexes = (mlb_animationclips.selection as array)
		theSelectionNames = for n in theSelectionIndexes collect mlb_animationclips.items[n]
			
		theLayer = (mlb_layers.selection as array)[1]
		theLayer = mlb_layers.items[theLayer]

		setINIsetting INI_OPTIONS theLayer "AnimationClips" (theSelectionNames as string)
		mlb_layers_properties_save()
	)
	
	--On pressing "browse"
	on btn_browse pressed do
	(
		--Select save file
		theSaveDialog = dotNetObject "System.Windows.Forms.SaveFileDialog" --create a OpenFileDialog 
		theSaveDialog.title = "Save BDAE file" --set the title
		theSaveDialog.Filter = "BDAE files (*.bdae)|*.bdae" --specify the filter
		theSaveDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		result = theSaveDialog.showDialog() --display the dialog, get result into variable
		test = result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		theFilenames = theSaveDialog.fileNames --the selected filenames will be returned as an array
		
		if theFilenames.count == 1 do
		(
			et_export_filename.text = theFilenames[1]
			
			theLayer = (mlb_layers.selection as array)[1]
			theLayer = mlb_layers.items[theLayer]
			
			setINIsetting INI_OPTIONS theLayer "ExportFile" theFilenames[1]
			mlb_layers_properties_save()
		)
	)
	
	
	--On clicking on the "export always" checkbox
	on cb_export_always changed theState do
	(
		theLayer = (mlb_layers.selection as array)[1]
		theLayer = mlb_layers.items[theLayer]

		setINIsetting INI_OPTIONS theLayer "ExportAlways" (theState as string)
		mlb_layers_properties_save()
	)
	
	

	on MaxGlitch_Layer_Export_Options open do
	(
		callbacks.removeScripts id:#MGLEOC
		callbacks.addScript #filePreOpenProcess "MaxGlitch_Layer_Export_Options_close()" id:#MGLEOC
		
		mlb_layers_properties_load()
		fill_mlb_layers()
		fill_dll_Presets()
		fill_mlb_animationclips()
		
		if (try(CM_PSC_GetExportPresetCount())catch(CM_PSC_GetExportOptionPresetCount())) == 0 do
		(
			messagebox "ERROR: No presets found! Make sure you installed MaxGlitch properly!"
			destroyDialog MaxGlitch_Layer_Export_Options
		)

	)
	
	on MaxGlitch_Layer_Export_Options close do
	(
		callbacks.removeScripts id:#MGLEOC
		deleteFile INI_OPTIONS
	)
	
	on MaxGlitch_Layer_Export_Options resized theSize do
	(
		mlb_layers.height = theSize[2] - 40
	)
	
	--export!
	on btn_export pressed do
	(
		TheLayers = ((mlb_layers.selection) as array)
		if TheLayers.count == 0 then
		(
			messagebox "ABORT: No layers selected!"
		)
		else
		(
			--Get Names of Selected Layers
			TheLayerNames = for n in TheLayers collect (mlb_layers.items[n])

			--First check: The selected layers, do they have the proper settings?
			firstcheck = undefined
			for n in TheLayerNames do
			(
				firstcheck = "pass"
				--Get Layer Properties
				thePresetName = getINIsetting INI_OPTIONS n "Preset"
				theExportFile = getINIsetting INI_OPTIONS n "ExportFile"
				
				if thePresetName == "" do
				(
					firstcheck = "fail"
					messagebox ("ABORT: Layer " + "\"" + n + "\"" + " has no Preset selected!")
				)
				if theExportFile == "" do
				(
					firstcheck = "fail"
					messagebox ("ABORT: Layer " + "\"" + n + "\"" + " has no export file specified!")
				)
			)
			
			--Second check: Do selected Presets exist?
			secondcheck = undefined
			if firstcheck == "pass" do
			(
				secondcheck = "pass"
				thePresets = for i=1 to (CM_PSC_GetExportPresetCount()) collect (CM_PSC_GetExportPresetName i)
				for n in TheLayerNames do
				(
					thePresetName = getINIsetting INI_OPTIONS n "Preset"
					PresetExists = for m in thePresets where m==thePresetName do exit with true
					--If Preset does not exit throw an error
					if PresetExists != true do
					(
						secondcheck = "fail"
						messagebox ("ABORT: Preset " + "\"" + thePresetName + "\"" + " does not exist! Make sure you have the right MaxGlitch.config!")
					)
				)
			)
			
			--Third check: Do animation clips exist in the scene?
			
			theMissingAnimationClips = #()
			theAnimationClips = for i=1 to (CM_GetNumAnimationClips()) collect (CM_GetAnimationClipName i)
			if secondcheck == "pass" do
			(
				for n in TheLayerNames do
				(
					--Get the Animation clips from INI
					theACini = getINIsetting INI_OPTIONS n "AnimationClips"
					if theACini != "" do
					(
						--Convert string to array if not empty
						theACini = execute(theACini)
						--For every AC in the INI, check if it's in the scene
						for m in theACini do
						(
							isACinScene = undefined
							isACinScene = for o in theAnimationClips where o==m do exit with true
							--If Animation Clip is not in scene add it to theMissingAnimationClips array
							if isACinScene != true do
							(
								append theMissingAnimationClips m
							)
						)
					)
				)
			)
			
			thirdcheck = "pass"
			if theMissingAnimationClips.count != 0 do
			(
				theString = ""
				for n in theMissingAnimationClips do
				(
					theString = theString + n + "\n"
				)
				if querybox ("WARNING: The following animation clips could not be found in the scene. They won't be exported. Are you sure you want to continue?" + "\n" + theString) == true then
				(
					thirdcheck = "pass"
				)
				else
				(
					thirdcheck = "false"
				)
			)
			


			--If the thirdcheck has passed as well proceed to export!
			if thirdcheck == "pass" do
			(

				--Since the Glitch BDAE export does not allow us to specify which user clips to export we need to make a backup. And add only the animation clips needed per layer.
				--At the end we need to restore all the animation clips

				--Create back up of Animation Clips
				theACArray = #()
				for i=1 to (CM_GetNumAnimationClips()) do
				(
					--Get AC info
					AnimationClipName = CM_GetAnimationClipName i
					AnimationClipStart = CM_GetAnimationClipStart i
					AnimationClipEnd = CM_GetAnimationClipEnd i
					
					--Create Array as String
					theString = (#(AnimationClipName,AnimationClipStart,AnimationClipEnd)) as string
					
					--Append to master array
					append theACArray theString
				)

				theString = ""
				for n in theACArray do
				(
					theString = theString + n + "\n"
				)
				fileProperties.addProperty #custom "MaxGlitchLayerExportOptionsACBACKUP" theString
				
				
				
				--Delete All Animation Clips. A clean slate.
				while (CM_GetNumAnimationClips()) != 0 do
				(
					(CM_DeleteAnimationClip (CM_GetNumAnimationClips()))
				)
				
				--Get Names of "Export Always" Layers
				AllLayers = for i=1 to mlb_layers.items.count collect (mlb_layers.items[i])
				theExportAlwaysLayers = for n in AllLayers where (getINIsetting INI_OPTIONS n "ExportAlways")=="true" collect n
				
				--Export selected layers
				for n in TheLayerNames do
				(
					--Store Layer visibility
					global theMGLEO_LayerVisibility = undefined
					global theMGLEO_LayerVisibility = ((LayerManager.getLayerFromName n).on)
					
					--Force Layer visible
					(LayerManager.getLayerFromName n).on = true
					
					--Select Layer nodes
					local thenodes = undefined
					(LayerManager.getLayerFromName n).nodes &thenodes
					select thenodes
					
					--Get Layer info
					theFilePath = getINIsetting INI_OPTIONS n "ExportFile"
					thePreset = getINIsetting INI_OPTIONS n "Preset"
					theLayerAnimationClips = getINIsetting INI_OPTIONS n "AnimationClips"
					if theLayerAnimationClips != "" do
					(
						--The Layer Animation Clips
						theLayerAnimationClips = execute(theLayerAnimationClips)
						
						--The "Export Always" Layer Animation Clips. Add them to the Layer Animation CLips array above.
						
						if theExportAlwaysLayers.count != 0 do
						(
							for m in theExportAlwaysLayers do
							(
								theExportLayerAnimationClips = getINIsetting INI_OPTIONS m "AnimationClips"
								if theExportLayerAnimationClips != "" do
								(
									--Append to array
									theExportLayerAnimationClips = execute(theExportLayerAnimationClips)
									for o in theExportLayerAnimationClips do
									(
										appendifUnique theLayerAnimationClips o
									)
								)
							)
						)

						--All Animation Clips
						textIndex = fileProperties.findProperty #custom "MaxGlitchLayerExportOptionsACBACKUP"
						theString = fileProperties.getPropertyValue #custom textIndex
						theACArray = filterstring theString "\n"
						
						for AC in theLayerAnimationClips do
						(
							for m in theACArray do
							(
								if m != "" do
								(
									theAC = execute(m)
									if theAC[1] == AC do
									(
										CM_AddAnimationClip theAC[1] theAC[2] theAC[3]
									)
								)
							)
						)
					)
					
					--Make "Expot Always Layers" visible
					if theExportAlwaysLayers.count != 0 do
					(
						global theExportAlwaysLayers_Visibility = undefined
						global theExportAlwaysLayers_Visibility = #()
						for m in theExportAlwaysLayers do
						(
							--Store visibility
							append theExportAlwaysLayers_Visibility ((LayerManager.getLayerFromName m).on)
							--Make Visible
							((LayerManager.getLayerFromName m).on) = true
							--Add the nodes to current selection
							theSelectionArray = #()
							for s in selection do (append theSelectionArray s)
							thenodesE = undefined
							(LayerManager.getLayerFromName m).nodes &thenodesE
							for s in thenodesE do (append theSelectionArray s)
							select theSelectionArray
						)
					)
					
					--Export!
					CM_ExportFile theFilePath show_prompt:false export_selected:true selected_preset:thePreset animation_clip_options:"UserClips"
					
					--Delete All Animation Clips. A clean slate.
					while (CM_GetNumAnimationClips()) != 0 do
					(
						(CM_DeleteAnimationClip (CM_GetNumAnimationClips()))
					)
					
					--Restore Layer visiblity
					(LayerManager.getLayerFromName n).on = theMGLEO_LayerVisibility
					
					--Restore Export Always Layer 
					if theExportAlwaysLayers.count != 0 do
					(
						for i=1 to theExportAlwaysLayers.count do
						(
							((LayerManager.getLayerFromName theExportAlwaysLayers[i]).on) =  theExportAlwaysLayers_Visibility[i]
						)
					)
					
					--Clear Selection
					clearselection()
				)
				
				
				
				
				--Restore Animation Clips
				textIndex = fileProperties.findProperty #custom "MaxGlitchLayerExportOptionsACBACKUP"
				theString = fileProperties.getPropertyValue #custom textIndex
				theACArray = filterstring theString "\n"

				for n in theACArray do
				(
					if n != "" do
					(
						theArray = execute(n)
						CM_AddAnimationClip theArray[1] theArray[2] theArray[3]
					)
				)
				fileProperties.deleteProperty #custom "MaxGlitchLayerExportOptionsACBACKUP"
			)
		)
	)
)
createDialog MaxGlitch_Layer_Export_Options width:440 height:440 style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing)