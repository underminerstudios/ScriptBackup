import pymel.core as pm


class ControllerMaker(object):
    """
    Makes controllers
    """
    
    def __init__(self, name = "new",scale = 1.0, 
                 parent = "",LockedChannels = ["s","v"],
                 controllerType = "circle"):
        
        self.MakeController(controllerType,name)
    
    def MakeController(self,controllerType,name):
        """
        controller types are "circle","square","cone"
        """
        if controllerType == "circle":
            Controller = pm.circle(n=name)
        elif controllerType == "square":
            pm.nurbsSquare(n=name)
        elif controllerType == "cone":
            pm.cone(n=name)