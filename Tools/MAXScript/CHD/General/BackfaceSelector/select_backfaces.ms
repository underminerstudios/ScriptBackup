rollout MainDialog "Select back faces"
(
	group "Options"
	(
		radiobuttons bAxis labels:#("X Axis","Y Axis", "Z Axis", "Camera Forward") default:4
		spinner spAngleMin "Angle Min" range:[0, 90, 0]
		spinner spAngleMax "Angle Max" range:[0, 90, 75]
		
	)
	button bSelect "Select Faces" 

	fn getViewDirection =
	(
		local coordSysTM = Inverse(getViewTM())
		local viewDir = -coordSysTM.row3
		viewDir
	)

	fn getVectorsAngle v1 v2 = 
	(
		acos(dot (normalize v1) (normalize v2))
	)

	on bSelect pressed do
	(
		local Axis
		case bAxis.state of
		(
			1: Axis = [1, 0, 0]
			2: Axis = [0, 1, 0]
			3: Axis = [0, 0, 1]
			4: Axis = getViewDirection()
		)
		
		obj = $
		convertToPoly obj
		faceCount = polyOp.getNumFaces obj
		faceSelected = #{}
		for face = 1 to faceCount do
		(
			Norm = polyOp.getFaceNormal obj face
			theAngle = getVectorsAngle Axis Norm
			if theAngle >= spAngleMin.value and theAngle <= spAngleMax.value then
			(
				append faceSelected face
			)
		)
		
		polyOp.setFaceSelection obj faceSelected
	)

)
try(destroyDialog MainDialog)catch()
createDialog MainDialog style:#(#style_sysmenu,#style_toolwindow)
