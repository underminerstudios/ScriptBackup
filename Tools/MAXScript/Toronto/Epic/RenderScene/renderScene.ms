(
	global glSpriteTool2
	
	clearListener()
	DEPOT_PATH = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	libDir = (DEPOT_PATH + "MAXScript\\Toronto\\_MAXScriptFunctions\\LibGLSpriteTools\\LibGLSpriteTools.ms")
	fileIn libDir

	try(DestroyDialog renderSceneSetup)catch()
	try(DestroyDialog warningDialog)catch()
	glSpriteTool2.init ()
	struct sceneVars
	(
		renderScene, renderOutPath, doesRender, doesExport 
	)
	
	renderSceneVars = sceneVars()	
	
	-- Change this to whatever you need
	-- will be fixed in next version to use glSpriteTool2.catagories in a drop down box
	catagoryName = "tempfile"

	
	
	fn selectMultipleScenes = 
	(
		--
		-- http://www.scriptspot.com/bobo/mxs9/dotNet/OpenFileDialog.html
		-- Bobo's dotNet select multiple files 
		--
		theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog
		theDialog.title = "PLEASE Select One Or More Files" --set the title
		theDialog.Multiselect = true --allow multiple files to be selected
		theDialog.Filter = "Max Files (*.max)|*.max" --specify the filter
		theDialog.FilterIndex = 2 --set the filter drop-down list to All Files
		theDialog.InitialDirectory = glSpriteTool2.baseArtDirectory
		result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		theFilenames = theDialog.fileNames --the selected filenames will be returned as an array	
		return theFilenames
	)
	
	fn renderStuff =
	(	
		StartTime = timeStamp()

		renderOutSize = (glSpriteTool2.pixelPerUnit * glSpriteTool2.tileSize)
		
		glSpriteTool2.fileLog = true
		glSpriteTool2.showVFB = true
		glSpriteTool2.printLog ("\n")
		glSpriteTool2.printLog ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" + "\n")		
		glSpriteTool2.printLog (localTime + "\n")
		glSpriteTool2.printLog ("Loading Master Scene: " + glSpriteTool2.masterScene + "\n")
				
		loadMaxFile glSpriteTool2.masterScene -- Loads the master scene
		max select all
		masterSceneObj = selection as array
	
		if glSpriteTool2.hasRootNodeCA() then
		(
			undo off
			with redraw off
			glSpriteTool2.printLog ("Loaded Master Scene Ok" + "\n")
		
			r = 1
			--for r = 1 to renderSceneVars.renderScene.count do 
			(
				glSpriteTool2.printLog ("merging " + (r as string) + "of" + " " + (renderSceneVars.renderScene.count as string) + " : " + renderSceneVars.renderScene[r] + "...")
				mergeMaxFile renderSceneVars.renderScene[r] #noRedraw #AutoRenameDups #useMergedMtlDups #select -- merge in the object max file
				
				glSpriteTool2.printLog ("Done" + "\n")
				
				nodeObj = #()
				staticNodeObj = #()
				animNodeObj = #()
								
				for h in helpers do 
				(	
					if (glSpriteTool2.hasAnimNodeCA h) then
					(
						append nodeObj h 
					)
				)	
				
				--**** checks if the animNodeAttributesCA is the latest version and updates it if not ****
				--print ("U: " + u as string)
				--print ("Trying " + u.glstVersion as string)-- + " < " + glSpriteTool2.animUIVersion as string)
				--try
				--(
					
				--	if u.glstVersion < glSpriteTool2.animUIVersion then
				--	(
				--		glSpriteTool2.updateAnimNode u
				--	)
				--)
				--catch
				--(
				--	print "Catch!"
				--	glSpriteTool2.updateAnimNode u
				--)
				
				for n in nodeObj do 
				(
					if (glSpriteTool2.hasValidStaticNodeCA n) then
					(
						append staticNodeObj n
					)
					if (glSpriteTool2.hasValidAnimNodeCA n) then
					(
						append animNodeObj n
					)
				)
				
				--***************************************
				--***** Renders Static Objects *****
				--***************************************
				
				
				if staticNodeObj.count > 0 then
				(
					for j in staticNodeObj do
					(
						for all in objects do (all.isHidden = true)
						for c in (j.animObjects) do (c.isHidden = false)
						for l in selection where superclassof l == light do l.on = false		-- disables any lights in the merged scene
						if j.useMSmatteShadow then (rootnode.masterShadowCatcher.isHidden = false)
						
						newObj = Dummy pos:j.pos
						for obj in j.animObjects do (obj.parent = newObj)
						newObj.pos = [0,0,0]
						delete newObj
												
						glSpriteTool2.printLog ("rendering static object :" + j.objNodeName)
						--Render Pass here
						glSpriteTool2.renderPass (renderSceneVars.renderOutPath + "\\") (glSpriteTool2.projectNamePrefix + "_" + catagoryName + "_" + j.objNodeName) renderOutSize					
						glSpriteTool2.printLog (" ...Done" + "\n")					
					)
				)
				else
				(
					glSpriteTool2.printLog ("No Static node objects found, skipping" + "\n")
				)
				
				--*******************************************
				--***** Renders Animated Objects *****
				--*******************************************
				
				if animNodeObj.count > 0 then
				(
					for j in animNodeObj do
					(
						for all in objects do (all.isHidden = true)
						for c in j.animObjects do (c.isHidden = false) 									
						for l in selection where superclassof l == light do l.on = false		-- disables any lights in the merged scene
						if j.useMSmatteShadow then (rootnode.masterShadowCatcher.isHidden = false)	
						
						glSpriteTool2.printLog ("rendering :" + j.objNodeName + "animation : " + j.animationName + "\n")

						for k = j.startFrame to j.endFrame by j.nthFrameRender do 
						(
							sliderTime = k
							frameNum = k as String
							if frameNum.count == 1 then (frameNum = ("00" + (k as String)))
							if frameNum.count == 2 then (frameNum = ("0" + (k as String)))	
								
							glSpriteTool2.printLog ("rendering frame: " + frameNum + ". Of : " + j.animationName + "\n")
							glSpriteTool2.printLog ("rendering:")
							
							--Render Pass here									
							glSpriteTool2.renderPass (renderSceneVars.renderOutPath + "\\") (glSpriteTool2.projectNamePrefix + "_" + catagoryName + "_" + j.objNodeName + "_" + j.animationName + "_f" + frameNum) renderOutSize							
							glSpriteTool2.printLog (renderSceneVars.renderOutPath + "\\" + glSpriteTool2.projectNamePrefix + "_" + catagoryName + "_" + j.objNodeName + "_" + j.animationName + "_f" + frameNum + " ...Done" + "\n")

						)	
					)				
				)
				else
				(
					glSpriteTool2.printLog ("No Animated node objects found in \n")
				)
								
				sliderTime = 1

				-- deletes all merged objects at the end
				for o in objects do 
				(
					o.isHidden = false
					o.isFrozen = false					
				)
				select masterSceneObj
				max select invert
				
				if selection.count > 0 then 
				(
					glSpriteTool2.printLog ("Deleting old junk from this scene \n")
					delete $
				)				
			)
			EndTime = timeStamp() 
			
			totalTime = (EndTime - StartTime)
				
			totalHours = floor (totalTime / 3600000)
			totalMinutes = floor ((totalTime - (totalHours *  3600000)) / 60000)
			totalSeconds = floor (totalTime - ((totalHours *  3600000) + (totalMinutes * 60000))) / 1000
			
			glSpriteTool2.printLog ("Completed in :  " + "\n")		
			glSpriteTool2.printLog ((totalHours as string) + " hours" + "\n")	
			glSpriteTool2.printLog ((totalMinutes as string) + " minutes" + "\n")
			glSpriteTool2.printLog ((totalSeconds as string) + " seconds" + "\n")
			
			loadMaxFile renderSceneVars.renderScene[1]
		)	
		else 
		(
			glSpriteTool2.printLog ("Loaded Master Scene Failed. No scene attributes found" + "\n")
		)
	)
				
				
	
	/***** Render Scene Dialog *****/
	rollout renderSceneSetup "Render Scene" width:145 height:100
	(		
		checkbox chkExport "Export" pos:[5,65] width:205 height:17 visible:false
		checkbox chk2 "Render" pos:[5,45] width:205 height:17 visible:false
		
		button btnCurrent "Current Scene" pos:[5,5] width:135 height:17 
		button btnSelect "Select Scene" pos:[5,25] width:135 height:17
		
		dropdownlist selectObjCatagory "Sprite Catagory:" pos:[5,45] width:135 items:glSpriteTool2.catagories
		
		on btnCurrent pressed do 
		(
			if maxfilename != "" then
			(	
				renderSceneVars.renderScene = #()
				catagoryName = selectObjCatagory.selected
				append renderSceneVars.renderScene (maxfilepath + maxFileName)
				renderSceneVars.doesRender = true
				renderSceneVars.doesExport = true
				
--				DestroyDialog renderSceneSetup
				CreateDialog warningDialog
			)
			else
			(
				messageBox "Max scene has no filename. Please save the scene before rendering"
			)
		)
		
		on btnSelect pressed do 
		(
			--renderSceneVars.renderScene = getOpenFileName caption:"Select file to render" types:"max files(*.max)"
			
			catagoryName = selectObjCatagory.selected
			renderSceneVars.renderScene = selectMultipleScenes()
			if renderSceneVars.renderScene != undefined then
			(
				renderSceneVars.doesRender = true
				renderSceneVars.doesExport = true				
				DestroyDialog renderSceneSetup
				CreateDialog warningDialog	
			)
		)	
	)
	
	
	
	rollout warningDialog "Warning!" width:250 height:80
	(
		label lbl1 "Warning, this will close the current scene."
		label lbl2 "Make sure your work is saved before continuing"
		
		button buttonOk "Save & Continue" pos:[5,50] width:115 height:17
		button buttonCancel "Cancel" pos:[125,50] width:115 height:17
		
		on buttonCancel pressed do 
		(
			DestroyDialog warningDialog			
		)
		
		on buttonOk pressed do 
		(
			saveMaxFile (maxfilepath + maxfilename)
			
			renderSceneVars.renderOutPath = getSavePath caption:"Select render output path"
			if renderSceneVars.renderOutPath != undefined then
			(
				DestroyDialog warningDialog	
				--print  renderSceneVars.renderScene
				--print  renderSceneVars.renderScene.count
				--print catagoryName
				if renderSceneVars.renderScene.count > 0 then
				(
					renderStuff()
				)
			)
		)		
	)	
	
	CreateDialog renderSceneSetup	
)