# ============================
# komodo rig
# ============================

import maya.cmds as mc
import rigLib
import komodoRig

reload(rigLib.base.module)
reload(rigLib.base.control)
reload(rigLib.rig.spine)
reload(rigLib.rig)
reload(rigLib.rig.neck)
reload(rigLib.rig.headParts)
reload(rigLib.rig.ikChain)
reload(rigLib.rig.leg)
reload(komodoRig)
reload(komodoRig.komodo)
reload(komodoRig.komodo_deform)

characterName = 'komodo'
komodoRig.komodo.build( characterName )

# save skin weights
geoList = mc.ls(sl=1)
komodoRig.komodo_deform.saveSkinWeights( characterName, geoList )

# load skin weights
geoList = mc.ls(sl=1)
geoList = []
komodoRig.komodo_deform.loadSkinWeights( characterName, geoList )

# bSkinSaver UI
from rigTools import bSkinSaver
bSkinSaver.showUI()
