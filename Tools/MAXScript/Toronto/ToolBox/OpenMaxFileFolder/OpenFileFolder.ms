/*
macroscript OpenFileFolder 
Category: "GameloftTools"
icon:#("ViewportNavigationControls",1)
ToolTip: "Opens the folder that the maxfile is saved to"
--created By Karl Kent 2011
*/
(
	if (Maxfilename != "") then 
	(
	shellLaunch "explorer.exe" MaxfilePath
	)
)