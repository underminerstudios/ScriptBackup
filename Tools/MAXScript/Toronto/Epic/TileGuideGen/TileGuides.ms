(
		Global MasterRollout
--Destroy the dialog if it is already open 
	try(destroyDialog MasterRollout)catch()
	
	--Cleaner
	Clearlistener ()
	GC ()

	
	-----------------------------------------------------------------------------------------------------------------
	--Create a rollout
	rollout MasterRollout "Building Tile Guidelines" width:130  Height: 120
	(
		group "Tile Size"
		(
			dropdownlist tile_ddl ""  items: #("1x1","2x2","3x3","4x4") Align: #Left tooltip: "The Number of tiles the building will occupy" 
		)
		group "Tile Guides"
		(
			button create_btn  "Create" Align: #Center Width: 90 height: 30
		)
		
		on MasterRollout open do 
		(
			tile_ddl.selection = 1
		)
		
		on create_btn pressed do 
		(
			--system Units 
			units.DisplayType = #generic
			units.SystemType = #Centimeters
			
			--Guide layerProperties
			local NewLayer
			if ((layerManager.getLayerFromName  "Tile_Guides" ) != undefined) then 		
			(
				NewLayer = layerManager.getLayerFromName   "Tile_Guides" 
			)
			else
			(
			NewLayer = layermanager.newLayerFromName "Tile_Guides"
			)
			
			NewLayer =  layerManager.getLayerFromName   "Tile_Guides" 
			--CLean Layer
			oldSel = selection
			clearSelection()
			NewLayer.select true
			delete selection 
			select oldsel
			--Set Layer properties
			NewLayer.isfrozen = true
			NewLayer.renderable = false
			NewLayer.castShadows = false
			NewLayer.renderable = false
			
			--Guide Creation
			tileMultiplier = ( (tile_ddl.selection * 2) * 100) 
			GroundPlane = plane typeinPos: [0.0, 0.0 , 0.0] wireColor: green length:tileMultiplier width:tileMultiplier lengthSegs:  tile_ddl.selection  widthSegs:  tile_ddl.selection 
			BoundariesBox = box pos: [0.0, 0.0 , 0.0] wireColor: red	length: (tileMultiplier - 40.0) width: (tileMultiplier - 40.0) height: tileMultiplier lengthSegs: 1 widthSegs: 1  heightSegs: 1
			OrthoCam = FreeCamera  pos: [0.0, 0.0, 0.0] fov: 53.13 lens: 36.0 orthoprojection: true clipManually: false showCone: false shorhorizon: false targetDistance: 11.314
			
			--Orthographic Camera properties
			in coordsys world rotate OrthoCam (eulerangles 60 0 45)
			Orthocam.pos =   [800, -800, 979.7]
			NewLayer.addnode Orthocam
			
			--Guide Plane properties
			setRenderable GroundPlane false
			GroundPlane.name = "_" + tile_ddl.selected +"_groundguide"
			NewLayer.addnode GroundPlane
			GroundPlane.showFrozenInGray  = false
						
			--Guide box properties
			BoundariesBox.name = "_" + tile_ddl.selected +"_pathguide"
			setRenderable BoundariesBox false
			normalMod= NormalModifier ()
			normalMod.flip = true
			addmodifier BoundariesBox normalMod
			BoundariesBox.backFaceCull  = true
			BoundariesBox.showFrozenInGray  = false
			BoundariesBox.xray   = true
			--CollapseStack BoundariesBox
			BoundariesBox.pivot.z = (BoundariesBox.min.z)
			BoundariesBox.pos.z = 0.0
			NewLayer.addnode BoundariesBox
			
			--Guide Player  scale properties
			
			PlayerScale =  box pos: [tileMultiplier, tileMultiplier , 0.0] wireColor: red	length: 20 width: 20 height: 80 lengthSegs: 1 widthSegs: 1  heightSegs: 1
			PlayerScale.name = "_" + tile_ddl.selected +"_pathguide"
			setRenderable PlayerScale false
		
			PlayerScale.showFrozenInGray  = false
			PlayerScale.xray   = true
			PlayerScale.pivot.z = (PlayerScale.min.z)
			PlayerScale.pos.z = 0.0
			NewLayer.addnode PlayerScale
			
		)
		
	)
	 createDialog MasterRollout  pos: [10,90]
)