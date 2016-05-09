theMaterials = #()
for n in selection do 
(
	if classof n.material == XRef_Material do
	(
		appendifunique theMaterials n.material
	)
)
for m in theMaterials do
(
	local theNewMaterial = m.GetSourceMaterial true
	replaceInstances m theNewMaterial
)