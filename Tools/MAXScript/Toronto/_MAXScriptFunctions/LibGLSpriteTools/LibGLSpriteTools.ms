-- GameLoft Sprite Tools.
print "Loading LibglSpriteTool2s..."

/* Custom attributes for the animated object Node, */
animNodeAttributesCA = attributes animNodeAttributes
(
	parameters main
	(
		-- same attributes as the static object CA
		objNodeName type:#string
		objCatagory type:#integer		
		renderViewA type:#boolean
		renderViewB type:#boolean
		renderViewC type:#boolean
		renderViewD type:#boolean
		renderEnabled type:#boolean	
		useMSmatteShadow type:#boolean
		overRideSceneAA type:#boolean		
		
		glstVersion type:#float default:0.3
		
		-- Animation specific attributes
		isAnimating type:#boolean
		animationName type:#string
		startFrame type:#integer
		endFrame type:#integer		
		animObjects type:#nodetab tabSizeVariable:true
		nthFrameRender type:#integer default:1
	)
)
/* Custom attributes for the root node. stores the camera, lights and matte shadow mesh */
sceneAttributesCA = attributes sceneAttributes
(
	parameters main
	(
		masterCamera type:#node
		masterLights type:#nodetab tabSizeVariable:true
		masterShadowCatcher type:#node
		tilesWide type:#integer 
		
	)
)



------------------------------------------------------
/* Global Functions:

glSpriteTool2.init
glSpriteTool2.getChildren
glSpriteTool2.getFilesRecursive
glSpriteTool2.getRenderPreFix
glSpriteTool2.renderPass
glSpriteTool2.hasRootNodeCA
glSpriteTool2.hasObjNodeCA
glSpriteTool2.hasAnimNodeCA
glSpriteTool2.hasValidAnimNodeCA
glSpriteTool2.hasValidStaticNodeCA
glSpriteTool2.printLog
glSpriteTool2.md5
glSpriteTool2.updateAnimNode

------------------------------------------------------
 Global Variables:
 
 glSpriteTool2.invalidChars
 
 ------------------------------------------------------
 Global Settings Variables:
 
glSpriteTool2.invalidChars
glSpriteTool2.animUIVersion
glSpriteTool2.localVersion
glSpriteTool2.showVFB
 
glSpriteTool2.overRideMinimumSamples
glSpriteTool2.overRideMaximumSamples
glSpriteTool2.overRideFilter

glSpriteTool2.defaultMinimumSamples
glSpriteTool2.defaultMaximumSamples
glSpriteTool2.defaultFilter

glSpriteTool2.masterScene			-- String
glSpriteTool2.baseArtDirectory		-- String
glSpriteTool2.subDirectoryName		-- String
glSpriteTool2.renderPath			-- String
glSpriteTool2.projectNamePrefix		-- String
glSpriteTool2.pixelPerUnit			-- Integer
glSpriteTool2.tileSize				-- Integer
glSpriteTool2.verticalAngle 			-- Integer	
glSpriteTool2.unitsPerMeter			-- Integer

glSpriteTool2.logFileName			-- String
glSpriteTool2.fileLog				-- Boolean
glSpriteTool2.printListener			-- Boolean

glSpriteTool2.hashFileName			-- String
glSpriteTool2.checkHashTable		-- Boolean

glSpriteTool2.saveTGA			-- Boolean
glSpriteTool2.savePNG			-- Boolean

*/
------------------------------------------------------

struct glSTool
(
	-- Global Constants	
	invalidChars, animUIVersion, localVersion, catagories,

	-- Global variables
	localVersion, showVFB, saveTGA, savePNG, 
	overRideMinimumSamples, overRideMaximumSamples, overRideFilter,
	defaultMinimumSamples, defaultMaximumSamples, defaultFilter,
	masterScene, baseArtDirectory, subDirectoryName, renderPath, projectNamePrefix,
	pixelPerUnit, tileSize,verticalAngle, unitsPerMeter, logFileName, fileLog, printListener,
	hashFileName, checkHashTable,
	
	-- Functions
	getChildren, getFilesRecursive,  getRenderPreFix, renderPass, hasRootNodeCA,
	hasObjNodeCA, glSLoadINI, init, hasAnimNodeCA, hasValidAnimNodeCA,
	hasValidStaticNodeCA, printLog, md5, updateAnimNode
)

-- create instance of glSTools struct
glSpriteTool2 = glSTool()


-- initalize the global constants
glSpriteTool2.invalidChars = #(" ",".","\n","\r")
glSpriteTool2.animUIVersion = 0.3
glSpriteTool2.localVersion = 0.2
glSpriteTool2.catagories = #("animals","buildings","exhibits","habitats","decors","visitors")

-- initalize the global variables

glSpriteTool2.saveTGA = true
glSpriteTool2.savePNG = true

/***********************/
/***** Functions *****/
/***********************/

glSpriteTool2.md5 = fn md5 thefile =
(
	if (doesFileExist ((getDir #scripts) + "\\glSpriteTool2\\md5.exe")) then
	(
		if (doesFileExist theFile) then 
		(	
			cmd = ("md5.exe -n -ohash.txt " + "\"" + theFile + "\"")
			HiddenDOSCommand cmd startpath:((getDir #scripts) + "\\glSpriteTool2\\")

			md5hashfile = openFile ((getDir #scripts) + "\\glSpriteTool2\\hash.txt")
			while not eof md5hashfile do
			(
				md5hashline = (readline md5hashfile)
			)
			close md5hashfile
			deleteFile ((getDir #scripts) + "\\glSpriteTool2\\hash.txt")
		)		
	)
	return md5hashline
)
md5 = undefined

-- prints string to the listener and the log txt file depending on the flags set.
-- Will always append the last printed line.
-- Use "\n" at the end of string for an carraige return
glSpriteTool2.printLog = fn printLog txt =
(	
	if txt != undefined then
	(
		if glSpriteTool2.fileLog then
		(
			print ("Trying to write to " + glSpriteTool2.logFileName)
			if not (doesFileExist glSpriteTool2.logFileName) then
			(
				print ("The log file doesn't exist.  Creating it.")
				createfile glSpriteTool2.logFileName
			)
			
			logFile = (openfile glSpriteTool2.logFileName mode:"at")	--set logFile as File stream
			format txt to:logFile 									-- appends to file stream
			close logFile 											-- close the file stream so the file can be deleted or modified after the script has run its course
			
			--(dotnetclass "System.IO.File").AppendAllText glSpriteTool2.logFileName (txt + "\n") 	-- dotnet text append
		)
		if glSpriteTool2.printListener then
		(
			format txt
		)
	)
)	
printLog = undefined

-- initializes the gsSpriteTool global variables from various INI files
-- Returns true if succesful
glSpriteTool2.init = fn init = 
(
	initSucces = true
	local DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	projectINILocation = (DEPOT_PATH + "MAXScript\\Toronto\\_MAXScriptFunctions\\LibGLSpriteTools\\BatchSpriteRender.ini")

	if (doesFileExist projectINILocation) then		--Load settings from the project INI into the gsSpriteTool Struct varibles
	(
		print "BatchSpriteRender.ini found"
		glSpriteTool2.masterScene = GetINISetting projectINILocation "RenderSettings" "masterScene" 
		glSpriteTool2.baseArtDirectory = GetINISetting projectINILocation "RenderSettings" "baseArtDirectory" 
		glSpriteTool2.subDirectoryName = GetINISetting projectINILocation "RenderSettings" "subDirectoryName" 
		glSpriteTool2.renderPath = GetINISetting projectINILocation "RenderSettings" "renderPath" 
		print ("Render path: " + glSpriteTool2.renderPath)
		glSpriteTool2.projectNamePrefix = GetINISetting projectINILocation "RenderSettings" "projectNamePrefix" 
		glSpriteTool2.pixelPerUnit = (GetINISetting projectINILocation "RenderSettings" "pixelPerUnit") as integer
		glSpriteTool2.tileSize = (GetINISetting projectINILocation "RenderSettings" "tileSize") as integer 
		glSpriteTool2.verticalAngle = (GetINISetting projectINILocation "RenderSettings" "verticalAngle") as integer 
		glSpriteTool2.unitsPerMeter = (GetINISetting projectINILocation "RenderSettings" "unitsPerMeter") as integer
		
		glSpriteTool2.overRideMinimumSamples = (GetINISetting projectINILocation "RenderSettings" "overRideMinimumSamples") as integer 
		glSpriteTool2.overRideMaximumSamples = (GetINISetting projectINILocation "RenderSettings" "overRideMaximumSamples") as integer 
		glSpriteTool2.overRideFilter = (GetINISetting projectINILocation "RenderSettings" "overRideFilter") as integer 

		glSpriteTool2.defaultMinimumSamples = (GetINISetting projectINILocation "RenderSettings" "defaultMinimumSamples") as integer 
		glSpriteTool2.defaultMaximumSamples = (GetINISetting projectINILocation "RenderSettings" "defaultMaximumSamples") as integer 
		glSpriteTool2.defaultFilter = (GetINISetting projectINILocation "RenderSettings" "defaultFilter") as integer 

		
		glSpriteTool2.hashFileName = GetINISetting projectINILocation "RenderSettings" "hashFileName" 
		glSpriteTool2.checkHashTable = GetINISetting projectINILocation "RenderSettings" "checkHashTable" 

		glSpriteTool2.saveTGA = GetINISetting projectINILocation "RenderSettings" "saveTGA" 			
		glSpriteTool2.savePNG = GetINISetting projectINILocation "RenderSettings" "savePNG" 			
					
		glSpriteTool2.logFileName = GetINISetting projectINILocation "LogSettings" "logFileName" 
		glSpriteTool2.fileLog = (GetINISetting projectINILocation "LogSettings" "fileLog")
		glSpriteTool2.printListener = (GetINISetting projectINILocation "LogSettings" "printListener")
		
		glSpriteTool2.showVFB = false -- default when tool initilizes
		
		if (toLower glSpriteTool2.fileLog) == "true" then
		(
			glSpriteTool2.fileLog = true
		)
		else (glSpriteTool2.fileLog = false)
		
		if (toLower glSpriteTool2.printListener) == "true" then
		(
			glSpriteTool2.printListener = true
		)
		else (glSpriteTool2.printListener = false)
		
		if (toLower glSpriteTool2.checkHashTable) == "true" then
		(
			glSpriteTool2.checkHashTable = true
		)
		else (glSpriteTool2.checkHashTable = false)
		
		if (toLower glSpriteTool2.saveTGA) == "true" then
		(
			glSpriteTool2.saveTGA = true
		)
		else (glSpriteTool2.saveTGA = false)
		
		if (toLower glSpriteTool2.savePNG) == "true" then
		(
			glSpriteTool2.savePNG = true
		)
		else (glSpriteTool2.savePNG = false)
		
	)
	else
	(
		messageBox "Unable to load settings from project INI file"
		initSucces = false
	)
			
	return initSucces 	
)
init = undefined

-- Function stolen from CRYTools. 
-- Get children
glSpriteTool2.getChildren = fn getChildren theNode =
(
	nodeArray = #()
	for obj in theNode.children do
	(
		append nodeArray obj
		join nodeArray (glSpriteTool2.getChildren obj)
	)
	return nodeArray
)
getChildren = undefined

-- Scans all directories and sub directories in Root and returns all max files contained only in dirPattern directory
glSpriteTool2.getFilesRecursive =fn getFilesRecursive root dirPattern =
(
	pattern = "*.max"
	dir_array = GetDirectories (root+"/*")
	for d in dir_array do
		join dir_array (GetDirectories (d+"/*"))
	my_files = #()
	for d in dir_array do
	(
		pathParts = filterstring (d as string) "\\"
		tempdir = ""
		if pathParts[pathParts.count] ==dirPattern do join my_files (getFiles (d + pattern))
	)
	sort my_files
)
getFilesRecursive = undefined

-- strips out the root directory name, everything after the dirPattern and replaces "\" with "_"
-- ect "c:\Repository\zoo_rescue_iphone\art\\Buildings\\DrinkStalls\\Scenes\drinkstalls.max"
-- to   "Buildings_DrinkStalls_"
glSpriteTool2.getRenderPreFix =fn getRenderPreFix maxFile =
(
	objRenderName = (replace maxFile (findString maxFile glSpriteTool2.baseArtDirectory) (glSpriteTool2.baseArtDirectory.count + 1) "")
	objRenderName = (replace objRenderName (findString objRenderName glSpriteTool2.subDirectoryName) (objRenderName.count - (findString objRenderName glSpriteTool2.subDirectoryName)+1) "")
	splitPaths = (filterString objRenderName "\\")  
	objRenderName = ""
	for i = 1 to (splitPaths.count)-1  do 
	(
		objRenderName = (objRenderName + splitPaths[i] + "_")
	)

	return objRenderName	
)
getRenderPreFix = undefined

glSpriteTool2.renderPass = fn renderPass renderPath objName renderOutSize =
(
	b = bitmap renderoutSize renderoutSize hasAlpha:true
	print ("Master Camera: " + rootNode.masterCamera as string)
	render renderSize renderSize renderhiddenobjects:false camera:rootNode.masterCamera  vfb:glSpriteTool2.showVFB quiet:false to:b
	
	if glSpriteTool2.saveTGA then
	(
		Targa.setPreMultAlpha false			-- ***IMPORTANT! 
		Targa.setColorDepth 32					-- *** both of these save TGA's as 32 bit with the alpha map.
		saveFileTGA as string
		saveFileTGA = toLower (renderPath + objName + ".tga")
		
		t = bitmap renderoutSize renderoutSize hasAlpha:true filename:saveFileTGA
		copy b t 
		save t
		close t
	)
	if glSpriteTool2.savePNG then
	(	
		pngio.setType #true48
		pngio.setAlpha true
		pngio.setInterlaced false
		saveFilePNG as string
		saveFilePNG = toLower (renderPath + objName + ".png")
		
		p = bitmap renderoutSize renderoutSize hasAlpha:true filename:saveFilePNG
		copy b p
		save p
		close p
	)
	
	close b
)
renderPass = undefined

-- Checks if the root node of the scene has the scene attributes CA added. Returns Bool
glSpriteTool2.hasRootNodeCA = fn hasRootNodeCA =
(
	hasCA = true
	try (rootNode.masterCamera.name) catch(hasCA = false)
	return hasCA
)
hasRootNodeCA = undefined

-- Checks if the object  has the obj attributes CA added. Returns Bool
glSpriteTool2.hasObjNodeCA = fn hasObjNodeCA obj =
(
	hasCA = true
	try (obj.objNodeName) catch(hasCA = false)
	return hasCA
)
hasObjNodeCA = undefined

-- Checks if the object  has the animation obj attributes CA added. Returns Bool
glSpriteTool2.hasAnimNodeCA = fn hasAnimNodeCA obj =
(
	hasCA = true
	try (obj.animationName) catch(hasCA = false)
	return hasCA
)
hasAnimNodeCA = undefined

glSpriteTool2.updateAnimNode = fn updateAnimNode obj =
(
	if (glSpriteTool2.hasAnimNodeCA obj) then
	(
		-- Checks if the render objects still exist.
		tempArray = #()
		for o in obj.animObjects do (append tempArray o)				
		obj.animObjects = #()
		for o = 1 to tempArray.count do 
		(
			if IsValidNode tempArray[o] then
			(
				append obj.animObjects tempArray[o]	
			)					
		)
		
		/***** Store AnimNode CA vars *****/
		/***** Defaults are set here aswell, I guess *****/
		try(tempobjNodeName = obj.objNodeName) catch(tempbjNodeName = "")
		try(temprenderViewA = obj.renderViewA) catch(temprenderViewA = false)
		try(temprenderViewB = obj.renderViewB) catch(temprenderViewB = false)
		try(temprenderViewC = obj.renderViewC) catch(temprenderViewC = false)
		try(temprenderViewD = obj.renderViewD) catch(temprenderViewD = false)
		try(temprenderEnabled = obj.renderEnabled) catch(temprenderEnabled = true)
		try(tempuseMSmatteShadow = obj.useMSmatteShadow) catch(tempuseMSmatteShadow = true)
		try(tempoverRideSceneAA = obj.overRideSceneAA) catch(tempoverRideSceneAA = false)
		try(tempisAnimating = obj.isAnimating) catch(tempisAnimating = false)
		try(tempanimationName = obj.animationName) catch(tempanimationName = "")
		try(tempstartFrame = obj.startFrame) catch(tempstartFrame = 0)
		try(tempendFrame = obj.endFrame) catch(tempendFrame = 0)
		try(tempanimObjects = obj.animObjects) catch(tempanimObjects = #())
		try(tempnthFrameRender = obj.nthFrameRender) catch(tempnthFrameRender = 1)
			
		custAttributes.delete obj 1		-- deletes the CA
		custAttributes.add obj animNodeAttributesCA	
			
		/***** Enter that shit back into the new CA *****/
		obj.objNodeName = tempobjNodeName
		obj.renderViewA = temprenderViewA
		obj.renderViewB = temprenderViewB	
		obj.renderViewC = temprenderViewC
		obj.renderViewD = temprenderViewD
		obj.renderEnabled = temprenderEnabled
		obj.useMSmatteShadow = tempuseMSmatteShadow
		obj.overRideSceneAA = tempoverRideSceneAA
		obj.isAnimating = tempisAnimating
		obj.animationName = tempanimationName
		obj.startFrame = tempstartFrame
		obj.endFrame = tempendFrame
		obj.animObjects = tempanimObjects
		obj.nthFrameRender = tempnthFrameRender
	)	
)
updateAnimNode = undefined

-- Checks if the Animation Obj Attribute CA is valid and the object will render
-- returns Bool
glSpriteTool2.hasValidAnimNodeCA = fn hasValidAnimNodeCA obj =
(
	validAnimCA = true
	if (glSpriteTool2.hasAnimNodeCA obj) then
	(		
		if not obj.renderEnabled then (validAnimCA = false) 
		if not obj.isAnimating then (validAnimCA = false) 		
		if obj.objNodeName == undefined then (validAnimCA = false)
		if obj.objNodeName == "" then (validAnimCA = false)		
		
		for i = 1 to (glSpriteTool2.invalidChars).count do 				-- Checks if the objNodeName against the invalidChars list 
		(
			 if (findString obj.objNodeName (glSpriteTool2.invalidChars)[i]) != undefined then (validAnimCA = false)
		)	
		for i = 1 to (glSpriteTool2.invalidChars).count do 				-- Checks if the animation the invalidChars list 
		(
			 if (findString obj.animationName (glSpriteTool2.invalidChars)[i]) != undefined then (validAnimCA = false)
		)
		if (obj.startFrame < 0)  then (validAnimCA = false)
		if (obj.startFrame > obj.endFrame) then (validAnimCA = false)
		if ((obj.animObjects).count == 0) then (validAnimCA = false) 
		try
		(	
			if (obj.nthFrameRender < 1) then (validAnimCA = false)
		)
		catch()
	)
	else
	(
		validAnimCA = false

	)
	
	return validAnimCA
)
hasValidAnimNodeCA = undefined

glSpriteTool2.hasValidStaticNodeCA = fn hasValidStaticNodeCA obj =
(
	validStaticCA = true
	if (glSpriteTool2.hasAnimNodeCA obj) then
	(
		if not obj.renderEnabled then (validStaticCA = false)	-- If render enabled, then it is not a static object, avoids hasValidAnimNodeCA and 
		if obj.isAnimating then (validStaticCA = false)			-- hasValidStaticNodeCA both returning true		
		if obj.objNodeName == undefined then (validStaticCA = false)
		if obj.objNodeName == "" then (validStaticCA = false)		
		
		for i = 1 to (glSpriteTool2.invalidChars).count do 				-- Checks if the objNodeName against the invalidChars list 
		(
			 if (findString obj.objNodeName (glSpriteTool2.invalidChars)[i]) != undefined then (validAnimCA = false)
		)	
		
		if ((obj.animObjects).count == 0) then (validStaticCA = false)
	)
	else (validStaticCA = false)
	
	return validStaticCA
)
hasValidStaticNodeCA = undefined


print "Done."