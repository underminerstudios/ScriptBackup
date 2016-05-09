/*
Real Football 2013  - Batch Viewport Render
This script will render the viewport from the selected max files.
- Output will be a avi file, with the same name as the maxfile.It will be saved in a subfolder with the max file name.
- The default avi settings will be used. So make sure to change them before, if you want. The script won't force any avi settings.
- Two different cameras will be merged from the CAMERAS.max file
- If the max file name contains a "_pv_" the "PV" camera will be used, if not, the other one will be used instead.
- The material in slot 24 will be applied to all the objects in the scene.
- Check line 38 for the Grab Viewport options
*/
-- by Norman Schaar - norman.schaar@gameloft.com


fn f_ConfigureCallback= 
(
	hWND = DialogMonitorOPS.GetWindowHandle()
	if ((UIAccessor.GetWindowText hWND) == "Make Preview") then
	(
		theControls = windows.getChildrenHWND hwnd

		BM_SETCHECK = 241 -- checkbutton toggle message ID

		--Set checkbox states
		chck_geometry = for n in theControls where n[5]=="Geometry" do exit with n[1]
		chck_shapes = for n in theControls where n[5]=="Shapes" do exit with n[1]
		chck_lights = for n in theControls where n[5]=="Lights" do exit with n[1]
		chck_cameras = for n in theControls where n[5]=="Cameras" do exit with n[1]
		chck_helpers = for n in theControls where n[5]=="Helpers" do exit with n[1]
		chck_space_warps = for n in theControls where n[5]=="Space Warps" do exit with n[1]
		chck_particle_systems = for n in theControls where n[5]=="Particle Systems" do exit with n[1]
		chck_active_grid = for n in theControls where n[5]=="Active Grid" do exit with n[1]
		chck_safe_frames = for n in theControls where n[5]=="Safe Frames" do exit with n[1]
		chck_frame_numbers = for n in theControls where n[5]=="Frame Numbers" do exit with n[1]
		chck_background = for n in theControls where n[5]=="Background" do exit with n[1]
		chck_bone_objects = for n in theControls where n[5]=="Bone Objects" do exit with n[1]
		
		--The first digit means on or off
		UIAccessor.SendMessage chck_frame_numbers BM_SETCHECK 1 0
		UIAccessor.SendMessage chck_shapes BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_lights BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_cameras BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_helpers BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_space_warps BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_particle_systems BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_active_grid BM_SETCHECK 1 0
		UIAccessor.SendMessage chck_safe_frames BM_SETCHECK 0 0
		UIAccessor.SendMessage chck_frame_numbers BM_SETCHECK 1 0
		UIAccessor.SendMessage chck_background BM_SETCHECK 1 0
		UIAccessor.SendMessage chck_bone_objects BM_SETCHECK 0 0
		
		--Hit the Create button
		UIAccessor.PressButtonByName hWND "Create"
		
		completeRedraw()
	)
	return true
)

fn f_myMakePreview =
(
	DialogMonitorOPS.Enabled = true 
	DialogMonitorOPS.RegisterNotification f_ConfigureCallback id:#GL_MakePreview
	DialogMonitorOPS.Interactive=false
	max preview
	DialogMonitorOPS.unRegisterNotification id:#GL_MakePreview
	DialogMonitorOPS.Enabled = false
	
)


--user has to select the files
theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
theDialog.title = "Select MAX files" --set the title
theDialog.Multiselect = true --allow multiple files to be selected
theDialog.Filter = "3DSMAX files (*.max)|*.max" --specify the filter
theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
result = theDialog.showDialog() --display the dialog, get result into variable
test = result.ToString() --when closed, convert the result to string
result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
theFilenames = theDialog.fileNames --the selected filenames will be returned as an array


/*
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
--get all .ms files from the folder c:/temp 
--and all its subfolders:
theFilenames = getFilesRecursive "D:\\RF13\\" "*.max"

*/

for i=1 to theFilenames.count do
(
	print ((i as string) + "/" + (theFilenames.count as string))
	--Load Max file
	LoadMaxFile theFilenames[i] quiet:true
	
	--Set Render dimensions
	renderWidth = 960
	renderHeight = 720

	--Set wireframe on
	if viewport.GetShowEdgeFaces() == false do
	(
		actionMan.executeAction 0 "369"
	)

	
	--Set default material 24 to all objects in scene
	for obj in objects do
	(
		obj.material = meditMaterials[24]
	)

	--Merge Camera
	theMaxFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\CAMERAS.max"
	mergeMAXFile theMaxFile
	
	--Set active viewport to Camera
	viewport.setCamera $CAMERA
		
	--Variables
	theCamera = $CAMERA
	theBiped = $Bip01

	if theBiped != undefined AND theCamera != undefined do
	(
		--Save OFFSET
		theOffsetX = theCamera.transform.pos.x
		theOffsetY = theCamera.transform.pos.y
		
		disableSceneRedraw()
		animate on
		for i = animationrange.start to animationrange.end do
		(
			slidertime = i
			
			BIPEDX = theBiped.transform.pos.x
			BIPEDY = theBiped.transform.pos.y
			
			theCamera.pos.x = BIPEDX + theOffsetX
			theCamera.pos.y = BIPEDY + theOffsetY
			
			addnewkey (theCamera.pos.controller) slidertime
		)
		animate off
		slidertime = animationrange.start
		enableSceneRedraw()
	)

	f_myMakePreview()
	if doesFileExist (getDir #preview + "\\_scene.avi") do
	(
		deleteFile (maxfilepath + "\\" + (getFileNameFile maxfilename) + ".avi")
		renameFile (getDir #preview + "\\_scene.avi") (maxfilepath + "\\" + (getFileNameFile maxfilename) + ".avi")
	)
)

messagebox "Done!"