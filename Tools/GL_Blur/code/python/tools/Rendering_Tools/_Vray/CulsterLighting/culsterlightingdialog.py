
#   :namespace  culsterlightingdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       05/24/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
from blurdev.gui import Dialog
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import PyQt4.uic # Loader file for ui parsing

from Py3dsMax import mxs # import max module
from  glmax.max3d import GLMax
nfy  = mxs.pyhelper.namify
glm = GLMax()


#exportPath = getExportPath()
#mxs.exportFile (exportPath, nfy("noPrompt"), selectedOnly = True ) #<filename_string> [ #noPrompt ] [ selectedOnly:<boolean> ] [ using:<maxclass> ] 

class CulsterLightingDialog( Dialog ):
	
	def __init__( self, parent = None ):
		super(CulsterLightingDialog,self).__init__( parent )
		# load the ui
		import blurdev
		blurdev.gui.loadUi( __file__, self )
		self.MaxColor = mxs.color(0, 0, 0)
		self.MainColor = None
		self.connect()
#		self.refreshLightClusterTree()
		exportLightPath = (mxs.maxFilePath + mxs.getFilenameFile(mxs.maxFileName) + "_lights.bdae")
#		self.txt_exportLight.text= exportLightPath

	def connect( self ):
		'''Connect all the UI elemnts '''
		self.ui_MakeLightGroup.clicked.connect ( self.makeLightClusters )
		self.btn_color.clicked.connect(self.getColorForButton)
		self.btn_setLightInfo.clicked.connect(self.setLightInfo)
		self.btn_selectChildren.clicked.connect(self.selectChildren)
		self.btn_selectLightCulster.clicked.connect(self.selectLightCulsters)
		self.btn_ExportLights.clicked.connect(self.exportLightClusters)
		self.btn_cleanClusters.clicked.connect(self.deleteEmptyClusters)
	
	def deleteEmptyClusters(self):
		emptyClusterNodes = []
		lightClusterNodes = self.getLightClusters()
		for node in lightClusterNodes:
			if len(node.children) == 0:
				emptyClusterNodes.append(node)
		mxs.delete(emptyClusterNodes)

	def exportLightClusters(self):
		'''Export the lights'''
		layer = glm.setLayer ('export_lights')
		glm.deleteLayerObjects ('export_lights')
		
		nodesToExport = self.makeExportNodes()
		for node in nodesToExport:
			node.ishidden = False
			
		mxs.select( nodesToExport )
		mxs.SuspendEditing()
		exportPath = self.getExportPath()
		mxs.exportFile (exportPath, nfy("noPrompt"), selectedOnly = True ) 
		mxs.ResumeEditing()
		layer.ishidden = True
		#glm.deleteLayerObjects ('export_lights')
		mxs.RedrawViews()
		
	def getExportPath( self ):
		'''Gets the export path for the lights '''
		sceneName = mxs.maxFilePath + mxs.maxFileName
		l = list(sceneName)
		del(l[-4:len(l)]) 
		l.append( "_Lights.bdae" )
		return "".join(l)
		
	def selectChildren( self ):
		''' selectec cluster childern'''
		oSel = mxs.selection
		nodesToSelect = []
		for node in oSel:
			branch = glm.getChildren  ( node )
			for node in branch:
				nodesToSelect.append(node)
		mxs.select(nodesToSelect)

	def getLightClusters(self):
		lightClusterNodes = []
		for node in mxs.shapes:
			if (node.name).find('lightCulster') == 0:
				lightClusterNodes.append( node )
		return lightClusterNodes
		
	def makeLightClusters(self):
		oSel = mxs.selection
		selectedTypes = self.getSelectedType ( oSel )
		count  = len(selectedTypes[0])
		
		layer = glm.setLayer ("lights")
		
		if len(selectedTypes[0]) != 0:
			center = [0,0,0]
			for light in selectedTypes[0]:
				center[0] += light.position.x
				center[1] += light.position.y
				center[2] += light.position.z
			center = mxs.Point3(center[0]/count, center[1]/count, center[2]/count)
			self.makeIcon( center, selectedTypes[0] )

		if len(selectedTypes[1]) != 0:
			self.makeVrayLightsOnGeo ( selectedTypes[1] )
		mxs.RedrawViews()

	def getClusterData( self, node ):
		'''	Gets the current node and its children returns an list'''
		lightsList = glm.getChildren ( node )
		lightDataList = []
		
		lightData = {
				'matrix3':'',
				'type': '',
				'color': '',
				'multiplier': '',
				'castShadows': '',
				'size0': None,
				'size1': None,
				'size2': None,
				'hotspot': None,
				'falloff': None,
				'decay_type': None,
				'decay_radius': None
				}
				
		for light in lightsList:
			lightType = str(mxs.classof(light))
			if str(mxs.superclassof(light) ) == "light":

				matrix = light.transform
				
				lightData['matrix3'] =str(matrix.row1) + str(matrix.row2)+ str(matrix.row3) +str(matrix.row4)
				
				if lightType == "VRayLight":
					lightData['color'] = str(light.color)
					lightData['multiplier'] = light.multiplier
					lightData['castShadows'] = light.castShadows
					if light.type == 0:
						lightData['type'] = "plane"
						lightData['size0'] = light.size0 * 2
						lightData['size1'] = light.size1 * 2
						lightData['size2'] = 0.0
					if light.type == 1:
						lightData['type'] = "dome"
						lightData['size0'] = 1.0
						lightData['size1'] = 0.0
						lightData['size2'] = 0.0				
					if light.type == 2:
						lightData['type'] = "omni"
						lightData['size0'] = light.size0 * 2
						lightData['size1'] = 0.0
						lightData['size2'] = 0.0
					if light.type == 3:
						lightData['type'] = "mesh"
						lightData['size0'] = 0.0
						lightData['size1'] = 0.0
						lightData['size2'] = 0.0

				if lightType == "freeSpot" or lightType  == "freeSpot":
					lightData['type'] = "spotlight"
					lightData['color'] = str(light.rgb)
					lightData['multiplier'] = light.multiplier
					lightData['castShadows'] = light.castShadows
					lightData['hotspot'] = light.hotspot
					lightData['falloff'] = light.falloff
					if light.attenDecay == 1:
						lightData['decay_type'] = "none"
					if light.attenDecay == 2:
						lightData['decay_type'] = "inverse"
					if light.attenDecay == 3:
						lightData['decay_type'] = "inverse_square"
				
				if lightType == "Omnilight":
					lightData['type'] = "omni"
					lightData['color'] = str(light.rgb)
					lightData['multiplier'] = light.multiplier
					lightData['castShadows'] = light.castShadows
					if light.attenDecay == 1:
						lightData['decay_type'] = "none"
					if light.attenDecay == 2:
						lightData['decay_type'] = "inverse"
						lightData['decay_radius'] = light.decayRadius
					if light.attenDecay == 3:
						lightData['decay_type'] = "inverse_square"
						lightData['decay_radius'] = light.decayRadius
					
			lightDataList.append(lightData)
			
		return lightDataList
		
	def makeLightExportNode(self, name, kine, lightClusterData):
		import json
		data = str( json.dumps(lightClusterData, indent= 4) )
		#Cleanup the string
		l = list(data)
		del(l[0]) 
		del(l[-1]) 
		data = "".join(l)
		data = data.replace('},','}')	
#		#make the boxe
		exportNode = mxs.box()
		exportNode.name = name 
		exportNode.wirecolor = mxs.color(210,5,5)
		exportNode.transform = kine
		mxs.setUserPropBuffer( exportNode, data )
		return exportNode
		
	def makeExportNodes( self ):
		lightClusters = self.getLightClusters()
		sceneLights = mxs.lights
		clusteredLights = []
		layer = glm.setLayer ("export_lights")
		exportNodes = []
		#work on light clusters
		for cluster in lightClusters:
			kine = cluster.transform

			lightClusterData = self.getClusterData(cluster)
			boxNode = self.makeLightExportNode(cluster.name, kine, lightClusterData)
			exportNodes.append(boxNode)	
			#remove lights from the scene lights list
			childLightsList = glm.getChildren ( cluster )
			for child in childLightsList:
				if str(mxs.superclassof(child) ) == "light":
					sceneLights.remove(child)
					if child.target != None:
						sceneLights.remove(child.target)
		#work on non clustered lights			
		for light in sceneLights:
			#TODO: Add additional logic to filter out unwanted lights here
			lightType = str(mxs.classof(light) )
			if lightType != "VRaySun" and lightType != "Targetobject":
				kine = light.transform
				lightClusterData = self.getClusterData(light)
				boxNode = self.makeLightExportNode(cluster.name, kine, lightClusterData)
				exportNodes.append(boxNode)
		return exportNodes

	def selectLightCulsters(self):
		nodesToSelect = self.getLightClusters()
		mxs.select(nodesToSelect)
		mxs.RedrawViews()
			
	def getSelectedType ( self, max_selection ):
		lights = []
		geo = []
		for item in max_selection:
			if str(mxs.superclassof(item)) == "light":
				lights.append(item)
			if str(mxs.superclassof(item) )== "GeometryClass":
				type = str(mxs.classof(item))
				if type != "Targetobject":
					geo.append(item)
		return [lights, geo]


	def getEdgeData(self, obj,  faceID):
		r''' 
		Gets edge data of each face for transformation 
		matrix3 to be used in placeing the lights
		'''
		faceEdges = list(mxs.polyop.getFaceEdges(obj, faceID))
		if len(faceEdges) == 4:
			longestEdgeID = None
			shortestEdgeID = None
			longestEdge = None
			shortestEdge = 1000000,
			directionVector  =  None
			
			for edge in faceEdges:
				edgeVerts = mxs.polyop.getVertsUsingEdge (obj, edge)
				tempArr = []
				for vert in range(0, len(edgeVerts) ):
					if edgeVerts[vert] == True:
						tempArr.append(mxs.polyop.getVert(obj, vert + 1) )

				vectorLength = mxs.distance((tempArr[0]), tempArr[-1])

				if vectorLength > longestEdge:

					longestEdge = float(vectorLength)
					longestEdgeID = int(edge)
					directionVector = mxs.normalize( tempArr[-1] - tempArr[0])

				if vectorLength < shortestEdge:
					shortestEdge = vectorLength
					shortestEdgeID = edge
					
			return [directionVector, longestEdge, shortestEdge]


	def makeIcon( self, center, lights ):
		r'''
		creates a light icon and parents 
		the light array to the newly created icon
		'''
		name  = mxs.uniqueName ("lightCulster_")
		
		ico = mxs.text()
		ico.size = 50
		ico.wirecolor = mxs.color(175, 25, 25)
		ico.rotation = mxs.quat( 0.707107, 0, 0, 0.707107) #rtate so that the ico is point up
		ico.text = 'R'
		ico.font = "Wingdings"
		ico.name = name
		ico.position = center
		
		for lite in lights:
			lite.parent = ico
			if lite.target != None:
				(lite.target).parent = ico
			
	def makeVrayLightsOnGeo (self, selected):
		r'''
		creates Vray lights based on the selected objects and puts 
		them into an icon parent child relationship
		'''
		center = glm.getCenterOfSelectedMeshs(selected)
		for obj in selected:

			lightArr = []
			faces = mxs.polyop.getNumFaces (obj)
			for i in range(0, faces):
				
				edgeData = self.getEdgeData(obj, i + 1)
				faceCenter = mxs.polyop.getFaceCenter( obj,  i + 1)

				X = mxs.normalize(edgeData[0]);
				N = mxs.normalize( -(mxs.polyop.getFaceNormal( obj, i + 1)));
				posOffset = N * -0.5 + faceCenter;
				Y = mxs.normalize(mxs.cross( N,  X) );
				M = (mxs.matrix3(X, Y, N, faceCenter) );
				
				vrLight = mxs.VRayLight()
				vrLight.type = 0
				vrLight.multiplier = self.ui_lightMultiply.value()
				vrLight.color  = self.MaxColor 
				vrLight.transform = M
				vrLight.size0 = edgeData[1] * 0.5;
				vrLight.size1 = edgeData[2] * 0.5
				vrLight.position = posOffset
				lightArr.append(vrLight)
			mxs.RedrawViews()
			self.makeIcon( center, lightArr )

	
	#EVENTS FOR UI
	def getColorForButton(self):
		'''Opens a color dialog and sets the color of the button'''
		col = QColorDialog.getColor()
		if col.isValid():
			self.MainColor =  col.getRgb()
			
			self.MaxColor = mxs.color(self.MainColor[0], self.MainColor[1], self.MainColor[2])
			self.btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"  % (self.MainColor[0], self.MainColor[1], self.MainColor[2]) )

	def getLightInfo( self ):
		'''Get the light information such as multiplier and color for the button''' 
		oSel = mxs.selection
		multiplier = self.ui_lightMultiply.value()

		stylesheet = str(self.btn_color.styleSheet())
		stylesheet = stylesheet[22:len(stylesheet)-1] #kinda hacky :(
		tc = stylesheet.split(",")
		r = int(tc[0])
		g = int(tc[1])
		b = int(tc[2])
#		tc =  self.btn_color.getRgb()
		color = mxs.color(r,g,b)
		
		if len(oSel) != 0:
			sel = oSel[0]
			lightType = str(mxs.classof(sel))
			if str(mxs.superclassof(sel))== "light":
				if  lightType == "VRayLight" or lightType == "freeSpot" or lightType == "targetSpot":
					multiplier = sel.multiplier
					color = sel.color
		return [multiplier, color]
		
	def setLightInfo( self ):
		r''' sets the button to'''
		lightInfo = self.getLightInfo()
		self.ui_lightMultiply.setValue(int(lightInfo[0]))
		
		newColor = QColor(int(lightInfo[1].r),int(lightInfo[1].g),int(lightInfo[1].b), 255)
		self.MainColor = newColor.getRgb()
		self.btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"  % (self.MainColor[0], self.MainColor[1], self.MainColor[2]) )
		
	def closeEvent( self, event ):
		r"""
			\remarks    [virtual]   overload the close event to handle saving of preferences before shutting down
			\param      event       <QEvent>
		"""
		self.recordSettings()
		super(CulsterLightingDialog,self).closeEvent( event )
	
	def recordSettings( self ):
		r"""
			\remarks	records settings to be used for another session
		"""
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/CulsterLighting', shared=True )
		# record the geometry
		pref.recordProperty( 'geom', self.geometry() )
		pref.recordProperty('light_multiply', self.ui_lightMultiply.value())
		pref.recordProperty('light_color', self.MainColor)
		
		# record additional settings
		# pref.recordProperty( 'index', self.uiSomeDDL.currentIndex() )
		
		# save the settings
		pref.save()
	
	def restoreSettings( self ):
		r"""
			\remarks    restores settings that were saved by a previous session
		"""
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/CulsterLighting', shared=True )
		mult = pref.restoreProperty( 'light_multiply')
		color = pref.restoreProperty ('light_color')
		self.ui_lightMultiply.setValue(mult)
		if color == None:
			self.btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"  % (255, 255, 255) )
		else:
			self.btn_color.setStyleSheet("background-color: rgb(%s, %s, %s)"  % (color[0], color[1], color[2]) )

		from PyQt4.QtCore import QRect
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )
	
	def showEvent ( self, event):
		r"""
			\remarks    [virtual]   overload the show event to handle loading of preferences when displaying
			\param      event       <QEvent>
		"""
		# restore settings from last session
		self.restoreSettings()