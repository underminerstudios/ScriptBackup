import os
import shutil


class intermediateFunctions(object):

    def __init__(self, prodLocation, bingoAssetsFolder, roomNumber,IsSlots):
        """Does the actual work of moving art from one location to another and giving different names. It also returns the issue to the user if there is a problem."""
        
        self.prodLocation = prodLocation
        self.bingoAssetsFolder = bingoAssetsFolder
        self.roomNumber = roomNumber
        self.isSlots = IsSlots
                
    def makeStuff(self,BINGOASSETSFolderName,PRODBKLGFolderName,EndsWith,FileName,Problem,*args):
        """Helper function that does all the heavylifting of name checking and file movement"""
        
        #Helper for above. Call Run Movement and it will do everything you need
        # Ends with this will turn a ends with to a starts with.
        try:
            newLocation = os.path.join(self.bingoAssetsFolder,BINGOASSETSFolderName)
            
            # if the prod folder is empty expect that the relative path is the same for both locations
            if (PRODBKLGFolderName == ""):
                PRODBKLGFolderName = BINGOASSETSFolderName 
            oldLocation = os.path.join(self.prodLocation,PRODBKLGFolderName)
            
            #get all the files in the folder
            getAllFiles = os.listdir(oldLocation)
            
            #loop through the files
            for getAllFile in getAllFiles:
                
                #if he have a bingo game on our hands do the following
                if not(self.isSlots == True):
                    
                    #the arts is for ends with or starts with.  If it ends with look at hte end of the file
                    if args[0] == True:
                        
                        if getAllFile.endswith(EndsWith):
                            oldFileName = getAllFile
                            newFileName = FileName
                    
                    #if it starts with and the name starts with the game name (per this naming convention) then it's good
                    elif args[0] == False:
                        if getAllFile.startswith(EndsWith) and getAllFile.endswith(self.GameFileNameNASWF):
                            oldFileName = getAllFile
                            newFileName = FileName
                
                #if we have a slots game do the following
                else:
                    if getAllFile.endswith(EndsWith):
                            oldFileName = getAllFile
                            newFileName = FileName
            try:
                #try to copy the files and if the new file exists kill it.
                newFile = os.path.join(newLocation,newFileName)
                
                if os.path.exists(newFile):
                    os.remove(newFile)
                shutil.copy(os.path.join(oldLocation,oldFileName), os.path.join(newLocation,newFileName))
                
                return ""
            
            except:
                # if it doesn't work then just tell everyone there's a problem.
                newProblem = Problem + " Does not Exist!!!"
                return newProblem
        except:
            return Problem
        
        
   

    def getThebroken(self,whatsBroken):
        """This one loops through the files and appends the issue to a list so we can display them.  If there is no issue we display nothing"""
        
        newWhatBroken = []
        for whatbroken in range(0,len(whatsBroken)):
            if not(whatsBroken[whatbroken] == '') and not(whatsBroken[whatbroken] == None):
                newWhatBroken.append(whatsBroken[whatbroken])
        
        whatsBroken = ", ".join(newWhatBroken)
        
        return whatsBroken