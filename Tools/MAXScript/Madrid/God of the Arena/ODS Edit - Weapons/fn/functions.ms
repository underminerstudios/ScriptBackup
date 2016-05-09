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

fn hair_DX9_preview theMaterial =
(
	if (classof theMaterial) == Standardmaterial do
	(
		local theDX = DirectX_9_Shader()
		theDX.effectfile = "Q:\\shaders\\hair\\hair_preview.fx"
		theDX.name = theMaterial.name

		--Diffuse
		if (classof theMaterial.DiffuseMap) == bitmapTexture AND (doesFileExist theMaterial.DiffuseMap.filename) do
		(
			local theFileName = theMaterial.DiffuseMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theDiffuse = bitmapTexture()
				theDiffuse.filename = theFileName
				theDx.diffuseMap = theDiffuse.bitmap
			)
		)
		
		--Normal
		if classof theMaterial.BumpMap == bitmapTexture do
		(
			local theFileName = theMaterial.BumpMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormalMap = bitmapTexture()
				theNormalMap.filename = theFileName
				theDx.normalMap = theNormalMap.bitmap
			)
		)
		if (classof theMaterial.BumpMap) == Normal_Bump do
		(
			local theFileName = theMaterial.BumpMap.normal_map.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormalMap = bitmapTexture()
				theNormalMap.filename = theFileName
				theDx.normalMap = theNormalMap.bitmap
			)
		)
		
		local theSpecMap = bitmapTexture()
		theSpecMap.filename = "Q:\\shaders\\hair\\SPEC.tga"
		theDX.specPalette = theSpecMap.bitmap
		
		local theBarlaMap = bitmapTexture()
		theBarlaMap.filename = "Q:\\shaders\\hair\\BARLA.tga"
		theDX.barlaPalette = theBarlaMap.bitmap
		
		theDX.tintColor = color (0.745 * 255.0)	(0.392 * 255.0) (0.188 * 255.0) 0.0
		
		replaceInstances theMaterial theDX
	)
	
	if (classof theMaterial) == DirectX_9_Shader do
	(
		local theSTD = Standardmaterial()
		theSTD.name = theMaterial.name
		
		--New DiffuseMap
		if theMaterial.diffuseMap != undefined do
		(
			local theFileName = theMaterial.diffuseMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theDiffuse = bitmaptexture()
				theDiffuse.filename = theFileName
				theSTD.DiffuseMap = theDiffuse
			)
		)
		
		--New Normal
		if theMaterial.normalMap != undefined do
		(
			local theFileName = theMaterial.normalMap.filename
			if theFileName != undefined AND (doesFileExist theFileName) == true do
			(
				local theNormal = bitmaptexture()
				theNormal.filename = theMaterial.normalMap.filename
				theSTD.bumpMap = theNormal
				theSTD.bumpMapAmount = 100
			)
		)
		showTextureMap theSTD true
		
		replaceInstances theMaterial theSTD
	)
)

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

fn getAssetBaseList =
(
	dotNet.loadAssembly "system.xml"
	local xmlDoc = dotNetObject "system.xml.xmlDocument"
	xmlDoc.load "P:\\data\\levels\\CustomPartsLib.libclara" --Hardcoded path
	local docEle = xmlDoc.documentElement
	local itemIter = (xmldoc.selectnodes "//root")
	local theArray = #()
	for i=0 to itemIter.ItemOf[0].ChildNodes.count-1 do
	(
		local theName = itemIter.ItemOf[0].ChildNodes.ItemOf[i].Attributes.itemOf["name"].value
		if matchpattern theName pattern:"Base*" do
			append theArray theName
	)
	sort theArray
	return theArray
)

fn getSpecificSheet theXML TheSheetTitle =
(
	local xmlDoc = theXML

	local docEle = xmlDoc.documentElement

	for i=0 to docEle.ChildNodes.count-1 do
	(
		if docEle.ChildNodes.itemOf[i].name == "office:body" do
		(
			for j=0 to docEle.ChildNodes.itemOf[i].ChildNodes.ItemOf[0].ChildNodes.count - 1 do
			(
				local theNode = docEle.ChildNodes.itemOf[i].ChildNodes.ItemOf[0].ChildNodes.ItemOf[j]
				if theNode.name == "table:table" do
				(
					if theNode.Attributes.itemOf["table:name"].value == TheSheetTitle do
					(
						return theNode
					)
				)
			)
		)
	)
	return false
)

fn getMaterialsCustomParts =
(
	dotNet.loadAssembly "system.xml"
	local xmlDoc = dotNetObject "system.xml.xmlDocument"
	xmlDoc.load "P:\\data\\levels\\Materials.libclara" --Hardcoded path
	local docEle = xmlDoc.documentElement
	local itemIter = (xmldoc.selectnodes "//root")
	local theArray = #()
	for i=0 to itemIter.ItemOf[0].ChildNodes.count-1 do
	(
		local theFolderNode = itemIter.ItemOf[0].ChildNodes.ItemOf[i]
		local theFolderName = theFolderNode.Attributes.itemOf["name"].value
		if theFolderName == "Mat_CustomParts" do
		(
			for j=0 to theFolderNode.ChildNodes.count-1 do
			(
				append theArray theFolderNode.ChildNodes.ItemOf[j].Attributes.itemOf["name"].value
			)
		)
	)
	sort theArray
	return theArray
)

fn getHairColor theMaterialName =
(
	dotNet.loadAssembly "system.xml"
	local xmlDoc = dotNetObject "system.xml.xmlDocument"
	xmlDoc.load "P:\\data\\levels\\Materials.libclara" --Hardcoded path
	local docEle = xmlDoc.documentElement
	local itemIter = (xmldoc.selectnodes "//root")
	for i=0 to itemIter.ItemOf[0].ChildNodes.count-1 do
	(
		local theFolderNode = itemIter.ItemOf[0].ChildNodes.ItemOf[i]
		local theFolderName = theFolderNode.Attributes.itemOf["name"].value
		if theFolderName == "Mat_CustomParts" do
		(
			for j=0 to theFolderNode.ChildNodes.count-1 do
			(
				if theFolderNode.ChildNodes.ItemOf[j].Attributes.itemOf["name"].value == theMaterialName do
				(
					local test = theFolderNode.ChildNodes.ItemOf[j].GetElementsByTagName "data"
					for k=0 to test.count-1 do
					(
						for l=0 to test.ItemOf[k].Attributes.count-1 do
						(
							if test.ItemOf[k].Attributes.itemOf[l].value == "tintColor" do
							(
								local theColor = test.ItemOf[k].Attributes.itemOf["val"].value
								theColor = filterstring theColor ","
								for m=1 to theColor.count do (theColor[m] = theColor[m] as float)
								theColor = color (theColor[1] * 255.0) (theColor[2] * 255.0) (theColor[3] * 255.0)
								return theColor
							)
						)
					)
				)
			)
		)
	)
	return false
)

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
	
fn getHairsListPIG =
(
	local theFiles = getFilesRecursive "P:\\data\\gfx3D\\hairs\\" "*.dae"
	local thePigs = for n in theFiles collect (getFileNameFile n + ".pig")
	sort thePigs
	thePigs
)
	
fn getHairsList_NM_TGA =
(
	local theFiles = getFilesRecursive "P:\\data\\gfx3D\\hairs\\" "*_nm.tga"
	theFiles
)

fn getHairsList_DF_TGA =
(
	local theFiles = getFilesRecursive "P:\\data\\gfx3D\\hairs\\" "*_df.tga"
	theFiles
)

fn getWeaponsListPIG =
(
	local theFiles = getFilesRecursive "P:\\data\\gfx3D\\weapons\\" "*.dae"
	local thePigs = for n in theFiles collect (getFileNameFile n + ".pig")
	sort thePigs
	thePigs
)

fn getWeaponsList_NM_TGA =
(
	local theFiles = getFilesRecursive "P:\\data\\gfx3D\\weapons\\" "*_nm.tga"
	theFiles
)

fn getWeaponsList_DF_TGA =
(
	local theFiles = getFilesRecursive "P:\\data\\gfx3D\\weapons\\" "*_df.tga"
	theFiles
)

fn getColumnIndex theXML TheSheetTitle theColumnTitle=
(
	local theSheet = getSpecificSheet theXML TheSheetTitle
	for i=0 to theSheet.ChildNodes.count-1 do
	(
		local theNode01 = theSheet.ChildNodes.itemOf[i]
		for j=0 to theNode01.ChildNodes.count-1 do
		(
			for k=0 to theNode01.ChildNodes.itemOf[j].ChildNodes.count-1 do
			(
				if theNode01.ChildNodes.itemOf[j].ChildNodes.itemOf[k].innerText == theColumnTitle do
				(
					return #(i,j,k)
				)
			)
		)
	)
	return false
)

fn getList theXML TheSheetTitle theColumnTitle =
(
	local theIndex = getColumnIndex theXML TheSheetTitle theColumnTitle
	local theSheet = getSpecificSheet theXML TheSheetTitle
	local theArray = #()

	for i=theIndex[1]+1 to theSheet.ChildNodes.count-1 do
	(
		local theErrorCheck = theSheet.ChildNodes.ItemOf[i].ChildNodes.itemOf[0].innerText
		if matchpattern theErrorCheck pattern:"Error*" then
		(
			return theArray
		)
		else
		(
			local theText = theSheet.ChildNodes.ItemOf[i].ChildNodes.itemOf[theIndex[2]].innerText
			append theArray theText
		)
	)
	return theArray
)

fn getMaxFile thePath objectName =
(
	local theFiles = getFilesRecursive thePath "*.max"
	for f in theFiles do
	(
		local theObjects = getMAXFileObjectNames f quiet:true
		for n in theObjects do
		(
			if n == objectName do
			(
				return f
			)
		)
	)
	false
)

fn setValue theXML theXMLPath TheSheetTitle theColumnTitle theRowColumnTitle theRowText theValue=
(
	local theSheet = getSpecificSheet theXML TheSheetTitle
	local ColumnIndex_TargetColumn = getColumnIndex theXML TheSheetTitle theColumnTitle
	local ColumnIndex_Row = getColumnIndex theXML TheSheetTitle theRowColumnTitle
	
	for i=ColumnIndex_Row[1]+1 to theSheet.ChildNodes.count-1 do
	(
		if theSheet.ChildNodes.ItemOf[i].ChildNodes.itemOf[ColumnIndex_Row[2]].innerText == theRowText do
		(
			theSheet.ChildNodes.ItemOf[i].ChildNodes.itemOf[ColumnIndex_TargetColumn[2]].ChildNodes.itemof[0].innerText = theValue
			theXML.save theXMLPath
			return true
		)
	)
	return false

)

fn addNode theXML theXMLPath TheSheetTitle theColumnTitle theName=
(
	local theIndex = getColumnIndex theXML TheSheetTitle theColumnTitle
	local theSheet = getSpecificSheet theXML TheSheetTitle
	
	local theLastNode = undefined
	for i=theIndex[1]+1 to theSheet.ChildNodes.count-1 do
	(
		local theErrorCheck = theSheet.ChildNodes.ItemOf[i].ChildNodes.itemOf[0].innerText
		if matchpattern theErrorCheck pattern:"Error*" AND theLastNode == undefined then
		(
			theLastNode = theSheet.ChildNodes.ItemOf[i-1]
		)
	)
	if theLastNode != undefined then
	(
		local newNode = theLastNode.cloneNode true
		newNode.ChildNodes.itemOf[theIndex[2]].ChildNodes.itemof[0].innerText = theName
		showMethods theLastNode
		theSheet.insertAfter newNode theLastNode
		
		theXML.save theXMLPath
		return true
	)
	return false
)

fn findNode theIndex theSheet theNodeName =
(
	for i=theIndex[1]+1 to theSheet.ChildNodes.count-1 do
	(
		if theSheet.ChildNodes.itemOf[i].ChildNodes.itemOf[theIndex[2]].ChildNodes.itemof[0].innerText == theNodeName do
		(
			return theSheet.ChildNodes.itemOf[i]
		)
	)
	false
)

fn deleteNode theXML theXMLPath TheSheetTitle theColumnTitle theNodeName =
(
	local theIndex = getColumnIndex theXML TheSheetTitle theColumnTitle
	local theSheet = getSpecificSheet theXML TheSheetTitle

	local theNode = findNode theIndex theSheet theNodeName
	
	if theNode != false do
	(
		theSheet.RemoveChild theNode
		theXML.save theXMLPath
		return true
	)
	false
)

fn extractODS theODSFile theXMLFile =
(
	local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local Exe7za = theDepotPath + "\\MAXScript\\Madrid\\_CommandLineTools\\7za\\7za.exe"
	HiddenDotNetCommand Exe7za ("e " + "\"" + theODSFile + "\"" + " -o" + "\"" + getFilenamePath theODSFile + "\"" + " " + "content.xml") ""
	renameFile ((getFilenamePath theODSFile) + "\\content.xml") theXMLFile
)

fn repackODS theODSFile theXMLFile =
(
	local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local Exe7za = theDepotPath + "\\MAXScript\\Madrid\\_CommandLineTools\\7za\\7za.exe"
	renameFile theXMLFile ((getFilenamePath theODSFile) + "\\content.xml")
	HiddenDotNetCommand Exe7za ("a " + "\"" + theODSFile + "\"" + " " + "\"" + ((getFilenamePath theODSFile) + "\\content.xml") + "\"") ""
	deleteFile ((getFilenamePath theODSFile) + "\\content.xml")
)
