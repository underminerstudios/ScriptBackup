-- Batch render layers

/*
How to:
-Disable the "Enable built-in Frame Buffer" checkbox if you are using Vray
-Run the script
-Select an output folder

		(NOTE: The script will ask the user to make sure he disabled the "Enable built-in Frame Buffer" checkbox, since it can't be turned off through maxscript)

		--Run the following if you want to check the vray properties available to maxscript
		vr = renderers.current
		showProperties vr

Some details:
- Layer 0 is always visible when rendering.
- You need a camera in layer0. Free or Target.
- If the layer is frozen it will not be rendered.
- If the radiosity button is turned ON in the layer, the node in Layer0 called GRID will be visible, (in case such a node exists). If it's off the node will be invisible.
- A progress bar in the status panel will show the overall progress. Don't click on the "Cancel" button since it will break the script.
- Each layer needs atleast a dummy called "Pos01"
- Additional dummies need to be called "Pos*". Examples: "Pos2, Pos3, Pos98". The TGAs will be rendered with the following suffixes "_2" , "_3",  "_98".
- If additional dummies are found, the "Pos01" one will be moved to their position and an additional render will be taken. The Pos01 suffix will then be moved back to its original position.
- The visibility of the layers is irrelevant. All will be hidden except "Layer 0". Their visibility will be restored to it's original setting once the script has finished.
- There is no way of cancelling the script. You have to wait for the script to finish or kill the 3dsmax process. I recommend to save before running it.

Messages that will be displayed in the MaxScript Listener:
-WARNING: If the PSD file already exists. (it will be saved with the suffix "_NEW.tga", if the "_NEW.tga" file also exists it will be overwritten)
-ERROR: If the render was successful but the output file hasn't been written to the disk for whatever reason.
-ERROR: If no dummy is found in the layer

Messages that are commented out, that _won't_ appear in MaxScript Listener.
-How many dummies are found in each layer.
-What dummy is being rendered
-If the render was successful
-If the file was written to disk successfully
*/
-- by Norman Schaar - norman.schaar@gameloft.com


--We define the function
fn render_layers theCamera =
(
	--This is the initial dir for the prompt. If it's undefined the 3dsmax file path will be used
	if GL_initialdir == undefined do (GL_initialdir = maxFilePath)

	--Launch the prompt
	thePath = getsavepath initialdir:(GL_initialdir) caption:"Selecet Output Folder"
	if thePath != undefined do
	(
		--Put the path in a global variable, so next time the script is run it will use that path as the initial dir
		global GL_initialdir = thePath
		
		--Find the grid node
		(LayerManager.getLayer 0).nodes &thenodes0
		theGrid = for n in thenodes0 where (n.name == "GRID") do exit with n
		
		--First create an Array with all the on/off layers
		LayerManagerOnOff =#()
		for i=1 to (LayerManager.count - 1) do (append LayerManagerOnOff ((LayerManager.getLayer i).on))


		--Now let's hide everything but layer 0
		for i=1 to (LayerManager.count - 1) do
		(
			((LayerManager.getLayer i).on) = false
		)

		--Now we can start the process
		progressStart "Rendering Layers..."
		
		for i=1 to (LayerManager.count - 1) do
		(
			progressUpdate (100.0*i/(LayerManager.count - 1))
			--Only if the layer is frozen we do the rendering
			if ((LayerManager.getLayer i).isfrozen) == false do
			(
				((LayerManager.getLayer i).on) = true --Make it visible
				
				--Check the Radisoity button and hide/un-hide the grid
				if theGrid != undefined do
				(
					if ((LayerManager.getLayer i).isGIExcluded) == true then
					(
						hide theGrid
					)
					else
					(
						unhide theGrid
					)
				)
				
				--Get dummies in layers
				theDummies =#()
				
				(LayerManager.getLayer i).nodes &thenodes
				--First we append all the Dummies called "Pos*"
				--First we append the Pos01 node, so no matter what it's the first in the array
				for n in thenodes do
				(
					if ((n.baseObject as string) == "Dummy") AND (n.name == "Pos01") do
					(
						append theDummies n
					)
				)
				--Now we look for all the other "Pos*" dummies, except "Pos01" of course, and append them as well.
				for n in thenodes do
				(
					if ((n.baseObject as string) == "Dummy") AND (matchpattern n.name pattern: "Pos*") AND (n.name != "Pos01") do
					(
						append theDummies n
					)
				)
				
				
				--If no dummies found throw an error
				if theDummies.count == 0 then
				(
					print ("WARNING: No dummy found in " + (LayerManager.getLayer i).name)
				)
				else --Keep going
				(
					--Run render of first dummy theDummies[1]
					
					--Print Info
					--print ("INFO: Found " + (theDummies.count as string) + " Dummy in " + "\"" + (LayerManager.getLayer i).name) + " Layer."
					--print ("INFO: Rendering Layer: " + (LayerManager.getLayer i).name + " Rendering " + "1/" + (theDummies.count as string))
					--TEST BEGIN

					--Save transform of first dummy
					theOriginalDummyTransform = (theDummies[1]).transform
						
					for j=1 to theDummies.count do
					(
						theSuffix = (filterstring (theDummies[j]).name "Pos")[1]
						--The transformation of the original is aligned to the additional dummies.
						(theDummies[1]).transform = (theDummies[j]).transform
						--Print info
						--print ("INFO: Rendering Layer: " + (LayerManager.getLayer i).name + " Rendering " + (j as string) + "/" + (theDummies.count as string))
						--Checking if file already exists.
						if doesfileexist (thePath + "\\" + (LayerManager.getLayer i).name + "_" + theSuffix + ".psd") then
						(
							--Yes it already exists, it will be saved under the "_NEW" suffix
							--Print a warning
							print ("WARNING: File " + ((LayerManager.getLayer i).name + "_" + theSuffix + ".psd") +" already exists! A new file with suffix " + "\"" + "_NEW.tga" + "\"" + " will be created.")
							--render
							render camera:theCamera outputFile:(thePath + "\\" + (LayerManager.getLayer i).name + "_" + theSuffix + "_NEW.tga") vfb:off
							--Verify that output file was written to disk
							if doesfileexist (thePath + "\\" + (LayerManager.getLayer i).name + "_" + theSuffix + "_NEW.tga") then
							(
								--It was successfully written to disk
								--print ("INFO: Rendering Layer: " + (LayerManager.getLayer i).name + " Rendering " + (j as string) + "/" + (theDummies.count as string) + " DONE!")
							)
							else
							(
								--Error it wasn't written to disk
								print ("ERROR: File " + ((LayerManager.getLayer i).name + "_" + theSuffix + "_NEW.tga") + " WAS NOT WRITTEN TO DISK!")
							)
						)
						else
						(
							--No the file doesn't exist yet. Go ahead and render.
							render camera:theCamera outputFile:(thePath + "\\" + (LayerManager.getLayer i).name + "_" + theSuffix + ".tga") vfb:off
							--Verify that output file was written to disk
							if doesfileexist (thePath + "\\" + (LayerManager.getLayer i).name + "_" + theSuffix + ".tga") then
							(
								--It was successfully written to disk
								--print ("INFO: Rendering Layer: " + (LayerManager.getLayer i).name + " Rendering " + (j as string) + "/" + (theDummies.count as string) + " DONE!")
							)
							else
							(
								--Error it wasn't written to disk
								print ("ERROR: File " + ((LayerManager.getLayer i).name + "_" + theSuffix + ".tga") + " WAS NOT WRITTEN TO DISK!")
							)
						)
						(theDummies[1]).transform = theOriginalDummyTransform	--Restore dummy to original transform
					)

					
					--TEST END

				)
				--Make it invisible again so that it doesn't interfer with the next layer.
				((LayerManager.getLayer i).on) = false
				--We also make the grid visible again
				if theGrid != undefined do
				(
					unhide theGrid
				)
			)
		)

		--Restore the layer visibility
		for i=1 to (LayerManager.count - 1) do
		(
			((LayerManager.getLayer i).on) = LayerManagerOnOff[i]
		)
		
		progressEnd()
	)
)


--First we check if a camera is selected. Needs to be the only selection
(LayerManager.getLayer 0).nodes &thenodes0
theCamera = for n in thenodes0 where matchpattern (n.baseObject as string) pattern:"*Camera*" do exit with n

if theCamera != undefined then
(
	--Here we are checking for vray. We need to ask the user if he disabled the Vray VFB. We can't disable it through maxscript.
	if matchpattern (renderers.current as string) pattern:"*v*ray*" then
	(
		if queryBox ("You are using V-Ray! Have you disabled the " + "\"" + "Enable built-in Frame Buffer" + "\"" + " checkbox? If not, please do.") == true then
		(
			targa.setCompressed true
			render_layers theCamera
			messagebox "Done!"
		)
		else
		(
			renderSceneDialog.open()
		)
	)
	else
	(
		render_layers theCamera
		messagebox "Done!"
	)
)
else
(
	messagebox "No camera in layer 0! You need one in order for the script to run"
)