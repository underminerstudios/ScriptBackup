fn import_process theXML =
(
	clearlistener()
	--Load the xml assemply
	dotNet.loadAssembly "system.xml"
	--Create an xml document object.
	local xmlDoc = dotNetObject "system.xml.xmlDocument"
		
	--Load the XML file.
	xmlDoc.load theXML
	--Check to make sure the xmlDoc has a root element. 
	local docEle = xmlDoc.documentElement
	local itemIter = (xmldoc.selectnodes "//folder/movie/track")
	for i=0 to itemIter.count-1 do
	(
		if itemIter.itemOf[i].Attributes.itemOf["type"].value == "e" do
		(
			local theDummy = dummy()
			theDummy.name = itemIter.itemOf[i].Attributes.itemOf["entityPath"].value

			for j=0 to itemIter.itemOf[i].ChildNodes.count-1 do
			(
				if itemIter.itemOf[i].ChildNodes.itemOf[j].LocalName == "clip" do
				(
					animationrange = interval 0 (itemIter.itemOf[i].ChildNodes.itemOf[j].Attributes.ItemOf["frames"].value as integer)
					for k=0 to itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.count-1 do
					(
						if itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].LocalName == "data" do
						(
							for l=0 to itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.count-1 do
							(
								if itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].LocalName == "frame" do
								(
									local theFrame = itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].Attributes.itemOf["index"].value as time
									local thePos = ""
									local theRot = ""
									for m=0 to itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].ChildNodes.count-1 do
									(
										if itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].ChildNodes.itemOf[m].LocalName == "p" do
										(
											local theTempPos = itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].ChildNodes.itemOf[m].Attributes.itemOf["val"].value
											theTempPos = filterstring theTempPos ","
											thePos = [theTempPos[1] as float,theTempPos[2] as float,theTempPos[3] as float]
										)
										if itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].ChildNodes.itemOf[m].LocalName == "r" do
										(
											local theTempRot = itemIter.itemOf[i].ChildNodes.itemOf[j].ChildNodes.itemOf[k].ChildNodes.itemOf[l].ChildNodes.itemOf[m].Attributes.itemOf["val"].value
											theTempRot = filterstring theTempRot ","
											theRot = quat ((theTempRot[1] as float) * -1.0) ((theTempRot[2] as float) * -1.0) ((theTempRot[3] as float) * -1.0) (theTempRot[4] as float)
										)
									)
									with animate on
									(
										if thePos != "" AND theRot != "" do
										(
											at time theFrame theDummy.rotation = theRot
											at time theFrame theDummy.pos = thePos
										)
										if thePos != "" AND theRot == "" do
										(
											at time theFrame theDummy.pos = thePos
											at time theFrame theDummy.pos = thePos
											--Delete rotation keyframe
											 selectKeys theDummy.rotation.controller theFrame
											 deleteKeys theDummy.rotation.controller #selection 
										)
										if thePos == "" AND theRot != "" do
										(
											at time theFrame theDummy.rotation = theRot
											at time theFrame theDummy.rotation = theRot
											--Delete position keyframe
											 selectKeys theDummy.pos.controller theFrame
											 deleteKeys theDummy.pos.controller #selection
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)
)


(
	local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
	theDialog.title = "Select file to import" --set the title
	theDialog.Multiselect = true --allow multiple files to be selected
	theDialog.Filter = "EClara Files (*.eclara)|*.eclara" --specify the filter
	theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
	local result = theDialog.showDialog() --display the dialog, get result into variable
	result.ToString() --when closed, convert the result to string
	-- result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
	-- result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
	local theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
	if (result.Equals result.OK) == true do
	(
		for n in theFilenames do
		(
			import_process n
		)
	)	
)