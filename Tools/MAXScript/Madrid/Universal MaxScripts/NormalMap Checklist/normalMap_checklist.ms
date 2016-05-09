

try(destroyDialog dlg_normalmap_checklist)catch()
rollout dlg_normalmap_checklist "Normal Map Checklist"
(
	label et_test "Gamma:" align:#left
	dotNetControl lbl_gamma "Windows.Forms.Label"
	
	label et_qualified "Qualified Normal:" align:#left
	dotNetControl lbl_qualifiednormal "Windows.Forms.Label"
	
	label et_trueColor "True Color:" align:#left
	dotNetControl lbl_trueColor "Windows.Forms.Label"
	
	button btn_fix "Fix All" width:120 height:30

	on dlg_normalmap_checklist open do
	(
		
		--Gamma Check
		local theGammaStatus = IDisplayGamma.colorCorrectionMode as string
		lbl_gamma.text = theGammaStatus
		if theGammaStatus == "none" then
		(
			lbl_gamma.backColor = (dotNetClass "System.Drawing.Color").fromArgb 0 255 0
		)
		else
		(
			lbl_gamma.backColor = (dotNetClass "System.Drawing.Color").fromArgb 255 0 0
		)
		
		--Qualified Normals check
		local theQualifiedNormalsState = getInisetting (getMAXIniFile()) "ViewportNormalMapping" "ViewportNormalMappingType"
		if theQualifiedNormalsState == "Qualified" then
		(
			lbl_qualifiednormal.text = "On"
			lbl_qualifiednormal.backColor = (dotNetClass "System.Drawing.Color").fromArgb 0 255 0
		)
		else
		(
			lbl_qualifiednormal.text = "Off"
			lbl_qualifiednormal.backColor = (dotNetClass "System.Drawing.Color").fromArgb 255 0 0
		)
		
		--TrueColor check
		if rendDitherTrue == true then
		(
			lbl_trueColor.text = "On"
			lbl_trueColor.backColor = (dotNetClass "System.Drawing.Color").fromArgb 255 0 0
		)
		else
		(
			lbl_trueColor.text = "Off"
			lbl_trueColor.backColor = (dotNetClass "System.Drawing.Color").fromArgb 0 255 0
		)
	)
	
	
	
	on btn_fix pressed do
	(
		--Gamma fix
		local theGammaStatus = IDisplayGamma.colorCorrectionMode as string
		if theGammaStatus != "none" do
		(
			IDisplayGamma.colorCorrectionMode = #none
			lbl_gamma.backColor = (dotNetClass "System.Drawing.Color").fromArgb 0 255 0
		)
		
		--Qualified Normals Fix
		local theQualifiedNormalsState = getInisetting (getMAXIniFile()) "ViewportNormalMapping" "ViewportNormalMappingType"
		if theQualifiedNormalsState != "Qualified" do
		(
			setINIsetting (getMAXINIFile()) "ViewportNormalMapping" "ViewportNormalMappingType" "Qualified"
			lbl_qualifiednormal.text = "On"
			lbl_qualifiednormal.backColor = (dotNetClass "System.Drawing.Color").fromArgb 0 255 0
		)
		
		--TrueColor fix
		rendDitherTrue = false
		lbl_trueColor.backColor = (dotNetClass "System.Drawing.Color").fromArgb 0 255 0
		
	)
)
createDialog dlg_normalmap_checklist