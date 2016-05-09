import os
from Py3dsMax import mxs # import max module
from  glmax.max3d import GLMax
glm = GLMax()

from  glmax.gl_material_utilities import MaterialUtilities
mu = MaterialUtilities()

class RenderingUtilities:
	def __init__(self):
		self.data = []
	def GetPresetPath (self):
		'''Gets a predefined path for the render presets'''		
		return str(os.path.split( __file__ )[0] + '\\presets\\')
	
	def GetCurrentScenePath(self):
		tokens  = mxs.maxFilePath.split( "\\")

		if len(tokens) == 1:
			print 'Need to save the scene'
			return ['c:/tmp/emptyScene/', 'emptyScene']
		else:
			sceneName = tokens[-2]
			tokens.pop(-1)
			path = ''
			for i in tokens:
				path += i + '/'
			return [path, sceneName]
	
class LightMapUtilities:
	'''Merges and manages meshes for baking lightmaps'''
	def __init__(self):
		self.data = []
		self.mu = MaterialUtilities()
		
	def MakeBakeMesh( self, name = 'LM_Mesh'):
		zoneNodes = self.GetZoneNodes( self.GetDHModules())
		bakeObject = glm.snapshotObjectMerge( zoneNodes )
		bakeObject.name = name
		material = bakeObject.material
		bakeObject.material = self.mu.makeVrayMaterial( self.mu.getMaterialData (material) )
		mxs.RedrawViews()
#		mxs.completeRedraw()
		
	def GetDHModules(self):
		zones = []
		for obj in mxs.objects:
			name = obj.name
			if name.startswith('_module'):
				zones.append(obj)
		return zones

	def GetZoneNodes(self, zoneList ):
		'''Get all the nodes all the supplied zones - modules - rooms'''
		bakeMeshChildren = []
		for zone in zoneList:
			zoneChildren = glm.getChildren(zone)

			if zoneChildren[0].name.startswith('_module') == True:
				zoneChildren.pop(0)

			for child in zoneChildren:
				bakeMeshChildren.append(child)
		return bakeMeshChildren
	
	def SetLayerBakingMode( self ):
		'''Set up the layers only "lights" and "BakeMesh" layers to be visible'''
		bakeMeshList = ['BakeMesh', 'LIGHTS', 'BakeMesh_Occ']
		for i in range(0, len(mxs.LayerManager)):
			layer = mxs.layerManager.getLayer(i)
			layer.ishidden = True
			for bml in bakeMeshList:
				if bml == layer.name:
					layer.ishidden = False
		mxs.RedrawViews()
				

#class MaterialUtilities:
#	'''Functions for getting the materials information and converting materials'''
#	def __init__(self):
#		self.data = []
#		
#	def makeVectorMaterials(self):
#		'''Returns three vector materials'''
#		matVectors = [["Red", 0.908248, 0.5, 0.788675],\
#						 ["Green", 0.295876, 0.853555, 0.788675],\
#						 ["Blue", 0.295876, 0.146446 , 0.788675] ]
#						 
#		vectorMaterials 	= []
#		
#		for info in matVectors:
#
#			newMat = mxs.VRayMtl ()
#			newMat.name 						= info[0]
#			newMat.texmap_bump_multiplier 		= 100
#			newMat.texmap_bump 					= mxs.VRayNormalMap ()
#			newMat.texmap_bump.normal_map 		= mxs.VRayColor ()
#			newMat.texmap_bump.normal_map.red 	= info[1]
#			newMat.texmap_bump.normal_map.green = info[2]
#			newMat.texmap_bump.normal_map.blue 	= info[3]
#			
#			vectorMaterials.append(newMat)
#		return vectorMaterials
#		
#		
#	
#	def getGLMaterialData(self, material):
#		'''Gets the GL instance texture infromation. diffuse[0]'''
#		bitmapList = []
#		DiffuseTests = ["DiffuseMap", "Diffuse", "FalloffSampler","DiffuseSampler", "Diffuse_Map"]
#		diffuseParams = None
#		count = 0
#		while diffuseParams == None:
#			diffuseParams = material.params.GetEffectParamByName (DiffuseTests[count])
#			count += 1
#			
#		diffuseMap =(mxs.Bitmaptexture(fileName = diffuseParams.texturePath))
#		bitmapList.append(diffuseMap)
#		
#		return bitmapList	
#		
#	def getStandardMaterialData(self, material):
#		'''Gets the standard material information. diffuse[0], spec[1], opacity[2]'''
#		bitmapList = []
#		#get Diffuse Map
#		if material.diffuseMap != None:
#			bitmapList.append(material.diffuseMap)
#		elif material.diffuseMap == None:
#			bitmapList.append(None)
#		#get Specular Map	
#		if material.specularMap != None:
#			bitmapList.append(material.specularMap)
#		elif material.specularMap == None:
#			bitmapList.append(None)
#		#get Opacity Map
#		if material.opacityMap != None:
#			bitmapList.append(material.opacityMap)
#		elif material.opacityMap == None:
#			bitmapList.append(None)
#		
#		return bitmapList
#			
#	def materialDictionary(self):
#		'''Dictionary Setup'''
#		materialDictionary = {
#				'ID': None,
#				'name': None,
#				'diffuse': None,
#				'specular': None,
#				'opacity': None
#				} 
#		return materialDictionary
#		
#	def getMaterialData (self, material):
#		'''Get the diffuse, spec and opcity maps for 
#		   Standardmaterial and GL Glitch materials'''
#		count = 0
#		matArr =0 
#		matDictList = []
#		
#		matCounter = 0
#		
#		if glm.classOf(material) =="Multimaterial":
#			matIDs = list(material.materialIDList)
#
#			for id in matIDs:
#				matDict = self.materialDictionary()
#				matDict['ID'] = id
#				mat = material[matCounter]
#				
#				if mat != None:
#					matDict['name'] = str(mat.name)
#					
#				if glm.classOf(mat) == "GL_Effect_Inst":
#					matDataList = self.getGLMaterialData(mat)
#					matDict['diffuse'] = matDataList[0]
#					
#				if glm.classOf(mat) == "Standardmaterial":
#					
#					matDataList = self.getStandardMaterialData(mat)
#					matDict['diffuse'] = matDataList[0]
#					matDict['specular'] = matDataList[1]
#					matDict['opacity'] = matDataList[2]
#				
#				matDictList.append(matDict)
#				matCounter += 1
#			
#		if glm.classOf( material) == "Standardmaterial":
#			matDict = self.materialDictionary()
#			matDataList = self.getStandardMaterialData(material)
#			matDict['name'] = str(material.name)
#			matDict['diffuse'] = matDataList[0]
#			matDict['specular'] = matDataList[1]
#			matDict['opacity'] = matDataList[2]
#			matDictList.append(matDict)
#		return matDictList		
#
#	def makeVrayMaterial( self, materialDictionaryList ):
#		''' Retruns a VRay Material based on supplied dictionary'''
#		dl = materialDictionaryList
#		material = None
#		if len(dl) == 1:
#			dict = dl[0]
#			vrm = mxs.VRayMtl ()
#			vrm.name = str(dict['name'])
#			if dict['diffuse'] != None:
#				vrm.texmap_diffuse = dict['diffuse'] 
#			if dict['specular'] != None:
#				vrm.texmap_hilightGlossiness = dict['specular']
#			if dict['opacity'] != None:
#				vrm.texmap_opacity = dict['opacity']
#			material = vrm
#			
#		if len(dl) > 1:
#			multiMat = mxs.multimaterial( numsubs = len(dl))
#			count = 0
#			for dict in dl:
#				vrm = mxs.VRayMtl ()
#				vrm.name = "VR_" + str(dict['name'])
#				multiMat.names[count] = str(dict['name'])
#				
#				multiMat.materialList[count] = vrm
#				if dict['name'] != None:
#					if dict['diffuse'] != None:
#						vrm.texmap_diffuse = dict['diffuse'] 
#						vrm.texmap_diffuse_on= True
#					if dict['specular'] != None:
#						vrm.texmap_hilightGlossiness = dict['specular']
#					if dict['opacity'] != None:
#						vrm.texmap_opacity = dict['opacity']
#				count += 1
#			material = multiMat
#		return material
#			
#	def makeStandardMaterial( self, materialDictionaryList ):
#		''' Retruns a Standard Material based on supplied dictionary'''
#		dl = materialDictionaryList
#		material = None
#		if len(dl) == 1:
#			dict = dl[0]
#			mat = mxs.Standardmaterial ()
#			mat.name = str(dict['name'])
#			if dict['diffuse'] != None:
#				mat.diffuseMap = dict['diffuse'] 
#			if dict['specular'] != None:
#				mat.specularMap = dict['specular']
#			if dict['opacity'] != None:
#				mat.opacityMap = dict['opacity']
#			material = mat
#			
#		if len(dl) > 1:
#			multiMat = mxs.multimaterial( numsubs = len(dl))
#			count = 0
#			for dict in dl:
#				mat = mxs.Standardmaterial ()
#				mat.name = "STD_" + str(dict['name'])
#				multiMat.names[count] = str(dict['name'])
#				
#				multiMat.materialList[count] = mat
#				if dict['name'] != None:
#					if dict['diffuse'] != None:
#						mat.diffuseMap = dict['diffuse'] 
#					if dict['specular'] != None:
#						mat.specularMap = dict['specular']
#					if dict['opacity'] != None:
#						mat.opacityMap  = dict['opacity']
#				count += 1
#			material = multiMat
#		return material
#		
class VrayUtilities:		
	def __init__(self):
		self.data = []
			
	def SetVrayCamera(self):
		cXform =  mxs.Inverse(mxs.viewport.getTM())
		vc = mxs.VRayPhysicalCamera()
		vc.transform = cXform
		vc.focal_length = 15
		vc.vignetting = False
		#vc.whiteBalance		= mxs.color(130, 205, 255)
		mxs.viewport.setcamera( vc )
		mxs.RedrawViews()
		return vc
		
	def GetVraySun(self):
		'''Returns VraySun of the current scene'''
		sceneSun = None
		for light in mxs.lights:
			if glm.classOf(light) =='VRaySun':
				sceneSun = light
		return sceneSun
		
	def SetVraySun(self):
		'''Sets the VraySun'''
		sunPos 			= mxs.Point3(0,25000,0 )
		sunTargetPos	= mxs.Point3(0, 0, 0 )
		size			= mxs.Point3(500, 500, 500 )
		
		sun = mxs.VRaySun(name = 'VRaySun', pos = sunPos)
		sunTarget = mxs.Dummy(name ='VRayTarget', pos = sunTargetPos)
		sunTarget.boxsize = (size * 0.5) 
		polarNode = mxs.Dummy(name = 'Polar', pos = sunTargetPos)
		polarNode.boxsize = size 
		
		sun.target = sunTarget
		sun.parent = polarNode
		sunTarget.parent = polarNode
		
	def SetVraySkyEnvironment (self):
		'''Sets environment sky global settings'''
		sun  = self.GetVraySun()
		env = mxs.VRaySky()
		env.manual_sun_node = True
		env.sun_node = sun
		mxs.environmentMap = env
		
		#set rendering global settings for environment
		vr = mxs.renderers.current
		vr.environment_gi_map = env
		vr.environment_gi_on = True
		vr.environment_gi_color = mxs.color(211, 234, 255 )

