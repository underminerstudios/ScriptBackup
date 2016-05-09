import pymel.core as pm

GetEverything = pm.select(all=True)
allObjects = pm.ls()

names = []
NamesAndObjects = {}
for object in allObjects:
    NamesAndObjects[object] = str(object)

ObjectsWithRecessedName = []

for key in NamesAndObjects:
    if "Recessed" in NamesAndObjects[key] or "Light" in NamesAndObjects[key]:
        ObjectsWithRecessedName.append(NamesAndObjects[key])
        

pm.group(ObjectsWithRecessedName)