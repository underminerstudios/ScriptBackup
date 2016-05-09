
--Obj Render
-- By Gwen Heliou - gwenael.heliou@gameloft.com


global ma2_FH_SVNpath = "D:/SVN/funny_hospital_iphone/FunnyHospital/*"
global ma2_FH_Layercount = LayerManager.count
global ma2_FH_ActiveLayer

/*
aa = getDirectories ma2FH_SVNpath

-- a = viewport.activeViewport
viewport.setType #view_camera

MasterDummy = Dummy pos:[0,0,0]
MasterDummy.boxsize = [100,100,100]

attach ma2_Activegroup MasterDummy

ma2_layercount = LayerManager.count
aaa = LayerManager.getLayer 0
*/

fn ma2_FH_PrepLayer LayerNumber =
(
--	print (LayerNumber as string)
	ma2_FH_ActiveLayer.ishidden = false
	ma2_FH_ActiveLayer.current = true
	delete (getnodebyname "DummyMaster")
	MasterDummy = Dummy pos:[0,0,0]
	MasterDummy.boxsize = [100,100,100]
	MasterDummy.name = "DummyMaster"
	attach ma2_Activegroup MasterDummy
)

for i = 1 to ma2_FH_Layercount do
(
	ma2_FH_ActiveLayer = LayerManager.getLayer (i-1)
	ma2_FH_ActiveLayer.ishidden = true
)

for i = 1 to ma2_FH_Layercount do
(
	ma2_FH_ActiveLayer
	ma2_FH_ActiveLayer = LayerManager.getLayer (i-1)
	--print ma2_FH_ActiveLayer.name
	case of 
	(
		(ma2_FH_ActiveLayer.name == "0"): ()
		(ma2_FH_ActiveLayer.name == "_luces y camara"): ()	
		default:(ma2_FH_PrepLayer(i-1))
	)
)

