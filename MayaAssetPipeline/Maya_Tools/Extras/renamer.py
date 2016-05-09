import pymel.core as pm

GetEverything = pm.select(all=True)
allObjects = pm.ls()

names = []
NamesAndObjects = {}
for object in allObjects:
    NamesAndObjects[object] = str(object)
    
for key in NamesAndObjects:
    if "FBXASC" in NamesAndObjects[key]:
        NameToChangeTo = NamesAndObjects[key].replace("FBXASC","_",1)
        NameToChangeTo = NameToChangeTo.split("FBXASC")[0]
        pm.rename(key, NameToChangeTo)