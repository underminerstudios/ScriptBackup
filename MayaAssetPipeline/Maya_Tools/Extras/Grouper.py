import pymel.core as pm
def groupstuff():
    GetEverything = pm.select(all=True)
    allObjects = pm.ls()
    
    names = []
    NamesAndObjects = {}
    for object in allObjects:
        NamesAndObjects[object] = str(object)
    
    #define the variables here
    
    Walls = []
    Lights = []
    Railing = []
    Ceramic = []
    Column = []
    Produce = []
    Trolley = []
    Rack = []
    Cook = []
    Stool = []
    Produce = []
    Register = []
    Cabinet = []
    Glass = []
    Soda = []
    Seating = []
    Gondolia = []
    
    Finders = {"wall":Walls,"lights":Lights,"railing":Railing,"toilet":Ceramic,"column":Column,"produce":Produce,"trolley":Trolley,"rack":Rack,"cook":Cook,
               "stool":Stool,"produce":Produce,"register":Register,"cabinet":Cabinet,"glass":Glass,"soda":Soda,"seating":Seating,"gondola":Gondolia}
    
    
    
    #loop variables here
    
    for object in NamesAndObjects:
        for finder in Finders:
            if finder in NamesAndObjects[object].lower():
                Finders[finder].append(NamesAndObjects[object])
        
    for finder in Finders:
        if len(Finders[finder])>0:
            pm.group(Finders[finder], n=finder)
    
groupstuff()    