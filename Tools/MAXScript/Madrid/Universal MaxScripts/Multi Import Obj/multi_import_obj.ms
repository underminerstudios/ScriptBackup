(
	local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
	theDialog.title = "PLEASE Select One Or More OBJs" --set the title
	theDialog.Multiselect = true --allow multiple files to be selected
	theDialog.Filter = "gw::OBJ-Importer (*.OBJ)|*.obj" --specify the filter
	theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
	local result = theDialog.showDialog() --display the dialog, get result into variable
	result.ToString() --when closed, convert the result to string
	result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
	result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
	local theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
	for n in theFilenames do
	(
		importFile n #noPrompt using:Wavefront_Object
	)
)