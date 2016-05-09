from blurdev.gui import Dialog
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import os, re, sys
import PyQt4.uic # Loader file for ui parsing

from Py3dsMax import mxs # import max module
from  glmax.max3d import GLMax
from  glmax.glitchmax import GlitchMax
import LevelGrunt.HogFileManager as hfm

nfy  = mxs.pyhelper.namify
glm = GLMax()
glch = GlitchMax()
hfm = hfm.HogFileManager()


# TODO: add a UV save module
# TODO: add a save Vertex Color module
# TODO: adde Morph save module
# TODO: Select objects in Max Layer list view
# TODO: Add Make library module
# TODO:

class HogRightClickMenu ( QMenu ):
	def __init__( self, parent, item ):#
		QMenu.__init__( self, parent )
		#self.addAction( 'Create Group...' ).triggered.connect()
		self.addAction( 'Rename' )
		self.addSeparator()
		self.addAction("Load as Reference");

class LevelHog( Dialog ):

	def __init__( self ):
		Dialog.__init__( self )

		# Load a ui file named 'TestDialog.ui' from the same folder as this script

		#Tool UI
		PyQt4.uic.loadUi( os.path.split( __file__ )[0] + '\\ui\\levelgruntdialog.ui', self )

		self.tool_img_path = os.path.split( __file__ )[0] + '/img/'
		self.open_ico = QIcon(self.tool_img_path + 'box_open.png')
		self.closed_ico = QIcon(self.tool_img_path + 'box_closed.png')
		self.layer_ico = QIcon(self.tool_img_path + 'layers.png')
		self.xrefclosed_ico = QIcon(self.tool_img_path + 'brick.png')
		self.xrefedit_ico = QIcon(self.tool_img_path + 'brick_edit.png')

		self.data = self.GetCustomFileProps()
#		print len(self.data)
#		print self.data[1]
#		self.gl_project_path = self.ui_ProjectPath.text()
#
		data = self.GetCustomFileProps()
		self.gl_level_path = data[0]
		self.gl_hog_file   = data[1]
		self.pID = self.SetProject()

		 #sets the correct project of dropdown box in the hog configuration
		self._connect() # Connect the signals/slots

		file_test = ( os.path.isfile ( self.data[1] ) )

		if file_test != False:
			self.AutoLoad( data )
			self.RefreshTree ()
			self.PopulateMaxLayerLV ()

	def _connect( self ):

		#HOG LOADING TAB
		self.connect( self.BTN_Refresh, SIGNAL( 'clicked()' ), self.RefreshTree ) # custom method
		self.hogfile = self.connect( self.BTN_Load, SIGNAL( 'clicked()' ), self.BrowseForHog ) # custom method
		self.connect( self.ui_SaveHogTreeNodes, SIGNAL( 'clicked()' ), self.SaveHogNodesTV ) # custom method
		self.connect( self.ui_UnloadHogTreeNodes, SIGNAL( 'clicked()' ), self.UnloadHogNodesTV ) # custom method
		self.connect( self.ui_LoadHogNodes, SIGNAL( 'clicked()' ), self.LoadSelectedHogTV ) # custom method
		self.connect( self.ui_HogTree, SIGNAL( 'itemClicked(QTreeWidgetItem*,int)' ), self.ItemsClicked ) # custom method

		#HOG CONFIGURATION TAB
		self.ui_ConformScene.clicked.connect( self.ConformScene )
		self.ui_SaveAllMaxLayersBTN.clicked.connect ( self.SaveAllMaxLayers )
		self.ui_WriteHogFileBTN.clicked.connect(  self.SaveHogFile )
		self.ui_RefreshMaxLayersBTN.clicked.connect( self.PopulateMaxLayerLV )

		#HOG X-REF TAB
		self.ui_MakeXrefBTN.clicked.connect ( self.MakeXrefClicked )

	def MakeXrefClicked (self ):
		print self.gl_level_path
		hfm.MakeLibrary ( self.gl_level_path )

	def ItemsClicked ( self ):
		#mxs.clearselection()
		#sel_items = self.ui_HogTree.selectedItems()
		#for itm in sel_items:
		#self.SelectLayerObject( itm )
		mxs.RedrawViews()

	def SelectLayerObject (self, item ):
		r'''Select of the layer for visual feedback'''
		_zone = item.text(0)
		nodes = []
		layer = mxs.ILayerManager.getLayerObject ( _zone )
		if layer != None:
			layerRT = layer.layerAsRefTarg
			layer_deps = mxs.refs.dependents ( layerRT )
			for itm in layer_deps:
				type = str( mxs.superclassof( itm ) )
				if type == "GeometryClass":
					nodes.append(itm)
		mxs.selectmore (nodes)

	def SaveHogFile(self):
		hfm.SaveHogFile( self.gl_hog_file , self.pID)

	def SetProject (self):

		projectID = None
		if os.path.isfile( self.gl_hog_file ) != False:
			with open(self.gl_hog_file) as hogfile:
				data = hogfile.readlines(0)
				projectID = int( (data[0].split('=') )[1] )
			hogfile.close()

			self.ui_ProjectCB.setCurrentIndex( projectID )
			return projectID

	def UnloadHogNodesTV ( self ):
		r''' Deletes Nodes of a selected layer'''
		mxs.setCommandPanelTaskMode ( nfy("create") )
		unload_layers = []

		for tt in self.ui_HogTree.selectedItems():
			layer_name = tt.text(0)
			if layer_name == "XreHfs":
				layer = (tt.parent()).text(0)
				layer += "_Xrefs"
				tt.setIcon (0, self.xrefclosed_ico )
				unload_layers.append(layer)
			else:
				tt.setIcon (0, self.closed_ico )
				unload_layers.append(layer_name)

		for lyr in unload_layers:
			test = str(lyr).find("_Xrefs")
			if test != -1:
				tokens = lyr.split("_")
				_sector = tokens[0] + "_" + tokens[1]
				layer = mxs.ILayerManager.getLayerObject ( _sector )
				if layer != None:
					layerRT = layer.layerAsRefTarg
					layer_deps = mxs.refs.dependents (layerRT)

					#gather some information about the current layers
					if layer_deps > 3:
						del_obj = []
						for itm in layer_deps:
							if str(mxs.superclassof(itm)) == "GeometryClass" or str(mxs.superclassof(itm)) == "shape" or str(mxs.superclassof(itm)) == "light":
								if (itm.name).find('{xrf}') != -1:
									del_obj.append (itm)
						mxs.delete ( del_obj )

			else:
				layer = mxs.ILayerManager.getLayerObject ( lyr )
				if layer != None:
					layerRT = layer.layerAsRefTarg
					layer_deps = mxs.refs.dependents (layerRT)

					#gather some information about the current layers
					if layer_deps > 3:
						del_obj = []
						for itm in layer_deps:
							if str(mxs.superclassof(itm)) == "GeometryClass" or str(mxs.superclassof(itm)) == "shape" or str(mxs.superclassof(itm)) == "light":
								if (itm.name).find('{xrf}') == -1:
									del_obj.append (itm)
						mxs.delete ( del_obj )
					else:
						pass

		self.PopulateMaxLayerLV()
		glm.deleteEmptyLayers()
		mxs.redrawViews()
		mxs.setCommandPanelTaskMode ( nfy("modify") )

	def ConformScene ( self ):
		current_project = self.ui_ProjectCB.currentText()

		if current_project == "Modern Combat":
			glch.ConformSceneMC ()
		if current_project == "Asphalt":
			glch.ConformSceneAsphalt()
		if current_project == "Dungeon Hunter":
			print "Not implemented"

	def LoadSelectedHogTV ( self ):
		r'''Loads selected hog tree items in to the scene container file.'''
		mxs.setCommandPanelTaskMode ( nfy("create") )
		glm.setLayer ( "0" )
		for lyr in self.ui_HogTree.selectedItems():
			layer_name =  (lyr.text(0) )

			if layer_name == "Xrefs":
				_sector = (lyr.parent()).text(0)
				hfm.LoadXrefs ( self.gl_hog_file, _sector )
				lyr.setIcon (0, self.xrefedit_ico )
			else:
				selected_ly = self.gl_level_path  + "level_layers/" + layer_name + ".max"
				file_test = os.path.isfile (selected_ly)
				if file_test == 0:
					none_existent.append(str(selected_ly))
				else:
					self.deleteLayerObjects ( layer_name )
					mxs.mergemaxfile( str(selected_ly),\
										nfy( "select" ),\
										nfy( "mergeDups" ),\
										nfy( "useSceneMtlDups" ),\
										nfy( "alwaysReparent" ) )

					#find reparent xref nodes to the newly loaded zone.
					_layer = mxs.ILayerManager.getLayerObject ( layer_name )
					if _layer != None:
						_layer.ishidden = False
						layerRT = _layer.layerAsRefTarg
						layer_deps = mxs.refs.dependents ( layerRT )
						lyr.setIcon(0, self.open_ico)

						_zone = mxs.getnodebyname (layer_name)
						if _zone != None:
							glm.moveChildrenToParentsLayer( _zone )
							for itm in layer_deps:
								if str(mxs.superclassof(itm)) == "GeometryClass" and (itm.name).find('{xrf}') != -1:
										itm.parent = _zone
	  					self.PopulateMaxLayerLV()
					else:
						QMessageBox.information(self, "Error","Max File is missing for Layer" )

		mxs.setCommandPanelTaskMode ( nfy("modify") )


	def IsXref (self, _node ):
		r'''Returns True or Fasle is the node is xref'''
		xrf = None
		if _node != None:
			if (_node.name).find('{xrf}') != -1:
				xrf = True
			if (_node.name).find('{xrf}') == -1:
				xrf = False
		return xrf

	def deleteLayerObjects (self, _zone):
		r'''Delete all objects in the given zone string '''
		layer = mxs.ILayerManager.getLayerObject ( _zone )
		if layer != None:
			layerRT = layer.layerAsRefTarg
			layer_deps = mxs.refs.dependents ( layerRT )
			for itm in layer_deps:

				type = str(mxs.superclassof( itm ))
				if type == "GeometryClass" or type == "shape" or type == "light":
					is_xref = self.IsXref( itm )
					if is_xref == False:
						mxs.delete( itm )

	def DeleteLayerXrefs (self, _zone):
		r'''Delete all xrefs in the given zone string '''
		layer = mxs.ILayerManager.getLayerObject ( _zone )
		if layer != None:
			layerRT = layer.layerAsRefTarg
			layer_deps = mxs.refs.dependents (layerRT)
			for itm in layer_deps:
				type = str(mxs.superclassof(itm))
				is_xref = self.IsXref(itm)
				if type == "GeometryClass" and is_xref == False:
					mxs.delete(itm)

	def RefreshHogTree( self, _path ):

		list_data = hfm.GetHogData( _path )

		for itm in list_data:
			itm = (itm.split("=") )[0]
			lyr_test = mxs.ILayerManager.getLayerObject ( itm )

			if itm != "project":

				par = QTreeWidgetItem( self.ui_HogTree  )
				par.setText (0, QString( itm ) )
	   			if str(lyr_test) == 'ReferenceTarget:BaseLayer':
	   				par.setIcon (0, self.open_ico)
	   			else:
	   				par.setIcon (0, self.closed_ico)

	   			tokens = itm.split("_")
	   			if tokens[0] == "room" or tokens[0] == "multi":
	   				child = QTreeWidgetItem( par )
	   				child.setText (0, QString( "Xrefs" ) )
	   				if str(lyr_test) == 'ReferenceTarget:BaseLayer':
	   					child.setIcon (0, self.xrefclosed_ico)
	   				else:
	   					child.setIcon (0, self.xrefedit_ico )

	def RefreshTree ( self ):
		self.ui_HogTree.clear()
		self.RefreshHogTree( self.gl_hog_file )

	def AutoLoad ( self, _list):
		hog_file = _list[1]
		if os.path.isfile( hog_file ) != False:
			self.ui_HogPath.setText(hog_file)
			self.RefreshTree ( )

	def GetCustomFileProps ( self ):
		_info = []
		current_path = mxs.maxFilePath

		if len(current_path) != 0:
			current_path = current_path.replace('\\', '/')
			current_scene = ( current_path.split("/") )[-2]
			hog_path = current_path + current_scene + ".hog"
			_info.append( current_path )
			_info.append( hog_path )
		return _info

	def ShowMenu( self ):
		item = self.ui_HogTree.selectedItems()
		if len( item ) > 0:
			HogRightClickMenu(self, item[0]).popup(QCursor.pos())
		else:
			HogRightClickMenu(self, "").popup(QCursor.pos())

	def UpdateHogData ( self, _list, _string ):
		list_check = _string in _list
		if list_check == False:
			_list.append( _string )
			return _list

	def BrowseForHog(self):
		print ("Browsing for hog file")
		fileName = QFileDialog
		print mxs.maxFilePath
		if len( mxs.maxFilePath ) == 0:
			if os.path.exists(self.gl_project_path) == True:
				fileName = QFileDialog.getOpenFileName (self, 'Load a *.hog file', "C:/", 'Hog (*.hog)')
		else:
			fileName = QFileDialog.getOpenFileName (self,\
									'Load a *.hog file',\
									self.gl_level_path,\
									'Hog (*.hog)')

		self.ui_HogPath.setText( fileName )
		self.RefreshTree()
		self.gl_hog_file = fileName
		return fileName



	def SaveHogNodesTV( self ):
		mxs.setCommandPanelTaskMode ( nfy("create") )
		save_layers = []
		glm.setLayer( "0" )

		for tt in self.ui_HogTree.selectedItems():
			layer_name = tt.text(0)
			if layer_name == "Xrefs":
				layer = (tt.parent()).text(0)
				layer += "_Xrefs"
#				tt.setIcon (0, self.xrefclosed_ico )
				save_layers.append(layer)
			else:
#				tt.setIcon (0, self.closed_ico )
				save_layers.append(layer_name)

		for lyr in save_layers:
			test = str(lyr).find("_Xrefs")
			if test != -1:
				tokens = lyr.split("_")
				_sector = tokens[0] + "_" + tokens[1]
				hfm.WriteOutXrefs( self.gl_hog_file, _sector )

			else:
				save_layer_path = ( self.gl_level_path  + "level_layers/" + lyr + ".max" )
				layer = mxs.ILayerManager.getLayerObject ( lyr )
				if layer != None:
					layerRT = layer.layerAsRefTarg
					layer_deps = mxs.refs.dependents (layerRT)

					#gather some information about the current layers
					if layer_deps > 3:
						save_nodes = []
						reparent_nodes = []
						for itm in layer_deps:


							#Filter out none xref nodes
							if str(mxs.superclassof(itm)) == "GeometryClass" and (itm.name).find('{xrf}') == -1:
									save_nodes.append (itm)
							if str(mxs.superclassof(itm)) == "shape" and (itm.name).find('{xrf}') == -1:
									save_nodes.append (itm)
							if str(mxs.superclassof(itm)) == "light" and (itm.name).find('{xrf}') == -1:
									save_nodes.append (itm)


							#get xref nodes
							if str(mxs.superclassof(itm)) == "GeometryClass" and (itm.name).find('{xrf}') != -1:
									dict = {'node':itm,'parent':itm.parent}
									itm.parent = None
									reparent_nodes.append(dict)
						#save static zone node


						mxs.saveNodes( save_nodes, str( save_layer_path ) )

						#reparent xref nodes
						for itm in reparent_nodes:
							_node = itm['node']
							_parent = itm['parent']
							_node.parent = _parent

		self.PopulateMaxLayerLV()
		mxs.redrawViews()
		mxs.setCommandPanelTaskMode ( nfy("modify") )

	def SaveAllMaxLayers ( self ):
		r'''Saves all the layers into a separate max files into level_layers directory'''
		mxs.Suspendediting ()

		current_project = self.ui_ProjectCB.currentText()
		#conform scene based ont the dropdown selection
		if current_project == "Modern Combat":
			glch.ConformSceneMC ()
		if current_project == "Asphalt":
			glch.ConformSceneAsphalt()
		if current_project == "Dungeon Hunter":
			print "Not implemented"

		_path = mxs.maxFilePath

		if _path == '':
			QMessageBox.information(self, "Error Empty Scene","You need to open a Max Container file" )
		else:
			level_layer_dir = _path + "level_layers/"
			if not os.path.exists( level_layer_dir ):
				os.mkdir( level_layer_dir )

			scene_layers = mxs.LayerManager
			for lyr in range( scene_layers.count ):
				export_nodes = []
				reparent_nodes = []

				layer = mxs.LayerManager.getLayer(lyr)
				max_layer_file = level_layer_dir + layer.name + ".max"

				layerRT = layer.layerAsRefTarg
				layer_deps = mxs.refs.dependents ( layerRT )

				if layer.name != "0":
					for dep in layer_deps:
						_node = str( mxs.superclassof ( dep ) )
						#Filter out the xref nodes
						if _node == "GeometryClass" or _node == "light" or\
							_node == "helper" or _node == "shape":
							if (dep.name).find('{xrf}') == -1:
								export_nodes.append( dep )

							#get xref nodes and put them in a dictionary
							if str(mxs.superclassof(dep)) == "GeometryClass" and\
													(dep.name).find('{xrf}') != -1:

									dict = {'node':dep,'parent':dep.parent}
									dep.parent = None
									reparent_nodes.append(dict)


				mxs.saveNodes( export_nodes, max_layer_file )

				#reparent xref nodes
				for itm in reparent_nodes:
					_node = itm['node']
					_parent = itm['parent']
					_node.parent = _parent
				print "save hog file "
				self.SaveHogFile()


		self.PopulateMaxLayerLV()
		mxs.Resumeediting ()

	def PopulateMaxLayerLV ( self ):
		self.ui_MaxLayers.clear()
		scene_layers = mxs.LayerManager
		layers = []
		for lyr in range( scene_layers.count ):
			layer = mxs.LayerManager.getLayer(lyr)
			layers.append(layer.name)
		for i in sorted(layers):
			if i != "0":
				itm = QListWidgetItem( QString(i) )
				itm.setIcon( self.layer_ico )
				self.ui_MaxLayers.addItem(itm)

def main():

	current_path = mxs.maxFilePath
	if len(current_path)== 0 :
		QMessageBox.information(None, "Error Empty Scene","You need to open a Max Container file" )
	else:
		dialog = LevelHog()
		dialog.show()

if __name__ == '__main__':
    main()
