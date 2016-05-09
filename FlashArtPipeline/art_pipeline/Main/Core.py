import os
import subprocess
import shutil
from Sounds.Sound_Converter import Sound_Converter
from ExternalCalls.make_folders import make_all_folders
from ExternalCalls.AllJson import jsonMakers
from ExternalCalls.SlotsOldConversion import MoveSlotsOldConversion
from Main.NewSlotsRoom import newCitySetup
from ExternalCalls.BingoConversion import MoveBingo
from ExternalCalls.SlotsNewConversion import MoveSlotsNewConversion
from Main.Jsx_Conversion import JsxConverter



class worker(object):
    
    def __init__(self):
        """Ok this does pretty much everything. This is the thing that is the intermetiery between actual processes and the UI"""
        
        self.templatesFolder = os.path.join(os.path.dirname(__file__),"..","Templates","SlotsTemplate")
        self.temp_location = make_all_folders().make_temp()    
        self.json_file = os.path.join(self.temp_location,"setup.json") 
        self.platform = os.name
        self.setup = make_all_folders()
        
        #this is hard coded ATM it will be fixed soon enough with a computer check and placed in a settings folder
        if self.platform == "nt":
            self.photoshop = r"C:\Program Files\Adobe\Adobe Photoshop CC 2015\Photoshop.exe"
            self.flash = r"C:\Program Files\Adobe\Adobe Flash CC 2015\Flash.exe"
            self.illustrator = r"C:\Program Files (x86)\Adobe\Adobe Illustrator CS5.1\Support Files\Contents\Windows\Illustrator.exe"
    
    def run_setup(self,*args):
        """runs the setup of the json file and the folders needed"""
        MakeJson = jsonMakers()
        MakeJson.removeJsonFile(self.json_file)
        jsonNameargs = []
        folderLocation = []
        
        #this is pretty cool. When someone puts in 2 args (the first being the key in the json and the second being the folder location I split the origonal list into two for
        #use below making the json
        for arg in range(1,len(args),2):
            if os.path.isdir(str(args[arg])):
                jsonNameargs.append(args[arg-1])
                folderLocation.append(args[arg])
        
        #this loops through the json and makes and appended list with a dictonary in each for a json to read.
        jsonInfo = [] 
        for jsonNamearg in range(0,len(jsonNameargs)):
            jsonInfo.append({jsonNameargs[jsonNamearg]: folderLocation[jsonNamearg]})
        
        #runs the info to the json maker and the file name of the json to it as well.
        MakeJson.makeSettings(jsonInfo,self.json_file)

            
    def getFolderAndMoveStuff(self,GameFolderLocationInfo,RoomNumber,conversionType):
        """Gets the json information from the folder info so we know the location of the final art then it runs the conversion from the artists location
        to the producer's location based on the selection"""
        
        # we get the folder info from the json fileand save it for later use
        FolderInfo = jsonMakers()
        AssetsFolder = FolderInfo.getFolderInfo(self.json_file,"Bingo Assets Folder")
        
        #check the bingo assets folder and if returned a location keep going.
        if not(AssetsFolder == False):
            
            ###
            #These all return broken files or nothing if it's good to go.
            ###
            
            #does the converson for the old slots games
            if conversionType == "SlotsOld":
                runMovement = MoveSlotsOldConversion(GameFolderLocationInfo,AssetsFolder,RoomNumber)
                brokenFiles = runMovement.runMovement()
                return brokenFiles
            
            #does the conversion for new naming convention of the slots
            elif conversionType == "SlotsNew":
                rotelle = False
                runMovement = MoveSlotsNewConversion(GameFolderLocationInfo, AssetsFolder, RoomNumber, rotelle)
                brokenFiles = runMovement.runMovement()
                return brokenFiles
            
            # does a conversion for the new rotelle 
            elif conversionType == "Rotelle":
                rotelle = "New"
                runMovement = MoveSlotsNewConversion(GameFolderLocationInfo, AssetsFolder, RoomNumber, rotelle)
                brokenFiles = runMovement.runMovement()
                return brokenFiles
            
            # does an old rotelle
            elif conversionType == "RotelleConversion":
                rotelle = "Old"
                runMovement = MoveSlotsNewConversion(GameFolderLocationInfo, AssetsFolder, RoomNumber, rotelle)
                brokenFiles = runMovement.runMovement()
                return brokenFiles
            
            # does a bingo conversion.
            elif conversionType == "Bingo":
                runMovement = MoveBingo(GameFolderLocationInfo,AssetsFolder,RoomNumber)
                brokenFiles = runMovement.runMovement()
                return brokenFiles
            
        #if we didn't return a location but false return and make a popup later saying.. hay your setup needs help.
        elif AssetsFolder == False:
            return AssetsFolder
        
    
        
    def setupSlotsRoom(self,cityName,cityType,Rotelle,*args):
        """This makes new citys for slot rooms"""
        
        FolderInfo = jsonMakers()
        slotsFolder = FolderInfo.getFolderInfo("Slots Assets Folder")
        
        #if the return from the json is good to go then get the core game elements and move the files
        if not(slotsFolder == False):
            CoreElements = newCitySetup(cityName,self.templatesFolder,slotsFolder,Rotelle)
            FilesToFindList = CoreElements.getCoreElements()
            
            ###
            #Wating for new templates.
            ###
            
            '''
            if cityType == 1:
                FilesToFindList.update(CoreElements.theamed())
                
            elif cityType == 2:
                FilesToFindList.update(CoreElements.pickTillYouPoop(args[0]))
            
            elif cityType == 3:
                FilesToFindList.update(CoreElements.fixedPick(args[0]))
            
            elif cityType == 4:
                FilesToFindList.update(CoreElements.freeSpin())
            
            elif cityType == 5:
                FilesToFindList.update(CoreElements.modified())
            '''
            
            CoreElements.makeLayout(FilesToFindList)
            
        #if it's false tell the user that something bad happened with their setup and they need to run it again.   
        elif slotsFolder == False:
            return slotsFolder
    
    def find_the_sounds(self,location):
        """Get the info back from the make sounds file you create and tell people what's gone on by putting them in a text file"""
        
        #get all the sounds in the source folders
        file_output = os.path.join(self.temp_location,"missing_sounds.txt")
        sounds = Sound_Converter()
        all_of_mp3,all_of_wav = sounds.get_all_the_source_sounds(location)
        
        
        # Look at the mp3 named objects and put them and their location into a list
        mp3_file_names = []
        for mp3_sound in all_of_mp3:
            file_remove = os.path.split(mp3_sound)[0]
            if not(os.path.split(file_remove)[-1] == "source"):
                mp3_file_names.append(os.path.join(os.path.split(mp3_sound)[0],os.path.splitext(os.path.split(mp3_sound)[-1])[0]))
                
        #look at the wav files and get their name and location
        wav_file_names = []
        for wav_sound in all_of_wav:
            file_remove = os.path.split(wav_sound)[0]
            if os.path.split(file_remove)[-1] == "source":
                wav_file_names.append(os.path.join(os.path.split(file_remove)[0],os.path.splitext(os.path.split(wav_sound)[-1])[0]))
        
        #sort the wav files so everything is in order then loop through them then look to see if it's in the list of mp3 files if so remove the wav sound from the mp3 list
        #this is done so we can find out what is not converted yet
        wav_file_names.sort()      
        for wav_sound in wav_file_names:
            if wav_sound in mp3_file_names:
                mp3_file_names.remove(wav_sound)
                      
        #open the file and put in all the mp3 file names so we know what's missing
        with open(file_output,"a+") as the_file:
            for missing_sound_file_name in mp3_file_names:
                the_file.write(missing_sound_file_name + "\n")   

    def fix_the_sounds(self,location):
        
        """this runs the fixing of the sounds file.  Converts files from MP3 to wav"""
        location = "C:\Sounds\slotSoundsZIP"
        sounds = Sound_Converter()
        the_sounds = sounds.get_all_the_sounds(location)
        
        #this loops through the sounds and fixes them appending them into a list we can copy
        sounds_info = []
        for sound in the_sounds:
            sounds_info.append(sounds.convert_the_sounds(sound))
            
    def MakeUITeamConversion(self,TheFiles,TheOutPutFolder):
        """Just started this but it makes all the files for the ui team conversion so they can get all the art out of the flash files and make some atlases"""
        jsonMakerClass = jsonMakers()
        JsflLocation = os.path.join(os.path.dirname(__file__), '..',"Flash","ExportOutTheUI.jsfl")
        
        convertion = JsxConverter()
        TempJavascript = convertion.makeJavascriptConversion(self.temp_location,"Flash", JsflLocation, TheFiles)
        subprocess.call([self.flash,TempJavascript])
            
            
            
    def MakeAllMap(self,RunType,RunAll):
        """This gets all the files and folders ready for us to make the origonal art. Png exports etc"""
        jsonMakerClass = jsonMakers()
        JsflLocation = os.path.join(os.path.dirname(__file__), '..',"Flash","makeAllMap.jsfl")
        
        if RunType == "Bingo":
            folderOfArt = os.path.join(jsonMakerClass.getFolderInfo(self.json_file,"Prod Backlog Folder"),'BB',"Rooms","Lobby Map","background","BingoMap")
        
        else:
            pass
        
        artFiles = []
        
        #finds all the flas in the folder and then converts the jsfl file with those files and calls flash on that jsfl file.
        for filesOfArt in os.listdir(folderOfArt):
            if filesOfArt.endswith(".fla"):
                artFiles.append(os.path.join(folderOfArt,filesOfArt))
        convertion = JsxConverter()
        TempJavascript = convertion.makeJavascriptConversion(self.temp_location,"Flash", JsflLocation, artFiles)
        subprocess.call([self.flash,TempJavascript])

        
    def makeAllMapAtlases(self,RunType,RunAll):
        
        """This makes all the atlases and folders for the art the whole final section from getting the art"""
        
        jsonMakerClass = jsonMakers()
        allArt = {}
        
        # if the user selects run all then run everything
        if RunAll == True:
            
            #if it's a bingo map they want then do this
            if RunType == "Bingo":
                
                #Make the folders of all the art locations.
                folderOfArt =  os.path.join(jsonMakerClass.getFolderInfo(self.json_file,"Prod Backlog Folder"),'Bingo Blitz',"Rooms","Lobby Map","background","BingoMap")
                EndFolder = os.path.join(jsonMakerClass.getFolderInfo(self.json_file,"Prod Backlog Folder"),"UnityMapArt")
                UnityMapArt = os.path.join(jsonMakerClass.getFolderInfo(self.json_file,"BB Unity Art Folder"),"TextureBundler","Assets","TexturesToBundle","textures_x2","lobby","bingo_map")

                #look in the folder where the art is and get all the files in there
                ArtsInFolder = os.listdir(folderOfArt)
                
                for artinfolder in ArtsInFolder:
                    
                    #if the art is what we are looking for then split the name and make a dictonary with the folder name as the key which will make it where if we have multiple
                    #files of the same location they will be merged into one... gotta love dicts
                    if artinfolder.startswith("bingo_map"):
                        if artinfolder.endswith(".png"):

                            NewFolderName = artinfolder.split("_")
                            NewFolderName = NewFolderName[0] + "_" + NewFolderName[1] + "_" + NewFolderName[2]
                            FinalFolderName = os.path.join(EndFolder,NewFolderName)
                            batFolder = os.path.join(EndFolder,NewFolderName,"batFile")
                            TexturePackerJsonFolder = os.path.join(EndFolder,NewFolderName,"TexturePackerJson")
                            AtlasFolder = os.path.join(EndFolder,NewFolderName,"AtlasFolder")
                            AssetsPngsFolder = os.path.join(EndFolder,NewFolderName,"Pngs","Assets")
                            MapPngsFolder = os.path.join(EndFolder,NewFolderName,"Pngs","MapSlices")
                            JsonFolder = os.path.join(EndFolder,NewFolderName,"Json")
                            PsdFolder = os.path.join(EndFolder,NewFolderName,"PSDs")
                            
                            
                            allArt.update({NewFolderName:[FinalFolderName,batFolder,TexturePackerJsonFolder,AtlasFolder,AssetsPngsFolder,MapPngsFolder,JsonFolder,PsdFolder]})     
                            
                            
                folderMaker = make_all_folders()
                
                #go through the key and make all the folders if they don't exist and kill the old ones that do and then make them
                for key in allArt.iterkeys():
                    for x in range(0,len(allArt[key])):
                        folderMaker.removeFolders(allArt[key][x])
                        folderMaker.makeFolders(allArt[key][x])

                #loop through the art folder again and start finding the map art
                for artinfolder in ArtsInFolder:
                    if artinfolder.startswith("bingo_map"):
                        startFileName = os.path.join(folderOfArt,artinfolder)
                        
                        if artinfolder.endswith(".png"):
                            
                            #loop through the dictonary and match up the art name with the final location
                            for key in allArt.iterkeys():
                            
                                FolderNumberSplit = artinfolder.split("_")
                                FolderNumberSplit = FolderNumberSplit[0] + "_" + FolderNumberSplit[1] + "_" + FolderNumberSplit[2]
                                if FolderNumberSplit == key:

                                    #If it's the bingo map section then run the split map photoshop script and put it in the final location.
                                    if artinfolder.endswith("bg.png"):
                                        endFileLocation = allArt[key][5]
                                        shutil.move(startFileName,endFileLocation)
                                        makeMapSlices = JsxConverter()
                                        JsxLocation = os.path.realpath(os.path.join(os.path.dirname(__file__), '..',"Photoshop","makeSplitMap.jsx"))
                                        fileToConvertSplit = os.path.split(startFileName)[-1]
                                        fileToConvert = os.path.join(endFileLocation,fileToConvertSplit)
                                        TempJavascript = makeMapSlices.makeJavascriptConversion(self.temp_location, "Photoshop", JsxLocation, fileToConvert)
                                        subprocess.call([self.photoshop,TempJavascript])
                                        FinalEndLocation = os.path.join(UnityMapArt,FolderNumberSplit)
                                        shutil.copy2(fileToConvert,FinalEndLocation)
                                        
                                    #if the art is not the map background then move the art to the generated folder and put it in the correct final art folder for making atlases later
                                    elif not(artinfolder.endswith("bg.png")):
                                        endFileLocation = allArt[key][4]
                                        shutil.copy2(startFileName,endFileLocation)
                                        NewLocation = os.path.join(os.path.split(startFileName)[0],"Generated")
                                        folderMaker.removeFolders(NewLocation)
                                        folderMaker.makeFolders(NewLocation)
                                        shutil.move(startFileName,NewLocation)
                    
                        #if it's a json file move it to the generated folder and put it in the final location for the devs to use.
                        elif artinfolder.endswith("json"):
                            for key in allArt.iterkeys():
                            
                                FolderNumberSplit = artinfolder.split("_")
                                FolderNumberSplit = FolderNumberSplit[0] + "_" + FolderNumberSplit[1] + "_" + FolderNumberSplit[2].replace(".json","")
                                if FolderNumberSplit == key:
                                    endFileLocation = allArt[key][6]
                                    shutil.copy(startFileName,endFileLocation)
                                    NewLocation = os.path.join(os.path.split(startFileName)[0],"Generated")
                                    folderMaker.removeFolders(NewLocation)
                                    folderMaker.makeFolders(NewLocation)
                                    FinalEndLocation = os.path.join(UnityMapArt,FolderNumberSplit)
                                    shutil.copy(startFileName,FinalEndLocation)
                                    shutil.move(startFileName,NewLocation)
                
                #for each key make a tps file which runs texture packer and start the texture packer process. It also copys the file to the new location.                      
                for key in allArt.iterkeys():                              
                    FileLocations = self.makeTPS(allArt[key][1], key, allArt[key][2], allArt[key][3], allArt[key][4])
                    for FileLocation in FileLocations:
                        NewLocation = os.path.join(UnityMapArt,key)
                        shutil.copy2(FileLocation,NewLocation)
                                
    def makeTPS(self,batFolder,newFolderName,JsonFolder,AtlasFolder,AssetsPngsFolder): 
        
        """This makes all the tps files bat files to run and exports all the final jsons to go to their correct location"""
        
        for filename in os.listdir(AssetsPngsFolder):
            if filename.startswith("bingo_map"):
                fileNameSplit = filename.split("_")
                newfilename = "_".join(fileNameSplit[3:])
                old = os.path.join(AssetsPngsFolder,filename)
                new = os.path.join(AssetsPngsFolder,newfilename)
                os.rename(old, new)
        batFile = os.path.join(batFolder,newFolderName + ".bat")
        JsonFile = os.path.join(JsonFolder, newFolderName + "_sprites.json")
        AtlasFile = os.path.join(AtlasFolder, newFolderName + "_sprites.png")
        
        # this is what makes all the texture packer information. Change this with care.
        texturePackerGuts = ('--format json-array ' + '--max-size 4096 ' + '--size-constraints POT ' + '--force-publish ' + '--trim-mode Trim ' + '--disable-rotation ' + '--trim-sprite-names ' + '--force-squared ')
        masterFileGuts = ('"C:\\Program Files\\CodeAndWeb\\TexturePacker\\bin\\TexturePacker.exe" %s --data %s --sheet %s %s')%(texturePackerGuts,JsonFile,AtlasFile,AssetsPngsFolder)
        
        batfilewrite = open(batFile, 'w+')
        batfilewrite.write(masterFileGuts)
        batfilewrite.close()
        
        if os.name == ("nt"):
            os.chdir(batFolder)
            subprocess.call(batFile)
        
        # return what the json file name is and the atlas file name is.
        return [JsonFile,AtlasFile]
                
