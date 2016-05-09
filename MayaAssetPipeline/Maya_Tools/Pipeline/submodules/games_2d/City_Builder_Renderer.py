import pymel.core as pm
from Pipeline.submodules.games_2d.Pipeline_Game_2d import Pipeline_Core_2d


class City_Builder_Renderer(Pipeline_Core_2d):

    
    
    def __init__(self,number_of_angles,view_fit_distance_city_builder):
        super(City_Builder_Renderer,self).__init__()
        
        
        self.number_of_angles     = number_of_angles
        self.VIEW_FIT_DISTANCE = view_fit_distance_city_builder
     
    
    def camera_setup(self):
        
        city_builder_camera = pm.camera(n="CityBuilderCam")
        pm.rotate(city_builder_camera,[-45,-45,0])
        pm.viewFit(city_builder_camera, f=self.VIEW_FIT_DISTANCE, all=True)
        
        city_builder_camera_group_name = pm.group(city_builder_camera)
        pm.autoKeyframe(state=True)
        precent_of_turn = (360/self.number_of_angles)
        
        
        for time in range(1,self.number_of_angles):
            pm.setCurrentTime(time)
            pm.rotate(city_builder_camera_group_name,[0,precent_of_turn,0])
            precent_of_turn += precent_of_turn
            
        pm.autoKeyframe(state=False)