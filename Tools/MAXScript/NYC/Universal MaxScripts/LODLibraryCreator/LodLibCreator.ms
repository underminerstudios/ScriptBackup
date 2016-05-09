scriptLOC = getFilenamePath "C:\\art_tools\\MAXScript\\NYC\\Universal MaxScripts\\LODLibraryCreator\\"
print scriptLOC
if scriptLOC != "C:\\art_tools\\MAXScript\\NYC\\Universal MaxScripts\\LODLibraryCreator\\" then 
(
	scriptLOC = getSavePath caption:"Can't Find LODLibraryCreator location, please select the folder this script is in."
)


fn loadDir i =
(
	scriptDir = scriptLOC
	selXML = ""
	
	selXMLFileName = scriptDir + "\\selectorXML.txt" 
	selXMLFile = openFile selXMLFileName
	while (not eof selXMLFile) do 
	( 
		currentLine = readline selXMLFile
		currentLine = substituteString currentLine "+++LOD_SELECTOR_NAME+++" ("+SEL+" + printData[1] + "+SEL+") 
		currentLine = substituteString currentLine "+++LOD_COUNT+++" ("+COUNT+" + printData[2] + "+COUNT+") 
		currentLine = substituteString currentLine "+++LOD_NAMES+++" ("+NAMES+" + printData[3] + "+NAMES+") 
		currentLine = substituteString currentLine "+++LOD_RANGES+++" ("+RANGES+" + printData[4] + "+RANGES+") 
		currentLine = substituteString currentLine "+++LOD_HYST+++" ("+HYST+" + printData[5] + "+HYST+") 
		
		selXML = selXML + currentLine + "\n"
	)
	close selXMLFile	
)

fn updateLib i =
(
	scriptDir = scriptLOC
	selLibDir = scriptDir + "\\SelectorInfo\\"
	selFiles = getFiles (selLibDir + "*.txt")
	libFiles = #()

	for f in selFiles do 
	(
		currentFile = f
		currentFile = substituteString currentFile selLibDir ""
		currentFile = substituteString currentFile ".txt" ""
		append libFiles currentFile
	)

	return libFiles 
)

fn addSelFn printData = 
(
	scriptDir = scriptLOC
	selXML = ""
	
	selXMLFileName = scriptDir + "\\selectorXML.txt" 
	selXMLFile = openFile selXMLFileName
	while (not eof selXMLFile) do 
	( 
		currentLine = readline selXMLFile
		currentLine = substituteString currentLine "+++LOD_SELECTOR_NAME+++" ("+SEL+" + printData[1] + "+SEL+") 
		currentLine = substituteString currentLine "+++LOD_COUNT+++" ("+COUNT+" + printData[2] + "+COUNT+") 
		currentLine = substituteString currentLine "+++LOD_NAMES+++" ("+NAMES+" + printData[3] + "+NAMES+") 
		currentLine = substituteString currentLine "+++LOD_RANGES+++" ("+RANGES+" + printData[4] + "+RANGES+") 
		currentLine = substituteString currentLine "+++LOD_HYST+++" ("+HYST+" + printData[5] + "+HYST+") 
		
		selXML = selXML + currentLine + "\n"
	)
	close selXMLFile
	
	selXML = selXML + "MAX INFO TO DELETE:" + printData[1] + "," + printData[2] + "," + printData[3] + "," + printData[4] + "," + printData[5]
	
	outputSelFile = createFile (scriptDir + "\\SelectorInfo\\" + printData[1] + ".txt")
	if outputSelFile != undefined then (
		format "%" selXML to:outputSelFile;
	) else (
		print "did not work";
	)
	close outputSelFile
	
	return printData[1] 
)

rollout LOD_Library_Creator "LOD Library Creator" width:242 height:390
(	
	groupBox currentSelInfoGrp "Selector Settings" pos:[4,53] width:234 height:246
	dropDownList selLibList "LOD Selector Library" pos:[10,5] width:148 height:40 items:(updateLib 1)
	button delSelButton "Delete" pos:[168,24] width:62 height:22
	button addSelButton "Add to Selector Library" pos:[5,304] width:130 height:22
	button updateSelButton "Update Current" pos:[140,304] width:96 height:22
	
	listBox lodNameList "Names" pos:[12,159] width:66 height:6
	listBox lodRangeList "Ranges" pos:[89,159] width:64 height:6
	listBox lodHystList "Hysteresis" pos:[166,159] width:64 height:6
	
	editText editLODName "Name" pos:[13,80] width:216 height:20
	spinner editLODRange "Range" pos:[34,110] width:114 height:16 range:[0,100000000,0] type:#integer scale:1
	spinner editLODHyst "Hysteresis" pos:[20,130] width:130 height:16 range:[0,100000000,0] type:#integer scale:1
	
	button addLODButton "Add LOD" pos:[155,110] width:74 height:40
	button pubLib "Publish Library" pos:[9,331] width:226 height:52
	button clearSel "Clear Selected" pos:[7,266] width:104 height:26
	button clearAll "Clear All" pos:[125,266] width:104 height:26
	
	on pubLib pressed do 
	(
		allSels = updateLib 1
		
		if allSels.count != 0 then
		(			
			scriptDir = scriptLOC
			combindSelsXML = ""
			baseXML = ""
			
			for f in allSels do
			(			
				
				file = openFile (scriptDir + "\\SelectorInfo\\" + f + ".txt")
				if file != undefined do
				(
					while (not eof file) do 
					( 
						currentLine = readline file
						linedata = filterString currentLine ":"
						
						if linedata[1] != "MAX INFO TO DELETE" then
							combindSelsXML = combindSelsXML + currentLine + "\n" 
					)
				)
				close file
			)
		
			basefile = openFile (scriptDir + "\\baseXML.txt")
			if basefile != undefined do
			(
				while (not eof basefile) do 
				( 
					currentLine = readline basefile
					if currentLine == "		+++ADD_SELECTOR_HERE+++" then 
					(
						baseXML = baseXML + combindSelsXML	
					)
					else 
					(
						baseXML = baseXML + currentLine + "\n" 
					)
				)
				close basefile
			)
			
			baseXML = substituteString baseXML "+++" ""
			baseXML = substituteString baseXML "+SEL+" ""
			baseXML = substituteString baseXML "+COUNT+" ""
			baseXML = substituteString baseXML "+NAMES+" ""
			baseXML = substituteString baseXML "+RANGES+" ""
			baseXML = substituteString baseXML "+HYST+" ""
			
			createDAE = (scriptDir + "\\LODSelectorLibrary.dae")
			publishDAE = createFile createDAE
			if publishDAE != undefined then (
				format "%" baseXML to:publishDAE;
			) else (
				print "did not work";
			)
			close publishDAE
			
			ShellLaunch (scriptDir + "\\LODlib_dae_2_bdae.bat\\") ""
			shellLaunch "explorer.exe" scriptDir
		)
		else 
		(
			messagebox "There are no Selectors created. PLease create some before tryihng to publish"
		)
	)
	
	on delSelButton pressed do 
	(
		rollout delSelGUI "Untitled" width:325 height:46
		(
			label lbl1 "Are you sure you want to delete this Selector from the Library" pos:[5,3] width:300 height:22
			button yesButton "Yes" pos:[58,23] width:78 height:18
			button noButton "No" pos:[143,22] width:78 height:18
			
			on noButton pressed do 
			(
				destroyDialog delSelGUI
			)  
			
			on yesButton pressed do 
			(
				scriptDir = scriptLOC
				libFileSel = scriptDir + "\\SelectorInfo\\" + selLibList.selected + ".txt" 
				deleteFile libFileSel 
				messagebox (selLibList.selected + " has been deleted from the Library.")
				selLibList.items = updateLib 1
				selLibList.selection = 1
				destroyDialog delSelGUI
			)  
		)
		createDialog delSelGUI
	)
	
	on selLibList selected i do
	(
		scriptDir = scriptLOC
		libFileSel = scriptDir + "\\SelectorInfo\\" + selLibList.selected + ".txt" 
		
		libFileOpen = openFile libFileSel
		
		if libFileOpen != undefined then
		(
			while (not eof libFileOpen) do 
			( 
				currentLine = readline libFileOpen
				linedata = filterString currentLine ":"
				
				if linedata[1] == "MAX INFO TO DELETE" then
				(
					tokens = filterString linedata[2] ","
					nameTok = filterString tokens[3] " "  
					rangeTok = filterString tokens[4] " " 
					hystTok = filterString tokens[5] " "  	

					lodNameList.items = nameTok
					lodRangeList.items = rangeTok
					lodHystList.items = hystTok
				)

			)
			close libFileOpen
		)
		else 
		(
			messagebox "Looks like this Selector info was deleted out of \\LODLibraryCreator\\SelectorInfo\\. Will delete this from the dropdown menu"
			selLibList.items = updateLib 1;
			selLibList.selection = 1;
		)
		
	)

	on updateSelButton pressed do
	(
		nameArray = lodNameList.items
		rangeArray = lodRangeList.items
		hystArray = lodHystList.items
		nameString = ""
		rangeString = ""
		hystString = ""
		
		for nameData in nameArray do
		(
			nameString = nameString + nameData + " "
		)

		for rangeData in rangeArray do
		(
			rangeString = rangeString + rangeData + " "
		)
		
		for hystData in hystArray do
		(
			hystString = hystString + hystData + " "
		)
		
		nameString = nameString + "END_STRING_SPACE"
		rangeString = rangeString + "END_STRING_SPACE"
		hystString = hystString + "END_STRING_SPACE"
		
		nameString = substituteString nameString " END_STRING_SPACE" ""
		rangeString = substituteString rangeString " END_STRING_SPACE" ""
		hystString = substituteString hystString " END_STRING_SPACE" ""
		
		scriptDir = scriptLOC
		libFileSel = scriptDir + "\\SelectorInfo\\" + selLibList.selected + ".txt" 
		
		updateSelFile = ""
		dataFromFile = #()
		
		libFileOpen = openFile libFileSel
		if libFileOpen != undefined then
		(
			while (not eof libFileOpen) do 
			( 
				currentLine = readline libFileOpen
				
				linedata = filterString currentLine ":"
				if linedata[1] == "MAX INFO TO DELETE" then
				(
					dataFromFile = filterString linedata[2] ","
				) 
				else 
				(
					updateSelFile = updateSelFile + currentLine + "\n"
				)
			)
			close libFileOpen
			
			updateSelFile = substituteString updateSelFile ("+COUNT+" + dataFromFile[2] + "+COUNT+") ("+COUNT+" + nameArray.count as string + "+COUNT+")
			updateSelFile = substituteString updateSelFile ("+NAMES+" + dataFromFile[3] + "+NAMES+") ("+NAMES+" + nameString + "+NAMES+")
			updateSelFile = substituteString updateSelFile ("+RANGES+" + dataFromFile[4] + "+RANGES+") ("+RANGES+" + rangeString + "+RANGES+")
			updateSelFile = substituteString updateSelFile ("+HYST+" + dataFromFile[5] + "+HYST+") ("+HYST+" + hystString + "+HYST+")
			updateSelFile = updateSelFile + "MAX INFO TO DELETE:" + dataFromFile[1] + "," + nameArray.count as string + "," + nameString + "," + rangeString + "," + hystString
			
			libFileOpen = createFile libFileSel
			if libFileOpen != undefined then (
				format "%" updateSelFile to:libFileOpen;
			) else (
				print "did not work";
			)
			close libFileOpen
			
			messagebox (selLibList.selected + " has been updated")
		)
		else 
		(
			messagebox "Looks like this Selector info was deleted out of \\LODLibraryCreator\\SelectorInfo\\. Will delete this from the dropdown menu"
			selLibList.items = updateLib 1;
			selLibList.selection = 1;
		)
	)
	
	on lodNameList selected i do
	(
		lodRangeList.selection = i
		lodHystList.selection = i
	)

	on lodRangeList selected i do
	(
		lodNameList.selection = i
		lodHystList.selection = i
	)
	
	on lodHystList selected i do
	(
		lodRangeList.selection = i
		lodNameList.selection = i
	)
	
	on addLODButton pressed do 
	(

		if editLODName.text != "" then 
		(
			nameArray = lodNameList.items
			rangeArray = lodRangeList.items
			hystArray = lodHystList.items
			
			append nameArray editLODName.text 
			append rangeArray (editLODRange.value as string)
			append hystArray (editLODHyst.value as string)
			
			lodNameList.items = nameArray
			lodRangeList.items = rangeArray
			lodHystList.items = hystArray
			
			editLODName.text = ""
			editLODRange.value  = 0
			editLODHyst.value = 0
		) 
		else 
		(
			messageBox "Please type a Name for this LOD"
		)
	)
	
	on clearSel pressed do 
	(
			nameArray = lodNameList.items
			rangeArray = lodRangeList.items
			hystArray = lodHystList.items
			
			deleteItem  nameArray lodNameList.selection 
			deleteItem  rangeArray lodRangeList.selection
			deleteItem  hystArray lodHystList.selection
			
			lodNameList.items = nameArray
			lodRangeList.items = rangeArray
			lodHystList.items = hystArray
			
			editLODName.text = ""
			editLODRange.value  = 0
			editLODHyst.value = 0
	)
	
	on clearAll pressed do 
	(
			lodNameList.items =  #()
			lodRangeList.items =  #()
			lodHystList.items =  #()

			editLODName.text = ""
			editLODRange.value  = 0
			editLODHyst.value = 0
	)
	
	on addSelButton pressed do
	(
		checkData = lodNameList.items
		
		if (checkData.count != 0) then 
		(
			rollout nameNewSelectorGUI "Name New Selector"
			(
				editText nameSel "Name Selector" width:250
				button addSel2Lib "Add Selector To Library"

				on addSel2Lib pressed do
				(
					if nameSel.text != "" then 
					(
						nameArray = lodNameList.items
						rangeArray = lodRangeList.items
						hystArray = lodHystList.items
						nameString = ""
						rangeString = ""
						hystString = ""
						
						for nameData in nameArray do
						(
							nameString = nameString + nameData + " "
						)

						for rangeData in rangeArray do
						(
							rangeString = rangeString + rangeData + " "
						)
						
						for hystData in hystArray do
						(
							hystString = hystString + hystData + " "
						)
						
						nameString = nameString + "END_STRING_SPACE"
						rangeString = rangeString + "END_STRING_SPACE"
						hystString = hystString + "END_STRING_SPACE"
						
						nameString = substituteString nameString " END_STRING_SPACE" ""
						rangeString = substituteString rangeString " END_STRING_SPACE" ""
						hystString = substituteString hystString " END_STRING_SPACE" ""
						
						printData = #(nameSel.text, nameArray.count as string, nameString, rangeString, hystString)
						
						selLibArray = selLibList.items
						newSel = addSelFn printData
						append selLibArray newSel 
						selLibList.items = selLibArray
						selLibList.selection  = selLibArray.count
						destroyDialog nameNewSelectorGUI 
					) 
					else 
					(
						messageBox "Please enter a Name for the Selector First"
					)
				)
			)
			createDialog nameNewSelectorGUI width:300
		)
		else
		(
			messageBox "Please add LOD values before creating the selector"
		)
	)
	
)
createDialog LOD_Library_Creator
print scriptLOC