##
#   :namespace  assetmanagerdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       09/13/13
#

# make sure this is being run as the main process
numpyExists  = False
openGLExists = False
pygameExists = False
libPath = r'S:\code\common\python_libs_26_64'
try:
	import numpy # Import Numpy
	numpyExists = True
except ImportError:
	print "Please Install \"numpy-MKL-1.7.1.win-amd64-py2.6.exe\" from " + libPath
try:
	import OpenGL # Import OpenGL
	openGLExists = True

except ImportError:
	print "Please Install \"PyOpenGL-3.0.2.win-amd64-py2.6.exe\" from " + libPath
try:
	import pygame # Import PyGame
	pygameExists = True
except ImportError:
	print "Please Install \"pygame-1.9.2pre.win-amd64-py2.6.exe\" from " + libPath


if numpyExists == False or openGLExists == False or pygameExists == False:
	import ctypes
	message = 'Then necessary libs aren\'t loaded. You need to install the following libs\n\n\
numpy-MKL-1.7.1.win-amd64-py2.6.exe\n\
PyOpenGL-3.0.2.win-amd64-py2.6.exe\n\
pygame-1.9.2pre.win-amd64-py2.6.exe\n\n\
located at ' + libPath

	MessageBox = ctypes.windll.user32.MessageBoxA
	MessageBox(None, message, 'MISSING LIBS', 0)
	

if numpyExists == True and openGLExists == True and pygameExists == True:
	
	if ( __name__ in ( '__main__', '__builtin__' ) ):
		import blurdev
		from PyQt4.QtGui import QApplication
		from PyQt4.QtCore import QObject
		
		def getWindow(QObjectName):
		#	widgets = QApplication.topLevelWidgets()
			widgets = QApplication.instance().topLevelWidgets()
			for item in widgets:
				if item.objectName() == QObjectName:
					return item
					break
					
#		taggerDialog = getWindow('asset_manager_ui')
#		if taggerDialog != None:
#			QApplication.setActiveWindow(taggerDialog)
#		if taggerDialog == None:
#			
#			from AssetManager.assetmanagerdialog import AssetManagerDialog
#			
#			blurdev.launch( AssetManagerDialog )	
			
from AssetManager.assetmanagerdialog import AssetManagerDialog
blurdev.launch( AssetManagerDialog )

		# since this file is being executed in the main scope, we need to register the tool package to the sys.path
#		import blurdev
#		blurdev.registerScriptPath( __file__ )
#		
#		# depending on our environment, Python initializes the script differently for scope, so try both methods:
#		# importing from a sub-module
#		try:
#			from assetmanagerdialog import AssetManagerDialog
#		
#		# importing from the main package
#		except:
#			from AssetManager.assetmanagerdialog import AssetManagerDialog
#		
#		blurdev.launch( AssetManagerDialog )