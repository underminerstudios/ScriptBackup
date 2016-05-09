/*
	Handplane Converter
	
	This script allows you to conver the object normal map to a tangent based normal map.
	You need to select the object and it's corresponding object normal map.
*/
-- by Norman Schaar - norman.schaar@gameloft.com

fn SendTextAssembly =
(
	source = ""
	source += "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "public class WindowsSendText\n"
	source += "{\n"
	source += "	[DllImport(\"user32.dll\")]\n"
	source += "	public static extern int SendMessage(Int32 hWnd, int wMsg, int wParam, [MarshalAs(UnmanagedType.LPStr)] string lParam);\n"
	source += "}\n"

	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.Add "System.dll"
	compilerParams.GenerateInMemory = true
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	(compilerResults.CompiledAssembly).CreateInstance "WindowsSendText"
)
global WindowsSendTextOps = if WindowsSendTextOps == undefined then SendTextAssembly() else WindowsSendTextOps

fn HP_GET_REG_VALUE key =
(
	local HANDPLANE_FOLDER_KEY
	local HANDPLANE_FOLDER_VALNAME
	local HANDPLANE_FOLDER_VALUE
	local HANDPLANE_FOLDER_TYPE
	local THE_KEY = registry.openKey HKEY_CURRENT_USER "Software\\Handplane3D LLC\\Handplane3D\\@current\\" accessRights:#readOnly key:&HANDPLANE_FOLDER_KEY
	
	if THE_KEY == true then
	(
		registry.queryValue HANDPLANE_FOLDER_KEY key type:&HANDPLANE_FOLDER_TYPE value:&HANDPLANE_FOLDER_VALUE
		registry.closeKey HANDPLANE_FOLDER_KEY
		return HANDPLANE_FOLDER_VALUE
	)
	else
	(
		return false
	)
)

fn HP_SET_REG_VALUE key data =
(
	local HANDPLANE_FOLDER_KEY
	local HANDPLANE_FOLDER_VALNAME
	local HANDPLANE_FOLDER_VALUE
	local HANDPLANE_FOLDER_TYPE
	local THE_KEY = registry.openKey HKEY_CURRENT_USER "Software\\Handplane3D LLC\\Handplane3D\\@current\\" accessRights:#all key:&HANDPLANE_FOLDER_KEY
	
	if THE_KEY == true then
	(
		if classof data == String do (registry.setValue HANDPLANE_FOLDER_KEY key #REG_SZ data)
		if classof data == integer do (registry.setValue HANDPLANE_FOLDER_KEY key #REG_DWORD data)
		registry.closeKey HANDPLANE_FOLDER_KEY
		return true
	)
	else
	(
		return false
	)
)

try(destroyDialog HandPlaneConverter)catch()
rollout HandPlaneConverter "Handplane Converter"
(
	local FBXPRESET_FILE = (pathconfig.normalizepath (getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path")) + "\\MAXScript\\Madrid\\_CommandLineTools\\handplane\\handplaneExport.fbxexportpreset"
	local HANDPLANE_EXE = (pathconfig.normalizepath (getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path")) + "\\MAXScript\\Madrid\\_CommandLineTools\\handplane\\Handplane-x64.exe"
	local THE_FBX = GetDir #userscripts + "\\tempHandplane.fbx"
		
	edittext et_normalmap "Object NormalMap:" width:400 across:2 align:#left readOnly:true labelontop:true
	button btn_browse "..." align:#right height:40
	radiobuttons rb_source "Source:" labels:#("3dsMax", "xNormal") align:#left
	button btn_process "Process" width:100
	
	fn GET_HANDPLANE_HWND =
	(
		for n in (windows.getChildrenHWND 0) where n[5] == "" AND n[3] == 0P AND n[4] == "#32770" do
		(
			for m in (windows.getChildrenHWND n[1]) where m[5] == "Handplane :" do (return n[1])
		)
		return false
	)
		
	fn sendText hwnd text_string =
	(
		windows.SendMessage hwnd (EM_SETSEL = 0x00B1) 0 1000
		WindowsSendTextOps.SendMessage hwnd (EM_REPLACESEL = 0xC2) 0 (text_string as string)
		windows.sendMessage hwnd (WM_CHAR=0x0102) (VK_RETURN=0x000D) (lparam = 0x00000000)
	)
		
	on btn_browse pressed do
	(
		local theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select Image File" --set the title
		theDialog.Multiselect = false --allow multiple files to be selected
		theDialog.Filter = "Image files (*.BMP, *.JPG, *.PNG, *.TIF, *.TGA)|*.bmp;*.jpg;*.png;*.tif;*.tga" --specify the filter
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		local theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
		
		if theFilenames[1] != undefined do (et_normalmap.text = theFilenames[1])
	)
	
	on btn_process pressed do
	(
		if selection.count == 1 then
		(
			--Close HandPlane in case it's found
			local theOldHWND = GET_HANDPLANE_HWND()
			if theOldHWND != false do (windows.sendMessage theOldHWND (WM_CLOSE = 0x0010) 0 0)
			
			local theGamma = IDisplayGamma.colorCorrectionMode
			IDisplayGamma.colorCorrectionMode = #none
			
			--The Properties
			local val_tag = 	#("tag",	"@current")
			local val_uvchan = 	#("uvchan",	0)
			local val_baked = 	#("baked",	"Autodesk 3DSMax")
			if rb_source.state == 2 do
			(
				val_baked = #("baked", "XNormal")
			)
			local val_target = 	#("target",	"Autodesk 3DS Max")
			local val_pad = 	#("pad", 	63)
			local val_format = 	#("format",	"TGA")
			local val_16bit = 	#("16bit",	1)
			local val_suffix = 	#("suffix",	"_NM")
			local val_sred = 	#("sred",	0)
			local val_sgreen = 	#("sgreen",	0)
			local val_tred = 	#("tred",	0)
			local val_tgreen = 	#("tgreen",	0)
			local val_updir = 	#("updir",	0)
			local theProperties = #(val_tag,val_uvchan,val_baked,val_target,val_pad,val_format,val_16bit,val_suffix,val_sred,val_sgreen,val_tred,val_tgreen,val_updir)
			
			local THE_INPUT_IMAGE = et_normalmap.text
			local THE_OUTPUT_PATH = getFilenamePath THE_INPUT_IMAGE
			local THE_OUTPUT_FILE = THE_OUTPUT_PATH + getfilenameFile THE_INPUT_IMAGE + val_suffix[2] + ".TGA"

			--Change properties in registry
			for n in theProperties do
			(
				if (HP_GET_REG_VALUE n[1]) != false then (HP_SET_REG_VALUE n[1] n[2])
				else 
				(
					--Run Handplane and close
					ShellLaunch HANDPLANE_EXE ""
					sleep 0.75
					local Handplane_HWND = GET_HANDPLANE_HWND()
					windows.sendMessage Handplane_HWND (WM_CLOSE = 0x0010) 0 0
					--Set registry
					HP_SET_REG_VALUE n[1] n[2]
				)
			)
			
			--Deleting the outputfile
			deleteFile THE_OUTPUT_FILE
			
			with undo off with redraw off
			(
				local theCurrentSelection = selection[1]
				local obj = copy selection[1]
				convertTo obj Editable_Poly
				obj.EditablePoly.SetSelection #Vertex #{1..(polyop.getNumVerts obj)}
				obj.EditablePoly.ConnectVertices()
				select obj
				FbxExporterSetParam "LoadImportPresetFile" FBXPRESET_FILE
				deleteFile THE_FBX
				exportFile THE_FBX #noPrompt selectedOnly:true using:FBXEXP
				delete obj
				select theCurrentSelection
			)
			
			
			--We Launch Handplane
			ShellLaunch HANDPLANE_EXE ""
			sleep 0.5
			
			local Handplane_HWND = GET_HANDPLANE_HWND()
			local Handplane_HWND_OutputFolder = for n in (windows.getChildrenHWND Handplane_HWND) where n[5] == "Output Folder" do exit with n[1]
			local Handplane_HWND_InputNormal = for n in (windows.getChildrenHWND Handplane_HWND) where n[5] == "Input Normal" do exit with n[1]
			local Handplane_HWND_InputFBX = for n in (windows.getChildrenHWND Handplane_HWND) where n[5] == "Input FBX" do exit with n[1]
			local Handplane_HWND_RENDER = for n in (windows.getChildrenHWND Handplane_HWND) where n[5] == "Render" do exit with n[1]
			
			--Send path
			sendText Handplane_HWND_InputFBX THE_FBX
			sendText Handplane_HWND_InputNormal THE_INPUT_IMAGE
			sendText Handplane_HWND_OutputFolder THE_OUTPUT_PATH
			
			--Render
			windows.postmessage Handplane_HWND_RENDER (WM_LBUTTONDOWN = 0x0201) 0 0
			windows.postmessage Handplane_HWND_RENDER (WM_LBUTTONUP 	= 0x0202) 0 0
			
			--Wait for Render to finish
			while (doesFileExist THE_OUTPUT_FILE) == false do (sleep 0.5)
			
			--Close HP
			windows.sendMessage Handplane_HWND (WM_CLOSE = 0x0010) 0 0
			
			--Delete the temp FBX
			deleteFile THE_FBX
						
			local theMaterial = selection[1].material
			if (classof theMaterial) == Standardmaterial do
			(
				if theMaterial.bumpMap == undefined do
				(
					enableHardwareMaterial theMaterial on
					showHWTextureMap theMaterial on
					theMaterial.bumpMapAmount = 100
					local NormalMap = Normal_Bump()
					theMaterial.bumpMap = NormalMap
					local theNormal = bitmaptexture()
					theNormal.filename = THE_OUTPUT_FILE
					theMaterial.bumpMap.normal_map = theNormal
				)
			)
			
			IDisplayGamma.colorCorrectionMode = theGamma
		)
		else
		(
			messagebox "you have nothing selected! You must select the object!"
		)
	)
)
createDialog HandPlaneConverter width:460