"""
komodo dragon rig setup
deformation setup
"""

import maya.cmds as mc
import maya.mel as mm

import os

from rigTools import bSkinSaver
from rigLib.utils import name

from . import project

skinWeightsDir = 'weights/skinCluster'
swExt = '.swt'

bodyGeo = 'body_geo'
bodyMidresGeo = 'body_midres_geo'



def build( baseRig, characterName ):
    
    modelGrp = '%s_model_grp' % characterName
    
    # make twist joints
    refTwistJoints = ['l_elbow1_jnt', 'l_knee1_jnt', 'r_elbow1_jnt', 'r_knee1_jnt']
    maketwistJoints( baseRig, refTwistJoints )
    
    # load skin weights
    geoList = _getModelGeoObjects( modelGrp )
    loadSkinWeights( characterName, geoList )
    
    # apply delta mush deformer
    _applyDeltaMush( bodyMidresGeo )
    
    # wrap hires body mesh
    _makeWrap( [bodyGeo], bodyMidresGeo )


def _makeWrap( wrappedObjs, wrapperObj ):
    
    mc.select( wrappedObjs )
    mc.select( wrapperObj, add=1 )
    mm.eval( 'doWrapArgList "7" { "1","0","1", "2", "1", "1", "0", "0" }' )

def _applyDeltaMush( geo ):
    
    deltaMushDf = mc.deltaMush( geo, smoothingIterations = 50 )[0]
    

def _getModelGeoObjects( modelGrp ):
    
    geoList = [ mc.listRelatives( o, p = 1 )[0] for o in mc.listRelatives( modelGrp, ad = 1, type = 'mesh' ) ]
    
    return geoList


def maketwistJoints( baseRig, parentJoints ):
    
    twistJointsMainGrp = mc.group( n= 'twistJoints_grp', p= baseRig.jointsGrp, em=1 )
    
    for parentJnt in parentJoints:
        
        prefix = name.removeSuffix( parentJnt )
        prefix = prefix[:-1]
        parentJntChild = mc.listRelatives( parentJnt, c= 1, type= 'joint' )[0]
        
        # make twist joints
        
        twistJntGrp = mc.group( n = prefix + 'TwistJoint_grp', p = twistJointsMainGrp, em = 1 )
        
        twistParentJnt = mc.duplicate( parentJnt, n = prefix + 'Twist1_jnt', parentOnly = True )[0]
        twistChildJnt = mc.duplicate( parentJntChild, n = prefix + 'Twist2_jnt', parentOnly = True )[0]
        
        # adjust twist joints
        
        origJntRadius = mc.getAttr( parentJnt + '.radius' )
        
        for j in [ twistParentJnt, twistChildJnt ]:
            
            mc.setAttr( j + '.radius', origJntRadius * 2 )
            mc.color( j, ud = 1 )
        
        mc.parent( twistChildJnt, twistParentJnt )
        mc.parent( twistParentJnt, twistJntGrp )
        
        # attach twist joints
        mc.pointConstraint( parentJnt, twistParentJnt )
        
        # make IK handle
        twistIk = mc.ikHandle( n = prefix + 'TwistJoint_ikh', sol = 'ikSCsolver', sj = twistParentJnt, ee = twistChildJnt )[0]
        mc.hide( twistIk )
        mc.parent( twistIk, twistJntGrp )
        mc.parentConstraint( parentJntChild, twistIk )
        
    

def saveSkinWeights( characterName, geoList = [] ):
    
    """
    save weights for character geometry objects
    """
    
    for obj in geoList:
        
        # weights file
        wtFile = os.path.join( project.mainProjectPath, characterName, skinWeightsDir, obj + swExt )
        
        # save skin weight file
        mc.select( obj )
        bSkinSaver.bSaveSkinValues( wtFile )
        
def loadSkinWeights( characterName, geoList = [] ):
    
    """
    load skin weights for character geometry objects
    """
    
    # weights folders
    
    wtDir = os.path.join( project.mainProjectPath, characterName, skinWeightsDir )
    wtFiles = os.listdir( wtDir )
    
    # load skin weights
    
    for wtFile in wtFiles:
        
        extRes = os.path.splitext( wtFile )
        
        # check extension format
        if not extRes > 1:
            
            continue
        
        # check skin weight file
        if not extRes[1] == swExt:
            
            continue
        
        # check geometry list
        if geoList and not extRes[0] in geoList:
            
            continue
        
        # check if objects exist
        if not mc.objExists( extRes[0] ):
            
            continue
        
        fullpathWtFile = os.path.join( wtDir, wtFile )
        bSkinSaver.bLoadSkinValues( loadOnSelection = False, inputFile = fullpathWtFile )

        
    
    
