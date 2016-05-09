try(destroyDialog DLG_REFLECTION_TUNNEL)catch()
rollout DLG_REFLECTION_TUNNEL "Compose Reflection Tunnel Texture"
(
	edittext et_path "Path:" labelontop:true readonly:true
	button btn_browse "Browse" width:270
	
	button btn_Compose "Compose" enabled:false
	
	on btn_browse pressed do
	(
		local savePath = getSavePath caption:"Pick Folder where frames are located" initialDir:maxfilepath
		if savePath != undefined do
		(
			et_path.text = savePath
			btn_Compose.enabled = true
		)
	)
	on btn_Compose pressed do
	(
		if et_path.text != "" do
		(
			local thePixels = #()

			local theFiles = getFiles (et_path.text + "\\*.tga")
			
			local subDiv = (theFiles.count / 4)
			
			local theCountArray = #(subDiv,subDiv*2,subDiv*3,subDiv*4)
			
			for i=1 to subDiv do
			(
				local theImages = #()
				local theImage01 = i
				local theImage02 = i + 1024
				local theImage03 = i + 2048
				local theImage04 = i + 3072
				append theImages theImage01
				append theImages theImage02
				append theImages theImage03
				append theImages theImage04
				
				local PixelsCollection = #()
				
				for n in theImages do
				(
					local theBitmap = openBitMap (theFiles[n])
					local pixels = getPixels theBitmap [0,0] 256
					for m in pixels do
						append PixelsCollection m
					close theBitmap
				)
				append thePixels PixelsCollection
			)
			
			local theOutputBitmap = bitmap 1024 thePixels.count color:(color 0 0 0)
			
			for i=1 to thePixels.count do
			(
				setPixels theOutputBitmap [0, i-1] thePixels[i]
			)
			display theOutputBitmap
		)
	)
)
createDialog DLG_REFLECTION_TUNNEL width:300