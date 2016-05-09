##
#   :namespace  dh5toolsdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       06/19/13
#
#000_benchmark_01
# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
import os, blurdev, PyQt4
from blurdev.gui import Dialog
from blurdev import prefs


from PyQt4.QtGui import 	QIcon, QDialog, QTreeWidgetItem
from PyQt4.QtCore import 	QString, QPoint, SIGNAL, Qt, QObject

from Py3dsMax import mxs # import max module
from  glmax.max3d import 	GLMax
glm = GLMax()
from  dh5.selections import DH5Selections
dhs = DH5Selections()
from  dh5.tagging import 	DH5Tagging
dht = DH5Tagging()
from  dh5.conformer import 	DH5Conformer
dhc = DH5Conformer()
from  dh5.exporter import 	DH5Export
dhe = DH5Export()
from  glmax.gl_material_utilities import MaterialUtilities
mu = MaterialUtilities()
from UI.loaduistyle import LoadStyle
ui = LoadStyle()
nfy  = mxs.pyhelper.namify

class DH5ToolsDialog( Dialog ):

	def __init__( self, parent = None ):
		super(DH5ToolsDialog,self).__init__( parent )
		# load the ui
		blurdev.gui.loadUi( __file__, self )
		self.setStyleSheet(ui.getZStyleSheet())
		

		
		self.irradColor = None
		
		self.EXPORT_NAME = dhe.getExportName()
		self.toolPath 		= os.path.split( __file__ )[0]
		self.uiImagePath	= self.toolPath + '/img/'
		
		self.icoShown 		= QIcon (self.uiImagePath + 'eye.png')
		self.icoHidden 		= QIcon (self.uiImagePath + 'eye_close.png')

		self.meshToggle 	= self.getSubComponentVisibilty('mesh')
		self.alphaToggle 	= self.getSubComponentVisibilty('alpha')
		self.decalsToggle 	= self.getSubComponentVisibilty('decal')
		
		self.floorToggle 	= self.getLayerVisibility('FLOOR')
		self.irradToggle 	= self.getLayerVisibility('IRRADIANCE')
		self.modulesToggle 	= self.getLayerVisibility('MODULES')
		
		if self.meshToggle 		== True:
			self.ui_btn_toggleMesh.setIcon(self.icoShown)
		if self.meshToggle 		!= True:
			self.ui_btn_toggleMesh.setIcon(self.icoHidden)
			
		if self.alphaToggle 	== True:
			self.ui_btn_toggleAlpha.setIcon(self.icoShown)
		if self.alphaToggle		!= True:
			self.ui_btn_toggleAlpha.setIcon(self.icoHidden)
			
		if self.decalsToggle 	== True:
			self.ui_btn_toggleDecals.setIcon(self.icoShown)
		if self.decalsToggle	!= True:
			self.ui_btn_toggleDecals.setIcon(self.icoHidden)
			
		if self.floorToggle 	== True:
			self.ui_btn_toggleFloor.setIcon(self.icoShown)
		if self.floorToggle 	!= True:
			self.ui_btn_toggleFloor.setIcon(self.icoHidden)
			
		if self.irradToggle 	== True:
			self.ui_btn_toggleIrrad.setIcon(self.icoShown)
		if self.irradToggle 	!= True:
			self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
			
		if self.modulesToggle 	== True:
			self.ui_btn_toggleModules.setIcon(self.icoShown)
		if self.modulesToggle 	!= True:
			self.ui_btn_toggleModules.setIcon(self.icoHidden)

		self.refreshTreeView()
		
		self.connect()

	def connect(self):
		#Tagging Tab
		self.ui_btn_tag.clicked.connect					(self.tagSelectedBnt)
		self.ui_btn_clear.clicked.connect				(self.clearTagsBtn)
		self.ui_btn_select.clicked.connect				(self.selectByTagBtn)
		self.ui_btn_rename.clicked.connect				(self.renameMeshBtn)
		self.ui_btn_selectMesh.clicked.connect			(self.selectMeshBtn)
		self.ui_btn_selectModules.clicked.connect		(self.selectModulesBtn)
		self.ui_btn_selectFloor.clicked.connect			(self.selectFloorBtn)
		self.ui_btn_selectAlpha.clicked.connect			(self.selectAlphaBtn)
		self.ui_btn_selectLM1.clicked.connect			(self.selectLM1Btn)
		self.ui_btn_selectLM2.clicked.connect			(self.selectLM2Btn)
		self.ui_btn_selectLM3.clicked.connect			(self.selectLM3Btn)
		self.ui_btn_selectLM4.clicked.connect			(self.selectLM4Btn)
		self.ui_cb_floor_tagger.currentIndexChanged.connect			(self.tagFloorChanged)
		
		# Level Editing group
		self.ui_btn_deleteEmptyNodes.clicked.connect	(self.deleteEmptyNodesBtn)
		self.ui_btn_superRestXform.clicked.connect		(self.superRestXformBtn)
		self.ui_btn_mergeSeleted.clicked.connect		(self.mergeSeletedBtn)
		self.ui_btn_separateSeleted.clicked.connect		(self.separateSeletedBtn)
		self.ui_btn_pivotToBottom.clicked.connect		(self.pivotToBottomBtn)
		self.ui_btn_pivotToSelected.clicked.connect		(self.pivotToSelectedBtn)
		self.ui_btn_moveToGround.clicked.connect		(self.moveToGroundBtn)
		self.ui_btn_isolateLayer.clicked.connect		(self.isolateLayerBtn)
		
		# MATERIAL TAB
		self.ui_btn_matToVray.clicked.connect			(self.matToVray)
		self.ui_btn_matToStandard.clicked.connect		(self.matToStandard)
		self.ui_btn_matToGlitch.clicked.connect			(self.matToGlitch)
		self.ui_btn_selectByMatID.clicked.connect		(self.selectByMatIDBtn)
		
		# SCENE MANAGER TAB
		self.ui_btn_sceneConformer.clicked.connect		(self.conformSceneBtn)
		
		#QT doesn't come with rightclicked singal so we use "customContextMenuRequested"
		#kinda hacking but it works :).
		self.ui_btn_toggleMesh.setContextMenuPolicy(Qt.CustomContextMenu)
		QObject.connect(self.ui_btn_toggleMesh, SIGNAL('clicked()'), self.toggleMeshBtn)  
		QObject.connect(self.ui_btn_toggleMesh, SIGNAL('customContextMenuRequested(const QPoint&)'), self.isolateMeshBtn)
		
		self.ui_btn_toggleAlpha.setContextMenuPolicy(Qt.CustomContextMenu)
		QObject.connect(self.ui_btn_toggleAlpha, SIGNAL('clicked()'), self.toggleAlphaBtn)  
		QObject.connect(self.ui_btn_toggleAlpha, SIGNAL('customContextMenuRequested(const QPoint&)'), self.isolateAlphaBtn)

		self.ui_btn_toggleDecals.setContextMenuPolicy(Qt.CustomContextMenu)
		QObject.connect(self.ui_btn_toggleDecals, SIGNAL('clicked()'), self.toggleDecalsBtn)  
		QObject.connect(self.ui_btn_toggleDecals, SIGNAL('customContextMenuRequested(const QPoint&)'), self.isolateDecalsBtn)

		self.ui_btn_toggleFloor.clicked.connect			(self.toggleFloorBtn)
		self.ui_btn_treeRefresh.clicked.connect			(self.treeRefreshBtn)
		
		self.ui_btn_toggleIrrad.clicked.connect			(self.toggleIrradBtn)
		self.ui_btn_toggleModules.clicked.connect		(self.toggleModulesBtn)
		#TreeviewWidget Manipulation
		self.ui_tv_sceneElements.itemClicked.connect	(self.sceneElementsClicked)
		
		#EXPORT TAB
		#-----------export settings--------------
		self.ui_btn_getLatest.clicked.connect			(self.getLatestBtn)
		self.ui_btn_getRawData.clicked.connect 			(self.getLatestRawDataBtn)
		self.ui_btn_SetExportProps.clicked.connect		(self.setExportNameBtn)
		
		self.ui_led_exportName.setText					(self.EXPORT_NAME) 
		
		#-----------export section --------------
		self.ui_btn_exportModules.clicked.connect (self.exportModulesBtn)
		
#		self.ui_btn_exportIrradiance.clicked.connect (self.exportIrradianceBtn)
		self.ui_btn_exportStreaming.clicked.connect (self.exportStreamingBtn)
		self.ui_btn_exportAll.clicked.connect (self.exportAllBtn)
		self.ui_btn_color.clicked.connect(self.getColorBtn)
		
	def tagFloorChanged(self):
		sel = mxs.selection
		tagType = self.ui_cb_floor_tagger.currentText() 
#		print len(tagType)
		for obj in sel:
			if obj.name[0:7] == '_floor_':
				if tagType != '-----------------------' and len(tagType) != 0:
					glm.setUserDefinedProps ( obj, "floortypes", tagType )
		
	def treeRefreshBtn(self):
		self.refreshTreeView()
		self.refreshSceneManagerUI()

	def selectByMatIDBtn(self):
		ID = int(self.ui_spn_matID.value () )
		meshes = glm.selectMeshbyID(ID, False)
		mxs.select(meshes)
		mxs.completeRedraw()
		
	def isolateLayerBtn(self):
		glm.isolateLayersBySelected()
		mxs.completeRedraw()
	
	def moveToGroundBtn(self):
		glm.moveToGround()
		mxs.completeRedraw()
		
	def superRestXformBtn(self):
		oSel = mxs.selection
		for obj in oSel:
			glm.resetXform(obj)
			mxs.convertTo( obj, mxs.PolyMeshObject)
		mxs.completeRedraw()
			
	def pivotToSelectedBtn(self):
		glm.setPivotToSelected()
		mxs.completeRedraw()	
					
	def pivotToBottomBtn(self):
		oSel = mxs.selection
		for obj in oSel:
			if mxs.superClassOf(obj) == mxs.GeometryClass:
				obj.pivot = mxs.point3(obj.center.x, obj.center.y, obj.min.z)
		mxs.completeRedraw()
						
	def deleteEmptyNodesBtn(self):
		glm.deleteEmptyNodes()
		mxs.completeRedraw()
		
	def mergeSeletedBtn(self):
		oSel = mxs.selection
		mergedObj = glm.snapshotObjectMerge(oSel)
		mxs.delete(oSel)
		mergedObj.pivot = mergedObj.center
		mxs.select(mergedObj)
		mxs.completeRedraw()
		
	def separateSeletedBtn(self):
		meshList = glm.separateSelected()
		mxs.select(meshList)
		mxs.completeRedraw()
				
	def getColorBtn(self):
		'''Opens a color dialog and sets the color of the button'''
		col = QColorDialog.getColor()
		if col.isValid():
			self.irradColor =  col.getRgb()
			self.ui_btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"\
			% (self.irradColor[0], self.irradColor[1], self.irradColor[2]) )
			
	def getColorFromBtn(self, ui_element):
		'''gets the color from a buttons stylesheet'''
		count = len(ui_element.styleSheet())
		color = (ui_element.styleSheet()[22:-1]).split(',')
		return [float(color[0]), float(color[1]), float(color[2])]
		
	def getIrradianceExportSettings(self):
		r'''get the ui setting for the irradiance export'''
		directState 		= self.ui_cbx_directIrr.checkState ()
		indirectState		= self.ui_cbx_indirectIrr.checkState ()
		viewRenderState		= self.ui_cbx_viewRender.checkState ()
		directIrrScale		= self.ui_spn_directIrr.value () 
		indirectIrrScale	= self.ui_spn_indirectIrr.value () 
		backgroundColor 	= self.getColorFromBtn( self.ui_btn_color )
		
		settingsString = ''
		if directState ==2:
			settingsString += " -direct"
		if indirectState ==2:
			settingsString += " -indirect"
		if viewRenderState ==2:
			settingsString += " -feedback"
			
		settingsString += " -scaleIndirect " + str(indirectIrrScale)
		settingsString += " -scaleDirect " + str(directIrrScale)
		
		settingsString += " -BGColorR " + str(backgroundColor[0] )
		settingsString += " -BGColorG " + str(backgroundColor[1])
		settingsString += " -BGColorB " + str(backgroundColor[2])
		
		return settingsString
		
	def exportIrradianceBtn(self):
		r'''export the irradiance of the scene'''
		destPath	= self.ui_led_ExportPath.text()
		exportName	= self.ui_led_exportName.text()
		irradSettings = self.getIrradianceExportSettings()
		dhe.exportIrradianceBDEA(str(destPath), str(exportName), str(irradSettings))
		mxs.completeRedraw()
		
	def exportModulesBtn(self):
		r'''Export modules and floor from the scene'''
		destPath	= self.ui_led_ExportPath.text()
		exportName	= self.ui_led_exportName.text()
		dhe.exportBDEA( str(destPath), str(exportName))
		mxs.completeRedraw()

	def exportStreamingBtn(self):
		r'''Export streaming section of the scene'''
		destPath	= self.ui_led_ExportPath.text()
		exportName	= self.ui_led_exportName.text()
		dhe.exportBDEA( str(destPath), str(exportName))
		dhe.exportStreamingBDEA (str(destPath), str(exportName) )
		mxs.completeRedraw()
	
	def exportAllBtn(self):
		r'''Exports modules and streaming for the scene'''
		destPath	= self.ui_led_ExportPath.text()
		exportName	= self.ui_led_exportName.text()
		dhe.exportBDEA( str(destPath), str(exportName))
		dhe.exportStreamingBDEA (str(destPath), str(exportName) )
		mxs.completeRedraw()
		
	def setExportNameBtn(self):
		r'''sets the export name from the textedit'''
		name = str(self.ui_led_exportName.text())
		dhe.setExportName(name)
		
	def setVisibilityOnParentTreeNode (self, treeNode):
						
		layerName = treeNode.text(2) #get the name from the treenode string

		layer = mxs.LayerManager.getLayerFromName(layerName)

		if layer.ishidden == True:
			treeNode.setIcon (1, self.icoHidden)
		if layer.ishidden != True:
			treeNode.setIcon (1, self.icoShown)

	def sceneElementsClicked(self):

		tv_Node 		= (self.ui_tv_sceneElements.selectedItems())[0]
		tv_LayerName 	= tv_Node.text(2)

		if self.ui_tv_sceneElements.currentColumn() == 1 :
			#Do scene manipulation if the second column is clicked on the treeview
			
			if tv_LayerName != 'Mesh' and tv_LayerName != 'Alpha'and tv_LayerName != 'Decals':
				moduleSubTypes 	= self.getModuleSubTypes (tv_LayerName)
				layer = mxs.ILayerManager.getLayerObject ( tv_LayerName )
				if layer.ishidden == True:
					layer.ishidden = False
					tv_Node.setIcon (1, self.icoShown)
				
					for i in range (0, 3):
						childTreeNode = tv_Node.child(i)
						iconVisibilty = self.getModuleSubTypeVisibilty ( moduleSubTypes[i])
						self.setModuleSubGeoVisibilty(iconVisibilty, moduleSubTypes[i] )
						if iconVisibilty == False:
							childTreeNode.setIcon (1, self.icoHidden)
						elif iconVisibilty == True:
							childTreeNode.setIcon (1, self.icoShown)
	
				elif layer.ishidden == False:
					layer.ishidden = True
					tv_Node.setIcon (1, self.icoHidden)
					for i in range (0, 3):
						childTreeNode = tv_Node.child(i)
						childTreeNode.setIcon (1, self.icoHidden)
						
			#Work on the sub geometry types				
			elif tv_LayerName == 'Mesh':
				moduleSubTypes = self.getModuleSubTypes (tv_Node.parent().text(2))
				meshObjects	   = moduleSubTypes[0]
				iconVisibilty  = self.getModuleSubTypeVisibilty ( meshObjects )
				self.setModuleSubGeoVisibilty(iconVisibilty, meshObjects )
				
				if iconVisibilty == False:
					tv_Node.setIcon (1, self.icoShown)
					self.setModuleSubGeoVisibilty(True, meshObjects )
					
				elif iconVisibilty == True:
					tv_Node.setIcon (1, self.icoHidden)
					self.setModuleSubGeoVisibilty(False, meshObjects )
				self.setVisibilityOnParentTreeNode (tv_Node.parent())
			
			elif tv_LayerName == 'Alpha':
				moduleSubTypes = self.getModuleSubTypes (tv_Node.parent().text(2))
				alphaObjects   = moduleSubTypes[1]
				iconVisibilty  = self.getModuleSubTypeVisibilty ( alphaObjects )
				self.setModuleSubGeoVisibilty(iconVisibilty, alphaObjects )
				
				if iconVisibilty == False:
					tv_Node.setIcon (1, self.icoShown)
					tv_Node.parent().setIcon (1, self.icoShown)
					self.setModuleSubGeoVisibilty(True, alphaObjects )
				elif iconVisibilty == True:
					tv_Node.setIcon (1, self.icoHidden)
					tv_Node.parent().setIcon (1, self.icoHidden)
					self.setModuleSubGeoVisibilty(False, alphaObjects )
					
				self.setVisibilityOnParentTreeNode (tv_Node.parent())
				
			elif tv_LayerName == 'Decals':
				moduleSubTypes = self.getModuleSubTypes (tv_Node.parent().text(2))
				decalObjects   = moduleSubTypes[2]
				iconVisibilty  = self.getModuleSubTypeVisibilty ( decalObjects )
				
				self.setModuleSubGeoVisibilty(iconVisibilty, decalObjects )
				if iconVisibilty == False:
					tv_Node.setIcon (1, self.icoShown)
					tv_Node.parent().setIcon (1, self.icoShown)
					self.setModuleSubGeoVisibilty(True, decalObjects )
				elif iconVisibilty == True:
					tv_Node.setIcon (1, self.icoHidden)
					tv_Node.parent().setIcon (1, self.icoHidden)
					self.setModuleSubGeoVisibilty(False, decalObjects )
					
				self.setVisibilityOnParentTreeNode (tv_Node.parent())
				
		mxs.completeRedraw()

	def conformSceneBtn(self):
		r'''Confroms specified by the artists'''
		glm.unhideAll()
		dhc.conformModules()
		dhc.confromMeshes ()
		dhc.conformSceneLights()

		glm.isolateLayersByString('M_' )
		
		self.refreshTreeView()
		mxs.completeRedraw()
		glm.deleteEmptyLayers()
		self.refreshSceneManagerUI()
		
	def refreshSceneManagerUI(self):
		irrLayer = glm.findLayersByString ( 'IRR' )
		floorLayer = glm.findLayersByString ( 'FLOOR' )
		moduleLayer = glm.findLayersByString ( 'MODULES' )
		if  len(irrLayer) != 0:
			if irrLayer[0].isHidden != True:
				self.ui_btn_toggleIrrad.setIcon(self.icoShown)
			if irrLayer[0].isHidden == True:
				self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
		if len(floorLayer) != 0:
			if floorLayer[0].isHidden != True:
				self.ui_btn_toggleFloor.setIcon(self.icoShown)
			if floorLayer[0].isHidden == True:
				self.ui_btn_toggleFloor.setIcon(self.icoHidden)
		if len(moduleLayer) != 0:
			if moduleLayer[0].isHidden != True:
				self.ui_btn_toggleModules.setIcon(self.icoShown)
			if moduleLayer[0].isHidden == True:
				self.ui_btn_toggleModules.setIcon(self.icoHidden)
				
		if  len(irrLayer) == 0:
			self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
		if  len(floorLayer) == 0:
			self.ui_btn_toggleFloor.setIcon(self.icoHidden)
		if  len(moduleLayer) == 0:
			self.ui_btn_toggleModules.setIcon(self.icoHidden)
			
				
	def refreshTreeView(self):
		r'''Refreshes the tree view'''
		lModules = glm.findLayersByString ( 'M_' )

		self.ui_tv_sceneElements.clear()
		for itm in lModules:

			layerName 		= itm.name
			moduleSubTypes 	= self.getModuleSubTypes (layerName)
			layerVisible 	= self.getLayerVisibility(layerName)
			meshObjList  	= moduleSubTypes[0]
			alphaObjList 	= moduleSubTypes[1]
			decalObjList 	= moduleSubTypes[2]
			
			#parent tree node
			tvItem = QTreeWidgetItem( self.ui_tv_sceneElements  )
			tvItem.setText (2, QString( layerName ) )
			if layerVisible != True:
				tvItem.setIcon (1, self.icoHidden)
			if layerVisible == True:
				tvItem.setIcon (1, self.icoShown)
				
			#mesh child tree node
			meshChild = QTreeWidgetItem( tvItem )
			meshChild.setText (2, QString( "Mesh" ) )
			if layerVisible == True:
				iconVisibilty = self.getModuleSubTypeVisibilty ( meshObjList )
				self.setModuleSubGeoVisibilty(iconVisibilty, meshObjList )
				if iconVisibilty == False:
					meshChild.setIcon (1, self.icoHidden)
				elif iconVisibilty == True:
					meshChild.setIcon (1, self.icoShown)
			else:
				meshChild.setIcon (1, self.icoHidden)

				
			#alphas child tree node
			alphaChild = QTreeWidgetItem( tvItem )
			alphaChild.setText (2, QString( "Alpha" ) )
			if layerVisible == True:
				iconVisibilty = self.getModuleSubTypeVisibilty ( alphaObjList )
				self.setModuleSubGeoVisibilty(iconVisibilty, alphaObjList )
				if iconVisibilty == False:
					alphaChild.setIcon (1, self.icoHidden)

				elif iconVisibilty == True:
					alphaChild.setIcon (1, self.icoShown)

			else:
				alphaChild.setIcon (1, self.icoHidden)
				
			#decals child tree node
			decalChild = QTreeWidgetItem( tvItem )
			decalChild.setText (2, QString( "Decals" ) )
			if layerVisible == True:
				iconVisibilty = self.getModuleSubTypeVisibilty ( decalObjList )
				self.setModuleSubGeoVisibilty(iconVisibilty, decalObjList )
				if iconVisibilty == False:
					decalChild.setIcon (1, self.icoHidden)
				elif iconVisibilty == True:
					decalChild.setIcon (1, self.icoShown)
			else:
				decalChild.setIcon (1, self.icoHidden)
				
			self.ui_tv_sceneElements.sortItems(2,0 )
			

	def getModuleSubTypes (self, _string):
		r'''returns a multi list of sub geomtry types to use with tree viewer'''
		meshes = []
		alphas = []
		decals = []

		#print _string
		layer_deps  = glm.getLayerChildren( _string )
		for itm in layer_deps:
			
			if glm.superClassOf(itm) == "GeometryClass":
				
				if (itm.name).startswith('_mesh_alpha_') ==  True:
					alphas.append(itm)
					
				elif (itm.name).startswith('_mesh_decal_') ==  True:
					decals.append(itm)
					
				else:
					meshes.append(itm)
	
		return [meshes, alphas, decals]
		
	def getModuleSubTypeVisibilty ( self, object_list ):
		r'''Figures out to hide or not of specified objects'''
		hidden = 0
		shown = 0
		for node in object_list:
			if node.ishidden == False:
				shown += 1
			if node.ishidden != False:
				hidden += 1	
		return shown > hidden		

	def setModuleSubGeoVisibilty (self, boolean, object_list):
		r'''Sets the geometry of a specified object list to hidden or show'''
		if  boolean == True:
			for node in object_list:
				node.ishidden = False
		if  boolean == False:
			for node in object_list:
				node.ishidden = True
				
	def toggleByType(self, toggleType, _string):
		r'''Toggle a specfied type '''
		tvItemsCount = self.ui_tv_sceneElements.topLevelItemCount()
		if toggleType == False:
			for i in range(0, tvItemsCount ):
				tvNode 			= self.ui_tv_sceneElements.topLevelItem(i)
				tvNode.setIcon(1, self.icoShown)
				
				moduleName 		= tvNode.text(2)
				layer 			= glm.setLayer (moduleName, False)
				layer.ishidden	= False
				
				moduleSubTypes 	= self.getModuleSubTypes (layer.name)
				meshObjList  	= moduleSubTypes[0]
				alphaObjList 	= moduleSubTypes[1]
				decalObjList 	= moduleSubTypes[2]
				
				if _string == 'Mesh':
					self.setModuleSubGeoVisibilty(True, meshObjList )
					
				elif _string == 'Alpha':
					self.setModuleSubGeoVisibilty(True, alphaObjList )

				elif _string == 'Decals':
					self.setModuleSubGeoVisibilty(True, decalObjList )
					
#				for i in range (0, 3):
#					childTreeNode = tvNode.child(i)
#					if childTreeNode.text(2) == _string:
#						childTreeNode.setIcon(1, self.icoShown)
#					else:
#						childTreeNode.setIcon(1, self.icoHidden)
				
		elif toggleType == True:
			
			for i in range(0, tvItemsCount ):
				tvNode 			= self.ui_tv_sceneElements.topLevelItem(i)
				tvNode.setIcon(1, self.icoShown)
				
				moduleName 		= tvNode.text(2)
				layer 			= glm.setLayer (moduleName, False)
				layer.ishidden	= False
				
				moduleSubTypes 	= self.getModuleSubTypes (layer.name)
				meshObjList  	= moduleSubTypes[0]
				alphaObjList 	= moduleSubTypes[1]
				decalObjList 	= moduleSubTypes[2]

				if _string == 'Mesh':
					self.setModuleSubGeoVisibilty(False, meshObjList )
					
				if _string == 'Alpha':
					self.setModuleSubGeoVisibilty(False, alphaObjList )
					
				if _string == 'Decals':
					self.setModuleSubGeoVisibilty(False, decalObjList )
					
#				for i in range (0, 3):
#					childTreeNode = tvNode.child(i)
#					childTreeNode.setIcon(1, self.icoHidden)	

		mxs.completeRedraw()
		
		
	def isolateMeshBtn(self):
		r'''Isolates the Mesh sub types Layer'''
		self.ui_btn_toggleMesh.setIcon(self.icoShown)
		self.ui_btn_toggleAlpha.setIcon(self.icoHidden)
		self.ui_btn_toggleDecals.setIcon(self.icoHidden)
		self.ui_btn_toggleFloor.setIcon(self.icoHidden)
		self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
		self.ui_btn_toggleModules.setIcon(self.icoHidden)
		
		floorLayer = glm.setLayer ('FLOOR', False)
		irradLayer = glm.setLayer ('IRRADIANCE', False)
		modulLayer = glm.setLayer ('MODULES', False)
			
		floorLayer.isHidden = True
		irradLayer.isHidden = True
		modulLayer.isHidden = True

		self.toggleByType(False, 'Mesh')
		self.toggleByType(True, 'Alpha')
		self.toggleByType(True, 'Decals')

		self.meshToggle 	= True
		self.alphaToggle 	= False
		self.decalsToggle 	= False	
		self.floorToggle 	= False
		self.irradToggle 	= False
		self.modulesToggle 	= False
		self.isolateTreeSubNodes('Mesh')
		
	def isolateTreeSubNodes(self, _string):
		tvItemsCount = self.ui_tv_sceneElements.topLevelItemCount()

		for i in range(0, tvItemsCount ):
			tvNode = self.ui_tv_sceneElements.topLevelItem(i)
			for zz in range (0, 3):
				childTreeNode = tvNode.child(zz)
				if childTreeNode.text(2) == _string:
					childTreeNode.setIcon(1, self.icoShown)
				else:
					childTreeNode.setIcon(1, self.icoHidden)	
					
	def showTreeSubNodes(self, _string, boolean):
		tvItemsCount = self.ui_tv_sceneElements.topLevelItemCount()

		for i in range(0, tvItemsCount ):
			tvNode = self.ui_tv_sceneElements.topLevelItem(i)
			for zz in range (0, 3):
				childTreeNode = tvNode.child(zz)
				if childTreeNode.text(2) == _string:
					if boolean == True:
						childTreeNode.setIcon(1, self.icoShown)
					if boolean == False:
						childTreeNode.setIcon(1, self.icoHidden)
			
	def toggleMeshBtn(self):
		r'''Toggles the Mesh layer'''
		type = 'Mesh'
		self.toggleByType(self.meshToggle, type )
		
		if self.meshToggle == False:
			self.meshToggle = True
			self.ui_btn_toggleMesh.setIcon(self.icoShown)
			self.showTreeSubNodes(type, True)
		elif self.meshToggle == True:
			self.meshToggle = False
			self.ui_btn_toggleMesh.setIcon(self.icoHidden)
			self.showTreeSubNodes(type, False)

	def isolateAlphaBtn(self):
		r'''Isolates the Alpha sub types Layer'''
		self.ui_btn_toggleMesh.setIcon(self.icoHidden)
		self.ui_btn_toggleAlpha.setIcon(self.icoShown)
		self.ui_btn_toggleDecals.setIcon(self.icoHidden)
		self.ui_btn_toggleFloor.setIcon(self.icoHidden)
		self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
		self.ui_btn_toggleModules.setIcon(self.icoHidden)
		
		floorLayer = glm.setLayer ('FLOOR', False)
		irradLayer = glm.setLayer ('IRRADIANCE', False)
		modulLayer = glm.setLayer ('MODULES', False)
			
		floorLayer.isHidden = True
		irradLayer.isHidden = True
		modulLayer.isHidden = True
		
		self.toggleByType(True, 'Mesh')
		self.toggleByType(False, 'Alpha')
		self.toggleByType(True, 'Decals')

		self.meshToggle 	= False
		self.alphaToggle 	= True
		self.decalsToggle 	= False	
		self.floorToggle 	= False
		self.irradToggle 	= False
		self.modulesToggle 	= False
		
		self.isolateTreeSubNodes('Alpha')
		
	def toggleAlphaBtn(self):
		r'''Toggles the Mesh layer'''
		type = 'Alpha'
		self.toggleByType(self.alphaToggle, type)
		
		if self.alphaToggle == False:
			self.alphaToggle = True
			self.ui_btn_toggleAlpha.setIcon(self.icoShown)
			self.showTreeSubNodes(type, True)
		elif self.alphaToggle == True:
			self.alphaToggle = False
			self.ui_btn_toggleAlpha.setIcon(self.icoHidden)
			self.showTreeSubNodes(type, False)

	def isolateDecalsBtn(self):
		r'''Isolates the Decals sub types Layer'''
		self.ui_btn_toggleMesh.setIcon(self.icoHidden)
		self.ui_btn_toggleAlpha.setIcon(self.icoHidden)
		self.ui_btn_toggleDecals.setIcon(self.icoShown)
		self.ui_btn_toggleFloor.setIcon(self.icoHidden)
		self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
		self.ui_btn_toggleModules.setIcon(self.icoHidden)
		
		floorLayer = glm.setLayer ('FLOOR', False)
		irradLayer = glm.setLayer ('IRRADIANCE', False)
		modulLayer = glm.setLayer ('MODULES', False)
			
		floorLayer.isHidden = True
		irradLayer.isHidden = True
		modulLayer.isHidden = True
		
		self.toggleByType(True, 'Mesh')
		self.toggleByType(True, 'Alpha')
		self.toggleByType(False, 'Decals')

		self.meshToggle 	= False
		self.alphaToggle 	= False
		self.decalsToggle 	= True	
		self.floorToggle 	= False
		self.irradToggle 	= False
		self.modulesToggle 	= False
		
		self.isolateTreeSubNodes('Decals')
		
	def toggleDecalsBtn(self):
		r'''Toggles the Mesh layer'''
		type = 'Decals'
		
		self.toggleByType(self.decalsToggle, type)
		
		if self.decalsToggle == False:
			self.decalsToggle = True
			self.ui_btn_toggleDecals.setIcon(self.icoShown)
			self.showTreeSubNodes(type, True)
			
		elif self.decalsToggle == True:
			self.decalsToggle = False
			self.ui_btn_toggleDecals.setIcon(self.icoHidden)
			self.showTreeSubNodes(type, False)
		
	def toggleFloorBtn(self):
		r'''Toggles the Floor layer'''
		layerList = glm.findLayersByString ( 'FLOOR' )	
		if self.floorToggle == False:
			self.floorToggle = True
			self.ui_btn_toggleFloor.setIcon(self.icoShown)
			for layer in layerList:
				layer.ishidden = False

		elif self.floorToggle == True:
			self.floorToggle = False
			self.ui_btn_toggleFloor.setIcon(self.icoHidden)
			for layer in layerList:
				layer.ishidden = True
		mxs.completeRedraw()
		
	def toggleIrradBtn(self):
		r'''Toggles the Iraddiance layer'''
		layerList = glm.findLayersByString ( 'IRRADIANCE' )
		if self.irradToggle == False:
			self.irradToggle = True
			self.ui_btn_toggleIrrad.setIcon(self.icoShown)
			for layer in layerList:
				layer.ishidden = False

		elif self.irradToggle == True:
			self.irradToggle = False
			self.ui_btn_toggleIrrad.setIcon(self.icoHidden)
			for layer in layerList:
				layer.ishidden = True
		mxs.completeRedraw()
		
	def toggleModulesBtn(self):
		r'''Toggles the Modules layer'''
		layerList = glm.findLayersByString ( 'MODULES' )
		if self.modulesToggle == False:
			self.modulesToggle = True
			self.ui_btn_toggleModules.setIcon(self.icoShown)
			for layer in layerList:
				layer.ishidden = False

		elif self.modulesToggle == True:
			self.modulesToggle = False
			self.ui_btn_toggleModules.setIcon(self.icoHidden)
			for layer in layerList:
				layer.ishidden = True
		mxs.completeRedraw()
		

	def getSubComponentVisibilty (self, _string ):
		r'''Returns a boolean  True:unhide False:hide all sub components'''
		shown 	= 0 
		hidden	= 0
		
		for node in mxs.objects:
			if glm.superClassOf(node) == 'GeometryClass':
				tokens = (node.name).split('_')
				if len(tokens) > 2:
					if tokens[1] == 'mesh' and tokens[2] == _string:
						if node.ishidden == True:
							hidden += 1
						if node.ishidden == False:
							shown += 1
					if tokens[1] == _string:
						if tokens[2] != 'alpha' or  tokens[2] != 'decal':
							if node.ishidden == True:
								hidden += 1
							if node.ishidden == False:
								shown += 1
					if tokens[1] == _string:
						if node.ishidden == True:
							hidden += 1
						if node.ishidden == False:
							shown += 1
		return shown > hidden	

	def getLayerVisibility(self, _string):
		'''Returns a boolean to hide or unhide all layers'''
		boolean = None
		meshLayerList = glm.findLayersByString ( _string )
		layersHidden = 0
		for layer in meshLayerList:
			if layer.ishidden == True:
				layersHidden += 1

		if layersHidden != 0:
			boolean = (len(meshLayerList)/2 >= layersHidden)
		if layersHidden == 0:
			boolean = True
		return boolean	
		
	def tagSelectedBnt (self):
		r'''Tags selected objects with tags from the ComboBox'''
		type = self.ui_cmb_tagList.currentText()
		dht.tagSelected(type)
		
	def clearTagsBtn(self):
		r'''clears selected object of its tags'''
		type = self.ui_cmb_tagList.currentText()
		dht.clearTags(type)
		
	def renameMeshBtn(self):
		r'''Renames selected objects with a prefix from the dropdown list '''
		type = self.ui_cmb_renames.currentText()
		if type == 'module':
			type = '_module_'
			
		if type == 'props':
			type = 'props_'
			
		if type == 'mesh':
			type = '_mesh_'
			
		if type == 'floor':
			type = '_floor_'
			
		if type == 'alpha':
			type = '_mesh_alpha_'

		if type == 'decal':
			type = '_mesh_decal_'
			
		if type == 'occluder':
			type = '_mesh_occluder_'

		if type == 'irradiance volume':
			type = 'irradiance_volume'
	
		if type == 'irradiance light':
			type = '_light_irr_'
			

		oSel = mxs.selection
		for i in oSel:
			dht.prefixNodeName(i, type )
	
	def runCommand(self, command):
		p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

	def getLatestBtn(self):
		'''Gets the latest from svn repo'''
		curScene = mxs.maxFilePath()
		
#		import subprocess
#		subprocess.Popen('svn update Q:\\', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		
	def getLatestRawDataBtn(self):
		'''Gets the latest from svn repo'''
#		self.runCommand('svn update Q:/raw_data/')
		import subprocess
		subprocess.Popen('svn update Q:\\raw_data\\', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		
	def matToVray (self):
		r'''Convert any selected object materials to Vray material'''

		mu.convertSelectedToVray()
		mxs.completeRedraw()
		
	def matToStandard (self):
		r'''Convert any selected object materials to Standard material'''

		matConverterScript = mxs.getDir(nfy('scripts')) + '\\startup\\' + "GL_MaterialConverter.ms"
		if os.path.isfile(matConverterScript) != True:
			import shutil, ctypes
			src = mxs.GL_BLUR_MXS_LIB + "GL_MaterialConverter.ms"
			dst = mxs.getDir(nfy('scripts')) + '\\startup\\' + "GL_MaterialConverter.ms"
			shutil.copy(src, dst)
			MessageBox = ctypes.windll.user32.MessageBoxA
			MessageBox(None, ('Next time you restart this function will work'), 'Missing Methods', 0)
		if os.path.isfile(matConverterScript) == True:
			try:
				mxs.convertMaterialtoStandard()
			except:
				print 'More than likely you need to restart Max'

		mxs.completeRedraw()
		
	def matToGlitch (self):
		r'''Convert any selected object materials to DirectX material'''

		matConverterScript = mxs.getDir(nfy('scripts')) + '\\startup\\' + "GL_MaterialConverter.ms"
		if os.path.isfile(matConverterScript) != True:
			import shutil, ctypes
			src = mxs.GL_BLUR_MXS_LIB + "GL_MaterialConverter.ms"
			dst = mxs.getDir(nfy('scripts')) + '\\startup\\' + "GL_MaterialConverter.ms"
			shutil.copy(src, dst)
			MessageBox = ctypes.windll.user32.MessageBoxA
			MessageBox(None, ('Next time you restart this function will work'), 'Missing Methods', 0)
		if os.path.isfile(matConverterScript) == True:
			try:
				mxs.convertMaterialtoGlitch()
			except:
				print 'More than likely you need to restart Max'
		mxs.completeRedraw()

	def selectByTagBtn(self):
		r'''Selects from the dropdown menu '''
		type = self.ui_cmb_tagList.currentText()
		ll = []
		for obj in mxs.objects:
			objTag = mxs.getUserProp (obj, 'lightmap')
			if objTag == type and obj.ishidden != True:
				ll.append(obj)
		mxs.clearselection()
		mxs.select(ll)
		mxs.completeRedraw()
		
	def selectLM1Btn(self):
		r'''Selects objects with LM1 tag'''
		dhs.selectByUserPropertyTag('lightmap', 'LM1')
		
	def selectLM2Btn(self):
		r'''Selects objects with LM2 tag'''
		dhs.selectByUserPropertyTag('lightmap', 'LM2')
		
	def selectLM3Btn(self):
		r'''Selects objects with LM3 tag'''
		dhs.selectByUserPropertyTag('lightmap', 'LM3')
		
	def selectLM4Btn(self):
		r'''Selects objects with LM4 tag'''
		dhs.selectByUserPropertyTag('lightmap', 'LM4')
		
	def selectMeshBtn(self):
		r'''Selects objects with "_mesh_" string in the name '''
		dhs.selectByType('_mesh_')
		
	def selectModulesBtn(self):
		r'''Selects objects with "_module_" string in the name '''
		dhs.selectByType('_module_')
		
	def selectFloorBtn(self):
		r'''Selects objects with "_floor_" string in the name '''
		dhs.selectByType('_floor_')
		
	def selectAlphaBtn(self):
		r'''Selects objects with "_alpha_" string in the name '''
		dhs.selectByType('_alpha_')
	
	def closeEvent( self, event ):
		self.recordSettings()
		super(DH5ToolsDialog,self).closeEvent( event )
	
	def recordSettings( self ):
		pref = prefs.find( 'tools/DH5Tools', shared=True )
		pref.recordProperty( 'geom', self.geometry() )
		pref.recordProperty( 'ui_cmb_tagList', self.ui_cmb_tagList.currentIndex() )
		pref.recordProperty( 'ui_cmb_renames', self.ui_cmb_renames.currentIndex() )
		pref.recordProperty( 'ui_tabs', self.ui_tabs.currentIndex() )
		
		pref.recordProperty( 'cbx_directIrr', int(self.ui_cbx_directIrr.checkState()) )
		pref.recordProperty( 'cbx_indirectIrr', int(self.ui_cbx_indirectIrr.checkState()) )
		pref.recordProperty( 'cbx_viewRender', int(self.ui_cbx_viewRender.checkState()) )
		pref.recordProperty( 'spn_directIrr', self.ui_spn_directIrr.value() )
		pref.recordProperty( 'spn_indirectIrr', self.ui_spn_indirectIrr.value() )

		if self.irradColor != None:
			pref.recordProperty('irrad_color', self.irradColor)
#		pref.recordProperty( 'ui_tabs', self.ui_tabs.currentIndex() )

		pref.save()
	
	def restoreSettings( self ):
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/DH5Tools', shared=True )

		# reload the geometry
		from PyQt4.QtCore import QRect
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )
		
		ui_cmb_tagList 	= pref.restoreProperty ( 'ui_cmb_tagList' )
		ui_cmb_renames 	= pref.restoreProperty ( 'ui_cmb_renames' )
		ui_tabs 		= pref.restoreProperty ( 'ui_tabs' )
		cbx_directIrr 	= pref.restoreProperty ( 'cbx_directIrr' )
		cbx_indirectIrr	= pref.restoreProperty ( 'cbx_indirectIrr' )
		cbx_viewRender 	= pref.restoreProperty ( 'cbx_viewRender' )
		spn_directIrr 	= pref.restoreProperty ( 'spn_directIrr' )
		spn_indirectIrr	= pref.restoreProperty ( 'spn_indirectIrr' )
		irrad_color 	= pref.restoreProperty ( 'irrad_color' )
		
		if ui_cmb_tagList != None:
			self.ui_cmb_tagList.setCurrentIndex(ui_cmb_tagList)
			
		if ui_cmb_renames != None:
			self.ui_cmb_renames.setCurrentIndex(ui_cmb_renames)
			
		if ui_tabs != None:
			self.ui_tabs.setCurrentIndex(ui_tabs)
			
		if cbx_directIrr != None:
			self.ui_cbx_directIrr.setCheckState (cbx_directIrr)
			
		if cbx_indirectIrr != None:
			self.ui_cbx_indirectIrr.setCheckState (cbx_indirectIrr)
			
		if cbx_viewRender != None:
			self.ui_cbx_viewRender.setCheckState (cbx_viewRender)

		if spn_directIrr != None:
			self.ui_spn_directIrr.setValue(spn_directIrr)
			
		if spn_indirectIrr != None:
			self.ui_spn_indirectIrr.setValue(spn_indirectIrr) 
		
		if irrad_color == None:
			self.ui_btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"  % (255, 255, 255) )
		else:
			self.ui_btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"  % (irrad_color[0], irrad_color[1], irrad_color[2]) )

			
	def showEvent ( self, event):
		# restore settings from last session
		self.restoreSettings()
	
		
def __main__(  ):
	
	dialog = DH5ToolsDialog()
	dialog.show()

	return True
#__main__()
