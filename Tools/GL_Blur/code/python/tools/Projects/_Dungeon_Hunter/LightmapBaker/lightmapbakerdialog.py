
#   :namespace  lightmapbakerdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       06/03/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
#GLOBAL IMPORTS
import PyQt4, os, blurdev, time, shutil
from PyQt4.QtCore import QRect
from PyQt4 import QtCore, QtGui
#BLUR STUFF
from blurdev.gui import Dialog
from blurdev import prefs
from Py3dsMax import mxs # import max module
nfy  = mxs.pyhelper.namify

#IMPORT UIs
import LightmapBaker.lightmapbakersettings as lmbs
#IMPORT LIBRARIES
from  glmax.max3d import GLMax
glm = GLMax()

from LightmapBaker.lm_globals import *
vru = VrayUtilities()
ru = RenderingUtilities()
lmu = LightMapUtilities()

from  glmax.gl_material_utilities import MaterialUtilities
mu = MaterialUtilities()

from UI.loaduistyle import LoadStyle
ui = LoadStyle()
#END

class LightmapBakerDialog( Dialog ):
	def __init__( self, parent = None ):
		super(LightmapBakerDialog,self).__init__( parent )
		# load the ui
		blurdev.gui.loadUi( __file__, self )
		self.bakeMeshNames 		= ['LM1', 'LM2', 'LM3', 'LM4']
		self.layerVisibility 	= []

		self.setStyleSheet(ui.getZStyleSheet())
		self.connect()


	def connect (self):
		self.btn_settings.clicked.connect(  self.openSettingsDialog )
		self.ui_btn_bakeMode.clicked.connect( self.setBakingMode )
		self.ui_btn_BakeLightmap.clicked.connect(self.bakeLighMapButton)
		self.ui_btn_RenderPreview.clicked.connect(self.renderPreviewButton)
		self.ui_btn_openBakedImages.clicked.connect(self.openCurrentImages)
		self.ui_btn_openBakeDirectory.clicked.connect(self.openCurrentSceneDir)
		
	def getCurrentBakePath(self):
		'''Returns the current bake output path'''
		lmBakeSettings = self.getLMBSettings()
		sceneData 	= ru.GetCurrentScenePath()
		netRender = lmBakeSettings['network_render']
		path = ''
		if netRender == 2:
			netRenderAddress = lmBakeSettings['network_address']
			path = netRenderAddress + '\\' + sceneData[1] + '\\'
		else:
			path = sceneData[0]	
		return path
		
	def openCurrentImages(self):
		'''Opens images for the currently selected items'''
		outputBakePath 		= self.getCurrentBakePath()
		sceneData 			= ru.GetCurrentScenePath()

		bakeLightMapState 	= self.ui_chb_bakeLightMap.checkState() 
		bakeAOState 		= self.ui_chb_bakeAO.checkState()
		bakeDirectState 	= self.ui_chb_bakeDirectionalLM.checkState()
		
		imageList 			= []
		meshesToOpenFor 	= []
		
		#get all the checked items in the listbox 
		for zz in range(0, self.ui_lst_lmLayers.count()):
			item = self.ui_lst_lmLayers.item(zz)
			if item.checkState() == 2:
				meshesToOpenFor.append(item.text())
				
		#create all the paths using the list box and ui information
		for nodeName  in meshesToOpenFor:
			rootPath =  outputBakePath  + nodeName +'_' + sceneData[1]

			if bakeLightMapState == 2:
				imageList.append( rootPath + '_LM.exr')
				imageList.append( rootPath + '_RawLM.exr')
				imageList.append( rootPath + '_GI.exr')
				imageList.append( rootPath + '_Shadow.exr')
			
			if bakeAOState == 2:
				imageList.append( rootPath + '_AO.exr')
				
			if bakeDirectState == 2:
				imageList.append( rootPath + '_Red.exr')
				imageList.append( rootPath + '_Green.exr')
				imageList.append( rootPath + '_Blue.exr')
				
		for map in imageList:
			if os.path.isfile(map) == True:
				os.startfile( map )
	
	def setUIDisabled (self):
		self.ui_chb_bakeLightMap.hide()
		self.ui_chb_bakeAO.hide()
		self.ui_chb_bakeDirectionalLM.hide()
		self.ui_btn_RenderPreview.hide()
		self.ui_btn_BakeLightmap.hide()
		self.ui_lst_lmLayers.hide()
		self.ui_btn_openBakedImages.hide()
		self.ui_btn_openBakeDirectory.hide()
		self.ui_groupBakeMaps.hide()
		
		#newSize = QtCore.QSize(self.width(), 35)
		#self.gridLayout_3.setEnabled(False)
		#self.geometry().setSize(newSize)
		
	def setUIEnabled (self):
		self.ui_chb_bakeLightMap.show()
		self.ui_chb_bakeAO.show()
		self.ui_chb_bakeDirectionalLM.show()
		self.ui_btn_RenderPreview.show()
		self.ui_btn_BakeLightmap.show()
		self.ui_lst_lmLayers.show()
		self.ui_btn_openBakedImages.show()
		self.ui_btn_openBakeDirectory.show()
		self.ui_groupBakeMaps.show()
		
	def openCurrentSceneDir(self):
		'''Opens directory of the current scene'''
		os.startfile( self.getCurrentBakePath() )
		
	def bakeLighMapButton(self):
		'''bakes selected LM type'''
		lmState = self.ui_chb_bakeLightMap.checkState()
		aoState = self.ui_chb_bakeAO.checkState()
		dlmState = self.ui_chb_bakeDirectionalLM.checkState()
		nodesToRender = []
		#Get the nodes to render
		for i in range(0,self.ui_lst_lmLayers.count()):
			lmLayer = self.ui_lst_lmLayers.item(i)
			if lmLayer.checkState() == 2:
				node = mxs.getnodebyname(lmLayer.text())
				nodesToRender.append(node)

		for node in nodesToRender:
			if node != None:
				if lmState == 2:
					print ('Rendering LM: %s' % node.name)
					
					self.renderMesh(node, 'lm')
					
				if aoState == 2:
					print ('Rendering AO: %s' % node.name)
					self.renderMesh(node, 'ao')
					
				if dlmState == 2:
					print ('Rendering DLM: %s' % node.name)
					self.renderMesh(node, 'dlm')
			else:
				print ('No baking mesh exists')

	def renderPreviewButton (self):
		'''Generates Render preview'''
		mxs.renderWidth = self.ui_btn_RenderPreview.geometry().width()
		mxs.renderHeight = self.ui_btn_RenderPreview.geometry().height()
		#set up temporary map for the preview button
		sceneData 	= ru.GetCurrentScenePath()
		path 		= sceneData[0] + '.tmp/'
		glm.makeDirectory( path )
		outputFile = path + "tmp.bmp"

		#get information regarding white balancing camera boolean
		lmBakeSettings = self.getLMBSettings()
		WBCameraSetting = lmBakeSettings['use_wb_camera']
		
		wbCam = None 
		if WBCameraSetting  == 2:
			wbCam = vru.SetVrayCamera()
			
		theBmp = mxs.render()
		theBmp.filename = outputFile
		mxs.save( theBmp)
		#color the button via stylsheets
		btnSS = ('QPushButton { background-image: url(%s);}' % outputFile)
		self.ui_btn_RenderPreview.setStyleSheet(btnSS)
		self.ui_btn_RenderPreview.setText('')
		
		if wbCam != None:
			mxs.delete(wbCam)
		try:
			mxs.blurManage.cleanFile()
		except:
			pass
	
	def openSettingsDialog(self):
		'''Opens settings dialog'''
		settingDialog = lmbs.LightmapBakerSettings( self )
		settingDialog.setModal(True)
		parentDialogGeo = self.geometry()
		settingsDialogGeo = settingDialog.geometry()
		
		# set up a new position of the setting dialog box
		parentDialogGeo.setX(parentDialogGeo.x() + 15)
		parentDialogGeo.setY(parentDialogGeo.y() + 70)
		parentDialogGeo.setWidth(settingsDialogGeo.width())
		parentDialogGeo.setHeight(settingsDialogGeo.height())

		settingDialog.setGeometry( parentDialogGeo )
		settingDialog.show()
		
	def meshExistsMessageBox (self):
		return QtGui.QMessageBox.information(self,
									'Attention',
									'Mesh already exists.\nRebuild or uses existing',
									 QtGui.QMessageBox.Yes,
									 QtGui.QMessageBox.No,
									 QtGui.QMessageBox.Cancel,)
	
	def gatherTags(self):
		
		LM1_List	= []
		LM2_List 	= []
		LM3_List	= []
		LM4_List 	= []
		
		for obj in mxs.objects:
			superObjectType = glm.superClassOf (obj)
			
			if superObjectType == 'GeometryClass':
				lmType = mxs.getUserProp( obj, 'lightmap' )
				
				if lmType == 'LM1':
					LM1_List.append(obj)
					
				if lmType == 'LM2':
					LM2_List.append(obj)
					
				if lmType == 'LM3':
					LM3_List.append(obj)
					
				if lmType == 'LM4':
					LM4_List.append(obj)
				
		return [LM1_List, LM2_List, LM3_List, LM4_List]
		
	def setLmLayersQList (self, ):
		for name in self.bakeMeshNames:
			node = mxs.getnodebyname(name)
			if node != None:
				itm = QtGui.QListWidgetItem()
				itm.setText(node.name)
				itm.setCheckState(False)
				self.ui_lst_lmLayers.addItem(itm)

	def makeBakeMeshes(self):
		'''Creates snapshots of all the lm tags'''
		sceneLigtmapsList = self.gatherTags()
		LM1_List		= sceneLigtmapsList[0]
		LM2_List		= sceneLigtmapsList[1]
		LM3_List		= sceneLigtmapsList[2]
		LM4_List		= sceneLigtmapsList[3]
		
		if len(LM1_List) > 0:
			LM1_Mesh = glm.snapshotObjectMerge( LM1_List )
			LM1_Mesh.name = self.bakeMeshNames[0]#'MainLM'
			vRayMat = mu.makeVrayMaterial( mu.getMaterialData (LM1_Mesh.material) )
			LM1_Mesh.material = vRayMat
			
		if len(LM2_List) > 0:
			LM2_Mesh = glm.snapshotObjectMerge( LM2_List )
			LM2_Mesh.name = self.bakeMeshNames[1]#'AlphaLM'
			vRayMat = mu.makeVrayMaterial( mu.getMaterialData (LM2_Mesh.material) )
			LM2_Mesh.material = vRayMat
			
		if len(LM3_List) > 0:
			LM3_Mesh = glm.snapshotObjectMerge( LM3_List )
			LM3_Mesh.name = self.bakeMeshNames[2]#'DecalsLM'
			vRayMat = mu.makeVrayMaterial( mu.getMaterialData (LM3_Mesh.material) )
			LM3_Mesh.material = vRayMat
			
		if len(LM4_List) > 0:
			LM4_Mesh = glm.snapshotObjectMerge( LM4_List )
			LM4_Mesh.name = self.bakeMeshNames[3]#'TempLM'
			vRayMat = mu.makeVrayMaterial( mu.getMaterialData (LM4_Mesh.material) )
			LM4_Mesh.material = vRayMat

	def setBakingMode( self ):
		btnState = self.ui_btn_bakeMode.isChecked()
		bakeMeshLayer 	= glm.setLayer('BakeMesh')

		if btnState == True:
			bakeMeshes		= []
			for name in self.bakeMeshNames:
				node = mxs.getnodebyname(name)
				if node != None:
					bakeMeshes.append(node)

			bakeSettings = self.getLMBSettings()

			
			if len(bakeMeshes) != 0:
				'''Ask delete mesh or use existing mesh'''
				self.ui_btn_bakeMode.setStyleSheet('background-color: rgb(209, 103, 10)')
				self.ui_btn_bakeMode.setText('>>> EXIT BAKING MODE <<<')
				answer = self.meshExistsMessageBox()
				
				if answer == 16384:
					print 'Yes answer'
					
					self.layerVisibility = glm.getMaxLayerVisibility()
					lmu.SetLayerBakingMode()
					
					for name in self.bakeMeshNames:
						node = mxs.getnodebyname(name)
						if node != None:
							mxs.delete(node)
					
					self.makeBakeMeshes()
					self.setLmLayersQList()
					#self.setUIEnabled()
					
				if answer == 65536:
					print 'No answer'
					self.layerVisibility = glm.getMaxLayerVisibility()
					lmu.SetLayerBakingMode()
					self.setLmLayersQList()
					#self.setUIEnabled()

				if answer == 4194304:
					print 'Cancel answer'
					self.ui_btn_bakeMode.setStyleSheet('')
					self.ui_btn_bakeMode.setChecked(False)
					self.ui_btn_bakeMode.setText('ENTER BAKING MODE')
					if len(self.layerVisibility) == 2:
						glm.setMaxLayerVisibility(self.layerVisibility)
						
			if len(bakeMeshes) == 0:
				self.ui_btn_bakeMode.setStyleSheet('background-color: rgb(209, 103, 10)')
				self.ui_btn_bakeMode.setText('>>> EXIT BAKING MODE <<<')
				self.layerVisibility = glm.getMaxLayerVisibility()
				lmu.SetLayerBakingMode()
				
				for name in self.bakeMeshNames:
					node = mxs.getnodebyname(name)
					if node != None:
						mxs.delete(node)
				
				self.makeBakeMeshes()
				self.setLmLayersQList()	
				
		if btnState != True:
			print 'Exiting baking Mode'
			self.ui_btn_bakeMode.setStyleSheet('')
			self.ui_btn_bakeMode.setChecked(False)
			self.ui_btn_bakeMode.setText('ENTER BAKING MODE')
			if len(self.layerVisibility) == 2:
				glm.setMaxLayerVisibility(self.layerVisibility)

			lightLayer 		= glm.setLayer ('LIGHTS', False)
			bakeOccLayer	= glm.setLayer ('BakeMesh_Occ', False)
			
			bakeMeshLayer.ishidden 	= True
			lightLayer.ishidden 	= True
			bakeOccLayer.ishidden	= True
			self.ui_lst_lmLayers.clear()
			
		mxs.completeRedraw()

	def getLMBSettings(self ):
		pref = prefs.find( 'tools/LightmapBakerSettings', shared=True )	
		renderSettings = {
				'texture_size': 	pref.restoreProperty( 'texture_size'),
				'uv_channel': 		pref.restoreProperty( 'uv_channel'),
				'dialation': 		pref.restoreProperty( 'dialation'),
				'network_render':	pref.restoreProperty( 'network_render'),
				'network_address':	pref.restoreProperty( 'network_address'),
				'use_wb_camera': 	pref.restoreProperty( 'use_wb_camera'),
				'delete_bake_mesh':	pref.restoreProperty( 'delete_bake_mesh' ),
				'render_presets': 	pref.restoreProperty( 'render_presets' )
				}
		if renderSettings['texture_size'] == 0:
			renderSettings['texture_size'] = 512
		if renderSettings['texture_size'] == 1:
			renderSettings['texture_size'] = 1024
		if renderSettings['texture_size'] == 2:
			renderSettings['texture_size'] = 2048
		if renderSettings['texture_size'] == 3:
			renderSettings['texture_size'] = 4096

		return renderSettings
			
	def getUniqueBitmaps(self ):
		'''Return a list of all bitmaps in the scene that have an image'''
		sceneImageList = mxs.GetClassInstances( mxs.BitmapTexture)
		filteredImgList = []
		li = []
		for item in sceneImageList:
			bitmap = item
			if len(bitmap.filename) > 0:
				path = bitmap.filename
				newpath = path.replace('\\', '/')
				
				#if list is empty adds appends data to lists
				if len(li) == 0:
					li.append(newpath)
					filteredImgList.append(bitmap)
					
				#if matches returns an empty list, appends data to lists 
				matches = [elem for elem in li if elem == newpath]
				if len(matches) == 0:
					li.append(newpath)
					filteredImgList.append(bitmap)
		
		return filteredImgList
				
	def copyImagesToRenderFarm(self,  imgList, address ):
		'''Copies a list of images to a specified path'''
		for item in imgList:
			srcFilePath = item.FileName
			currentFileName = mxs.filenameFromPath(item.FileName)
			sceneData 	= ru.GetCurrentScenePath()
			sceneName 		= sceneData[1]
			serverPath = address + "\\" + sceneName

			glm.makeDirectory ( serverPath )

			dstFilePath = serverPath + '\\' + currentFileName
			srcFilePath = srcFilePath.replace('\\', '/')

			if os.path.isfile(srcFilePath) != False:
				
				if os.path.isfile(dstFilePath) == True:
					srcTimeStamp = time.ctime(os.path.getmtime(srcFilePath))
					dstTimeStamp = time.ctime(os.path.getmtime(dstFilePath))
					if (srcTimeStamp > dstTimeStamp) == True:
						shutil.copyfile(srcFilePath, dstFilePath)

				if os.path.isfile(dstFilePath) == False:
					shutil.copyfile(srcFilePath, dstFilePath)
			
	def setBitmapsPath(self, imgList, path ):
		'''Changes the path of a given imgList to point to a given path'''
		sceneData 	= ru.GetCurrentScenePath()
		sceneName 	= sceneData[1]
		dstPath		= None
		# find out what type of path we are working with 0=local 1=network

		pathType 	= self.getPathType(path)
		if pathType == 0:
			dstPath = path
		if pathType == 1:
			dstPath = path + '\\' + sceneName

		for item in imgList:
			currentFileName = mxs.filenameFromPath(item.FileName)
			dstServerFileName = dstPath + '\\' + currentFileName
			item.FileName = dstServerFileName

	def getPathType(self, path):
		'''Finds out what type of path returns None, 0=Local, 1=Network'''
		pathType = None
		if (path[0] != '\\'):
			pathType = 0
		if (path[0] == '\\'):
			pathType = 1
		return pathType
		
	def sendToRenderNetwork(self,  node, address ):
		fileType	= ".exr"
		mxs.fileproperties.addproperty( nfy('custom'), "RTT_Default_Path", address)
		mxs.fileproperties.addproperty( nfy('custom'), "RTT_Default_FileType", fileType)
		mxs.fileproperties.addproperty( nfy('custom'), "RTT_RenderTimeType", mxs.rendTimeType)
		mxs.NetworkRTT(node)
		mxs.fileproperties.deleteproperty( nfy('custom'), "RTT_Default_Path" )
		mxs.fileproperties.deleteproperty( nfy('custom'), "RTT_Default_FileType")
		mxs.fileproperties.deleteproperty( nfy('custom'), "RTT_RenderTimeType")

	
	def setTempRenderPreset(self):
		'''Sets up a temporary render preset to render out AO'''
		presetPath = ru.GetPresetPath()
		tempRPS = mxs.getDir( nfy('renderPresets')) + "\\" + "current_setting.rps"
		AO_RPS = presetPath + "vray_low_settings.rps"
		mxs.renderpresets.SaveAll ( 0, tempRPS )
		mxs.renderPresets.LoadAll ( 0, AO_RPS) 
		
		#additional settings for the render
		vr = mxs.renderers.current
		vr.environment_gi_color 			= mxs.color(255,255,255)
		vr.environment_gi_color_multiplier 	= 1.5
		
		return tempRPS

	def setLightMapRTT_Network(self, node, path, scene):
		'''Sets up a Lightmap Render To Texture'''
		lmBakeSettings = self.getLMBSettings()	

		CompositeLMPath 	= (path)
		RawShadowMapPath	= (path)
		RawGIMapPath 		= (path)
		RawLightingMapPath 	= (path)
		#Sets up shadow pass -------------------------------------
		RawShadowPass				= mxs.VRayRawShadowMap ()
		RawShadowPass.fileType 		= '.exr'
		RawShadowPass.fileName 		= RawShadowMapPath 
		RawShadowPass.elementName 	= '_' + scene + 'Shadow' 
		RawShadowPass.outputSzX		= lmBakeSettings['texture_size']
		RawShadowPass.outputSzY		= lmBakeSettings['texture_size']
		#Sets up GI pass -----------------------------------------
		RawGIPass					= mxs.VRayRawGlobalIlluminationMap ()
		RawGIPass.fileType			= '.exr'
		RawGIPass.fileName			= RawGIMapPath 
		RawGIPass.elementName		= '_' + scene + 'GI'
		RawGIPass.outputSzX			= lmBakeSettings['texture_size']
		RawGIPass.outputSzY			= lmBakeSettings['texture_size']
		#Sets up lighting pass ------------------------------------
		RawLightingPass 			= mxs.VRayRawLightingMap ()
		RawLightingPass.fileType	= '.exr'
		RawLightingPass.fileName	= RawLightingMapPath 
		RawLightingPass.elementName	= '_' + scene + 'RawLM'
		RawLightingPass.outputSzX	= lmBakeSettings['texture_size']
		RawLightingPass.outputSzY	= lmBakeSettings['texture_size']
		#Sets up composited lightmap ------------------------------
		CompositeLM					= mxs.VRayRawTotalLightingMap ()
		CompositeLM.fileType 		= '.tga'
		CompositeLM.fileName  		= CompositeLMPath
		CompositeLM.elementName  	= '_' + scene + 'LM'
		CompositeLM.outputSzX		= lmBakeSettings['texture_size']
		CompositeLM.outputSzY		= lmBakeSettings['texture_size']
		#clear any bake properties on the bakemesh
		node.INodeBakeProperties.removeAllBakeElements()
		#Add bake nodes
		
		node.INodeBakeProperties.addBakeElement (RawShadowPass)
		node.INodeBakeProperties.addBakeElement (RawGIPass)
		node.INodeBakeProperties.addBakeElement (RawLightingPass)
		node.INodeBakeProperties.addBakeElement (CompositeLM)

		node.INodeBakeProperties.bakeEnabled 	= True
		node.INodeBakeProperties.flags 			= 1
		node.INodeBakeProperties.bakeChannel 	= lmBakeSettings['uv_channel']
		node.INodeBakeProperties.nDilations 	= lmBakeSettings['dialation']


		mxs.renderWidth		= lmBakeSettings['texture_size']
		mxs.renderHeight	= lmBakeSettings['texture_size']

	def setLightMapRTT(self, node, path, scene):
		lmBakeSettings = self.getLMBSettings()	
		
		CompositeLMPath 	= (path + node.name + '_' + scene + "LM.tga")
		RawShadowMapPath	= (path + node.name + '_' + scene + "Shadow.exr")
		RawGIMapPath 		= (path + node.name + '_' + scene + "GI.exr")
		RawLightingMapPath 	= (path + node.name + '_' + scene + "RawLM.exr")

		#Sets up shadow pass -------------------------------------
		RawShadowPass				= mxs.VRayRawShadowMap ()
		RawShadowPass.fileType 		= RawShadowMapPath
		RSM_Img 					= RawShadowMapPath 
		#Sets up GI pass -----------------------------------------
		RawGIPass					= mxs.VRayRawGlobalIlluminationMap ()
		RawGIPass.fileType			= RawGIMapPath 
		RawGIPass.fileName			= RawGIMapPath 
		#Sets up lighting pass ------------------------------------
		RawLightingPass 			= mxs.VRayRawLightingMap ()
		RawLightingPass.fileType	= RawLightingMapPath 
		RawLightingPass.fileName	= RawLightingMapPath 

		#Sets up composited lightmap ------------------------------
		CompositeLM					= mxs.VRayRawTotalLightingMap ()
		CompositeLM.fileType 		= CompositeLMPath
		CompositeLM.fileName  		= CompositeLMPath

		#clear any bake properties on the bakemesh
		node.INodeBakeProperties.removeAllBakeElements()
		#Add bake nodes

		node.INodeBakeProperties.addBakeElement (RawShadowPass)
		node.INodeBakeProperties.addBakeElement (RawGIPass)
		node.INodeBakeProperties.addBakeElement (RawLightingPass)
		node.INodeBakeProperties.addBakeElement (CompositeLM)

		node.INodeBakeProperties.bakeEnabled 	= True
		node.INodeBakeProperties.flags 			= 1
		node.INodeBakeProperties.bakeChannel 	= lmBakeSettings['uv_channel']
		node.INodeBakeProperties.nDilations 	= lmBakeSettings['dialation']


		mxs.renderWidth		= lmBakeSettings['texture_size']
		mxs.renderHeight	= lmBakeSettings['texture_size']
	
	def setAmbienOcclusionRTT_Network(self, node, path, scene):
		'''Bakes AO for current object'''
		lmBakeSettings = self.getLMBSettings()
		
		AOPath 	= (path)
		AOMap				= mxs.VRayDiffuseFilterMap()
		AOMap.fileType 		= '.exr' 
		AOMap.fileName 		= AOPath
		AOMap.elementName	=  '_' + scene + 'AO' 
		AOMap.outputSzX		= lmBakeSettings['texture_size']
		AOMap.outputSzY		= lmBakeSettings['texture_size']

		#clear any bake properties on the bakemesh
		node.INodeBakeProperties.removeAllBakeElements()
		
		node.INodeBakeProperties.addBakeElement (AOMap)
		node.INodeBakeProperties.bakeEnabled 	= True
		node.INodeBakeProperties.flags 			= 1
		node.INodeBakeProperties.bakeChannel 	= lmBakeSettings['uv_channel']
		node.INodeBakeProperties.nDilations 	= lmBakeSettings['dialation']
		
		mxs.renderWidth							= lmBakeSettings['texture_size']
		mxs.renderHeight						= lmBakeSettings['texture_size']
	
	def setAmbienOcclusionRTT(self, node, path, scene):
		'''Bakes AO for current object'''
		lmBakeSettings = self.getLMBSettings()
	
		#Sets up AO pass
		AOPath 	= (path + node.name  + '_' +  scene + 'AO.exr')
		AOMap				= mxs.VRayDiffuseFilterMap()
		AOMap.fileType 		= AOPath 
		AOMap.fileName 		= AOPath 

		#clear any bake properties on the bakemesh
		node.INodeBakeProperties.removeAllBakeElements()
		
		node.INodeBakeProperties.addBakeElement (AOMap)
		node.INodeBakeProperties.bakeEnabled 	= True
		node.INodeBakeProperties.flags 			= 1
		node.INodeBakeProperties.bakeChannel 	= lmBakeSettings['uv_channel']
		node.INodeBakeProperties.nDilations 	= lmBakeSettings['dialation']
		
		mxs.renderWidth							= lmBakeSettings['texture_size']
		mxs.renderHeight						= lmBakeSettings['texture_size']
		
	def setDirectionalRTT_Network(self, node, path, scene, color):
		'''Sets up a Directional Lightmap Render To Texture'''
		lmBakeSettings = self.getLMBSettings()	

		CompositeLMPath 	= (path)

		#Sets up composited lightmap ------------------------------
		CompositeLM					= mxs.VRayRawTotalLightingMap ()
		CompositeLM.fileType 		= '.exr'
		CompositeLM.fileName  		= CompositeLMPath
		CompositeLM.elementName  	= '_' + scene + color
		CompositeLM.outputSzX		= lmBakeSettings['texture_size']
		CompositeLM.outputSzY		= lmBakeSettings['texture_size']
		#clear any bake properties on the bakemesh
		node.INodeBakeProperties.removeAllBakeElements()
		#Add bake nodes
		node.INodeBakeProperties.addBakeElement (CompositeLM)

		node.INodeBakeProperties.bakeEnabled 	= True
		node.INodeBakeProperties.flags 			= 1
		node.INodeBakeProperties.bakeChannel 	= lmBakeSettings['uv_channel']
		node.INodeBakeProperties.nDilations 	= lmBakeSettings['dialation']


		mxs.renderWidth		= lmBakeSettings['texture_size']
		mxs.renderHeight	= lmBakeSettings['texture_size']

	def setDirectionalRTT(self, node, path, scene, color):
		'''Sets up a Directional Lightmap Render To Texture'''
		lmBakeSettings = self.getLMBSettings()	
		
		CompositeLMPath 	= (path + node.name + '_' + scene + color + ".exr")

		#Sets up composited lightmap ------------------------------
		CompositeLM					= mxs.VRayRawTotalLightingMap ()
		CompositeLM.fileType 		= CompositeLMPath
		CompositeLM.fileName  		= CompositeLMPath

		#clear any bake properties on the bakemesh
		node.INodeBakeProperties.removeAllBakeElements()
		#Add bake nodes
		node.INodeBakeProperties.addBakeElement (CompositeLM)

		node.INodeBakeProperties.bakeEnabled 	= True
		node.INodeBakeProperties.flags 			= 1
		node.INodeBakeProperties.bakeChannel 	= lmBakeSettings['uv_channel']
		node.INodeBakeProperties.nDilations 	= lmBakeSettings['dialation']


		mxs.renderWidth		= lmBakeSettings['texture_size']
		mxs.renderHeight	= lmBakeSettings['texture_size']
	
	def getSceneBitmaps(self ):
		'''Gets all the BitmapTexture resouces'''
		sceneBitmapList = mxs.GetClassInstances( mxs.BitmapTexture)
		resource = []
		for item in sceneBitmapList:
			bitmap = item
			if len(bitmap.filename) > 0:
				resource.append (bitmap)
		return resource
		
	def setPathsToServer(self, bitmaps): 
		'''Sets the image paths to point to the server'''
		originalPaths = []	
		lmBakeSettings = self.getLMBSettings()
		serverAddress = lmBakeSettings['network_address']	
		for item in bitmaps:
			originalPaths.append(item.FileName)
			currentFileName = mxs.filenameFromPath(item.FileName)
			item.FileName = serverAddress + '\\' + currentFileName
		return originalPaths
		
	def restorePaths(self, originalPathsList, bitmapList):
		'''Restores the image paths from the server to original'''
		for i in range(0, len(bitmapList)):
			bitmap = bitmapList[i]
			orgFileName = originalPathsList[i]
			bitmap.filename = orgFileName
			
	def renderMesh(self, node, renderType):
		'''Sends the given node to the render farm'''
		#get the Lightmap tool settings------------------------------------------------
		lmBakeSettings = self.getLMBSettings()
		serverAddress = lmBakeSettings['network_address']
		WBCameraSetting = lmBakeSettings['use_wb_camera']
		networkRendering = lmBakeSettings['network_render']
		#Get scene name and path information--------------------------------------------
		sceneData 	= ru.GetCurrentScenePath()
		path 		= sceneData[0]
		sceneName 	= sceneData[1] + "_"
		dlmTypes = ['Red','Green','Blue']
			
		orgPaths = []
		
		wbCam = None 
		if WBCameraSetting  == 2:
			wbCam = vru.SetVrayCamera()
		
		if networkRendering == 2:
			#TODO: write a funct6ion that returns a unique list of images
			#      to replace the getUniqueBitmaps() fuction
			maxBitmapList = self.getUniqueBitmaps()
			self.copyImagesToRenderFarm( maxBitmapList, serverAddress )

			renderOutputPath = serverAddress + '\\' + sceneData[1]  + '\\' 
			
			bitmapList = self.getSceneBitmaps()

			orgImagePathsList = self.setPathsToServer(bitmapList)
			
			#Lightmap preset setting logic ---------------------------------------------------	
			if renderType == 'lm':
				self.setLightMapRTT_Network(node, renderOutputPath, sceneName)
				mxs.select(node)
				
				#turn off the tranparencies during AlphaLM render
				if node.Name == 'AlphaLM':
					mu.makeVrayMaterialOpac( node.material, False)
					self.sendToRenderNetwork( node, serverAddress )
					mu.makeVrayMaterialOpac( node.material, True) #Turn transparencies back on 
				else:
					self.sendToRenderNetwork( node, serverAddress )
				
			if renderType == 'dlm':
				vectorMaterials = mu.makeVectorMaterials()
				originalMaterial = node.material
				
				#turn off the tranparencies during AlphaLM render
				if node.Name == 'AlphaLM':
					mu.makeVrayMaterialOpac( node.material, False)
					self.sendToRenderNetwork( node, serverAddress )
					mu.makeVrayMaterialOpac( node.material, True) #Turn transparencies back on 
				else:
					for type in dlmTypes:
						mu.makeVrayMaterialVectored(node.material, type)
						self.setDirectionalRTT_Network(node, renderOutputPath, sceneName, type)
						self.sendToRenderNetwork( node, serverAddress )
						
				node.material = originalMaterial
				
			if renderType == 'ao':
				#set up the scene for AO baking
				originalMat = node.material 
				originalRPS = self.setTempRenderPreset()
				
				AOMat = mu.makeAmbienOcclusionMat()
				node.material = AOMat
				
				self.setAmbienOcclusionRTT_Network(node, renderOutputPath, sceneName)
				
				#Bake the map--set camera in presepctive mode or the output will be black. 
				mxs.actionMan.executeAction( 0, "40182")
				mxs.select(node)
				self.sendToRenderNetwork( node, serverAddress )
				
				#Restore Settings
				mxs.renderPresets.loadall(0, originalRPS)
				node.material = originalMat
				
			self.restorePaths(orgImagePathsList, bitmapList)

		if networkRendering == 0:
			#Lightmap preset setting logic ---------------------------------------------------	
			if renderType == 'lm':
				self.setLightMapRTT(node, path, sceneName)
				mxs.select( node )
				
				#turn off the tranparencies during AlphaLM render
				if node.Name == 'AlphaLM':
					mu.makeVrayMaterialOpac( node.material, False)
					mxs.render (rendertype = nfy('bakeSelected'), vfb = True)
					mu.makeVrayMaterialOpac( node.material, True) #Turn transparencies back on 
				else:
					mxs.render (rendertype = nfy('bakeSelected'), vfb = True)

			if renderType == 'dlm':
				vectorMaterials = mu.makeVectorMaterials()
				originalMaterial = node.material
				mxs.select( node )
				
				#turn off the tranparencies during AlphaLM render
				if node.Name == 'AlphaLM':
					mu.makeVrayMaterialOpac( node.material, False)
					mxs.render (rendertype = nfy('bakeSelected'), vfb = True)
					mu.makeVrayMaterialOpac( node.material, True) #Turn transparencies back on 
				else:
					for type in dlmTypes:
						mu.makeVrayMaterialVectored(node.material, type)
						self.setDirectionalRTT(node, path, sceneName, type)
						mxs.render (rendertype = nfy('bakeSelected'), vfb = True)
					
				node.material = originalMaterial
				
			if renderType == 'ao':
				#set up the scene for AO baking
				originalMat = node.material 
				AOMat = mu.makeAmbienOcclusionMat()
				originalRPS = self.setTempRenderPreset()
				self.setAmbienOcclusionRTT(node, path, sceneName)
				node.material = AOMat
				
				#Bake the map
				mxs.select( node )
				mxs.actionMan.executeAction( 0, "40182") #set camera in presepctive mode. 
				mxs.render (rendertype = nfy('bakeSelected'), vfb = True)
					
				#Restore Settings
				mxs.renderPresets.loadall(0, originalRPS)
				node.material = originalMat
				
			
			#mxs.clearselection()	
		if wbCam != None:
			mxs.delete(wbCam)
			
	#GUI STUFF
	def keyPressEvent(self, e):
		'''Escape key event'''
		if e.key() == QtCore.Qt.Key_Escape:
			#return back the layer 
			btnState = self.ui_btn_bakeMode.isChecked()
			if btnState == True:
				glm.setMaxLayerVisibility(self.layerVisibility)
				mxs.completeRedraw()
			self.close()
			
	def closeEvent( self, event ):
		btnState = self.ui_btn_bakeMode.isChecked()
		if btnState == True:
			glm.setMaxLayerVisibility(self.layerVisibility)
			mxs.completeRedraw()
				
		self.recordSettings()
		super(LightmapBakerDialog,self).closeEvent( event )
	
	def recordSettings( self ):

		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/LightmapBaker', shared=True )
		pref.recordProperty( 'geom', self.geometry() )
		pref.recordProperty('lm_cb_state', int(self.ui_chb_bakeLightMap.checkState()))
		pref.recordProperty('ao_cb_state', int(self.ui_chb_bakeAO.checkState()))
		pref.recordProperty('dlm_cb_state', int(self.ui_chb_bakeDirectionalLM.checkState()))
		#print self.geometry() 

		pref.save()
			
	def restoreSettings( self ):
		r"""
			\remarks    restores settings that were saved by a previous session
		"""

		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/LightmapBaker', shared=True )
		
		# reload the geometry
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )

		lm_cb_state = pref.restoreProperty( 'lm_cb_state')
		ao_cb_state = pref.restoreProperty( 'ao_cb_state')
		dlm_cb_state = pref.restoreProperty( 'dlm_cb_state')
		
		if lm_cb_state !=  None:
			self.ui_chb_bakeLightMap.setCheckState( lm_cb_state )
		if ao_cb_state !=  None:
			self.ui_chb_bakeAO.setCheckState( ao_cb_state )
		if dlm_cb_state !=  None:
			self.ui_chb_bakeDirectionalLM.setCheckState( dlm_cb_state )

		
		# restore additional settings
		#self.uiSomeDDL.setCurrentIndex( pref.restoreProperty( 'index', 0 ) )
	
	def showEvent ( self, event):
		r"""
			\remarks    [virtual]   overload the show event to handle loading of preferences when displaying
			\param      event       <QEvent>
		"""
		# restore settings from last session
		self.restoreSettings()
	
	
	
def __main__(  ):
	dialog = LightmapBakerDialog(None)
	
	dialog.show()
	return True
#__main__() 
