if (not globalDXDisplayManager.isDXActive()) then
(
	messagebox "Viewport Canvas is only available when Direct3D is used as the viewport display driver." title:"Viewport Canvas"
)
else if PolyBoost.ViewportCanvasOpen then
(
	cui.unRegisterDialogBar VCMainFloater
	closeRolloutFloater VCMainFloater
)
else
(
--VCanvas = undefined
--if VCanvas has already been defined only the code for opening the dialog is run
 if (VCanvas == undefined) do
(
--Load layer file
layerfile = (GetDir #maxroot) + "stdplugs\\stdscripts\\(PolyTools)\\ViewportCanvasLayerDialog.ms"
filein layerfile

struct ViewportCanvasStruct
(
currentTextureFile = "",
currentBrushFile = "",
currentMaskFile ="",
mapSlotName = "Pick Map...",
brushImageFileNames = #(),
brushImageFileNamesCustom = #(),
brushImagesDisplay = #(),
colorDisplayMap = undefined,
maskDisplayMap = undefined,
customBrushImages = #(),
customBrushImagesDisplay = #(),
isSelectingMask = false,
dialogIsOpen = false,
brushDialogIsOpen = false,
isView2DOpen = false,
currentTool = 1,
doRestartTool = false,
currentObject = undefined,
currentMaterial = undefined,
wasLayerDialogLeftOpen = false,
wasView2DLeftOpen = false,
hasLoadedDefaultSettings = false,
view2DPos = [200,200],
brushDir = getdir #plugcfg + ("\\ViewportCanvas\\"),
brushfiles = #("Metal.tif","Rust.tif","Leather.tif","Woodswirl.tif","Concrete.tif","Skin.tif","Colors.tif","Fabric.tif","Bark.tif"),
maskfiles = #("Ring.tif","Rough.tif","Cloud.tif","Abstract.tif","Scratch.tif","Square.tif","Dirt.tif","Fabricmask.tif","Rocks.tif"),
buttonStates = #(false, false, false, false, false, false, false, false, false,false,false,false,false,false),
colorPaletteColors = #(),
colorPaletteHasLoaded = false,
colorPaletteUInum = undefined,
colorPaletteOpen = false,
usedMapSlot = undefined,
-- << CHD
GL_isGlitchEffect = false,
GL_mapSlotIndex = 0,
GL_savedUsedMapSlot = undefined,
GL_paramName = undefined,
-- CHD >>
endMapslotSearch = false,
dialogPos = [970,150],
dialogHeight = 584,
dialogDockingState = #cui_floatable,
rolloutStates = #(false,true,false,true,true,true,true),

fn ValidPaintObject =
(
	if (selection.count == 1) and (superclassof $ == GeometryClass) then true else false
),
fn FindMapslotMapSearch map =
(
	if (classof map == BitmapTexture) and (map.filename == currentTextureFile) then
	(
		usedMapSlot = map
		endMapslotSearch = true
	)
	else
	(
		numMapSlots = getNumSubTexmaps map
		for d = 1 to numMapSlots do
		(
			tex = getSubTexmap map d
			if tex != undefined do
			(
				FindMapslotMapSearch tex
			)
			if endMapslotSearch do exit
		)
	)
),
fn FindUsedMapslot mat =
(
	-- << CHD
	if (classOf mat == GL_Effect) or (classOf mat == GL_Effect_Inst) then
	(
		usedMapSlot = GL_savedUsedMapSlot
		GL_savedUsedMapSlot = undefined
		endMapslotSearch = true
	)
	else
	(
	-- CHD >>
		numMaterials = getNumSubMtls mat
		if numMaterials == 0 then
		(
			numMaps = getNumSubTexmaps mat
			for d = 1 to numMaps do
			(
				tex = getSubTexmap mat d
				if tex != undefined do
				(
					FindMapslotMapSearch tex
				)
				if endMapslotSearch do exit
			)
		)
		else
		(
			for i = 1 to numMaterials do
			(
				FindUsedMapslot (getSubMtl mat i)
				if endMapslotSearch do exit
			)
		)
	)
),
fn ReloadMap =
(
	if ValidPaintObject() and VCOptionsRoll.savetex.checked do
	(
		mat = $.material
		endMapslotSearch = false
		GL_savedUsedMapSlot = usedMapSlot
		usedMapSlot = undefined
		FindUsedMapslot mat
		if (usedMapSlot != undefined) then
		(
			if (classof usedMapSlot == Bitmaptexture) and (doesFileExist usedMapSlot.filename) do
			(
				try(usedMapSlot.reload())catch()
			)
			-- << CHD
			if GL_isGlitchEffect then
			(
				mat = VCSetup.mapSlotArray[GL_mapSlotIndex]
				if (classOf mat == GL_Effect) or (classOf mat == GL_Effect_Inst) then
				(
					param = mat.params.GetEffectParamByName GL_paramName
					if classOf param == GLParamSampler2D then
					(
						if param.reloadTexture != undefined then
						(
							print "Reload texture param"
							param.reloadTexture()
							return true
						)
					)
					print "Not support reload texture param. Do a completly reloading."
					CM_MTL_ReloadAllTextures() -- tmp, could cost a lot of time
				)
			)
			-- CHD >>
		)
	)
),
fn IsFilePSD filename =
(
	filetype = getFilenameType filename
	if (filetype == ".psd") or (filetype == ".PSD") then true else false
),
fn AssignMaterialDialog doRestart =
(
	VCanvas.doRestartTool = doRestart
	rollout AssignMaterialRollout "Assign Material"
	(
		label assignlab "The object needs a material:"
		button standardbut "Assign Standard Material" width:200 offset:[0,4]
		materialbutton browsebut "Browse Material To Assign..." width:200
		button cancelbut "Cancel" width:200
		
		on standardbut pressed do
		(
			$.material = StandardMaterial()
			destroyDialog AssignMaterialRollout
			if VCanvas.doRestartTool then
			(
				VCanvas.StartPaintTool currentTool
			)
			else VCSetup.BuildMapMenu $.material
		)
		on browsebut picked mtl do
		(
			$.material = mtl
			destroyDialog AssignMaterialRollout
			if VCanvas.doRestartTool then
			(
				VCanvas.StartPaintTool currentTool
			)
			else VCSetup.BuildMapMenu $.material
		)
		on cancelbut pressed do
		(
			destroyDialog AssignMaterialRollout
		)
	)
	createDialog AssignMaterialRollout 260 120 modal:true
),
fn StartPaintTool theTool =
(
	currentTool = theTool
	doRestartTool = false
	buttonarr = #(VCPaintRoll.toolPaint,VCPaintRoll.toolClone,VCPaintRoll.toolBlur,VCPaintRoll.toolSharpen,VCPaintRoll.toolContrast,VCPaintRoll.toolDodge,VCPaintRoll.toolBurn,VCPaintRoll.toolFill,VCPaintRoll.toolSmudge,VCPaintRoll.toolErase,VCPaintRoll.toolMove,VCPaintRoll.toolScale,VCPaintRoll.toolRotate,VCPaintRoll.toolGradient)
	for i = 1 to buttonarr.count where i != theTool do
	(
		buttonarr[i].state = false
		buttonStates[i] = false
	)
	buttonarr[theTool].state = true
	buttonStates[theTool] = true
	if ValidPaintObject() then
	(
		if $.material == undefined then
		(
			currentObject = undefined
			currentTextureFile = ""
			VCPaintRoll.ResetButtons()
			AssignMaterialDialog true
		)
		else
		(
			if (currentTextureFile == "") or (not (doesFileExist currentTextureFile)) or (currentObject != undefined and $ != currentObject) or ($.material != currentMaterial) then
			(
				currentObject = undefined
				currentTextureFile = ""
				VCPaintRoll.ResetButtons()
				doRestartTool = true
				VCSetup.BuildMapMenu $.material
			)
			else
			(
				if theTool == 10 then VCPaintRoll.opacspin.value = VCGetSetting 10
				else VCPaintRoll.opacspin.value = VCGetSetting 3
				if theTool == 3 or theTool == 4 then VCPaintRoll.blurradius.enabled = true
				else VCPaintRoll.blurradius.enabled = false
				if theTool == 8 or theTool == 14 then --Fill tool does not use these spinners
				(
					VCPaintRoll.bsize.enabled = false
					VCPaintRoll.opacspin.enabled = true
					VCPaintRoll.hardness.enabled = false
					VCPaintRoll.spacespin.enabled = false
					VCPaintRoll.scatterspin.enabled = false
				)
				else if theTool > 10 then --move, scale, rotate layer
				(
					VCPaintRoll.bsize.enabled = false
					VCPaintRoll.opacspin.enabled = false
					VCPaintRoll.hardness.enabled = false
					VCPaintRoll.spacespin.enabled = false
					VCPaintRoll.scatterspin.enabled = false
				)
				else
				(
					VCPaintRoll.bsize.enabled = true
					VCPaintRoll.opacspin.enabled = true
					VCPaintRoll.hardness.enabled = true
					VCPaintRoll.spacespin.enabled = true
					VCPaintRoll.scatterspin.enabled = true
				)
				
				--Set mapping channel
				if usedMapSlot != undefined do
				(
					VCSetSetting 4 usedMapSlot.coords.mapchannel
					VCOptionsRoll.mapch.value = usedMapSlot.coords.mapchannel
				)
					
				currentObject = $
				isPSDfile = IsFilePSD currentTextureFile
				result = ViewportCanvasSetup theTool currentTextureFile currentBrushFile currentMaskFile isPSDfile
				if result do
				(
					VCOptionsRoll.mapbut.enabled = false
					VCPaintRoll.view2Dbut.enabled = true
					VCPaintRoll.layerdiagbut.enabled = true
					undo off (sel = $; hide sel)
					if wasView2DLeftOpen do VCanvas.Open2DView()
					if VCLayers.LayerDialogLeftOpen do VCLayers.OpenLayerDialog()
					VCStartTrack()
					setwaitCursor()
					if (isValidNode sel) do
					(
						undo off (unhide sel)
					)
					enablesceneredraw()
					ReloadMap()
					VCOptionsRoll.mapbut.enabled = true
					if isView2DOpen then
					(
						wasView2DLeftOpen = true
						VCview2D.Close2dView()
						redrawviews()
					)
					else wasView2DLeftOpen = false
					if (VCGetLayerSetting 9 0) then
					(
						VCLayers.LayerDialogLeftOpen = true
						VCLayers.CloseLayerDialog()
					)
					else VCLayers.LayerDialogLeftOpen = false
					VCPaintRoll.view2Dbut.enabled = false
					VCPaintRoll.layerdiagbut.enabled = false
					redrawviews()
					setarrowCursor()
				)
				if isSceneRedrawDisabled() do --if there was an error in setup redraw will be disabled
				(
					enablesceneredraw()
					redrawviews()
					setarrowCursor()
				)
			)
		)
	)
	else
	(
		VCPaintRoll.ResetButtons()
		messagebox "A valid object is not selected.\nYou need to have one geometry object selected that has a material applied." title:"Viewport Canvas"
	)
),
fn EndPaintTool =
(
	VCPaintRoll.ResetButtons()
	VCEndTrack()
	ViewportCanvasEnd()
),
fn OpenBrushMenu dialogPosition =
(
	if not brushDialogIsOpen do
	(
		rollout VCBrushMenu "Viewport Canvas Brush Images"
		(
			group "Color Presets"
			(
				imgTag colormap1 width:32 height:32 offset:[-3,-2] transparent:(color 255 0 255) tooltip:"Metal"
				imgTag colormap2 width:32 height:32 offset:[28,-37] transparent:(color 255 0 255) tooltip:"Rust"
				imgTag colormap3 width:32 height:32 offset:[59,-37] transparent:(color 255 0 255) tooltip:"Leather"
				imgTag colormap4 width:32 height:32 offset:[90,-37] transparent:(color 255 0 255) tooltip:"Wood Swirly"
				imgTag colormap5 width:32 height:32 offset:[121,-37] transparent:(color 255 0 255) tooltip:"Concrete"
				imgTag colormap6 width:32 height:32 offset:[152,-37] transparent:(color 255 0 255) tooltip:"Skin"
				imgTag colormap7 width:32 height:32 offset:[183,-37] transparent:(color 255 0 255) tooltip:"Colors"
				imgTag colormap8 width:32 height:32 offset:[214,-37] transparent:(color 255 0 255) tooltip:"Fabric"
				imgTag colormap9 width:32 height:32 offset:[245,-37] transparent:(color 255 0 255) tooltip:"Bark"
			)
			group "Mask Presets"
			(
				imgTag maskmap1 width:32 height:32 offset:[-3,-2] transparent:(color 255 0 255) tooltip:"Ring"
				imgTag maskmap2 width:32 height:32 offset:[28,-37] transparent:(color 255 0 255) tooltip:"Rough"
				imgTag maskmap3 width:32 height:32 offset:[59,-37] transparent:(color 255 0 255) tooltip:"Cloud"
				imgTag maskmap4 width:32 height:32 offset:[90,-37] transparent:(color 255 0 255) tooltip:"Abstract"
				imgTag maskmap5 width:32 height:32 offset:[121,-37] transparent:(color 255 0 255) tooltip:"Scratch"
				imgTag maskmap6 width:32 height:32 offset:[152,-37] transparent:(color 255 0 255) tooltip:"Square"
				imgTag maskmap7 width:32 height:32 offset:[183,-37] transparent:(color 255 0 255) tooltip:"Dirt"
				imgTag maskmap8 width:32 height:32 offset:[214,-37] transparent:(color 255 0 255) tooltip:"Fabricmask"
				imgTag maskmap9 width:32 height:32 offset:[245,-37] transparent:(color 255 0 255) tooltip:"Rocks"
			)
			subrollout CustomBrushRollout ""
			button browsebut "Browse Custom Maps Dir" offset:[-64,86] tooltip:"Open folder containing custom map files"
			button reloadbut "Reload Custom Maps" offset:[74,-26] tooltip:"Reload custom files to include new added files. Reopening the menu also does this"
			
			fn SwitchBrush num isCustom =
			(
				fileExists = false
				if isCustom then fileExists = doesFileExist VCanvas.brushImageFileNamesCustom[num]
				else fileExists = doesFileExist VCanvas.brushImageFileNames[num]
				if fileExists then
				(
					if isCustom then brushbitmap = openbitmap VCanvas.brushImageFileNamesCustom[num]
					else brushbitmap = openbitmap VCanvas.brushImageFileNames[num]
					if (brushbitmap != undefined) do
					(
						if isCustom then
						(
							if VCanvas.isSelectingMask then VCanvas.currentMaskFile = VCanvas.brushImageFileNamesCustom[num]
							else VCanvas.currentBrushFile = VCanvas.brushImageFileNamesCustom[num]
							ViewportCanvasSwitchBrush VCanvas.brushImageFileNamesCustom[num] VCanvas.isSelectingMask
						)
						else
						(
							if VCanvas.isSelectingMask then VCanvas.currentMaskFile = VCanvas.brushImageFileNames[num]
							else VCanvas.currentBrushFile = VCanvas.brushImageFileNames[num]
							ViewportCanvasSwitchBrush VCanvas.brushImageFileNames[num] VCanvas.isSelectingMask
						)
						if isCustom then brushbitmap = openbitmap VCanvas.brushImageFileNamesCustom[num]
						else brushbitmap = openbitmap VCanvas.brushImageFileNames[num]
						displaybrush = bitmap 48 48
						VCCreateDisplayBitmap brushbitmap displaybrush
						if VCanvas.isSelectingMask then
						(
							VCanvas.maskDisplayMap = displaybrush
							VCBrushImageRoll.maskmap.bitmap = displaybrush
						)
						else
						(
							VCanvas.colorDisplayMap = displaybrush
							VCBrushImageRoll.brushmap.bitmap = displaybrush
						)
						destroyDialog VCBrushMenu
					)
				)
				else reloadbut.pressed()
			)
			on reloadbut pressed do
			(
				diagpos = getDialogPos VCBrushMenu
				destroyDialog VCBrushMenu
				for i = 1 to VCanvas.customBrushImagesDisplay.count do
				(
					try(close VCanvas.customBrushImagesDisplay[i])catch()
				)
				VCanvas.customBrushImagesDisplay = #()
				VCanvas.OpenBrushMenu diagpos
			)
			on browsebut pressed do
			(
				customdir = VCanvas.brushDir + "Custom Brushes"
				if (getDirectories customdir).count != 0 then shellLaunch customdir ""
				else messagebox "Could not find custom brush directory." title:"Viewport Canvas"
			)
			on colormap1 click do SwitchBrush 1 false
			on colormap2 click do SwitchBrush 2 false
			on colormap3 click do SwitchBrush 3 false
			on colormap4 click do SwitchBrush 4 false
			on colormap5 click do SwitchBrush 5 false
			on colormap6 click do SwitchBrush 6 false
			on colormap7 click do SwitchBrush 7 false
			on colormap8 click do SwitchBrush 8 false
			on colormap9 click do SwitchBrush 9 false
			on maskmap1 click do SwitchBrush 10 false
			on maskmap2 click do SwitchBrush 11 false
			on maskmap3 click do SwitchBrush 12 false
			on maskmap4 click do SwitchBrush 13 false
			on maskmap5 click do SwitchBrush 14 false
			on maskmap6 click do SwitchBrush 15 false
			on maskmap7 click do SwitchBrush 16 false
			on maskmap8 click do SwitchBrush 17 false
			on maskmap9 click do SwitchBrush 18 false
					
			on VCBrushMenu open do
			(
				uibrushcontrols = #(colormap1,colormap2,colormap3,colormap4,colormap5,colormap6,colormap7,colormap8,colormap9)
				uimaskcontrols = #(maskmap1,maskmap2,maskmap3,maskmap4,maskmap5,maskmap6,maskmap7,maskmap8,maskmap9)
				if VCanvas.brushImagesDisplay.count != 0 then
				(
					for i = 1 to 9 do
					(
						uibrushcontrols[i].bitmap = VCanvas.brushImagesDisplay[i]
						uimaskcontrols[i].bitmap = VCanvas.brushImagesDisplay[i + 9]
					)
				)
				else --first time around load all preset maps
				(
					for i = 1 to 9 do
					(
						brushbitmap = openbitmap VCanvas.brushImageFileNames[i]
						displaybrush = bitmap 32 32
						VCCreateDisplayBitmap brushbitmap displaybrush
						close brushbitmap
						uibrushcontrols[i].bitmap = displaybrush
						append VCanvas.brushImagesDisplay displaybrush
					)
					for i = 1 to 9 do
					(
						maskbitmap = openbitmap VCanvas.brushImageFileNames[i + 9]
						displaymask = bitmap 32 32
						VCCreateDisplayBitmap maskbitmap displaymask
						close maskbitmap
						uimaskcontrols[i].bitmap = displaymask
						append VCanvas.brushImagesDisplay displaymask
					)
				)
			)
			on VCBrushMenu close do
			(
				VCanvas.brushDialogIsOpen = false
			)
		)
		if customBrushImagesDisplay.count == 0 then brushImageFileNamesCustom = getFiles (VCanvas.brushDir + "Custom Brushes\\*.tif")
		else --Check to see if there are new custom files or custom files have been deleted
		(
			tempfiles = getFiles (brushDir + "Custom Brushes\\*.tif")
			numbrush = brushImageFileNamesCustom.count
			doreload = false
			if tempfiles.count != numbrush then doreload = true
			else
			(
				for i = 1 to numbrush do
				(
					if not (doesFileExist brushImageFileNamesCustom[i]) do doreload = true
				)
			)
			if doreload do
			(
				for i = 1 to customBrushImagesDisplay.count do (try(close customBrushImagesDisplay[i])catch())
				customBrushImagesDisplay = #()
				brushImageFileNamesCustom = tempfiles
			)
		)
		numcustomBrushes = brushImageFileNamesCustom.count
		customstring = "rollout VCCustomBrushRollout \"Custom Maps\"\n
		(\n"
		tagevents = ""
		for i = 1 to numcustomBrushes do
		(
			currow = floor ((i - 1) / 8.0)
			curpos = i - (currow * 8)
			offsetx = (((curpos - 1) * 31) - 7) as string
			if curpos == 1 then
			(
				if currow == 0 then offsety = (-4) as string
				else offsety = (-6) as string
			)
			else offsety = (-37) as string
			tagstring = "imgTag custommap" + (i as string) + " width:32 height:32 offset:[" + offsetx + "," + offsety + "] transparent:(color 255 0 255) tooltip:\"" + (getFilenameFile brushImageFileNamesCustom[i]) + "\"\n"
			customstring += tagstring
			tagevents += "on custommap" + (i as string) + " click do VCBrushMenu.SwitchBrush " + (i as string) + " true\n"
		)
		customstring += tagevents
		tagarr = "#("
		for i = 1 to numcustomBrushes do
		(
			tagarr += "custommap" + (i as string)
			if i != numcustomBrushes then tagarr += ","
			else tagarr += ")"
		)
		
		openevent = "on VCCustomBrushRollout open do\n
		(\n
			numcustom = VCanvas.brushImageFileNamesCustom.count\n
			uibrushcontrols = " + tagarr + "\n
			if VCanvas.customBrushImagesDisplay.count != 0 then\n
			(\n
				for i = 1 to numcustom do\n
				(\n
					uibrushcontrols[i].bitmap = VCanvas.customBrushImagesDisplay[i]\n
				)\n
			)\n
			else\n
			(\n
				for i = 1 to numcustom do\n
				(\n
					if (doesFileExist VCanvas.brushImageFileNamesCustom[i]) do\n
					(\n
						brushbitmap = openbitmap VCanvas.brushImageFileNamesCustom[i]\n
						displaybrush = bitmap 32 32\n
						VCCreateDisplayBitmap brushbitmap displaybrush\n
						close brushbitmap\n
						uibrushcontrols[i].bitmap = displaybrush\n
						append VCanvas.customBrushImagesDisplay displaybrush\n
					)\n
				)\n
			)\n
		)"
		customstring += openevent
		customstring += ")"
		execute customstring

		if (dialogPosition.x + 415) < (gw.getWinSizeX() / 2) do dialogPosition.x += 550
		if (dialogPosition.x < 0) do dialogPosition.x = 0
		createDialog VCBrushMenu 300 256 dialogPosition.x dialogPosition.y
		AddSubRollout VCBrushMenu.CustomBrushRollout VCCustomBrushRollout fgcolor:(color 0 0 0)
		VCBrushMenu.CustomBrushRollout.height = 100
		VCanvas.brushDialogIsOpen = true
	)
),
fn OpenColorPalette =
(
	rollout ColorPaletteRollout "Color Palette"
	(
		imgTag col1 width:16 height:16 offset:[0,0] transparent:(color 255 0 255)
		imgTag col2 width:16 height:16 offset:[20,-21] transparent:(color 255 0 255)
		imgTag col3 width:16 height:16 offset:[40,-21] transparent:(color 255 0 255)
		imgTag col4 width:16 height:16 offset:[60,-21] transparent:(color 255 0 255)
		imgTag col5 width:16 height:16 offset:[80,-21] transparent:(color 255 0 255)
		imgTag col6 width:16 height:16 offset:[100,-21] transparent:(color 255 0 255)
		imgTag col7 width:16 height:16 offset:[120,-21] transparent:(color 255 0 255)
		imgTag col8 width:16 height:16 offset:[0,-2] transparent:(color 255 0 255)
		imgTag col9 width:16 height:16 offset:[20,-21] transparent:(color 255 0 255)
		imgTag col10 width:16 height:16 offset:[40,-21] transparent:(color 255 0 255)
		imgTag col11 width:16 height:16 offset:[60,-21] transparent:(color 255 0 255)
		imgTag col12 width:16 height:16 offset:[80,-21] transparent:(color 255 0 255)
		imgTag col13 width:16 height:16 offset:[100,-21] transparent:(color 255 0 255)
		imgTag col14 width:16 height:16 offset:[120,-21] transparent:(color 255 0 255)
		imgTag col15 width:16 height:16 offset:[0,-2] transparent:(color 255 0 255)
		imgTag col16 width:16 height:16 offset:[20,-21] transparent:(color 255 0 255)
		imgTag col17 width:16 height:16 offset:[40,-21] transparent:(color 255 0 255)
		imgTag col18 width:16 height:16 offset:[60,-21] transparent:(color 255 0 255)
		imgTag col19 width:16 height:16 offset:[80,-21] transparent:(color 255 0 255)
		imgTag col20 width:16 height:16 offset:[100,-21] transparent:(color 255 0 255)
		imgTag col21 width:16 height:16 offset:[120,-21] transparent:(color 255 0 255)
		imgTag col22 width:16 height:16 offset:[0,-2] transparent:(color 255 0 255)
		imgTag col23 width:16 height:16 offset:[20,-21] transparent:(color 255 0 255)
		imgTag col24 width:16 height:16 offset:[40,-21] transparent:(color 255 0 255)
		imgTag col25 width:16 height:16 offset:[60,-21] transparent:(color 255 0 255)
		imgTag col26 width:16 height:16 offset:[80,-21] transparent:(color 255 0 255)
		imgTag col27 width:16 height:16 offset:[100,-21] transparent:(color 255 0 255)
		imgTag col28 width:16 height:16 offset:[120,-21] transparent:(color 255 0 255)
		button loadpalette "Load" width:36 height:21 offset:[-59,0]
		button savepalette "Save" width:36 height:21 offset:[-21,-26]
		button setdefaultpalette "Set As Default" width:78 height:21 offset:[38,-26]
			
		fn CreateColorPicker num =
		(
			VCanvas.colorPaletteUInum = num
			colstring = "(getpixels ColorPaletteRollout.col" + (num as string) + ".bitmap [0,0] 1)[1]"
			curcol = execute colstring
			ViewportCanvasColorPicker (curcol.r as integer) (curcol.g as integer) (curcol.b as integer)
		)
		fn SetMainColor item num =
		(
			thecol = VCanvas.colorPaletteColors[num]
			VCPaintRoll.colpick.color = thecol
			VCSetSetting 2 (Point3 thecol.r thecol.g thecol.b)
			colpos = item.pos
			item.pos = [0,200]
			sleep 0.06
			item.pos = colpos
		)
		fn SetColor col index =
		(
			colstring = "ColorPaletteRollout.col" + (index as string) + ".bitmap = bitmap 16 16 color:" + (col as string) + ""
			execute colstring
			transparent = execute ("ColorPaletteRollout.col" + (index as string) + ".transparent")
			if transparent == col do
			(
				newtrans = (color (255 - transparent.r) transparent.g transparent.b) as string
				colstring = "ColorPaletteRollout.col" + (index as string) + ".transparent = " + newtrans + ""
				execute colstring
			)
		)
		fn SetPaletteColor col =
		(
			VCanvas.colorPaletteColors[VCanvas.colorPaletteUInum] = col
			SetColor col VCanvas.colorPaletteUInum
			SetMainColor VCanvas.colorPaletteUInum
		)
		on ColorPaletteRollout open do
		(
			if not VCanvas.colorPaletteHasLoaded then
			(
				palettedir = VCanvas.brushDir + "Palettes\\"
				palettefilename = palettedir + "Default.txt"
				if (doesFileExist palettefilename) then
				(
					palettefile = openFile palettefilename
					colorarr = execute (readline palettefile)
					close palettefile
					numcolors = colorarr.count
					for i = 1 to numcolors do
					(
						col = colorarr[i]
						append VCanvas.colorPaletteColors col
						SetColor col i
					)
					VCanvas.colorPaletteHasLoaded = true
				)
				else
				(
					for i = 1 to 28 do
					(
						append VCanvas.colorPaletteColors (color 0 0 0)
						SetColor VCanvas.colorPaletteColors[i] i
					)
					VCanvas.colorPaletteHasLoaded = true
				)
			)
			else
			(
				for i = 1 to 28 do
				(
					SetColor VCanvas.colorPaletteColors[i] i
				)
			)
			VCanvas.colorPaletteOpen = true
		)
		on ColorPaletteRollout close do
		(
			VCanvas.colorPaletteOpen = false
		)
		on loadpalette pressed do
		(
			palettedir = VCanvas.brushDir + "Palettes\\"
			palettefilename = GetOpenFileName caption:"Load Palette" filename:palettedir types:"Text(*.txt)|*.txt|"
			if (palettefilename != undefined) and (doesFileExist palettefilename) do
			(
				palettefile = openFile palettefilename
				VCanvas.colorPaletteColors = execute (readline palettefile)
				close palettefile
				for i = 1 to 28 do
				(
					SetColor VCanvas.colorPaletteColors[i] i
				)
			)
		)
		on savepalette pressed do
		(
			palettedir = VCanvas.brushDir + "Palettes\\"
			palettefiledir = palettedir + "Palette_01.txt"
			palettefilename = GetSaveFileName caption:"Save Palette" filename:palettefiledir types:"Text(*.txt)|*.txt|"
			if palettefilename != undefined do
			(
				if (doesFileExist palettefilename) and (getFileAttribute palettefilename #readOnly) do
				(
					setFileAttribute palettefilename #readOnly false
				)
				palettefile = createfile palettefilename
				format "#(" to:palettefile
				for i = 1 to 28 do
				(
					curcol = (VCanvas.colorPaletteColors[i]) as string
					format curcol to:palettefile
					if i < 28 do format "," to:palettefile
				)
				format ")" to:palettefile
				close palettefile
			)
		)
		on setdefaultpalette pressed do
		(
			if (querybox "Do you want to set the current palette as default?" title:"Color Palette") do
			(
				palettedir = VCanvas.brushDir + "Palettes\\"
				palettefilename = palettedir + "Default.txt"
				if not (doesFileExist palettefilename) do
				(
					palettefile = createfile palettefilename
					close palettefile
				)
				if (doesFileExist palettefilename) do
				(
					if (getFileAttribute palettefilename #readOnly) do
					(
						setFileAttribute palettefilename #readOnly false
					)
					palettefile = openFile palettefilename mode:"w+"
					format "#(" to:palettefile
					for i = 1 to 28 do
					(
						curcol = (VCanvas.colorPaletteColors[i]) as string
						format curcol to:palettefile
						if i < 28 do format "," to:palettefile
					)
					format ")" to:palettefile
					close palettefile
				)
			)
		)
		
		on col1 click do (SetMainColor col1 1)
		on col2 click do (SetMainColor col2 2)
		on col3 click do (SetMainColor col3 3)
		on col4 click do (SetMainColor col4 4)
		on col5 click do (SetMainColor col5 5)
		on col6 click do (SetMainColor col6 6)
		on col7 click do (SetMainColor col7 7)
		on col8 click do (SetMainColor col8 8)
		on col9 click do (SetMainColor col9 9)
		on col10 click do (SetMainColor col10 10)
		on col11 click do (SetMainColor col11 11)
		on col12 click do (SetMainColor col12 12)
		on col13 click do (SetMainColor col13 13)
		on col14 click do (SetMainColor col14 14)
		on col15 click do (SetMainColor col15 15)
		on col16 click do (SetMainColor col16 16)
		on col17 click do (SetMainColor col17 17)
		on col18 click do (SetMainColor col18 18)
		on col19 click do (SetMainColor col19 19)
		on col20 click do (SetMainColor col20 20)
		on col21 click do (SetMainColor col21 21)
		on col22 click do (SetMainColor col22 22)
		on col23 click do (SetMainColor col23 23)
		on col24 click do (SetMainColor col24 24)
		on col25 click do (SetMainColor col25 25)
		on col26 click do (SetMainColor col26 26)
		on col27 click do (SetMainColor col27 27)
		on col28 click do (SetMainColor col28 28)
		on col1 rightclick do (CreateColorPicker 1)
		on col2 rightclick do (CreateColorPicker 2)
		on col3 rightclick do (CreateColorPicker 3)
		on col4 rightclick do (CreateColorPicker 4)
		on col5 rightclick do (CreateColorPicker 5)
		on col6 rightclick do (CreateColorPicker 6)
		on col7 rightclick do (CreateColorPicker 7)
		on col8 rightclick do (CreateColorPicker 8)
		on col9 rightclick do (CreateColorPicker 9)
		on col10 rightclick do (CreateColorPicker 10)
		on col11 rightclick do (CreateColorPicker 11)
		on col12 rightclick do (CreateColorPicker 12)
		on col13 rightclick do (CreateColorPicker 13)
		on col14 rightclick do (CreateColorPicker 14)
		on col15 rightclick do (CreateColorPicker 15)
		on col16 rightclick do (CreateColorPicker 16)
		on col17 rightclick do (CreateColorPicker 17)
		on col18 rightclick do (CreateColorPicker 18)
		on col19 rightclick do (CreateColorPicker 19)
		on col20 rightclick do (CreateColorPicker 20)
		on col21 rightclick do (CreateColorPicker 21)
		on col22 rightclick do (CreateColorPicker 22)
		on col23 rightclick do (CreateColorPicker 23)
		on col24 rightclick do (CreateColorPicker 24)
		on col25 rightclick do (CreateColorPicker 25)
		on col26 rightclick do (CreateColorPicker 26)
		on col27 rightclick do (CreateColorPicker 27)
		on col28 rightclick do (CreateColorPicker 28)
	)
	mainpos = VCMainFloater.pos
	if mainpos.x > (gw.getWinSizeX() / 2) then menupos = [mainpos.x - 170,mainpos.y + 278]
	else menupos = [mainpos.x + VCMainFloater.size.x + 8, mainpos.y + 278]
	createDialog ColorPaletteRollout 162 110 menupos.x menupos.y
),
fn Open2DView =
(
	if VCview2D == undefined do
	(
		rollout VCview2D "2D Paint"
		(
			button toggleUVwire "Wire" width:32 height:22 align:#left tooltip:"Toggle UV Wireframe"
			button fittex "Fit " width:32 height:22 align:#left offset:[40,-27] tooltip:"Fit Texture To View"
			button fullsiz "1:1" width:32 height:22 align:#left offset:[80,-27] tooltip:"Actual Size"
			
			fn Resize2DView orig newWidth =
			(
				diagpos = getDialogPos VCview2D
				diagpos.x = orig - 6
				setDialogpos VCview2D diagpos
				VCview2D.width = newWidth + 6
			)
			fn Close2dView =
			(
				destroyDialog VCview2D
			)
			
			on toggleUVwire pressed do VCToggleUVWireframe()
			on fittex pressed do VCFitTextureToView2D()
			on fullsiz pressed do VCFullSizeView2D()
			on VCview2D open do
			(
				--Assign button images
				backColor = colorman.getcolor #background
				buttonImageAlpha = bitmap 192 22
				buttonImage = bitmap 192 22 color:([255,255,255] * (colorman.getcolor #background))
				colSum = (backColor.x + backColor.y + backColor.z) / 3
				useDark = false
				if (colSum < 0.5) then
				(
					useDark = true
					filename = (VCanvas.brushDir + "View2DButtonsDark.bmp")
				)
				else filename = (VCanvas.brushDir + "View2DButtonsLight.bmp")
				VCCreateToolButtonImage buttonImage filename useDark backColor
				toggleUVwire.images = #(buttonImage, buttonImageAlpha, 6, 1, 4, 1, 4)
				fittex.images = #(buttonImage, buttonImageAlpha, 6, 2, 5, 2, 5)
				fullsiz.images = #(buttonImage, buttonImageAlpha, 6, 3, 6, 3, 6)
			
				diagpos = getDialogPos VCview2D
				diagpos.x += 6
				diagpos.y += (GetDialogSize VCview2D).y + 30.0
				VCSet2DViewOpen true diagpos
				VCanvas.isView2DOpen = true
			)
			on VCview2D close do
			(
				VCanvas.view2DPos = getDialogPos VCview2D
				VCSet2DViewOpen false
				VCanvas.isView2DOpen= false
			)
			on VCview2D moved pos do
			(
				diagpos = getDialogPos VCview2D
				VCanvas.view2DPos = diagpos
				diagpos.x += 6
				diagpos.y += (GetDialogSize VCview2D).y + 30.0
				VCMove2DView diagpos
			)
		)
	)
	createDialog VCview2D 520 30 view2DPos.x view2DPos.y style:#(#style_titlebar, #style_border, #style_sysmenu,#style_toolwindow)
)
) --End ViewportCanvasStruct

rollout VCBrushImageRoll "Brush Images"
(
	label collab "Color:" align:#left offset:[-6,0]
	checkbox usebcol "Use" checked:(VCGetSetting 8) align:#left offset:[-7,0]
	imgTag brushmap width:48 height:48 offset:[38,-40] transparent:(color 255 0 255)
	label masklab "Mask:" offset:[22,-51]
	checkbox usebmask "Use" checked:(VCGetSetting 9) align:#center offset:[28,0]
	imgTag maskmap width:48 height:48 offset:[146,-40] transparent:(color 255 0 255)
	
	group "Rotation:"
	(
		radiobuttons orientradio "" labels:#("None","Follow Stroke","Random") default:1 columns:2 offset:[0,-2]
	)
	groupbox colbox "" width:1 height:60 align:#center pos:[108,-2] --offset:[0,-61]

	on usebcol changed state do VCSetSetting 8 state
	on usebmask changed state do VCSetSetting 9 state
	on brushmap lbuttonup pos flags do
	(
		leftcorner = mouse.screenpos - pos
		VCanvas.isSelectingMask = false
		VCanvas.OpenBrushMenu [leftcorner.x - 370,leftcorner.y - 45]
	)
	on maskmap lbuttonup pos flags do
	(
		leftcorner = mouse.screenpos - pos
		VCanvas.isSelectingMask = true
		VCanvas.OpenBrushMenu [leftcorner.x - 478,leftcorner.y - 45]
	)
	on orientradio changed num do
	(
		if num == 1 then
		(
			VCSetSetting 7 false
			VCSetSetting 27 false
		)
		else if num == 2 then
		(
			VCSetSetting 7 false
			VCSetSetting 27 true
		)
		else
		(
			VCSetSetting 7 true
			VCSetSetting 27 false
		)
	)
	on VCBrushImageRoll open do
	(
		if (VCGetSetting 27) then orientradio.state = 2
		else if (VCGetSetting 7) then orientradio.state = 3
		else orientradio.state = 1
		if VCanvas.colorDisplayMap != undefined do
		(
			close VCanvas.colorDisplayMap
			close VCanvas.maskDisplayMap
			VCanvas.colorDisplayMap = undefined
			VCanvas.maskDisplayMap = undefined
		)
		if VCanvas.colorDisplayMap == undefined do
		(
			if VCanvas.currentBrushFile.count == 0 then brushfile = VCanvas.brushDir + "Nomap.tif"
			else brushfile = VCanvas.currentBrushFile
			if VCanvas.currentMaskFile.count == 0 then maskfile = VCanvas.brushDir + "Nomap.tif"
			else maskfile = VCanvas.currentMaskFile
			brushbitmap = openbitmap brushfile
			maskbitmap = openbitmap maskfile
			VCanvas.colorDisplayMap = bitmap 48 48
			VCanvas.maskDisplayMap = bitmap 48 48
			VCCreateDisplayBitmap brushbitmap VCanvas.colorDisplayMap
			VCCreateDisplayBitmap maskbitmap VCanvas.maskDisplayMap
		)
		brushmap.bitmap = VCanvas.colorDisplayMap
		maskmap.bitmap = VCanvas.maskDisplayMap
	)
)

rollout VCBrushImageSettingsRoll "Brush Image Settings"
(
	group "Projection:"
	(
		radiobuttons projradio "" labels:#("Hit Normal","From Screen") default:2 columns:2
	)
	checkbox scalecol "Fit To Brush" checked:(VCGetSetting 21) align:#left offset:[0,16]
	label tillab1 "Tiling: " align:#left offset:[-2,2]
	radiobuttons tilcolradio "" labels:#("None","Tile","Across Screen") default:1 columns:1 offset:[-52,0]

	checkbox scalemask "Fit To Brush" checked:(VCGetSetting 22) align:#left offset:[108,-90]
	label tillab2 "Tiling: " align:#left offset:[108,2]
	radiobuttons tilmaskradio "" labels:#("None","Tile","Across Screen") default:1 columns:1 offset:[54,0]
	
	groupbox colbox "Color:" width:102 height:110 pos:[4,50]
	groupbox maskbox "Mask:" width:102 height:110 pos:[111,50]
	
	on projradio changed num do
	(
		if num == 1 then VCSetSetting 20 true --Hit Normal
		else VCSetSetting 20 false --Screen project
	)
	on scalecol changed state do VCSetSetting 21 state
	on scalemask changed state do VCSetSetting 22 state
	on tilcolradio changed num do
	(
		if num == 1 then --None
		(
			VCSetSetting 13 false
			VCSetSetting 23 false
		)
		else if num == 2 then --Tile
		(
			VCSetSetting 13 true
			VCSetSetting 23 false
		)
		else --Screen tile
		(
			VCSetSetting 13 false
			VCSetSetting 23 true
		)
	)
	on tilmaskradio changed num do
	(
		if num == 1 then --None
		(
			VCSetSetting 14 false
			VCSetSetting 24 false
		)
		else if num == 2 then --Tile
		(
			VCSetSetting 14 true
			VCSetSetting 24 false
		)
		else --Screen tile
		(
			VCSetSetting 14 false
			VCSetSetting 24 true
		)
	)
	on VCBrushImageSettingsRoll open do
	(
		if (VCGetSetting 20) then projradio.state = 1 else projradio.state = 2
		if (VCGetSetting 13) then tilcolradio.state = 2
		else if (VCGetSetting 23) then tilcolradio.state = 3
		else tilcolradio.state = 1
		if (VCGetSetting 14) then tilmaskradio.state = 2
		else if (VCGetSetting 24) then tilmaskradio.state = 3
		else tilmaskradio.state = 1
	)
)
rollout VCBehaveRoll "Paint Behavior"
(
	group "Paint Affects:"
	(
		radiobuttons affectadio "" labels:#("Spherical Radius","Depth") default:(VCGetSetting 51) columns:2 offset:[24,0]
	)
	group "Mirroring:"
	(
		radiobuttons mirrorradio "" labels:#("None","X","Y","Z") default:((VCGetSetting 49)+ 2) columns:4 offset:[12,0]
	)
	group "Clone Source:"
	(
		radiobuttons cloneradio "" labels:#("Current Layer","All Layers","Viewport") default:(VCGetSetting 50) columns:2
	)
	group "Fill Tool - Brush Images:"
	(
		radiobuttons fillradio "" labels:#("Tile","3D Wrap") default:(VCGetSetting 53) columns:2 offset:[4,0]
	)
	
	on affectadio changed num do VCSetSetting 51 num
	on mirrorradio changed num do VCSetSetting 49 (num - 2)
	on cloneradio changed num do VCSetSetting 50 num
	on fillradio changed num do VCSetSetting 53 num
)
rollout VCSettingsRoll "Load/Save Settings"
(
	button lodbut "Load" width:80 height:20 offset:[-46,0] tooltip:"Load Settings"
	button savbut "Save" width:80 height:20 offset:[46,-25] tooltip:"Save Settings"
	button setdefbut "Set Current Settings As Default" width:171 height:20 tooltip:"Set Current Settings As Default"
	
	on lodbut pressed do
	(
		settingsDir = VCanvas.brushDir + "Settings\\"
		settingsFileName = GetOpenFileName caption:"Load Settings" filename:settingsDir types:"Text(*.txt)|*.txt|"
		if (settingsFileName != undefined) and (doesFileExist settingsFileName) do
		(
			settings = execute (getINISetting settingsFileName "InterfaceSettings" "ToolSettings")
			numsettings = settings.count
			for i = 1 to numsettings do
			(
				VCSetSetting i settings[i]
			)
			
			cui.unRegisterDialogBar VCMainFloater
			closeRolloutFloater VCMainFloater
			VCanvas.rolloutStates = execute (getINISetting settingsFileName "InterfaceSettings" "RolloutStates")
			VCanvas.dialogPos = execute (getINISetting settingsFileName "InterfaceSettings" "DialogPos")
			VCanvas.dialogHeight = execute (getINISetting settingsFileName "InterfaceSettings" "DialogHeight")
			VCanvas.view2DPos = execute (getINISetting settingsFileName "InterfaceSettings" "view2DPos")
			VCLayers.LayerDialogPos = execute (getINISetting settingsFileName "InterfaceSettings" "LayerDialogPos")
			VCanvas.dialogDockingState = (getINISetting settingsFileName "InterfaceSettings" "DockingState") as name
			VCLayers.LayerDialogDockState = (getINISetting settingsFileName "InterfaceSettings" "LayerDialogDockingState") as name
			VCanvas.wasView2DLeftOpen = execute (getINISetting settingsFileName "InterfaceSettings" "View2DOpen")
			VCLayers.LayerDialogLeftOpen = execute (getINISetting settingsFileName "InterfaceSettings" "LayerDialogOpen")
			
			VCMainFloater = newRolloutFloater "Viewport Canvas" 230 VCanvas.dialogHeight VCanvas.dialogPos.x VCanvas.dialogPos.y
			addRollout VCPaintRoll VCMainFloater rolledUp:false border:false
			addRollout VCBrushImageRoll VCMainFloater rolledUp:VCanvas.rolloutStates[1] border:true
			addRollout VCBrushImageSettingsRoll VCMainFloater rolledUp:VCanvas.rolloutStates[2] border:true
			addRollout VCOptionsRoll VCMainFloater rolledUp:VCanvas.rolloutStates[3] border:true
			addRollout VCBehaveRoll VCMainFloater rolledUp:VCanvas.rolloutStates[4] border:true
			addRollout VCRandomizeRoll VCMainFloater rolledUp:VCanvas.rolloutStates[5] border:true
			addRollout VCPressureRoll VCMainFloater rolledUp:VCanvas.rolloutStates[6] border:true
			addRollout VCSettingsRoll VCMainFloater rolledUp:VCanvas.rolloutStates[7] border:true
			cui.RegisterDialogBar VCMainFloater style:#(#cui_floatable, #cui_dock_vert) minSize:[236,100] maxSize:[236,1600]
			if (VCanvas.dialogDockingState != #cui_floatable) do
			(
				cui.DockDialogBar VCMainFloater VCanvas.dialogDockingState
			)
		)
	)
	on savbut pressed do
	(
 		settingsFileDir = VCanvas.brushDir + "Settings\\Canvas_Settings_01.txt"
		settingsFileName = GetSaveFileName caption:"Save Settings" filename:settingsfiledir types:"Text(*.txt)|*.txt|"
		if (settingsFileName != undefined) do
		(
			if (doesFileExist settingsFileName) and (getFileAttribute settingsFileName #readOnly) do
			(
				setFileAttribute settingsFileName #readOnly false
			)
			settings = "#("
			for i = 1 to 53 do
			(
				settings += (VCGetSetting i) as string
				if i < 53 do settings += ","
			)
			settings += ")"
			setINISetting settingsFileName "InterfaceSettings" "ToolSettings" settings
			
			VCanvas.dialogDockingState = cui.getDockState VCMainFloater
			cui.unRegisterDialogBar VCMainFloater
			VCanvas.dialogPos = VCMainFloater.pos
			VCanvas.dialogHeight = VCMainFloater.size.y
			cui.RegisterDialogBar VCMainFloater style:#(#cui_floatable, #cui_dock_vert) minSize:[236,100] maxSize:[236,1600]
			if (VCanvas.dialogDockingState != #cui_floatable) do
			(
				cui.DockDialogBar VCMainFloater VCanvas.dialogDockingState
			)
			if VCanvas.isView2DOpen do VCanvas.view2DPos = getDialogPos VCview2D
			
			VCanvas.rolloutStates = #(not VCBrushImageRoll.open,not VCBrushImageSettingsRoll.open,not VCOptionsRoll.open,not VCBehaveRoll.open,not VCRandomizeRoll.open,not VCPressureRoll.open,true)
			
			setINISetting settingsFileName "InterfaceSettings" "RolloutStates" (VCanvas.rolloutStates as string)
			setINISetting settingsFileName "InterfaceSettings" "DialogPos" (VCanvas.dialogPos as string)
			setINISetting settingsFileName "InterfaceSettings" "DialogHeight" (VCanvas.dialogHeight as string)
			setINISetting settingsFileName "InterfaceSettings" "view2DPos" (VCanvas.view2DPos as string)
			setINISetting settingsFileName "InterfaceSettings" "LayerDialogPos" (VCLayers.LayerDialogPos as string)
			setINISetting settingsFileName "InterfaceSettings" "DockingState" (VCanvas.dialogDockingState as string)
			setINISetting settingsFileName "InterfaceSettings" "LayerDialogDockingState" (VCLayers.LayerDialogDockState as string)
			if (VCGetSetting 100) then --if paint is active
			(
				setINISetting settingsFileName "InterfaceSettings" "View2DOpen" (VCanvas.isView2DOpen as string)
				setINISetting settingsFileName "InterfaceSettings" "LayerDialogOpen" ((VCGetLayerSetting 9) as string)
			)
			else
			(
				setINISetting settingsFileName "InterfaceSettings" "View2DOpen" (VCanvas.wasView2DLeftOpen as string)
				setINISetting settingsFileName "InterfaceSettings" "LayerDialogOpen" (VCLayers.LayerDialogLeftOpen as string)
			)
		)
	)
	on setdefbut pressed do
	(
		if (querybox "Do you want to set the current settings as default?" title:"Viewport Canvas") do
		(
			settingsFileName = VCanvas.brushDir + "Settings\\Default.txt"
			if not (doesFileExist settingsFileName) do createFile settingsFileName
			if (getFileAttribute settingsFileName #readOnly) do
			(
				setFileAttribute settingsFileName #readOnly false
			)
			if (doesFileExist settingsFileName) do
			(
				settings = "#("
				for i = 1 to 53 do
				(
					settings += (VCGetSetting i) as string
					if i < 53 do settings += ","
				)
				settings += ")"
				setINISetting settingsFileName "InterfaceSettings" "ToolSettings" settings
				
				VCanvas.dialogDockingState = cui.getDockState VCMainFloater
				cui.unRegisterDialogBar VCMainFloater
				VCanvas.dialogPos = VCMainFloater.pos
				VCanvas.dialogHeight = VCMainFloater.size.y
				cui.RegisterDialogBar VCMainFloater style:#(#cui_floatable, #cui_dock_vert) minSize:[236,100] maxSize:[236,1600]
				if (VCanvas.dialogDockingState != #cui_floatable) do
				(
					cui.DockDialogBar VCMainFloater VCanvas.dialogDockingState
				)
				if VCanvas.isView2DOpen do VCanvas.view2DPos = getDialogPos VCview2D
				
				VCanvas.rolloutStates = #(not VCBrushImageRoll.open,not VCBrushImageSettingsRoll.open,not VCOptionsRoll.open,not VCBehaveRoll.open,not VCRandomizeRoll.open,not VCPressureRoll.open,true)
				
				setINISetting settingsFileName "InterfaceSettings" "RolloutStates" (VCanvas.rolloutStates as string)
				setINISetting settingsFileName "InterfaceSettings" "DialogPos" (VCanvas.dialogPos as string)
				setINISetting settingsFileName "InterfaceSettings" "DialogHeight" (VCanvas.dialogHeight as string)
				setINISetting settingsFileName "InterfaceSettings" "view2DPos" (VCanvas.view2DPos as string)
				setINISetting settingsFileName "InterfaceSettings" "LayerDialogPos" (VCLayers.LayerDialogPos as string)
				setINISetting settingsFileName "InterfaceSettings" "DockingState" (VCanvas.dialogDockingState as string)
				setINISetting settingsFileName "InterfaceSettings" "LayerDialogDockingState" (VCLayers.LayerDialogDockState as string)
				if (VCGetSetting 100) do --if paint is active
				(
					setINISetting settingsFileName "InterfaceSettings" "View2DOpen" (VCanvas.isView2DOpen as string)
					setINISetting settingsFileName "InterfaceSettings" "LayerDialogOpen" ((VCGetLayerSetting 9) as string)
				)
			)
		)
	)
)
rollout VCRandomizeRoll "Randomize"
(
	checkbox bsizecheck "Brush Radius:"  checked:(VCGetSetting 28) offset:[0,-2]
	spinner bsizemin "Min: " range:[1,999,(VCGetSetting 34)] type:#integer fieldwidth:36 offset:[-90,-2] enabled:(VCGetSetting 28)
	spinner bsizemax "Max: " range:[2,1000,(VCGetSetting 35)] type:#integer fieldwidth:36 align:#right offset:[0,-21] enabled:(VCGetSetting 28)
	checkbox opaccheck "Opacity:"  checked:(VCGetSetting 30) offset:[0,-2]
	spinner opacmin "Min: " range:[0,99,(VCGetSetting 38)] type:#integer fieldwidth:36 offset:[-90,-2] enabled:(VCGetSetting 30)
	spinner opacmax "Max: " range:[1,100,(VCGetSetting 39)] type:#integer fieldwidth:36 align:#right offset:[0,-21] enabled:(VCGetSetting 30)
	checkbox eopaccheck "Eraser Opacity:"  checked:(VCGetSetting 31) offset:[0,-2]
	spinner eopacmin "Min: " range:[0,99,(VCGetSetting 40)] type:#integer fieldwidth:36 offset:[-90,-2] enabled:(VCGetSetting 31)
	spinner eopacmax "Max: " range:[1,100,(VCGetSetting 41)] type:#integer fieldwidth:36 align:#right offset:[0,-21] enabled:(VCGetSetting 31)
	checkbox hardcheck "Hardness:"  checked:(VCGetSetting 29) offset:[0,-2]
	spinner hardmin "Min: " range:[0,99,(VCGetSetting 36)] type:#integer fieldwidth:36 offset:[-90,-2] enabled:(VCGetSetting 29)
	spinner hardmax "Max: " range:[1,100,(VCGetSetting 37)] type:#integer fieldwidth:36 align:#right offset:[0,-21] enabled:(VCGetSetting 29)
	checkbox spacecheck "Spacing:"  checked:(VCGetSetting 32) offset:[0,-2]
	spinner spacemin "Min: " range:[0.05,19.999,(VCGetSetting 42)] type:#float scale:0.01 fieldwidth:36 offset:[-90,-2] enabled:(VCGetSetting 32)
	spinner spacemax "Max: " range:[0.051,20.0,(VCGetSetting 43)] type:#float scale:0.01 fieldwidth:36 align:#right offset:[0,-21] enabled:(VCGetSetting 32)
	checkbox scattcheck "Scatter:"  checked:(VCGetSetting 33) offset:[0,-2]
	spinner scattmin "Min: " range:[0,499,(VCGetSetting 44)] type:#integer fieldwidth:36 offset:[-90,-2] enabled:(VCGetSetting 33)
	spinner scattmax "Max: " range:[1,500,(VCGetSetting 45)] type:#integer fieldwidth:36 align:#right offset:[0,-21] enabled:(VCGetSetting 33)
	checkbox colcheck "Color:"  checked:(VCGetSetting 46) offset:[0,-2]
	colorpicker coljitt "" modal:false color:(VCGetSetting 47) title:"ViewportCanvas color" align:#center offset:[-18,-20] enabled:(VCGetSetting 46)
	
	on bsizemin entered do
	(
		VCSetSetting 34 bsizemin.value
		if (bsizemin.value >= bsizemax.value) do
		(
			bsizemax.value = bsizemin.value + 1
			VCSetSetting 35 bsizemax.value
		)
	)
	on bsizemax entered do
	(
		VCSetSetting 35 bsizemax.value
		if (bsizemax.value <= bsizemin.value) do
		(
			bsizemin.value = bsizemax.value - 1
			VCSetSetting 34 bsizemin.value
		)
	)
	on hardmin entered do
	(
		VCSetSetting 36 hardmin.value
		if (hardmin.value >= hardmax.value) do
		(
			hardmax.value = hardmin.value + 1
			VCSetSetting 37 hardmax.value
		)
	)
	on hardmax entered do
	(
		VCSetSetting 37 hardmax.value
		if (hardmax.value <= hardmin.value) do
		(
			hardmin.value = hardmax.value - 1
			VCSetSetting 36 hardmin.value
		)
	)
	on opacmin entered do
	(
		VCSetSetting 38 opacmin.value
		if (opacmin.value >= opacmax.value) do
		(
			opacmax.value = opacmin.value + 0.001
			VCSetSetting 39 opacmax.value
		)
	)
	on opacmax entered do
	(
		VCSetSetting 39 opacmax.value
		if (opacmax.value <= opacmin.value) do
		(
			opacmin.value = opacmax.value - 0.001
			VCSetSetting 38 opacmin.value
		)
	)
	on eopacmin entered do
	(
		VCSetSetting 40 eopacmin.value
		if (eopacmin.value >= eopacmax.value) do
		(
			eopacmax.value = eopacmin.value + 0.001
			VCSetSetting 41 eopacmax.value
		)
	)
	on eopacmax entered do
	(
		VCSetSetting 41 eopacmax.value
		if (eopacmax.value <= eopacmin.value) do
		(
			eopacmin.value = eopacmax.value - 0.001
			VCSetSetting 40 eopacmin.value
		)
	)
	on spacemin entered do
	(
		VCSetSetting 42 spacemin.value
		if (spacemin.value >= spacemax.value) do
		(
			spacemax.value = spacemin.value + 0.001
			VCSetSetting 43 spacemax.value
		)
	)
	on spacemax entered do
	(
		VCSetSetting 43 spacemax.value
		if (spacemax.value <= spacemin.value) do
		(
			spacemin.value = spacemax.value - 0.001
			VCSetSetting 42 spacemin.value
		)
	)
	on scattmin entered do
	(
		VCSetSetting 44 scattmin.value
		if (scattmin.value >= scattmax.value) do
		(
			scattmax.value = scattmin.value + 1
			VCSetSetting 45 scattmax.value
		)
	)
	on scattmax entered do
	(
		VCSetSetting 45 scattmax.value
		if (scattmax.value <= scattmin.value) do
		(
			scattmin.value = scattmax.value - 1
			VCSetSetting 44 scattmin.value
		)
	)
	on bsizecheck changed state do
	(
		VCSetSetting 28 state
		bsizemin.enabled = bsizemax.enabled = state
	)
	on hardcheck changed state do
	(
		VCSetSetting 29 state
		hardmin.enabled = hardmax.enabled = state
	)
	on opaccheck changed state do
	(
		VCSetSetting 30 state
		opacmin.enabled = opacmax.enabled = state
	)
	on eopaccheck changed state do
	(
		VCSetSetting 31 state
		eopacmin.enabled = eopacmax.enabled = state
	)
	on spacecheck changed state do
	(
		VCSetSetting 32 state
		spacemin.enabled = spacemax.enabled = state
	)
	on scattcheck changed state do
	(
		VCSetSetting 33 state
		scattmin.enabled = scattmax.enabled = state
	)
	on colcheck changed state do
	(
		VCSetSetting 46 state
		coljitt.enabled = coljitt.enabled = state
	)
	on coljitt changed col do VCSetSetting 47 (Point3 col.r col.g col.b)
)
rollout VCPressureRoll "Tablet Pressure"
(
	checkbox pressuresiz "Brush Radius"  checked:(VCGetSetting 16)
	checkbox pressureopac "Opacity"  checked:(VCGetSetting 17) offset:[100,-20]
	checkbox pressurehard "Hardness"  checked:(VCGetSetting 18)
	checkbox pressurescatt "Scatter"  checked:(VCGetSetting 48) offset:[100,-20]
	
	on pressuresiz changed state do VCSetSetting 16 state
	on pressureopac changed state do VCSetSetting 17 state
	on pressurehard changed state do VCSetSetting 18 state
	on pressurescatt changed state do VCSetSetting 48 state
)
rollout VCOptionsRoll "Options"
(
	label maplab "Paint On: " offset:[-72,1]
	button mapbut "Pick Map..." width:140 height:21 offset:[28,-22] tooltip:"Choose Map To Paint On"
	spinner mapch "Map Channel: " range:[1,99,(VCGetSetting 4)] type:#integer fieldwidth:36 align:#center
	checkbox savetex "Save Texture" checked:(VCGetSetting 11)
	checkbox brushprev "Brush Preview"  checked:(VCGetSetting 15) align:#right offset:[6,-20]
	
	on mapbut pressed do
	(
		if VCanvas.ValidPaintObject() then
		(
			if $.material == undefined then VCanvas.AssignMaterialDialog false
			else VCSetup.BuildMapMenu $.material
		)
		else messagebox "A valid object is not selected.\nYou need to have one geometry object selected that has a material applied." title:"Viewport Canvas"
	)
	on mapch entered do VCSetSetting 4 mapch.value
	on savetex changed state do VCSetSetting 11 state
	on brushprev changed state do VCSetSetting 15 state
	on VCOptionsRoll open do
	(
		mapbut.text = VCanvas.mapSlotName
		buttonarr = #(VCPaintRoll.toolPaint,VCPaintRoll.toolClone,VCPaintRoll.toolBlur,VCPaintRoll.toolSharpen,VCPaintRoll.toolContrast,VCPaintRoll.toolDodge,VCPaintRoll.toolBurn,VCPaintRoll.toolFill,VCPaintRoll.toolSmudge,VCPaintRoll.toolErase,VCPaintRoll.toolMove,VCPaintRoll.toolScale,VCPaintRoll.toolRotate,VCPaintRoll.toolGradient)
		isToolActive = false
		for i = 1 to buttonarr.count do
		(
			if buttonarr[i].state do
			(
				isToolActive = true
				exit
			)
		)
		if isToolActive do mapbut.enabled = false
	)
)
rollout VCPaintRoll "Paint"
(
	checkbutton toolPaint "Paint" width:38 height:30 offset:[-80,-4] highlightcolor:[158,234,180] tooltip:"Paint"
	checkbutton toolErase "Erase" width:38 height:30 offset:[-38,-35] highlightcolor:[158,234,180] tooltip:"Erase"
	checkbutton toolClone "Clone" width:38 height:30 offset:[4,-35] highlightcolor:[158,234,180] tooltip:"Clone"
	checkbutton toolFill "Fill" width:38 height:30 offset:[46,-35] highlightcolor:[158,234,180] tooltip:"Fill"
	checkbutton toolGradient "Gradient" width:38 height:30 offset:[89,-35] highlightcolor:[158,234,180] tooltip:"Gradient"
	
	checkbutton toolBlur "Blur" width:38 height:30 offset:[-80,-2] highlightcolor:[158,234,180] tooltip:"Blur"
	checkbutton toolSharpen "Sharpen" width:38 height:30 offset:[-38,-35] highlightcolor:[158,234,180] tooltip:"Sharpen"
	checkbutton toolContrast "Contrast" width:38 height:30 offset:[4,-35] highlightcolor:[158,234,180] tooltip:"Contrast"
	checkbutton toolDodge "Dodge" width:38 height:30 offset:[46,-35] highlightcolor:[158,234,180] tooltip:"Dodge"
	checkbutton toolBurn "Burn" width:38 height:30 offset:[89,-35] highlightcolor:[158,234,180] tooltip:"Burn"
	
	checkbutton toolSmudge "Smudge" width:38 height:30 offset:[-80,-2] highlightcolor:[158,234,180] tooltip:"Smudge"
	label translab "Layer:" align:#left offset:[42,-28]
	checkbutton toolMove "Move" width:38 height:30 offset:[4,-25] highlightcolor:[158,234,180] tooltip:"Move Layer"
	checkbutton toolRotate "Rotate" width:38 height:30 offset:[46,-35] highlightcolor:[158,234,180] tooltip:"Rotate Layer"
	checkbutton toolScale "Scale" width:38 height:30 offset:[89,-35]highlightcolor:[158,234,180] tooltip:"Scale Layer"
	
	colorpicker colpick "" modal:false width:56 color:(VCGetSetting 2) title:"ViewportCanvas color" align:#center offset:[-70,22]
	button colblack "" width:24 height:16 offset:[-82,-1] images:#((bitmap 20 12 color:black), (bitmap 24 12 color:black), 1, 1, 1, 1, 1) tooltip:"Black"
	button colwhite "" width:24 height:16 offset:[-54,-21] images:#((bitmap 20 12 color:white), (bitmap 24 12 color:black), 1, 1, 1, 1, 1) tooltip:"White"
	button palettebut "Palette" width:52 height:20 offset:[-68,-1] images:#((openbitmap (VCanvas.brushDir + "PaletteButton.bmp")), (bitmap 52 20 color:black), 1, 1, 1, 1, 1) tooltip:"Open Color Palette"
		
	spinner bsize "Radius: " range:[1,1000,(VCGetSetting 1)] type:#integer fieldwidth:36 align:#right offset:[3,-70]
	spinner opacspin "Opacity: " range:[0,100,(VCGetSetting 3)] type:#integer fieldwidth:36 align:#right offset:[3,0]
	spinner hardness "Hardness: " range:[0,100,(VCGetSetting 19)] type:#integer fieldwidth:36 align:#right offset:[3,0]
	spinner spacespin "Spacing: " range:[0.05,20.0,(VCGetSetting 25)] type:#float scale:0.01 fieldwidth:36 align:#right offset:[3,0]
	spinner scatterspin "Scatter: " range:[0,500,(VCGetSetting 26)] type:#integer fieldwidth:36 align:#right offset:[3,0]
	spinner blurradius "Blur/Sharpen: " range:[1,50,(VCGetSetting 12)] type:#integer fieldwidth:36 align:#right offset:[3,0]
	
	button view2Dbut "2D View" width:72 height:22 align:#left offset:[-9,-45] enabled:false tooltip:"Toggle 2D View"
	button layerdiagbut "Layers Dialog" width:72 height:22 align:#left offset:[-9,0] enabled:false tooltip:"Toggle Layers Dialog"
	
	groupbox colbox "Color" width:72 height:92 pos:[4,108]
	groupbox brushbox "Brush Settings" width:134 height:147 pos:[82,108]
	
	fn ResetButtons =
	(
		buttonarr = #(toolPaint,toolClone,toolBlur,toolSharpen,toolContrast,toolDodge,toolBurn,toolFill,toolSmudge,toolErase,toolMove,toolScale,toolRotate,toolGradient)
		for i = 1 to buttonarr.count do
		(
			buttonarr[i].state = false
			VCanvas.buttonStates[i] = false
		)
		opacspin.value = VCGetSetting 3
		bsize.enabled = true
		opacspin.enabled = true
		hardness.enabled = true
		spacespin.enabled = true
		scatterspin.enabled = true
		blurradius.enabled = true
		view2Dbut.enabled = false
		layerdiagbut.enabled = false
	)
	
	on bsize entered do VCSetSetting 1 bsize.value
	on opacspin entered do
	(
		if VCanvas.currentTool == 10 then VCSetSetting 10 opacspin.value --set eraser opacity
		else VCSetSetting 3 opacspin.value
	)
	on hardness entered do VCSetSetting 19 hardness.value
	on spacespin entered do VCSetSetting 25 spacespin.value
	on scatterspin entered do VCSetSetting 26 scatterspin.value
	on blurradius entered do VCSetSetting 12 blurradius.value
	on toolPaint changed state do
	(
		if state then VCanvas.StartPaintTool 1
		else VCanvas.EndPaintTool()
	)
	on toolClone changed state do
	(
		if state then VCanvas.StartPaintTool 2
		else VCanvas.EndPaintTool()
	)
	on toolBlur changed state do
	(
		if state then VCanvas.StartPaintTool 3
		else VCanvas.EndPaintTool()
	)
	on toolSharpen changed state do
	(
		if state then VCanvas.StartPaintTool 4
		else VCanvas.EndPaintTool()
	)
	on toolContrast changed state do
	(
		if state then VCanvas.StartPaintTool 5
		else VCanvas.EndPaintTool()
	)
	on toolDodge changed state do
	(
		if state then VCanvas.StartPaintTool 6
		else VCanvas.EndPaintTool()
	)
	on toolBurn changed state do
	(
		if state then VCanvas.StartPaintTool 7
		else VCanvas.EndPaintTool()
	)
	on toolFill changed state do
	(
		if state then VCanvas.StartPaintTool 8
		else VCanvas.EndPaintTool()
	)
	on toolSmudge changed state do
	(
		if state then VCanvas.StartPaintTool 9
		else VCanvas.EndPaintTool()
	)
	on toolErase changed state do
	(
		if state then VCanvas.StartPaintTool 10
		else VCanvas.EndPaintTool()
	)
	on toolMove changed state do
	(
		if state then VCanvas.StartPaintTool 11
		else VCanvas.EndPaintTool()
	)
	on toolScale changed state do
	(
		if state then VCanvas.StartPaintTool 12
		else VCanvas.EndPaintTool()
	)
	on toolRotate changed state do
	(
		if state then VCanvas.StartPaintTool 13
		else VCanvas.EndPaintTool()
	)
	on toolGradient changed state do
	(
		if state then VCanvas.StartPaintTool 14
		else VCanvas.EndPaintTool()
	)
	on colpick changed col do VCSetSetting 2 (Point3 col.r col.g col.b)
	on colblack pressed do
	(
		colpick.color = (color 0 0 0)
		VCSetSetting 2 (Point3 0 0 0)
	)
	on colwhite pressed do
	(
		colpick.color = (color 255 255 255)
		VCSetSetting 2 (Point3 255 255 255)
	)
	on palettebut pressed do VCanvas.OpenColorPalette()
	on layerdiagbut pressed do
	(
		if (VCGetLayerSetting 9 0) then VCLayers.CloseLayerDialog()
		else if (VCGetSetting 100) do VCLayers.OpenLayerDialog()
	)
	on view2Dbut pressed do
	(
		if VCanvas.isView2DOpen then destroyDialog VCview2D
		else if (VCGetSetting 100) do VCanvas.Open2DView()
	)
	on VCPaintRoll open do
	(
		--Assign tool button images
		backColor = colorman.getcolor #background
		buttonImageAlpha = bitmap 1064 30
		buttonImage = bitmap 1064 30 color:([255,255,255] * (colorman.getcolor #background))
		colSum = (backColor.x + backColor.y + backColor.z) / 3
		useDark = false
		if (colSum < 0.5) then
		(
			useDark = true
			filename = (VCanvas.brushDir + "ToolButtonsDark.bmp")
		)
		else filename = (VCanvas.brushDir + "ToolButtonsLight.bmp")
		VCCreateToolButtonImage buttonImage filename useDark backColor
		toolPaint.images = #(buttonImage, buttonImageAlpha, 28, 1, 15, 1, 15)
		toolErase.images = #(buttonImage, buttonImageAlpha, 28, 2, 16, 2, 16)
		toolClone.images = #(buttonImage, buttonImageAlpha, 28, 3, 17, 3, 17)
		toolFill.images = #(buttonImage, buttonImageAlpha, 28, 4, 18, 4, 18)
		toolGradient.images = #(buttonImage, buttonImageAlpha, 28, 5, 19, 5, 19)
		toolBlur.images = #(buttonImage, buttonImageAlpha, 28, 6, 20, 6, 20)
		toolSharpen.images = #(buttonImage, buttonImageAlpha, 28, 7, 21, 7, 21)
		toolContrast.images = #(buttonImage, buttonImageAlpha, 28, 8, 22, 8, 22)
		toolDodge.images = #(buttonImage, buttonImageAlpha, 28, 9, 23, 9, 23)
		toolBurn.images = #(buttonImage, buttonImageAlpha, 28, 10, 24, 10, 24)
		toolSmudge.images = #(buttonImage, buttonImageAlpha, 28, 11, 25, 11, 25)
		toolMove.images = #(buttonImage, buttonImageAlpha, 28, 12, 26, 12, 26)
		toolScale.images = #(buttonImage, buttonImageAlpha, 28, 13, 27, 13, 27)
		toolRotate.images = #(buttonImage, buttonImageAlpha, 28, 14, 28, 14, 28)
		
		if (VCGetsetting 100) do --paint is active, can happen if user closes and reopens dialog or settings are loaded
		(
			buttonarr = #(toolPaint,toolClone,toolBlur,toolSharpen,toolContrast,toolDodge,toolBurn,toolFill,toolSmudge,toolErase,toolMove,toolScale,toolRotate,toolGradient)
			buttonarr[VCanvas.currentTool].state = true
			
			if VCanvas.currentTool == 10 then opacspin.value = VCGetSetting 10
			else opacspin.value = VCGetSetting 3
			if VCanvas.currentTool == 3 or VCanvas.currentTool == 4 then blurradius.enabled = true
			else blurradius.enabled = false
			if VCanvas.currentTool == 8 then --Fill tool does not use these spinners
			(
				bsize.enabled = false
				hardness.enabled = false
				spacespin.enabled = false
				scatterspin.enabled = false
			)
			else if VCanvas.currentTool == 11 then
			(
				bsize.enabled = false
				opacspin.enabled = false
				hardness.enabled = false
				spacespin.enabled = false
				scatterspin.enabled = false
			)
			else
			(
				bsize.enabled = true
				hardness.enabled = true
				spacespin.enabled = true
				scatterspin.enabled = true
			)
		)
		PolyBoost.ViewportCanvasOpen = true
	)
	on VCPaintRoll close do
	(
		VCanvas.dialogDockingState = #cui_floatable
		VCanvas.dialogPos = VCMainFloater.pos
		VCanvas.dialogHeight = VCMainFloater.size.y
		VCanvas.rolloutStates = #(not VCBrushImageRoll.open,not VCBrushImageSettingsRoll.open,not VCOptionsRoll.open,not VCBehaveRoll.open,not VCRandomizeRoll.open,not VCPressureRoll.open,true)
		PolyBoost.ViewportCanvasOpen = false
		if VCanvas.colorPaletteOpen do destroyDialog ColorPaletteRollout
	)
)

struct VCMapSlotStruct
(
	slotName = "",
	menuName = "",
	hasTexture = false,
	fileName = "",
	mapSlotArrayIndex = 0,
	slotIndex = 0,
	numSubMaterials = 0,
	numSubSlots = 0,
	subSlots = #()
)
struct ViewportCanvasSetupStruct
(
itemCounter,
menuString,
eventString,
createTextureIndices = [0,0],
currentMapSlotIndex = 1,
mapSlotArray = #(),
fn CreateNewTexture width height filename  colorval show mapchannel =
(
	if mapSlotArray.count != 0 then
	(
		btex = BitmapTexture()
		map = bitmap width height color:colorval
		try(
		map.filename = filename
		save map
		close map
		btex.bitmap = openbitmap filename
		)catch(return false)
		setSubTexmap mapSlotArray[createTextureIndices.x] createTextureIndices.y btex
		mapSlot = getSubTexmap mapSlotArray[createTextureIndices.x] createTextureIndices.y
		mapSlot.coords.mapchannel = mapchannel
		VCanvas.usedMapSlot = mapSlot
		if show do
		(
			showTextureMap $.material btex true
		)
		VCanvas.currentTextureFile = filename
		true
	)
	else false
),
fn VCCreateTextureDialog =
(
	if mapSlotArray.count != 0 do
	(
		rolltext = "Create Texture: " + VCanvas.mapSlotName
		rollout VDsetuproll rolltext
		(
			local hasPickedSaveFile = false
			spinner widthspin "Width: " range:[1,10000,512] type:#integer fieldwidth:42 offset:[-152,4]
			spinner heightspin "Height: " range:[1,10000,512] type:#integer fieldwidth:42 offset:[-152,0]
			label setlab4 "Preset Sizes:" offset:[66,-50]
			button presetbut1 "256" width:48 height:18 offset:[40,0] tooltip: "256"
			button presetbut2 "512" width:48 height:18 offset:[94,-23] tooltip: "512"
			button presetbut3 "1024" width:48 height:18 offset:[40,0] tooltip: "1024"
			button presetbut4 "2048" width:48 height:18 offset:[94,-23] tooltip: "2048"
			colorpicker setcol "Color:" offset:[29,-10] modal:false color:(color 127 127 127) title:"Texture color"
			group "Save New Texture To:"
			(
				edittext setedtex "" text:"" width:220
				button setsave "..." offset:[114,-24]
			)
			checkbox showcheck "Show Map In Viewport" checked:true
			spinner mapch "Map Channel: " range:[1,99,1] type:#integer fieldwidth:36 align:#left
			button okbut "OK" width:48 height:20 align:#right offset:[-54,10] tooltip: "Create Texture"
			button cancelbut "Cancel" width:48 height:20 align:#right offset:[0,-25] tooltip: "Cancel"
			
			on presetbut1 pressed do (widthspin.value = 256 ; heightspin.value = 256)
			on presetbut2 pressed do (widthspin.value = 512 ; heightspin.value = 512)
			on presetbut3 pressed do (widthspin.value = 1024 ; heightspin.value = 1024)
			on presetbut4 pressed do (widthspin.value = 2048 ; heightspin.value = 2048)
			on setedtex changed txt do hasPickedSaveFile = false
			on setsave pressed do
			(
				filename = getBitmapSaveFileName caption:"Save Texture to:" filename:""
				if filename != undefined and filename != "" do
				(
					setedtex.text = filename
					hasPickedSaveFile = true
				)
			)
			on cancelbut pressed do destroyDialog VDsetuproll
			on okbut pressed do
			(
				filetext = setedtex.text
				if filetext != "" then
				(
					if (getFilenameFile filetext) != "" and ((getFilenamePath filetext) != "") and ((getFilenameType filetext) != "") then
					(
						result = true
						if (not hasPickedSaveFile) do
						(
							filepath = getFilenamePath filetext
							if (not doesFileExist filepath) do
							(
								if (queryBox "The directory does not exist. Do you want to create it?" title:"Directory Does Not Exist") then
								(
									result = makeDir filepath
									if not result do messagebox "Invalid Path" title:"Viewport Canvas"
								)
								else result = false
							)
							if result and (doesFileExist filetext) do
							(
								boxtext = "Confirm Overwriting " + filetext
								if not (queryBox boxtext title:"File Exists") do result = false
							)
						)
						if result do
						(
							result = VCSetup.CreateNewTexture widthspin.value heightspin.value filetext setcol.color showcheck.state mapch.value
							if result then
							(
								destroyDialog VDsetuproll
								if VCanvas.doRestartTool do VCanvas.StartPaintTool VCanvas.currentTool
							)
							else messagebox "Not a valid filename" title:"Viewport Canvas"
						)
					)
					else messagebox "Not a valid filename" title:"Viewport Canvas"
				)
				else messagebox "Choose a filepath for the texturefile" title:"Viewport Canvas"
			)
		)
		createDialog VDsetuproll 280 210 style:#(#style_titlebar, #style_border, #style_sysmenu) modal:true
	)
),
fn CollectMapSlots mat tree =
(
	if tree.numSubMaterials != 0 then
	(
		for i = 1 to tree.numSubMaterials do
		(
			matrial = getSubMtl mat i
			-- << CHD
			if (classOf matrial == GL_Effect) or (classOf matrial == GL_Effect_Inst) then
			(
				slot = VCMapSlotStruct()
				slot.slotName = matrial.name
				slot.menuName = "Material: " + slot.slotName
				slot.numSubMaterials = 0
				append tree.subSlots slot
				CollectMapSlots matrial slot
			)
			else
			-- CHD >>
			(
				slot = VCMapSlotStruct()
				slot.slotName = matrial.name
				slot.menuName = "Material: " + slot.slotName
				slot.numSubMaterials = getNumSubMtls matrial
				append tree.subSlots slot
				CollectMapSlots matrial slot
			)
		)
	)
	else
	(
		-- << CHD
		if (classOf mat == GL_Effect) or (classOf mat == GL_Effect_Inst) then
		(
			tree.numSubSlots = 0
			for i = 1 to mat.params.effectParamCount do
			(
				param = mat.params.GetEffectParam i
				if classOf param == GLParamSampler2D then
				(
					fname = param.texturePath
					slotName = param.name
					tree.numSubSlots += 1
					if (doesFileExist fname) then
					(
						slot = VCMapSlotStruct()
						tokens = filterString fname "\\"
						filename = ""
						if (fname[1] == "\\") and (fname[2] == "\\") do (filename += "\\\\\\\\") --using network path
						for i = 1 to (tokens.count) do
						(
							filename += tokens[i]
							if i < tokens.count do filename += "\\\\"
						)				
					
						slot.mapSlotArrayIndex = currentMapSlotIndex
						currentMapSlotIndex += 1
						slot.slotIndex = tree.numSubSlots
						append mapSlotArray mat
					
						slot.fileName = filename
						slot.slotName = slotName
						slot.menuName = slotName + ": " + filename
						slot.hasTexture = true	
						slot.numSubMaterials = 0					
						append tree.subSlots slot
					)
					else
					(
						-- file not exists
						slot = VCMapSlotStruct()
						slot.slotName = slotName
						slot.menuName = slotName + ": " + "..."
						slot.mapSlotArrayIndex = currentMapSlotIndex
						currentMapSlotIndex += 1
						slot.slotIndex = tree.numSubSlots
						append mapSlotArray mat
						append tree.subSlots slot
					)
				)
			)
		)
		else
		-- CHD >>
		(
			tree.numSubSlots = getNumSubTexmaps mat
			if tree.numSubSlots != 0 do
			(
				for i = 1 to tree.numSubSlots do
				(
					tex = getSubTexmap mat i
					slotName = getSubTexmapSlotName mat i
					if tex != undefined then
					(
						numSubs = getNumSubTexmaps tex
						if numSubs != 0 then
						(
							slot = VCMapSlotStruct()
							slot.slotName = slotName
							slot.menuName = slotName + ": " + ((classof tex) as string) + " - " + tex.name
							slot.numSubSlots = numSubs
							append tree.subSlots slot
							CollectMapSlots tex slot
						)
						else if (classof tex == Bitmaptexture) do --slot has a texture
						(
							slot = VCMapSlotStruct()
							filenam = tex.filename
							if (doesFileExist filenam) then
							(
								tokens = filterString filenam "\\"
								filename = ""
								if (filenam[1] == "\\") and (filenam[2] == "\\") do (filename += "\\\\\\\\") --using network path
								for i = 1 to (tokens.count) do
								(
									filename += tokens[i]
									if i < tokens.count do filename += "\\\\"
								)
								slot.mapSlotArrayIndex = currentMapSlotIndex
								currentMapSlotIndex += 1
								slot.slotIndex = i
								append mapSlotArray mat
								slot.fileName = filename
								slot.slotName = slotName
								slot.menuName = slotName + ": " + tex.name + " - " + filename
								slot.hasTexture = true
								append tree.subSlots slot
							)
							else --the texture does not exist in the used path, enable creating a new texture for this slot
							(
								if slotName != "" do
								(
									slot = VCMapSlotStruct()
									slot.slotName = slotName
									slot.menuName = slotName + ": " + "..."
									slot.mapSlotArrayIndex = currentMapSlotIndex
									currentMapSlotIndex += 1
									slot.slotIndex = i
									append mapSlotArray mat
									append tree.subSlots slot
								)
							)
						)
					)
					else --slot is empty
					(
						if slotName != "" do
						(
							slot = VCMapSlotStruct()
							slot.slotName = slotName
							slot.menuName = slotName + ": " + "..."
							slot.mapSlotArrayIndex = currentMapSlotIndex
							currentMapSlotIndex += 1
							slot.slotIndex = i
							append mapSlotArray mat
							append tree.subSlots slot
						)
					)
				)
				tree.numSubSlots = tree.subSlots.count
			)
		)
	)
),
fn BuildMenuString tree =
(
	numSlots = 0
	if tree.numSubMaterials != 0 then numSlots = tree.numSubMaterials
	else if tree.numSubSlots != 0 do numSlots = tree.numSubSlots
	if numSlots != 0 then
	(
		for i = 1 to numSlots do
		(
			theSlot = tree.subSlots[i]
			if theSlot.subSlots.count != 0 then
			(
				menuString += "subMenu \"" + theSlot.menuName + "\" \n ( \n"
				BuildMenuString tree.subSlots[i]
				menuString += ")\n"
			)
			else BuildMenuString tree.subSlots[i]
		)
	)
	else
	(
		indexString = itemCounter as string
		menuString += "menuItem menu" + indexString + " \"" + tree.menuName + "\" checked:false\n"
		arrayIndex = tree.mapSlotArrayIndex as string
		slotIndex = tree.slotIndex as string
		-- << CHD
		paintOnMat = mapSlotArray[tree.mapSlotArrayIndex]
		if (classOf paintOnMat == GL_Effect) or (classOf paintOnMat == GL_Effect_Inst) then
		(
			if tree.fileName == "" then
			(
				-- todo
			)
			else
			(
				eventString += "on menu" + indexString + " picked do ( \n"
				eventString += "   VCanvas.currentTextureFile = \"" + tree.fileName + "\"\n"
				eventString += "   VCOptionsRoll.mapbut.text = \"" +  tree.slotName + "\"\n"
				eventString += "   VCanvas.mapSlotName = \"" + tree.slotName + "\"\n"
				eventString += "   VCanvas.currentMaterial = $.material\n"
				eventString += "   VCanvas.usedMapSlot = Bitmaptexture filename:\""+tree.fileName+"\"\n"
				eventString += "   VCanvas.GL_isGlitchEffect = true\n"
				eventString += "   VCanvas.GL_mapSlotIndex = " + arrayIndex + "\n"
				eventString += "   VCanvas.GL_paramName = \"" + tree.slotName + "\"\n"
				eventString += "   if VCanvas.doRestartTool do VCanvas.StartPaintTool VCanvas.currentTool \n"
				eventString += ")\n"
			)
		)
		else
		(
		-- CHD >>
			if tree.fileName == "" then
			(
				eventString += "on menu" + indexString + " picked do ( \n
				VCSetup.createTextureIndices = [" + arrayIndex + "," + slotIndex + "] \n
				VCanvas.currentMaterial = $.material \n
				VCanvas.mapSlotName = getSubTexmapSlotName VCSetup.mapSlotArray[" + arrayIndex + "] " + slotIndex + " \n
				VCOptionsRoll.mapbut.text = VCanvas.mapSlotName \n
				VCSetup.VCCreateTextureDialog() \n
				) \n"
			)
			else
			(
				slotname = ""
				eventString += "on menu" + indexString + " picked do ( \n
				VCanvas.currentTextureFile = \"" + tree.fileName + "\" \n
				VCOptionsRoll.mapbut.text = \"" +  tree.slotName + "\"\n
				VCanvas.mapSlotName = \"" + tree.slotName + "\"\n
				VCanvas.currentMaterial = $.material \n
				VCanvas.usedMapSlot = getSubTexmap VCSetup.mapSlotArray[" + arrayIndex + "] " + slotIndex + " \n
				if VCanvas.doRestartTool do VCanvas.StartPaintTool VCanvas.currentTool \n
				) \n"
			)
		)
		itemCounter += 1
	)
),
fn BuildMapMenu mat =
(
	--Fill map slot tree
	mapSlotArray = #()
	currentMapSlotIndex = 1
	VCMapSlotTree = undefined
	VCMapSlotTree = VCMapSlotStruct()
	VCMapSlotTree.slotName = mat.name
	VCMapSlotTree.menuName = "Material: " + mat.name
	-- << CHD
	if classOf mat == GL_Effect or classOf mat == GL_Effect_Inst then
	(
		VCMapSlotTree.numSubMaterials = 0
	)
	else
	-- CHD >>
	(
		VCMapSlotTree.numSubMaterials = getNumSubMtls mat
	)
	CollectMapSlots mat VCMapSlotTree
	
	--Build menu
	itemCounter = 1
	menuString = "rcmenu VCMapMenu \n ( \n"
	eventString = ""
	BuildMenuString VCMapSlotTree
	menuString += eventString
	menuString += ")"
	execute menuString
	popUpMenu VCMapMenu
)
) --end ViewportCanvasSetupStruct

VCanvas = ViewportCanvasStruct()

VCanvas.hasLoadedDefaultSettings = false
--Load default settings
if not VCanvas.hasLoadedDefaultSettings do
(
	settingsFileName = VCanvas.brushDir + "Settings\\Default.txt"
	if (doesFileExist settingsFileName) do
	(
		settings = execute (getINISetting settingsFileName "InterfaceSettings" "ToolSettings")
		numsettings = settings.count
		for i = 1 to numsettings do
		(
			VCSetSetting i settings[i]
		)
		VCanvas.rolloutStates = execute (getINISetting settingsFileName "InterfaceSettings" "RolloutStates")
		VCanvas.dialogPos = execute (getINISetting settingsFileName "InterfaceSettings" "DialogPos")
		VCanvas.dialogHeight = execute (getINISetting settingsFileName "InterfaceSettings" "DialogHeight")
		VCanvas.view2DPos = execute (getINISetting settingsFileName "InterfaceSettings" "View2DPos")
		VCLayers.LayerDialogPos = execute (getINISetting settingsFileName "InterfaceSettings" "LayerDialogPos")
		VCanvas.dialogDockingState = (getINISetting settingsFileName "InterfaceSettings" "DockingState") as name
		VCLayers.LayerDialogDockState = (getINISetting settingsFileName "InterfaceSettings" "LayerDialogDockingState") as name
		VCanvas.wasView2DLeftOpen = execute (getINISetting settingsFileName "InterfaceSettings" "View2DOpen")
		VCLayers.LayerDialogLeftOpen = execute (getINISetting settingsFileName "InterfaceSettings" "LayerDialogOpen")
		VCanvas.hasLoadedDefaultSettings = true
	)
	--Collect brush file names
	for i = 1 to 18 do
	(
		if i < 10 then append VCanvas.brushImageFileNames (VCanvas.brushDir + VCanvas.brushfiles[i])
		else append VCanvas.brushImageFileNames (VCanvas.brushDir + VCanvas.maskfiles[i - 9])
	)
)

VCSetup = ViewportCanvasSetupStruct()
) --All Viewport Canvas struct defined, if this has been done before only the code for opening the dialog is run

VCMainFloater = newRolloutFloater "Viewport Canvas" 230 VCanvas.dialogHeight VCanvas.dialogPos.x VCanvas.dialogPos.y
addRollout VCPaintRoll VCMainFloater rolledUp:false border:false
addRollout VCBrushImageRoll VCMainFloater rolledUp:VCanvas.rolloutStates[1] border:true
addRollout VCBrushImageSettingsRoll VCMainFloater rolledUp:VCanvas.rolloutStates[2]  border:true
addRollout VCOptionsRoll VCMainFloater rolledUp:VCanvas.rolloutStates[3]  border:true
addRollout VCBehaveRoll VCMainFloater rolledUp:VCanvas.rolloutStates[4]  border:true
addRollout VCRandomizeRoll VCMainFloater rolledUp:VCanvas.rolloutStates[5]  border:true
addRollout VCPressureRoll VCMainFloater rolledUp:VCanvas.rolloutStates[6]  border:true
addRollout VCSettingsRoll VCMainFloater rolledUp:VCanvas.rolloutStates[7]  border:true
cui.RegisterDialogBar VCMainFloater style:#(#cui_floatable, #cui_dock_vert) minSize:[236,100] maxSize:[236,1600]
if (VCanvas.dialogDockingState != #cui_floatable) do
(
	cui.DockDialogBar VCMainFloater VCanvas.dialogDockingState
)

)