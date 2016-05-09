-- Adjusts the current filename and all of the render passes to the 
-- name of the last folder
-- eg.  C:\MyGame\MyObject\Log\ -> C:\MyGame\MyObject\Log\Log_Specular.tga, C:\MyGame\MyObject\Log\Log_Diffuse.tga
(
	
	rollout InfoRollout "Render Pass Setup" width:472 height:104
	(
		--label lbl1 "Render Pass Name:" pos:[8,8] width:136 height:16
		--edittext edtName "" pos:[8,32] width:144 height:16
		edittext edtFolder "" pos:[8,32] width:432 height:16
		label lbl2 "Render(s) Folder:" pos:[8,8] width:96 height:16
		button btnFolder "..." pos:[440,32] width:24 height:16
		button BTNOK "OK" pos:[328,64] width:65 height:24
		button BTNCANCEL "Cancel" pos:[400,64] width:64 height:24
	
		fn SetRenderElements fold filename =
		(
			mgr = MaxOps.GetCurRenderElementMgr()
			count = mgr.NumRenderElements()
			
			for i = 0 to count - 1 do
			(
				element = mgr.GetRenderElement i
				print (mgr.GetRenderElementFilename i)
				print (element.elementName)
				mgr.SetRenderElementFilename i (fold + "\\" + filename + "_" + element.elementName + ".tga")
			)
		)
		
		fn SetupPass =
		(
			if edtFolder.text == "" then
			(
				return ""
			)
			
			-- Set the filename to the last sub folder name.
			pathParts = filterString edtFolder.text "\\"
			filename = pathParts[pathParts.count]
			
			fullPath = edtFolder.text + "\\" + filename + ".tga"
			renderSceneDialog.close()
			rendOutputFilename = fullPath
			SetRenderElements edtFolder.text filename
			renderSceneDialog.open()
		)
		
		
		
		
		on InfoRollout open do
		(
			edtFolder.text = "P:\\Environments\\Plots\\Military\\DewDropDojo P012\\Wip\\Render\\Stage2LillyPadFlower"
		)
		on btnFolder pressed do
		(
			result = getSavePath caption:"Render Folder" initialDir:edtFolder.text --(getDir #maxroot)
			if result == null then
			(
				edtFolder.text = ""
				return ""
			)
			
			edtFolder.text = result
		)
		on BTNOK pressed do
		(
			SetupPass()
			DestroyDialog InfoRollout
		)
		on BTNCANCEL pressed do
		(
			DestroyDialog InfoRollout
		)
	)
	
	fn SetRenderPass =
	(
		CreateDialog InfoRollout escapeEnable:true modal:true
	)

	SetRenderPass()
)