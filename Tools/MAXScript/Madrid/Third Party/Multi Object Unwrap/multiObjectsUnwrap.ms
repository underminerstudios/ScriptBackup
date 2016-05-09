global multiObjUnwrapFloater
global multiObjUnwrapRollout
try(removeRollout multiObjUnwrapRollout)catch()
try(closerolloutfloater multiObjUnwrapFloater)catch()

rollout waitRollout "multi Objects unwrap" ( label lb_wait "please wait a minute ..." )
rollout multiObjUnwrapRollout "multiObjectsUnwrap 2.1"
(
group "multi Objects Unwrap"
	(
	spinner channel_osd "work on channel:" range:[1,99,1] type:#integer scale:1 fieldwidth:28
	checkbox copyFromChannel_osd "copied from" checked:false
	spinner fromChannel_osd "" range:[1,99,1] type:#integer scale:1 fieldwidth:28 offset:[0,-20] enabled:false
	checkbox ignoreChannelInfo_osd "don't use Channel Info" checked:false
	button editUVW_osd "unwrap UV's" align:#left width:72
	button copyUVW_osd "set UV's" align:#right offset:[0,-26] width:50 enabled:false
	button cancelUVW_osd "Cancel" enabled:false
	checkbox usePrevUVW_osd "use previous unwrap" checked:true
	checkbox convertToPoly_osd "convert to polys" checked:false
	button infoHC_osd "?" align:#right height:18 width:16 offset:[0,-22]
	progressBar pBar value:0 color:blue
	)
label lb1 "by Olivier Vandecasteele"
label lb2 "email: gray@skynet.be"

global multiObjUnwrap_sel=undefined
global multiObjUnwrap_faceIndex=undefined
global multiObjUnwrap_uvwRef=undefined

fn isGeometry obj = ( if ( isKindOf obj geometryClass and classof obj != TargetObject ) then true else false )

fn filterGeometry sel = (for obj in sel where isGeometry obj collect obj)

fn convertObj obj =
	(
	local vn=maxVersion()
	local classOfObj=classOf obj
	if not(classOfObj==Editable_Poly or classOfObj==PolyMeshObject or classOfObj==Editable_mesh)
		do ( if vn[1]<7000 then addModifier obj (Edit_Mesh ()) else addModifier obj (Edit_Poly ()) )
	)--fn

fn setUnwrapContext obj objUnwrapMod =
	(
	if modPanel.getCurrentObject()==undefined do max modify mode
	if selection.count!=1 do select obj
	if selection[1]!=obj do select obj
	if modPanel.getCurrentObject()!=objUnwrapMod do modPanel.setCurrentObject objUnwrapMod
	)

fn getThisOp obj =
	(
	local classOfObj=classOf obj
	local thisOp
	case classOfObj of
		(
		Editable_Poly: thisOp=polyOp
		PolyMeshObject: thisOp=polyOp
		Editable_mesh: thisOp=meshOp
		default: ( addModifier obj (Edit_Mesh ()) ; thisOp=meshOp )
		)
	thisOp
	)

fn copyMapChannel objUnwrapMod fromChannel toChannel =
	(
	local objUnwrap1=objUnwrapMod.unwrap
	local objUnwrap2=objUnwrapMod.unwrap2
	local thisElementMode=objUnwrap2.getTVElementMode()
	local thisSubObjectMode=objUnwrap2.getTVSubObjectMode()
	objUnwrap2.setTVElementMode false
	objUnwrap2.setTVSubObjectMode 3
	local thisFaces=objUnwrap2.getSelectedFaces()
	objUnwrap1.setMapChannel fromChannel
	modPanel.setCurrentObject objUnwrapMod -- update
	local theFaces=#{1..objUnwrap1.numberPolygons()}
	objUnwrap2.selectFaces theFaces
	objUnwrap2.copy()
	objUnwrap1.setMapChannel toChannel
	modPanel.setCurrentObject objUnwrapMod -- update
	objUnwrap2.selectFaces theFaces
	objUnwrap2.paste false
	objUnwrap2.selectFaces thisFaces
	objUnwrap2.setTVElementMode thisElementMode
	objUnwrap2.setTVSubObjectMode thisSubObjectMode
	)

fn copyMapChannel2 obj fromChannel toChannel =
	(
	try(channelInfo.CopyChannel obj 3 fromChannel)catch(channelInfo.CopyChannel obj 3 1; channelInfo.PasteChannel obj 3 fromChannel)
	local thisOp=getThisOp obj
	local currentNumMaps=(thisOp.getNumMaps obj)-1
	if currentNumMaps<1 do thisOp.setNumMaps obj toChannel+1 keep:true
	local currentMapSupport1=thisOp.getMapSupport obj fromChannel
	if currentMapSupport1==false do thisOp.defaultMapFaces obj fromChannel
	local currentMapSupport2=thisOp.getMapSupport obj toChannel
	if currentMapSupport2==false do thisOp.defaultMapFaces obj toChannel
	channelInfo.CopyChannel obj 3 fromChannel
	channelInfo.PasteChannel obj 3 toChannel
	)

fn multiCopyMapChannel objUnwrapMod1 theFaces1 fromChannel objUnwrapMod2 theFaces2 toChannel =
	(
	local objUnwrap1=objUnwrapMod1.unwrap
	local objUnwrap2=objUnwrapMod1.unwrap2
	objUnwrap2.setTVElementMode false
	objUnwrap2.setTVSubObjectMode 3
	if (objUnwrap1.getMapChannel())!=fromChannel do objUnwrap1.setMapChannel fromChannel
	modPanel.setCurrentObject objUnwrapMod1 -- update
	objUnwrap2.selectFaces theFaces1
	objUnwrap2.copy()
	local obj2Unwrap1=objUnwrapMod2.unwrap
	local obj2Unwrap2=objUnwrapMod2.unwrap2
	obj2Unwrap2.setTVElementMode false
	obj2Unwrap2.setTVSubObjectMode 3
	if (obj2Unwrap1.getMapChannel())!=toChannel do obj2Unwrap1.setMapChannel toChannel
	modPanel.setCurrentObject objUnwrapMod2 -- update
	obj2Unwrap2.selectFaces theFaces2
	obj2Unwrap2.paste false
	obj2Unwrap2.selectFaces #{}
	)

fn addUnwrapIfNecessary obj channel reuse =
	(
	if ( reuse and (classof obj.modifiers[1]==Unwrap_UVW) )
		then (
			currentChannel=obj.modifiers[1].unwrap.getMapChannel()
			case currentChannel of
				(
				0: currentChannel=1
				1: currentChannel=0
				)
			if channel==currentChannel
				then obj.modifiers[1]
				else (
					objUnwrapMod=Unwrap_UVW()
					addModifier obj objUnwrapMod
					objUnwrapMod.unwrap.setMapChannel channel
					objUnwrapMod
					)
			)
		else (
			objUnwrapMod=Unwrap_UVW()
			addModifier obj objUnwrapMod
			objUnwrapMod.unwrap.setMapChannel channel
			objUnwrapMod
			)
		)--fn

fn resetXFormAndFlip obj = 
	(
	local rotvalue=obj.rotation
	obj.rotation=(quat 0 0 0 1)
	local M=obj.transform
	obj.transform=transMatrix obj.pos
	local p=obj.objecttransform*(inverse obj.transform)
	obj.objectoffsetPos=[0,0,0]
	obj.objectoffsetRot=(quat 0 0 0 1)
	obj.objectoffsetScale=[1,1,1]
	M.translation=[0,0,0]
	M=p*M
	local xformMod=XForm()
	addmodifier obj xformMod
	xformMod.gizmo.transform=M
	obj.rotation=rotvalue
	addmodifier obj (Normalmodifier flip:true)
	)--fn

on infoHC_osd pressed do
	(
	msg="Same as 'convert to Editable Poly'\n"
	msg+="beware: the stack will be collapsed!\n"
	msg+="Use this option with caution : no undo available"
	messageBox(msg) title:"Collapse option"
	)--on

on editUVW_osd pressed do
	(
	multiObjUnwrap_sel=selection as array
	multiObjUnwrap_sel=filterGeometry multiObjUnwrap_sel
	local vn=maxVersion()
	if multiObjUnwrap_sel.count>0 then
		(
		if multiObjUnwrap_sel.count==1 do (
			max modify mode
			local obj=multiObjUnwrap_sel[1]
			convertObj obj
			select obj
			local newMode=false
			if vn[1]>=6000 do newMode=true
			if ignoreChannelInfo_osd.checked do newMode=false
			if newMode do (if copyFromChannel_osd.checked do ( copyMapChannel2 obj fromChannel_osd.value channel_osd.value ) )
			local objUnwrapMod=addUnwrapIfNecessary obj channel_osd.value usePrevUVW_osd.checked
			setUnwrapContext obj objUnwrapMod
			if not newMode do (if copyFromChannel_osd.checked do ( copyMapChannel objUnwrapMod fromChannel_osd.value channel_osd.value ) )
			objUnwrapMod.unwrap.edit()
			objUnwrapMod.unwrap.displayMap false
			objUnwrapMod.unwrap2.setGridVisible false
			objUnwrapMod.unwrap2.setTVSubObjectMode 3
			objUnwrapMod.unwrap2.setTVElementMode true
			)
		if multiObjUnwrap_sel.count>1 do (
			startTime=timeStamp()
			format "\n"
			max modify mode
			undo off (
				local count=0
				local errorLinearFaces=false
				local selClone
				hide multiObjUnwrap_sel
				for obj in multiObjUnwrap_sel do convertObj obj
				maxops.cloneNodes multiObjUnwrap_sel cloneType:#copy newNodes:&selClone
				multiObjUnwrap_faceIndex=#()
				local selCloneCount=selClone.count
				for i=1 to selCloneCount do (
					pBar.value=((i as float/selCloneCount as float)*100.0)as integer
					local obj=selClone[i]
					if ((obj.scale.x < 0) OR (obj.scale.y < 0) OR (obj.scale.z < 0)) do (resetXFormAndFlip obj)
					if classOf obj==Editable_mesh do (
						convertToMesh obj
						for face=1 to obj.numfaces do ( for edge=1 to 3 do ( setedgevis obj face edge true ) )
						)
					local errorLinearFaces1=obj.numFaces
					convertToPoly obj
					local objNumFaces=obj.numFaces
					if errorLinearFaces1!=objNumFaces then errorLinearFaces=true
					local currentFaces=for f=1 to objNumFaces collect (count+f)
					append multiObjUnwrap_faceIndex currentFaces
					count+=objNumFaces
					)
				if errorLinearFaces
					then (
						format "multiObjectsUnwrap :: error in object(s): there are illegal faces\n"
						max create mode
						pBar.value=0.0
						for obj in selClone where isValidNode obj do delete obj
						sel2=#()
						for obj in multiObjUnwrap_sel where isValidNode obj do ( unhide obj ; append sel2 obj )
						select sel2
						editUVW_osd.enabled=true
						channel_osd.enabled=true
						copyFromChannel_osd.enabled=true
						if copyFromChannel_osd.checked do fromChannel_osd.enabled=true
						copyUVW_osd.enabled=false
						cancelUVW_osd.enabled=false
						max views redraw
						messageBox("error in object(s)\nthere are illegal faces") title:"multiObjectsUnwrap error"
						)
					else (
						if count>5000 do createDialog waitRollout 192 28 modal:false
						select selClone[1]
						max create mode
						for idxObj=2 to selCloneCount do ( theName=selClone[idxObj].name ; try(polyOp.attach selClone[1] selClone[idxObj])catch(format "multiObjectsUnwrap :: attachement warning : % \n" theName) )
						max modify mode
						multiObjUnwrap_uvwRef=selClone[1]
						convertToPoly multiObjUnwrap_uvwRef
						multiObjUnwrap_uvwRef.name="multiObjectsUnwrap"
						unhide multiObjUnwrap_uvwRef
						select multiObjUnwrap_uvwRef
						local newMode=false
						if vn[1]>=6000 do newMode=true
						if ignoreChannelInfo_osd.checked do newMode=false
						if newMode do (
							if copyFromChannel_osd.checked
								then ( copyMapChannel2 multiObjUnwrap_uvwRef fromChannel_osd.value 1 )
								else ( copyMapChannel2 multiObjUnwrap_uvwRef channel_osd.value 1 )
							convertToPoly multiObjUnwrap_uvwRef
							)
						local uvwRefUnwrapMod=Unwrap_UVW()
						addModifier multiObjUnwrap_uvwRef uvwRefUnwrapMod
						uvwRefUnwrapMod.name="Unwrap UVW ch"+(channel_osd.value as string)
						setUnwrapContext multiObjUnwrap_uvwRef uvwRefUnwrapMod
						if not newMode do (
							if copyFromChannel_osd.checked
								then ( copyMapChannel uvwRefUnwrapMod fromChannel_osd.value 1 )
								else ( copyMapChannel uvwRefUnwrapMod channel_osd.value 1 )
							)
						if count>5000 do (try(destroyDialog waitRollout)catch())
						editUVW_osd.enabled=false
						channel_osd.enabled=false
						copyFromChannel_osd.enabled=false
						fromChannel_osd.enabled=false
						cancelUVW_osd.enabled=true
						copyUVW_osd.enabled=true
						endTime=timeStamp()
						format "multiObjectsUnwrap :: unwrap UV's Processing took % seconds\n" ((endTime-startTime) / 1000.0)
						pBar.value=0.0			
						max views redraw
						uvwRefUnwrapMod.unwrap.edit()
						uvwRefUnwrapMod.unwrap.displayMap false
						uvwRefUnwrapMod.unwrap2.setGridVisible false
						uvwRefUnwrapMod.unwrap2.setTVSubObjectMode 3
						uvwRefUnwrapMod.unwrap2.setTVElementMode true
						)--else
				)--undo off
			)--if multiObjUnwrap_sel.count>1
		)
	else MessageBox("select at least one object")
	)--on

on copyUVW_osd pressed do
	(
	if multiObjUnwrap_sel.count>0 do
		(
		startTime=timeStamp()
		max modify mode		
		undo off (
			unhide multiObjUnwrap_sel
			clearSelection()
			disableSceneRedraw()
			local count=0
			for i=1 to multiObjUnwrap_faceIndex.count do count+=multiObjUnwrap_faceIndex[i].count
			if count>5000 do createDialog waitRollout 192 28 modal:false
			local uvwRefUnwrapMod=multiObjUnwrap_uvwRef.modifiers[1]
			setUnwrapContext multiObjUnwrap_uvwRef uvwRefUnwrapMod
			for i=1 to multiObjUnwrap_sel.count do
				(
				pBar.value=((i as float/multiObjUnwrap_sel.count as float)*100.0)as integer
				local obj=multiObjUnwrap_sel[i]
				local theFacesuvwRef=(multiObjUnwrap_faceIndex[i] as bitarray)
				select obj
				local objUnwrapMod=addUnwrapIfNecessary obj channel_osd.value usePrevUVW_osd.checked
				if not objUnwrapMod.enabled do objUnwrapMod.enabled=true
				objUnwrapMod.name="Unwrap UVW ch"+(channel_osd.value as string)
				local theFacesObj=#{1..objUnwrapMod.unwrap.numberPolygons()}
				if theFacesObj.numberset==theFacesuvwRef.numberset
					then ( multiCopyMapChannel uvwRefUnwrapMod theFacesuvwRef 1 objUnwrapMod theFacesObj channel_osd.value )
					else (format "multiObjectsUnwrap :: error ! object % has changed\n" obj.name)
				)
			enableSceneRedraw()
			if convertToPoly_osd.checked do (for obj in multiObjUnwrap_sel do convertToPoly obj)
			delete multiObjUnwrap_uvwRef
			if count>5000 do (try(destroyDialog waitRollout)catch())
			
			editUVW_osd.enabled=true
			channel_osd.enabled=true
			copyFromChannel_osd.enabled=true
			if copyFromChannel_osd.checked do fromChannel_osd.enabled=true
			copyUVW_osd.enabled=false
			cancelUVW_osd.enabled=false
			endTime=timeStamp()
			format "multiObjectsUnwrap :: Set UV's Processing took % seconds\n" ((endTime-startTime) / 1000.0)
			pBar.value=0.0
			max views redraw
			select multiObjUnwrap_sel
			)--undo off
		)--if multiObjUnwrap_sel.count>0
	)--on

on cancelUVW_osd pressed do
	(
	max create mode
	pBar.value=0.0
	undo off (
		if isValidNode multiObjUnwrap_uvwRef do delete multiObjUnwrap_uvwRef
		sel2=#()
		for obj in multiObjUnwrap_sel do ( if isValidNode obj do ( unhide obj ; append sel2 obj ) )
		select sel2
		editUVW_osd.enabled=true
		channel_osd.enabled=true
		copyFromChannel_osd.enabled=true
		if copyFromChannel_osd.checked do fromChannel_osd.enabled=true
		copyUVW_osd.enabled=false
		cancelUVW_osd.enabled=false		
		)
	max views redraw
	)--on

on multiObjUnwrapRollout open do
	(
	local vn=maxVersion()
	if vn[1]<6000 do ( ignoreChannelInfo_osd.checked=true ; ignoreChannelInfo_osd.enabled=false )
	)

on copyFromChannel_osd changed theState do (if theState then fromChannel_osd.enabled=true else fromChannel_osd.enabled=false )

)
multiObjUnwrapFloater = newRolloutFloater "multiUnwrap" 162 228
addRollout multiObjUnwrapRollout multiObjUnwrapFloater rolledUp:false
