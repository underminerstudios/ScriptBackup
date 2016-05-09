import maya.mel

from Pipeline.main.Core import Pipeline_Core
import pymel.core as pm


class Pipeline_Core_3d(Pipeline_Core):
    """
    """
    EDITOR_DRIVE = 'c:'
    FBX_VERSION  = 'FBX201500'
    
    
    def __init__(self, export_type, animation_separate):
        super(Pipeline_Core_3d,self).__init__()
        
        self.export_type        = export_type
        self.animation_separate = animation_separate
        
        
        
    def texture_export(self):
        
        textures = pm.ls(type='file')
        #I really hate the dupes!!!
        textures = list(set(textures))
        for texture in textures:
            texture_path = pm.getAttr(texture.fileTextureName)
            self.engine_exporter(texture_path, 'Textures')
        
        
        
    def animation_export(self):
        maya_file_name = pm.sceneName()
        split = self.splitter(maya_file_name, 0, True)
        #export the art to the correct location
        if not(split[2][1] == 'ANIM'):
            # tell the user we can't send out files that we only export animations seperate of models
            pass
        else:
            self.fbx_options_export(maya_file_name, True, True)
        self.engine_exporter(maya_file_name,'Animations')
        
        
        
    def export_model(self):
        maya_file_name = pm.sceneName()
        split = self.splitter(maya_file_name, 0, True)
        #export the art to the correct location
        if split[2][1] == 'ANIM':
            # tell the user we can't send out files that are animation files
            pass
        else:
            self.fbx_options_export(maya_file_name, False, False)
        
            self.engine_exporter(maya_file_name,'Models')
        
        
        
    def fbx_options_export(self,export_file_name,anim_only,bake_animation):
        
        # if I ever decide to split out animations I'll need to restructure,
        # also if anyone knows how to do this correctly in pymel I would be grateful for the solution
        possible_flags =('FBXResetExport()','FBXExportBakeComplexAnimation(v=bake_animation)',
                        'FBXExportAnimationOnly(v=anim_only)','FBXExportInAscii(v=True)',
                        'FBXExportInAscii(v=True)','FBXExportGenerateLog(v=True)','FBXExportCameras(v=False)',
                        'FBXExportLights(v=False)','FBXExportFileVersion(v=self.FBX_VERSION)',
                        'FBXExport(s=True, f=export_file_name)')

        
        # just in case I need this later
        '''
        FBXExportConstraints(v=False)
        FBXExportInputConnections(v=False)
        FBXExportUseSceneName(v=True)
        FBXExportSkins(v=True)
        FBXExportShapes(v=True)
        '''
        
        
        # as much as I love pymel sometimes mel is the only way.  If anyone has the correct way to do this 
        # I would really appreciate it!
        for possible_flag in possible_flags:
            maya.mel.eval('%s')%(possible_flag)

        
