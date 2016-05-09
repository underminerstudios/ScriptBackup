/*
	Stadium State Changer
	
	Cycles through the different states of the stadium.
	
	Changes lightmaps
	
	Hides/Un-Hides layers

*/
--by Norman Schaar norman.schaar@gameloft.com

try(destroyDialog rf2013_state)catch()

fn replace_tga theArray the_State =
(
	for n in theArray do
	(
		--Day
		if the_State == 1 do
		(
			FX_Layer = LayerManager.getLayerFromName "Fx"
			if FX_Layer == undefined do
			(
				FX_Layer = LayerManager.getLayerFromName "Fx_night"
			)
			FX_Layer.on = false
			
			Pub_cloud = LayerManager.getLayerFromName "Pub_cloud"
			if Pub_cloud != undefined do (Pub_cloud.on = false)
			
			Pub_day = LayerManager.getLayerFromName "Pub_day"
			if Pub_day != undefined do (Pub_day.on = true)
			
			Pub_night = LayerManager.getLayerFromName "Pub_night"
			if Pub_night != undefined do (Pub_night.on = false)
			
			lightshaft_day = LayerManager.getLayerFromName "lightshaft_day"
			if lightshaft_day != undefined do (lightshaft_day.on = true)
			
			lightshaft_cloud = LayerManager.getLayerFromName "lightshaft_cloud"
			if lightshaft_cloud != undefined do (lightshaft_cloud.on = false)
			
			
			if (matchpattern n pattern:"*_night.*" == true) OR (matchpattern n pattern:"*_cloud.*" == true) do
			(
				atsops.selectfiles #(n)
				theFileName = (substitutestring n "_cloud." "_day.")
				theFileName = (substitutestring theFileName "_night." "_day.")
				atsops.RetargetSelection theFileName
			)
			if (matchpattern n pattern:"*sky_*_D.*" == true) do
			(
				atsops.selectfiles #(n)
				theFileName = (substitutestring n "sky_02_D" "sky_01_D")
				theFileName = (substitutestring theFileName "sky_03_D" "sky_01_D")
				atsops.RetargetSelection theFileName
			)
		)
		--Night
		if the_State == 2 do
		(
			FX_Layer = LayerManager.getLayerFromName "Fx"
			if FX_Layer == undefined do
			(
				FX_Layer = LayerManager.getLayerFromName "Fx_night"
			)
			FX_Layer.on = true
			
			Pub_cloud = LayerManager.getLayerFromName "Pub_cloud"
			if Pub_cloud != undefined do (Pub_cloud.on = false)
			
			Pub_day = LayerManager.getLayerFromName "Pub_day"
			if Pub_day != undefined do (Pub_day.on = false)
			
			Pub_night = LayerManager.getLayerFromName "Pub_night"
			if Pub_night != undefined do (Pub_night.on = true)
			
			lightshaft_day = LayerManager.getLayerFromName "lightshaft_day"
			if lightshaft_day != undefined do (lightshaft_day.on = false)
			
			lightshaft_cloud = LayerManager.getLayerFromName "lightshaft_cloud"
			if lightshaft_cloud != undefined do (lightshaft_cloud.on = false)
			
			if (matchpattern n pattern:"*_day.*" == true) OR (matchpattern n pattern:"*_cloud.*" == true) do
			(
				atsops.selectfiles #(n)
				theFileName = (substitutestring n "_day." "_night.")
				theFileName = (substitutestring theFileName "_cloud." "_night.")
				atsops.RetargetSelection theFileName
			)
			if (matchpattern n pattern:"*sky_*_D.*" == true) do
			(
				atsops.selectfiles #(n)
				theFileName = (substitutestring n "sky_01_D" "sky_02_D")
				theFileName = (substitutestring theFileName "sky_03_D" "sky_02_D")
				atsops.RetargetSelection theFileName
			)
		)
		--Cloud
		if the_State == 3 do
		(
			FX_Layer = LayerManager.getLayerFromName "Fx"
			if FX_Layer == undefined do
			(
				FX_Layer = LayerManager.getLayerFromName "Fx_night"
			)
			FX_Layer.on = false
			
			Pub_cloud = LayerManager.getLayerFromName "Pub_cloud"
			if Pub_cloud != undefined do (Pub_cloud.on = true)
			
			Pub_day = LayerManager.getLayerFromName "Pub_day"
			if Pub_day != undefined do (Pub_day.on = false)
			
			Pub_night = LayerManager.getLayerFromName "Pub_night"
			if Pub_night != undefined do (Pub_night.on = false)
			
			lightshaft_day = LayerManager.getLayerFromName "lightshaft_day"
			if lightshaft_day != undefined do (lightshaft_day.on = false)
			
			lightshaft_cloud = LayerManager.getLayerFromName "lightshaft_cloud"
			if lightshaft_cloud != undefined do (lightshaft_cloud.on = true)
			
			if (matchpattern n pattern:"*_day.*" == true) OR (matchpattern n pattern:"*_night.*" == true) do
			(
				atsops.selectfiles #(n)
				theFileName = (substitutestring n "_day." "_cloud.")
				theFileName = (substitutestring theFileName "_night." "_cloud.")
				atsops.RetargetSelection theFileName
			)
			if (matchpattern n pattern:"*sky_*_D.*" == true) do
			(
				atsops.selectfiles #(n)
				theFileName = (substitutestring n "sky_01_D" "sky_03_D")
				theFileName = (substitutestring theFileName "sky_02_D" "sky_03_D")
				atsops.RetargetSelection theFileName
			)
		)
	)
)

rollout rf2013_state "Change State"
(
	radiobuttons rb_state "States:" labels:#("day","night","cloud")

	
	on rb_state changed theState do
	(
		atsops.refresh()
		atsops.silent = true
		local fileList
		
		-- Get all files 
		atsops.GetFiles &fileList
		
		replace_tga filelist theState
		atsops.refresh()
	)
	
	on rf2013_state open do
	(
		ATSOps.Visible = true
		ATSOps.Visible = false
	)
)
createDialog rf2013_state