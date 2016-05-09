##
#   :namespace  lightmapbakerdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       06/03/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
from blurdev.gui import Dialog
from blurdev import prefs
from Py3dsMax import mxs # import max module

nfy  = mxs.pyhelper.namify

#from PyQt4.QtCore import QRect
import PyQt4, os, blurdev
from PyQt4 import QtCore, QtGui
from PyQt4.QtCore import *
from PyQt4.QtGui import *

from  glmax.max3d import GLMax
glm = GLMax()

import LightmapBaker.renderpresetname as rpn #rpn = Render 
from LightmapBaker.lm_globals import RenderingUtilities, VrayUtilities, LightMapUtilities
vru = VrayUtilities()
ru = RenderingUtilities()
lmu = LightMapUtilities()
import shutil, os, time
#def fixPathSlashes(path, stringChange):
#	'''changes the paht from "\\" to "/" '''

		
#node = mxs.getnodebyname('LM1_')
#NetRenderMesh(node)

class Sandbox( Dialog ):
	def __init__( self, parent):
		super(Sandbox,self).__init__( parent )
		
		# load the ui
		PyQt4.uic.loadUi( os.path.split( __file__ )[0] + '\\ui\\sandbox.ui', self )
		
		self.bakeMeshNames 		= ['MainLM', 'AlphaLM', 'DecalsLM', 'TempLM']
		self.layerVisibility	= []
		
#		self.setUIDisabled()
#		self.gridLayoutMain = QtGui.QGridLayout(self)
#		self.gridLayoutMain.addWidget(self.ui_btn_bakeMode, 0, 0, 1, 1)
#		self.addGridLayoutCollapsed()
#		self.setGeometry( newSize )
		
#		self.geometry().setSize(newSize)

#		geom = pref.restoreProperty( 'geom', QRect() )
#		if ( geom and not geom.isNull() ):
			
		self.connect()
		
	def connect (self):
		'''Connect the widgets from the ui'''
		self.ui_btn_bakeMode.clicked.connect( self.destroyGridLayout )
		self.ui_btn_BakeLightmap.clicked.connect(self.setUIDisabled)
		
	#Save settings 	
	def destroyGridLayout(self):
#		'removeItem', 'removeWidget'
#		self.gridLayoutMain.removeWidget(self.ui_btn_bakeMode)
		self.gridLayoutMain.removeWidget(self.pushButton)
		self.gridLayoutMain.removeItem(self.horizontalLayout_2)
		self.gridLayoutMain.removeItem(self.horizontalLayout)
		self.pushButton.hide()
		self.ui_chb_bakeLightMap.hide()
		self.ui_chb_bakeAO.hide()
		self.ui_chb_bakeDirectionalLM.hide()
		self.ui_btn_BakeLightmap.hide()
		self.setMaximumHeight(35)
		newSize = QtCore.QRect(51,50, 315, 35)
		self.setGeometry( newSize )
#		self.gridLayoutMain.update()
#		print (self.gridLayoutMain.maximumSize())
#		self.destroyGridLayout()
		print (dir(self.geometry()))
		print (dir(self.gridLayoutMain.setGeometry))
#		self.destroyGridLayout()
		
	def setUIDisabled (self):
		self.pushButton.hide()
		self.ui_chb_bakeLightMap.hide()
		self.ui_chb_bakeAO.hide()
		self.ui_chb_bakeDirectionalLM.hide()
		self.ui_btn_BakeLightmap.hide()
		

		

		
	def setUIEnabled (self):
		self.pushButton.show()
		self.ui_chb_bakeLightMap.show()
		self.ui_chb_bakeAO.show()
		self.ui_chb_bakeDirectionalLM.show()
		self.ui_btn_BakeLightmap.show()
		
		self.addGridLayoutExpanded()
		newSize = QtCore.QRect(50,50, 315, 330)
		self.setGeometry( newSize )
#		

	def addGridLayoutExpanded(self):
		self.gridLayoutMain = QtGui.QGridLayout()
		self.gridLayoutMain.setMargin(3)
		self.gridLayoutMain.setSpacing(2)
		self.gridLayoutMain.addWidget(self.ui_btn_bakeMode, 0, 0, 1, 1)
		self.gridLayoutMain.addWidget(self.pushButton, 1, 0, 1, 1)
		self.gridLayoutMain.addLayout(self.horizontalLayout_2, 2, 0, 1, 1)
		self.gridLayoutMain.addLayout(self.horizontalLayout, 3, 0, 1, 1)
		
	def addGridLayoutCollapsed(self):
		''' '''
#		print (self.gridLayoutMain)
#		if self.gridLayoutMain != None:
			
		self.gridLayoutMain = QtGui.QGridLayout(self)
		self.gridLayoutMain.addWidget(self.ui_btn_bakeMode, 0, 0, 1, 1)
#		self.gridLayoutMain.setMargin(3)
#		self.gridLayoutMain.setSpacing(2)


	def closeSettingDialog(self):
		lmbDialog = Sandbox(self)
		lmbDialog.recordSettings()
		self.close()
		
	def closeEvent( self, event ):
		self.recordSettings()
		super(Sandbox,self).closeEvent( event )
		
	def recordSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/sandboxsettings', shared=True )
		pref.save()

	def restoreSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/sandboxsettings', shared=True )

	def showEvent ( self, event):
		# restore settings from last session
		self.restoreSettings()
def __main__(  ):
	dialog = Sandbox(None)
	dialog.show()
	return True
__main__()
#for obj in mxs.objects:
#	superObjectType = glm.superClassOf (obj)
#	if superObjectType == 'GeometryClass':
#		objectType = glm.classOf (obj)
#		print objectType