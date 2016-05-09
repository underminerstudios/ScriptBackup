##
#   :namespace  lmtaggerdialog
#
#   :remarks
#
#   :author     [author::email]
#   :author     [author::company]
#   :date       06/17/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
import random, blurdev
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import PyQt4.uic
from blurdev.gui import Dialog
from blurdev import prefs
from Py3dsMax import mxs # import max module
##import xml.etree.ElementTree as ET
from lxml import etree as ET

import subprocess, time
import ConfigParser, os
import shutil

from  glmax.max3d import GLMax
from  enmax.enlighten import EnlightenClass
glm = GLMax()
enm = EnlightenClass()
mxsLibpath = "S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\lib\\"
toolpath = "S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\"
config = ConfigParser.ConfigParser()
settings = (toolpath + 'settings.ini')
scenedir = ""
bakedir = ""
iPath = ""
oPath = ""
georadpath = ""
scenenodes = []

#SetUserDefinedProps ( self, _obj, _key, _value )

def checkboxtobool(oCheckbox):
	if oCheckbox == 0:
		return "false"
	else:
		return "true"

def deleteUnlitElements(oName):
	for obj in mxs.objects:
		objisnode = (obj.name).split('_')
		if objisnode[1] == oName:
			mxs.delete(obj)


def WriteMaterials(scenedir):
		mDiffuse = ""

		for obj in mxs.geometry:

			if obj.parent != None:

				oParent = (obj.parent.name).split("_")
				if oParent[0] == "inst":
					oInst = obj.parent.name
					oMesh = obj.name
					mat = obj.mat
					multisubmats = []
					root = ET.Element('materials')
					root.set("version", "1")
					if glm.classOf(mat) == "Standardmaterial":
							matid = 0
							matDict = { 'ID': 0,
										'FileName': '',
										'Diffuse': None,
										'TextureD': None,
										'TextureO': None,
										'TextureN':None}







							matDict['ID'] = matid
							matDict['Diffuse'] = mat.Diffuse

							if  mat.diffuseMap != None:
								matDict['TextureD'] = (mat.diffuseMap).filename

							if  mat.opacityMap != None:
								matDict['TextureO'] = (mat.opacityMap).filename
							if mat.bumpMap != None:
								matDict['TextureN'] = (mat.bumpMap).filename
							dDiffuse = str(matDict['Diffuse']).split(" ")
							dDiffuse[3] = dDiffuse[3].rstrip(")")
							dDiffuse[1] = round((float(dDiffuse[1]) / 255), 7)
							dDiffuse[2] = round((float(dDiffuse[2]) / 255), 7)
							dDiffuse[3] = round((float(dDiffuse[3]) / 255), 7)

							matDict['Diffuse'] = (str(dDiffuse[1]) + " " + str(dDiffuse[2]) + " " + str(dDiffuse[3]) + " " + "0.000000")
							eMaterial = ET.SubElement(root,"material")
							eMaterial.set("id", str(matDict['ID']))
							eDiffuse = ET.SubElement(eMaterial, "diffuse")
							eDiffuse.set("colour", str(matDict['Diffuse']))

							if matDict['TextureD'] != None:
								eTextureD = ET.SubElement(eDiffuse, "texture")
								eTextureD.text = matDict['TextureD']
							if matDict['TextureO'] != None:
								eOpacity = ET.SubElement(eMaterial, "opacity")
								eTextureO = ET.SubElement(eOpacity, "texture")
								eTextureO.text = matDict['TextureO']
							if matDict['TextureN'] != None:
								eNormal = ET.SubElement(eMaterial, "normal")
								eTextureN = ET.SubElement(eNormal, "texture")
								eTextureN.text = matDict['TextureN']




##					parser = ET.XMLParser(remove_blank_text=True)
##					oMats = ET.parse(str(scenedir + "\\" + oInst + "\\" + oMesh + ".mats"), parser)
##					root = oMats.getroot()


					if glm.classOf(mat) == "Multimaterial":
						for submaterial in (obj.mat).materialIDList:
							matid = submaterial - 1
							submat = obj.mat.materialList[matid]

							matDict = { 'ID': 0,
										'FileName': '',
										'Diffuse': None,
										'TextureD': None,
										'TextureO': None,
										'TextureN':None}




##							oMaterial = root[matid]
							hasdiffuse = False
							hasopacity = False
							hasnormal = False


##							xmlid = (int((oMaterial.attrib)['id']))
							submat = obj.mat.materialList[matid]


							matDict['ID'] = matid
							matDict['Diffuse'] = submat.Diffuse

							if  submat.diffuseMap != None:
								matDict['TextureD'] = (submat.diffuseMap).filename

							if  submat.opacityMap != None:
								matDict['TextureO'] = (submat.opacityMap).filename
							if submat.bumpMap != None:
								matDict['TextureN'] = (submat.bumpMap).filename
							print matDict['TextureD']
							dDiffuse = str(matDict['Diffuse']).split(" ")
							dDiffuse[3] = dDiffuse[3].rstrip(")")
							dDiffuse[1] = round((float(dDiffuse[1]) / 255), 7)
							dDiffuse[2] = round((float(dDiffuse[2]) / 255), 7)
							dDiffuse[3] = round((float(dDiffuse[3]) / 255), 7)

							matDict['Diffuse'] = (str(dDiffuse[1]) + " " + str(dDiffuse[2]) + " " + str(dDiffuse[3]) + " " + "0.000000")
							print matDict['Diffuse']
							eMaterial = ET.SubElement(root,"material")
							eMaterial.set("id", str(matDict['ID']))
							eDiffuse = ET.SubElement(eMaterial, "diffuse")
							eDiffuse.set("colour", str(matDict['Diffuse']))

							if matDict['TextureD'] != None:
								eTextureD = ET.SubElement(eDiffuse, "texture")
								eTextureD.text = matDict['TextureD']
							if matDict['TextureO'] != None:
								eOpacity = ET.SubElement(eMaterial, "opacity")
								eTextureO = ET.SubElement(eOpacity, "texture")
								eTextureO.text = matDict['TextureO']
							if matDict['TextureN'] != None:
								eNormal = ET.SubElement(eMaterial, "normal")
								eTextureN = ET.SubElement(eNormal, "texture")
								eTextureN.text = matDict['TextureN']







					oMats = ET.ElementTree(root)

					oMats.write(str(scenedir + "\\" + oInst + "\\" + oMesh + ".mats"), pretty_print=True)
##					oMats.write(("C:\\tmp\\TESTMAT.mats"), pretty_print=True)








class EnlightenDialog(Dialog):
	def __init__( self, parent = None ):
		super(EnlightenDialog,self).__init__( parent )
		# load the ui
		blurdev.gui.loadUi( __file__, self )
#Setup Combo List
		self.ui_cmb_lighttype.addItem("Radiosity")
		self.ui_cmb_lighttype.addItem("Static Set Dressing")
		self.ui_cmb_lighttype.addItem("Fully Dynamic")
		self.connect()


	def connect(self):
		self.ui_btn_launchenlighten.clicked.connect(self.LaunchEnlighten)
		self.ui_btn_getscenepath.clicked.connect(self.GetScenePath)
		self.ui_btn_exportmaxscene.clicked.connect(self.ExportMaxScene)
		self.ui_btn_converttex.clicked.connect(self.ConvertTex)
		self.ui_btn_projectselected.clicked.connect(self.ProjectSelected)
		self.ui_btn_applymeshsettings.clicked.connect(self.ApplyMeshSettings)
		self.ui_btn_generateenparams.clicked.connect(self.GenerateEnParams)
		self.ui_btn_preparemaxscene.clicked.connect(self.PrepareMaxScene)
		self.ui_btn_applynodesettings.clicked.connect(self.ApplyNodeSettings)
		self.ui_btn_applynodeglobal.clicked.connect(self.ApplyNodeGlobal)
		self.ui_refreshscenenode.clicked.connect(self.RefreshSceneNode)
		self.ui_btn_getbakepath.clicked.connect(self.GetBakePath)

		pass


	def LaunchEnlighten(self):
		scenedir = self.ui_ln_scenepath.text()
		scenefile = (str(scenedir + "\\GeoMaxExport\\GeoMaxExport.scene"))
		georadpath = ("S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\Bin\\GeoRadiosity.exe")
		if os.path.isfile(scenefile):
			shutil.copy("S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\Bin\\georadiosity.bat",(str(scenedir) + "\\GeoMaxExport\\"))
			georadpath = (scenedir + "\\GeoMaxExport\\georadiosity.bat")
			subprocess.call(str(georadpath))
			os.remove(str(georadpath))
		else:
		  subprocess.call(str(georadpath))
		pass
	def GenerateEnParams(self):
		enm.AssignMeshParams()

	def ProjectSelected(self):
		enm.AssignMeshParams()
		for obj in mxs.objects:
			objname = (obj.name).split('_')
			if objname[0] == "inst":
				mxs.select( obj )

				for i in mxs.selection:
					mxs.selectmore( i.children )

				mxs.enlighten.toggleprojection()

				mxs.enlighten.toggleprojection()





	def ApplyNodeSettings(self):
		enLMName = self.ui_ln_en_nodelm.text()
		enBKProfile = self.ui_ln_en_nodeprofileen.text()
		enType = self.ui_cmb_lighttype.currentText()
		enPixelSize = self.ui_sp_en_pixelsize.value()
		enClusterSize = self.ui_sp_en_clustersize.value()
		for obj in mxs.objects:
			if obj.name == (self.ui_cmb_scenenode.currentText()):
   				if enLMName != "":
					mxs.setUserProp(obj, "#EN_LM", enLMName)
				if enBKProfile != "":
					mxs.setUserProp(obj, "#EN_BakeProfile", enBKProfile)
				mxs.setUserProp(obj, "#EN_Type", enType)
				mxs.setUserProp(obj, "#EN_PixelSize", enPixelSize)
				mxs.setUserProp(obj, "#EN_ClusterSize", enClusterSize)

	def ApplyNodeGlobal(self):
		enLMName = self.ui_ln_en_nodelm.text()
		enBKProfile = self.ui_ln_en_nodeprofileen.text()
		enType = self.ui_cmb_lighttype.currentText()
		enPixelSize = self.ui_sp_en_pixelsize.value()
		enClusterSize = self.ui_sp_en_clustersize.value()
		enm.SelectModule()
		for obj in mxs.selection:

			if enLMName != "":
				mxs.setUserProp(obj, "#EN_LM", enLMName)
			if enBKProfile != "":
				mxs.setUserProp(obj, "#EN_BakeProfile", enBKProfile)
			mxs.setUserProp(obj, "#EN_Type", enType)
			mxs.setUserProp(obj, "#EN_PixelSize", enPixelSize)
			mxs.setUserProp(obj, "#EN_ClusterSize", enClusterSize)

	def ApplyMeshSettings(self):

		spChartuvs = self.ui_sp_en_chartuvs.value()
		ckTarget = self.ui_ck_Target.checkState()
		ckVisible = self.ui_ck_Visible.checkState()
		ckAutoScale = self.ui_ck_en_autoscale.checkState()
		ckParametize = self.ui_ck_en_parametize.checkState()
		ckDeferProjection = self.ui_ck_en_deferprojection.checkState()

		oSel = mxs.selection

		ckTarget = checkboxtobool(ckTarget)
		ckVisible = checkboxtobool(ckVisible)
		ckAutoScale = checkboxtobool(ckAutoScale)
		ckParametize = checkboxtobool(ckParametize)
		ckDeferProjection = checkboxtobool(ckDeferProjection)

		mxs.setUserProp(oSel, "#EN_Target", ckTarget)
		mxs.setUserProp(oSel, "#EN_Visible", ckVisible)
		mxs.setUserProp(oSel, "#EN_ChartUvs", spChartuvs)
		mxs.setUserProp(oSel, "#EN_AutoScale", ckAutoScale)
		mxs.setUserProp(oSel, "#EN_Parametize", ckParametize)
		mxs.setUserProp(oSel, "#EN_DeferProjection", ckDeferProjection)


		pass

	def RefreshSceneNode(self):
		self.ui_cmb_scenenode.clear()
		scenenodes = []
		for obj in mxs.objects:
			objname = (obj.name).split('_')
		enm.SelectModule()
		for obj in mxs.selection:
			scenenodes.append(obj)
##			if objname[1] == "module":
##				scenenodes.append(obj)

		enm.SelectNone()
		for itm in scenenodes:
			self.ui_cmb_scenenode.addItem(str(itm.name))
		pass

	def GetScenePath(self):
		if os.path.isdir(str(self.ui_ln_scenepath.text())):
			oPath = (str(self.ui_ln_scenepath.text()))
		else:
			oPath = "C:\\"
		scenedir = QFileDialog.getExistingDirectory(self, 'Browse Scene Directory', oPath)
		self.ui_ln_scenepath.setText( scenedir )




	def ConvertTex(self):
		scenedir = self.ui_ln_scenepath.text()
		bakedir = self.ui_ln_bakepath.text()
		iPath = (scenedir + r"\__Build_GeoMaxExport__\baking\GeoMaxExport")
		oPath = (bakedir)
		ckExportAll = self.ui_ck_en_exportallmaps.checkState()
##		ckExportAll = checkboxtobool(ckExportAll)

		if ckExportAll == 2:
			scenedir = self.ui_ln_scenepath.text()
			bakedir = self.ui_ln_bakepath.text()
			iPath = (scenedir + r"\__Build_GeoMaxExport__\baking\GeoMaxExport")
			oPath = (bakedir)
			for filename in os.listdir(iPath):
				converttotexcmd = ("S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\Bin\\GeoConvert.exe /ConvertTexToExr ")
				tokens = filename.split("_")
				if tokens[0] == "Composite":
					ifilename = filename
					ofilename = filename.split(".")
					ofilename = (ofilename[0]) + ".exr"
					converttotexcmd = converttotexcmd + (iPath + "\\" + ifilename) + " " + (oPath + "\\" + ofilename)
					subprocess.call(str(converttotexcmd))
				if tokens[0] == "Direct":
					ifilename = filename
					ofilename = filename.split(".")
					ofilename = (ofilename[0]) + ".exr"
					converttotexcmd = converttotexcmd + (iPath + "\\" + ifilename) + " " + (oPath + "\\" + ofilename)
					subprocess.call(str(converttotexcmd))
				if tokens[0] == "Indirect":
					ifilename = filename
					ofilename = filename.split(".")
					ofilename = (ofilename[0]) + ".exr"
					converttotexcmd = converttotexcmd + (iPath + "\\" + ifilename) + " " + (oPath + "\\" + ofilename)
					subprocess.call(str(converttotexcmd))
				if tokens[0] == "irradiance":
					shutil.copy(str(iPath) + "\\" + filename, str(oPath))


				#changedir
			iPath = (scenedir + r"\__Build_GeoMaxExport__\baking")
			for filename in os.listdir(iPath):
				if tokens[0] == "AO":
					ifilename = filename
					ofilename = filename.split(".")
					ofilename = (ofilename[0]) + ".exr"
					converttotexcmd = converttotexcmd + (iPath + "\\" + ifilename) + " " + (oPath + "\\" + ofilename)
					subprocess.call(str(converttotexcmd))
			iPath = (scenedir + r"\__Build_GeoMaxExport__\radiosity")
			for filename in os.listdir(iPath):
				tokens = filename.split(".")
				if tokens[1] == "ps" and tokens[2] == "ref":
					glIrName = tokens[0] + ".bsc"
					shutil.copy(str(iPath) + "\\" + filename, str(oPath) + "\\" + glIrName)

		else:
			for filename in os.listdir(iPath):
				converttotexcmd = ("S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\Bin\\GeoConvert.exe /ConvertTexToExr ")
				tokens = filename.split("_")
				if tokens[0] == "Composite":
					ifilename = filename
					ofilename = filename.split(".")
					ofilename = (ofilename[0]) + ".exr"
					converttotexcmd = converttotexcmd + (iPath + "\\" + ifilename) + " " + (oPath + "\\" + ofilename)
					subprocess.call(str(converttotexcmd))
				if tokens[0] == "irradiance":
					shutil.copy(str(iPath) + "\\" + filename, str(oPath))
			iPath = (scenedir + r"\__Build_GeoMaxExport__\radiosity")
			for filename in os.listdir(iPath):
				tokens = filename.split(".")
				if tokens[1] == "ps" and tokens[2] == "ref":
					glIrName = tokens[0] + ".bsc"
					shutil.copy(str(iPath) + "\\" + filename, str(oPath) + "\\" + glIrName)




	def GetBakePath(self):
		if os.path.isdir(str(self.ui_ln_bakepath.text())):
			oPath = (str(self.ui_ln_bakepath.text()))
		else:
			oPath = "C:\\"
		bakedir = QFileDialog.getExistingDirectory(self, 'Browse Bake Directory', oPath)
		self.ui_ln_bakepath.setText( bakedir )


	def PrepareMaxScene(self):
		enm.PrepareDHScene()


	def ExportMaxScene(self):
		scenedir = self.ui_ln_scenepath.text()
		if os.path.isdir(str(scenedir)):
			shutil.copy("S:\\code\\python\\tools\\Projects\\_Dungeon_Hunter\\Enlighten\\GeoMaxExport_default.bp", (str(scenedir)))
			mxs.enlighten.exportscene(str(scenedir))
			WriteMaterials(scenedir)

	def closeEvent( self, event ):
		self.recordSettings()
		super(EnlightenDialog,self).closeEvent( event )

	def recordSettings( self ):
		scenedir = str(self.ui_ln_scenepath.text())
		bakedir = str(self.ui_ln_bakepath.text())
		config.readfp(open(settings))
		config.set("Paths", "scenedir", scenedir)
		config.set("Paths", "bakedir", bakedir)
		with open(settings, 'w') as configfile:
			config.write(configfile)
		pref = prefs.find( 'tools/Enlighten', shared=True )
		pref.recordProperty( 'geom', self.geometry() )


		pref.save()

	def restoreSettings( self ):
		config.readfp(open(settings))
		scenedir = config.get("Paths", "scenedir")
		bakedir = config.get("Paths", "bakedir")
		self.ui_ln_scenepath.setText(scenedir)
		self.ui_ln_bakepath.setText(bakedir)
		pref = prefs.find( 'tools/Enlighten', shared=True )
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )


	def showEvent ( self, event):
		self.restoreSettings()


def __main__(  ):
	dialog = EnlightenDialog(None)

	dialog.show()
	return True
