"""
module for making rig controls 
"""

import maya.cmds as mc

class Control():
    
    """
    class for building rig control
    """
    
    def __init__(
                 self,
                 prefix = 'new',
                 scale = 1.0,
                 translateTo = '',
                 rotateTo = '',
                 parent = '',
                 shape = 'circle',
                 lockChannels = ['s','v']
                 ):
        
        """
        @param prefix: str, prefix to name new objects
        @param scale: float, scale value for size of control shapes
        @param translateTo: str, reference object for control position
        @param rotateTo: str, reference object for control orientation
        @param parent: str, object to be parent of new control
        @param shape: str, control shape type
        @param lockChannels: list( str ), list of channels on control to be locked and non-keyable
        @return: None
        """
        
        ctrlObject = None
        circleNormal = [1, 0, 0]
        
        if shape in ['circle', 'circleX']:
            
            circleNormal = [1, 0, 0]
        
        elif shape == 'circleY':
            
            circleNormal = [0, 1, 0]
        
        elif shape == 'circleZ':
            
            circleNormal = [0, 0, 1]
        
        elif shape == 'sphere':
            
            ctrlObject = mc.circle( n = prefix + '_ctl', ch = False, normal = [1, 0, 0], radius = scale )[0]
            addShape = mc.circle( n = prefix + '_ctl2', ch = False, normal = [0, 0, 1], radius = scale )[0]
            mc.parent( mc.listRelatives( addShape, s = 1 ), ctrlObject, r = 1, s = 1 )
            mc.delete( addShape )
        
        if not ctrlObject:
            
            ctrlObject = mc.circle( n = prefix + '_ctl', ch = False, normal = circleNormal, radius = scale )[0]
            
        ctrlOffset = mc.group( n = prefix + 'Offset_grp', em = 1 )
        mc.parent( ctrlObject, ctrlOffset )
        
        # color control
        ctrlShapes = mc.listRelatives( ctrlObject, s = 1 )
        [ mc.setAttr( s + '.ove', 1 ) for s in ctrlShapes ]
        
        if prefix.startswith( 'l_' ):
            
            [ mc.setAttr( s + '.ovc', 6 ) for s in ctrlShapes ]
        
        elif prefix.startswith( 'r_' ):
            
            [mc.setAttr( s + '.ovc', 13 ) for s in ctrlShapes ]
        
        else:
            
            [mc.setAttr( s + '.ovc', 22 ) for s in ctrlShapes ]
        
        # translate control
        
        if mc.objExists( translateTo ):
            
            mc.delete( mc.pointConstraint( translateTo, ctrlOffset ) )
        
        # rotate control
        
        if mc.objExists( rotateTo ):
            
            mc.delete( mc.orientConstraint( rotateTo, ctrlOffset ) )
        
        # parent control
        
        if mc.objExists( parent ):
            
            mc.parent( ctrlOffset, parent )
        
        # lock control channels
        
        singleAttributeLockList = []
        
        for lockChannel in lockChannels:
            
            if lockChannel in ['t','r','s']:
                
                for axis in ['x','y','z']:
                    
                    at = lockChannel + axis
                    singleAttributeLockList.append( at )
            
            else:
                
                singleAttributeLockList.append( lockChannel )
        
        for at in singleAttributeLockList:
            
            mc.setAttr( ctrlObject + '.' + at, l = 1, k = 0 )
        
        
        # add public members
        
        self.C = ctrlObject
        self.Off = ctrlOffset
        
        
        
        
                    
                    
        
        
        
        
        
        
        
        
        
        
        
       
        
        
        
