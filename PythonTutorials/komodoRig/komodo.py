"""
komodo dragon rig setup
main module
"""

from rigLib.base import control
from rigLib.base import module

from rigLib.rig import spine
from rigLib.rig import neck
from rigLib.rig import ikChain
from rigLib.rig import leg
from rigLib.rig import headParts

from rigLib.utils import joint

from . import project
from . import komodo_deform


import maya.cmds as mc

sceneScale = project.sceneScale
mainProjectPath = project.mainProjectPath

modelFilePath = '%s/%s/model/%s_model.mb'
builderSceneFilePath = '%s/%s/builder/%s_builder.mb'

rootJnt = 'root1_jnt'
headJnt = 'head1_jnt'
pelvisJnt = 'pelvis1_jnt'
jawJnt = 'jaw1_jnt'

def build( characterName ):
    
    """
    main function to build character rig
    """
    
    # new scene
    mc.file( new = True, f = True )
    
    # import builder scene
    builderFile = builderSceneFilePath % ( mainProjectPath, characterName, characterName )
    mc.file( builderFile, i = 1 )
    
    # make base
    baseRig = module.Base( characterName = characterName, scale = sceneScale, mainCtrlAttachObj = headJnt )
    
    # import model
    modelFile = modelFilePath % ( mainProjectPath, characterName, characterName )
    mc.file( modelFile, i = 1 )
    
    # parent model
    modelGrp = '%s_model_grp' % characterName
    mc.parent( modelGrp, baseRig.modelGrp )
    
    # parent skeleton
    mc.parent( rootJnt, baseRig.jointsGrp )
    
    # deform setup
    komodo_deform.build( baseRig, characterName )
    
    # control setup
    makeControlSetup( baseRig )
    
    # delete build objects
    
    builderGrp = 'builder_grp'
    mc.delete( builderGrp )
    
    
def makeControlSetup( baseRig ):
    
    """
    make control setup
    """
    
    # adjust orientation of feet
    mc.setAttr( 'l_hand1_jnt.jo', 138.28570432475698, -48.90539524404269, -30.284152362844438 )
    mc.setAttr( 'r_hand1_jnt.jo', 138.28570432475684, -48.905395244042566, -30.28415236284434 )
    
    # spine
    
    spineJoints = ['spine1_jnt', 'spine2_jnt', 'spine3_jnt', 'spine4_jnt', 'spine5_jnt', 'spine6_jnt']
    
    spineRig = spine.build( 
                          spineJoints = spineJoints,
                          rootJnt = rootJnt,
                          spineCurve = 'spine_crv',
                          bodyLocator = 'body_loc',
                          chestLocator = 'chest_loc',
                          pelvisLocator = 'pelvis_loc',
                          prefix = 'spine',
                          rigScale = sceneScale,
                          baseRig = baseRig
                          )
    
    # neck
    
    neckJoints = ['neck1_jnt', 'neck2_jnt', 'neck3_jnt', 'neck4_jnt', 'neck5_jnt', 'neck6_jnt']
    
    neckRig = neck.build( 
                      neckJoints = neckJoints,
                      headJnt = headJnt,
                      neckCurve = 'neck_crv',
                      prefix = 'neck',
                      rigScale = sceneScale,
                      baseRig = baseRig
                      )
    
    mc.parentConstraint( spineJoints[-2], neckRig['baseAttachGrp'], mo = 1 )
    mc.parentConstraint( spineRig['bodyCtrl'].C, neckRig['bodyAttachGrp'], mo = 1 )
    
    # tail
    
    tailJoints = joint.listHierarchy( 'tail1_jnt' )
    
    tailRig = ikChain.build( 
                  chainJoints = tailJoints,
                  chainCurve = 'tail_crv',
                  prefix = 'tail',
                  rigScale = sceneScale,
                  smallestScalePercent = 0.4,
                  fkParenting = False,
                  baseRig = baseRig
                  )
    
    mc.parentConstraint( pelvisJnt, tailRig['baseAttachGrp'], mo = 1 )
    
    
    # tongue
    
    tongueJoints = joint.listHierarchy( 'tongue1_jnt' )
    
    tongueRig = ikChain.build( 
                  chainJoints = tongueJoints,
                  chainCurve = 'tongue_crv',
                  prefix = 'tongue',
                  rigScale = sceneScale * 0.2,
                  smallestScalePercent = 0.3,
                  fkParenting = True,
                  baseRig = baseRig
                  )
    
    mc.parentConstraint( jawJnt, tongueRig['baseAttachGrp'], mo = 1 )
    
    
    # left arm
    
    legJoints = ['l_shoulder1_jnt','l_elbow1_jnt','l_hand1_jnt','l_hand2_jnt','l_hand3_jnt']
    topToeJoints = ['l_foreToeA1_jnt', 'l_foreToeB1_jnt', 'l_foreToeC1_jnt', 'l_foreToeD1_jnt', 'l_foreToeE1_jnt']
    
    lArmRig = leg.build( 
              legJoints = legJoints,
              topToeJoints = topToeJoints,
              pvLocator = 'l_arm_pole_vector_loc',
              scapulaJnt = 'l_scapula1_jnt',
              prefix = 'l_arm',
              rigScale = sceneScale,
              baseRig = baseRig
              )
    
    mc.parentConstraint( spineJoints[-2], lArmRig['baseAttachGrp'], mo = 1 )
    mc.parentConstraint( spineRig['bodyCtrl'].C, lArmRig['bodyAttachGrp'], mo = 1 )
    
    
    # right arm
    
    legJoints = ['r_shoulder1_jnt', 'r_elbow1_jnt', 'r_hand1_jnt', 'r_hand2_jnt', 'r_hand3_jnt']
    topToeJoints = ['r_foreToeA1_jnt', 'r_foreToeB1_jnt', 'r_foreToeC1_jnt', 'r_foreToeD1_jnt', 'r_foreToeE1_jnt']
    
    rArmRig = leg.build( 
              legJoints = legJoints,
              topToeJoints = topToeJoints,
              pvLocator = 'r_arm_pole_vector_loc',
              scapulaJnt = 'r_scapula1_jnt',
              prefix = 'r_arm',
              rigScale = sceneScale,
              baseRig = baseRig
              )
    
    mc.parentConstraint( spineJoints[-2], rArmRig['baseAttachGrp'], mo = 1 )
    mc.parentConstraint( spineRig['bodyCtrl'].C, rArmRig['bodyAttachGrp'], mo = 1 )
    
    
    # left leg
    
    legJoints = ['l_hip1_jnt', 'l_knee1_jnt', 'l_foot1_jnt', 'l_foot2_jnt', 'l_foot3_jnt']
    topToeJoints = ['l_hindToeA1_jnt', 'l_hindToeB1_jnt', 'l_hindToeC1_jnt', 'l_hindToeD1_jnt', 'l_hindToeE1_jnt']
    
    lLegRig = leg.build( 
              legJoints = legJoints,
              topToeJoints = topToeJoints,
              pvLocator = 'l_leg_pole_vector_loc',
              scapulaJnt = '',
              prefix = 'l_leg',
              rigScale = sceneScale,
              baseRig = baseRig
              )
    
    mc.parentConstraint( spineJoints[-2], lLegRig['baseAttachGrp'], mo = 1 )
    mc.parentConstraint( spineRig['bodyCtrl'].C, lLegRig['bodyAttachGrp'], mo = 1 )
    
    
    # right leg
    
    legJoints = ['r_hip1_jnt', 'r_knee1_jnt', 'r_foot1_jnt', 'r_foot2_jnt', 'r_foot3_jnt']
    topToeJoints = ['r_hindToeA1_jnt', 'r_hindToeB1_jnt', 'r_hindToeC1_jnt', 'r_hindToeD1_jnt', 'r_hindToeE1_jnt']
    
    rLegRig = leg.build( 
              legJoints = legJoints,
              topToeJoints = topToeJoints,
              pvLocator = 'r_leg_pole_vector_loc',
              scapulaJnt = '',
              prefix = 'r_leg',
              rigScale = sceneScale,
              baseRig = baseRig
              )
    
    mc.parentConstraint( spineJoints[-2], rLegRig['baseAttachGrp'], mo = 1 )
    mc.parentConstraint( spineRig['bodyCtrl'].C, rLegRig['bodyAttachGrp'], mo = 1 )
    
    
    # head parts
    
    muzzleJoints = ['muzzle1_jnt', 'muzzle2_jnt']
    
    headParts.build( 
                  headJnt = headJnt,
                  jawJnt = jawJnt,
                  muzzleJoints = muzzleJoints,
                  leftEyeJnt = 'l_eye1_jnt',
                  rightEyeJnt = 'r_eye1_jnt',
                  prefix = 'headParts',
                  rigScale = sceneScale,
                  baseRig = baseRig
                  )
    
    
    
    
    


