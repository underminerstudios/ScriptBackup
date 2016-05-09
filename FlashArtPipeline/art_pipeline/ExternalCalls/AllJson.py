import json
import os


class jsonMakers(object):
   

    def __init__(self): 
        """Does all work with jsons. Makes them and gets information from them"""
        pass
        
    def removeJsonFile(self,json_file):
        """Removes old Json File"""
        
        if os.path.exists(json_file):
            os.remove(json_file)
        
    def makeSettings(self,jsonInfo,json_file):
        """Makes New Json information"""
        
        with open(json_file,"a") as jsoner:
            json.dump(jsonInfo, jsoner,sort_keys = True, indent=4,ensure_ascii=False,separators=(",",": "))
        
    def getFolderInfo(self,temp_location,jsonDataName):
        """Takes the location of the json file and json data name and returns it's value"""
        
        AssetFolder = self._get_info_from_setup_file(temp_location,jsonDataName)
        return AssetFolder
    
    def _get_info_from_setup_file(self,TheJsonFile,jsonDataName):
        # brings in the info from the setup file for use.
        
        if os.path.exists(TheJsonFile):
            with open(TheJsonFile) as json_file:
                json_datas = json.load(json_file)
                
                # look through the data for the key we need.
                for json_data in json_datas:
                    try:
                        folderLocation = json_data[jsonDataName]
                    except:
                        pass
            return folderLocation
        
        else:
            #if the keyvalue is not found return false so we can tell the user there is something wrong.
            folderLocation = False
            return folderLocation
        
    