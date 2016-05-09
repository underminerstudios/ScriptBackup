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

#from PyQt4.QtCore import QRect
import PyQt4, os, blurdev
from PyQt4 import QtCore, QtGui

import LightmapBaker.renderpresetname as rpn #rpn = Render 
from LightmapBaker.lm_globals import RenderingUtilities, VrayUtilities
vru = VrayUtilities()
ru = RenderingUtilities()


class LightmapBakerSettings( Dialog ):
	def __init__( self, parent):
		super(LightmapBakerSettings,self).__init__( parent )
		
		# load the ui
		PyQt4.uic.loadUi( os.path.split( __file__ )[0] + '\\ui\\lightmapbakersettings.ui', self )
		
		self.fillPresetComboBox()
		#Dialog.connect(self.ui_cmb_renderPresets, QtCore.SIGNAL('activated(QString)'), self.fillPresetComboBox)
		
		self.connect()
		
	def connect (self):
		'''Connect the widgets from the ui'''
		self.ui_btn_OK.clicked.connect(  self.closeSettingDialog )		
		self.ui_btn_reload.clicked.connect(  self.fillPresetComboBox )
		
		self.ui_btn_deleteCurrent.clicked.connect(  self.delRenderPreset )
		self.ui_btn_saveCurrent.clicked.connect(  self.launchPresetNameDialog )
		self.ui_btn_setRenderingPreset.clicked.connect( self.setRenderPreset )
		
		#self.ui_cmb_renderPresets.activated[str].connect(self.fillPresetComboBox)
		
	def setRenderPreset( self ):
		''' set the current selected setting to the scene'''
		presetName = str(self.ui_cmb_renderPresets.currentText())
		presetPath = ru.GetPresetPath()  + presetName
		mxs.renderpresets.LoadAll (0,  presetPath )
#		print presetName
		if presetName == 'vray_outside_settings.rps':
			sun = vru.GetVraySun()
			if sun == None:
				vru.SetVraySun()
				vru.SetVraySkyEnvironment()
				
		
	def delRenderPreset( self ):
		''' deletes the current render preset settings'''
		currentPreset = str(self.ui_cmb_renderPresets.currentText())
		currentIndex = self.ui_cmb_renderPresets.currentIndex()
		os.remove(ru.GetPresetPath() + currentPreset)
		self.fillPresetComboBox()
		self.ui_cmb_renderPresets.setCurrentIndex(currentIndex)
		
	def launchPresetNameDialog( self ):
		'''Launch a dialog box for saving presets'''
		nameDialog = rpn.RenderPresetName(self)
		nameDialog.setModal(True)
		nameDialog.show()
		
	def fillPresetComboBox( self ):
		'''Refreshes the the render preset QComboBox'''
		presets = os.listdir(ru.GetPresetPath())
		curText = self.ui_cmb_renderPresets.currentText()
		
		self.ui_cmb_renderPresets.clear()
		self.ui_cmb_renderPresets.addItems(presets)
		
		orgIndex = self.ui_cmb_renderPresets.findText(curText)
		self.ui_cmb_renderPresets.setCurrentIndex(orgIndex)

	#Save settings 	
	def closeSettingDialog(self):
		lmbDialog = LightmapBakerSettings(self)
		lmbDialog.recordSettings()
		self.close()
		
	def closeEvent( self, event ):
		self.recordSettings()
		super(LightmapBakerSettings,self).closeEvent( event )
		
	def recordSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/LightmapBakerSettings', shared=True )
		
		pref.recordProperty( 'texture_size', self.ui_cb_textureSizes.currentIndex() )
		pref.recordProperty( 'uv_channel', self.ui_spn_channel.value() )
		pref.recordProperty( 'dialation', self.ui_spn_dialation.value() )
		
		pref.recordProperty( 'network_render', int(self.ui_cbx_networkRender.checkState() ) )
		pref.recordProperty( 'network_address', self.ui_tx_networkadress.text())
		pref.recordProperty( 'use_wb_camera', int(self.ui_chb_useWBCamera.checkState() ))
		pref.recordProperty( 'delete_bake_mesh', int(self.ui_chb_deleteBakeMesh.checkState() ))
		pref.recordProperty( 'render_presets', self.ui_cmb_renderPresets.currentIndex() )
		
		pref.save()

	def restoreSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/LightmapBakerSettings', shared=True )
		cur_index = pref.restoreProperty( 'texture_size')
		uv_channel = pref.restoreProperty( 'uv_channel')
		dialation = pref.restoreProperty( 'dialation')

		network_render = pref.restoreProperty( 'network_render')
		network_address = pref.restoreProperty( 'network_address')
		use_wb_camera = pref.restoreProperty( 'use_wb_camera')
		delete_bake_mesh = pref.restoreProperty( 'delete_bake_mesh' )
		render_presets = pref.restoreProperty( 'render_presets' )
		
		if cur_index != None:
			self.ui_cb_textureSizes.setCurrentIndex(cur_index)
		if uv_channel != None:
			self.ui_spn_channel.setValue(uv_channel)
		if dialation != None:
			self.ui_spn_dialation.setValue(dialation)
		if network_render != None:
			self.ui_cbx_networkRender.setCheckState( network_render )
		if network_address != None:
			self.ui_tx_networkadress.setText(network_address)
		if use_wb_camera != None:
			self.ui_chb_useWBCamera.setCheckState(use_wb_camera) 
		if delete_bake_mesh != None:
			self.ui_chb_deleteBakeMesh.setCheckState(delete_bake_mesh)
		if render_presets != None:
			self.ui_cmb_renderPresets.setCurrentIndex(render_presets)

	def showEvent ( self, event):
		# restore settings from last session
		self.restoreSettings()
def __main__(  ):
	dialog = LightmapBakerSettings(None)
	dialog.show()
	return True
#__main__()