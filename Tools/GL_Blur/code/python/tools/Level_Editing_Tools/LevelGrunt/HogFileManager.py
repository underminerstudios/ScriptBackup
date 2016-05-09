##
#   :namespace  levelgruntdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       01/23/13
#



from PyQt4.QtGui import * 
import ast, os, re
from Py3dsMax import mxs # import max modul
nfy  = mxs.pyhelper.namify
from  glmax.max3d import GLMax
glm = GLMax()


class HogFileManager:
	'''Class for managing GL Hog file and Xrefs'''
	def __init__( self ):
		self.str_dict = "{'name':'%s', 'path':'%s', 'parent':'%s', 'rot':'%s', 'scale':'%s','pos':'%s', 'lm':'%s', 'uv2':'%s','vcolor':'%s','morph':'%s'}"

	def SaveHogFile (self, hog_file, pID ):
		print pID
		layers = mxs.LayerManager
		_count = layers.count
		
		scene_layers = []
		for lyr in range(_count):
			
			xrefs = ""
			_sector = (mxs.LayerManager.getLayer (lyr)).name
			if _sector != "0":
				layer = mxs.ILayerManager.getLayerObject ( _sector )
				layerRT = layer.layerAsRefTarg
				layer_deps = mxs.refs.dependents ( layerRT )
				
				for itm in layer_deps:
					# build the xref dictionary
					_node = str( mxs.superclassof (itm ) )
					if _node == "GeometryClass" and (itm.name).find('{xrf}') != -1:
						lm = mxs.getUserProp (itm, "#LightMap")
						xref_path =  mxs.getUserProp (itm, "#xref_path")

						xref_name = str(itm.name)
						xref_name = xref_name.replace('{xrf}', '')
						xref_name = re.sub("[^aA-zZ]", "", xref_name) #sript all numbers
						
						prop = (self.str_dict % ( xref_name, xref_path, _sector, str(itm.rotation), str(itm.scale), str(itm.position), lm, "","","") )
						xrefs += ( str(prop) + ";" )
							
				data_out =  (_sector + "=" +  str(xrefs))
				scene_layers.append(data_out)
			
		scene_layers.sort()
		#insert the project Id in the begining of the list
		scene_layers.insert(0, "project=" + "0" ) 
		#write out the hog file
		out_file = open( hog_file, "w")
		for lyr in scene_layers:
			out_file.write(lyr + "\n")
		out_file.close()	
		
	def GetHogData ( self, _file ):
		r'''Gets the currently stored data in the hog file '''
		list_data = []
		f = open(_file, 'r')
		for line in f:
			line = line.strip()
			list_data.append(line)
		list_data.sort()
		f.close()
		return list_data
		
		if len(none_existent) != 0:
			error_msg = "Error! Could not find the following max files.\r-----------------------------------------------------\r"
			for itm in none_existent:
				error_msg += itm + "\r"
			QMessageBox.information(self, "Error Empty Scene", error_msg  )
			self.RefreshHogList()
			
		mxs.redrawViews() 

	def SetHogData ( self, _file, hog_data, _sector, data_out ):
		r''' Actual writing of the hog data '''
		list_data = []
		for line in hog_data:
			line = line.strip()
			tokens = line.split("=")
			
			if tokens[0] == _sector:
				list_data.append ( data_out )
			else:
				list_data.append( line )
		
		f = open( _file, 'w' )
		for itm in list_data:
			f.write(itm + "\n")
		f.close()
		
	def WriteOutXrefs (self, _file, _sector ):
		r'''Gathers the xref objects based on a given sector'''
		hog_data = self.GetHogData ( _file )
		data_out = ""
		for itm in hog_data:
			tokens = itm.split("=")
			if tokens[0] == _sector:
				xrefs = ""
				
#				obj = mxs.getnodebyname ( _sector )
				layer = mxs.ILayerManager.getLayerObject ( _sector )
				layerRT = layer.layerAsRefTarg
				layer_deps = mxs.refs.dependents ( layerRT )
				for itm in layer_deps:
					_node = str( mxs.superclassof (itm ) )
					if _node == "GeometryClass" and (itm.name).find('{xrf}') != -1:
						lm = mxs.getUserProp (itm, "#LightMap")
						xref_path = udp = mxs.getUserProp (itm, "#xref_path")
						name = ( (itm.name).split("_") )[1]
#						str_dict = "{'name':'%s', 'path':'%s', 'parent':'%s', 'rot':'%s', 'scale':'%s','pos':'%s', 'lm':'%s', 'morph':'%s'}"
						prop = (self.str_dict % ( 'prop_A', xref_path, _sector, str(itm.rotation), str(itm.scale), str(itm.position), lm, "") )
						xrefs += ( str(prop) + ";" )
#						
				data_out =  (_sector + "=" +  str(xrefs))
#				print data_out
		
		self.SetHogData ( _file, hog_data, _sector, data_out )
		
	def WriteOutXrefsORGINAL (self, _file, _sector ):
		r'''Gathers the xref objects based on a given sector'''
		hog_data = self.GetHogData ( _file )
		data_out = ""
		for itm in hog_data:
			tokens = itm.split("=")
			if tokens[0] == _sector:
				xrefs = ""
				
				obj = mxs.getnodebyname ( _sector )

				children = glm.getChildren(obj)
				for itm in children:
					
					if (itm.name).find('{xrf}') != -1:
						lm = mxs.getUserProp (itm, "#LightMap")
						xref_path = udp = mxs.getUserProp (itm, "#xref_path")
						print lm
						print xref_path
						name = ( (itm.name).split("_") )[1]
						str_dict = "{'name':'%s', 'path':'%s', 'parent':'%s', 'rot':'%s', 'scale':'%s','pos':'%s', 'lm':'%s', 'morph':'%s'}"
						prop = (str_dict % ( 'prop_A', xref_path, itm.parent.name, str(itm.rotation), str(itm.scale), str(itm.position), lm, "") )
						xrefs += ( str(prop) + ";" )
						
				data_out =  (_sector + "=" +  str(xrefs))
		
		self.SetHogData ( _file, hog_data, _sector, data_out )

		
	def DeleteXrefs ( self, _sector ):
		r'''Deletes xrefs from a given sector '''
		obj = mxs.getnodebyname ( _sector )
		children = glm.getChildren(obj)
		for itm in children:
			if (itm.name).find('{xrf}') != -1:
				mxs.delete( itm )
				

	def LoadXrefs ( self, _file, _sector ):
		r''' Loads the xref objects from a string dictionary '''
		
		_list = self.GetHogData ( _file )
		xrefs = []
		for itm in _list:
			tokens = itm.split("=")
			if tokens[0] == _sector and len(tokens):
				xrefs = tokens[1].split(";")
		for itm in xrefs:
			if len(itm) != 0:
				dct = ast.literal_eval( str( itm ) ) #convert the string to a dictionary
				file_test = ( dct['path'] )
				sector = mxs.getnodebyname ( dct['parent'] )
#				print sector.name
				layer = mxs.ILayerManager.getLayerObject ( dct['parent'] )
				
				if file_test != 0 and sector != None:	
					name = dct['name']
#					print name
					d_rot = (dct['rot']).strip('(quat' ')').split()
					d_pos = (dct['pos']).strip('[' ']').split(',')
					d_scl = (dct['scale']).strip('[' ']').split(',')
					
					rot = mxs.quat( float(d_rot[0] ), float(d_rot[1] ), float( d_rot[2] ), float( d_rot[3] ) )
					pos = mxs.Point3( float( d_pos[0] ), float( d_pos[1] ), float( d_pos[2] ))
					scale = mxs.Point3( float( d_scl[0] ), float( d_scl[1] ), float( d_scl[2] ))
				
					mxs.mergemaxfile( dct['path'], nfy( "select" ),nfy( "mergeDups" ),\
										nfy( "useSceneMtlDups" ), nfy( "alwaysReparent" ) ) 
										
					#parent the new object to the sector name and move to layer
					obj = mxs.getnodebyname ( name )
					glm.setUserDefinedProps (obj, "#LightMap", dct["lm"] )
					glm.setUserDefinedProps (obj, "#xref_path", dct["path"] )
					obj.parent =  sector 
					layer.addnode (obj)

					#rotate the oject befrom scaling and moving the object	
					obj.rotation = rot
					obj.position = pos
					obj.scale 	 = scale
					obj.name =  dct[ 'name' ] + '{xrf}'
					
	def makeDirectory (self, _path):
		r'''Creates a directory for a given path'''
		file_test = os.path.isdir ( _path ) 
		if file_test == False:
			os.mkdir( _path )
			
	def FilterName ( self, _string ):
		r'''Filters the a string removing numbers and col_, HD_, dtl_, hd_, {xrf} '''
		prefixes = ['col_','HD_','dtl_','hd_','{xrf}']
		for itm in prefixes:
			_string = _string.replace(itm, '')
		_string = re.sub("[^aA-zZ]", "", _string)
		return _string
		
		
	def MakeLibrary (self, scn_path ):
		libs_exist = []
		lib_path = scn_path + 'library\\'
		self.makeDirectory( lib_path )
		
		for _node in mxs.selection:
			
			#gather the info about the library object
			pos = _node.position
			rot = _node.rotation 
			scale = _node.scale
			par = _node.parent
			original_layer = mxs.ILayerManager.getLayerObject ( par.name )
			default_layer  = mxs.ILayerManager.getLayerObject ( '0' )
			original_name = _node.name
			new_name = self.FilterName(original_name)
				
			#manipulate the object
			default_layer.addNode ( _node )
			_node.name = new_name
			_node.parent = None
			_node.rotation = mxs.quat(0, 0, 0, 1)
			_node.position = mxs.Point3(0, 0, 0 )
			_node.scale = mxs.Point3(1, 1, 1 )
			
			#Do the actual export of the lib
			export_lib = lib_path + _node.name + ".max"
			lib_test = os.path.isfile ( export_lib )
			if lib_test == False:
				mxs.saveNodes( _node, export_lib )
			else:
				libs_exist.append( _node.name ) 
			
			#return the object back to its normal state.
			_node.name = original_name 
			_node.rotation = rot
			_node.position = pos
			_node.scale = scale
			_node.parent = par
			original_layer.addNode ( _node )

		if len(libs_exist) != 0:
			
			error_msg = ("Library item already exists in:\n %s\n\n" % ( lib_path ) )
			for itm in libs_exist:
				error_msg += itm + "\r"
			QMessageBox.information(None, "Error Empty Scene", error_msg )

#scn_path = mxs.maxFilePath

#_node = mxs.getnodebyname('green_teapot')
	
#hfm = HogFileManager( )
#hfm.SaveHogFile()
#xrf.MakeLibrary( scn_path )

#data = xrf.GetHogData ( file )
#xrf.LoadXrefs(data, 'room_01')
#file = "C:/Users/Anisim.Kalugin/Documents/3dsMax/scenes/scenes.hog"

#hfm.MakeLibrary("D:/Projects/zone_test/")
