fn UVOP uvcoors=
(	
	undo on
	(
		oSel = selection as array
		oCoors = uvcoors 
		for obj in oSel do 
		(
			select obj
			addModifier obj (Unwrap_UVW ()) 
			modPanel.setCurrentObject obj.modifiers[#Unwrap_UVW]
			uv = modPanel.getCurrentObject ()
			uv.setMapChannel uvcoors[3]
			subObjectLevel = 1
			uv.selectVertices #{1..500000}
			uv.moveX uvcoors[1]
			uv.moveY uvcoors[2]
			maxOps.CollapseNode $ off

		)
		select oSel
	)
)

try(destroyDialog AnimMainRollout )catch()

rollout AnimMainRollout "" width:160 height:350
(
	groupBox grpAnimParam "Animation Parameters" pos:[8,8] width:144 height:170
	label lblSpeed "Anim Speed" pos:[16,88] width:80 height:16
	label lblTimeOffset "Time Offset" pos:[16,152] width:80 height:16
	label lblPanning "Diff Speed" pos:[16,120] width:80 height:16
	dropDownList ddlAnimPattern "Pattern" pos:[16,32] width:128 height:16 items:#("Set Patterns!")
	spinner spSpeed "" pos:[80,88] width:64 height:16 range:[-50,50,1]
	spinner spOffset "" pos:[80,152] width:64 height:16 range:[0,100,0] 
	spinner spPanning "" pos:[80,120] width:64 height:16 range:[-50,50,0] 
	
	groupBox grpPttnInfo "Pattern Info" pos:[8,180] width:144 height:65
--	checkbox chkPatternDir "" pos:[112,236] width:16 height:16
--	label lblHorizontal "H-Tiling Pattern" pos:[24,236] width:80 height:16
--	dropDownList ddlDiffuseDirection "Diffuse Tiling" pos:[16,262] width:128 height:3 items:#("Vertical","Horizontal")
	label lblPtrnNum "# of Patterns" pos:[24,204] width:80 height:16
	spinner spNumPatterns "" pos:[94,204] width:40 height:16 range:[1,64,0] type:#integer
	
	
	button btnApply "Apply" pos:[16,256] width:128 height:32
--	button btnRefresh "Refresh" pos:[16,405] width:128 height:32
	button btnReset "Reset" pos:[16,296] width:128 height:32
	
	-- UV2 Coordinate Variables (Pattern and Offset)
	global uPtrn = 0 as float
	global uOffst = 0 as float
	
	-- UV3 Coordinate Variables (Speed U and Speed V)
	global uSpeedU = 0 as float
	global uSpeedV = 0 as float
	
	global ptIncrement = 1  as float
	global ptIncHalf = 0.5  as float
	
	-- UV3 Coordinate Variables (Speed U and Speed V)
	global dSpeedU = 0 as float
	global dSpeedV = 0 as float
	
	local ulastspeedused = 0
	local ulastdiffusepan = 0
	local ptArray = #("Animation 1")
	
		
	on spNumPatterns changed true do
	(
		ddlAnimPattern.items = #()	
		ptArray = #("Animation 1")
		if spNumPatterns.value != 0 or spNumPatterns.value != 1 then
		(
			ptIncrement = (1.0 / spNumPatterns.value)
			ptIncHalf = (ptIncrement / 2.0)
		) else (
			spNumPatterns.value = 1
			ptIncrement = (1.0 / spNumPatterns.value)
			ptIncHalf = (ptIncrement / 2.0)
		)
		ptcount = spNumPatterns.value
		
		while ptcount > 0 do
		(
			ptArray[ptcount] = ("Animation " + (ptcount as string))
			ptcount -= 1		
		)
			
		ddlAnimPattern.items = ptArray	
	)
	
	on btnApply pressed do
	(	
		if ddlAnimPattern.items[1] == "Set Patterns!" then
		(
			MessageBox "Set # of Patterns"
		) else
		(
		if ddlAnimPattern.selection != undefined then
		(
			uPtrn = (((ptIncrement * ddlAnimPattern.selection) + ptIncHalf) - ptIncrement)
			uOffst = ((spOffset.value) / 100) as float
		)
			setObjValues = selection as array
			isValidArray = true
		for obj in setObjValues do
		(
			if Classof obj != Editable_Poly  then 
			(
				MessageBox "Objects must be Editable Poly!"
				isValidArray = false
			)
		)
		
		if setObjValues[1] != undefined and isValidArray == true then
		(
			uChannel = 2
			uvcoors = [ uOffst, uPtrn, uChannel]
			UVOP (uvcoors)
		
		if spSpeed.value != ulastspeedused or spPanning.value != ulastdiffusepan then
		(
			ulastspeedused = spSpeed.value
			ulastdiffusepan = spPanning.value
				if spPanning.value == 0 then
				(
					uSpeedU = 0
				) else
				(
					uSpeedU = ( 1.0 / spPanning.value) as float
				)
				if spSpeed.value == 0 then
				(
					uSpeedV = 0
				) else
				(
					uSpeedV = ( 1.0  / spSpeed.value) as float
				)
				uChannel = 3
				uvcoors = [uSpeedV , uSpeedU , uChannel]
				UVOP (uvcoors)		
		)
		)	
		)
	)
	
	
	on btnReset pressed do
	(	
		if ddlAnimPattern.items[1] == "Set Patterns!" then
		(
			MessageBox "Set # of Patterns"
		) else
		(
		if ddlAnimPattern.selection != undefined then
		(
			ddlAnimPattern.selection = 1
			spOffset.value = 0
			uPtrn = (((ptIncrement * ddlAnimPattern.selection) + ptIncHalf) - ptIncrement)
			uOffst = 0
		)
			setObjValues = selection as array
			isValidArray = true
		for obj in setObjValues do
		(
			if Classof obj != Editable_Poly  then 
			(
				MessageBox "Objects must be Editable Poly!"
				isValidArray = false
			)
		)
		
		if setObjValues[1] != undefined and isValidArray == true then
		(
				uChannel = 2
				uvcoors = [uOffst , uPtrn, uChannel]
				UVOP (uvcoors)
		
		
			
				spSpeed.value = 1
				uSpeedU = 1
				uSpeedV = 0
				uChannel = 3
				uvcoors = [uSpeedU , uSpeedV, uChannel]
				UVOP (uvcoors)
		)	
		)
	)
	
)



createDialog AnimMainRollout style:#(#style_sysmenu,#style_titlebar,#style_minimizebox,#style_resizing)