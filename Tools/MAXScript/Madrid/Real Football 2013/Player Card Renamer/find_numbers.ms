/*
	This script will find the player card source jpgs in the list and copy them to the "cards" folder. The name will be changed to the line of the RF2013_GettyImages_PlayersList.csv file
	
	by Norman Schaar - norman.schaar@gameloft.com
*/



fn getFilesRecursive root pattern =
(
	dir_array = GetDirectories (root+"/*")
	for d in dir_array do
	join dir_array (GetDirectories (d+"/*"))
	 
	my_files = #()
	for f in dir_array do
	join my_files (getFiles (f + pattern))
	my_files 
)

fn find_number arrayFiles arrayDB =
(
	theDB = (dotnetClass "System.IO.File").ReadAllLines "W:\\sources\\UI\\textures\\players\\RF2013_GettyImages_PlayersList.csv" (dotNetClass "System.Text.Encoding").Default
	for f in arrayFiles do
	(
		(dotnetClass "Application").doEvents()
		local theName = substitutestring (getFileNameFile f) "_" " "
		theName = substitutestring theName " " "*"
		
		local theTeam = substitutestring (substitutestring (pathconfig.strippathtoleaf (getFileNamePath f)) "\\" "") " " "*"
		
		local found = false
		for i=1 to theDB.count do
		(
			if matchpattern theDB[i] pattern:("*" + theName + "*" + theTeam + "*") do
			(
				--renameFile f ((getFilenamePath f) + "\\" + (i as string) + ".jpg")
				deleteFile ("W:\\sources\\UI\\textures\\players\\cards\\" + (i as string) + ".jpg")
				copyFile f ("W:\\sources\\UI\\textures\\players\\cards\\" + (i as string) + ".jpg")
				--print ("found in line " + (i as string) + " " + theName)
				found = true
			)
			if found == true do (exit)
		)
		if found == false do (print ("ERROR NAME NOT FOUND: " + getFileNameFile f))
	)	
)
if querybox "Do you want to continue?" == true do
(
	actionMan.executeAction 0 "40472"
	theFiles = getFilesRecursive "W:\\sources\\UI\\textures\\players\\cards\\" "*.jpg"

	theDB = (dotnetClass "System.IO.File").ReadAllLines "W:\\sources\\UI\\textures\\players\\RF2013_GettyImages_PlayersList.csv" (dotNetClass "System.Text.Encoding").Default
	start = timeStamp()
	find_number theFiles theDB
	end = timeStamp()
	format "Processing took % seconds\n" ((end - start) / 1000.0)
	messagebox "Completed!"
)

