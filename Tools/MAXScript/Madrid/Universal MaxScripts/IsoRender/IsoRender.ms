-- Iso Render
-- By Gwen Heliou - gwenael.heliou@gameloft.com

/*
re = maxOps.GetCurRenderElementMgr() 
re.NumRenderElements()
re.GetRenderElementFilename 1
re.SetRenderElementFilename 1 ""


"M:\Tools\MA2_maxscripts\assets\MA2_MZ_Rendermonkey01.max"

*/


global MaxToLoad
global RenderRig = pathConfig.removePathLeaf(getSourceFileName()) + "\\assets\\MA2_MZ_Rendermonkey01.max" --made path relative. Edited by Norman Schaar norman.schaar@gameloft.com
global MA2_IsoRender_error = false
global MA2_TmpName = undefined
global MA2_ElementName = undefined


fn FindDummyName =
(
	Allstuff = $objects
	for i = 1 to Allstuff.count do 
	(
		if (classof Allstuff[i] == Dummy) then (MA2_TmpName = Allstuff[i].name) else ()
	)
	if (MA2_TmpName == undefined) then 
		(
			messagebox "No valid dummy named Dummy_xxxxxx in this file"
			MA2_IsoRender_error = true
			)
		else
			(
				MA2_ElementName = substring MA2_TmpName 7 50
			)
	)

	fn NameRenderElement =
(
	elementlist = #(VRayGlobalIllumination, VRayLighting, VRayMatteShadow, VRayRawGlobalIllumination, VRayShadows, VRayTotalLighting, VRayDiffuseFilter, VRayMtlID)
	re = maxOps.GetCurRenderElementMgr() 
	re.removeallrenderelements()
	re.numrenderelements()
	theManager = maxOps.GetRenderElementMgr #Production
	theManager.numrenderelements()
	rendoutputfilename = "c:\\temp\\" + MA2_ElementName + ".tga"
	for n in elementlist do
	(
	re.addrenderelement (n elementname:(MA2_ElementName + "_" + (n as string)))
	format "\nAdded % renderelement" n
	)
	rendsavefile = true

	setsilentmode true
	saveMaxFile ("c:\\temp\\" + "IsoRender_" + MA2_ElementName + ".max") quiet:true
	renderSceneDialog.open()

	for n = 0 to (theManager.numrenderelements()- 1) do
	(
	el = re.getrenderelement n
	format "\nGetting % render element" el.elementname
	format "\nRender element outputfilename: %" (re.GetRenderElementFileName n)
	)
)
	
rollout MA2_IsoRender "Iso renderer"
(
	button btn1 "Do it" pos:[19,152] width:119 height:58
	label lbl1 "WARNING. \r \n- Save your job first \n- All changes will be lost\r \n- Pick the Dummy and the objects to render" pos:[18,19] width:127 height:117

	on btn1 pressed do
	(
		resetMaxFile #noPrompt 
		MaxToLoad = getOpenFileName caption:"Open the Maxfile:"
		loadMaxFile RenderRig quiet:true
		mergemaxFile MaxToLoad #prompt #deleteOldDups #useMergedMtlDups 
		FindDummyName()
		NameRenderElement()
		)
	
	)

createDialog MA2_IsoRender 150 250
