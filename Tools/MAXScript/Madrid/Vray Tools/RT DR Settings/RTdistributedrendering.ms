/*
	RT DR Settings
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

Fn fn_socket_test_DLG_VRAY_RT_DR_SETTINGS theSender theEvent = 
(
	local theTempFolder = getFilenamePath (getSourceFileName())
	local THE_IP_ADDRESS = GLOBAL_DLG_VRAY_RT_DR_SETTINGS_IP_ADDRESS
	local socket = dotNetObject "System.Net.Sockets.Socket" ( dotnetclass "System.Net.Sockets.AddressFamily" ).InterNetwork ( dotnetclass "System.Net.Sockets.SocketType" ).Stream ( dotnetclass "System.Net.Sockets.ProtocolType" ).Tcp
	try
	(
		socket.connect THE_IP_ADDRESS 20206
		print "found"
		(dotnetClass "System.IO.File").WriteAllLines (theTempFolder + THE_IP_ADDRESS + ".dat") #("")
	)catch()
)

try(destroyDialog DLG_VRAY_RT_DR_SETTINGS)catch()
rollout DLG_VRAY_RT_DR_SETTINGS "Vray RT DR Settings"
( 
	local theFile = ((getDir #plugcfg)+"\\vrayrt_dr.cfg")
	local theTempFolder = getFilenamePath (getSourceFileName())
	dotNetControl lv "System.Windows.Forms.ListView" width:200 height:280 align:#center pos:[0,0]
	spinner sp_timeout "Timeout (seconds)" type:#float range:[0.1,1.5,0.3]
	label lbl_estimated_time "Estimated Time:" align:#left
	button btn_spawner_check "Check for Spawners" width:150
	checkbox cb_autostart_local_slave "Auto-start local slave"
	button btn_ok "OK" across:2 width:75
	button btn_cancel "Cancel" width:75
	
	fn getPCs =
	(
		local finalArray = #()
		local theOutput = HiddenDotNetCommand "net.exe" "view" ""
		theOutput = filterstring theOutput "\n"

		for n in theOutput do
		(
			if matchpattern n pattern:"\\*" do
			(
				local thePC = substitutestring (filterstring n " ")[1] "\\" ""
				append finalArray thePC
			)
		)
		finalArray
	)
	
	fn AlreadyAdded theList name =
	(
		for n in theList do
		(
			if matchpattern n pattern:(name + " *") do
			(
				return true
			)
		)
		return false	
	)
	
	fn refresh_estimated_time =
	(
		lbl_estimated_time.text = "Estimated Time: " + (lv.items.count * sp_timeout.value) as string + " seconds"
	)
	
	fn fill_lv Spawnercheck timeout=
	(
		lv.clear()
		local TheArray = (dotNetClass "System.IO.File").ReadAllLines theFile
		local NEW_PCs = getPCs()
		
		--Add new PCs found in network to the list
		for n in NEW_PCs do
		(
			local found = AlreadyAdded TheArray n
			if found == false do (append TheArray (n + " 0"))
		)
		
		sort TheArray
		
		-- Setup the listview
		lv.View = (dotNetClass "System.Windows.Forms.View").Details  
		lv.fullRowSelect = true  
		lv.checkBoxes=true
		
		-- Add Column Headers
		lv.Columns.add "PCs" 150
		
		if Spawnercheck == true do
		(
			for f in getFiles (theTempFolder + "\\*.dat") do (deleteFile f)
			progressStart "Checking..."
		)
		
		-- Add items to listview
		for i=1 to TheArray.count do
		(
			if Spawnercheck == true do
			(
				progressUpdate (100.0*i/(TheArray.count))
			)
				
			local theSplitArray = filterstring (TheArray[i]) " "
			local PC_NAME = theSplitArray[1]
			local THE_VALUE = theSplitArray[2]
			if PC_NAME == "autostart_local_slave"  then
			(
				if THE_VALUE == "1" do
				(
					cb_autostart_local_slave.checked = true
				)
			)
			else
			(
				local newItem = dotNetObject "System.Windows.Forms.ListViewItem" PC_NAME
				if THE_VALUE == "1" do(newItem.Checked = true)
				if Spawnercheck == true do
				(
					--Is the PC even turned on? If not mark it red, if it is turned on check if the spawner is available.
					if (finditem NEW_PCs PC_NAME) != 0 do
					(
						global GLOBAL_DLG_VRAY_RT_DR_SETTINGS_IP_ADDRESS = PC_NAME
						local BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
						DotNet.AddEventHandler BackgroundWorker "DoWork" fn_socket_test_DLG_VRAY_RT_DR_SETTINGS 
						BackgroundWorker.WorkerSupportsCancellation = true
						BackgroundWorker.RunWorkerAsync()
						sleep timeout
					)
				)
				lv.items.add newItem
			)
		)
		if Spawnercheck == true do
		(
			local FoundPCs = for f in getFiles (theTempFolder + "\\*.dat") collect (getFileNameFile f)
			for f in getFiles (theTempFolder + "\\*.dat") do (deleteFile f)
			for i=0 to (lv.items.count - 1) do
			(
				if (finditem FoundPCs lv.items.item[i].text) != 0 then
				(
					lv.items.item[i].ForeColor = (dotNetClass "System.Drawing.Color").Green
				)
				else
				(
					lv.items.item[i].ForeColor = (dotNetClass "System.Drawing.Color").Red
				)
			)
			progressEnd()
		)
	)
	
	on sp_timeout changed arg do
	(
		refresh_estimated_time()
	)
	
	on btn_spawner_check pressed do
	(
		start = timeStamp()
		fill_lv true sp_timeout.value
		end = timeStamp()
		format "Processing took % seconds\n" ((end - start) / 1000.0)
	)
	
	on btn_ok pressed do
	(
		clearlistener()

		local theTextArray = #()
		
		--Computer Names
		for i=0 to (lv.items.count - 1) do
		(
			local theItemChecked = lv.items.Item[i].checked
			local theItemName = lv.items.Item[i].text
			if theItemChecked == true then
			(
				append theTextArray (theItemName + " 1")
			)
			else
			(
				append theTextArray (theItemName + " 0")
			)
		)
		
		--Autostart Local Slave
		if cb_autostart_local_slave.checked == true then
		(
			append theTextArray "autostart_local_slave 1"
		)
		else
		(
			append theTextArray "autostart_local_slave 0"
		)
		
		(dotnetClass "System.IO.File").WriteAllLines theFile theTextArray
		
		destroyDialog DLG_VRAY_RT_DR_SETTINGS
	)
	
	on btn_cancel pressed do
	(
		destroyDialog DLG_VRAY_RT_DR_SETTINGS
	)
	
	on DLG_VRAY_RT_DR_SETTINGS open do
	(
		if not doesFileExist theFile do
		(
			local theTextArray = #()
			append theTextArray "autostart_local_slave 0"
			(dotnetClass "System.IO.File").WriteAllLines theFile theTextArray
		)
		
		fill_lv false sp_timeout.value
		refresh_estimated_time()
	)
)

--For some reason I need to run the script twice if it's the first launch. My guess it's that it's some scope issue with the BackgroundWorker that I don't quite understand
if GLOBAL_DLG_VRAY_RT_DR_SETTINGS_OPENED == undefined then
(
	global GLOBAL_DLG_VRAY_RT_DR_SETTINGS_OPENED = true
	filein (getSourceFileName())
)else(createDialog DLG_VRAY_RT_DR_SETTINGS width:200 height:400)