--====================================================================================================================--
-- 	ResetXForm for Export v0.0.3 
--====================================================================================================================--
-- 
-- Gabriel Coriiu (gabriel.coriiu@gameloft.com)
--
-- ResetXForm
-- same name check
-- bad faces check (surface ~= 0) - select them if any
-- bad lod name check
-- remove all map channels > 2 and all map channels (-2 to 99) if matchPattern obj.name "*_Collision"
--====================================================================================================================--

function isGoodObjName obj =
(
	local filteredString = #()
	
	if ( matchPattern obj.name pattern:"*_LODD" ) then return true
	if ( matchPattern obj.name pattern:"*_LOD??" ) then
	(
		local int i
		for i = 0 to 9 do
			if ( matchPattern obj.name pattern:( "*_LOD0"+(i as string)) ) then return true
		return false
	)
	
	filteredString = filterString obj.name "_"
	if ( (filteredString[filteredString.count]).count != 5 and matchPattern filteredString[filteredString.count] pattern:"*LOD*" ) then return false 
	return true
)

function ContainsBadFaces obj =
(
	local BadFaces = #()
		
	if ( classOf obj != Editable_Poly ) then convertToPoly obj
	BadFaces = ( for face = 1 to obj.numFaces where (polyop.getFaceArea obj face) <= 0.00007 collect face )
	if ( BadFaces.count > 0 ) then
	(
		obj.SetSelection #Face (BadFaces as bitarray)
		return true
	)
	return false
)

function IsNameUnique obj objArray =
(	
	for o in objArray where ( o != obj and o.name == obj.name ) do
	(
		return false
	)
	return true
)

function FoundSkinModifier obj =
(
	if ( superClassOf obj != GeometryClass ) then return false
	for M in obj.modifiers where 	ClassOf M == Skin or
											ClassOf M == Skin_Morph do return true
	return false
)

function ObjectsToBeExported =
(
	local Object obj
	local bIsMacrorecorderEnabled = false
	local mcrString = ""
	local mcrCommands = #()
	
	if ( (mcrString = (macrorecorder as string)) != "" ) then
	(
		bIsMacrorecorderEnabled = true
		mcrCommands = filterString mcrString "\n"
	)
	
	if ( matchPattern mcrCommands[mcrCommands.count] pattern:"*saveMaxFile*" ) then mcrCommands[mcrCommands.count] = mcrCommands[mcrCommands.count-1]

	if ( matchPattern mcrCommands[mcrCommands.count] pattern:"*actionMan.executeAction 0 \"40011\"*" and bIsMacrorecorderEnabled ) then
		return ( for obj in Geometry where ( (not obj.IsHidden) and (not obj.IsFrozen) ) collect obj ) -- export
	else if ( matchPattern mcrCommands[mcrCommands.count] pattern:"*actionMan.executeAction 0 \"40373\"*" and bIsMacrorecorderEnabled and selection.count > 0 ) then
		return selection -- export selected
	
	if ( selection.count != 0 ) then 
		return selection
	else
		return ( for obj in Geometry where ( (not obj.IsHidden) and (not obj.IsFrozen) ) collect obj )
)

function LaunchParametersDialog parametersStr =
(
	return ""
)

function Main parametersStr =
(	
	local sameNamesArray = #()
	local badFacesArray = #()
	local invalidNamesArray = #()
	
	local string MSG_sameNames = ""
	local string MSG_badFaces = ""
	local string MSG_invalidNames = ""
	
	clearListener()
	
	format "================= ResetXForm =================\n"
	
	for obj in ( OTBE = ObjectsToBeExported() ) where SuperClassOf obj == GeometryClass do
	(
		if (	classOf obj.modifiers[1] != BillboardSpacewarpModifier and
				not FoundSkinModifier obj and
				obj.parent == undefined ) then
				(
					if ( not matchPattern obj.name pattern:"*_!RX*" ) then
						ResetXForm obj
					convertToPoly obj
					
					if ( not IsNameUnique obj OTBE	and findItem sameNamesArray obj.name 	== 0 ) then (	join sameNamesArray 	#(obj.name); append MSG_sameNames 	("\n"+obj.name) )
					if ( ContainsBadFaces obj 			and findItem badFacesArray obj.name		== 0 ) then (	join badFacesArray 		#(obj.name); append MSG_badFaces 		("\n"+obj.name) )
					if ( not isGoodObjName obj 		and findItem invalidNamesArray obj.name == 0 ) then (	join invalidNamesArray 	#(obj.name); append MSG_invalidNames 	("\n"+obj.name) )
					
					format "ResetXForm: %\n" obj.name
				)
		
		convertToMesh obj
		for channel = -2 to 99 do
		(
			if ( meshOp.getMapSupport obj channel ) then
				if ( matchPattern obj.name pattern:"*_Collision" or channel > 2 ) then 
					meshOp.freeMapChannel obj channel
		)
		convertToPoly obj
	)
	
	if ( MSG_sameNames != "" ) 	then messageBox ("There are objects with same name. \n" + MSG_sameNames) 											title:"Warning"
	if ( MSG_badFaces != "" ) 	then messageBox ("There are objects that may contain corrupt faces (surface ~= 0). \n" + MSG_badFaces) 		title:"Warning"
	if ( MSG_invalidNames != "" ) then messageBox ("There are objects with invalid name. \n" + MSG_invalidNames) 											title:"Warning"
	
	format "==============================================\n"		
	gc()
)

Main ""

ok