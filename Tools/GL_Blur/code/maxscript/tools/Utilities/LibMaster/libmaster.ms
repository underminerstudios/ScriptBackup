global libMasterDiag 
function exportFbx _path =
(
	FbxExporterSetParam "Cameras" false
	FbxExporterSetParam "Animation" false
	FbxExporterSetParam "Lights" false
	FbxExporterSetParam "SmoothingGroups" true
	FbxExporterSetParam "TangentSpaceExport" true
	FbxExporterSetParam "NormalsPerPoly"
	FbxExporterSetParam "SmoothMeshExport" false
	FbxExporterSetParam "Preserveinstances" false
	FbxExporterSetParam "SelectionSetExport" false
	FbxExporterSetParam "GeomAsBone" false
	exportFile _path #noPrompt selectedOnly:true
)

fn exportObj _path = 
( 
	exportFile _path #noPrompt selectedOnly: True	
)
fn exportMax _path = 
( 
	saveNodes selection _path
)

fn snapshotSelected = 
(
	local newObj
	oObjsArr = selection as array

	if oObjsArr.count != 0 then
	(
		newObj = (copy oObjsArr[ 1 ])
		convertTo newObj PolyMeshObject

		for zz = 2 to oObjsArr.count do
		(
			polyOp.attach newObj ( copy oObjsArr[ zz ])
		)
	)
	newObj.pivot = [newObj.center.x, newObj.center.y, newObj.min.z]
	return newObj
)

fn isolateSelection = 
(
	local unhideObjects = #()
	for _node in objects do
	(
		if (_node.isSelected) == false then
		(
			if _node.isHidden == False then
			(
				append unhideObjects _node
				_node.ishidden = true
			)		
		)
	)
	return unhideObjects
)

fn retsoreHiddenObjects nodeArray = 
(
	for zz in nodeArray do
	(
		zz.isHidden = false
	)	
)

fn standardMaterialParser _material = 
(
	local imageArr = #()
	if _material.diffuseMap != undefined then
	(
		print (classof( _material.diffuseMap))
		appendIfUnique imageArr _material.diffuseMap.filename
	)				
	if _material.opacityMap != undefined then
	(
		appendIfUnique imageArr _material.opacityMap.filename
		_material.opacityMap.monoOutput = 1
	)				
	if _material.specularLevelMap != undefined then
	(
		appendIfUnique imageArr _material.specularMap.filename
	)
	if _material.bumpMap != undefined then
	(
		if (classof( _material.bumpMap)) == Normal_Bump then
			(
				appendIfUnique imageArr _material.bumpMap.normal_map.filename
			)
			else
			(
				appendIfUnique imageArr _material.bumpMap.filename
			)
		
	)
	return imageArr
)
fn glitchMaterialImages _material = 
(
	local tempImgArr = #()
	paramCount = _material.params.effectParamCount
	for i = 1 to paramCount do
	(
		param = _material.params[i]
		
		try 
		(
			lightMapImg = findString param.name "light"
			if lightMapImg == undefined then 
			(
				appendIfUnique tempImgArr param.texturePath
			)
		)
		catch
		(
		)

	)
	return tempImgArr	
)

fn gatherMaterialImages _material = 
(
	local imageArr = #()
	if classof(_material)  == Multimaterial then
	(
		for id = 1 to _material.materialList.count do 
		(
			subMaterial = _material.materialList[id]
			if classof(subMaterial) == Standardmaterial then
			(
				local tempArr = standardMaterialParser subMaterial
				for img in tempArr do
				(
					appendIfUnique imageArr img 
				)
			)
			if classof(subMaterial) == GL_Effect_Inst then
			(

				local tempArr = glitchMaterialImages subMaterial
				for img in tempArr do
				(
					appendIfUnique imageArr img 
				)
			)
		)
	)
	
	if classof(_material) == Standardmaterial then
	(
		local tempArr = standardMaterialParser _material
		for img in tempArr do
		(
			appendIfUnique imageArr img 
		)
	)
	if classof(_material) == GL_Effect_Inst then
	(
		local tempArr = glitchMaterialImages _material
		for img in tempArr do
		(
			appendIfUnique imageArr img 
		)
	)
	return imageArr
)
	
fn getFaceIds _object = 
(
	local faceIdArr = #()
	faceCount = polyOp.getNumFaces(_object)
	for id = 1 to faceCount do
	(					
		faceID = polyOp.getFaceMatID _object id 
		appendIfUnique faceIdArr faceID
	)
	return faceIdArr
)

fn makeStandardMatFromGlitch _material = 
(
	-- returns a standard material from a glitch material
	local shaderNodes = #()
	local paramCount = _material.params.effectParamCount
	local newMat = standardMaterial()
	newMat.adTextureLock = off
	showTextureMap newMat on
	
	for i = 1 to paramCount do
	(
		param = _material.params[i]
			try 
			(
				imgPath = param.texturePath
				if imgPath != "" then
				(
					appendifunique shaderNodes (#(param.name, param.texturePath))
				)
			)
			catch
			(
			)
	)
	
	for i in shaderNodes do
	(
		if (findString i[1] "diff") != undefined then
		(
			map =(Bitmaptexture fileName:i[2])
			newMat.diffuseMap = map
		)
		if (findString i[1] "spec") != undefined then
		(
			map =(Bitmaptexture fileName:i[2])
			newMat.specularLevelMap = map
		)
		if (findString i[1] "alpha") != undefined then
		(
			map =(Bitmaptexture fileName:i[2])
			newMat.opacityMap = map
			newMat.opacityMap.monoOutput = 1
		)
		if (findString i[1] "normal") != undefined then
		(
			map =(Bitmaptexture fileName:i[2])
			newMat.bumpMap.filename = i[2]
		)
	)
	
	return newMat
)

fn makeCleanMaterial _material  = --faceIdArr
(
	local newMat = undefined 
	local objectMat = copy _material

	if classof(objectMat)  == StandardMaterial then
	(
		objectMat.ambientMap = undefined
-- 		objectMat.opacityMapAmount = 0
	)
	if classof(objectMat)  == GL_Effect_Inst then
	(
		newMat = makeStandardMatFromGlitch objectMat
		newMat.adTextureLock = off
	)
	
	if classof(objectMat)  == Multimaterial then
	(
		for id = 1 to objectMat.materialList.count do 
		(
			submat = objectMat.materialList[id]
			if classof subMat == StandardMaterial then
			(
				subMat.ambientMap = undefined
-- 				subMat.opacityMapAmount = 0
			)
			if classof subMat == GL_Effect_Inst then
			(
				local tempMat = makeStandardMatFromGlitch subMat
				tempMat.adTextureLock = off
				tempMat.name = subMat.name
				objectMat.materialList[id]  = tempMat
			)
		)
		newMat = objectMat
	)

	if newMat == undefined then
	(
		newMat = standardMaterial()
		newMat.adTextureLock = off
	)
	return newMat
)
fn condenseMultiMat _object = 
(
  faceIdArr = getFaceIds _object
	
	if classof(_object.material) == Multimaterial then
	(
		newMultiMat = Multimaterial numsubs:faceIDArr.count
		count  = 1
		for id in faceIdArr do
		(
			
			local mat = _object.material.materialList[id]
			newMultiMat.material[count] = mat
			newMultiMat.materialIDList[count] = id
			count += 1
		)
		return newMultiMat
	)
	else
	(
		return _object.material
	)
)
fn makeRelativeStandardMat _material = 
(
	if _material.diffuseMap != undefined then
	(
		fname = filenameFromPath   _material.diffuseMap.filename
		_material.diffuseMap.filename = fname
	)				
	if _material.opacityMap != undefined then
	(
		fname = filenameFromPath   _material.opacityMap.filename
		_material.opacityMap.filename = fname
		_material.opacityMap.monoOutput = 1
	)				
	if _material.specularLevelMap != undefined then
	(
		fname = filenameFromPath   _material.specularMap.filename
		_material.specularMap.filename = fname
	)
	if _material.bumpMap != undefined then
	(
		fname = filenameFromPath   _material.bumpMap.filename
		_material.bumpMap.filename = fname
	)
)

fn makePathAbsolutStandardMat _material _basePath = 
(

	if _material.diffuseMap != undefined then
	(
		fname = filenameFromPath _material.diffuseMap.filename
		_material.diffuseMap.filename = _basePath + fname
	)				
	if _material.opacityMap != undefined then
	(
		fname = filenameFromPath   _material.opacityMap.filename
		_material.opacityMap.filename = _basePath + fname
		_material.opacityMap.monoOutput = 1
	)				
	if _material.specularLevelMap != undefined then
	(
		fname = filenameFromPath   _material.specularMap.filename
		_material.specularMap.filename = _basePath + fname
	)
	if _material.bumpMap != undefined then
	(	
		if (classof( _material.bumpMap)) == Normal_Bump then
		(
			fname = filenameFromPath _material.bumpMap.normal_map.filename
		)
		else
		(
			fname = filenameFromPath _material.bumpMap.filename
		)
	)
)

fn conforlmMaterialPaths _material _basePath = 
(
	if classof(_material)  == Multimaterial then
	(
		for subMat in _material do 
		(
			if subMat != undefined then
			(
				if classof(subMat) == Standardmaterial then
				(
					makePathAbsolutStandardMat subMat _basePath
				)
			)
		)
	)
	if classof(_material) == Standardmaterial then
	(
		makePathAbsolutStandardMat _material _basePath
	)
)

fn makeMaterialPathsRelative _material = 
(
	
	if classof(_material)  == Multimaterial then
	(
		for subMat in _material do 
		(
			if subMat != undefined then
			(
				if classof(subMat) == Standardmaterial then
				(
					makeRelativeStandardMat subMat
				)
			)
		)
	)
	if classof(_material) == Standardmaterial then
	(
		makeRelativeStandardMat _material
	)
)
	
fn existFile _path = 
(
	filecount = (getfiles _path).count != 0
)
	
fn pivotToBottomCenter _node = 
(
	_node.pivot = [ _node.center[1], _node.center[2], _node.min[3] ] 	
)

fn copyTextures imageArr textureOutput = 
(
	for img in imageArr do
	(
		fname = filenameFromPath img
		destFile = textureOutput + fname

		if (getFiles destFile).count != 0 then
		(
			if (getFileCreateDate  img > getFileCreateDate destFile) == true then
			(
				deleteFile destFile
				copyFile img destFile
			)
		)
		if (getFiles destFile).count == 0 then
		(

			copyFile img destFile
		)
	)
)
fn exportAsset = 
(
	local oSel 				= selection as array
	local outputPath 		= (libMasterDiag.pathEDT.text)
	local project 			= (libMasterDiag.ProjectDDL.text)
	local category 			= (libMasterDiag.categoryDDL.text)
	local outputName 		= (libMasterDiag.nameEDT.text)
	local meshOutput 		= outputPath + project + "\\" + category + "\\"
	local textureOutput 	= outputPath + project + "\\textures\\" 
	local maxFile 			= meshOutput + outputName +  ".max"
	local fbxFile 			= meshOutput + outputName +  ".fbx"
	local objFile 			= meshOutput + outputName +  ".obj"
	local defaultLayer 		= layermanager.getlayer 0
	defaultLayer.current 	= True
	defaultLayer.ishidden  	= False
	
	makeDir (meshOutput) all:true
	makeDir (textureOutput) all:true
	
	
	
	local obj = snapshotSelected()
	local newMat = condenseMultiMat obj
	local cleanMat = makeCleanMaterial newMat
	obj.pos = [0,0,0]
	obj.parent = undefined
	obj.name = outputName
	obj.material = cleanMat
	obj.material.name = outputName
	
	pivotToBottomCenter obj

	local imageArr = gatherMaterialImages newMat

	copyTextures imageArr textureOutput
	conforlmMaterialPaths cleanMat textureOutput
	
	select obj
	hiddenObject = isolateSelection()
	
	if existFile(maxFile) == True then
	(
		if queryBox "Mesh already present,\nDo you want to continue?" beep:false then
		(
			
			actionMan.executeAction 0 "311" -- Tools: Zoom Extents All Selected
-- 			exportObj objFile
			exportFbx fbxFile
			exportMax maxFile
			actionMan.executeAction 0 "40104"-- Views: Undo Viewport Operation
		)
	)
	else 
	(
		actionMan.executeAction 0 "311" -- Tools: Zoom Extents All Selected
-- 		exportObj objFile
		exportFbx fbxFile
		exportMax maxFile
		actionMan.executeAction 0 "40104"-- Views: Undo Viewport Operation
	)
	delete obj
	
	retsoreHiddenObjects hiddenObject
	select oSel
	
)
fn cleanString _string = 
(
	filterOutList = #("\\","/",":","*","?","”","<",">","|", " ")
	newStr = ""
	
	for i = 1 to _string.count  do
	(
		_set = False

		for ff in filterOutList do
		(
			if ff ==  _string[i] then
			(
				_set =  True
			)
		)
		if _string[i] == " " then
		(
			newStr += "_"
		)
		else if _set == True then
		(
			newStr += ""
		)
		else if _set == False then
		(
			newStr += _string[i]
		)
	)
	return newStr
)
fn  getIniFile = 
(
	iniDir = getDir (#temp)
	ini_file = iniDir + "\\libmaster.ini"
	if existFile ini_file != True then
	(
		setINISetting ini_file "UI" "project_path" (getDir #export)
		setINISetting ini_file "UI" "project" "DH5"
		setINISetting ini_file "UI" "category" "buildings"
		setINISetting ini_file "UI" "rename_mesh" "True"
		setINISetting ini_file "UI" "pos" "[741,396]"
	)
	return ini_file

)
rollout libMasterDiag "Lib Master" width:188 height:190
(
	
	editText pathEDT  "Path" 			pos:[8,16] width:150 height:21 text:@"c:\tmp\sandbox\"
	button browseBTN "..." 				pos:[165,16] width:20 height:21
	dropDownList ProjectDDL "Project" 	pos:[4,40] width:180 height:40 items:#("DH5", "MC4", "Universe", "Asphalt")
	dropDownList categoryDDL "Category"	pos:[4,80] width:180 height:40 items:#( "buildings", "props", "vegetation", "character", "vehicles")
	editText nameEDT "Name" 			pos:[4,125] width:135 height:21 text:"circular_stairs"
	button getNameBTN ".."	 			pos:[145,125] width:21 height:21 
	checkbox renameCBX ""				pos:[170,120] width:21 height:21 checked:True tooltip: "Renames the selected meshes"

	button exportBTN "Export" 			pos:[4,155] width:180 height:21
	
	on nameEDT entered arg do
	(
		libMasterDiag.nameEDT.text = cleanString(arg)
	)

	on getNameBTN pressed do
	(
		libMasterDiag.nameEDT.text = selection[1].name
	)
	on exportBTN pressed  do 
	(
		if selection.count > 0 then
		(
			if  libMasterDiag.renameCBX.checked == True then
			(
				for i in selection do
				(
					i.name = uniquename(libMasterDiag.nameEDT.text)
				)
			)
			exportAsset()
		)
	)
	on exportBtn rightClick do
	(
		local _path = (libMasterDiag.pathEDT.text  + libMasterDiag.ProjectDDL.selected + "\\" +libMasterDiag.categoryDDL.selected + "\\")
		_path =  ("explorer \"" + _path + "\"")
		doscommand _path
	)
	on browseBTN pressed  do
	(
		_output = getSavePath caption:"Browse for the destination directory" initialDir: libMasterDiag.pathEDT.text
		if  _output != undefined then
		(
			libMasterDiag.pathEDT.text = _output
		)
	)
	
	on libMasterDiag moved pos do
	(

	)
	on libMasterDiag close do
	(
		local iniFile = getIniFile()
		local coords = GetDialogPos libMasterDiag
		setINISetting iniFile "UI" "project_path" libMasterDiag.pathEDT.text
		setINISetting iniFile "UI" "project" (libMasterDiag.ProjectDDL.selection as string)
		setINISetting iniFile "UI" "category" (libMasterDiag.categoryDDL.selection   as string) 
		setINISetting iniFile "UI" "object_name" libMasterDiag.nameEDT.text
		setINISetting iniFile "UI" "rename_mesh" (libMasterDiag.renameCBX.checked as string)
		setINISetting iniFile "UI" "pos" (GetDialogPos libMasterDiag as string)
	)
)

fn __main__ = 
(
	local iniFile = getIniFile()
	global libMasterDiag 
	createDialog libMasterDiag 
	coord = filterstring (getINISetting iniFile  "UI" "pos") "[,],\,"
	coord = [coord[1] as integer, coord[2] as integer ]
	SetDialogPos  libMasterDiag coord
	libMasterDiag.pathEDT.text			= getINISetting iniFile  "UI" "project_path"
	libMasterDiag.ProjectDDL.selection 	= (getINISetting iniFile  "UI" "project")as integer
	libMasterDiag.categoryDDL.selection	= (getINISetting iniFile  "UI" "category")as integer
	libMasterDiag.nameEDT.text 			= getINISetting iniFile  "UI" "object_name"
	libMasterDiag.renameCBX.checked		= (getINISetting iniFile  "UI" "rename_mesh" )as booleanclass
)
try (destroydialog libMasterDiag)
catch()

__main__()




