macroScript GLL_GrabViewport2 category:"Gameloft" ButtonText:"Grabviewport"
(
	/* Grabviewport v2.5 by Leslie Van den Broeck
		for use in 3dsmax 9 first install the Avguard extension found here http://www.scriptspot.com/3ds-max/plugins/avguard-maxscript-extension-package
		Credits to : Borislav Petrov (MaxScript reference), denisT (Dotnet + mxs info), Kostadin Kotev (Alpha Masking technique), Rotem Shiffman (Window button unchecking technique), polycount.org and scriptspot communities for the feedback and suggestions
	*/	
	
	rollout FileTagRollout "FileTag Tool"
	(
	)
	rollout CreatePresetRollout "Create Preset"
	(
	)
	fn ParseFilename &filepath &filename = ()
	fn ParseFilepath &filepath &filename = ()
	fn ResizeViewport = ()
	fn CaptureStates statelist = ()
	fn ApplySettings = ()
	fn LoadSettings filepath category=()
	fn SaveSettings filepath category=()
	fn TweakZdepth = ()
	fn TweakAO = ()
	struct scenematerial(_object,_objectmat)
	struct scenelight(_light,_lightstate)
	struct sceneinfo(_Width,_Height,_BgColor,_bVHWS,_VAO,_bVS,_Transparency,_SFX,_MaxVersion,_bVC,_SFColor) 
	struct stateslist(_Alpha,_Color,_Wire,_Zdepth,_SSAO)
	global m_bAxisChecked
	struct ShowWorldAxisStr
	(
			fn setCheckBoxState hwnd state = 
			(	
				local BN_CLICKED =0
				local BM_SETCHECK = 241
				local WM_COMMAND = 273
				
				local parent = UIAccessor.getParentWindow hwnd
				local id = UIAccessor.getWindowResourceID hwnd
				
				windows.sendMessage hwnd BM_SETCHECK (if state then 1 else 0) 0
				windows.sendMessage parent WM_COMMAND ((bit.shift BN_CLICKED 16) + id) hwnd	
				ok
			),
			fn getCheckBoxState hwnd = 
			(	
				local BM_GETCHECK = 240
				
				result = case (windows.sendMessage hwnd BM_GETCHECK 0 0) of (
				0: false
				1: true
				0: #indeterminate
				)
				--print result
				return result
				
			),
			fn getButtonHwnd hnd =
			(
				for i in (windows.getChildrenHWND hnd) where matchPattern i[5] pattern:"Display World*" do return i[1]
				0
			),
			fn ChangeTab hnd =
			(
				TCM_SETCURFOCUS = 0x1330
				for kidHWND in (UIAccessor.GetChildWindows hnd) where ((UIAccessor.GetWindowClassName kidHWND) == "SysTabControl32") do
				(
					UIAccessor.SendMessage kidHWND TCM_SETCURFOCUS 2 0 
				)
			),	
			fn ShowWorldAxisOn = 
			(
				local hnd = dialogmonitorops.getwindowhandle()
				ShowWorldAxisStr.ChangeTab hnd
				ShowWorldAxisStr.setCheckBoxState (ShowWorldAxisStr.getButtonHwnd hnd) on
				uiaccessor.pressButtonByName hnd "OK"
				true
			),
			
			fn ShowWorldAxisOff = 
			(
				local hnd = dialogmonitorops.getwindowhandle()
				ShowWorldAxisStr.ChangeTab hnd
				ShowWorldAxisStr.setCheckBoxState (ShowWorldAxisStr.getButtonHwnd hnd) off
				uiaccessor.pressButtonByName hnd "OK"
				true
			),
			fn ShowWorldAxisState = 
			(
				local hnd = dialogmonitorops.getwindowhandle()
				ShowWorldAxisStr.ChangeTab hnd
				m_bAxisChecked = ShowWorldAxisStr.getCheckBoxState(ShowWorldAxisStr.getButtonHwnd hnd)
				uiaccessor.pressButtonByName hnd "OK"
				true
			),
			fn ShowWorldAxis state =
			(
					DialogMonitorOPS.unRegisterNotification id:#ShowWorldAxis
					DialogMonitorOPS.enabled = off
					DialogMonitorOPS.enabled = on	
					DialogMonitorOPS.RegisterNotification (if state then ShowWorldAxisStr.ShowWorldAxisOn else ShowWorldAxisStr.ShowWorldAxisOff) id:#ShowWorldAxis
					actionMan.executeAction 0 "40108" 
					DialogMonitorOPS.unRegisterNotification id:#ShowWorldAxis
					DialogMonitorOPS.enabled = off
			),
			fn GetWorldAxisState =
			(
					DialogMonitorOPS.unRegisterNotification id:#GetWorldAxisState
					DialogMonitorOPS.enabled = off
					DialogMonitorOPS.enabled = on
					DialogMonitorOPS.RegisterNotification (ShowWorldAxisStr.ShowWorldAxisState) id:#GetWorldAxisState
					actionMan.executeAction 0 "40108" 
					DialogMonitorOPS.unRegisterNotification id:#GetWorldAxisState
					DialogMonitorOPS.enabled = off
			)
			
	)
	
	source = "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "using System.Text;\n"
	source += "class assembly\n"
	source += "{\n"
	source += " [DllImport(\"user32.dll\")]\n"
	source += " public static extern bool SetWindowPos(IntPtr hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);\n"
	source += " [DllImport(\"user32.dll\")]\n"
	source += "	static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);\n"
	source += "	public struct RECT\n"
	source += "	{\n"
	source += "	 public int Left;\n"
	source += "	 public int Top;\n"
	source += "	 public int Right;\n"
	source += "	 public int Bottom;\n"
	source += "	}\n"
	source += "	public int[] getWindowRect(IntPtr hWnd)\n"
	source += "	{\n"
	source += "	 RECT rect;\n"
	source += "	 if ( GetWindowRect(hWnd, out rect) )\n"
	source += "	 {\n"
	source += "	 return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };\n"
	source += "	 }\n"
	source += "	 return null;\n"
	source += "	}\n"
	source += "}\n"
	
	local csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	local compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.GenerateInMemory = on
	local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	global assembly = compilerResults.CompiledAssembly.createInstance "assembly"
	
	local m_scenematarr = #()
	local m_scenelightarr = #()
	local m_nomatarr = #()
	local m_sceneinfo
	local m_stateslist = stateslist _Alpha:false _Color:false _Wire:false _Zdepth:false _SSAO:false
	local m_width, m_height, m_ratio ,m_sfratio
	local m_viewportbmp , m_alphabmp 
	local m_savepath, m_filename, m_bmpname
	local m_depthlightbegin , m_depthlightend , m_depthlight
	if (((maxVersion())[1] / 1000) > 11) then
	local m_vps = maxops.getViewportShadingSettings()
	local m_filetypearr = #(#(".PNG", ".TGA", ".BMP"),#(".AVI",".PNG", ".TGA", ".BMP"))
	local m_Filepathtagsarr = #("#font" , "#Scene" , "#Export", "#import", "#help", "#expression", "#preview", "#image", "#Sound", "#plugcfg", "#maxstart", "#vpost", "#drivers", "#autoback", "#matlib", "#userscripts", "#startupScripts", "#defaults", "#renderPresets", "#ui", "#maxroot", "#renderoutput", "#animations", "#archives", "#Photometric", "#renderassets", "#userScripts", "#userMacros", "#userStartupScripts", "#temp", "#userIcons", "#maxData", "#downloads", "#proxies", "#assemblies", "#pageFile" , "#hardwareShadersCache")
	local m_Filenametagsarr = #("#Date","#Time", "#UniqueNumber", "#MaxFileName","#ViewportName")
	local m_NoDialog = false
	local m_capturetype = 1
	local m_Inipath = getdir #userscripts + "\\GLL_Launcher\\Grabviewport.ini"
	local m_presetspath =  getdir #userscripts  + "\\GLL_Launcher\\Grabviewportpresets.ini"
	global GetOriginalState
	fn GetOriginalState = 
	(
		m_sceneinfo = sceneinfo _Width:(gw.getWinSizeX()) _Height:(gw.getWinSizeY()) _BgColor:(GetUIColor 41) _SFColor:(GetUIColor 5) _bVHWS:(false) _VAO:(false)  _bVS:(false) _Transparency:(viewport.GetTransparencyLevel()) _SFX:(SceneEffectLoader.IsSceneEffectsEnabled()) _MaxVersion:(((maxVersion())[1] / 1000)) _bVC:(false)
		m_ratio = (gw.getWinSizeX() as float)/(gw.getWinSizeY() as float) as float
		if (m_sceneinfo._MaxVersion > 10 and ViewCubeOps != undefined) then (m_sceneinfo._bVC = ViewCubeOps.Visibility)
		if (m_sceneinfo._MaxVersion > 11) then 
		(
			
			m_sceneinfo._bVHWS = m_vps.ActivateViewportShading
			m_sceneinfo._VAO =  m_vps.AmbientOcclusionMode
			m_sceneinfo._bVS =  m_vps.ShadowsActive
			--print m_sceneinfo._MaxVersion
		)
		if (m_sceneinfo._MaxVersion > 9) then(ShowWorldAxisStr.GetWorldAxisState())
		SetUIColor 5 black
		m_sfratio = (renderwidth as float) / (renderheight as float)
		m_scenematarr = #()
		m_scenelightarr = #()
		for obj in objects do
		(
			if superclassof obj == GeometryClass then
			(
				append m_scenematarr (scenematerial _object:obj _objectmat:obj.mat)
			)
		)
		for i in lights do
		(
			append m_scenelightarr (scenelight _light:i _lightstate:i.enabled)
		)
		print "state retrieved"
	)

	fn SetOriginalState =
	(
		----print "Restoring Original State"
		actionMan.executeAction 0 "549"--ViewportShading to Smooth + Highlighted
		SetUIColor 41 m_sceneinfo._BgColor
		SetUIColor 5 m_sceneinfo._SFColor
		colorMan.repaintUI #repaintAll
		viewport.SetShowEdgeFaces false
		SceneEffectLoader.EnableSceneEffects m_sceneinfo._SFX 
		viewport.SetTransparencyLevel (m_sceneinfo._Transparency)
		if (m_sceneinfo._MaxVersion > 11) then
		(
			m_vps.AmbientOcclusionMode = m_sceneinfo._VAO
			m_vps.ActivateViewportShading = m_sceneinfo._bVHWS
			m_vps.ShadowsActive = m_sceneinfo._bVS
		)
		for i=1 to m_scenematarr.count do
		(
			if isvalidnode m_scenematarr[i]._object then
			m_scenematarr[i]._object.mat = m_scenematarr[i]._objectmat
			----print "material restored" 
		)
		for i=1 to m_scenelightarr.count do
		(
			m_scenelightarr[i]._light.enabled = m_scenelightarr[i]._lightstate
		)
		for i=1 to m_nomatarr.count do
		(
			if isvalidnode m_nomatarr[i] then
			m_nomatarr[i].mat = undefined
		)
		ResizeViewport m_sceneinfo._Width m_sceneinfo._Height
		hwnd = windows.getmaxhwnd()
		WM_EXITSIZEMOVE = 0x232
		windows.sendmessage hwnd WM_EXITSIZEMOVE 0 0 -- force to update views client area
	)
	fn ToggleUIItems bstate=	
	(	

		if (m_sceneinfo._MaxVersion > 10 and ViewCubeOps != undefined) then
		(
				if bstate then
				(
					ViewCubeOps.Visibility = m_sceneinfo._bVC
				)
				else
				(
					ViewCubeOps.Visibility = false
				)
		)
		if (m_sceneinfo._MaxVersion > 11) then
		(
			if bstate then
			(
				ViewportButtonMgr.EnableButtons = true
			)
			else
			(
				ViewportButtonMgr.EnableButtons = false
				max tool maximize
				max tool maximize
			)
		)
		if (m_sceneinfo._MaxVersion > 9) then
		(
			if bstate and m_bAxisChecked then
			( 
				ShowWorldAxisStr.ShowWorldAxis on
			)
			else
			(
				ShowWorldAxisStr.ShowWorldAxis off
			)
		)
	)
	fn AddAlpha &basebmp &alphabmp =
	(
		tempBMP = bitmap basebmp.width basebmp.height
				
		for i = 1 to basebmp.height do
		(
			AR_thepixels_A = Getpixels basebmp [0,i] basebmp.width
			AR_thepixels_B = Getpixels alphabmp [0,i] alphabmp.width
					
			for j = 1 to AR_thepixels_A.count do
			(
				swap AR_thepixels_A[j].a AR_thepixels_B[j].r
			)
				setpixels tempBMP [0,i] AR_thepixels_A
		)
			basebmp = tempBMP
	)
	fn ResizeViewport width height=
	(
		compensation = 4
		ViewportHwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
		assembly.setwindowpos (dotNetObject "System.IntPtr" ViewportHwnd) 0 0 0 (width+compensation) (height+compensation) 0x0026
		ForcecompleteRedraw()
	)
	fn ScaleBitmap &basebmp width height  =
	(
		DNGraphics = dotNetClass "System.Drawing.graphics"
		DNClipboard = dotNetClass "System.Windows.Forms.Clipboard"
		DNRectangle = dotNetClass "System.Drawing.Rectangle"
		
		setClipboardBitmap basebmp
		DNbmp = DNClipboard.GetImage()
		
		g = DNGraphics.FromImage(DNbmp);
		g.CompositingQuality = (dotnetclass "system.drawing.drawing2d.compositingquality").HighQuality
		g.SmoothingMode = (dotnetclass "system.drawing.drawing2d.smoothingmode").HighQuality 
		g.InterpolationMode = (dotnetclass "system.drawing.drawing2d.Interpolationmode").HighQualityBicubic 
		newBmp=dotNetObject "system.drawing.bitMap" width height ((dotNetClass "system.Drawing.Imaging.PixelFormat").Format32bppArgb)
		r = (dotNetObject DNRectangle 0 0 width height)
		g1 =  DNGraphics.FromImage(newBmp);
		g1.DrawImage DNbmp  r
		DNClipboard.SetImage newBmp
		basebmp = getclipboardBitmap()
		
	)
	fn CropToSafeframes &basebmp = 
	(
		m_sfratio = (renderwidth as float) / (renderheight as float)
		sfwidth = ((((basebmp.height)) as float)*m_sfratio)as integer
		sfx = (((basebmp.width as float )/2) - ((sfwidth as float)/2)) 
		tempbmp = bitmap (sfwidth) (basebmp.height)
		pasteBitmap basebmp tempbmp (box2 sfx 0 sfwidth (tempbmp.height)) [0,0]
		basebmp = tempbmp
	)
	fn SetStandardMaterial bAlpha colors=
	(
		brandom = false
		if colors == "random" then brandom = true
		for obj in objects do
		(
			if brandom then
			(
				--print "assigning random color"
				colors = color (random 0 255) (random 0 255) (random 0 255)
			)
			if superclassof obj == GeometryClass and obj.material != undefined then
			(
				if bAlpha then
				(
						--print "alpha true"
						viewport.SetTransparencyLevel 2
						alphamat = standard()
						if  hasproperty obj.material "opacityMap" and obj.material.opacityMap != undefined then
						(
							alphamat.opacityMap  = obj.material.opacityMap
							alphamat.opacityMap.monoOutput = 1
							obj.mat = alphamat
							obj.mat.name = "TempMat" + obj.name
							obj.mat.Diffuse_Color = colors
							obj.wirecolor = colors
							showTextureMap obj.material on
						)
						else if hasproperty obj.material "bUseAlpha" then
						(
							if obj.material.bUseAlpha == true then
							(
								--print "Xoliul Shader Detected 1.*"
								alphatexmap = bitmaptexture()
								alphatexmap.filename =substring (obj.material.diffuseMap as string) 8 (obj.material.diffuseMap as string).count
								alphatexmap.alphasource =  0
								alphatexmap.monoOutput = 1
								alphamat.opacityMap  = alphatexmap
								obj.material = alphamat
								obj.mat.name = "TempMat" + obj.name
								obj.mat.Diffuse_Color = colors
								obj.wirecolor = colors
								showTextureMap obj.material on
							)
							else 
							(
									obj.mat = standard()
									obj.mat.Diffuse_Color = colors
									obj.wirecolor = colors
							)
						)
						else if hasproperty obj.material "m_bUseAlpha" then
						(
							if obj.material.m_bUseAlpha == true then
							(
								--print "Xoliul Shader Detected 2.*"
								alphatexmap = bitmaptexture()
								alphatexmap.filename =substring (obj.material.delegate.diffuseMap as string) 8 (obj.material.delegate.diffuseMap as string).count
								--print alphatexmap.filename
								alphatexmap.alphasource =  0
								alphatexmap.monoOutput = 1
								alphamat.opacityMap  = alphatexmap
								if obj.material.delegate.technique == 1 then alphamat.twoSided = on
								obj.material = alphamat
								obj.mat.name = "TempMat" + obj.name
								obj.mat.Diffuse_Color = colors
								obj.wirecolor = colors
								showTextureMap obj.material on
							)
							else 
							(
									--print "Xoliul Shader Detected 2.* No Alphamap"
									obj.mat = standard()
									obj.mat.Diffuse_Color = colors
									obj.wirecolor = colors
							)
						)
						else if classof obj.material == t3PSStandardFX  or classof obj.material == t3PSStandardFXliteUI or classof obj.material == t3PSStandardFXUI or classof obj.material == t3PSStandardFXlite then
						(
							if obj.material.delegate.g_UseAlpha == true then
							(
								--print "3Point Shader Detected"
								alphatexmap = bitmaptexture()
								alphatexmap.filename =substring (obj.material.delegate.g_DiffuseTexture as string) 8 (obj.material.delegate.g_DiffuseTexture as string).count
								--print alphatexmap.filename
								alphatexmap.alphasource =  0
								alphatexmap.monoOutput = 1
								alphamat.opacityMap  = alphatexmap
								obj.material = alphamat
								obj.mat.name = "TempMat" + obj.name
								obj.mat.Diffuse_Color = colors
								obj.wirecolor = colors
								showTextureMap obj.material on
							)
						)
						else 
						(
								--print "No Alpha map"
								obj.mat = standard()
								obj.mat.Diffuse_Color = colors
								obj.wirecolor = colors
						)
				)
				else
				(
					if (findstring obj.mat.name "TempMat") == undefined then
					(
						obj.mat = standard()
						obj.mat.name = "TempMat" + obj.name
					)
						obj.mat.Diffuse_Color = colors
						obj.wirecolor = colors
				)
				
			)
			else if superclassof obj == GeometryClass and obj.material == undefined then
			(
						obj.mat = standard()
						obj.mat.name = "TempMat" + obj.name
						append m_nomatarr obj
			)
		)
	)
	fn ShowAlphaMasks =
	(
		for obj in objects do
		(
			if superclassof obj == GeometryClass then
			(
				showTextureMap obj.material on
			)
		)
	)
	fn SetBGColor colors = 
	(
		if GetUIColor 41 != colors then
		(
			SetUIColor 41 colors
			colorMan.repaintUI #repaintAll
		)
	)
	fn ChangePostfix &basebmp &currentname postfix =
	(
		extension = substring currentname (currentname.count-3) 4
		basebmp.filename = ((substring currentname 1 (currentname.count-4)) + "_" + postfix + extension)
	)
	rollout GrabviewportRollout "GrabViewport" width:157 height:600
	(
		spinner spnWidth "Width" pos:[22,90] width:77 height:16 range:[1,7500,600] type:#integer scale:1
		spinner spnHeight "Height" pos:[24,117] width:74 height:16 range:[1,6000,600] type:#integer scale:1
		spinner SpnBegin "" pos:[11,294] width:65 height:16 range:[-99999,99999,0] type:#float
		spinner spnEnd "" pos:[81,294] width:65 height:16 range:[-99999,99999,100]
		GroupBox grp1 "Size" pos:[4,70] width:148 height:75
		GroupBox grp4 "Passes" pos:[4,320] width:146 height:88
		GroupBox grp5 "Save Settings" pos:[4,148] width:148 height:74
		GroupBox grp2 "Animation Options" pos:[3,226] width:148 height:92
		GroupBox grp21 "Anti Aliasing" pos:[6,413] width:146 height:47
		GroupBox grp6 "Options" pos:[5,466] width:146 height:66
		dropdownList ddlFileType "" pos:[95,192] width:49 height:21 items:#(".PNG", ".TGA", ".BMP")
		radiobuttons RdoRange "Animation Range" pos:[12,242] width:114 height:46 labels:#("Active Time Range", "From To") columns:1
		radiobuttons RdoAA "" pos:[13,433] width:111 height:16 labels:#("0", "2X", "4X") columns:3
		radiobuttons RdoMode "" pos:[12,538] width:150 height:16 labels:#("Image", "Animation") columns:2
		checkbox ChkColorMask "Color" pos:[81,342] width:55 height:20
		checkbox ChkAlphaMask "Alpha" pos:[13,342] width:54 height:15
		checkbox ChkAOMask "" pos:[13,381] width:14 height:21
		checkbox ChkWireMask "Wire" pos:[13,361] width:56 height:21
		checkbox ChkZdepthMask "" pos:[81,361] width:17 height:21
		checkbox chkCropped "Crop" pos:[13,486] width:46 height:18
		checkbox chkShowCapture "ShowCapture" pos:[61,484] width:82 height:21
		checkbox chkOpenFolder "OpenFolder" pos:[61,507] width:79 height:19
		button btnSave "Save" pos:[4,563] width:146 height:25		
		button btnTagTool "TagTool" pos:[94,168] width:50 height:18
		button btnReset "Reset" pos:[103,89] width:41 height:44
		button btnSetDir "Set Directory ..." pos:[11,168] width:79 height:17
		edittext edtFileName "" pos:[7,194] width:82 height:17
		dropdownList ddlPresets "Presets" pos:[8,5] width:143 height:40
		button btnCreatePreset "Create" pos:[111,49] width:39 height:18
		button btnApplyPreset "Apply" pos:[8,49] width:60 height:18
		button btnDeletePreset "Delete" pos:[70,49] width:39 height:18
		button btnZdepth "Zdepth" pos:[96,363] width:44 height:18
		button btnAO "SSAO" pos:[30,382] width:32 height:18
		on GrabviewportRollout open do
		(
			GetOriginalState()
			--Callbacks to check for scenechanges
			callbacks.removeScripts id:#GVFileChange
			callbacks.addScript #filePostOpenProcess "GetOriginalState()" id:#GVFileChange --persistent:true
			
			ddlPresets.items = #("Select A Preset")
			ddlPresets.items = join ddlPresets.items (getIniSetting m_presetspath)
		)
		on GrabviewportRollout close do
		(
			SetOriginalState()
			m_viewportbmp = undefined
			m_alphabmp = undefined
			SaveSettings m_Inipath "Settings"
			freeSceneBitmaps()
			if FileTagRollout != undefined then DestroyDialog FileTagRollout
			callbacks.removeScripts id:#GVFileChange
			gc()
		)
		on spnWidth changed val do
		(
			if chkCropped.checked == true then
			(
				m_ratio = (gw.getWinSizeX() as float)/(gw.getWinSizeY() as float) as float
				print m_ratio
				m_sfratio = (renderwidth as float) / (renderheight as float)
				spnHeight.value = (spnWidth.value as float)/m_sfratio
				m_height = spnHeight.value
				m_width = (spnheight.value as float)*m_ratio
				
			)
			else 
			(
				m_ratio = (gw.getWinSizeX() as float)/(gw.getWinSizeY() as float) as float
				print m_ratio
				spnHeight.value = ((spnWidth.value as float)/m_ratio)
				m_width = spnWidth.value
				m_height = spnHeight.value
			)
			
		)
		on spnHeight changed val do
		(	
			if chkCropped.checked == true then
			(
				m_ratio = (gw.getWinSizeX() as float)/(gw.getWinSizeY() as float) as float
				m_sfratio = (renderwidth as float) / (renderheight as float)
				m_height = spnHeight.value
				m_width = spnheight.value*m_ratio
				spnWidth.value = spnHeight.value*m_sfratio
			)
			else 
			(
				m_ratio = (gw.getWinSizeX() as float)/(gw.getWinSizeY() as float) as float
				print m_ratio
				spnWidth.value = (spnHeight.value as float)*m_ratio
				m_width = spnWidth.value
				m_height = spnHeight.value
			)
			
		)
		on RdoMode changed thestate do
		(
			case thestate of
			(
				1: (
						ddlFileType.items = m_filetypearr[1]
						RdoAA.enabled = true
					)
				2: (
						ddlFileType.items = m_filetypearr[2]
						RdoAA.enabled = false
					)
			)
		)
		on ChkColorMask changed theState do
		(
			m_stateslist._Color = theState
		)
		on ChkAlphaMask changed theState do
		(
			m_stateslist._Alpha = theState
		)
		on ChkAOMask changed theState do
		(
			m_stateslist._SSAO = theState
		)
		on ChkWireMask changed theState do
		(
		 m_stateslist._Wire = theState
		)
		on ChkZdepthMask changed theState do
		(
		 m_stateslist._Zdepth = theState
		)
		on chkCropped changed theState do
		(
			if theState then
			(
				m_sfratio = (renderwidth as float) / (renderheight as float)
				m_height = spnHeight.value
				m_width = spnHeight.value*m_ratio
				spnWidth.value = spnHeight.value*m_sfratio
			)
			else
			(
				m_ratio = (gw.getWinSizeX() as float)/(gw.getWinSizeY() as float) as float
				spnWidth.value = spnHeight.value*m_ratio
				m_width = spnWidth.value
				m_height = spnHeight.value
			)
			
		)
		on btnSave pressed do
		(
			case GrabviewportRollout.RdoMode.state of 
			(
				1: CaptureStates false
				2: CaptureStates true
			)
		)
		on btnTagTool pressed do
		(
			maindialogpos = GetDialogPos GrabviewportRollout
			createDialog FileTagRollout 166 205 (maindialogpos.x + GrabviewportRollout.width +25) (maindialogpos.y ) style:#(#style_toolwindow,#style_sysmenu)
		)
		on btnReset pressed do
		(
			if chkCropped.checked == true then
			(
				m_sfratio = (renderwidth as float) / (renderheight as float)
				spnHeight.value = gw.getWinSizeY()
				m_height = spnHeight.value
				m_width = (spnheight.value as float)*m_ratio
				spnWidth.value = (spnHeight.value as float)*m_sfratio
			)
			else
			(
				m_width = gw.getWinSizeX()
				m_height = gw.getWinSizeY()
				GrabviewportRollout.spnWidth.value =  m_width 
				GrabviewportRollout.spnHeight.value =  m_height
			)
			
		)
		on btnSetDir pressed do
		(
			m_savepath = getSavePath caption:"Save Directory" initialDir:(getdir (#image))
			if m_savepath == undefined then m_savepath = (getDir #image)
			btnSetDir.toolTip = m_savepath
			if m_savepath != undefined and m_savepath.count > 21 then btnSetDir.caption = (substring m_savepath (m_savepath.count-20) (m_savepath.count)) else btnSetDir.caption = m_savepath
		)
		on btnSetDir rightClick do
		(
			if m_savepath != undefined or m_savepath != "" then
			(shellLaunch "explorer.exe" m_savepath)
		)
		on edtFileName changed txt do
		(
			m_filename = txt
		)
		on btnCreatePreset pressed do
		(
			createDialog CreatePresetRollout 195 132 ((gw.getWinSizeX())/2) ((gw.getWinSizeY())/2) style:#(#style_toolwindow) modal:true
		)
		on btnApplyPreset pressed do
		(
			if ddlPresets.selection  != 1 then
			LoadSettings m_presetspath ddlPresets.selected 
		)
		on btnDeletePreset pressed do
		(
			if ddlPresets.selection  != 1 then
			delIniSetting m_presetspath ddlPresets.selected
			
			ddlPresets.items = #("Select A Preset")
			ddlPresets.items = join ddlPresets.items (getIniSetting m_presetspath)
			ddlPresets.selection = ddlPresets.items.count
		)
		on btnZdepth pressed do
		(
			TweakZdepth()
		)
		on btnAO pressed do
		(
			TweakAO()
		)
	)
	rollout ZdepthRollout "Zdepth Settings" width:166 height:181
	(
		local beginvalue, endvalue
		spinner SpnBegin "Begin:" pos:[17,50] width:141 height:16 range:[0.3,99999,3]
		spinner spnEnd "End:" pos:[26,79] width:133 height:16 range:[0.3,99999,300]
		button btncontinue "Continue" pos:[12,110] width:144 height:24
		button btnReset "Reset Values" pos:[12,141] width:144 height:24
		label lbl1 "Tweak the parameters to get a good zdepth range." pos:[6,8] width:153 height:36
		on ZdepthRollout open do
		(
			if m_depthlightbegin != undefined and m_depthlightbegin != "" then 
			(
				spnbegin.value = m_depthlightbegin
				m_depthlight.multiplier = m_depthlightbegin
				beginvalue = spnbegin.value
			)
			if m_depthlightend != undefined and m_depthlightend != "" then 
			(	
				spnend.value = m_depthlightend
				m_depthlight.farAttenEnd = m_depthlightend
				m_depthlight.farAttenStart = 0
				endvalue = spnend.value
			)
		)
		on SpnBegin changed val do
		(
			m_depthlightbegin = val
			m_depthlight.multiplier = m_depthlightbegin
			
		)
		on spnEnd changed val do
		(
			m_depthlightend = val
			m_depthlight.farAttenEnd = m_depthlightend
			m_depthlight.farAttenStart = 0
		)
		on btncontinue pressed do
		(
			DestroyDialog ZdepthRollout
		)
		on btnReset pressed do
		(
			spnBegin.value = beginvalue
			spnEnd.value  = endvalue
		)
	)
	rollout AORollout "AO Settings" width:166 height:181
	(
		local beginvalue, endvalue
		spinner SpnRadius "Radius:" pos:[17,50] width:141 height:16 range:[0.1,99999,3]
		spinner SpnStrength "Strength:" pos:[17,79] width:142 height:16 range:[0.1,1,0.1] scale:0.01
		button btncontinue "Continue" pos:[12,110] width:144 height:24
		button btnReset "Reset Values" pos:[12,141] width:144 height:24
		label lbl1 "Tweak the parameters to get a good AO range." pos:[6,8] width:153 height:36
		on AORollout open do
		(
			SpnRadius.value = m_vps.AmbientOcclusionRadius
			SpnStrength.value = m_vps.AmbientOcclusionStrength
			beginvalue = m_vps.AmbientOcclusionRadius
			endvalue = m_vps.AmbientOcclusionStrength
		)
		on SpnRadius changed val do
		(
			m_vps.AmbientOcclusionRadius = val
		)
		on SpnStrength changed val do
		(
			m_vps.AmbientOcclusionStrength =val
		)
		on btncontinue pressed do
		(
			DestroyDialog AORollout
		)
		on btnReset pressed do
		(
			SpnRadius.value = beginvalue
			spnStrength.value  = endvalue
		)
	)
	rollout FileTagRollout "FileTag Tool" width:166 height:205
	(
		button btnUseName "Use" pos:[13,176] width:145 height:19
		dropdownList ddlFilePathTags "FilePathTags" pos:[9,10] width:148 height:40
		button btnUsePath "Use" pos:[10,55] width:146 height:19
		multiListBox mlbFileNameTags "FileNameTags" pos:[12,78] width:145 height:6


		on FileTagRollout open do
		(
			sort m_Filepathtagsarr
			mlbFileNameTags.items = m_Filenametagsarr
			ddlFilePathTags.items = m_Filepathtagsarr
		)
		on btnUseName pressed do
		(
			for i  in mlbFileNameTags.selection do
			 (
				if (findString GrabviewportRollout.edtFileName.text mlbFileNameTags.items[i]) == undefined then
				(
					GrabviewportRollout.edtFileName.text =  mlbFileNameTags.items[i] + GrabviewportRollout.edtFileName.text
					m_filename = GrabviewportRollout.edtFileName.text
				)
			 )
		)
		on btnUsePath pressed do
		(
			for i=1 to m_Filepathtagsarr.count do
			(
				found = findstring GrabviewportRollout.edtFileName.text m_Filepathtagsarr[i]
				if (found != undefined) then
				(
					--print "removed additional filepath"
					GrabviewportRollout.edtFileName.text = Replace GrabviewportRollout.edtFileName.text found m_Filepathtagsarr[i].count ""
				)
			)
			
			GrabviewportRollout.edtFileName.text = ddlFilePathTags.selected + GrabviewportRollout.edtFileName.text 
		)
	)
	rollout CreatePresetRollout "Create Preset" width:195 height:132
	(
		editText edtFilename "" pos:[5,22] width:181 height:20
		label lbl1 "Enter New Preset Name" pos:[12,3] width:174 height:15
		dropDownList ddlReplace "Or Replace An Existing One" pos:[12,50] width:174 height:40
		button btnCreate "Create" pos:[13,100] width:86 height:21
		button btnCancel "Cancel" pos:[100,100] width:85 height:21
		on CreatePresetRollout open do
		(
			ddlReplace.items = #("Select A Preset")
			ddlReplace.items = join ddlReplace.items (getIniSetting m_presetspath)
		)
		on btnCreate pressed do
		(
			if ddlReplace.selection != 1 then
			(
				SaveSettings m_presetspath ddlReplace.selected
			)
			else if CreatePresetRollout.edtFilename.text != "" then
			(
				if (findstring CreatePresetRollout.edtFilename.text "[") == undefined and (findstring CreatePresetRollout.edtFilename.text "]") == undefined  and (findstring CreatePresetRollout.edtFilename.text "\\") == undefined then
				SaveSettings m_presetspath edtFilename.text 
			)
			GrabviewportRollout.ddlPresets.items = #("Select A Preset")
			GrabviewportRollout.ddlPresets.items = join GrabviewportRollout.ddlPresets.items (getIniSetting m_presetspath)
			DestroyDialog CreatePresetRollout
		)
		on btnCancel pressed do
		(
			DestroyDialog CreatePresetRollout
		)
		
	)
	fn TweakAO =
	(
		
			SetStandardMaterial false white
			SetBGColor white
			m_vps.AmbientOcclusionQuality= 2
			m_vps.ActivateViewportShading = true
			m_vps.AmbientOcclusionMode = #AOOnly
			forceCompleteRedraw()
			createDialog AORollout 166 181 ((gw.getWinSizeX())/2) ((gw.getWinSizeY())/2) style:#(#style_toolwindow) modal:true
			SetOriginalState()
	)
	fn TweakZdepth =
	(
			SetStandardMaterial true white
			for light in lights do light.enabled = false
			actionMan.executeAction 0 "549"--ViewportShading to Smooth + Highlighted
			m_vps.AmbientOcclusionMode = 0
			m_vps.ActivateViewportShading = true
			m_vps.ShadowsActive = true
			SetStandardMaterial true white
			SetBGColor Black
			
			if (viewport.GetType()) != #view_camera then
			(
				macros.run "Lights and Cameras" "Camera_CreateFromView"
				m_bhascamera = false
			)
			else
			(
				m_bhascamera = true
			)
			
			activecam = getActiveCamera()
			m_depthlight = Omnilight rgb:(color 255 255 255) shadowColor:(color 0 0 0) multiplier:3 farAttenEnd:300 pos:(activecam.pos)
			m_depthlight.useFarAtten = on
			m_depthlight.ambientOnly = on
			m_depthlight.parent = activecam
			screendimensions = getViewSize()
			deselect $*
			createDialog ZdepthRollout 166 181 ((gw.getWinSizeX())/2) ((gw.getWinSizeY())/2) style:#(#style_toolwindow) modal:true
			if m_bhascamera == false  then
			(
				actionMan.executeAction 0 "40182"  -- Views: Perspective User View
				delete activecam
			)
			delete m_depthlight
			
			SetOriginalState()
	)
	fn ParseFilename &filepath &filename =
	(
		
		fulldate = getLocalTime()
		date = "_" +(fulldate[2])as string+"-"+(fulldate[4])as string+"-"+(fulldate[1])as string
		ttime = "_" + (fulldate[5])as string+"-"+(fulldate[6])as string+"-"+(fulldate[7])as string
		maxname = substring maxFileName 1 ((maxFileName).count-4)
		viewportname = viewport.GetType() as string
		viewportname = substring viewportname 6 (viewportname.count-5)
		
		if viewportname == "camera" then 
		( viewportname = (getActiveCamera()).name)
		for i=1 to m_Filenametagsarr.count do
		(	
			match = findstring filename m_Filenametagsarr[i]
			if match != undefined then
			(
				if m_Filenametagsarr[i] == "#Date" then
				(filename = replace filename match m_Filenametagsarr[i].count date)
				if m_Filenametagsarr[i] == "#Time" then
				(filename = replace filename match m_Filenametagsarr[i].count ttime)
				if m_Filenametagsarr[i] == "#MaxFileName" then
				(filename = replace filename match m_Filenametagsarr[i].count maxname)
				if m_Filenametagsarr[i] == "#ViewportName" then
				(filename = replace filename match m_Filenametagsarr[i].count viewportname)
				if m_Filenametagsarr[i] == "#UniqueNumber" then
				(
					tempname = replace filename match m_Filenametagsarr[i].count ("_"+((random 0 9999)as string))
					while (doesFileExist(filepath + "\\"+ tempname +GrabviewportRollout.ddlFileType.selected)) do
					(
						tempname = replace filename match m_Filenametagsarr[i].count ("_"+((random 0 9999)as string))
					)
					filename = tempname
				)
			)
		)	
	)
	fn ParseFilepath &filepath &filename = 
	(
		doubles = false
		for i=1 to m_Filepathtagsarr.count do
		(	
			match = findstring filename m_Filepathtagsarr[i]
			if match != undefined then
			(
				if doubles = false then
				(
					filepath = Getdir (execute(m_Filepathtagsarr[i]))
					doubles = true
				)
				filename = replace filename match m_Filepathtagsarr[i].count ""
			)
		)
		filepath = replace filepath 3 1 "\\"
	)
	fn AlphaToAnim &Alphabmp ttime =
	(
		currentname = Alphabmp.filename
		frametime = 0
		case ((ttime as integer)as string).count of
		(
			1: frametime = "000" + (ttime as integer) as string
			2: frametime = "00" + (ttime as integer) as string
			3: frametime = "0" + (ttime as integer) as string
			4: frametime = (ttime as integer) as string
			undefined: Messagebox ("No Time??");
		)
		extension = substring currentname (currentname.count-3) 4
		currentname = (substring currentname 1 (currentname.count-10)) + frametime + extension
		--MessageBox currentname
		basebmp = openBitmap currentname
		tempbmp = bitmap basebmp.width basebmp.height 
		copy basebmp tempbmp
		AddAlpha &tempbmp &Alphabmp
		tempbmp.filename = currentname
		save tempbmp
		close basebmp
		close tempbmp
	)
	fn CreateAnim postfix= 
	(
		if GrabviewportRollout.RdoRange.state == 1 then
		(
			animbegin = animationrange.start 
			animend = animationrange.end
		)
		else if GrabviewportRollout.RdoRange.state == 2 then
		(			
			animbegin = GrabviewportRollout.SpnBegin.value 
			animend = GrabviewportRollout.SpnEnd.value 
		)
		
		ResizeViewport (m_width) (m_height)
		if GrabviewportRollout.chkCropped.checked then (anim_bmp = bitmap ((((m_height)) as float)*m_sfratio) m_height filename:m_bmpname)
		else (anim_bmp = bitmap m_width m_height filename:m_bmpname)
		ChangePostfix &anim_bmp &m_bmpname postfix
				
		for t = animbegin to animend do
		(
			if keyboard.escPressed == false then
			(
				sliderTime = t
				dib = gw.getViewportDib()
				if GrabviewportRollout.chkCropped.checked then CropToSafeframes &dib
				copy dib anim_bmp
				if GrabviewportRollout.ddlFileType.selected == ".PNG" and postfix == "Alpha" then
				(
					AlphaToAnim &anim_bmp t
				)
				else
				(
					save anim_bmp frame:t
				)
			)
		)
		close anim_bmp
		--print "anim done"

	)

	fn CaptureStates banim = 
	(
		clearSelection()
		ToggleUIItems off
		
		animbegin = 0 
		animend = 0
		if (((maxVersion())[1] / 1000) > 12) then 
		(
			m_vps = (maxops.getViewportShadingSettings())
		)
		if GrabviewportRollout.RdoRange.state == 1 then
		(
			animbegin = animationrange.start 
			animend = animationrange.end
		)
		else if GrabviewportRollout.RdoRange.state == 2 then
		(			
			animbegin = GrabviewportRollout.SpnBegin.value 
			animend = GrabviewportRollout.SpnEnd.value 
		)

		--Filename
		bfilepathset = true
		if m_savepath == undefined or  m_savepath == "" then
		(
			m_savepath = GetDir(#image)
			bfilepathset = false
		)
		if m_NoDialog!=true then m_filename = GrabviewportRollout.edtFileName.text
		
		ParseFilepath &m_savepath &m_filename
		ParseFilename &m_savepath &m_filename
		if doesFileExist(m_savepath) != true then makeDir (m_savepath)
		m_bmpname = m_savepath + "\\" + m_filename  + GrabviewportRollout.ddlFileType.selected
			
		--BASE
		if banim then
		(
			ResizeViewport (m_width) (m_height)
			--print 
			if GrabviewportRollout.chkCropped.checked then (anim_bmp = bitmap ((((m_height)) as float)*m_sfratio) m_height filename:m_bmpname)
			else (anim_bmp = bitmap m_width m_height filename:m_bmpname)

			
			for t = animbegin to animend do
			(
				if keyboard.escPressed == false then
				(
					sliderTime = t
					dib = gw.getViewportDib()
					if GrabviewportRollout.chkCropped.checked then CropToSafeframes &dib
					copy dib anim_bmp
					save anim_bmp frame:t
				)
			)
			close anim_bmp
			--print "anim done"
		)
		else
		(
			case GrabviewportRollout.RdoAA.state of 
			(
			1: (

					if (GrabviewportRollout.chkCropped.checked) then
					(
						ResizeViewport (m_width) (m_height)
						m_viewportbmp = gw.getViewportDib()
						CropToSafeframes &m_viewportbmp
					)
					else
					(
						ResizeViewport m_width m_height
						m_viewportbmp = gw.getViewportDib()
					)
				)
			2: (
					ResizeViewport (m_width*2) (m_height*2)
					m_viewportbmp = gw.getViewportDib()
					ScaleBitmap &m_viewportbmp m_width m_height
					if (GrabviewportRollout.chkCropped.checked == true) then
					(
						CropToSafeframes &m_viewportbmp 
					)
				)
			3: (
					ResizeViewport (m_width*4) (m_height*4)
					m_viewportbmp = gw.getViewportDib()
					ScaleBitmap &m_viewportbmp m_width m_height
					if (GrabviewportRollout.chkCropped.checked == true) then
					(
						CropToSafeframes &m_viewportbmp
					)
				)
			)
		)
		if (m_sceneinfo._MaxVersion > 11) then 
		(
			m_vps.ActivateViewportShading = false
			m_vps.ShadowsActive = false
			--print "shadows off"
		)
		--ALPHA
		if m_stateslist._Alpha then
		(
			actionMan.executeAction 0 "554" --ViewportShading to Flat
			SetBGColor Black
			SetStandardMaterial true white
			forceCompleteRedraw()
			if banim then
			(
				CreateAnim "Alpha"
			)
			else
			(
				case GrabviewportRollout.RdoAA.state of 
				(
				1: (
						m_alphabmp = gw.getViewportDib()
						if (GrabviewportRollout.chkCropped.checked == true) then
						(
							m_alphabmp = CropToSafeframes &m_alphabmp
						)
					)
				2: (
						ResizeViewport (m_width*2) (m_height*2)
						m_alphabmp = gw.getViewportDib()
						ScaleBitmap &m_alphabmp m_width m_height
						ResizeViewport m_width m_height
						if (GrabviewportRollout.chkCropped.checked == true) then
						(
							m_alphabmp = CropToSafeframes &m_alphabmp
						)
					)
				3: (
						ResizeViewport (m_width*4) (m_height*4)
						m_alphabmp = gw.getViewportDib()
						ScaleBitmap &m_alphabmp m_width m_height
						ResizeViewport m_width m_height
						if (GrabviewportRollout.chkCropped.checked == true) then
						(
							m_alphabmp = CropToSafeframes &m_alphabmp
						)
					)
				)
				
				
				if GrabviewportRollout.ddlFileType.selected == ".PNG" then
				(
					AddAlpha &m_viewportbmp &m_alphabmp
					ResizeViewport m_width m_height
					m_viewportbmp.filename = m_bmpname
					
					save m_viewportbmp
					close m_viewportbmp
					close m_alphabmp
				)
				else 
				(
					m_viewportbmp.filename = m_bmpname
					save m_viewportbmp
					close m_viewportbmp
					ChangePostfix &m_alphabmp &m_bmpname "Alpha"
					save m_alphabmp
					close m_alphabmp
					
					case GrabviewportRollout.RdoAA.state of 
					(
						2: ResizeViewport m_width m_height
						3: ResizeViewport m_width m_height
					)
				
				)
			)
		)
		else
		(
			if banim == false then
			(
				m_viewportbmp.filename = m_bmpname
				case GrabviewportRollout.RdoAA.state of 
				(
					2: ResizeViewport m_width m_height
					3: ResizeViewport m_width m_height
				)
				save m_viewportbmp
				close m_viewportbmp
			)
		)
		if m_stateslist._Color then
		(
			actionMan.executeAction 0 "554" --ViewportShading to Flat
			SetStandardMaterial false "random"
			SetBGColor Black
			forceCompleteRedraw()
			if banim then
			(
				CreateAnim "Color"
			)
			else
			(
				m_viewportbmp = gw.getViewportDib()
				if (GrabviewportRollout.chkCropped.checked == true) then
				(
					CropToSafeframes &m_viewportbmp
				)
				ChangePostfix &m_viewportbmp &m_bmpname "Color"
					
				save m_viewportbmp
				close m_viewportbmp
			)
		)
		--WIRE
		if m_stateslist._Wire then
		(
			actionMan.executeAction 0 "554" --ViewportShading to Flat
			viewport.SetShowEdgeFaces true
			SceneEffectLoader.EnableSceneEffects false
			SetBGColor Black
			SetStandardMaterial false white
			
			for obj in objects do
			(
				if superclassof obj == GeometryClass and obj.mat != undefined then
				(
					obj.mat.Diffuse_Color = black
				)
			)
			forceCompleteRedraw()
			if banim then
			(
				CreateAnim "Wire"
			)
			else
			(
				m_viewportbmp = gw.getViewportDib()
				if (GrabviewportRollout.chkCropped.checked == true) then
				(
					CropToSafeframes &m_viewportbmp
				)
				ChangePostfix &m_viewportbmp &m_bmpname "Wire"
				
				
				save m_viewportbmp
				close m_viewportbmp
			)
			viewport.SetShowEdgeFaces false
		)
		--SSAO
		if m_stateslist._SSAO then
		(
			SetStandardMaterial false white
			SetBGColor white
			
			m_vps.AmbientOcclusionQuality= 2
			m_vps.AmbientOcclusionMode = #AOOnly
			m_vps.ActivateViewportShading = true
			forceCompleteRedraw()
			if banim then
			(
				CreateAnim "AO"
			)
			else
			(
				m_viewportbmp = gw.getViewportDib()
				if (GrabviewportRollout.chkCropped.checked == true) then
				(
					CropToSafeframes &m_viewportbmp
				)
				ChangePostfix &m_viewportbmp &m_bmpname "AO"
					
				save m_viewportbmp
				close m_viewportbmp
			)
		)
		--ZDEPTH
		if m_stateslist._Zdepth then
		(
			for light in lights do light.enabled = false
			actionMan.executeAction 0 "549"--ViewportShading to Smooth + Highlighted
			m_vps.AmbientOcclusionMode = 0
			m_vps.ActivateViewportShading = true
			m_vps.ShadowsActive = true
			SetStandardMaterial false white
			SetBGColor Black
			
			if (viewport.GetType()) != #view_camera then
			(
				macros.run "Lights and Cameras" "Camera_CreateFromView"
				m_bhascamera = false
			)
			else
			(
				m_bhascamera = true
			)
			
			activecam = getActiveCamera()
			m_depthlight = Omnilight rgb:(color 255 255 255) shadowColor:(color 0 0 0) multiplier:m_depthlightbegin farAttenStart:0 farAttenEnd:m_depthlightend pos:(activecam.pos)
			m_depthlight.useFarAtten = on
			m_depthlight.ambientOnly = on
			m_depthlight.parent = activecam
			screendimensions = getViewSize()
			deselect $*
			--createDialog ZdepthRollout 166 181 ((gw.getWinSizeX())/2) ((gw.getWinSizeY())/2) style:#(#style_toolwindow) modal:true
			if banim then
			(
				CreateAnim "Zdepth"
			)
			else
			(
				ResizeViewport m_width m_height
				m_viewportbmp = gw.getViewportDib()
				if (GrabviewportRollout.chkCropped.checked == true) then
				(
					CropToSafeframes &m_viewportbmp
				)
				ChangePostfix &m_viewportbmp &m_bmpname "Zdepth"
				
				save m_viewportbmp
				close m_viewportbmp
				)
			if m_bhascamera == false  then
			(
				actionMan.executeAction 0 "40182"  -- Views: Perspective User View
				delete activecam
			)
			delete m_depthlight
			
		)
		SetOriginalState()
		sliderTime = animbegin
		ToggleUIItems on
			
		if GrabviewportRollout.chkShowCapture.checked == true or bfilepathset == false then
		(
			if banim then
			(
				RAMPlayer (m_savepath+"\\"+m_filename +GrabviewportRollout.ddlFileType.selected) ""
			)
			else
			(
				display (openBitMap (m_savepath + "\\" + m_filename  + GrabviewportRollout.ddlFileType.selected))
			)
		)
		if GrabviewportRollout.chkOpenFolder.checked == true or bfilepathset == false then
		(
			if m_savepath != undefined or m_savepath != "" then
			(shellLaunch "explorer.exe" (m_savepath + "\\"))
		)
		if m_NoDialog!=true then m_filename = GrabviewportRollout.edtFileName.text 
	)
	fn LoadSettings filepath category=
	(
			if (getfiles filepath) != 0 then
			(
				--variables
				m_filename = GetINISetting filepath category "filename"
				if m_NoDialog!=true then GrabviewportRollout.edtFileName.text =  m_filename
				m_savepath = GetINISetting filepath category "savepath"
				if m_NoDialog!=true then GrabviewportRollout.btnSetDir.caption = m_savepath
				m_height = GetINISetting filepath category "height" as integer
				if m_NoDialog!=true then GrabviewportRollout.spnHeight.value = m_height
				m_width = GetINISetting filepath category "width" as integer
				if m_NoDialog!=true then GrabviewportRollout.spnWidth.value = m_width
				if m_depthlightbegin != undefined and m_depthlightbegin != "" then m_depthlightbegin = (GetINISetting filepath category "depthlightbegin") as float  else m_depthlightbegin = 3
				if m_depthlightend != undefined and m_depthlightend != "" then m_depthlightend = (GetINISetting filepath category "depthlightend") as float  else m_depthlightend = 300
				
				--radiobuttons
				tempanimrange = (GetINISetting filepath category "animationrange")
				if tempanimrange != undefined and tempanimrange != "" then tempanimrange = (tempanimrange as integer) else tempanimrange = 1
				if m_NoDialog!=true then GrabviewportRollout.RdoRange.state = tempanimrange
				tempaa = (GetINISetting filepath category "antialiasing")
				if tempaa != undefined and tempaa != "" then tempaa = (tempaa) as integer else tempaa = 1
				if m_NoDialog!=true then GrabviewportRollout.RdoAA.state = tempaa
				m_capturetype = (GetINISetting filepath category "capturetype")
				if m_capturetype != undefined and m_capturetype != "" then m_capturetype = (m_capturetype) as integer else m_capturetype = 1
				if m_NoDialog!=true then GrabviewportRollout.RdoMode.state = m_capturetype
				case m_capturetype of
				(
					1: (
							if m_NoDialog!=true then GrabviewportRollout.ddlFileType.items = m_filetypearr[1]
							if m_NoDialog!=true then GrabviewportRollout.RdoAA.enabled = true
						)
					2: (
							if m_NoDialog!=true then GrabviewportRollout.ddlFileType.items = m_filetypearr[2]
							if m_NoDialog!=true then GrabviewportRollout.RdoAA.enabled = false
						)
				)
				
				--dropdowns
				tempfiletype =  (GetINISetting filepath category "filetype")
				if tempfiletype != undefined and tempfiletype != "" then tempfiletype = tempfiletype as integer else tempfiletype = 1
				if m_NoDialog!=true then GrabviewportRollout.ddlFileType.selection = tempfiletype
				


				--sliders
				tempanimrangebegin = (GetINISetting filepath category "animationrangebegin")
				if tempanimrangebegin != undefined and tempanimrangebegin != "" then tempanimrangebegin = tempanimrangebegin as integer else tempanimrangebegin = 0
				if m_NoDialog!=true then GrabviewportRollout.spnBegin.value = tempanimrangebegin
				tempanimrangeend = (GetINISetting filepath category "animationrangeend")
				if tempanimrangeend != undefined and tempanimrangeend != "" then tempanimrangeend = tempanimrangeend as integer else tempanimrangeend = 100
				if m_NoDialog!=true then GrabviewportRollout.spnEnd.value = tempanimrangeend
				
				--checkboxes
				tempcrop = (GetINISetting filepath category "crop")
				if tempcrop != undefined and tempcrop != "" then tempcrop = (tempcrop) as booleanClass else tempcrop = false
				if m_NoDialog!=true then GrabviewportRollout.chkCropped.checked = tempcrop
				tempshowcapture = (GetINISetting filepath category "showcapture")
				if tempshowcapture != undefined and tempshowcapture != "" then tempshowcapture = (tempshowcapture) as booleanClass else tempshowcapture = false
				if m_NoDialog!=true then GrabviewportRollout.chkShowCapture.checked = tempshowcapture
				tempopenfolder = (GetINISetting filepath category "openfolder")
				if tempopenfolder != undefined and tempopenfolder != "" then tempopenfolder = (tempopenfolder) as booleanClass else tempopenfolder = false
				if m_NoDialog!=true then GrabviewportRollout.chkOpenFolder.checked  = tempopenfolder
				tempalpha = (GetINISetting filepath category "alpha")
				if m_stateslist._Alpha != undefined and tempalpha != "" then m_stateslist._Alpha = (tempalpha) as booleanClass else m_stateslist._Alpha = false
				if m_NoDialog!=true then GrabviewportRollout.ChkAlphaMask.checked = m_stateslist._Alpha
				tempcolor = (GetINISetting filepath category "color")
				if m_stateslist._Color != undefined  and tempcolor != "" then m_stateslist._Color = (tempcolor) as booleanClass  else m_stateslist._Color = false
				if m_NoDialog!=true then GrabviewportRollout.ChkColorMask.checked = m_stateslist._Color
				tempwire = (GetINISetting filepath category "wire")
				if m_stateslist._Wire != undefined  and tempwire != "" then m_stateslist._Wire = (tempwire) as booleanClass  else m_stateslist._Wire = false
				if m_NoDialog!=true then GrabviewportRollout.ChkWireMask.checked = m_stateslist._Wire
				tempzdepth = (GetINISetting filepath category "zdepth")
				if m_stateslist._Zdepth != undefined and tempzdepth != "" then m_stateslist._Zdepth = (tempzdepth) as booleanClass  else m_stateslist._Zdepth = false
				if m_NoDialog!=true then GrabviewportRollout.ChkZdepthMask.checked = m_stateslist._Zdepth
				tempssao = (GetINISetting filepath category "ao")
				if m_stateslist._SSAO != undefined and tempssao != "" then m_stateslist._SSAO = (tempssao) as booleanClass  else m_stateslist._SSAO = false
				if m_NoDialog!=true then GrabviewportRollout.ChkAOMask.checked = m_stateslist._SSAO
			)
			
			if m_width == 0 or m_width == undefined then
			(
					m_width = gw.getWinSizeX()
					if m_NoDialog!=true then GrabviewportRollout.spnWidth.value =  m_width 
			)
			if m_height == 0 or m_height == undefined then
			(
					m_height = gw.getWinSizeY()
					if m_NoDialog!=true then GrabviewportRollout.spnHeight.value =  m_height
			)
			
	)	
	fn SaveSettings filepath category =
	(
			SetINISetting filepath category "filename" (m_filename as string)
			SetINISetting filepath category "savepath" (m_savepath as string)
			SetINISetting filepath category "width" (GrabviewportRollout.spnWidth.value as string)
			SetINISetting filepath category "height" (GrabviewportRollout.spnHeight.value as string)
			SetINISetting filepath category "filetype" (GrabviewportRollout.ddlFileType.selection as string)
			SetINISetting filepath category "animationrange" (GrabviewportRollout.RdoRange.state as string)
			SetINISetting filepath category "animationrangebegin" (GrabviewportRollout.spnBegin.value as string)
			SetINISetting filepath category "animationrangeend" (GrabviewportRollout.spnEnd.value as string)
			SetINISetting filepath category "antialiasing" (GrabviewportRollout.RdoAA.state as string)
			SetINISetting filepath category "capturetype" (GrabviewportRollout.RdoMode.state as string)
			SetINISetting filepath category "crop" (GrabviewportRollout.chkCropped.checked as string)
			SetINISetting filepath category "showcapture" (GrabviewportRollout.chkShowCapture.checked as string)
			SetINISetting filepath category "openfolder" (GrabviewportRollout.chkOpenFolder.checked as string)
			SetINISetting filepath category "alpha" (m_stateslist._Alpha as string)
			SetINISetting filepath category "color" (m_stateslist._Color as string)
			SetINISetting filepath category "wire" (m_stateslist._Wire as string)
			SetINISetting filepath category "zdepth" (m_stateslist._Zdepth as string)
			SetINISetting filepath category "ao" (m_stateslist._SSAO as string)
			SetINISetting filepath category "depthlightbegin" (m_depthlightbegin as string)
			SetINISetting filepath category "depthlightend" (m_depthlightend as string)
	)

	on Execute do
	(
		m_NoDialog = false
		if (((maxVersion())[1] / 1000) < 12) then 
		(
			checkstring = "#Struct:windows("
			checkstring += "\n  sendMessage:<fn>,"
			checkstring += "\n  addChild:<fn>)"
			
			if windows as string == checkstring then
			(
				case (((maxVersion())[1] / 1000)) of
				(
					9: currentmaxversion = "3dsMax 9"
					10: currentmaxversion = "3dsMax 2008"
					11: currentmaxversion = "3dsMax 2009"
				)
				MessageBox ("Please Install The Appropriate AVGuardPlugin First\nGoto WWW.SCRIPTSPOT.COM And Search For AVGuard Extension " + currentmaxversion) as string
				return true
			)
		)
		else
		(
			m_vps = (maxops.getViewportShadingSettings())
		)
		if keyboard.shiftPressed != true or doesfileexist m_Inipath == false  then
		(
			createDialog GrabviewportRollout 157 600 100 100 style:#(#style_toolwindow, #style_sysmenu)
		)
		else m_NoDialog = true
		LoadSettings m_Inipath "Settings"
		if (((maxVersion())[1] / 1000) < 12) then 
		(
			if m_NoDialog == false then
			(
				GrabviewportRollout.ChkAOMask.checked = false
				GrabviewportRollout.ChkAOMask.enabled = false
				GrabviewportRollout.ChkZdepthMask.checked = false
				GrabviewportRollout.ChkZdepthMask.enabled = false
			)
			m_stateslist._Zdepth = false
			m_stateslist._SSAO = false
		)
		if m_NoDialog then 
		(
			GetOriginalState(); 
			case m_capturetype of
			(
				1: CaptureStates false
				2: CaptureStates true
			)
		)
		
			case GrabviewportRollout.RdoMode.state of 
			(
				1: CaptureStates false
				2: CaptureStates true
			)
			DestroyDialog GrabviewportRollout
	)
)