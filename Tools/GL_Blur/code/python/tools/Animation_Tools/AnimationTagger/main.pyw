##
#   :namespace  animationtaggerdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       08/13/13
#
from PyQt4.QtGui import QApplication
from PyQt4.QtCore import QObject

# make sure this is being run as the main process
if ( __name__ in ( '__main__', '__builtin__' ) ):
	# since this file is being executed in the main scope, we need to register the tool package to the sys.path
	import blurdev
	blurdev.registerScriptPath( __file__ )
	
	def getWindowObject (widgetName):
	#	widgets = QApplication.topLevelWidgets()
		widgets = QApplication.instance().topLevelWidgets()
		for item in widgets:
			if item.objectName() == widgetName:
				return item
				break
				
	taggerDialog = getWindowObject('animation_tagger')
	if taggerDialog != None:
		QApplication.setActiveWindow(taggerDialog)
	if taggerDialog == None:
		from AnimationTagger.animationtaggerdialog import AnimationTaggerDialog
		blurdev.launch( AnimationTaggerDialog )	
#from AnimationTagger.animationtaggerdialog import AnimationTaggerDialog
#blurdev.launch( AnimationTaggerDialog )	