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

from PyQt4.QtCore import QRect
from blurdev.gui import Dialog
from blurdev import prefs
from Py3dsMax import mxs # import max module

from  glmax.max3d import GLMax
glm = GLMax()

from UI.loaduistyle import LoadStyle
ui = LoadStyle()


class LMTaggerDialog( Dialog ):
	def __init__( self, parent = None ):
		super(LMTaggerDialog,self).__init__( parent )
		# load the ui
		blurdev.gui.loadUi( __file__, self )
		self.setStyleSheet(ui.getZStyleSheet())
		self.mainWireColor = mxs.color(20, 20, 200)
		self.alphaWireColor = mxs.color(255, 175, 5)
		self.decalWireColor = mxs.color( 200, 0, 100)
		self.tempWireColor = mxs.color(25, 175, 25)
		self.occWireColor = mxs.color(128, 128, 128)

		self.connect()

	def connect(self):
		self.ui_btn_tag.clicked.connect(self.TagSelected)
		self.ui_btn_clear.clicked.connect(self.ClearTags)
		self.ui_btn_select.clicked.connect(self.SelectByTag)
		
	
	def SelectByTag(self):
		'''Selects what ever tag that is in the drop down'''
		type = self.ui_cmb_tagList.currentText()
		ll = []
		for obj in mxs.objects:
			objTag = mxs.getUserProp (obj, 'lightmap')
			if objTag == type:
				ll.append(obj)
		
		mxs.select(ll)
		mxs.completeRedraw()
		
	def SetOccluder(self, _node):
		'''Works on occluder objects'''
		#TODO: find a occluder vray material
		bakeLayer = glm.setLayer('BakeMesh')
		bakeLayer.addnode ( _node )
		newString = self.PrefixAdd(_node.name)
		_node.wirecolor = self.occWireColor
		if newString != None:
			_node.name = newString

		
	def ClearTags (self):
		'''Clears User properties on selected object'''
		oSel = mxs.selection
		type = self.ui_cmb_tagList.currentText()
		
		for obj in oSel:
			self.randomColor = mxs.color(random.randint(0,255), random.randint(0,255),random.randint(0,255))
			if type == 'Occluder':
				newName = self.PrefixRemove(obj.name)
				if newName != None:
					obj.name = newName
					
				refLayer = glm.setLayer ('ref',  False)
				refLayer.AddNode(obj)
				obj.wirecolor = self.randomColor
				
			else:
				mxs.setUserPropBuffer(obj, '')

				obj.wirecolor = self.randomColor
		mxs.completeRedraw()
			
	def TagSelected (self):
		'''Tags selected objects with tags from the ComboBox'''
		oSel = mxs.selection
		type = self.ui_cmb_tagList.currentText()
		
		for obj in oSel:
			
			if type == 'Occluder':
				self.SetOccluder(obj)
			
			else:
				glm.setUserDefinedProps ( obj, 'lightmap', str(type) )
				if type == 'LM1':
					obj.wirecolor = self.mainWireColor
				if type == 'LM2':
					obj.wirecolor = self.alphaWireColor
				if type == 'LM3':
					obj.wirecolor = self.decalWireColor
				if type == 'LM4':
					obj.wirecolor = self.tempWireColor
		mxs.completeRedraw()

	def PrefixAdd(self, _string):
		''''''
		newName = None
		if _string[0:3].lower() != 'occ':
			newName = 'occ_' + _string
			
		return newName			

	def PrefixRemove(self, _string):
		''''''
		newName = None
		if _string[0:3].lower() == 'occ':
			if _string[3] != '_':
				newName = _string[3:len(_string)]
			else:
				newName = _string[4:len(_string)]
		return newName			
			
	def closeEvent( self, event ):

		self.recordSettings()
		super(LMTaggerDialog,self).closeEvent( event )
	
	def recordSettings( self ):

		pref = prefs.find( 'tools/LMTagger', shared=True )
		
		pref.recordProperty( 'geom', self.geometry() )
		pref.recordProperty( 'ui_cmb_tagList', self.ui_cmb_tagList.currentIndex() )
		
		pref.save()
	
	def restoreSettings( self ):
		
		pref = prefs.find( 'tools/LMTagger', shared=True )
		
		cur_index = pref.restoreProperty( 'ui_cmb_tagList')
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )
		
		if cur_index != None:
			self.ui_cmb_tagList.setCurrentIndex(cur_index)

	
	def showEvent ( self, event):
		self.restoreSettings()


def __main__(  ):
	dialog = LMTaggerDialog(None)
	
	dialog.show()
	return True
#__main__()

#
#	
#	
#selected = mxs.selection
#
#PrefixRemove(selected[0].name)