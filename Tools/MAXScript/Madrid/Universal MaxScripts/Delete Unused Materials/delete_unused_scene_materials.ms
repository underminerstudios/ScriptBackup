/*
	Delete Unused Scene Materials
	
	This script will delete all materials from the scene that are not being used by objects.


	--by Norman Schaar --- norman.schaar@gameloft.com
*/


for i=1 to meditMaterials.count do
(
	meditMaterials[i] = standard()
)


theMaterials = #()
for n in objects do
(
	if n.material != undefined do
	(
		appendifunique theMaterials n.material
	)
)


if theMaterials.count > 24 then
(
	for i=1 to 24 do
	(
		meditMaterials[i] = theMaterials[i]
	)
)
else
(
	for i=1 to theMaterials.count do
	(
		meditMaterials[i] = theMaterials[i]
	)
)