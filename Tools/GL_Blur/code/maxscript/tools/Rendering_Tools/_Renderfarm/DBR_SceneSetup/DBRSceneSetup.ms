fn_DBRSceneSetup =
	(
		gSP=getSavePath caption:"Resource Collector Destination:"
		okToProceed=true
		
		try (gsp=pathconfig.convertPathToUnc gsp) catch (okToProceed=false)
		
		if okToProceed and gsp[1]!="\\" do okToProceed = querybox "Not a network Path!\nProceed?"
		
		if okToProceed do
		(
			a=getclassinstances bitmaptexture
			rawArray=for i in a collect i.filename
			sort rawArray
			currentBM = ""
			for i in rawArray do
			(
				if i!=currentBM do
				(
					if (copyFile i (gSP+"\\"+filenameFromPath i)) do format "file % copied to %\n" i gsp
					currentBM=i -- reset the comparator
				)
			)
			for i in a do 
			(
				if doesFileExist i.filename then
					i.filename = gSP+"\\"+(filenamefrompath i.filename)
				else
					format "Missing File: %\n" i.filename
			)
		)
	)
	
fn_DBRSceneSetup ()