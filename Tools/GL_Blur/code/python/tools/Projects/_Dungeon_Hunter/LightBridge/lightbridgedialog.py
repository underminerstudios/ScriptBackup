##
#   :namespace  lightbridgedialog
#
#   :remarks    import/export Enlighten xml light
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       07/29/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments

from blurdev.gui import Dialog
from Py3dsMax import mxs # import max module
from PyQt4 import QtCore, QtGui, QtXml

import math

#-----------------------------------------------------------------#

class LightBridgeDialog( Dialog ):
	
	def __init__( self, parent = None ):
		super(LightBridgeDialog,self).__init__( parent )
		# load the ui
		import blurdev
		blurdev.gui.loadUi( __file__, self )
		
		self.connect()
	#-----------------------------------------------------------------#	
	
	def connect(self):
		self.importButton.clicked.connect	(self.importLight)
		self.exportButton.clicked.connect	(self.exportLight)
		
	#-----------------------------------------------------------------#
	#-------------------------- IMPORT -------------------------------#
	#-----------------------------------------------------------------#
	def importLight(self):
		#Select xml light file
		fileName = QtGui.QFileDialog.getOpenFileName(self,"Open Light File", "Q:\\raw_data\\iphone\\assets\\modules\\_benchmark\\geoRadiosity\\GeoMaxExport\\","Enlighten Files (*.lights)")
		
		#verify if file selected
		if not fileName:
			QtGui.QMessageBox.warning(self, "LightBridge","Any light file have been selected")
			return
		
		lightFile = QtCore.QFile(fileName)
		
		#Verify if file is readable
		if not lightFile.open(QtCore.QFile.ReadOnly | QtCore.QFile.Text):
			QtGui.QMessageBox.warning(self, "LightBridge","Cannot read file %s:\n%s." % (fileName, lightFile.errorString()))
			return
			
		#import QtXml
		self.domDocument = QtXml.QDomDocument()
		
		#Verify if file is an xml structure
		ok, errorStr, errorLine, errorColumn = self.domDocument.setContent(lightFile, True)
		if not ok:
			QtGui.QMessageBox.information(self.window(), "LightBridge","Parse error at line %d, column %d:\n%s" % (errorLine, errorColumn, errorStr))
			return
		
		root = self.domDocument.documentElement()
		if root.tagName() != 'lights':
			QtGui.QMessageBox.information(self.window(), "LightBridge","The file is not an enlighten file.")
			print root.tagName()
		
		child = root.firstChildElement('light')
		while not child.isNull():
			self.parseLightElement(child)
			child = child.nextSiblingElement('light')
			
		child = root.firstChildElement('aux')
		while not child.isNull():
			self.parseAuxElement(child)
			child = child.nextSiblingElement('aux')	
		
	#-----------------------------------------------------------------#
	#--------------------- PARSE SETTING -----------------------------#
	#-----------------------------------------------------------------#
	
	def parseAuxElement(self, element, parentItem=None):
		
		if self.btt_env.isChecked():
			# Set background color
			envColor = str(element.attribute("envColor"))
				
			if self.btt_gamma.isChecked():
				envColor = [math.pow(float(c),(1/self.gammaValue.value())) for c in envColor.split(' ')]
			else:
				envColor = [float(c) for c in envColor.split(' ')]
				
			maxColor = mxs.color(
							min(255, int( envColor[0] * 255)),
							min(255, int( envColor[1] * 255)),
							min(255, int( envColor[2] * 255))
						)
			mxs.backgroundColor = maxColor
			
	#-----------------------------------------------------------------#
	#------------------------ PARSE LIGHT ----------------------------#
	#-----------------------------------------------------------------#
	
	def parseLightElement(self, element, parentItem=None):
		
		lgName = self.nameSpace.text() + "_" + element.attribute("name")
		
		lgType = int(element.attribute("type"))
		#type 0:spot 1:point 2:direct 3:area
		if lgType == 0:
			#print "freeSpot"
			lgItem = mxs.freeSpot(name=lgName)
			
		elif lgType == 1:
			#print "omniLight"
			lgItem = mxs.omniLight(name=lgName)
			
		elif lgType == 2:
			#print "Directionallight"
			lgItem = mxs.Directionallight(name=lgName)
			
		elif lgType == 3:
			#Area light
			if self.btt_vray.isChecked():
				lgItem = mxs.VRayLight(name=lgName)
				lgItem.type = 0
			else:
				print "none Vray Area light inProgress"
				return
			
		else:
			print "unsupported light type: " + str(lgType)
			return
		
		#------------------ Light properties ------------------------#
		
		# set intensity
		if self.btt_gamma.isChecked() and self.btt_intgamma.isChecked():
			lgItem.multiplier =  math.pow( float(element.attribute("intensity")), (1/self.gammaValue.value()) ) * self.intensityValue.value()
		else:
			lgItem.multiplier =  float(element.attribute("intensity")) * self.intensityValue.value()
		
		# Set radiosity Multiplier
		mxs.setUserProp(lgItem, "VRay_Diffuse_Multipier", element.attribute("radiosityMultiplier") )
		
		# Set color
		lgColor = str(element.attribute("indirectColour"))	
		if self.btt_gamma.isChecked():
			lgColor = [math.pow(float(c),(1/self.gammaValue.value())) for c in lgColor.split(' ')]
		else:
			lgColor = [float(c) for c in lgColor.split(' ')]
		
		maxColor = mxs.color(
						min(int( lgColor[0] * self.redMult.value()*255 ), 255),
						min(int( lgColor[1] * self.greenMult.value()*255 ), 255),
						min(int( lgColor[2] * self.blueMult.value()*255 ), 255)
					)
		
		if lgType == 3:
			lgItem.color_mode = 0
			lgItem.color = maxColor
		else:
			lgItem.rgb = maxColor
			
		#wireFrame Color
		maxColor = mxs.color(
						min(int( lgColor[0] * self.redMult.value()*255 ), 255),
						min(int( lgColor[1] * self.greenMult.value()*255 ), 255),
						min(int( lgColor[2] * self.blueMult.value()*255 ), 255)
						)
		lgItem.wirecolor = maxColor
		
		#---------- Shadow -----------------------------------#
		
		if str(element.attribute("castsShadow")) == "true":	
			
			if lgType == 3:

				if self.btt_vray.isChecked():
					lgItem.AreaShadow = True
					# Shdw Radius for Vray light
					lgItem.size0 = float(element.attribute("rectangleWidth") ) 
					lgItem.size1 = float(element.attribute("rectangleHeight") )
			else:
				lgItem.baseObject.castShadows = True
				if self.btt_vray.isChecked():
					#print ("vray")
					lgItem.shadowGenerator = mxs.VRayShadow()
					# Shdw Radius for standard light
					lgSize = float(element.attribute("pointRadius") )
					mxs.setUserProp(lgItem, "#pointRadius", lgSize )
					lgItem.usize = lgSize
					lgItem.vsize = lgSize
					lgItem.wsize = lgSize
				else:
					#print("Shadow map")
					lgItem.shadowGenerator = mxs.shadowMap()
					lgItem.mapsize = self.shdwValue.value()
					
					if self.btt_global.isChecked():
						lgItem.useGlobalShadowSettings = True
					else:
						lgItem.useGlobalShadowSettings = False
		else:
			#No shdw
			print (lgName + " : NO shdw")
			#if lgType == 3:
				#lgItem.AreaShadow = False
			#else:
				#lgItem.castShadows = False
				
		# Display Volume only for omniLight
		if lgType == 1:
			lgItem.showNearAtten = False
			lgItem.nearAttenEnd = float(element.attribute("pointRadius") )
			
		#--------- Attenuation ----------------------------------#
		if lgType != 3 and lgType != 2:
			lgItem.useFarAtten = True
			lgItem.showFarAtten = False
			lgItem.farAttenStart = float(element.attribute("near") )* self.attenValue.value()
			lgItem.farAttenEnd = float(element.attribute("far") )* self.attenValue.value()
		
		# ConeAngle for spot light
		if lgType == 0:
			lgItem.hotspot = float(element.attribute("innerConeAngle")) * 45.0
			lgItem.falloff = float(element.attribute("coneAngle")) * 45.0

		#---- set Transform --------------------------------#
		#>> matrix = "1 0 0 Px 0 1 0 Py 0 0 1 Pz 0 0 0 1"
		# Position
		lgTRS = element.attribute("matrix")
		lgTRS = [float(i) for i in lgTRS.split(' ')]
		lgItem.position = mxs.Point3(lgTRS[3],lgTRS[7],lgTRS[11])
		
		# Rotation XZY
		lgMx = mxs.matrix3 (1)
		lgMx.row1 = mxs.Point3(lgTRS[0], lgTRS[4], lgTRS[8])
		lgMx.row3 = mxs.Point3(lgTRS[1], lgTRS[5], lgTRS[9])
		lgMx.row2 = mxs.Point3(lgTRS[2], lgTRS[6], lgTRS[10])
			
		mxs.rotate(lgItem, lgMx.rotationpart)
		
		#backup data
		mxs.setUserProp(lgItem, "EN:name", element.attribute("name") )
		mxs.setUserProp(lgItem, "EN:type", element.attribute("type") )
		mxs.setUserProp(lgItem, "EN:indirectColour", element.attribute("indirectColour") )
		mxs.setUserProp(lgItem, "EN:radiosityMultiplier", element.attribute("radiosityMultiplier") )
		mxs.setUserProp(lgItem, "EN:castsShadow", element.attribute("castsShadow") )
		mxs.setUserProp(lgItem, "EN:rectangleWidth", element.attribute("rectangleWidth")  )
		mxs.setUserProp(lgItem, "EN:rectangleHeight", element.attribute("rectangleHeight") )			
		mxs.setUserProp(lgItem, "EN:near", element.attribute("near") )
		mxs.setUserProp(lgItem, "EN:far", element.attribute("far") )
		mxs.setUserProp(lgItem, "EN:innerConeAngle", element.attribute("innerConeAngle") )
		mxs.setUserProp(lgItem, "EN:coneAngle", element.attribute("coneAngle") )
		mxs.setUserProp(lgItem, "EN:matrix", element.attribute("matrix") )

	#-----------------------------------------------------------------#
	#-------------------------- EXPORT -------------------------------#
	#-----------------------------------------------------------------#
	
	def exportLight(self):
		
		oSel = mxs.selection
		
		maxLights = []
		for item in oSel:
			if str(mxs.superclassof(item)) == "light":
				maxLights.append(item)
				
		for lgItem in maxLights:
			print lgItem.name
		
		
def __main__(  ):
	
	dialog = LightBridgeDialog()
	dialog.show()

	return True	
	
#__main__()	