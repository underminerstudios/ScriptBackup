##
#   :namespace  lightmapbakerdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       06/03/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
from blurdev.gui import Dialog
from blurdev import prefs
from Py3dsMax import mxs # import max module
from PyQt4.QtGui import QColor, QDialog
from PyQt4.QtCore import QCoreApplication,Qt
#from PyQt4.QtGui import QDialog,QListWidget,QVBoxLayout,QHBoxLayout,QToolButton,QPushButton,QSplitter,QFileDialog,QMessageBox
  
#from PyQt4.QtCore import QRect
import PyQt4, os, blurdev



atfFile =  mxs.maxFilePath + mxs.maxFileName[0:-3] + 'atf'

class AddDialog( Dialog ):
	def __init__( self, parent):
		super(AddDialog,self).__init__( parent )

		# load the ui
		PyQt4.uic.loadUi( os.path.split( __file__ )[0] + '\\ui\\adddialog.ui', self )
		
		self.connect()
		self.returnData = None
		
	def connect (self):
		'''Connect the widgets from the ui'''
		self.ui_btn_setTag.clicked.connect(self.setTag)
		self.ui_btn_cancel.clicked.connect(self.closeSettingDialog)
	
	def getValues(self):
		return self.returnData
	#Save settings 	
	def setTag(self):
		
		'''Set the tag'''
		tagDict 	= {'name': None,'start': None, 'end': None, 'color0': None , 'color1': None }
		tagName 	=  str(self.ui_le_tagName.text())
		tagStart	= self.ui_sb_start.value()
		tagEnd 		= self.ui_sb_end.value()
		tagColorStart 	= self.ui_btn_colorStart.currentText()
		tagColorEnd		= self.ui_btn_colorEnd.currentText()
		good2go 	= -1
		color0 = None
		color1 = None
		if tagName != '' and tagStart < tagEnd and tagStart != tagEnd:
			tagDict ['name'] 	= tagName
			tagDict['start'] 	= tagStart
			tagDict['end'] 		= tagEnd
			good2go = 1

		if tagColorStart == "Color Start":
			tagDict['color0'] = None
		elif tagColorStart == "Red":
			color0 = QColor(255, 100, 100)
		elif tagColorStart == "Blue":
			color0 = QColor(0, 170, 255)
		elif tagColorStart == "Green":
			color0 = QColor(70, 190, 70)
		elif tagColorStart == "Orange":
			color0 = QColor(200, 150, 70)
		elif tagColorStart == "Yellow":
			color0 = QColor(253, 242, 120)
		
		if tagColorEnd == "Color End":
			tagDict['color1'] = None
		elif tagColorEnd == "Red":
			color1 = QColor(255, 100, 100)
		elif tagColorEnd == "Blue":
			color1 = QColor(0, 170, 255)
		elif tagColorEnd == "Green":
			color1 = QColor(70, 190, 70)
		elif tagColorEnd == "Orange":
			color1 = QColor(200, 150, 70)
		elif tagColorEnd == "Yellow":
			color1 = QColor(253, 242, 120)
			
		if good2go == 1:
			self.returnData =  [tagName, tagStart, tagEnd, color0, color1]

#			file = None
#			if os.path.isfile(atfFile) != True:
#				file = open(atfFile, 'w')
#				file.write(str(tagDict)+'\n')
#			elif os.path.isfile(atfFile):
#				file = open(atfFile, 'a')
#				file.write(str(tagDict)+'\n')
#			file.close
			
		self.closeSettingDialog()
		
	def closeSettingDialog(self):
		lmbDialog = AddDialog(self)
		lmbDialog.recordSettings()
		self.close()
		
	def closeEvent( self, event ):
		self.recordSettings()
		super(AddDialog,self).closeEvent( event )
		
	def recordSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/AddDialog', shared=True )	
		pref.save()

	def restoreSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/AddDialog', shared=True )

	def showEvent ( self, event):
		# restore settings from last session
		self.restoreSettings()
		 
	def keyPressEvent(self, event):
		if event.modifiers() == Qt.ControlModifier and event.key() == Qt.Key_Escape:
			self.reject()
#		if event.modifiers() == Qt.ControlModifier and event.key() == Qt.Key_Return:
#			print "Retrun pressed"
			
		QDialog.keyPressEvent(self, event)	
	
		
def __main__():
	dialog = AddDialog(None)
	dialog.show()
	return True
#__main__()
#atfFile =  mxs.maxFilePath + mxs.maxFileName[0:-3] + 'atf'


#file = open(atfFile, 'a')
#file.write('')
#file.close()
#open(atfFile, "rw")
#if os.path.isfile(atfFile) != True:
#	file = open(atfFile, 'rw')
	
	
#getAnimTagsData( aftFile )