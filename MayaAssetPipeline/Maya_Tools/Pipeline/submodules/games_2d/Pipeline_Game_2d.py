import maya.mel

from main.Pipeline_Core import Pipeline_Core
import pymel.core as pm


class Pipeline_Core_2d(Pipeline_Core):
    """
    I'm planning on putting in a Render Farm Option in at some point
    Right now it works on user computer
    Also my assumption is that the user will touch up the renders in AE or the like
    There is a seperate Art Pipeline that will allow the user to make texture atlases ect
    Render Layers of each tier with names based on layers
    Render layers for each tier
    Diff
    AO
    Spec
    Shadows
    beauty
    """
    
    RENDER_PASS_NAMES = {'diffuse'           :"DIFF",
                         "ambient_occlusion"  :"AO",
                         "specularity"       :'SPEC',
                         "shadow"            :"SHD",
                         "beauty"            :"BEAUTY",
                         "diffuse_no_shadow" :"DIFFNS"
                        }
    
    WHAT_WE_RENDER_TO = Pipeline_Core.RENDER_TYPE["TGA"]
    
    
    def __init__(self, diffuse, ambient_occlusion, speculaity, shadow,
                beauty, diffuse_no_shadow, render_size, final_render_quality):
        super(Pipeline_Core_2d,self).__init__()
        
        # if we ever decide to extend add the render pass to here as well.  Used later
        self.render_passes          = (diffuse,ambient_occlusion,speculaity,
                                       shadow,beauty,diffuse_no_shadow)
        
        self.render_size            = render_size
        
        self.final_render_quality   = final_render_quality
        
     
    def make_render_layers_and_passes(self):
        layers = pm.ls(type='displayLayer')
        for layer in range(1,len(layers)):
            objects_selected = pm.editDisplayLayerMembers(layers[layer], fn=True, q=True)
            
            render_layer_name = "Render_" + layers[layer]
            
            #might possibly have to list connection and recurse through and get all the objects instead of this way
            
            pm.select(objects_selected)
            
            pm.createRenderLayer(n=render_layer_name, nr=True)
        
        render_layers = pm.ls(type='renderLayer')
        for render_layer in range(1,len(render_layers)):
            
            for render_pass in self.render_passes:
                
                # We pass the dict key here if it's false then skip the pass
                if render_pass == False:
                    pass
                
                render_pass_name = (render_layers[render_layer] + '_' + render_pass) 
                pm.createNode('renderPass', n=render_pass_name)
                pm.setRenderPassType(render_pass_name, type=self.RENDER_PASS_NAMES[render_pass])
                pm.connectAttr('%s.renderPass', '%s.owner', nextAvailable=True) % (render_layers[render_layer],
                                                                                   render_pass_name)  
                
                
    def set_render_settings(self):
        maya_file_name = pm.sceneName()
        pm.setAttr('defaultRenderGlobals.currentRenderer','mentalRay')
        render_name = ("<%s>_<RenderLayer>_<RenderPassType>_")%(maya_file_name)
        set_attrs = {"defaultRenderGlobals.imageFilePrefix":render_name,
                     "defaultRenderGlobals.imageformat":self.WHAT_WE_RENDER_TO,
                     "defaultResolution":self.render_size[0],
                     "defaultResolution":self.render_size[1]
                     }
        
        for key in set_attrs.keys():
            pm.setAttr(key,set_attrs[key])
        
    def render_everything(self):
        maya_file_name = pm.sceneName()
        maya.mel.eval('batchRender %s')%(maya_file_name)
        pass



    