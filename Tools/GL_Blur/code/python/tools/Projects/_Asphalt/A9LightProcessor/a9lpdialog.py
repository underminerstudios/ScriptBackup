##
#	\namespace	MyTool.mytooldialog
#
#	\remarks	The main Dialog definition for the MyTool tool
#
#	\author		beta@blur.com
#	\author		Blur Studio
#	\date		01/10/11
#

# we import from blurdev.gui vs. QtGui becuase there are some additional
# management features for running the Dialog in multiple environments
import os
import operator

import blurdev
from blurdev import prefs
from blurdev.gui import Dialog
#from Py3dsMax import mxs # import max module
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import PyQt4.uic # Loader file for ui parsing
from lxml import etree as ET
import os, os.path , stat
import shutil, subprocess

import sys
import getopt

##Global Decs
parser = ET.XMLParser(ns_clean=True)
sceneTree = []
lightTree = []


def execBat(bat):
    p = Popen(bat, shell=False)
    stdout, stderr = p.communicate()
    os.remove(bat)

class A9LPDialog(Dialog):

	def __init__(self, parent=None):
		super(A9LPDialog, self).__init__(parent)
		blurdev.gui.loadUi(__file__, self)
		iconfp = os.path.join(os.path.dirname(__file__), 'img', 'icon.png')
		self.tool_img_path = os.path.split( __file__ )[0] + '/img/'
		self.open_ico = QIcon(self.tool_img_path + 'box_open.png')
		self.closed_ico = QIcon(self.tool_img_path + 'box_closed.png')
		self.layer_ico = QIcon(self.tool_img_path + 'layers.png')
		self.xrefclosed_ico = QIcon(self.tool_img_path + 'brick.png')
		self.xrefedit_ico = QIcon(self.tool_img_path + 'brick_edit.png')
		self.setWindowIcon(QIcon(iconfp))
		self.restoreSettings()
		self.setWindowTitle('A9 Light Processor')
		self.connect()

	def connect(self):
		self.ui_btn_setscnpath.clicked.connect(self.getScenePath)
#		self.ui_btn_setlgtpath.clicked.connect(self.getLightPath)
		self.ui_btn_addscnres.clicked.connect(self.addSceneRes)
		self.ui_btn_rmvscnres.clicked.connect(self.rmvSceneRes)
		self.ui_btn_addlgtres.clicked.connect(self.addLightRes)
		self.ui_btn_addenvres.clicked.connect(self.addEnvRes)
		self.ui_btn_rmvlgtres.clicked.connect(self.rmvLightRes)
		self.ui_btn_procscn.clicked.connect(self.processScene)
		self.ui_btn_proclgt.clicked.connect(self.processLights)
		self.ui_btn_getexportpath.clicked.connect(self.getExportPath)
		self.ui_btn_launchenlighten.clicked.connect(self.LaunchEnlighten)

	def getScenePath(self):
		if os.path.isfile(str(self.ui_ln_scncfgpath.text())):
			oPath = (str(self.ui_ln_scncfgpath.text()))
		else:
			oPath = 'C:\\'
		scenedir = QFileDialog.getOpenFileName(self, 'Browse Scene Config File', oPath, '*.xml')
		self.ui_ln_scncfgpath.setText(scenedir)


	
	def processScene(self):
		sceneInfo = []
		scenePaths = []
		glo_ScenePath = (str(self.ui_ln_exportpath.text())) + '\\'
		## Scene Info stores Dict values, Scene Paths store the resource paths
		sTree = self.ui_tree_scene
		SceneTree = self.ui_tree_scene.invisibleRootItem()
		sItemCount = SceneTree.childCount()
		## Get List elements in the Treeview
		for i in range(sItemCount):
			item = SceneTree.child(i)
			sceneRes = str(item.text(0))
			scenePaths.append(sceneRes)
			## Got scene Path Parsing XML
			sTree = ET.parse(sceneRes, parser)
			root = sTree.getroot()
			for Element in root:
				if Element.tag == 'instance':
					sceneDict = {'name' : Element.attrib['name'],
						 'systemId' : Element.attrib['systemId'],
						 'paramSet' : Element.attrib['paramSet'],
						 'geometry' : Element.attrib['geometry'],
						 'type' : Element.attrib['type'],
						 'lmName' : Element.attrib['lmName'],
						 'lmType' : Element.attrib['lmType'],
						 'position' : Element.attrib['position'],
						 'rotation' : Element.attrib['rotation']}

					sceneInfo.append(dict(sceneDict))

		root = ET.Element('scene')
		root.set('name', 'GeoMaxExport')
		root.set('version', '1')
		for inst in sceneInfo:
			instance = ET.SubElement(root,'instance')
			instance.set('name',inst['name'])
			instance.set('systemId',inst['systemId'])
			instance.set('paramSet',inst['paramSet'])
			instance.set('geometry',inst['geometry'])
			instance.set('type',inst['type'])
			instance.set('lmName',inst['lmName'])
			instance.set('lmType',inst['lmType'])
			instance.set('position',inst['position'])
			instance.set('rotation',inst['rotation'])


		oSceneFile = ET.ElementTree(root)
		self.checkGeoPath()
		oSceneFile.write(glo_ScenePath + 'GeoMaxExport\\GeoMaxExport.scene', pretty_print=True)
		self.processParamSet(scenePaths)
		self.copySceneResources(scenePaths)

	def getExportPath(self):
		if os.path.isfile(str(self.ui_ln_exportpath.text())):
			glo_ScenePath = (str(self.ui_ln_exportpath.text()))  + '\\'
		else:
			glo_ScenePath = 'C:\\'
		scenedir = QFileDialog.getExistingDirectory(self, 'Browse Export Path', glo_ScenePath)
		self.ui_ln_exportpath.setText(scenedir)

	def processLights(self):
		lightInfo = []
		lightPaths = []
		environmentRes = ''
		glo_ScenePath = (str(self.ui_ln_exportpath.text()))  + '\\'


		lTree = self.ui_tree_light
		LightTree = self.ui_tree_light.invisibleRootItem()
		lItemCount = LightTree.childCount()

		for i in range(lItemCount):
			item = LightTree.child(i)
			lightRes = str(item.text(0))
			if lightRes.find('[Environment]') != 0:
				lightPaths.append(lightRes)
			else:
				environmentRes = lightRes.strip('[Environment]')

		for lightRes in lightPaths:
			lTree = ET.parse(lightRes, parser)
			root = lTree.getroot()

			filepath = os.path.dirname(os.path.dirname(lightRes))
			paths = filepath.rsplit('/')

			pC = int(len(paths)) - 1
			pPrefix = str(paths[pC]) + '_'



			for Element in root:
				if Element.tag == 'light':
					lightDict = {'name' : pPrefix + (Element.attrib['name']),
						 'type' :  Element.attrib['type'],
						 'matrix' :  Element.attrib['matrix'],
						 'colour' :  Element.attrib['colour'],
						 'intensity' :  Element.attrib['intensity'],
						 'indirectColour' :  Element.attrib['indirectColour'],
						 'indirectIntensity' :  Element.attrib['indirectIntensity'],
						 'near' :  Element.attrib['near'],
						 'far' :  Element.attrib['far'],
						 'intensityRadius' :  Element.attrib['intensityRadius'],
						 'epsilon' :  Element.attrib['epsilon'],
						 'coneAngle' :  Element.attrib['coneAngle'],
						 'innerConeAngle' :  Element.attrib['innerConeAngle'],
						 'falloffModel' :  Element.attrib['falloffModel'],
						 'exponent' :  Element.attrib['exponent'],
						 'radiosityMultiplier' :  Element.attrib['radiosityMultiplier'],
						 'pointRadius' :  Element.attrib['pointRadius'],
						 'rectangleWidth' :  Element.attrib['rectangleWidth'],
						 'rectangleHeight' :  Element.attrib['rectangleHeight'],
						 'useCuda' :  Element.attrib['useCuda'],
						 'directionalSpread' :  Element.attrib['directionalSpread'],
						 'lightUsage' :  Element.attrib['lightUsage'],
						 'castsShadow' :  Element.attrib['castsShadow'],
						 'disableDirect' :  Element.attrib['disableDirect'],
						 'animDuration' :  Element.attrib['animDuration']}
					lightInfo.append(dict(lightDict))

		if environmentRes != '':
			lTree = ET.parse(environmentRes, parser)
			root = lTree.getroot()
			for Element in root:
				if Element.tag == 'light':
					if Element.attrib['type'] == '2':
						directionalDict = {'name' : Element.attrib['name'],
							 'type' :  Element.attrib['type'],
							 'matrix' :  Element.attrib['matrix'],
							 'colour' :  Element.attrib['colour'],
							 'intensity' :  Element.attrib['intensity'],
							 'indirectColour' :  Element.attrib['indirectColour'],
							 'indirectIntensity' :  Element.attrib['indirectIntensity'],
							 'near' :  Element.attrib['near'],
							 'far' :  Element.attrib['far'],
							 'intensityRadius' :  Element.attrib['intensityRadius'],
							 'epsilon' :  Element.attrib['epsilon'],
							 'coneAngle' :  Element.attrib['coneAngle'],
							 'innerConeAngle' :  Element.attrib['innerConeAngle'],
							 'falloffModel' :  Element.attrib['falloffModel'],
							 'exponent' :  Element.attrib['exponent'],
							 'radiosityMultiplier' :  Element.attrib['radiosityMultiplier'],
							 'pointRadius' :  Element.attrib['pointRadius'],
							 'rectangleWidth' :  Element.attrib['rectangleWidth'],
							 'rectangleHeight' :  Element.attrib['rectangleHeight'],
							 'useCuda' :  Element.attrib['useCuda'],
							 'directionalSpread' :  Element.attrib['directionalSpread'],
							 'lightUsage' :  Element.attrib['lightUsage'],
							 'castsShadow' :  Element.attrib['castsShadow'],
							 'disableDirect' :  Element.attrib['disableDirect'],
							 'animDuration' :  Element.attrib['animDuration']}
				if Element.tag == 'aux':
					environmentDict = {'type' : Element.attrib['type'],
								'envFilename' : Element.attrib['envFilename'],
								'envInfluence' : Element.attrib['envInfluence'],
								'envColor' : Element.attrib['envColor'],
								'bloomMultiplier' : Element.attrib['bloomMultiplier'],
								'bloomThreshold' : Element.attrib['bloomThreshold'],
								'brightness' : Element.attrib['brightness'],
								'cascadeStretch' : Element.attrib['cascadeStretch'],
								'contrast' : Element.attrib['contrast'],
								'fogAlpha' : Element.attrib['fogAlpha'],
								'fogColour' : Element.attrib['fogColour'],
								'fogT' : Element.attrib['fogT'],
								'sharpnessNPR' : Element.attrib['sharpnessNPR'],
								'sharpnessScale' : Element.attrib['sharpnessScale'],
								'sharpnessThreshold' : Element.attrib['sharpnessThreshold'],
								'toneMapRadiosity' : Element.attrib['toneMapRadiosity'],
								'ssaoIntensity' : Element.attrib['ssaoIntensity'],
								'ssaoScale' : Element.attrib['ssaoScale'],
								'ssaoSceneScale' : Element.attrib['ssaoSceneScale'],
								'ssaoRadius' : Element.attrib['ssaoRadius'],
								'probeVolumeSpacing' : Element.attrib['probeVolumeSpacing'],
								'dynamicObjectInnerRadius' : Element.attrib['dynamicObjectInnerRadius'],
								'dynamicObjectCutoffRadius' : Element.attrib['dynamicObjectCutoffRadius']}


		root = ET.Element('lights')
		root.set('version', '1')
		root.set('animPlaybackFactor','1.000000')

		for lght in lightInfo:
			if lght['type'] != '2':
				light = ET.SubElement(root,'light')
				light.set('name',lght['name'])
				light.set('type',lght['type'])
				light.set('matrix',lght['matrix'])
				light.set('colour',lght['colour'])
				light.set('intensity',lght['intensity'])
				light.set('indirectColour',lght['indirectColour'])
				light.set('indirectIntensity',lght['indirectIntensity'])
				light.set('far',lght['far'])
				light.set('intensityRadius',lght['intensityRadius'])
				light.set('epsilon',lght['epsilon'])
				light.set('coneAngle',lght['coneAngle'])
				light.set('innerConeAngle',lght['innerConeAngle'])
				light.set('falloffModel',lght['falloffModel'])
				light.set('exponent',lght['exponent'])
				light.set('radiosityMultiplier',lght['radiosityMultiplier'])
				light.set('pointRadius',lght['pointRadius'])
				light.set('rectangleWidth',lght['rectangleWidth'])
				light.set('rectangleHeight',lght['rectangleHeight'])
				light.set('useCuda',lght['useCuda'])
				light.set('directionalSpread',lght['directionalSpread'])
				light.set('lightUsage',lght['lightUsage'])
				light.set('castsShadow',lght['castsShadow'])
				light.set('disableDirect',lght['disableDirect'])
				light.set('animDuration',lght['animDuration'])
		if directionalDict:
			light = ET.SubElement(root,'light')
			light.set('name',directionalDict['name'])
			light.set('type',directionalDict['type'])
			light.set('matrix',directionalDict['matrix'])
			light.set('colour',directionalDict['colour'])
			light.set('intensity',directionalDict['intensity'])
			light.set('indirectColour',directionalDict['indirectColour'])
			light.set('indirectIntensity',directionalDict['indirectIntensity'])
			light.set('far',directionalDict['far'])
			light.set('intensityRadius',directionalDict['intensityRadius'])
			light.set('epsilon',directionalDict['epsilon'])
			light.set('coneAngle',directionalDict['coneAngle'])
			light.set('innerConeAngle',directionalDict['innerConeAngle'])
			light.set('falloffModel',directionalDict['falloffModel'])
			light.set('exponent',directionalDict['exponent'])
			light.set('radiosityMultiplier',directionalDict['radiosityMultiplier'])
			light.set('pointRadius',directionalDict['pointRadius'])
			light.set('rectangleWidth',directionalDict['rectangleWidth'])
			light.set('rectangleHeight',directionalDict['rectangleHeight'])
			light.set('useCuda',directionalDict['useCuda'])
			light.set('directionalSpread',directionalDict['directionalSpread'])
			light.set('lightUsage',directionalDict['lightUsage'])
			light.set('castsShadow',directionalDict['castsShadow'])
			light.set('disableDirect',directionalDict['disableDirect'])
			light.set('animDuration',directionalDict['animDuration'])
		if environmentDict:
			env = ET.SubElement(root,'aux')
			env.set('type',environmentDict['type'])
			env.set('envFilename',environmentDict['envFilename'])
			env.set('envInfluence',environmentDict['envInfluence'])
			env.set('envColor',environmentDict['envColor'])
			env.set('bloomMultiplier',environmentDict['bloomMultiplier'])
			env.set('bloomThreshold',environmentDict['bloomThreshold'])
			env.set('brightness',environmentDict['brightness'])
			env.set('cascadeStretch',environmentDict['cascadeStretch'])
			env.set('contrast',environmentDict['contrast'])
			env.set('fogAlpha',environmentDict['fogAlpha'])
			env.set('fogColour',environmentDict['fogColour'])
			env.set('fogT',environmentDict['fogT'])
			env.set('sharpnessNPR',environmentDict['sharpnessNPR'])
			env.set('sharpnessScale',environmentDict['sharpnessScale'])
			env.set('sharpnessThreshold',environmentDict['sharpnessThreshold'])
			env.set('toneMapRadiosity',environmentDict['toneMapRadiosity'])
			env.set('ssaoIntensity',environmentDict['ssaoIntensity'])
			env.set('ssaoScale',environmentDict['ssaoScale'])
			env.set('ssaoSceneScale',environmentDict['ssaoSceneScale'])
			env.set('ssaoRadius',environmentDict['ssaoRadius'])
			env.set('probeVolumeSpacing',environmentDict['probeVolumeSpacing'])
			env.set('dynamicObjectInnerRadius',environmentDict['dynamicObjectInnerRadius'])
			env.set('dynamicObjectCutoffRadius',environmentDict['dynamicObjectCutoffRadius'])





		oLightFile = ET.ElementTree(root)
		self.checkGeoPath()
		oLightFile.write(glo_ScenePath + 'GeoMaxExport\\GeoMaxExport.lights', pretty_print=True)
		
	def processParamSet(self, scenePaths):
		glo_ScenePath = (str(self.ui_ln_exportpath.text()))  + '\\'
		sParamSetPaths = []
		sParamSets = []
		paramid = -1

		for path in scenePaths:
			paramSetPath = os.path.dirname(os.path.dirname(path)) + '/Default.paramset'
			sParamSetPaths.append(paramSetPath)
		for paramsetfile in sParamSetPaths:
			pTree = ET.parse(paramsetfile, parser)
			root = pTree.getroot()
			
			for Element in root:
				if Element.tag == 'parameterSet':
					paramid += 1
					paramDict = {'name' : Element.attrib['name'],
								 'id' : str(paramid),
								 'outputPixelSize' : Element.attrib['outputPixelSize'],
								 'clusterSize' : Element.attrib['clusterSize']}
					sParamSets.append(dict(paramDict))

		root = ET.Element('parameterSetList')
		root.set('version', '1')
		for param in sParamSets:
			paramset = ET.SubElement(root,'parameterSet')
			paramset.set('name',param['name'])
			paramset.set('id',param['id'])
			paramset.set('outputPixelSize',param['outputPixelSize'])
			paramset.set('clusterSize',param['clusterSize'])
		self.checkGeoPath()
		oParamFile = ET.ElementTree(root)
		oParamFile.write(glo_ScenePath + 'Default.paramset', pretty_print=True)


	def LaunchEnlighten(self):
		scenedir = self.ui_ln_exportpath.text()
		scenefile = (str(scenedir) + "\\GeoMaxExport\\GeoMaxExport.scene")
		georadpath = ("S:\\code\\python\\tools\\Projects\\_Asphalt\\A9Enlighten\\Bin\\GeoRadiosity.exe")
		if os.path.isfile(scenefile):
#			shutil.copy("S:\\code\\python\\tools\\Projects\\_Asphalt\\A9Enlighten\\Bin\\georadiosity.bat",(str(scenedir) + "\\GeoMaxExport\\"))
			self.WriteBatFile()
			georadpath = (str(scenedir) + "\\GeoMaxExport\\georadiosity.bat")
			subprocess.call(str(georadpath))
			os.remove(str(georadpath))
		else:
		  subprocess.call(str(georadpath))

	def WriteBatFile(self):
		scenedir = self.ui_ln_exportpath.text()
		scene = str(scenedir) + '\\GeoMaxExport\\GeoMaxExport.scene'
		ln1 = '@echo off\n'
		ln2 = 'cd /d %~dp0\n'
		ln3 = 'start S:\\code\\python\\tools\\Projects\\_Asphalt\\A9Enlighten\\Bin\\GeoRadiosity.exe -scene:' + scene
		georadbat = open((str(scenedir) + '\\GeoMaxExport\\georadiosity.bat'), 'w')
		georadbat.write(ln1)
		georadbat.write(ln2)
		georadbat.write(ln3)
		georadbat.close()

	def copySceneResources(self, scenePaths):
		glo_ScenePath = (str(self.ui_ln_exportpath.text()))  + '\\'
		for path in scenePaths:
			sPath = ET.parse(path, parser)
			root = sPath.getroot()
			for Element in root:
				geo = ''
				if Element.tag == 'instance':
					geo = Element.attrib['geometry']
					ipath = os.path.dirname(os.path.dirname(path)) + '/' + geo
					opath = (glo_ScenePath + geo)
					self.cleanpath(opath)
					shutil.copytree(ipath, opath)
	def cleanpath(self, path):
		if os.path.isdir(path):
			subprocess.check_call(('attrib -R ' + path + '\\* /S').split())
			shutil.rmtree(path)

	def checkGeoPath(self):
		glo_ScenePath = (str(self.ui_ln_exportpath.text()))  + '\\'
		if not os.path.isdir(glo_ScenePath + 'GeoMaxExport\\'):
			os.makedirs(glo_ScenePath + 'GeoMaxExport\\')

	def addSceneRes(self):
		oPath = 'C:\\'
		sceneRes = QFileDialog.getOpenFileName(self, 'Browse Scene File', oPath, '*.scene')
		sceneRes = str(sceneRes)
		instName = []
		sTree = ET.parse(sceneRes, parser)
		root = sTree.getroot()
		for Element in root:
			if Element.tag == 'instance':
#				self.refreshSceneTree()
				elementName = Element.attrib['name']
				instName.append(elementName)
		if instName:
			self.appendSceneNode(sceneRes , instName)

	def addLightRes(self):
		oPath = 'C:\\'
		sceneRes = QFileDialog.getOpenFileName(self, 'Browse Scene File', oPath, '*.lights')
		sceneRes = str(sceneRes)
		lghtName = []
		sTree = ET.parse(sceneRes, parser)
		root = sTree.getroot()
		for Element in root:
			if Element.tag == 'light':
#				self.refreshSceneTree()
				elementName = Element.attrib['name']
				lghtName.append(elementName)
		if lghtName:
			self.appendLightNode(sceneRes , lghtName)

	def addEnvRes(self):
		oPath = 'C:\\'
		sceneRes = QFileDialog.getOpenFileName(self, 'Browse Environment File', oPath, '*.lights')
		sceneRes = '[Environment]' + str(sceneRes)
		self.appendEnvNode(sceneRes)

	def rmvSceneRes(self):
		sTree = self.ui_tree_scene
		i = sTree.currentItem()
		sTree.takeTopLevelItem(sTree.indexOfTopLevelItem(i))
	
	def rmvLightRes(self):
		sTree = self.ui_tree_light
		i = sTree.currentItem()
		sTree.takeTopLevelItem(sTree.indexOfTopLevelItem(i))

	def appendSceneNode(self, nodeName, instName):
		sTree = QTreeWidgetItem ( self.ui_tree_scene )
		sTree.setText(0, QString(nodeName))
		for instance in instName:
			child = QTreeWidgetItem( sTree )
			child.setText (0, QString(instance))
	
	def appendLightNode(self, nodeName, lghtName):
		sTree = QTreeWidgetItem ( self.ui_tree_light )
		sTree.setText(0, QString(nodeName))
		for light in lghtName:
			child = QTreeWidgetItem( sTree )
			child.setText (0, QString(light))

	def appendEnvNode(self, nodeName):
		sTree = QTreeWidgetItem ( self.ui_tree_light )
		sTree.setText(0, QString(nodeName))

	def refreshSceneTree(self, nodeName, instName):
		pass

	def clearSceneTree(self):
		sTree = self.ui_tree_scene
		sTree.clear()

	def closeEvent(self, event):
		self.recordSettings()
		super(A9LPDialog, self).closeEvent(event)

	def recordSettings(self):
		pass

	def restoreSettings(self):
		pass