"""
ikChain @ rig
"""

import maya.cmds as mc

from ..base import module
from ..base import control

def build(
          chainJoints,
          chainCurve,
          prefix = 'tail',
          rigScale = 1.0,
          smallestScalePercent = 0.5,
          fkParenting = True,
          baseRig = None
          ):
    
    """
    @param chainJoints: list( str ), list of chain joints
    @param chainCurve: str, name of chain cubic curve
    @param prefix: str, prefix to name new objects
    @param rigScale: float, scale factor for size of controls
    @param smallestScalePercent: float, scale of smallest control at the end of chain compared to rigScale
    @param fkParenting: bool, parent each control to previous one to make FK chain
    @param baseRig: instance of base.module.Base class
    @return: dictionary with rig module objects
    """
    
    # make rig module
    
    rigmodule = module.Module( prefix = prefix, baseObj = baseRig )
    
    # make chain curve clusters
    
    chainCurveCVs = mc.ls( chainCurve + '.cv[*]', fl = 1 )
    numChainCVs = len( chainCurveCVs )
    chainCurveClusters = []
    
    for i in range( numChainCVs ):
        
        cls = mc.cluster( chainCurveCVs[i], n = prefix + 'Cluster%d' % ( i + 1 ) )[1]
        chainCurveClusters.append( cls )
    
    mc.hide( chainCurveClusters )
    
    # parent chain curve
    
    mc.parent( chainCurve, rigmodule.partsNoTransGrp )
    
    
    # make attach groups
    
    baseAttachGrp = mc.group( n = prefix + 'BaseAttach_grp', em = 1, p = rigmodule.partsGrp )
    
    mc.delete( mc.pointConstraint( chainJoints[0], baseAttachGrp ) )
    
    # make controls
    
    chainControls = []
    controlScaleIncrement = ( 1.0 - smallestScalePercent ) / numChainCVs
    mainCtrlScaleFactor = 5.0
    
    for i in range( numChainCVs ):
        
        ctrlScale = rigScale * mainCtrlScaleFactor * ( 1.0 - ( i * controlScaleIncrement ) )
        ctrl = control.Control( prefix = prefix + '%d' % ( i + 1 ), translateTo = chainCurveClusters[i],
                                scale = ctrlScale, parent = rigmodule.controlsGrp, shape = 'sphere' )
        
        chainControls.append( ctrl )
        
    
    # parent controls
    
    if fkParenting:
        
        for i in range( numChainCVs ):
            
            if i == 0:
                
                continue
            
            mc.parent( chainControls[i].Off, chainControls[i - 1].C )
    
    # attach clusters
    
    for i in range( numChainCVs ):
        
        mc.parent( chainCurveClusters[i], chainControls[i].C )
    
    # attach controls
    
    mc.parentConstraint( baseAttachGrp, chainControls[0].Off, mo = 1 )
    
    # make IK handle
    
    chainIk = mc.ikHandle( n = prefix + '_ikh', sol = 'ikSplineSolver', sj = chainJoints[0], ee = chainJoints[-1],
                           c = chainCurve, ccv = 0, parentCurve = 0 )[0]
    
    mc.hide( chainIk )
    mc.parent( chainIk, rigmodule.partsNoTransGrp )
    
    # add twist attribute
    
    twistAt = 'twist'
    mc.addAttr( chainControls[-1].C, ln = twistAt, k = 1 )
    mc.connectAttr( chainControls[-1].C + '.' + twistAt, chainIk + '.twist' )
    
    
    return { 'module':rigmodule, 'baseAttachGrp':baseAttachGrp }
    
    
    
       
