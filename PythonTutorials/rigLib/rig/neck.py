"""
neck @ rig
"""

import maya.cmds as mc

from ..base import module
from ..base import control

def build(
          neckJoints,
          headJnt,
          neckCurve,
          prefix = 'neck',
          rigScale = 1.0,
          baseRig = None
          ):
    
    """
    @param neckJoints: list( str ), list of neck joints
    @param headJnt: str, head joint at the end of neck joint chain
    @param neckCurve: str, name of neck cubic curve with 5 CVs matching neck joints
    @param prefix: str, prefix to name new objects
    @param rigScale: float, scale factor for size of controls
    @param baseRig: instance of base.module.Base class
    @return: dictionary with rig module objects
    """
    
    # make rig module
    
    rigmodule = module.Module( prefix = prefix, baseObj = baseRig )
    
    # make neck curve clusters
    
    neckCurveCVs = mc.ls( neckCurve + '.cv[*]', fl = 1 )
    numNeckCVs = len( neckCurveCVs )
    neckCurveClusters = []
    
    for i in range( numNeckCVs ):
        
        cls = mc.cluster( neckCurveCVs[i], n = prefix + 'Cluster%d' % ( i + 1 ) )[1]
        neckCurveClusters.append( cls )
    
    mc.hide( neckCurveClusters )
    
    # parent neck curve
    
    mc.parent( neckCurve, rigmodule.partsNoTransGrp )
    
    # make attach groups
    
    bodyAttachGrp = mc.group( n = prefix + 'BodyAttach_grp', em = 1, p = rigmodule.partsGrp )
    baseAttachGrp = mc.group( n = prefix + 'BaseAttach_grp', em = 1, p = rigmodule.partsGrp )
    
    mc.delete( mc.pointConstraint( neckJoints[0], baseAttachGrp ) )
    
    # make controls
    
    headMainCtrl = control.Control( prefix = prefix + 'HeadMain', translateTo = neckJoints[-1], scale = rigScale * 5,
                                    parent = rigmodule.controlsGrp, shape = 'circleZ' )
    
    headLocalCtrl = control.Control( prefix = prefix + 'HeadLocal', translateTo = headJnt, rotateTo = headJnt,
                                      scale = rigScale * 4, parent = headMainCtrl.C, shape = 'circleX' )
    
    middleCtrl = control.Control( prefix = prefix + 'Middle', translateTo = neckCurveClusters[2], rotateTo = neckJoints[2],
                                  scale = rigScale * 4, parent = rigmodule.controlsGrp, shape = 'circleX' )
    
    # attach controls
    
    mc.parentConstraint( headMainCtrl.C, baseAttachGrp, middleCtrl.Off, sr = ['x', 'y', 'z'], mo = 1 )
    mc.orientConstraint( baseAttachGrp, middleCtrl.Off, mo = 1 )
    mc.parentConstraint( bodyAttachGrp, headMainCtrl.Off, mo = 1 )
    
    # attach clusters
    
    mc.parent( neckCurveClusters[3:], headMainCtrl.C )
    mc.parent( neckCurveClusters[2], middleCtrl.C )
    mc.parent( neckCurveClusters[:2], baseAttachGrp )
    
    # attach joints
    
    mc.orientConstraint( headLocalCtrl.C, headJnt, mo = 1 )
    
    # make IK handle
    
    neckIk = mc.ikHandle( n = prefix + '_ikh', sol = 'ikSplineSolver', sj = neckJoints[0], ee = neckJoints[-1],
                           c = neckCurve, ccv = 0, parentCurve = 0 )[0]
    
    mc.hide( neckIk )
    mc.parent( neckIk, rigmodule.partsNoTransGrp )
    
    # setup IK twist
    
    mc.setAttr( neckIk + '.dTwistControlEnable', 1 )
    mc.setAttr( neckIk + '.dWorldUpType', 4 )
    mc.connectAttr( headMainCtrl.C + '.worldMatrix[0]', neckIk + '.dWorldUpMatrixEnd' )
    mc.connectAttr( baseAttachGrp + '.worldMatrix[0]', neckIk + '.dWorldUpMatrix' )
    
    
    return { 'module':rigmodule, 'baseAttachGrp':baseAttachGrp, 'bodyAttachGrp':bodyAttachGrp }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
