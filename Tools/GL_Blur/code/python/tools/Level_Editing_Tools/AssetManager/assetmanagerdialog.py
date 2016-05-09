##
#   :namespace  assetmanagerdialog
#
#   :remarks
#
#   :author     [author::anisim.kalugin@gameloft.com]
#   :author     [author::gameloft]
#   :date       09/13/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
from blurdev.gui import Dialog
from PyQt4 import QtGui, QtCore
from PyQt4.QtGui import QFileDialog
from PyQt4.QtCore import QRect
from blurdev import prefs

import math, sys, os
from Py3dsMax import mxs # import max module
nfy  = mxs.pyhelper.namify

#local libs
from AssetManager.lib.openglcanvas import OpenGLCanvas
from AssetManager.lib.assetmanagerdatamodel import AssetManagerDataModel
from AssetManager.lib.objloader import OBJ
from glmax.gl_material_utilities import MaterialUtilities
from UI.loaduistyle import LoadStyle

ui = LoadStyle()
mu = MaterialUtilities()
ob = OBJ()

#gameloft libs
from glmax.max3d import GLMax
from glmax.gl_material_utilities import MaterialUtilities
glm = GLMax()
mu = MaterialUtilities()

class AssetManagerDialog( Dialog ):
	def __init__( self, parent = None ):
		super(AssetManagerDialog,self).__init__( parent )
		# load the ui
		import blurdev
		blurdev.gui.loadUi( __file__, self )
		self.setStyleSheet(ui.getZStyleSheet())
		self.viewer3D 	= OpenGLCanvas(self)
		self.hlayout_opengl.addWidget(self.viewer3D)
		self.tableView = self.ui_tbl_PropNodes
		self.connect()
#		self.fillPackageDropdown()
		self.setAssetDataModel()
		
	def connect (self):
		#Explorer Tab
		self.ui_btn_projectFolder.clicked.connect(self.browseFolderAct)
		self.ui_cb_staticProps.clicked.connect(self.getPropNodes)
		self.tableView.clicked.connect(self.clickTableAct)
		self.ui_btn_editAsset.clicked.connect(self.openMaxAssetAct)
		self.ui_cb_packages.currentIndexChanged.connect(self.setAssetDataModel)
		self.tableView.doubleClicked.connect(self.doubleclickTableAct)
		
		#LibMaster Tab
		self.ui_btn_makePreview.clicked.connect(self.makePreviewAct)

		#OpenGL Section
		self.ui_btn_toggleAxis.clicked.connect(self.toggleAxis)
		self.ui_btn_toggleGrid.clicked.connect(self.toggleGrid)
		self.ui_btn_toggleHuman.clicked.connect(self.toggleHuman)
		self.ui_rb_mayaCamera.toggled.connect(self.setCanvasCameraMode)
		self.ui_rb_maxCamera.toggled.connect(self.setCanvasCameraMode)

#		self.ui_rb_fpsCamera.toggled.connect(self.setCanvasCameraMode)

	def setProjectPath(self):
		projectPath = self.getProjectPath()
		self.ui_le_rootPackagePath.setText(projectPath)	
			
	def getProjectPath(self):
		#TODO: Add error checking to see if the file exists
		iniFile = mxs.getDir(nfy('startupScripts')) +  "\\DH_LevelEditor_ProjectDir.ini"
		return mxs.GetINISetting (iniFile, "General", "project")
			
	def setCanvasCameraMode(self):
		self.cameraMode = str(self.sender().text())
		self.viewer3D.cameraMode = self.cameraMode.lower()
		
	def browseFolderAct(self):
		file = QFileDialog.getExistingDirectory(self, "Select Directory")
		if  len(file) != 0:
			self.ui_le_rootPackagePath.setText(file)
			self.fillPackageDropdown()
			self.setAssetDataModel()
			
		
	def convertMaterialToStandard(self):
		'''Converts material to a standard material'''
		for _node in mxs.Selection:
			#TODO: Add logic to parse Multimaterial
			if mxs.classof(_node.material) == mxs.Gl_Effect_Inst:
				matName = 'STD_' + _node.material.name
				matExist = mxs.sceneMaterials[matName]
				if matExist == None:
					newMat = mu.makeStandardMatFromGlitch(_node.material)
					_node.material = newMat
				else:
					_node.material = matExist
					
	def mergeAsset(self, maxFile):
		mxs.mergemaxfile( maxFile,\
					nfy( "select" ),\
					nfy( "mergeDups" ),\
					nfy( "useSceneMtlDups" ),\
					nfy( "alwaysReparent" ) )
		
		self.convertMaterialToStandard()
		
		transformNode = mxs.Dummy( pos = glm.getCenterBottomOfSelected() )

		for _node in mxs.selection:
			_node.parent = transformNode
			
		viewportTarget =  glm.getViewportTargetPosition()
		transformNode.position = viewportTarget[0]
		mxs.delete(transformNode)
		if viewportTarget[1] != None:
			for _node in mxs.selection:
				_node.parent = viewportTarget[1]
		else:
			pass
			#TODO: Find the nearest Module

		#TODO move the objects to the right layer
			
		
	def setAssetDataModel (self):
		tableData = self.getPropNodes()
		headers = ['Name','Type', 'Sub Type' ]
		
		self._proxyModel = QtGui.QSortFilterProxyModel()
		self.model = AssetManagerDataModel(tableData, headers)
		self._proxyModel.setSourceModel(self.model)
		self._proxyModel.setDynamicSortFilter(True)
		self._proxyModel.setFilterCaseSensitivity(QtCore.Qt.CaseInsensitive)

		self.tableView.setModel(self._proxyModel)
		self.tableView.setColumnWidth(0,90)
		self.tableView.setColumnWidth(1,50)
		self.tableView.setColumnWidth(2,50)	
		
	def getPropNodes(self):
		'''Fills tree based on ui selection'''
		project	= str(self.ui_le_rootPackagePath.text()) + '\\data_workspace\\packages\\'
		package = str(self.ui_cb_packages.currentText())
		
		if package == '':
			package = str(self.ui_cb_packages.currentText())
		
		self.initialDir = os.path.abspath(os.path.join( project, package, 'props' ))

		maxFiles = self.getMaxFiles(self.initialDir)

		propNodes = []
		if len(maxFiles) != 0:
			for file in maxFiles:
				tkns = file.split('\\')
				maxFileName = tkns[-1][0:-4]
				parentDir = tkns[-2]
				if parentDir != 'baking':
					if maxFileName == parentDir:
						tkns = file.split("\\")
						data = [tkns[-2], tkns[-4],tkns[-3], file, file[0:-3] + 'obj' ]
						propNodes.append(data)
#				if os.path.exists(file[0:-3] + 'obj' ) == True :
#					tkns = file.split("\\")
#					data = [tkns[-2], tkns[-4],tkns[-3], file, file[0:-3] + 'obj' ]
#					propNodes.append(data)
		return propNodes

	def getMaxFiles ( self, initialDir):
		list = []
		for root, dirs, files in os.walk(initialDir, topdown=False):
			for name in files:

				suffix = ".max"
				_path = (os.path.join(root, name))
				if _path.endswith(suffix):
					list.append( _path)
		#		print(name)
			for name in dirs:
				pass #print(os.path.join(root, name))

		return list		
		
	def fillPackageDropdown(self):
		_path = (self.ui_le_rootPackagePath.text())
		if _path != '':
			list = os.listdir(_path + '\\data_workspace\\packages\\')
			self.ui_cb_packages.clear()
			self.ui_cb_packages.addItems(list)
		
	
	def makePreview(self):
		exportLayer = glm.setLayer('export')
		oSel = mxs.selection
		previewFile = os.path.join(mxs.maxFilePath, (mxs.getFilenameFile( mxs.maxFileName) + ".obj"))
		obj = glm.snapshotObjectMerge( oSel )
		newMat = mu.condenseMultiMaterial ( obj )
		cleanMat = mu.makeCleanMaterial( newMat)

		
		obj.pivot = mxs.Point3( obj.center.x, obj.center.y, obj.min.z )
		obj.pos = mxs.Point3(0,0,0)
		obj.parent = None
		obj.material = cleanMat
		obj.material.name = mxs.getFilenameFile (mxs.maxFileName)

		mxs.select (obj)
		mxs.exportFile( previewFile, nfy('noPrompt'), selectedOnly = True )
		mxs.delete(obj)
		mxs.select(oSel)
		glm.deleteEmptyLayers()

	def fetchModelData(self, _index):
		dat = None
		dat= [str(_index.sibling(_index.row(),0).data(0).toString()),\
			  str(_index.sibling(_index.row(),1).data(0).toString()),\
			  str(_index.sibling(_index.row(),2).data(0).toString())]

		return dat
	def makePreviewAct(self):
		self.makePreview()
		self.setAssetDataModel()

	def doubleclickTableAct(self):
		''''''
		dat = self.fetchModelData(self.tableView.selectedIndexes()[0])
		maxFile = (self.model.getDataIndex(dat))[3]
		self.mergeAsset( maxFile )

		mxs.completeredraw()					
	def clickTableAct(self):	
		''''''
		dat = self.fetchModelData(self.tableView.selectedIndexes()[0])
		objPath = (self.model.getDataIndex(dat))[4]
		
		if os.path.exists( objPath ) == False:
			objPath = os.path.split( __file__ )[0] + '\\lib\\resource\\null.obj'

		self.viewer3D.previewObj 		= ob.getObjData(objPath, swapyz=False)
		self.viewer3D.previewObjCenter 	= ob.objectCenter
		self.viewer3D.previewObjBBox 	= ob.objectBBox

		self.viewer3D.objectDisplay = 1 #paintGridObject()
		self.viewer3D.repaint()		
		
	def openMaxAssetAct(self):
		dat = self.fetchModelData(self.tableView.selectedIndexes()[0])	
		maxFile = (self.model.getDataIndex(dat))[3]
		mxs.loadMaxFile(maxFile, useFileUnits=True, quiet=False)
		
	def toggleAxis(self):		
		if self.viewer3D.axisVisible == False:
			self.viewer3D.axisVisible = True
		else:
			self.viewer3D.axisVisible = False
		self.viewer3D.repaint()
	
	def toggleGrid(self):
		if self.viewer3D.gridVisible == False:
			self.viewer3D.gridVisible  = True
		else:
			self.viewer3D.gridVisible  = False
		self.viewer3D.repaint()

	def toggleHuman(self):
		if self.viewer3D.humanVisible == False:
			self.viewer3D.humanVisible  = True
		else:
			self.viewer3D.humanVisible  = False
		self.viewer3D.repaint()
		
	def keyPressEvent(self, event):
		''' (DEBUG) This is a good place to put actions '''
		if event.key() == QtCore.Qt.Key_Escape:
			self.close()
			
		if event.key() == QtCore.Qt.Key_1:
			self.toggleGrid()
			
		if event.key() == QtCore.Qt.Key_2:
			self.toggleAxis()
		
		if event.key() == QtCore.Qt.Key_3:
			self.toggleHuman()
			
		if event.key() == QtCore.Qt.Key_F:
			print "fit to object"
			
		if event.key() == QtCore.Qt.Key_A:
			self.viewer3D.setFocus()
			self.viewer3D.APressed 	= True
			
		if event.key() == QtCore.Qt.Key_S:
			self.viewer3D.setFocus()
			self.viewer3D.SPressed 	= True
			
		if event.key() == QtCore.Qt.Key_D:
			self.viewer3D.setFocus()
			self.viewer3D.DPressed 	= True
			
		if event.key() == QtCore.Qt.Key_W:
			self.viewer3D.setFocus()
			self.viewer3D.WPressed 	= True
			
		if event.key() == QtCore.Qt.Key_Q:
			self.viewer3D.setFocus()
			self.viewer3D.QPressed 	= True
			
		if event.key() == QtCore.Qt.Key_E:
			self.viewer3D.setFocus()
			self.viewer3D.EPressed 	= True
			
		if event.key() == QtCore.Qt.Key_Alt:
			self.viewer3D.setFocus()
			self.viewer3D.AltPressed  = True

		if event.key() == QtCore.Qt.Key_Control:
			self.viewer3D.setFocus()
			self.viewer3D.CtrPressed  = True

			
	def keyReleaseEvent(self, event):
		if event.key() == QtCore.Qt.Key_Alt:
			self.viewer3D.AltPressed  = False
			
		if event.key() == QtCore.Qt.Key_Control:
			self.viewer3D.CtrPressed  = False
			
		if event.key() == QtCore.Qt.Key_A:
			self.viewer3D.setFocus()
			self.viewer3D.APressed  = False
			
		if event.key() == QtCore.Qt.Key_S:
			self.viewer3D.setFocus()
			self.viewer3D.SPressed  = False
			
		if event.key() == QtCore.Qt.Key_D:
			self.viewer3D.setFocus()
			self.viewer3D.DPressed  = False
			
		if event.key() == QtCore.Qt.Key_W:
			self.viewer3D.setFocus()
			self.viewer3D.WPressed  = False
			
		if event.key() == QtCore.Qt.Key_Q:
			self.viewer3D.setFocus()
			self.viewer3D.QPressed  = False
			
		if event.key() == QtCore.Qt.Key_E:
			self.viewer3D.setFocus()
			self.viewer3D.EPressed  = False

		
	def closeEvent( self, event ):
		r"""
			\remarks    [virtual]   overload the close event to handle saving of preferences before shutting down
			\param      event       <QEvent>
		"""
		self.recordSettings()
		super(AssetManagerDialog,self).closeEvent( event )

	
	def recordSettings( self ):
		r"""
			\remarks	records settings to be used for another session
		"""
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/AssetManager', shared=True )
		

		# record the geometry
		pref.recordProperty( 'geom', self.geometry() )
		pref.recordProperty( 'project_path', self.ui_le_rootPackagePath.text())
		pref.recordProperty( 'project_package', int(self.ui_cb_packages.currentIndex()) )
#		print self.ui_cb_packages.currentIndex()
		
		pref.recordProperty( 'ogl_grid', self.viewer3D.gridVisible)
		pref.recordProperty( 'ogl_axis', self.viewer3D.axisVisible)
		pref.recordProperty( 'ogl_scale', self.viewer3D.humanVisible)
		
		#camera mode save
		if self.ui_rb_mayaCamera.isChecked() == True:
			pref.recordProperty( 'ogl_cam', 'maya')
		if self.ui_rb_maxCamera.isChecked() == True:
			pref.recordProperty( 'ogl_cam', 'max')


		pref.save()
	
	def restoreSettings( self ):
		r"""
			\remarks    restores settings that were saved by a previous session
		"""
		
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/AssetManager', shared=True )
		
		# reload the geometry
		
		geom = pref.restoreProperty( 'geom', QRect() )
		projectPath = pref.restoreProperty('project_path')
		
		if len(projectPath) == 0:
			self.setProjectPath()
		else:
			self.ui_le_rootPackagePath.setText(projectPath)
			
		self.fillPackageDropdown()
		self.viewer3D.gridVisible = int(pref.restoreProperty( 'ogl_grid' ))
		self.viewer3D.axisVisible = int(pref.restoreProperty( 'ogl_axis' ))
		self.viewer3D.humanVisible = int(pref.restoreProperty( 'ogl_scale'))
		
		cameraMode = pref.restoreProperty( 'ogl_cam')
		if cameraMode == 'maya':
			self.ui_rb_mayaCamera.setChecked(True)
		if cameraMode == 'max':
			self.ui_rb_maxCamera.setChecked(True)
			
		try:
			self.ui_cb_packages.setCurrentIndex( int( pref.restoreProperty( 'project_package' ) ) )
		except:
			print "doesn't exist."

		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )

	def showEvent ( self, event):
		r"""
			\remarks    [virtual]   overload the show event to handle loading of preferences when displaying
			\param      event       <QEvent>
		"""
		# restore settings from last session
		self.restoreSettings()

def __main__(  ):
	dialog = AssetManagerDialog()
	dialog.show()
	return True
#__main__()
#height2ssbump.exe -A D:\Projects\DH5\DH5\data_workspace\packages\magginaos\props\static\pillar_barrier\_atlas_magginaos_ext_barrier_pillar_a_h.tga 1.0
