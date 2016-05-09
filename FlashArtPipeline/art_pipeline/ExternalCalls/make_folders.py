import os
import shutil

class make_all_folders(object):
    
    
    def __init__(self):
        """Need a folder? This makes it. Don't like the folder you got... take care of it. This initalizes with make temp running because everything else counts on this folder."""
        self.make_temp()
        pass
    
    
    def make_temp(self):
        """Makes the tmp folder location.  Pretty awesome thing is it also feeds back the location to all the scripts. No hard coding here. ***Does not delete the folder***"""
        
        #be we windows or be we mac?
        if (os.name == 'nt'):
            location_of_home = os.path.expanduser("~")
        else:
            location_of_home = os.getenv("HOME")
                
        temp_location = os.path.join(location_of_home, "chips")
        
        self.makeFolders(temp_location)
        
        #nice return for every other script to use. What's the location we need to write to? Boom!
        return temp_location
            
    
    def sound_export_folder(self,sound_folder):
        """Makes the sound folders"""
        
        #need to take the sounds and they need to follow the current folder structure?
        converted_sound_folder = os.path.realpath(os.path.join((sound_folder,"..")))
        
        self.makeFolders(converted_sound_folder)
            
    
    def setupSlotsArtFolders(self,slotsFolder,gameName):
        """This is for making the new templates for slots games.  Makes sure we follow the naming convention"""
        self.removeFolders(os.path.join(slotsFolder,gameName))
        foldersToMake = ['Achievements',"cityBackgrounds","cityTitle","etc",
                         "Facebook",'Postcards','scatter','slotsBigWheel',
                         'slotsSymbols','slotsUI','trophy',"backgrounds","Movs"]
        
        for artFolder in foldersToMake:
            self.makeFolders(os.path.join(slotsFolder,gameName,artFolder))
            

    def makeFolders(self,folderToMake):
        """make folder helper function"""
        if not(os.path.exists(folderToMake)):
            os.makedirs(folderToMake)
            
    def removeFolders(self,folderToDelete):
        """Removes the full tree function. This means EVERYTHING from the folder you tell it to on down"""
        if os.path.exists(folderToDelete):
            shutil.rmtree(folderToDelete, ignore_errors=True)
