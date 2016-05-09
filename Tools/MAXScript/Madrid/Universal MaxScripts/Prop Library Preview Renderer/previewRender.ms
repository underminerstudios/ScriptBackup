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


try(destroyDialog rl_create_preview)catch()
rollout rl_create_preview "Create Preview"
(
	local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local ConvertExe = theDepotPath + "\\MAXScript\\Madrid\\_CommandLineTools\\ImageMagick\\convert.exe"
	
	
	Fn LR_CaptureRenderAspectViewport theCurrentSelected = 
	(
		local ViewCap=undefined			
		local cv = getViewSize()
		local ratio = undefined

		case of 
		( 
			(cv.x > cv.y):(ratio = cv.y/cv.x)
			(cv.x = cv.y):(ratio = 1)			
			(cv.x < cv.y):(ratio = cv.x/cv.y)
		)

		
		VptDib =gw.getViewportDib();
		ViewCap = bitmap 512 512 color:white
		ViewportRatio = VptDib.width/VptDib.height as float
		RenderRatio = 512/512 as float
		
		case of
		(
			(ViewportRatio <= RenderRatio):(
			CapturetoRenderHeightRatio =VptDib.width/RenderRatio as float
			TopEdge = ((VptDib.Height-CapturetoRenderHeightRatio)/ 2.0) as integer
			FullViewcap = bitmap vptdib.width CapturetoRenderHeightRatio color:white
			pasteBitmap VptDib FullViewcap (box2 0 TopEdge VptDib.width VptDib.height) [0,0]
			Copy FullViewcap ViewCap)
			(ViewportRatio > RenderRatio):(
			CapturetoRenderHeightRatio =VptDib.height*RenderRatio as float
			LeftEdge = ((VptDib.width-CapturetoRenderHeightRatio)/ 2.0) as integer
			FullViewcap = bitmap CapturetoRenderHeightRatio VptDib.height color:white
			pasteBitmap VptDib FullViewcap (box2 LeftEdge 0 VptDib.width VptDib.height) [0,0]
			Copy FullViewcap ViewCap)
			default:()
		)
		close VptDib
		gc light:true


		ViewCap.filename = maxfilepath + maxfilename + "_" + theCurrentSelected + ".png"
		close ViewCap
		save ViewCap
		HiddenDotNetCommand ("\"" + ConvertExe + "\"") (" " + "\"" + ViewCap.filename + "\"" + " -colors 256 -depth 8 -resize " + 128 as string + " " + "\"" +ViewCap.filename + "\"") ""
	)
	
	local theCurrentSelected = undefined
	bitmap the_bmp width:128 height:128
	button btn_render_preview "Render Preview" width:128
	
	on btn_render_preview pressed do
	(
		if selection.count == 1 then
		(
			
			LR_CaptureRenderAspectViewport selection[1].name
			the_bmp.bitmap = openbitmap (maxfilepath + maxfilename + "_" + selection[1].name + ".png")
		)
		else
		(
			messagebox "You need to select an object"
		)
	)
)
createDialog rl_create_preview