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

fn sendText hwnd text_string =
(
	windows.SendMessage hwnd (EM_SETSEL = 0x00B1) 0 1000
	WindowsSendTextOps.SendMessage hwnd (EM_REPLACESEL = 0xC2) 0 (text_string as string)
	windows.sendMessage hwnd (WM_CHAR=0x0102) (VK_RETURN=0x000D) (lparam = 0x00000000)
)

fn addPositionConstraint obj constrainTo keepOffset:false replaceList:false =
(
 	local pc = Position_Constraint ()
 	-- if the position controller is a Position List then add the pc to the available slot
 	if classOf obj.position.controller == Position_List and replaceList == false then (
 		obj.position.controller.available.controller = pc
 		-- get the number of the pc controller
 		local numCon = obj.position.controller.getCount()
 		-- set the controller's name
 		obj.position.controller.setName numCon "posCon"
 		obj.position.controller.setActive numCon
 		)
 	-- replace position controller if it's not a Position List
 	if classOf obj.position.controller != Position_List or replaceList == true then (
 		obj.position.controller = pc
 		)
 	-- set the attributes of the controller
 	if classOf constrainTo != array then (pc.appendTarget constrainTo 100)
 	if classOf constrainTo == array then (
 		local n = constrainTo.count
 		for i = 1 to n do (
 			pc.appendTarget constrainTo[i] (100 / n)
 			)
 		)
 	pc.relative = keepOffset
 	-- return the position constraint controller
 	pc
)

fn addOrientationConstraint obj constrainTo keepOffset:false replaceList:false =
(
 	local oc = Orientation_Constraint ()
 	-- add the oc to the available slot of the rotation list controller
 	if classOf obj.rotation.controller == Rotation_List and replaceList == false then (
 		obj.rotation.controller.available.controller = oc
 		-- get the number of the pc controller
 		local numCon = obj.rotation.controller.getCount()
 		-- set the controller's name
 		obj.rotation.controller.setName numCon "orientCon"
 		obj.rotation.controller.setActive numCon
 		)
 	-- replace rotation controller
 	if classOf obj.rotation.controller != Rotation_List or replaceList == true then (
 		obj.rotation.controller = oc
 		)
 	-- set the attributes of the controller
 	oc.appendTarget constrainTo 100
 	oc.relative = keepOffset
 	-- return the orientation constraint controller
 	oc
)

fn collapseTrajectories theMesh =
(
	local p = Point()
	for i = animationRange.start to animationRange.end do
	(
		at time i
		with animate on p.transform = theMesh.transform
	)

	theMesh.transform.controller = transform_script()	
	theMesh.transform.controller = prs()	
	theMesh.parent = undefined

	for i = animationRange.start to animationRange.end do
	(
		at time i
		with animate on	theMesh.transform = p.transform
	)
	delete p
)

fn find_TrajectoriesPanel =
(
	for n in (windows.getChildrenHWND #max) where n[4] == "RollupPanel" do
	(
		for m in (windows.getChildrenHWND n[1]) do
		(
			if m[4] == "RollupPanelTitle" AND m[5] == "Trajectories" do
			(
				return n[1]
			)
		)
	)
)

--Function that will find a node in the layers
fn findthenode theNode =
(
	for i=0 to (LayerManager.count - 1) do
	(
		(LayerManager.getLayer i).nodes &thenodes
		for n in thenodes do
		(
			if n == theNode do
			(
				return i
			)
		)
	)
)

fn fn_IrrColladaExporter_AUTO =
(
	local hWND = DialogMonitorOPS.GetWindowHandle()
	if ((UIAccessor.GetWindowText hWND) == "ColladaMax Export") do
	(
		UIAccessor.PressButtonByName hWND "..."
		UIAccessor.PressButtonByName hWND "OK"
	)
	if ((UIAccessor.GetWindowText hWND) == "Batch Export Option String") do
	(
		local theListboxes = for n in windows.getChildrenHwnd hWND where n[4] == "ListBox" collect n[1]
		windows.SendMessage theListboxes[1] (LB_SETCURSEL = 0x00000186) (wparam = 0x00000001) (lparam = 0x00000000)
		UIAccessor.PressButtonByName hWND "OK"
	)
	return true
)



try(destroyDialog DLG_Gladiator_Biped_Exporter)catch() --try to destroy it if it already exists as a dialog
rollout DLG_Gladiator_Biped_Exporter "Gladiator Exporter" --define the rollout 
(
	local PathChanges = false
	local CurrentSelectionSets = #()
	local CurrentRowIndex = undefined
	local CurrentSubItemIndex = undefined
	
	dotNetControl lv "System.Windows.Forms.ListView" width:500 height:200 pos:[0,0]
	
	edittext et_exportfile "Export File:" readonly:true align:#left pos:[10,210] width:440
	button btn_browseExport "Save" enabled:false	align:#left pos:[450,209]
		
	button btn_export "Prepare & Export" height:40 width:200
	checkbox cb_export "Export" checked:true

	
	local Position_dummy = #()
	local Position_dummy_inverted = #(false,false)
	
	fn fill_lv =
	(
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = true-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable
		lv.Columns.add "Selection Set" 150
		lv.Columns.add "Export Path" 350
		
		local theRange = #()
		
		for n in selectionsets do
		(
			append CurrentSelectionSets n
			local li = dotNetObject "System.Windows.Forms.ListViewItem"
			li.text = n.name
			li.UseItemStyleForSubItems=false
			
			local theIndex = fileProperties.findProperty #custom ("GOA_SELECTIONSET_" + n.name)
			if theIndex != 0 then
			(
				local thePath = fileProperties.getPropertyValue #custom theIndex
				li.SubItems.add thePath
			)
			else
			(
				li.SubItems.add ""
			)
			
			append theRange li
		)
		
		lv.Items.AddRange theRange

	)
	
	fn export_all =
	(
		local theColladaINI = (getDir #plugcfg) + "\\IrrColladaMax.ini"
		setInisetting theColladaINI "ColladaMax" "animations" "1"
		
		for n in selectionsets do
		(
			local theIndex = fileProperties.findProperty #custom ("GOA_SELECTIONSET_" + n.name)
			if theIndex != 0 then
			(
				local thePath = fileProperties.getPropertyValue #custom theIndex
				if thePath != "" do
				(
					select n

					DialogMonitorOPS.Enabled = true 
					DialogMonitorOPS.RegisterNotification fn_IrrColladaExporter_AUTO id:#IrrColladaExporter_AUTO_GLADIATORS
					DialogMonitorOPS.Interactive=false
					exportFile thePath selectedOnly:true using:IrrColladaExporter
					DialogMonitorOPS.unRegisterNotification id:#IrrColladaExporter_AUTO_GLADIATORS
					DialogMonitorOPS.Enabled = false
				)
			)
		)
	)
	
	fn prepare_for_export theBiped export_state =
	(
		local theLayer = findthenode theBiped
		local theNodes = #()
		(LayerManager.getLayer theLayer).nodes &thenodes	
		local theMovementDummy = for n in thenodes where n.name == "Movement_Dummy" do exit with n
		local thePositionDummy = for n in thenodes where n.name == "Position_Dummy" do exit with n
		local theFreeDummys = for n in thenodes where (matchpattern n.name pattern:"*_free_*") == true collect n
			
		local thePositionDummyIndex = for i=1 to Position_dummy.count where Position_dummy[i] == thePositionDummy do exit with i
		local isInverted = Position_dummy_inverted[thePositionDummyIndex]
		
		local ctrl = theBiped.transform.controller

	-- 	Here we bake down the keys for the legs
		local theTempBipedNodes
		maxOps.CloneNodes #(theBiped) expandHierarchy:true cloneType:#copy newNodes:&theTempBipedNodes

		select theTempBipedNodes

		local theTempBiped = for o in theTempBipedNodes where (classof o) == Biped_object AND (o.controller as string) == "Controller:Body" do exit with o
		local theTempThighs = for o in theTempBipedNodes where (classof o) == Biped_object AND (o.controller as string) == "Controller:L_Thigh" OR (o.controller as string) == "Controller:R_Thigh" collect o
		select theTempBiped
		local Tempctrl = theTempBiped.transform.controller
		biped.convertToFootSteps Tempctrl keyPerFrame:true flattenToZ:false 

		select theTempThighs
		
	-- 		We need to click on the Track button otherwise the track won't be copied. Stupid 3dsmax...
		setCommandPanelTaskMode #motion
		local theParametersButton = for n in (windows.getChildrenHWND #max) where n[4] == "CustButton" AND n[5] == "Parameters" do exit with n[1]
		windows.sendMessage theParametersButton (WM_LBUTTONDOWN = 0x0201) 0 0
		windows.sendMessage theParametersButton (WM_LBUTTONUP   = 0x0202) 0 0
		local theTrackButton = for n in (windows.getChildrenHWND #max) where n[5] == "Track" do exit with n[1]
		windows.sendMessage theTrackButton (WM_LBUTTONDOWN = 0x0201) 0 0
		windows.sendMessage theTrackButton (WM_LBUTTONUP   = 0x0202) 0 0
		
		
		local TheTrackName = biped.copyPosture Tempctrl #track true true true
		delete theTempBipedNodes
		select theBiped

		biped.pastePosture ctrl #track false TheTrackName 
		
	-- 	Baking finished, we start offsetting and baking as well


		ctrl.MoveAllMode = true
		
		--Offset Biped to 000
		for n in theFreeDummys do (n.parent = theBiped) --Link the free dummies so that they move with the biped
		biped.setTransform theBiped #pos [0,0,theBiped.transform.pos.z] true
		for n in theFreeDummys do (n.parent = undefined) --Unlink the dummies after the offset

		--Rotate Biped
		if isInverted == true do
		(
			thePositionDummy.parent = theBiped
			rotate theBiped (angleaxis 180.0 [0,0,1])
			thePositionDummy.parent = undefined
		)
		
		--Rotate free dumies
		if isInverted == true do
		(
			for o in theFreeDummys do
			(
				local theTempFreeDummy = copy o
				local theDummy = dummy()
				theDummy.pos = [0,0,0]
				theTempFreeDummy.parent = theDummy
				rotate theDummy (angleaxis 180.0 [0,0,1])
				
				select o
				addPositionConstraint o theTempFreeDummy keepOffset:false replaceList:false
				addOrientationConstraint o theTempFreeDummy keepOffset:false replaceList:false
				
				--Collapse dummy
				collapseTrajectories o
				
				delete theTempFreeDummy
				delete theDummy
			)
		)
		biped.CollapseMoveAllMode theBiped.Controller
		ctrl.MoveAllMode = false

		select theMovementDummy
		theMovementDummy.rotation.z_rotation = (quatToEuler2 theBiped.transform.rotation).z
		
			
		addPositionConstraint theMovementDummy theBiped keepOffset:true replaceList:false
		addOrientationConstraint theMovementDummy theBiped keepOffset:true replaceList:false
		
		
		--Collapse dummy
		collapseTrajectories theMovementDummy

		--We save the transform in the first frame before deleting the keyframes that are not needed
		local theTransformation = theMovementDummy.transform
		
		local thePosZ = theMovementDummy.position.controller.z_position
		local theRotX = theMovementDummy.rotation.controller.x_rotation
		local theRotY = theMovementDummy.rotation.controller.y_rotation
		
		deleteKeys theMovementDummy.position.controller.z_position.keys
		deleteKeys theMovementDummy.rotation.controller.x_rotation.keys
		deleteKeys theMovementDummy.rotation.controller.y_rotation.keys
		
		theMovementDummy.position.controller.z_position = thePosZ
		theMovementDummy.rotation.controller.x_rotation = theRotX
		theMovementDummy.rotation.controller.y_rotation = theRotY
		
		ctrl.inPlaceMode = true
		
		--Substracting movement of movement dummy from the free dummies since it will be added again ingame
		for o in theFreeDummys do
		(
			collapseTrajectories o
		)
		
		for i=animationrange.start to animationrange.end do
		(
			at time i
			(
				with animate on
				(
					for o in theFreeDummys do
					(
						o.pos.x -= theMovementDummy.pos.x
						o.pos.y -= theMovementDummy.pos.y
					)
				)
			)
		)
		slidertime = animationrange.start
	)
	
	fn prepare_for_export_cameras =
	(
		set animate off
		
		local theCameras = for o in cameras collect o
		
		for o in theCameras do
		(
			local theNameArray = filterstring o.name "_"
			if theNameArray[1] == "D" do
			(
				local theTempCamera = copy o				
				local theDummy = dummy()
				theDummy.pos = [0,0,0]
				theTempCamera.parent = theDummy
				rotate theDummy (angleaxis 180.0 [0,0,1])

				select o
				addPositionConstraint o theTempCamera keepOffset:false replaceList:false
				addOrientationConstraint o theTempCamera keepOffset:false replaceList:false
				
				collapseTrajectories o

				delete theTempCamera
				delete theDummy
			)
			
			o.name = "Camera001"
		)
	)
	

	
	on btn_export pressed do
	(
		if PathChanges == true do
		(
			local theQueryOutput = queryBox "WARNING: You have changed export paths. Do you wish to save before running the script?"
			if theQueryOutput == true do
			(
				saveMaxFile (maxfilepath + maxfilename )
			)
		)
		
		slidertime = animationrange.start
		set animate off
		
		--Delete edit-poly modifier o any other modfier that animators have put on top of bipeds
		for o in objects where (classof o.baseObject) == Biped_object AND (o.modifiers.count != 0) do
		(
			for i=1 to o.modifiers.count do
			(
				deletemodifier o 1
			)
		)
		
		Position_dummy = for n in objects where n.name == "Position_Dummy" collect n
		if Position_dummy[1].pos.y > Position_dummy[2].pos.y do (Position_dummy_inverted[1] = true)
		if Position_dummy[2].pos.y > Position_dummy[1].pos.y do (Position_dummy_inverted[2] = true)
		
		with redraw off
		(
			local theBipeds = for o in objects where (classof o) == Biped_object AND (o.controller as string) == "Controller:Body" collect o
			for n in theBipeds do
			(
				prepare_for_export n cb_export.state
			)
			prepare_for_export_cameras()
			
			if cb_export.state == true do
			(
				export_all()
			)
		)
	)
	
	on DLG_Gladiator_Biped_Exporter open do
	(
		fill_lv()
	)
	
	on lv MouseClick theClick do
	(
		local theItem = lv.GetItemAt theClick.x theClick.y
		local theRowIndex = theItem.Index + 1
		local theSubItem = (theItem.GetSubItemAt theClick.x theClick.y)
		local theSubItemIndex = theItem.subitems.indexof theSubItem --INDEX OF SELECTED SUB ITEM
		
		CurrentRowIndex = theRowIndex
		CurrentSubItemIndex = theSubItemIndex
		
		if theSubItemIndex == 1 then
		(
			btn_browseExport.enabled = true
			et_exportfile.readonly = false
			et_exportfile.text = lv.Items.Item[CurrentRowIndex - 1].SubItems.Item[1].text
		)
		else
		(
			btn_browseExport.enabled = false
			et_exportfile.readonly = true
		)
	)
	
	on et_exportfile changed arg do
	(
		lv.Items.Item[CurrentRowIndex - 1].SubItems.Item[1].text = arg
		local theName = lv.Items.Item[CurrentRowIndex - 1].text
		fileProperties.addProperty #custom ("GOA_SELECTIONSET_" + theName) arg
		PathChanges = true
	)
	
	on btn_browseExport pressed do
	(
		local theOutput = getSaveFileName caption:"Select File to Save" types:"IrrCOLLADA (*.DAE)|*.dae"  initialDir:"P:\\data\\gfx3D\\"
		if theOutput != undefined do
		(
			lv.Items.Item[CurrentRowIndex - 1].SubItems.Item[1].text = theOutput
			et_exportfile.text = theOutput
			local theName = lv.Items.Item[CurrentRowIndex - 1].text
			fileProperties.addProperty #custom ("GOA_SELECTIONSET_" + theName) theOutput
			PathChanges = true
		)
	)
	
	on DLG_Gladiator_Biped_Exporter resized theSize do
	(
		lv.width = theSize[1]
		DLG_Gladiator_Biped_Exporter.height = 200
	)
	
	on cb_export changed theState do
	(
		if theState == true then
		(
			btn_export.text = "Prepare & Export"
		)
		else
		(
			btn_export.text = "Prepare"
		)
	)
)
CreateDialog DLG_Gladiator_Biped_Exporter width:500 height:300 style:#(#style_resizing,#style_titlebar,#style_sysmenu)