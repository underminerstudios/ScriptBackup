import _winreg, os, shutil

import pymel.core as pm


class Pipeline_Core(object):


    # most common file types derived from pm.getAttr('defaultRenderGlobals.imageFormat')
    # applying it is as simple as pm.setAttr('defaultRenderGlobals.imageFormat', value)

    RENDER_TYPE            = {"IFF"              :7,
                             "TIFF"              :3,
                             "Tiff uncompressed" :51,
                             "Jpg"               :8,
                             "TGA"               :19,
                             "HDR"               :51,
                             "Layered PSD"       :36,
                             "PNG"               :32,
                             "EXR"               :51}

    MASTER_GAME_DIRECTORY  = 'G:\games'
    NAME_TYPE              = ['CHA','PROP','ANIM','ENV',"GLOBAL"]
    TEXT_NAME_TYPE         = ['TEXT']
    SIDE                   = ['L','R','C']
    MASTER_NAME            = 'MASTER'
    DATABASE_NAME          = 'DATABASE'
    PROGRAMS_NEEDED        = ["TexturePacker","TortoiseSVN"]
    DATABASE_CAMERA        = 'Database_Camera'
    DATABASE_CAMERA_X      = 1024
    DATABASE_CAMERA_Y      = 1024
    DATABASE_LOCATION      = 'G:\Database'
    TEXTURE_TYPES          = ['.tga','.tiff']
    FILE_TYPES             = ['.ma','.mb']
    TEXTURE_PASS           = ['NRM','DIF','TRA','BMP','NRM','SPE','GLO','REF']
    TEXTURE_FLAGS          = 7
    FILE_FLAGS             = 6
    VIEW_FIT_DISTANCE      = 0.5
    DEFAULT_GAME           = 'GLOBAL'
    
    def __init__(self,files_to_use,game_directory='',database_location=''):
        self.files_to_use          = files_to_use
        self.game_directory        = game_directory or self.Master_Game_Directory
        self.database_location     = database_location or self.DATABASE_LOCATION
        
        
        
    def get_game_names(self):
        try:
            ( _,temp_game_names,_) = os.walk(self.game_directory).next()
            temp_game_names_iterate_over=[]
            for game_check in range(0,len(temp_game_names)):
                if not(temp_game_names[game_check].endswith('.') or temp_game_names[game_check].startswith('.')):
                    temp_game_names_iterate_over+=temp_game_names[game_check]
                return temp_game_names_iterate_over
        except OSError, whatver_the_error_is:
            pm.error('''Either the directory does not exist or there are no games in the directory of %s.
            Please check the directory''')%(whatver_the_error_is)
    
    
    
    def file_check(self):
        
        '''
        does checks on the files including length and that the files are of correct type
        and named correctly then imports the files if the are good!
        '''
        
        broken_files_w_whats_wrong = []
        files_to_test = self.files_to_use
        while True:
            
            for current_file in range(0,(len(files_to_test))):
                
                pass_name_test = self.name_checker(files_to_test[current_file], 
                                                   self.FILE_TYPES, self.FILE_FLAGS,self.NAME_TYPE)
            
                if pass_name_test:
                    files_to_test[current_file].pop(current_file)
                    pass
                
                else:
                    broken_files_w_whats_wrong.extend([pass_name_test[0],pass_name_test[1]])


            #run the popup with broken files broken_files_w_whats_wrong then 
            if len(files_to_test) == 0:
                break
                    
        
       
    def name_checker(self,current_file,file_extension_type, number_of_flags,name): 
        
        # correct file name is Game(3 length acronym all upper case)_Type(CHA/PROP/ANIM/ENV)
                #_name(all lower think bob it it's a prop that belongs to no one then
                #global always lower)_side(L R or C. if none it's C)_idenifier(ex: body, gun, run, moon. 
                #always lower)
                # if any of the below happens the program will stop till the user renames the files

        split = self.splitter(current_file, 0, True)
        file_ext   = split[1][-1]
         
        errors = [file_ext in file_extension_type
                  ((len(split[2]))== number_of_flags),
                     (split[2][0] in self.get_game_names()),
                     (split[2][1] in name),
                     (split[2][2].islower()),        
                     (split[2][3] in self.SIDE),     
                     (split[2][4].islower()),
                     (split[2][5] in self.TEXTURE_PASS)          
                    ]
        
        
        errors_printouts = ["Wrong File Type"
                            "There is a missing flag",
                             "The game name is incorrect",
                             "The type is not correct",
                             "The name flag is not lower cased",
                             "The side is incorrect",
                             "The idenifier is not lower cased",
                             "Not a correct texture type"]
                    
            
        whats_broken_number = range(0,number_of_flags+1)
        
        error_and_printouts = zip(errors,errors_printouts)
        
        file_name_checker = dict(zip(whats_broken_number,error_and_printouts))

        for problem_check in split[3]:
            if not (file_name_checker[problem_check][0]):
                #print a ui popup with the broken flag
                
                return (self.files_to_use[current_file],file_name_checker[problem_check][1])
        else:
            return True
                
                
    def make_maya_file_and_import(self,maya_file):
        """
        Makes the maya file, imports files, and makes visibility layers.
        """
        
        maya_file = self.files_to_use[0]
        
        if ((len(self.files_to_use))==1):
            maya_file = self.files_to_use
        
        #split the file name extension and with underscores so we can combine
        
        split = self.splitter(maya_file)
        
        # change the name of the type from 
        split[2][1] = self.MASTER_NAME
        
        maya_file_final_name = self.splitter(split)[3]
        pm.newFile(maya_file_final_name)
        
        for file_imported in self.files_to_use:
            
            split = self.splitter(file_imported)
            
            pm.importFile(file_imported, groupReference=True, groupName=split[3], defaultNamespace=True)
        
            pm.createDisplayLayer(n=split[3])
            
               
            
    def texture_check(self):
        textures = pm.ls(type='file')
        # getin rid of the dupes one line at a time...
        textures = list(set(textures))
        for texture in textures:
            
            try:
                texture_path = pm.getAttr(texture.fileTextureName)
                
                self.name_checker(texture_path, self.TEXTURE_TYPES, self.TEXTURE_FLAGS, self.TEXT_NAME_TYPE)

                # actual pymel... I KNOW!!!!!! WOW....
                file_size = texture.outSize.get()
                
                # generate power of 2 to use later
                power_of_two = []
                start_number = 2
                while not(start_number == 4096): 
                    start_number *= 2
                    power_of_two.append(start_number)
                    
                    
                if not((file_size[0]/file_size[1])==1):
                    
                    #tell the user that the art is not square
                    
                    pass
                
                elif ((file_size[0]/file_size[1])==1) and not(file_size[0] in power_of_two):
                    
                    #tell the user that the art is not pot
                    
                    pass
                
                elif ((file_size[0]/file_size[1])==1) and (file_size[0] in power_of_two):
                    # art is good and passes all our tests!!! sweeeeet
                    break
                
                else:
                    problem = 'not sure what happened with the texture %s please check it manually and rerun.'%(texture)
                    # send problem to the user and have them fix before we move on
                    return 
                
            except:
                pass  
            
        
        
    def check_installed_programs(self):
        
        winreg_key = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, 
                                     r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", 
                                     0, _winreg.KEY_WOW64_64KEY + _winreg.KEY_READ)
        
        list_of_programs = []
        
        for i in xrange(0, _winreg.QueryInfoKey(winreg_key)[0]-1):
            winreg_key_idenifier = _winreg.EnumKey(winreg_key, i)
            winreg_key_name = _winreg.OpenKey(winreg_key, winreg_key_idenifier)
            
            try:
                programs= _winreg.QueryValueEx(winreg_key_name, 'DisplayName')[0]
                list_of_programs.append(programs)
            except:
                pass
            finally:
                winreg_key_name.Close()
          
        for program_needed in list_of_programs:
            program_needed = program_needed.split(' ')[0]
            if not program_needed in list_of_programs:
                
                pass
        
        
        
    def turn_on_needed_plugins(self):
        pm.loadPlugin("fbxmaya")
        pm.loadPlugin('Mayatomr')
        
        
        
    def render_settings_and_render(self,display_layer_name):
        
        maya_file_name = pm.sceneName()
        
        split = self.splitter(maya_file_name, 0, True)
        
        split[2][1] = self.DATABASE_NAME
        
        
        database_scene_name = self.splitter(split[2], 0, 2) 
        render_name = ("<%s>_%s")%(database_scene_name,display_layer_name)
        pm.setAttr("defaultRenderGlobals.imageFilePrefix",render_name)
        
        render_to_move = pm.render('%s', x=self.DATABASE_CAMERA_X, 
                                y=self.DATABASE_CAMERA_Y )%(self.DATABASE_CAMERA)
                                
        return render_to_move
        
        
        
    def ortho_setup_and_run(self): 
        
        pm.setAttr("defaultRenderGlobals.imageformat", self.RENDER_TYPE["Jpg"])
        database_camera = pm.camera(n=self.DATABASE_CAMERA)
        pm.rotate(database_camera,[-45,-45,0])
        
        layers = pm.ls(type='displayLayer',long=True)
        
        if not (len(layers) > 1):
            
            pm.setAttr('%s.visibility',1)%(layers)
            pm.viewFit(database_camera, f=self.VIEW_FIT_DISTANCE, all=True)
            self.render_settings_and_render(layers)
            
        else:
            
            for layer in range(1,len(layers)):
                
                pm.setAttr('%s.visibility',0)%(layer)
                
            for layer in range(1,len(layers)):
                
                pm.setAttr('%s.visibility',1)%(layers[layer])
                pm.setAttr('%s.visibility',0)%(layers[layer-1])
                objects_to_select = pm.editDisplayLayerMembers(layers[layer], fn=True, q=True)
                pm.select(objects_to_select)
                pm.viewFit(database_camera, f= self.VIEW_FIT_DISTANCE)
                file_to_move = self.render_settings_and_render(layers[layer])
                self.move_file(file_to_move,self.database_location, False)
                



    def move_files(self,file_to_move,move_to,editor):
        
            split = self.splitter(file_to_move,0,True)
            
            flag_name = split[3]
            
            if editor:
                split = self.splitter(file_to_move,1,True)               
                flag_name = split[3]
            
            final_location = os.path.join(move_to,flag_name,split[0])
            
            if not (os.path.exists(os.path.dirname(final_location))):
                
                os.makedirs(os.path.dirname(final_location))
                shutil.copyfile(file_to_move, final_location)
                
                
                
    def splitter(self,file_to_split,start,end):
        name_split = os.path.split(file_to_split)[-1]
        no_location_name_split = name_split.split('.')
        name_to_check = no_location_name_split[0].split('_')
        
        if end:
            end = len(name_to_check)
        reconstitute = [(name_to_check.join('_')[i]) for i in range(start,end)] 
        
        return name_split, no_location_name_split, name_to_check,reconstitute
    
    
    
    def engine_exporter(self,art_location, file_type_of_art):
        split = self.splitter(art_location)
        #export the animation files and place correct location
        engine_location = os.path.join(self.EDITOR_DRIVE,split[2][0],file_type_of_art)
        self.move_files(art_location, engine_location, True)
        


