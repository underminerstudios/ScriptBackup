/*
	Network Share
*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog networkShare)catch()
rollout networkShare "Network Share"
(
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
	
	--Will get SUBST status with shared and unshared folders
	fn get_SUBST_status =
	(
		local theOutput = filterstring (HiddenDotNetCommand "subst.exe" "" "") "\n"
		local Drives = #()
		local Paths = #()
		for n in theOutput do
		(
			local theDrive = substring n 1 2
			append Drives theDrive
			local thePath = substitutestring (substring n 2 -1) ":\\: => " ""
			append Paths thePath
		)
		#(Drives,Paths)
	)
	
	fn get_real_folders theFolders =
	(
		local theSUBST = get_SUBST_status()
		local FinalFolders = #()
		for j=1 to theFolders.count do
		(
			for i=1 to theSUBST[1].count do
			(
				if matchpattern theFolders[j] pattern:((theSUBST[1])[i] + "*") do
				(
					local theFinalPath = (theSUBST[2])[i] + (substring theFolders[j] 3 -1) + "\\"
					theFinalPath = substring theFinalPath 1 (theFinalPath.count - 1)
					append FinalFolders theFinalPath
				)
			)
			if FinalFolders.count != j do
			(
				append FinalFolders theFolders[j]
			)
		)
		FinalFolders		
	)
	
	fn GetFilesReferenced =
	(
		atsops.refresh()
		ATSOps.ExcludeOutputFiles
		atsops.silent = true
		local fileList
		local finalList = #()
		atsops.GetFiles &fileList
		for f in fileList do
		(
			if f != (maxfilepath + maxfilename) do
			(
				appendifunique finalList f
			)
		)
		finalList
	)
	
	fn getFolders theFileList =
	(
		local theArray = #()
		for n in theFileList do
		(
			local theFolder = getFilenamePath (pathConfig.convertPathToLowerCase n)
			theFolder = substring theFolder 1 (theFolder.count - 1)
			if doesFileExist theFolder do
			(
				appendifunique theArray theFolder
			)
		)
		theArray
	)
	
	fn SET_SHARE_FOLDER_NAME_LIST THE_REAL_PATHS =
	(
		local NetWorkPaths = #()
		for i=1 to THE_REAL_PATHS.count do
		(
			appendifunique NetWorkPaths (maxfilename + "_" + i as string)
		)
		NetWorkPaths
	)
	
	fn SET_SHARE_FOLDER_PATHS THE_SHARE_FOLDER_NAMES =
	(
		local theFolders = #()
		for n in THE_SHARE_FOLDER_NAMES do
		(
			local thePath = "\\\\" + sysinfo.computername + "\\" + n
			append theFolders thePath
		)
		
		theFolders		
	)
	
	fn getNetworkFolders theFileList =
	(
		local theArray = #()
		for n in theFileList do
		(
			local theFolder = getFilenamePath (pathConfig.convertPathToLowerCase n)
			theFolder = substring theFolder 1 (theFolder.count - 1)
			if (pathIsNetworkPath theFolder) == true and (doesFileExist theFolder) == true do
			(
				appendifunique theArray theFolder
			)
		)
		theArray
	)
	
	fn GetLocalPaths NetWorkPaths=
	(
		local theDOSoutput = filterstring (HiddenDotNetCommand "net.exe" "share" "") "\n"
		local returnArray = #()
		for n in NetWorkPaths do
		(
			for i=1 to theDOSoutput.count do
			(
				local theFolderName =  pathConfig.convertPathToLowerCase(substitutestring (pathConfig.stripPathToLeaf (getFilenamePath (n + "\\"))) "\\" "")
				local DOS_Line = pathConfig.convertPathToLowerCase(theDOSoutput[i])
				
				-- If the folder name matches the DOS_Line add it to the array
				if theFolderName == DOS_Line do
				(
					appendifunique returnArray (trimright (trimleft theDOSoutput[i + 1]))
				)
				
				-- This case is somewhat special. If the name of the max file is too short, the path will be in the same line in the DOS prompt.
				if i!=theDOSoutput.count do
				(
					--Check if the next line is empty, this is where the path should be
					if (trimleft theDOSoutput[i + 1]) == "" then
					(
						--Now that we know it is, we need to check if the line even has the name of the Shared Folder in it
						if matchpattern theDOSoutput[i] pattern:(theFolderName + " *") do
						(
							--Now we know it does, we get rid of the shared folder name, use trimleft to get rid of the spaces on the left and append it to the array
							local theLine = trimright (trimleft (substitutestring theDOSoutput[i] theFolderName ""))
							appendifunique returnArray theLine
						)
					)
				)
			)
		)
		returnArray
	)
	
	fn CreateShareBat THE_REAL_PATHS THE_NETWORK_SHARE_FOLDER_NAMES TheShareBat =
	(
		local theShareBatArray = #()
		for i=1 to THE_REAL_PATHS.count do
		(
			local theLine = "net share " + "\"" + THE_NETWORK_SHARE_FOLDER_NAMES[i] + "\"" + "=" + "\"" + THE_REAL_PATHS[i] + "\""
			local UnShareLine = "net share " + "\"" + THE_NETWORK_SHARE_FOLDER_NAMES[i] + "\"" + " " + "/y /delete"
			append theShareBatArray UnShareLine
			append theShareBatArray theLine
		)
		append theShareBatArray ("DEL " + "\"" + pathConfig.normalizePath TheShareBat + "\"")
		(dotnetClass "System.IO.File").WriteAllLines theShareBat theShareBatArray
		true
	)
	
	fn CreateUnshareBat NetWorkPaths theUnshareBat =
	(
		local theUnshareBatArray = #()

		for f in NetWorkPaths do
		(
			local theSharedFolderName =  substitutestring (pathConfig.stripPathToLeaf (getFilenamePath (f + "\\"))) "\\" ""
			local theLine = "net share " + "\"" + theSharedFolderName + "\"" + " /y /delete"
			append theUnshareBatArray theLine
		)
		append theUnshareBatArray ("DEL " + "\"" + pathConfig.normalizePath theUnshareBat + "\"")
		(dotnetClass "System.IO.File").WriteAllLines theUnshareBat theUnshareBatArray
	)
	
	fn PathToNetwork LocalFolders NetworkPaths =
	(
		atsops.refresh()
		atsops.visible = true
		atsops.visible = false
		
		local theFiles = GetFilesReferenced()
		
		for n in theFiles do
		(
			for i=1 to LocalFolders.count do
			(
				local theFolder = (getFilenamePath (pathConfig.convertPathToLowerCase n))
				--If the Local Folder matches the current folder...
				if theFolder == (LocalFolders[i] + "\\") do
				(
					--...Set the network path to it
					atsops.selectfiles #(n)
					atsops.setpathonselection (NetworkPaths[i] + "\\")
				)
			)
		)
		atsops.refresh()
	)
	
	fn NetworkToPath NetworkPaths RealPaths =
	(
		atsops.refresh()
		atsops.visible = true
		atsops.visible = false
		
		local theFiles = GetFilesReferenced()
		for n in theFiles do
		(
			for i=1 to NetworkPaths.count do
			(
				local theFolder = (getFilenamePath (pathConfig.convertPathToLowerCase n))
				--If the Local Folder matches the current folder...
				if theFolder == (NetworkPaths[i] + "\\") do
				(
					--...Set the network path to it
					atsops.selectfiles #(n)
					atsops.setpathonselection (RealPaths[i] + "\\")
				)
			)
		)
		atsops.refresh()
	)
	
	fn GetRealPaths LOCAL_PATHS =
	(
		local returnArray = #()
		local SUBST_STATUS = get_SUBST_status()
		--Loop through every path
		for i=1 to LOCAL_PATHS.count do
		(
			local thePath = ""
			for j=1 to SUBST_STATUS[2].count do
			(
				local RealPathBeginning = pathConfig.convertPathToLowerCase ((SUBST_STATUS[2])[j])
				local LocalPath = pathConfig.convertPathToLowerCase LOCAL_PATHS[i]
				local DriveLetter = ((SUBST_STATUS[1])[j])
				--Check if it matches any of the real folders found
				if matchpattern LocalPath pattern:(RealPathBeginning + "*") do
				(
					thePath = substitutestring LocalPath RealPathBeginning DriveLetter
					append returnArray thePath
				)
			)
			if returnArray.count != i do
			(
				append returnArray LOCAL_PATHS[i]
			)
		)
		returnArray	
	)

	local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local NircmdEXE = theDepotPath + "\\MAXScript\\Madrid\\_CommandLineTools\\NirCmd\\nircmd.exe"
	
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:425 pos:[0,0]
	button btn_share "Share" width:150 height:25
	button btn_unshare "Unshare" width:150 height:25
	
	fn fill_lv =
	(
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Wrong & Missing paths" 600
		
		-- Get all files 
		local fileList = GetFilesReferenced()

		theRange = #()
		
		for n in fileList do
		(
			li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.text = n
			li.UseItemStyleForSubItems=false
			
			if doesFileExist n then
			(
				li.ForeColor = (dotNetClass "System.Drawing.Color").Green
			)
			else
			(
				li.ForeColor = (dotNetClass "System.Drawing.Color").Red
			)
				
			append theRange li
		)
		
		lv.Items.AddRange theRange
	)
	
	on btn_share pressed do
	(
		local theShareBatFile = getFilenamePath (getSourceFileName()) + "\\theSharebat.bat"
		
		local THE_SCENE_PATHS = getFolders (GetFilesReferenced())
		local THE_REAL_PATHS = get_real_folders THE_SCENE_PATHS
		local THE_NETWORK_SHARE_FOLDER_NAMES = SET_SHARE_FOLDER_NAME_LIST THE_REAL_PATHS
		local THE_NETWORK_PATHS = SET_SHARE_FOLDER_PATHS THE_NETWORK_SHARE_FOLDER_NAMES

		--Create Bat File
		CreateShareBat THE_REAL_PATHS THE_NETWORK_SHARE_FOLDER_NAMES theShareBatFile
		
		--Launch Bat File, create newtowrk shares
		HiddenDotNetCommand NircmdEXE ("elevate " + "\"" + theShareBatFile + "\"") ""
			
		--Map paths to network
		PathToNetwork THE_SCENE_PATHS THE_NETWORK_PATHS
		--Refresh
		if not doesFileExist theShareBatfile then
		(
			fill_lv()
		)
		else
		(
			sleep 0.5
			fill_lv()
		)
	)
	
	on btn_unshare pressed do
	(
		local theUnshareBatFile = getFilenamePath (getSourceFileName()) + "\\theUnshareBat.bat"
			
		local NETWORK_PATHS = getNetworkFolders (GetFilesReferenced())
		local LOCAL_PATHS = GetLocalPaths NETWORK_PATHS
		local REAL_FOLDERS = GetRealPaths LOCAL_PATHS
			
		--Create Unshare Bat
		CreateUnshareBat NETWORK_PATHS theUnshareBatFile
		
		--Conver the Paths to Local
		NetworkToPath NETWORK_PATHS REAL_FOLDERS
		
		--Run UnshareBat file
		HiddenDotNetCommand NircmdEXE ("elevate " + "\"" + theUnshareBatFile + "\"") ""
		
		--Refresh list
		if not doesFileExist theUnshareBatFile then
		(
			fill_lv()
		)
		else
		(
			sleep 0.5
			fill_lv()
		)
	)
	
	on networkShare open do
	(
		fill_lv()
	)
	
)
createDialog networkShare width:600 height:500