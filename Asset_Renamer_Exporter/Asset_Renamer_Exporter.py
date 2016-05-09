import os,time,shutil,subprocess,json,sys
from time import sleep
reload(sys)
from dircache import listdir
sys.setdefaultencoding("utf-8")


class Asset_Rename_Exporter(object):
    
    def __init__(self):
        
        #checks the name and if it's windows gets the common location.
        self.platform = os.name
        if self.platform == "nt":
            self.photoshop = r"C:\Program Files\Adobe\Adobe Photoshop CC 2015\Photoshop.exe"
            self.after_effects = r"C:\Program Files\Adobe\Adobe After Effects CC 2015\Support Files\AfterFX.exe"
        else:
            self.photoshop = "Adobe Photoshop CC 2014"
            self.after_effects = "Adobe AfterEffects CC 2014"
        pass
    
    def makeScreenShots(self, files_to_convert,seperator):
        #relative path of all script files and put out the art to new locations
        current_script_path = os.path.dirname(os.path.realpath(__file__))
        javascript_file_export = os.path.realpath(os.path.join(current_script_path,'..','photoshop_scripts','photoshop_jpegSave_BATCH.jsx'))
        
        for file_to_convert in files_to_convert:

            file_to_convert = seperator + file_to_convert
            

            splitFileName = os.path.split(file_to_convert)[-1]
            fileName = splitFileName.split('.')[0] + ".jpeg"

            psd_export_folder = os.path.realpath(os.path.join(os.path.split(file_to_convert)[0],'..','Converted'))
              
            location_of_temp = self._make_temp_folder(psd_export_folder)
            new_file_name = os.path.join(psd_export_folder,fileName)
            
            if not(os.path.exists(new_file_name)):
            #sends for conversion
                self._windows_jsx_file_prep(file_to_convert, javascript_file_export, location_of_temp, new_file_name,False,self.photoshop)
        

           
    def check_photoshop_names(self,file_name,new_file_name, everything):
        
        #old fasioned loop to go through the psd (comic book names) to shot names
        last = 0
        for key in everything:
            last+=1
            
            if new_file_name in everything[key]['Comicbook Panel']:
                dict_of_old_new = {everything[key]["Comicbook Panel"]:everything[key]["Shot"]}
                return dict_of_old_new,file_name
            
            elif not(new_file_name in everything[key]['Comicbook Panel']) and (last == len(everything)):
                
                problem_with_file = new_file_name
                return problem_with_file
            
           
    def exchange_photoshop_names_plus_export(self,file_to_convert, new_file_name,do_both):
        
        
        #relative path of all script files and put out the art to new locations
        current_script_path = os.path.dirname(os.path.realpath(__file__))
        if (do_both == True):
            javascript_file_export = os.path.realpath(os.path.join(current_script_path,'..','photoshop_scripts','photoshopExportToolResize.jsx'))
        elif (do_both == False):
            javascript_file_export = os.path.realpath(os.path.join(current_script_path,'..','photoshop_scripts','photoshopExportTool.jsx'))
        else:
            print "why?"
        
        psd_export_folder = os.path.realpath(os.path.join(os.path.split(file_to_convert)[0],'..','Exported'))
        
        location_of_temp = self._make_temp_folder(psd_export_folder)
        new_file_name = os.path.join(psd_export_folder,new_file_name+".psd")
        
        
        
        #sends for conversion
        self._windows_jsx_file_prep(file_to_convert, javascript_file_export, location_of_temp, new_file_name,False,self.photoshop)     
        
        
    def run_check_for_linear_dodge(self,file_to_convert):
        current_script_path = os.path.dirname(os.path.realpath(__file__))
        for file_for_splitting in file_to_convert:
            
            file_split = file_for_splitting.split(os.sep)
            
            file_name = file_split.pop(-1)
            
            file_split = ('/').join(file_split)
            
            possible_export_location = os.path.realpath(os.path.join(file_split, "..", "broken", file_name))
            possible_export_folder = os.path.realpath(os.path.join(file_split, "..", "broken"))
            art_export_folder = os.path.realpath(os.path.join(os.path.split(file_for_splitting)[0],'..','Optimized'))
            location_of_temp = self._make_temp_folder(art_export_folder)
    
            line = ('var DocToOpen = ["filler","%s",%s];')%(file_for_splitting,possible_export_location)
            
            make_linear = os.path.realpath(os.path.join(current_script_path,'..','photoshop_scripts','photoshop_linear_dodge_batch.jsx'))
            
            self._windows_jsx_file_prep(file_for_splitting, make_linear, location_of_temp, possible_export_location, False, self.photoshop)  
            
            
            folder = self._make_temp()
            file_to_use = os.path.join(folder, "BrokedFiles.txt")
            
            target = open(file_to_use, 'w+')
            
        for root, dirs, files in os.walk(possible_export_folder):
            for individual_file in files: 
                target.write(str(individual_file))
         
         
    def make_resized_art(self,file_to_convert):
      
        #relative path of all script files and put out the art to new locations
        current_script_path = os.path.dirname(os.path.realpath(__file__))
        javascript_file_export = os.path.realpath(os.path.join(current_script_path,'..','photoshop_scripts','photoshopExportTool_Resize_new.jsx'))
        
        psd_export_folder = os.path.realpath(os.path.join(os.path.split(file_to_convert)[0],'..','Converted'))
          
        location_of_temp = self._make_temp_folder(psd_export_folder)
        new_file_name = os.path.join(psd_export_folder,os.path.split(file_to_convert)[-1])
        
        if not(os.path.exists(new_file_name)):
        #sends for conversion
            self._windows_jsx_file_prep(file_to_convert, javascript_file_export, location_of_temp, new_file_name,False,self.photoshop)
      
    
    def check_ae_names(self,file_name,new_file_name,everything):
        
        
        #goes through and checks that the name of the shot vs the name of the file.  if it's good then it returns the name ect and if not then it tells it's a problem
        file_name_to_test = file_name.split('_')[-1]
        file_name_to_test = file_name_to_test.split('.aep')[0]
        last = 0
        for key in everything:
            last+=1
            
            dictonary_name_to_split = everything[key]["Shot"].split('_')
            combined_dictonary_name_split = []
            first_split = dictonary_name_to_split[0][1:]
            try:
                second_split = dictonary_name_to_split[1][1:]
                combined_dictonary_name_split.append(first_split)
                combined_dictonary_name_split.append(second_split)
                combined_dictonary_name = '-'.join(combined_dictonary_name_split)
                if file_name_to_test in combined_dictonary_name:
                    dict_of_old_new = {file_name_to_test:combined_dictonary_name}
                    return dict_of_old_new,file_name
            
                elif not(file_name_to_test in combined_dictonary_name) and (last == len(everything)):
                    problem_with_file = new_file_name
                    return problem_with_file
            except:
                pass
        
        
    def exchange_ae_names_plus_comp_test(self,file_to_convert, new_file_name,everything):
        
        #goes into the comps and starts after effects and will export json of the comps in the file. checks them aginst the dictoanry for export
        current_script_path = os.path.dirname(os.path.realpath(__file__))
        
        check_comps = os.path.realpath(os.path.join(current_script_path,'..','AfterEffects_Scripts','AfterEffectsCompTester.jsx'))
        
        exchange_pngs = os.path.realpath(os.path.join(current_script_path,'..','AfterEffects_Scripts','AfterEffects_ExchangePNGs_batch.jsx'))
        
        all_times = os.path.realpath(os.path.join(current_script_path,'..','AfterEffects_Scripts','AfterEffects_JSONer_all_times_batch.jsx')) 
        
        xmler = os.path.realpath(os.path.join(current_script_path,'..','AfterEffects_Scripts','AfterEffectsXMLer_batch.jsx'))
        
 
        art_export_folder = os.path.realpath(os.path.join(os.path.split(file_to_convert)[0],'..','Backup'))
        location_of_temp = self._make_temp_folder(art_export_folder)
        json_file_name = os.path.join(location_of_temp,"comp_to_use.json")
        new_file_name = os.path.join(art_export_folder,new_file_name+".aep")

        #export out the comps so we can loop over them later
        self._windows_jsx_file_prep(file_to_convert, check_comps, location_of_temp, new_file_name,True,self.after_effects)
        
        #Setup for the Export out the JSON for the entire master comp
        master_comp = self._get_master_comp(json_file_name, everything)
        
        if master_comp == False:
            pass
        
        elif not(master_comp == False):
            files_to_work_on = self._get_the_comps(json_file_name,everything,False)
            
            #switches the psds to pngs
            #self._windows_jsx_file_prep(file_to_convert, exchange_pngs, location_of_temp, files_to_work_on, False, self.after_effects)
            
            #Export out the JSON for the entire master comp
            self._windows_jsx_file_prep(file_to_convert, all_times, location_of_temp, master_comp, False, self.after_effects)
            
            #Final Export of all the actual JSON and xml data.  THIS TAKES FOREVER turn off for debugging of scripts... This script RARELY breaks.
            self._windows_jsx_file_prep(file_to_convert, xmler, location_of_temp, files_to_work_on,False,self.after_effects)
        
        else:        
            pass
        
        
        
    def anchor_point_fix(self,file_to_convert,new_file_name,everything):
        
        #goes into the comps and starts after effects and will export json of the comps in the file. checks them aginst the dictoanry for export
        current_script_path = os.path.dirname(os.path.realpath(__file__))
        
        check_comps = os.path.realpath(os.path.join(current_script_path,'..','AfterEffects_Scripts','AfterEffectsCompTester.jsx'))  
        
        fix_piviot_points = os.path.realpath(os.path.join(current_script_path,'..','AfterEffects_Scripts','AfterEffects_Anchor_Point_batch.jsx'))
 
        art_export_folder = os.path.realpath(os.path.join(os.path.split(file_to_convert)[0],'..','Backup'))
        
        location_of_temp = self._make_temp_folder(art_export_folder)
        json_file_name = os.path.join(location_of_temp,"comp_to_use.json")
        new_file_name = os.path.join(art_export_folder,new_file_name+".aep")

        #export out the comps so we can loop over them later
        self._windows_jsx_file_prep(file_to_convert, check_comps, location_of_temp, new_file_name,True,self.after_effects)

        files_to_work_on = self._get_the_comps(json_file_name,everything,False)
        
        #switches the psds to pngs
        shutil.copy(file_to_convert,location_of_temp) 
        self._windows_jsx_file_prep(file_to_convert, fix_piviot_points, location_of_temp, files_to_work_on, False, self.after_effects)
             
                                 
    def populate_null_pngs(self,null_png):
        # put in your local folder that you want to put the files in
        directory_to_check_split = (os.path.split(null_png)[0])
        directory_to_check = (os.path.split(directory_to_check_split)[0])
        for root,dirs,files in os.walk(directory_to_check):
                    
            #if you need some other file put in then say so here
            file_to_check_for = "Null.png"
            for directory in dirs:
                file_foler = os.path.join(root,directory)
                files_in_dir = listdir(file_foler)
                if not(file_to_check_for in files_in_dir):
                    # this is the location of some png you need.  If you want to copy a different one then just say so... just reemmber that you need to change the file_to_check variable too!
                    shutil.copy(null_png,(os.path.join(file_foler,file_to_check_for))) 

     
    def _make_temp_folder(self, art_export_folder):
        #makes tmp folder for use to use throughout the files
        if self.platform == 'nt':
            home_location = os.path.expanduser("~")
        else:
            home_location = os.getenv("HOME")
            
        location_of_temp = os.path.join(home_location,"wild_blue_temp")
        if not (os.path.exists(location_of_temp)):
            os.makedirs(location_of_temp)
        
        
        if not (os.path.exists(art_export_folder)):
            os.makedirs(art_export_folder)
        
        return location_of_temp
                    
                     
    def _make_temp(self):
                
        #specific one that is used for the purpose of making a txt file 
        if self.platform == 'nt':
            home_location = os.path.expanduser("~")
        else:
            home_location = os.getenv("HOME")
            
        location_of_temp = os.path.join(home_location,"wild_blue_temp")
        if not (os.path.exists(location_of_temp)):
            os.makedirs(location_of_temp)
        
        return location_of_temp


    def _line_for_photoshop(self, file_to_convert, add_new_file):
        #header for the jsx in photoshop
        line = 'var DocToOpen = ["filler","%s","%s"]\nmain(DocToOpen[1],DocToOpen[2]);'%(file_to_convert,add_new_file)
        return line
        
            
    def _get_the_comps(self,json_file_name,everything,is_master_flag):
        #looks through the json that was created before that holds all the comps so we can export them for automation use    
        with open(json_file_name) as json_data:
            data_to_use = json.load(json_data)
            json_data.close()
        
        scene_names = []
        for x in range(0,len(data_to_use),2):
            scene_names.append(str(data_to_use[x]))
            
        id_names = []
        for x in range(1,len(data_to_use),2):
            id_names.append(data_to_use[x])
            
        data_to_use = (dict(zip(scene_names,id_names)))
        
        new_list_of_data = []  

        for key in data_to_use.iteritems():
            try:
                everything[key[0]]
                new_list_of_data.append(key[1])
            except KeyError:
                pass

        return new_list_of_data
    
    
    def _get_master_comp(self,json_file_name,everything):
        with open(json_file_name) as json_data:
            data_to_use = json.load(json_data)
            json_data.close()
        
        scene_name = data_to_use[0]    
        
        try:
            everything[scene_name[0]]
            id_name = data_to_use[1]
            return id_name
        except KeyError:
            is_broke=False
            return is_broke
        
        
    def _line_for_check_ae(self,file_to_convert,add_new_file,location_of_temp):
        #first like for the check jsx
        comps_to_use = os.path.join(location_of_temp,'comp_to_use.json')
        comps_to_use = comps_to_use.replace('\\','/')
        if not (os.path.exists(comps_to_use)):
            the_file = open(comps_to_use,"w+")
            the_file.close()
        line = ('var DocToOpen = ["%s","%s","%s"];')%(file_to_convert,comps_to_use,add_new_file)
        return line
    
    
    def _run_conversion_ae(self,file_to_convert, name_of_comps):
        #first line for the run jsx
        line = ('var DocToOpen = ["filler","%s",%s];')%(file_to_convert,name_of_comps)
        return line
    
    
    def _run_all_time_ae(self,file_to_convert,parent_comp):
        #first line to run jsx of AE all time conversion
        line = ('var DocToOpen = ["filler","%s",%s];')%(file_to_convert,parent_comp)
        return line


    def _run_exchange_pngs(self,file_to_convert, name_of_comps):
        #first line to run jsx of AE all time conversion
        line = ('var DocToOpen = ["filler","%s",%s];')%(file_to_convert,name_of_comps)
        return line
   
    
    def _line_prepender(self,javascript_file_name,line):
        #not really used anymore.... it's just in case we want to keep photoshop open between converted psds ect....
        with open(javascript_file_name,'r+') as f:
            content = f.read()
            content = content.encode('utf8','replace')
            f.seek(0,0)
            f.write(line.rstrip('\r\n') + '\n' + content)
    

    def _windows_jsx_file_prep(self,file_to_convert, java_script_file_name, location_of_temp, new_file,check,program):
                
        #lets us convert the jsx files for photoshop and AE so we can send it to them static with the name of the files we want to do work on ect.
        #commented files are left in if we ever want to multiprocess the photoshop files at this point it closes and opens photoshop each time... slows it down but clears memory each time
        if self.platform == "nt":
            file_to_convert = file_to_convert.replace('\\','/')
        
        
        if (check) and (program == self.after_effects):
            if self.platform == "nt":
                add_new_file = new_file.replace('\\','/')
            else:
                add_new_file = new_file
            line = self._line_for_check_ae(file_to_convert, add_new_file, location_of_temp)
        elif not(check) and (program == self.after_effects):
            sleep(3)
            line = self._run_conversion_ae(file_to_convert,new_file)
        elif program == self.photoshop:
            if self.platform == "nt":
                add_new_file = new_file.replace('\\','/')
            else:
                add_new_file = new_file
            line = self._line_for_photoshop(file_to_convert,add_new_file)
        
        javascript_file_name_split = java_script_file_name.split('.')
        
        end_file = javascript_file_name_split[-2] + "_temp.jsx"
        end_file = os.path.join(location_of_temp,os.path.split(end_file)[-1])
        
        #Adds this to the end of the javascript in program so that the file modifys the temp file breaking the loop
        end_of_file = ''
        """
        end_of_file =('var TempFileName = "%s";'+
        '''
        var StuffToPutIntoFile = "yup";
        FileOut = File(TempFileName);
        FileOut.open("w");
        FileOut.writeln(String(StuffToPutIntoFile));
        FileOut.close();
        ''')%(temp_file_to_modify)
        """
        
        
        if os.path.exists(end_file):
            os.remove(end_file)
        shutil.copy(java_script_file_name,end_file)
        time.sleep(0.1)
        
        #add to the beginning of the temp file the name of the file to run
        self._line_prepender(end_file,line)
        
        
        with open(end_file,'a') as opened_file:
            
            end_of_file = end_of_file.encode('utf8','replace')
            opened_file.write(end_of_file)
        
        #sends the jsx files to the correct program
        if program == self.after_effects:
            if self.platform == "nt":
                subprocess.call([program,"-r",end_file])
            else:
                applescript_command =("""tell application "%s"
                  with timeout of 8100 seconds
                    DoScriptFile "%s"
                  end timeout
                  end tell""")%(program,end_file)
                applescript_name = (os.path.splitext(end_file)[0]+'.scpt')
                applescript_name = os.path.join(location_of_temp,os.path.split(applescript_name)[-1])
                self.make_applescript(applescript_name, applescript_command)
                time.sleep(0.3)
                subprocess.call(["osascript",applescript_name])
        if program == self.photoshop:
            if self.platform == "nt":
                subprocess.call([program,end_file])
            else:
                applescript_command =("""tell application "%s"
                  with timeout of 8100 seconds
                    do javascript (file "%s")
                  end timeout
                  end tell""")%(program,end_file)
                applescript_name = (os.path.splitext(end_file)[0]+'.scpt')
                applescript_name = os.path.join(location_of_temp,os.path.split(applescript_name)[-1])
                self.make_applescript(applescript_name, applescript_command)
                time.sleep(0.3)
                subprocess.call(["osascript",applescript_name])
                

    def make_applescript(self,applescript_name, applescript_command):
        #well... we make applescripts and stuff this is for those people who paid too much for their computer.......
        if os.path.exists(applescript_name):
            os.remove(applescript_name)
        with open(applescript_name,'w+') as f:
            f.write(applescript_command)