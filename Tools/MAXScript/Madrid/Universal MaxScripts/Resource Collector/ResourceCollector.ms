fn CreateDotNetProcessor = 
(
	if dotnet.GetType "DotNetProcessor" == undefined do
	(
		format "Constructing .NET Processor...\n"
		-- If layout of this text looks ragged, press ctrl-F11 to switch to a monospaced font...
		sb = ""
		sb +="    using System;																			\n"
		sb +="    using System.Text;																	\n"
		sb +="    using System.Diagnostics;																\n"
		sb +="																							\n"
		sb +="    class DotNetProcessor																	\n"
		sb +="    {																						\n" 
		sb +="																							\n"
		sb +="		private static StringBuilder stdOut = null;											\n"
		sb +="		private static StringBuilder stdErr = null;											\n"
		sb +="																							\n"
		sb +="		public String Output() { return stdOut == null ? \"\" : stdOut.ToString(); }		\n"
		sb +="		public String Errors() { return stdErr == null ? \"\" : stdErr.ToString(); }		\n"
		sb +="																							\n"
		sb +="		public void Execute(String filename, String args, String stdinbuff)					\n"
		sb +="		{																					\n"
		sb +="			Process p = new System.Diagnostics.Process();									\n"
		sb +="																							\n"
		sb +="			stdErr = new StringBuilder();													\n"
		sb +="			stdOut = new StringBuilder();													\n"
		sb +="			                               													\n"
		sb +="			p.EnableRaisingEvents = true;													\n"
		sb +="			p.StartInfo.FileName = filename;												\n"
		sb +="			p.StartInfo.Arguments = args;													\n"
		sb +="			p.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden	;		\n"
		sb +="			p.StartInfo.UseShellExecute = false;											\n"
		sb +="			p.StartInfo.RedirectStandardOutput = true;										\n"
		sb +="			p.StartInfo.RedirectStandardError = true;										\n"
		sb +="			p.StartInfo.RedirectStandardInput = stdinbuff.Length > 0;						\n"
		sb +="																							\n"
		sb +="			p.StartInfo.CreateNoWindow = true;												\n"
		sb +="																							\n"
		sb +="			p.OutputDataReceived += new DataReceivedEventHandler(OutputHandler);			\n"
		sb +="			p.ErrorDataReceived += new DataReceivedEventHandler(ErrorHandler);				\n"
		sb +="																							\n"
		sb +="			p.Start();																		\n"
		sb +="																							\n"
		sb +="			if (stdinbuff.Length > 0)														\n" 
		sb +="			{																				\n"
		sb +="				p.StandardInput.Write(stdinbuff);											\n"
		sb +="				p.StandardInput.Close();													\n"
		sb +="			}																				\n"
		sb +="																							\n"
		sb +="			stdErr = new StringBuilder();													\n"
		sb +="			stdOut = new StringBuilder();													\n"
		sb +="																							\n"
		sb +="			p.BeginOutputReadLine();														\n"
		sb +="			p.BeginErrorReadLine();															\n"
		sb +="																							\n"
		sb +="			p.WaitForExit();																\n"
		sb +="			p.Close();																		\n"	
		sb +="		}																					\n"
		sb +="																							\n"
		sb +="		private static void OutputHandler(object sendingProcess, DataReceivedEventArgs d)	\n"
		sb +="		{																					\n"
		sb +="			if (!String.IsNullOrEmpty(d.Data)) stdOut.Append(d.Data + \"\\n\");				\n"
		sb +="		}																					\n"
		sb +="																							\n"
		sb +="		private static void ErrorHandler(object sendingProcess, DataReceivedEventArgs d)	\n"
		sb +="		{																					\n"
		sb +="			if (!String.IsNullOrEmpty(d.Data)) stdErr.Append(d.Data + \"\\n\");				\n"
		sb +="		}																					\n"
		sb +="   }																						\n"

		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		
		compilerParams.ReferencedAssemblies.Add("System.dll");
		
		compilerParams.GenerateInMemory = true
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(sb)
		
		if (compilerResults.Errors.Count > 0 ) then
		(
			errs = stringstream ""
			for i = 0 to (compilerResults.Errors.Count-1) do
			(
				err = compilerResults.Errors.Item[i]
				format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line \                                              
													 err.Column err.ErrorText to:errs 
			)
			MessageBox (errs as string) title: "Errors encountered while compiling C# code"
			format "%\n" errs
			return undefined
		)
	)
	dotnetobject "DotNetProcessor"	
)

---------------------------------------------------------------------------------------------------
-- HiddenDotNetCommand
---------------------------------------------------------------------------------------------------

fn HiddenDotNetCommand exe args input=
(
	dnp = CreateDotNetProcessor()
	dnp.execute exe args input
	return (dnp.output())
)

fn GetFilesReferenced =
(
	atsops.refresh()
	ATSOps.ExcludeOutputFiles
	atsops.silent = true
	local fileList
	atsops.GetFiles &fileList
	if fileList.count != 0 do
	(
		deleteItem fileList  1
	)
	fileList
)

fn GenerateHtmlImage theHtmlPath theImagePath =
(
	local TextArray = #("<html>","<body style=" + "\"" + "overflow-y:hidden" + "\"" + " background=" + "\"" + theImagePath + "\"" + ">","</body>","</html>")
	(dotnetClass "System.IO.File").WriteAllLines theHtmlPath TextArray
)

fn GenerateStaticThumb ConvertExe theImagePath PixelWidth =
(
	--Store Values
	local JPEG_Quality = jpeg.getQuality()
	
	--Change JPEG Quality
	jpeg.setquality 100
	
	--Generate Thumb and convert
	local theBMP = gw.getViewportDib()
	theBMP.filename = theImagePath
	save theBMP
	(HiddenDotNetCommand ("\"" + ConvertExe + "\"") (" " + "\"" + theImagePath + "\"" + " -resize " + PixelWidth as string + " " + "\"" + theImagePath + "\"") "")
	
	--Restore Values
	jpeg.setquality JPEG_Quality
)

fn GenerateGifThumb ConvertExe TheFileName PixelWidth nth=
(
	with undo off
	(
		local CurrentSliderTime = slidertime
		local theExtension = ".bmp"
		local view_size = getViewSize()
		local NumberCount = (animationrange.end as string).count - 1
		animationrange
		for t = (animationrange.start as integer /ticksperframe) to (animationrange.end as integer /ticksperframe) where mod t nth == 0 do
		(
			slidertime = t
			local CurrentTimeFrame = (t as string)
			if CurrentTimeFrame.count != NumberCount do
			(
				local theDif = NumberCount - CurrentTimeFrame.count
				for i=1 to theDif do
				(
					CurrentTimeFrame = "0" + CurrentTimeFrame 
				)
			)
			local theBMP = gw.getViewportDib()
			theBMP.filename = pathconfig.removepathleaf TheFileName + "\\" + getFileNameFile TheFileName + "_" + CurrentTimeFrame + theExtension
			deleteFile theBMP.filename
			save theBMP
			(HiddenDotNetCommand ("\"" + ConvertExe + "\"") (" " + "\"" + (substitutestring theBMP.filename "\\" "\\\\") + "\"" + " -resize " + PixelWidth as string + " " + "\"" + (substitutestring theBMP.filename "\\" "\\\\") + "\"") "")
			freescenebitmaps()
			gc light:true
		)

		local theBMPs = substitutestring (pathconfig.removepathleaf TheFileName + "\\" + getFileNameFile TheFileName + "*" + theExtension) "\\" "\\\\"
		local theGIF = substitutestring TheFileName "\\" "\\\\"
		deletefile theGIF
		(HiddenDotNetCommand ("\"" + ConvertExe + "\"") (" -delay " + "1x" + (framerate * (1.0 / nth)) as string + " -loop 0 " + "\"" + theBMPs + "\"" + " " + "\"" + theGIF + "\"") "")
		(HiddenDotNetCommand ("\"" + ConvertExe + "\"") (" " + "\"" + theGIF + "\"" + " +matte +map -colors 16 " + "\"" + theGIF + "\"") "")
		
		for f in getFiles (pathconfig.removepathleaf TheFileName + "\\" + getFileNameFile TheFileName + "*" + theExtension) do
		(
			deleteFile f
		)
		slidertime = CurrentSliderTime
	)
)

try(destroyDialog resourceCollector)catch()
rollout resourceCollector "Resource Collector"
(
	--Local variables to the Dialog
	local ConvertExe = ((pathconfig.removepathleaf (getSourceFileName()) + "\\convert.exe"))
	local Exe7za = ((pathconfig.removepathleaf (getSourceFileName()) + "\\7za.exe"))
	local CurrentFolder = substitutestring ((pathconfig.removepathleaf (getSourceFileName())) + "\\") "\\" "\\\\"
 	local TempFolder = substitutestring ((pathconfig.removepathleaf (getSourceFileName())) + "\\TEMP\\") "\\" "\\\\"
	
	fn CleanTempFolder TempFolder =	(HiddenDotNetCommand "cmd.exe" ("/K rmDir " + "\"" + TempFolder + "\"" + " /s /q") "")
	fn CreateTempFolder TempFolder = (makeDir TempFolder)
	
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:265 pos:[0,0]
	button btn_createThumb "Generate Thumb" width:200 pos:[600,0]
	checkbox cb_gif "Animated Gif" width:200 pos:[610,25]
	dotNetControl wb "System.Windows.Forms.WebBrowser" width:200 height:200 pos:[600,45]
	button btn_createZip "Create Zip file" width:200 height:20 pos:[600,245]
	
	fn fill_lv =
	(
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Status" 50
		lv.Columns.add "Files" 600
		
		
		local fileList = GetFilesReferenced()
		local theRange = #()
		for n in fileList do
		(
			li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.UseItemStyleForSubItems=false
			if doesFileExist n then
			(
				li.ForeColor = (dotNetClass "System.Drawing.Color").Green
				li.text = "Found"
			)
			else
			(
				li.ForeColor = (dotNetClass "System.Drawing.Color").Red
				li.text = "Missing"
			)
			li.SubItems.add n
			append theRange li
		)
		lv.Items.AddRange theRange
	)
	
	on btn_createZip pressed do
	(
		local getSelection = for x=0 to lv.selectedIndices.count-1 collect lv.selectedIndices.item[x]
		local SelectedArray = for n in getSelection collect lv.Items.Item[n].SubItems.Item[1].Text
			
		print SelectedArray
-- 		local theMaxFile = maxfilepath + maxfilename
-- 		appendifunique SelectedArray theMaxFile
-- 		
-- 		local ResourcesFolder = (TempFolder + "\\resources\\")
-- 		makeDir ResourcesFolder
-- 		
-- 		for f in SelectedArray do
-- 		(
-- 			if doesFileExist f do
-- 			(
-- 				copyFile f (ResourcesFolder + "\\" + getFileNameFile f + getFileNameType f)
-- 			)
-- 		)
-- 		
-- 		--Zip it
-- 		deleteFile (CurrentFolder + "\\zip.zip")
-- 		--Resource folder
-- 		HiddenDotNetCommand Exe7za ("a -tzip " + "\""+ CurrentFolder + "\\zip.zip" + "\"" + " " + "\"" + ResourcesFolder + "\"" + " -mx9") ""
-- 		--preview
-- 		HiddenDotNetCommand Exe7za ("a -tzip " + "\""+ CurrentFolder + "\\zip.zip" + "\"" + " " + "\"" + TempFolder + "\\preview.jpg" + "\"" + " -mx9") ""
-- 		HiddenDotNetCommand Exe7za ("a -tzip " + "\""+ CurrentFolder + "\\zip.zip" + "\"" + " " + "\"" + TempFolder + "\\preview.gif" + "\"" + " -mx9") ""
-- 		
-- 		destroyDialog resourceCollector
-- 		shellLaunch "explorer.exe" ("/e,/select," + pathconfig.normalizepath (CurrentFolder + "\\zip.zip"))
	)
	
	on btn_createThumb pressed do
	(
		--Variables
		local PixelWidth = 200
		local PixelHeight = ((PixelWidth / (getViewSize())[1]) * (getViewSize())[2]) as integer
		local theImagePath = TempFolder + "\\preview.jpg"
		deleteFile theImagePath
		if cb_gif.state == true do 	(theImagePath =  TempFolder + "\\preview.gif")
		deleteFile theImagePath
		local theHtmlPath = pathconfig.normalizepath (TempFolder + "\\preview.html")
			
		--Generate thumbs
		if cb_gif.state == true then
		(
			GenerateGifThumb ConvertExe theImagePath PixelWidth 4
		)
		else
		(
			GenerateStaticThumb ConvertExe theImagePath PixelWidth
		)
		
		--Generate HTML page
		GenerateHtmlImage theHtmlPath theImagePath
		wb.url = dotNetObject "System.Uri" theHtmlPath
		wb.height = PixelHeight
	)
	
	on resourceCollector open do
	(
		fill_lv()
		CleanTempFolder TempFolder
		CreateTempFolder TempFolder
	)
	
	on resourceCollector close do
	(
		CleanTempFolder TempFolder
	)
)
CreateDialog resourceCollector width:800 height:265