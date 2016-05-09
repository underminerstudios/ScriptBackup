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

fn getMaxVersion =
(
	VersionNumber = (maxversion())[1] as string
	
	FinalVersion = "" 
	if matchpattern VersionNumber pattern:"14*" do
	(
		FinalVersion = "2012"
	)
	if matchpattern VersionNumber pattern:"13*" do
	(
		FinalVersion = "2011"
	)
	if matchpattern VersionNumber pattern:"12*" do
	(
		FinalVersion = "2010"
	)
	if matchpattern VersionNumber pattern:"11*" do
	(
		FinalVersion = "2009"
	)
	if matchpattern VersionNumber pattern:"10*" do
	(
		FinalVersion = "2008"
	)
	if matchpattern VersionNumber pattern:"9*" do
	(
		FinalVersion = "9"
	)
	
	return FinalVersion
)

fn is64bit =
(
	bit64 = false
	if doesFileExist ((getDir #maxroot) + "\\max64.task") do
		bit64 = true
	
	bit64
)

fn getWindowsVersion = 
(
	TheDosCommandOutput = (HiddenDotNetCommand "cmd.exe" ("VER") "")
	AsArray = (filterstring TheDosCommandOutput "\n")
	return AsArray[1]
)

fn isWindows7 = 
(
	local theWindows = getWindowsVersion()
	theWindows = filterstring theWindows " "
	theWindows = theWindows[theWindows.count]
	theWindows = substitutestring theWindows "]" ""
	
	local win7 = false
	if matchpattern theWindows pattern:("6.1.*") == true do
		win7 = true
	
	win7
)
fn testest = 
(



		

)

try(destroyDialog dlg_irrCollada_install)catch()
rollout dlg_irrCollada_install "irrCollada Installer"
(
	local DepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local nircmdcCommandLineTool = pathconfig.normalizepath (DepotPath + "\\MAXScript\\Madrid\\_CommandLineTools\\NirCmd_x64\\nircmdc.exe")
	
	local Windows7 = isWindows7()
	local theMaxVersion = getMaxVersion()
	local theMax64bit = is64bit()
	local rootPath = getFilenamePath  (getSourceFileName())
		
	local thePluginFilex86 = rootPath + "\\files\\IrrColladaMax12_32bits.dle"
	local thePluginFilex64 = rootPath + "\\files\\IrrColladaMax12_64bits.dle"
	local additionalFilesPath = rootPath + "\\files\\win7\\"
	local theBatFile = rootPath + "\\theBatFile.bat"
	local theBatFileArray = #()
	local theLaunchBatFile = rootPath + "\\launch.bat"
	local theLaunchBatFileArray = #()
	local restartRequired = false
		
		
	button btn_install "Install" width:100 height:30
		
	on btn_install pressed do
	(
		deleteFile theBatFile

		if windows7 == true then
		(
			if theMaxVersion == "2012" then
			(
				if theMax64bit == true do
				(
					local thePluginFile = (getDir #maxRoot) + "\\plugins\\IrrColladaMax12_64bits.dle"
					if doesFileExist thePluginFile == false do
					(
						--we copy the file
						local theLine = "copy " + "\"" + pathconfig.normalizepath thePluginFilex64 + "\"" + " " + "\"" + pathconfig.normalizepath thePluginFile + "\""
						append theBatFileArray theLine
						restartRequired = true
					)
				)
				if theMax64bit == false do
				(
					local thePluginFile = (getDir #maxRoot) + "\\plugins\\IrrColladaMax12_32bits.dle"
					if doesFileExist thePluginFile == false do
					(
						--we copy the file
						local theLine = "copy " + "\"" + pathconfig.normalizepath thePluginFilex86 + "\"" + " " + "\"" + pathconfig.normalizepath thePluginFile + "\""
						append theBatFileArray theLine
						restartRequired = true
					)
				)
			)
			else
			(
				MessageBox "ERROR: You do not have 3dsMax 2012 installed!"
			)
			
			--Check for missing files
			for f in (getFiles (additionalFilesPath + "\\*.*")) do
			(
				local theFile = pathconfig.normalizepath f
				local theTargetFile = sysInfo.windowsdir + "\\" + getFileNameFile theFile + getFileNameType theFile
				if doesFileExist theTargetFile == false do
				(
					local theLine = "copy " + "\"" + theFile + "\"" + " " + "\"" + theTargetFile + "\""
					append theBatFileArray theLine
				)
			)
		)
		else
		(
			MessageBox "ERROR: It seems yo do not have Windows 7 installed!"
		)
		if theBatFileArray.count != 0 do
		(
			--Write Launch Bat file
			append theLaunchBatFileArray ("\"" + pathconfig.normalizepath nircmdcCommandLineTool + "\"" + " elevate " + "\"" + pathconfig.normalizepath theBatFile + "\"")
			(dotnetClass "System.IO.File").WriteAllLines theLaunchBatFile theLaunchBatFileArray
			
			
			--Write Bat
			(dotnetClass "System.IO.File").WriteAllLines theBatFile theBatFileArray
			--Run bat
			shellLaunch theLaunchBatFile ""
			
			if restartRequired == true do
			(
				local theOutput = queryBox "A restart of 3dsMax is needed. Do you want to restart now?"
				if theOutput == true do
				(
					shellLaunch ((getDir #maxRoot) + "\\3dsmax.exe") ""
					quitMAX #noPrompt
				)
			)
		)
	)
	
	on dlg_irrCollada_install open do
	(
		deleteFile theBatFile
		deleteFile theLaunchBatFile
	)
	
	on dlg_irrCollada_install close do
	(
		deleteFile theBatFile
		deleteFile theLaunchBatFile
	)
	
)
createDialog dlg_irrCollada_install