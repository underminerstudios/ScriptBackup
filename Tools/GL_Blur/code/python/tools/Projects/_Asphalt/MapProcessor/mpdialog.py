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
from PyQt4.QtCore import *
from PyQt4.QtGui import *
#from Py3dsMax import mxs # import max module

import sys
import getopt
import subprocess
from subprocess import Popen
import shutil

def execBat(bat):
    p = Popen(bat, shell=False)
    stdout, stderr = p.communicate()
    os.remove(bat)

class MpDialog(Dialog):


	maxdiff = 50
	maxoutliers = 500
	maxoutlierpercent = 0.10
	default_hires_cap = 4096
	default_medres_scale = 0.5
	default_lores_scale = 0.25
	default_scale = 1.0
	default_mode = 'Texture'


	

	def __init__(self, parent=None):
		super(MpDialog, self).__init__(parent)
		blurdev.gui.loadUi(__file__, self)
		iconfp = os.path.join(os.path.dirname(__file__), 'img', 'icon.png')
		self.setWindowIcon(QIcon(iconfp))
		self.restoreSettings()
		self.setWindowTitle('Map Processor')
		self.connect()
		self.parseScenes()
		self.parseTrackList()

	def connect(self):
#		self.ui_btn_getscenepath.clicked.connect(self.parseScenes)
		self.ui_btn_streamBatchMesh.clicked.connect(self.streamBatchMesh)
		self.ui_btn_calcluatePVS.clicked.connect(self.calculatePVS)
		self.ui_btn_launchGame.clicked.connect(self.launchGame)
		self.ui_btn_clearbakeddata.clicked.connect(self.clearBakedData)
		self.ui_cb_scenes.currentIndexChanged.connect(self.parseTrackList)
#		self.ui_cb_tracklist.currentIndexChanged.connect(self.writeAutoExec)
		self.ui_btn_exportTextures.clicked.connect(self.exportTextures)
	
	def parseScenes(self):
		self.ui_cb_scenes.clear()
		scenes = []
		for r,d,f in os.walk('Z:\\Tracks\\'):
			for files in f:
				if files.endswith(".cfg"):
					scenepath = os.path.join(r,files)
					scenes.append(scenepath)
		for itm in scenes:
			name = itm.rsplit('\\')
			nC = len(name) - 2
			scenename = name[nC]
			self.ui_cb_scenes.addItem(scenename)


	def parseTrackList(self):
		self.ui_cb_tracklist.clear()
		oTrackList = 'S:\\code\\python\\tools\\Projects\\_Asphalt\\MapProcessor\\AsphaltTracks.txt'
		mapTracks = []
		mappath = (str(self.ui_cb_scenes.currentText()))

		trackFile = open(oTrackList, "r")
		for line in trackFile:
			lineInfo = line.rsplit(':')
			if lineInfo[1] == mappath:
				mapline = str(lineInfo[0] + '-' + lineInfo[2])
				mapTracks.append(mapline)
		self.ui_cb_tracklist.addItem('None')
		for track in mapTracks:
			self.ui_cb_tracklist.addItem(QString(track))



	def exportTextures(self):
		mapname = str(self.ui_cb_scenes.currentText())
		sourcepath = 'Z:\\Tracks\\' + mapname  + '\\Textures\\Tga\\'
		trunkpath = 'T:\\data\\Map\\' + mapname + '\\Visual\\Textures\\'
		exportTexCmd = ("python S:\\code\\python\\tools\\Projects\\_Asphalt\\TexConvert\\TexConvert.py " + sourcepath + " " + trunkpath)	
		QProcess.startDetached(exportTexCmd)




	def writeAutoExec(self):
		tracklist = self.ui_cb_tracklist

		autoexec = open('T:\\bin\\autoexec.txt' , 'w')
		autoexec.write('menu.setCar 54\n')
		autoexec.write('menu.setLaps 99\n')
		autoexec.write('menu.setNumAI 0\n')
		autoexec.write('menu.setTraffic 1\n')
		if tracklist.currentText() != 'None':
			mapstring = str(tracklist.currentText())
			trackid = mapstring.rsplit('-')
			autoexec.write('menu.setTrack ' + trackid[0] + '\n')
			autoexec.write('menu.start\n')
			autoexec.close()
		else:
			autoexec.close()
			

	def getScenePath(self):
		if os.path.isdir(str(self.ui_ln_scenepath.text())):
			oPath = (str(self.ui_ln_scenepath.text()))
		else:
			oPath = 'T:\\data\\Map'
		scenedir = QFileDialog.getExistingDirectory(self, 'Browse Scene Directory', oPath)
		self.ui_ln_scenepath.setText(scenedir)

	def launchGame(self):
		self.writeAutoExec()
		if os.path.isfile('T:\\bin\\launchasphalt9.bat'):
			os.startfile('T:\\bin\\launchasphalt9.bat')


	def clearBakedData(self):
		mappath = (str(self.ui_cb_scenes.currentText()))
		if os.path.isfile('T:\\data\\Map\\' + mappath + '\\Visual\\gl_visual.bdae.zip'):
					os.remove('T:\\data\\Map\\' + mappath + '\\Visual\\gl_visual.bdae.zip')
		if os.path.isfile('T:\\data\\Map\\' + mappath + '\\Visual\\gl_road.bdae.zip'):
					os.remove('T:\\data\\Map\\' + mappath + '\\Visual\\gl_road.bdae.zip')
		if os.path.isfile('T:\\data\\Map\\' + mappath + '\\Visual\\Occlusion.pvs.bin'):
					os.remove('T:\\data\\Map\\' + mappath + '\\Visual\\Occlusion.pvs.bin')
		if os.path.isfile('T:\\bin\\autoexec.txt'):
			os.remove('T:\\bin\\autoexec.txt')

	def streamBatchMesh(self):

		ckVisual = self.ui_ck_doVisual.checkState()
		ckRoad = self.ui_ck_doRoad.checkState()
		ckDeletePVS = self.ui_ck_deletePVS.checkState()
		mappath = (str(self.ui_cb_scenes.currentText()))

#		mname = (str(self.ui_ln_scenepath.text()))
#		mname = mname[12:]

		execpath = ''
		if os.path.isfile('T:\\bin\\Asphalt9_2012_Release.exe'):
			execpath = ('Asphalt9_2012_Release.exe')
		projectpath = (r'cd T:\bin')

		batcmd = ''
		if execpath != '':
			if ckVisual == 2:
				mtype = 'Visual'
				if os.path.isfile('T:\\data\\Map\\' + mappath + '\\Visual\\gl_visual.bdae.zip'):
					os.remove('T:\\data\\Map\\' + mappath + '\\Visual\\gl_visual.bdae.zip')
				batcmd = (execpath + ' --build-batch --input Map/' + mappath + '/Visual/Zones --output Map/' + mappath + '/Visual/GL_Visual.bdae.zip --width 128 --length 128')
				with open('T:\\bin\\batch.bat' , 'a+') as f:
					f.write('cd /d %~dp0 \n')
					f.write(batcmd)
				f.close()
				self.uiLog.setText(batcmd)
				execBat('T:\\bin\\batch.bat')
			if ckRoad == 2:
				mtype = 'Road'
				if os.path.isfile('T:\\data\\Map\\' + mappath + '\\Visual\\gl_road.bdae.zip'):
					os.remove('T:\\data\\Map\\' + mappath + '\\Visual\\gl_road.bdae.zip')
				batcmd = (execpath + ' --build-batch --input Map/' + mappath + '/Visual/Road --output Map/' + mappath + '/Visual/GL_Road.bdae.zip --width 128 --length 128')
				with open('T:\\bin\\batch.bat' , 'a+') as f:
					f.write('cd /d %~dp0 \n')
					f.write(batcmd)
				f.close()
				self.uiLog.setText(batcmd)
				execBat('T:\\bin\\batch.bat')
			if ckDeletePVS == 2:
				if os.path.isfile('T:\\data\\Map\\' + mappath + '\\Visual\\Occlusion.pvs.bin'):
					os.remove('T:\\data\\Map\\' + mappath + '\\Visual\\Occlusion.pvs.bin')

	def calculatePVS(self):

		mappath = (str(self.ui_cb_scenes.currentText()))
#		mname = (str(self.ui_ln_scenepath.text()))
#		mname = mname[12:]
		execPath = ''
		mapPath = 'T:\\data\\Map\\' + mappath + '\\Visual\\'
		projectPath = 'T:\\libraries\\glitch\\tools\\PVS\\bin\\PVSEditor\\'
		pvsConfigFile = 'T:\\data\\Map\\' + mappath + '\\Visual\\PVS_config.pvs.xml'
		if os.path.isfile('T:\\libraries\\glitch\\tools\\PVS\\bin\\PVSEditor\\PVSEditor.exe'):
		   execPath = ('PVSEditor.exe')
		batcmd = ''
		if execPath != '':
			if os.path.isfile(pvsConfigFile):
				batcmd = (execPath + ' -i ' + pvsConfigFile + ' -o T:\\data\\Map\\' + mappath + '\\Visual\\Occlusion.pvs.bin')
				batchfile = projectPath + 'batch.bat'
				with open((batchfile), 'a+') as f:
					f.write('cd /d %~dp0 \n')
					f.write(batcmd)
				f.close()
				self.uiLog.setText('Starting PVS Calculation')
				execBat(batchfile)
				self.uiLog.setText(str('PVS Written to: T:\\data\\Map\\' + mappath + '\\Visual\\Occlusion.pvs.bin'))


	def closeEvent(self, event):
		self.recordSettings()
		super(MpDialog, self).closeEvent(event)

	def recordSettings(self):
		pass

	def restoreSettings(self):
		pass
