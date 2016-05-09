
try
(
	destroyDialog GLL_revisions
)catch()

rollout GLL_revisions "Revisions"
(
	dotNetControl lv "System.Windows.Forms.ListView" width:500 height:200 pos:[0,0]
	label lbl_ed "Description:" pos:[0,200]
	edittext ed width:500 height:100 pos:[0,220] readOnly:true
	button btn_get_revision "Get Revision..." enabled:false width:250 height:80 pos:[0,320]
	
	fn getSVNlog theFile=
	(
		theSVN = getDir #userscripts + "\\GLL_Launcher\\svn-win32-1.7.2\\bin\\svn.exe"
		TheDosCommandOutput = (HiddenDotNetCommand theSVN (" log " + "\"" + theFile + "\"") "")
		AsArray = (filterstring TheDosCommandOutput "\n")
		theOutput = #()
		for n in AsArray do
		(
			if matchpattern n pattern:"*|*|*|*" do
			(
				append theOutput n
			)
		)
		return theOutput
	)
	
	fn getSVNrevisionDescription theFile theRevision =
	(
		theSVN = getDir #userscripts + "\\GLL_Launcher\\svn-win32-1.7.2\\bin\\svn.exe"
		TheDosCommandOutput = (HiddenDotNetCommand theSVN (" log " + "\"" + theFile + "\"" + " -r" + theRevision) "")
		AsArray = (filterstring TheDosCommandOutput "\n")
		lineCount = filterstring AsArray[2] "|"
		lineCount = lineCount[lineCount.count]
		lineCount = filterstring lineCount " "
		lineCount = lineCount[1] as integer
		theOutputString = ""
		for i=3 to (2 + lineCount) do
		(
			theOutputString = theOutputString + AsArray[i] + "\n"
		)
		return theOutputString
	)
	
	
	fn fill_lv =
	(
		lv.clear() 
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Revision" 60
		lv.Columns.add "User" 175
		lv.Columns.add "Time" 245
		
		theList = #()
		theOutput = (getSVNlog GLL_theFile_revision)
		for n in theOutput do
		(
			theFilter = filterstring n "|"
			
			theRevision = trimleft theFilter[1]
			theRevision = trimRight theRevision
			theRevision = substituteString theRevision "r" ""
			
			theUser = trimleft theFilter[2]
			theUser = trimright theUser
			
			theTime = trimleft theFilter[3]
			theTime = trimright theTime
			
			li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.UseItemStyleForSubItems=false
			li.text = theRevision
			sub_li = li.SubItems.add theUser
			sub_li = li.SubItems.add theTime
			append theList li
		)
		
		-- Add the item to the list
		lv.Items.AddRange theList
	)
	
	on GLL_revisions open do
	(
		fill_lv()
	)
	
	on lv MouseClick theClick do
	(
		local theItem = lv.GetItemAt theClick.x theClick.y
		local theRowIndex = theItem.Index + 1
		local theSubItem = (theItem.GetSubItemAt theClick.x theClick.y)
		local theRevision = lv.SelectedItems.Item[0].SubItems.Item[0].text
		ed.text = "loading..."
		ed.text = getSVNrevisionDescription GLL_theFile_revision theRevision
		btn_get_revision.text = "Get Revision " + theRevision
		btn_get_revision.enabled = true
	)
	
	on btn_get_revision pressed do
	(
		revisionNumber = filterstring btn_get_revision.text " "
		revisionNumber = revisionNumber[revisionNumber.count]
		
		theSVN = getDir #userscripts + "\\GLL_Launcher\\svn-win32-1.7.2\\bin\\svn.exe"
		TheDosCommandOutput = (HiddenDotNetCommand theSVN (" update " + "\"" + (GLL_theFile_revision) + "\"" + " -r" + revisionNumber) "")
		theOutput = (filterstring TheDosCommandOutput "\n")
		print theOutput
		if matchpattern theOutput[theOutput.count] pattern:"Updated to revision *" then
		(
			messagebox ("Succesfully downloaded revision " + revisionNumber)
			destroyDialog GLL_revisions
		)
		else
		(
			if matchpattern theOutput[theOutput.count] pattern:"At revision *" then
			(
				messagebox "You already have this revision"
			)
			else
			(
				messagebox "Something went wrong!"
			)
		)
	)
	
	
)
createDialog GLL_revisions width:500 height:400