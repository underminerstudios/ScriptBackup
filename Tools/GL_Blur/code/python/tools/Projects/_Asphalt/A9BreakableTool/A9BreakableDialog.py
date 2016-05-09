import os
import operator

import blurdev
from blurdev import prefs
from blurdev.gui import Dialog
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from Py3dsMax import mxs # import max module

import sys
import getopt
from  a9.a9fn import a9GeneralFunctions
from a9.a9fn import a9Breakables

a9fn = a9GeneralFunctions()
a9brk = a9Breakables()



class A9BreakableDialog(Dialog):


	def __init__(self, parent=None):
		super(A9BreakableDialog, self).__init__(parent)
		blurdev.gui.loadUi(__file__, self)
		iconfp = os.path.join(os.path.dirname(__file__), 'img', 'icon.png')
		self.setWindowIcon(QIcon(iconfp))
		self.restoreSettings()
		self.setWindowTitle('A9 Breakable Tool')
		self.connect()

	def connect(self):
		self.ui_btn_createBreakable.clicked.connect(self.createBreakable)
		self.ui_btn_getExportPath.clicked.connect(self.getExportPath)
		self.ui_btn_exportBreakable.clicked.connect(self.exportBreakable)

	
	def createBreakable(self):
		breakablename = self.ui_ln_breakableName.text()
		oSel = mxs.selection
		mxs.execute("function applyXForm = (modPanel.addModToSelection (XForm ()))")
		if mxs.selection:
			for obj in mxs.selection:
				mxs.select(obj)
				mxs.applyXForm()
				mxs.converttopoly(obj)
				a9brk.moveToLayer('0',obj)
				
			a9brk.compareObjectArray(oSel,breakablename)
			baseObj = mxs.getNodeByName('mergedObject')
			if self.ui_ln_breakableName.text() != '':
				baseObj.name = str(self.ui_ln_breakableName.text()) + '_Base'
			else:
				baseObj.name = 'BaseObject'
			a9brk.createCollisionVol(baseObj)
			for obj in baseObj.children:
				a9brk.moveToLayer('BaseObject',obj)
			
	def getExportPath(self):
		if os.path.isdir(str(self.ui_ln_exportPath.text())):
			oPath = (str(self.ui_ln_exportPath.text()))
		else:
			oPath = "T:\\data\\Map\\"
		expPath = QFileDialog.getExistingDirectory(self, 'Browse Scene Directory', oPath)
		self.ui_ln_exportPath.setText(expPath)	
			

	def exportBreakable(self):
		exportpath = str(self.ui_ln_exportPath.text())
		breakablename = self.ui_ln_breakableName.text()

		if os.path.isdir(exportpath):
			baseObjectLayer = (mxs.LayerManager.getLayerFromName('BaseObject'))
			if baseObjectLayer:
				exportpath = str(self.ui_ln_exportPath.text())
				mxs.execute("function getLayerNodes layerInterface = ( layerInterface.nodes &outputList; outputList)")
				objnodes = mxs.getLayerNodes(baseObjectLayer)
				mxs.select(objnodes)
				exportpath = (exportpath + '\\' + breakablename + '_Base.bdae')
				mxs.CM_ExportFile(exportpath, export_selected = True, selected_preset = "Visual")
			archObjectLayer = (mxs.LayerManager.getLayerFromName('Archetype'))
			if archObjectLayer:
				exportpath = str(self.ui_ln_exportPath.text())
				mxs.execute("function getLayerNodes layerInterface = ( layerInterface.nodes &outputList; outputList)")
				objnodes = mxs.getLayerNodes(archObjectLayer)
				for obj in objnodes:
					tagname = obj.name[-4:]
					if tagname != '_col':
						exportpath = str(self.ui_ln_exportPath.text())
						expObj = []
						for col in obj.children:
							expObj.append(col)
						expObj.append(obj)
						mxs.select(expObj)
						exportpath = (exportpath + '\\' + obj.name + '.bdae')
						mxs.CM_ExportFile(exportpath, export_selected = True, selected_preset = "Visual")



	def closeEvent(self, event):
		self.recordSettings()
		super(A9BreakableDialog, self).closeEvent(event)

	def recordSettings(self):
		pass

	def restoreSettings(self):
		pass
