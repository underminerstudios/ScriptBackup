"""
module for making top rig structure and rig module 
"""

import maya.cmds as mc

sceneObjectType = 'rig'

from . import control


class Base():
    
    """
    class for building top rig structure
    """
    
    def __init__(
                 self,
                 characterName = 'new',
                 scale = 1.0,
                 mainCtrlAttachObj = ''
                 ):
        
        """
        @param characterName: str, character name
        @param scale: float, general scale of the rig
        @return: None
        """
        
        self.topGrp = mc.group( n = characterName + '_rig_grp', em = 1 )
        self.rigGrp = mc.group( n = 'rig_grp', em = 1, p = self.topGrp )
        self.modelGrp = mc.group( n = 'model_grp', em = 1, p = self.topGrp )
        
        characterNameAt = 'characterName'
        sceneObjectTypeAt = 'sceneObjectType'
        
        for at in [ characterNameAt, sceneObjectTypeAt ]:
            
            mc.addAttr( self.topGrp, ln = at, dt = 'string' )
        
        mc.setAttr( self.topGrp + '.' + characterNameAt, characterName, type = 'string', l = 1 )
        mc.setAttr( self.topGrp + '.' + sceneObjectTypeAt, sceneObjectType, type = 'string', l = 1 )
        
        
        # make global control
        
        global1Ctrl = control.Control( 
                                     prefix = 'global1',
                                     scale = scale * 20,
                                     parent = self.rigGrp,
                                     lockChannels = ['v']
                                     )
        
        global2Ctrl = control.Control( 
                                     prefix = 'global2',
                                     scale = scale * 18,
                                     parent = global1Ctrl.C,
                                     lockChannels = ['s', 'v']
                                     )
        
        self._flattenGlobalCtrlShape( global1Ctrl.C )
        self._flattenGlobalCtrlShape( global2Ctrl.C )
        
        for axis in ['y', 'z']:
            
            mc.connectAttr( global1Ctrl.C + '.sx', global1Ctrl.C + '.s' + axis )
            mc.setAttr( global1Ctrl.C + '.s' + axis, k = 0 )
        
        
        # make more groups
        
        self.jointsGrp = mc.group( n = 'joints_grp', em = 1, p = global2Ctrl.C )
        self.modulesGrp = mc.group( n = 'modules_grp', em = 1, p = global2Ctrl.C )
        
        self.partGrp = mc.group( n = 'parts_grp', em = 1, p = self.rigGrp )
        mc.setAttr( self.partGrp + '.it', 0, l = 1 )
        
        # make main control
        
        mainCtrl = control.Control( 
                                     prefix = 'main',
                                     scale = scale * 1,
                                     parent = global2Ctrl.C,
                                     translateTo = mainCtrlAttachObj,
                                     lockChannels = ['t', 'r', 's', 'v']
                                     )
        
        self._adjustMainCtrlShape( mainCtrl, scale )
        
        if mc.objExists( mainCtrlAttachObj ):
            
            mc.parentConstraint( mainCtrlAttachObj, mainCtrl.Off, mo = 1 )
        
        mainVisAts = ['modelVis', 'jointsVis']
        mainDispAts = ['modelDisp', 'jointsDisp']
        mainObjList = [ self.modelGrp, self.jointsGrp ]
        mainObjVisDvList = [1, 0]
        
        # add rig visibility connections
        
        for at, obj, dfVal in zip( mainVisAts, mainObjList, mainObjVisDvList ):
            
            mc.addAttr( mainCtrl.C, ln = at, at = 'enum', enumName = 'off:on', k = 1, dv = dfVal )
            mc.setAttr( mainCtrl.C + '.' + at, cb = 1 )
            mc.connectAttr( mainCtrl.C + '.' + at, obj + '.v' )
        
        # add rig display type connections
        
        for at, obj in zip( mainDispAts, mainObjList ):
            
            mc.addAttr( mainCtrl.C, ln = at, at = 'enum', enumName = 'normal:template:reference', k = 1, dv = 2 )
            mc.setAttr( mainCtrl.C + '.' + at, cb = 1 )
            mc.setAttr( obj + '.ove', 1 )
            mc.connectAttr( mainCtrl.C + '.' + at, obj + '.ovdt' )
        
    def _adjustMainCtrlShape( self, ctrl, scale ):
        
        # adjust shape of main control
        
        ctrlShapes = mc.listRelatives( ctrl.C, s = 1, type = 'nurbsCurve' )
        cls = mc.cluster( ctrlShapes )[1]
        mc.setAttr( cls + '.ry', 90 )
        mc.delete( ctrlShapes, ch = 1 )
        
        mc.move( 8 * scale, ctrl.Off, moveY = True, relative = True )
        
        
        
    
    def _flattenGlobalCtrlShape( self, ctrlObject ):
        
        # flatten ctrl object shape
        
        ctrlShapes = mc.listRelatives( ctrlObject, s = 1, type = 'nurbsCurve' )
        cls = mc.cluster( ctrlShapes )[1]
        mc.setAttr( cls + '.rz', 90 )
        mc.delete( ctrlShapes, ch = 1 )

    
        
class Module():
    
    """
    class for building module rig structure
    """
    
    def __init__( 
                 self,
                 prefix = 'new',
                 baseObj = None
                 ):
        
        """
        @param prefix: str, prefix to name new objects
        @param baseObj: instance of base.module.Base class
        @return: None
        """
        
        self.topGrp = mc.group( n = prefix + 'Module_grp', em = 1 )
        
        self.controlsGrp = mc.group( n = prefix + 'Controls_grp', em = 1, p = self.topGrp )
        self.jointsGrp = mc.group( n = prefix + 'Joints_grp', em = 1, p = self.topGrp )
        self.partsGrp = mc.group( n = prefix + 'Parts_grp', em = 1, p = self.topGrp )
        self.partsNoTransGrp = mc.group( n = prefix + 'PartsNoTrans_grp', em = 1, p = self.topGrp )
        
        mc.hide( self.partsGrp, self.partsNoTransGrp )
        
        mc.setAttr( self.partsNoTransGrp + '.it', 0, l = 1 )
        
        # parent module
        
        if baseObj:
            
            mc.parent( self.topGrp, baseObj.modulesGrp )
        
        
        
