import sys, os
from PyQt4 import QtGui, QtCore
from blurdev.gui import Dialog
from Py3dsMax import mxs # import max module

from LightmapBaker.lm_globals import RenderingUtilities
ru = RenderingUtilities()

class RenderPresetName( Dialog ):
	def __init__( self, parent):
		super(RenderPresetName,self).__init__( parent )
		# load the ui
		self.le_presetName  = QtGui.QLineEdit()
		self.le_presetName.setMinimumSize(QtCore.QSize(100, 23))
		btn_ok          = QtGui.QPushButton("OK")
		btn_ok.setMaximumSize(QtCore.QSize(23, 23))
		
		hLayout 		= QtGui.QHBoxLayout()
		gLayout		= QtGui.QGridLayout(self)

		hLayout.addWidget(self.le_presetName, 0)
		hLayout.addWidget(btn_ok, 1)

		gLayout.addLayout(hLayout, 0, 0, 1, 1)

		self.setWindowTitle('Set Preset Name')
		
		btn_ok.clicked.connect(self.saveRenderPreset)
		
	def saveRenderPreset (self):
		#print len(self.le_presetName.text())
#		print (self.le_presetName.setText('Hello'))
		if len(self.le_presetName.text()) != 0:
			
			presetName = str(self.le_presetName.text() + '.rps')
			
			presetName = self.stripString(presetName)
			
			presetPath = ru.GetPresetPath() + presetName
			mxs.renderpresets.SaveAll (0,  presetPath )
			self.close()
			
	def stripString(self, string):
		'''removes unwanted characthers from any given string'''
		return filter(lambda x: x not in '/\\><:*?\"|', string)

			
		
def __main__(  ):
	dialog = RenderPresetName(None)
	return True
#__main__()
