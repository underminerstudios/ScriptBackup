/*
	GIF Creation function
	
	CreateGif <ConvertExe> <GifFilenamePath> <PixelWidth> <nth>
	
    ConvertExe
        type:string
        It's the full path to the convert.exe command line tool
	
	GifFilenamePath
		type: string
		It's the full path to the output GIF

	PixelWidth
		type: integer
		It's the width of the output GIF
	
	nth
		type: integer
		This value will only render the nth frame. If the value is 2, for example, then every 2nd frame will be rendered.
		This is to avoid big gif files for long animations.
*/
--by Norman Schaar - norman.schaar@gameloft.com

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

fn CreateGif ConvertExe TheFileName PixelWidth nth=
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

CreateGif ("D:\\SVN\\art_tools\\MAXScript\\Madrid\\_MAXScriptFunctions\\GifCreations\\convert.exe") (maxfilepath + (GetFileNameFile maxfilename) + ".GIF") 200 2