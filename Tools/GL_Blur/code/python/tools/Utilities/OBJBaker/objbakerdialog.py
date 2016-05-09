##
#   :namespace  objbakerdialog
#
#   :remarks    Bakes selected object then exports the images and the object as OBJ to a specified directory. 
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       04/12/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
from blurdev.gui import Dialog
from Py3dsMax import mxs # import max module
from PyQt4.QtGui import * 
import os
nfy  = mxs.pyhelper.namify

class OBJBakerDialog( Dialog ):
	def __init__( self, parent = None ):
		super(OBJBakerDialog,self).__init__( parent )
		# load the ui
		import blurdev
		blurdev.gui.loadUi( __file__, self )
		
		self.bm = BakeMesh()
		self._connect()
	
	def _connect( self ):
		r'''Do all the connection here from the UI'''
		self.ui_getObjName.clicked.connect( self.SetObjName )
		self.btn_browseProject.clicked.connect (self.SetProjectDir)
		self.btn_bake.clicked.connect ( self.BakeObject )
		
		
		
		
	def BakeObject(self):
		projLoc = self.le_dir.text()
		objName = self.le_objName.text()
		uv = self.sb_uv.value()		
		diff = self.rb_diffuse.isChecked()
		spec = self.rb_specular.isChecked()
		norm = self.rb_normal.isChecked() 
		size = int( self.ui_sizeCB.currentText() )

		
		obj = mxs.getNodeByName ( objName )
		path = ( projLoc + "\\" + objName ) 
		
		if projLoc == '':
			QMessageBox.information(None, "Project Error", "Need to set the destination directory" )
			
		if projLoc != '':
			if os.path.exists(path) != True:
				os.mkdir(path)
				
		if objName == '':
			QMessageBox.information(None, "Object Error", "Need An object to bake" )
			
		obj.INodeBakeProperties.removeAllBakeElements()
		if diff == True:
			self.bm.SetBakeMap(obj, path, "-d", size, uv )
		if diff == True:
			self.bm.SetBakeMap(obj, path, "-s", size, uv )
		if diff == True:
			self.bm.SetBakeMap(obj, path, "-n", size, uv )
			
		mxs.select(obj)
		mxs.render (rendertype=nfy("bakeSelected"),  progressBar=True, outputwidth=size, outputheight=size)
		
		self.bm.exportObj(obj, path )
				
	def SetObjName( self ):
		r'''Set the object name you are working on'''
		sel = mxs.selection
		try:
			name = sel[0].name
			name =name.replace(' ','_')

			self.le_objName.setText( name )
		except:
			pass

	def SetProjectDir(self):
		r''' Browse for the destination of where to export the obj and images '''
		directory = ""
		if (self.le_dir.text() == ""):
			home = os.path.expanduser("~") 
			home = home + "\Documents"
			options = QFileDialog.DontResolveSymlinks | QFileDialog.ShowDirsOnly  
			directory = QFileDialog.getExistingDirectory(self, "", home, options)  
		else:
			directory = self.le_dir.text()
			options = QFileDialog.DontResolveSymlinks | QFileDialog.ShowDirsOnly  
			directory = QFileDialog.getExistingDirectory(self, "", directory, options)  
		self.le_dir.setText ( directory )


		
	def closeEvent( self, event ):
		r"""
			\remarks    [virtual]   overload the close event to handle saving of preferences before shutting down
			\param      event       <QEvent>
		"""
		self.recordSettings()
		super(OBJBakerDialog,self).closeEvent( event )
	
	def recordSettings( self ):
		r"""
			\remarks	records settings to be used for another session
		"""
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/OBJBaker', shared=True )
		
		# record the geometry
		pref.recordProperty( 'geom', self.geometry() )
		
		# record additional settings
#		pref.recordProperty( 'index', self.uiSomeDDL.currentIndex() )
		
		# save the settings
		pref.save()
	
	def restoreSettings( self ):
		r"""
			\remarks    restores settings that were saved by a previous session
		"""
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/OBJBaker', shared=True )
		
		# reload the geometry
		from PyQt4.QtCore import QRect
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )
		
		# restore additional settings
#		self.uiSomeDDL.setCurrentIndex( pref.restoreProperty( 'index', 0 ) )
	
	def showEvent ( self, event):
		r"""
			\remarks    [virtual]   overload the show event to handle loading of preferences when displaying
			\param      event       <QEvent>
		"""
		# restore settings from last session
		self.restoreSettings()
		
class BakeMesh():
	r''' '''
	
	def SetBakeMap(self, obj, path, mapType="-d", size=1024, uv=2 ):

		bakeType = None
		if mapType == "-d":
			bakeType = mxs.DiffuseMap()
			path = path + "\\" + obj.name + "_D.tga"
		if mapType == "-s":
			bakeType = mxs.SpecularMap()
			path = path + "\\" + obj.name + "_S.tga"
		if mapType == "-n":
			bakeType = mxs.NormalsMap()
			path = path + "\\" + obj.name + "_N.tga"
#		print path
		bakeType.outputSzX 	= size
		bakeType.outputSzY 	= size
		bakeType.fileType = str(path)
		bakeType.fileName = mxs.filenameFromPath (bakeType.fileType)

#		bakeType.fileType = path
#		newImage = bakeType.fileType = path

		obj.INodeBakeProperties.addBakeElement( bakeType ) 		obj.INodeBakeProperties.flags = 1
		obj.INodeBakeProperties.bakeChannel = uv
		obj.INodeBakeProperties.nDilations = 6
		
	def exportObj(self, obj, path):
		r'''Exports select object to a given path '''
		#mxs.setCommandPanelTaskMode ( nfy("create") )
		try:
			path = str(path +"\\" + obj.name + ".obj")
			print path
			sh_obj = mxs.snapshot (obj)
			mxs.ChannelInfo.CopyChannel( sh_obj, 3, 2)
			mxs.ChannelInfo.PasteChannel (sh_obj, 3, 1)
			mxs.select(sh_obj)
			mxs.exportFile ( path, nfy("noPrompt"), selectedOnly=True)
			mxs.delete(sh_obj)
			mxs.select(obj)
		except:
			pass
		#mxs.setCommandPanelTaskMode ( nfy("modify") )

	