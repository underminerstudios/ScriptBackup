

try(destroyDialog prop_library)catch()
rollout prop_library "Prop Library"
(
	dropdownlist ddl_folders width:600 pos:[0,0]
	edittext et_search "Search:" --pos:[0,0] wid
	dotNetControl lv "System.Windows.Forms.ListView" width:600 height:310 pos:[0,90]
	button btn_merge "Merge selected" width:100 height:40 pos:[0,50]
	button btn_xref "Xref Selected" width:100 height:40 pos:[100,50]
	checkbox cb_lod1 "LOD1" pos:[210,50] checked:true
	checkbox cb_lod2 "LOD2" pos:[210,70]
	checkbox cb_lod3 "LOD3" pos:[270,50]
	checkbox cb_lod4 "LOD4" pos:[270,70]
	
	fn getFoldersRecursive root =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
		join dir_array (GetDirectories (d+"/*"))
		append dir_array root
		dir_array
	)
	
	fn fillLv string thePath=
	(
		lv.View = (dotNetClass "System.Windows.Forms.View").LargeIcon
		lv.Scrollable = true
		lv.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 22 22 22
		lv.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 117 117 117
		lv.Clear()
		lv.items.Clear()	
		lv.Refresh()
		
		local imageList = dotnetobject "System.Windows.Forms.ImageList"
		imageList.images.Clear()
		imageList.Dispose()
		imageList.imagesize =  dotnetobject "System.Drawing.Size" 128 128
		imageList.ColorDepth = imageList.ColorDepth.Depth32Bit
		
		local thumbs = #()
		local items = #()
  			
		local SubFolders = getFoldersRecursive (thePath + "\\")

 		for s = 1 to SubFolders.count do
 		(
			for f in getFiles (SubFolders[s] + "\\*.png") where (findstring f ".max_") != undefined do
			(
				append thumbs ((dotNetClass "System.Drawing.Image").fromFile f)
				
				local THEFILE = filenameFromPath f
				local maxStart = findstring THEFILE ".max_"
				local MaxFile = pathconfig.normalizepath (SubFolders[s] + "\\" + (substring THEFILE 1 (maxStart + 3)))
				local ObjectName = substitutestring (substring THEFILE (maxStart + 5) (-1)) ".png" ""
				if (matchpattern SubFolders[s] pattern:("*" + string + "*")) do
				(
					local item = dotNetObject "System.Windows.Forms.ListViewItem" ObjectName
					if doesFileExist maxFile then
					(
						item.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 88 153 81
					)
					else
					(
						item.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 153 81 81
					)
					item.name = SubFolders[s]
					item.imageIndex = thumbs.count - 1
					lv.items.add item
					item.SubItems.add maxFile
				)
			)
 		)
		
 		imageList.images.addrange thumbs
 		lv.LargeImageList = imageList
		
 		for t in thumbs do t.dispose()
		local LV_DLG = for n in (windows.getChildrenhwnd 0) where n[4]=="MAXScriptDialog" AND n[5]==prop_library.title do exit with n[1]
		for n in (windows.getChildrenhwnd LV_DLG) where matchpattern n[4] pattern:"*SysListView32*" do (Windows.sendMessage n[1] (LVM_SETICONSPACING = 0x00001035) (wParam = 0x00000000) (lparam = 0x00990080))
	)
	
	on ddl_folders selected arg do
	(
		fillLv et_search.text ddl_folders.selected
	)
	
	on prop_library open do
	(
		if GLB_GL_PROP_LIBRARY_PATHS != undefined do
		(
			ddl_folders.items = GLB_GL_PROP_LIBRARY_PATHS
		)
		
		if ddl_folders.items.count != 0 do
		(
			fillLv "" ddl_folders.selected
		)
	)
	
	on et_search changed arg do
	(
		if ddl_folders.items.count != 0 do
		(
			fillLv arg ddl_folders.selected
		)
	)
	
	on prop_library resized theSize do
	(
		lv.width = theSize[1]
		lv.height = theSize[2] - 90
	)
	
	on btn_merge pressed do
	(
		local getSelection = for x=0 to lv.selectedIndices.count-1 collect lv.selectedIndices.item[x]
		local MaxFiles = for n in getSelection collect lv.Items.Item[n].SubItems.Item[1].Text
		local ObjectNames = for n in getSelection collect lv.Items.Item[n].SubItems.Item[0].Text
		local selectionArray = #()
		for i=1 to MaxFiles.count do
		(
			local LODCheck = filterstring ObjectNames[i] "_"
			if LODCheck[LODCheck.count] == "LOD1" then
			(
				local theObjects = getMAXFileObjectNames MaxFiles[i] quiet:true
				for n in theObjects do
				(
					if cb_lod1.state == true do
					(
						if n == ObjectNames[i] do
						(
							mergeMaxFile MaxFiles[i] #(ObjectNames[i]) #prompt #select #noRedraw #promptDups #promptMtlDups #promptReparent 
						)
					)
					if cb_lod2.state == true do
					(
						local theName = substitutestring ObjectNames[i] "_LOD1" "_LOD2"
						if n == theName do
						(
							mergeMaxFile MaxFiles[i] #(theName) #prompt #select #noRedraw #promptDups #promptMtlDups #promptReparent 
						)
						
					)
					if cb_lod3.state == true do
					(
						local theName = substitutestring ObjectNames[i] "_LOD1" "_LOD3"
						if n == theName do
						(
							mergeMaxFile MaxFiles[i] #(theName) #prompt #select #noRedraw #promptDups #promptMtlDups #promptReparent 
						)
					)
					if cb_lod4.state == true do
					(
						local theName = substitutestring ObjectNames[i] "_LOD1" "_LOD4"
						if n == theName do
						(
							mergeMaxFile MaxFiles[i] #(theName) #prompt #select #noRedraw #promptDups #promptMtlDups #promptReparent 
						)
					)
				)
			)
			else
			(
				mergeMaxFile MaxFiles[i] #(ObjectNames[i]) #prompt #select #noRedraw #promptDups #promptMtlDups #promptReparent 
				append selectionArray selection[1]
			)
		)
		select selectionArray
	)
	
	on btn_xref pressed do
	(
		local getSelection = for x=0 to lv.selectedIndices.count-1 collect lv.selectedIndices.item[x]
		local MaxFiles = for n in getSelection collect lv.Items.Item[n].SubItems.Item[1].Text
		local ObjectNames = for n in getSelection collect lv.Items.Item[n].SubItems.Item[0].Text
		local selectionArray = #()
		for i=1 to MaxFiles.count do
		(
			objXRefMgr.AddXRefItemsFromFile maxFiles[i] promptObjNames:false objNames:#(ObjectNames[i]) xrefOptions:#(#xrefModifiers,#selectNodes)
			for n in selection do
			(
				if classof n.material == multimaterial then
				(
					for i=1 to n.material.materialList.count do
					(
						if (classof n.material.materialList[i]) == XRef_Material do
						(
							showTextureMap n.material.materialList[i] true
						)
					)
				)
				else
				(
					if classof n.material == XRef_Material do
					(
						showTextureMap n.material true
					)
				)
			)
			append selectionArray selection[1]
		)
		select selectionArray
	)
	
	on lv mouseDown arg do
	(
		local theItem = (lv.getItemAt arg.x arg.y)
		
		if theItem != undefined do
		(
			local MaxFile = theItem.SubItems.Item[1].text
			local ObjectName = theItem.SubItems.Item[0].text
		
			local theArray = #(true,false,false,false)
			local LODCheck = filterstring ObjectName "_"
			if LODCheck[LODCheck.count] == "LOD1" then
			(
				theArray[1] = true
				
				local theObjects = getMAXFileObjectNames MaxFile quiet:true
				for n in theObjects do
				(
					if n==(substitutestring ObjectName "_LOD1" "_LOD2") do
					(
						theArray[2] = true						
					)
					if n==(substitutestring ObjectName "_LOD1" "_LOD3") do
					(
						theArray[3] = true						
					)
					if n==(substitutestring ObjectName "_LOD1" "_LOD4") do
					(
						theArray[4] = true						
					)
				)
			)
			cb_lod1.checked = theArray[1]
			cb_lod2.checked = theArray[2]
			cb_lod3.checked = theArray[3]
			cb_lod4.checked = theArray[4]
		)
	)
	
	on prop_library close do
	(
		--Dispose images in imagelist
		try
		(
			for i=0 to (lv.LargeImageList.Images.count - 1) do
			(
				lv.LargeImageList.Images.Item[i].Dispose()
			)
			lv.LargeImageList.Dispose()
			lv.Dispose()
		)catch()
		--Garbage Collection to unlock bitmaps
		gc light:true
		dgc = dotnetclass "system.gc"
		dgc.collect()
		GLB_GL_PROP_LIBRARY_PATHS = undefined
	)
)
createDialog prop_library width:600 height:400 style:#(#style_resizing,#style_titlebar,#style_sysmenu,#style_maximizebox)