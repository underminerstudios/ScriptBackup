--Edited by norman.schaar@gameloft.com


-- 
--	Export game objects 
-- 
--  
--  Global declaration
--  

global GLLive3D_ExportName=""
global GLLive3D_CurrentEnvId="Undefined"
global GLLive3D_ConfigName=""
global GLLive3D_ConfigFile=""

----------------------------------------------------------------------
--
-- scriptInit : init postSceneLoad callback
--
----------------------------------------------------------------------
function scriptInit =
(
	--remove previous callback if still here
	callbacks.removeScripts id:#gllive3dRefreshEnvId
	
	--reassign the doInit() call to filePostOpenProcess callback
	callbacks.addScript #filePostOpenProcess "doInit()" id:#gllive3dRefreshEnvId
)

----------------------------------------------------------------------
--
-- fake definitions to avoid loading errors
--
----------------------------------------------------------------------
function findEnvId silent = ( return false )
function exportBDAE selected = ()
function doExportEnvironment = ()

----------------------------------------------------------------------
--
-- Utility rollouts
--
----------------------------------------------------------------------
scriptInit()

utility GLLive3D_ExportUtility "GLLive3D - Export Environment"
(
	
	edittext GLLive3D_EndIdLbl "EnvId : " text:GLLive3D_CurrentEnvId readOnly:true
		
	-- export all the scene
	button exportScene "Export Scene"
	on exportScene pressed do
	(
		envIdIsOk = findEnvId false
		if( envIdIsOk ) then
		(		
			exportBDAE false
			doExportEnvironment()
		)
	)
	
	-- export selected
	button exportSelected "Export Selected"
	on exportSelected pressed do
	(
		envIdIsOk = findEnvId false
		if( envIdIsOk ) then
		(	
			exportBDAE true
			doExportEnvironment()
		)
	)
)


----------------------------------------------------------------------
--
-- remove_endline : replace ';' endline character by whitespace ' '
--
----------------------------------------------------------------------
function remove_endline stringin = 
(
	r = stringin.count
	for i = 1 to r do
	(
		if stringin[i] == ";" then
		(
			stringin = replace stringin i 1 " "
		)
	)
	return stringin
)

----------------------------------------------------------------------
--
-- getPropValue : retrieve
--
----------------------------------------------------------------------
function getPropValue stringin = 
(
	paramValue=""
	r = stringin.count
	startCopyIndex=r
	for i = 1 to r do
	(
		if stringin[i] == "=" then
		(
			startCopyIndex = i+1
		)
		
		if(i >= startCopyIndex) do
		(
			paramValue = paramValue + stringin[i]
		)
	)
	
	return paramValue
)

function retrieveEndId stringin =
(
	idPos = findString stringin "id="
	format "retrive Pos = %" idPos
	
)

----------------------------------------------------------------------
--
-- exportBDAE
--
----------------------------------------------------------------------
function exportBDAE selected =
(
	GLLive3D_ExportName = getSaveFileName caption:"BDAE Export" types:"bdae file (*.bdae)|*.bdae|All Files (*.*)|*.*|"

	if GLLive3D_ExportName != undefined then
	(
		-- avoid to have twice the "are you sure do want to overwrite?" message
		if doesFileExist GLLive3D_ExportName then
		(
			deleteFile GLLive3D_ExportName
		)
		
		--yet we assume that Glitch_COLLADA_Exporter is installed
		exportFile GLLive3D_ExportName selectedOnly:selected using:Glitch_COLLADA_Exporter
		
		if doesFileExist GLLive3D_ExportName then
		(
			print "Export successfully done!"
		)
	)
	-- else User cancelled
)

----------------------------------------------------------------------
--
-- findEnvId : Look in AvatarSlot001 User Property and check for EnvId prop
--
----------------------------------------------------------------------
function findEnvId silent=
(
	sel = helpers as array
	
	for obj in sel do
	(
		if matchPattern obj.name pattern:"AvatarSlot001" then
		(
			ObjProperties = remove_endline (getUserPropBuffer obj)
			parseValue = ObjProperties as stringstream
			
			while peekToken parseValue  != undefined do
			(
				local prop = readToken parseValue
				if matchPattern prop pattern:"EnvId*" then
				(
					GLLive3D_CurrentEnvId = getPropValue prop
					return true
				)
			)
			
			if not silent then
			(
				warningStream = "" as stringstream
				format "You must add in User property of % the property :\n\"EnvId=XXXX\"\nXXXX representing 4 letter unique Id for your Environment." obj.name to:warningStream
				
				warningMsg = warningStream as string
				messageBox warningMsg title:"Missing EnvId"
			)
			return false
		)		
	)
	return false
)

----------------------------------------------------------------------
--
-- doInit : call at the loading of the script
--
----------------------------------------------------------------------
function doInit =
(
	-- init GLLive3D_CurrentEnvId by looking for envId in the current scene	
	GLLive3D_CurrentEnvId="Undefined"
	findEnvId true --do it silently, do not display message if we find nothing
	GLLive3D_ExportUtility.controls[1] .text = GLLive3D_CurrentEnvId
)

----------------------------------------------------------------------
--
-- resolveConfigName : Set, if export went well, proper config file name in GLLive3D_ConfigName
--
----------------------------------------------------------------------
function resolveConfigName =
(
	if GLLive3D_ExportName == undefined then
		return false --something went wrong during export
	
	format "Exported file : %\n" GLLive3D_ExportName
	-- don't bother create the config file if export did not go well
	if doesFileExist GLLive3D_ExportName then
	(
		GLLive3D_ConfigName = substituteString GLLive3D_ExportName ".bdae" ".xml"
		format "Name of configuration file : %\n" GLLive3D_ConfigName
		return true
	)
	else
	(
		format "% does not exists!" GLLive3D_ExportName
	)
	return false
)

----------------------------------------------------------------------
--
-- doExportEnvironment
--
----------------------------------------------------------------------
function doExportEnvironment =
(
	local thePath = pathConfig.removePathLeaf(getSourceFileName()) + "\\ExportedTypes.txt" --Relative path to txt file EDIT BY: norman.schaar@gameloft.com
	objectNames = (dotnetClass "System.IO.File").ReadAllLines thePath --Puts all the lines to an array EDIT BY: norman.schaar@gameloft.com
	
	canContinue = resolveConfigName()
	if canContinue then
	(
		format "try to open %\n" GLLive3D_ConfigName
		if (doesFileExist GLLive3D_ConfigName) then
		(
			GLLive3D_ConfigFile = openFile GLLive3D_ConfigName mode:"w+"
		)
		else
		(
			GLLive3D_ConfigFile = createFile GLLive3D_ConfigName
		)
		
		-- xml header
		format "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" to:GLLive3D_ConfigFile
		
		stringFilename = filenameFromPath GLLive3D_ExportName
		format "<environment id=\"%\" file=\"%\">\n" GLLive3D_CurrentEnvId stringFilename to:GLLive3D_ConfigFile 
		
		-- select dummies
		sel = helpers as array
		-- sel = geometry as array
	
		object_count = #()
		object_count.count = objectNames.count
		for i = 1 to objectNames.count do
		(
			object_count[i] = 0
		)		
		
		-- join sel sel2
		for obj in sel do
		(
			for i = 1 to objectNames.count do
			(
				objectName = objectNames[i]
				-- check if the object name fit our predefinites
				if( matchPattern obj.name pattern:(objectName+"*") ) do
				(
					format "dummy % match pattern %\n" obj.name objectName
					object_count[i] = object_count[i] + 1
					objectType = objectName
					soundParamValue=""

					-- parse user properties to get values we want
					ObjProperties = remove_endline (getUserPropBuffer obj)
					parseValue = ObjProperties as stringstream
					parsedToken = #() --set it up to empty array
					while peekToken parseValue  != undefined do
					(
						readValue = readToken parseValue
						append parsedToken readValue 
					)
					numLines = parsedToken.count
					
					----------------------------------------------------------------------
					-- check Sound Paramter Value
					for subIndex = 1 to numLines do
					(
						if( matchPattern parsedToken[subIndex] pattern:"Sound*" ) do
						(
							soundParamValue = getPropValue (parsedToken[subIndex])
							format "- Sound parameter defined (%) for dummy %" soundParamValue obj.name
						)
					)
					
					format "\t<% name=\"%\" sound=\"%\"/>\n" objectType obj.name soundParamValue to:GLLive3D_ConfigFile
					----------------------------------------------------------------------
				)
			)
		)
		
		-- close environment Tag
		format "</environment>\n" to:GLLive3D_ConfigFile
		close GLLive3D_ConfigFile
		
		-- put export report at the end
		message = stringStream ""
		format "Done!!\n\n" count output_name to:message
		format "Report:\n" count output_name to:message
		format "------------\n" count output_name to:message
		for i = 1 to objectNames.count do
		(
			if(object_count[i] > 0) do
			(
				format "% : %\n" objectNames[i] object_count[i] to:message
				object_count[i] = 0
			)
		)		
		messageBox message title:"Environement Export"
	)
	else
	(
		print "Export aborted...\n"
	)
)

