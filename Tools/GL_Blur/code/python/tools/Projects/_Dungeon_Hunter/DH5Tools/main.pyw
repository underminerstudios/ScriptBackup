##
#   :namespace  dh5toolsdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       06/19/13
#
from PyQt4.QtGui import QApplication
from PyQt4.QtCore import QObject


# make sure this is being run as the main process
if ( __name__ in ( '__main__', '__builtin__' ) ):
	# since this file is being executed in the main scope, we need to register the tool package to the sys.path
	import blurdev
	blurdev.registerScriptPath( __file__ )

	def getWindow(QObjectName):
	#	widgets = QApplication.topLevelWidgets()
		widgets = QApplication.instance().topLevelWidgets()
		for item in widgets:
			if item.objectName() == QObjectName:
				return item
				break
				
	taggerDialog = getWindow('dh5_tools')
	if taggerDialog != None:
		QApplication.setActiveWindow(taggerDialog)
	if taggerDialog == None:
		from DH5Tools.dh5toolsdialog import DH5ToolsDialog
		blurdev.launch( DH5ToolsDialog )	
		

#	# depending on our environment, Python initializes the script differently for scope, so try both methods:
#	# importing from a sub-module
#	try:
#		from dh5toolsdialog import DH5ToolsDialog
#	
#	# importing from the main package
#	except:
#		from DH5Tools.dh5toolsdialog import DH5ToolsDialog
#
#	blurdev.launch( DH5ToolsDialog )