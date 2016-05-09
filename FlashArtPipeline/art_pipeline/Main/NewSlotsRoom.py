from ExternalCalls.SlotsOldConversion import MoveSlotsOldConversion
import os
from fileinput import filename
from ExternalCalls.SlotsNewConversion import MoveSlotsNewConversion
import shutil
from ExternalCalls import make_folders

class newCitySetup(MoveSlotsOldConversion,MoveSlotsNewConversion):
    #folders named on the top.  Each folder gets it's own function.  Put into a 
    #dictonary with val = folder location file name is key.  There is a 
    #helper that does all the core (needed things) with axalary on their own too
    # list comprehension in MakeDictonary function. New game types or kobbled 
    # together version can happen with
    # different variables added. Files are found in the findFilesYou need function.
    
    
    ##############################
    # I have removed the templates folder because those are propitary files that I had no hand in creating.
    ##############################
    
    
    def __init__(self,gameName,templatesFolder,slotsFolder,Rotelle):
        """Gets all the templates folders for slots rooms"""
        
        self.gameName = gameName
        self.slotsFolder = slotsFolder
        self.templatesFolder = templatesFolder
        self.Rotelle = Rotelle
        self.achievementsLocation = os.path.join(self.templatesFolder,"Achievements")
        self.cityBackgroundsLocation = os.path.join(self.templatesFolder,"cityBackgrounds")
        self.cityTitleLocation = os.path.join(self.templatesFolder,"cityTitle")
        self.etcLocation = os.path.join(self.templatesFolder,"etc")
        self.facebookLocation = os.path.join(self.templatesFolder,"facebook")
        self.postcardsLocation = os.path.join(self.templatesFolder,"postcards")
        self.scatterLocation = os.path.join(self.templatesFolder,"scatter")
        self.slotsBigWheelLocation = os.path.join(self.templatesFolder,"slotsBigWheel")
        self.slotsSymbolsLocation = os.path.join(self.templatesFolder,"slotsSymbols")
        self.slotsUILocation = os.path.join(self.templatesFolder,"slotsUI") 
        self.trophyLocation = os.path.join(self.templatesFolder,"trophy")
        self.backgroundsLocation = os.path.join(self.templatesFolder,"backgrounds")
        MakeFolders = make_folders.make_all_folders()
        MakeFolders.setupSlotsArtFolders(slotsFolder,gameName)
        
    def Achievements(self):
        """Adds acheavements and their location to the dictonary"""
        Achievements = "_achievements"
        
        Achievements = [Achievements]
        
        AchievementsList = self.dictonaryMaker(Achievements, self.achievementsLocation)
        
        return AchievementsList
    
    def backgrounds(self):
        """Adds backgrounds and their location to the dictonary"""
        
        backgrounds = "_backgrounds"
        
        backgrounds = [backgrounds]
        
        backgroundsList = self.dictonaryMaker(backgrounds, self.backgroundsLocation)
        
        return backgroundsList
    
    def cityBackgrounds(self):
        """Adds city backgrounds and their location to the dictonary"""
        
        cityBackgrounds = "_cityBackgrounds"
        
        cityBackgrounds = [cityBackgrounds]
        
        cityBackgroundsList = self.dictonaryMaker(cityBackgrounds, self.cityBackgroundsLocation)
        
        return cityBackgroundsList
        
    def cityTitle(self):
        """Adds city title and their location to the dictonary"""
        
        cityTitle = "_cityTitle"
        
        cityTitle = [cityTitle]
        
        cityTitleList = self.dictonaryMaker(cityTitle, self.cityTitleLocation)
        
        return cityTitleList
        
    def featuredIcon(self):
        """Adds featured Icon and their location to the dictonary. Featured icon in rotelle lives in the extras folder"""
        
        featuredIconName = "_featuredIcon"
        frame = "_frame"
        
        if not(self.Rotelle):
            featuredIconName = [featuredIconName,frame]
        else:
            extras = "_Extras"
            featuredIconName = [featuredIconName,frame,extras]
            
        
        featuredIconNameList = self.dictonaryMaker(featuredIconName, self.etcLocation)
        
        return featuredIconNameList
        
    def facebook(self):
        """Adds facebook items and their locations to the dictonary"""
        
        unlockedCity = "_unlockedCity"
        achievement = '_achievement'
        roomvisit = '_roomvisit'
        pickGame = '_pickGame'
        brags = "_brag"
        
        facebook = [unlockedCity,achievement,roomvisit,pickGame,brags]
        
        
        facebookList = self.dictonaryMaker(facebook, self.facebookLocation)
        
        return facebookList
        
    def postcards(self):
        """Adds postcards and their locations to the dictonary"""
        
        featuredPostCardLarge = "_featuredPostCardLarge"
        cityPostCard = "_cityPostCard"
        lobby2 = '_lobby2'
        
        postcards = [featuredPostCardLarge,cityPostCard,lobby2]
        
        postcardsList = self.dictonaryMaker(postcards, self.postcardsLocation)
        
        return postcardsList
        
    def slotsBigwheel(self):
        """Adds big wheel and its location to the dictonary"""
        
        slotsBigWheel = "_bigwheel"
        
        slotsBigWheel = [slotsBigWheel]
        
        slotsBigWheelList = self.dictonaryMaker(slotsBigWheel, self.slotsBigWheelLocation)
        
        return slotsBigWheelList
        
    def slotsSymbols(self):
        """Adds slots symbols and their location to the dictonary.  Rotelle is a bit different name"""
        
        if not(self.Rotelle):
            slotsSymbolsName = "_symbols_V2"
        else:
            slotsSymbolsName = '_symbols_rotelle'
           
        
        slotsSymbolsName = [slotsSymbolsName]
        
        slotsSymbolsNameList = self.dictonaryMaker(slotsSymbolsName, self.slotsSymbolsLocation)
        
        return slotsSymbolsNameList
        
    def slotsUI(self):
        """Adds slotsUI and their location to the dictonary. Rotelle has a different name"""
        
        if not(self.Rotelle):
            slotsUIName = "_ui_V2"
        else:
            slotsUIName = "_ui_rotelle"
        
        slotsUIName = [slotsUIName]
        
        slotsUINameList = self.dictonaryMaker(slotsUIName, self.slotsUILocation)
        
        return slotsUINameList
    
    def trophy(self):
        """Adds trophy and their location to the dictonary"""
        
        trophyName = "_trophy"
        
        trophyName = [trophyName]
        
        trophyNameList = self.dictonaryMaker(trophyName, self.trophyLocation)
        
        return trophyNameList


    #scatters  
    #############################
    ###################Taken out till I can get new templates
    ##############################
    '''      
    def freeSpin(self):
        slotBonusRound = "_slots_bonus_round"
        
        slotBonusRound = [slotBonusRound]
        
        slotBonusRoundList = self.dictonaryMaker(slotBonusRound, self.scatterLocation)
        
        return slotBonusRoundList
         
    def theamed(self):
        themedName = "_theamedScatter"
        
        themedName = [themedName]
        
        themedNameList = self.dictonaryMaker(themedName, self.scatterLocation)
        
        return themedNameList
        
    def pickTillYouPoop(self,poopNumber):
        poop = "_poopScatter_%s.swf"%(poopNumber)
        
        poop = [poop]
        
        poopList = self.dictonaryMaker(poop, self.scatterLocation)
        
        return poopList
        
    def fixedPick(self,fixedPickNumber):
        fixedPickName = "_fixedPickScatter_%s.swf"%(fixedPickNumber)
        
        fixedPickName = [fixedPickName]
        
        fixedPickNameList = self.dictonaryMaker(fixedPickName, self.scatterLocation)
        
        return fixedPickNameList
    
    def modified(self):
        #specials for modified games
        modifiedName = "_modifiedScatter.swf"
        
        modifiedName = [modifiedName]
        
        modifiedNameList = self.dictonaryMaker(modifiedName, self.scatterLocation)
        
        return modifiedNameList
    '''
    #####
    # Put it all together down here
    #####
    
    def getCoreElements(self):
        
        """Gets all the core elements"""

        allOfCore =  {}
        
        allOfCore.update(self.Achievements())
        allOfCore.update(self.cityBackgrounds())
        allOfCore.update(self.cityTitle())
        allOfCore.update(self.featuredIcon())
        allOfCore.update(self.facebook())
        allOfCore.update(self.postcards())
        allOfCore.update(self.slotsBigwheel())
        allOfCore.update(self.slotsSymbols())
        allOfCore.update(self.slotsUI())
        allOfCore.update(self.trophy())
        
        if (self.Rotelle):
            allOfCore.update(self.backgrounds())
        else:
            shutil.rmtree(self.backgroundsLocation)
        
        return allOfCore

    
    def buildFreeSpin(self):
        """Free spins game"""
        
        freeSpinList = {}
        
        freeSpinList.update(self.getCoreElements())
        #freeSpinList.update(self.freeSpin())
        
        return freeSpinList
        
    def buildPickTillYouPoop(self,poopNumber):
        """If you need a pick till you are done called a 'pick till you poop game'... seriously...."""
        
        poopList = {}
        
        poopList.update(self.getCoreElements())
        #poopList.update(self.pickTillYouPoop())
        
        return poopList
    
    def BuildTheamed(self):
        """If you need a theamed game call this"""
        
        theamedList = {}
        
        theamedList.update(self.getCoreElements())
        #theamedList.update(self.theamed())
        
        return theamedList
        
    def buildFixedPick(self,fixedPickNumber):
        """If you need a fixed pick game call this"""
        
        fixedList = {}
        
        fixedList.update(self.getCoreElements())
        #ixedList.update(self.fixedPick(fixedPickNumber))
        
        return fixedList
    
    def buildModified(self):
        """If you need a modified game call this"""
        
        modifiedList = {}
        
        modifiedList.update(self.getCoreElements())
        #modifiedList.update(self.modified())
        
        return modifiedList
        
    def dictonaryMaker(self,list,location):
        # makes a quick dictonary
        value = location
        dictonary = {key:value for key in list}
        
        return dictonary
    
    
    def makeLayout(self,FilesToFindList):
        
        filesToGet = FilesToFindList.keys()

        for fileToGet in filesToGet:
            TemplatesfolderLocation = FilesToFindList.get(fileToGet)
            AllFiles = os.listdir(TemplatesfolderLocation)
            newFolderLocation = os.path.split(TemplatesfolderLocation)[-1]
            
            for AllFile in AllFiles:
                SplitFile = AllFile.split(".")
                
                if SplitFile[0].endswith(fileToGet):
                    oldFileLocation = os.path.join(TemplatesfolderLocation,AllFile)
                    ext = SplitFile[-1]
                    SplitFile[0]
                    oldFileName = SplitFile[0].split("_")
                    oldFileName.pop(0)
                    
                    if oldFileName[-1] == "V2" or oldFileName[-1] == "rotelle":
                        oldFileName.pop(-1)
                    oldFileName = self.gameName + '_' + '_'.join(oldFileName) + '.' + ext
                    
                    NewFileLocation = os.path.realpath(os.path.join(self.slotsFolder,self.gameName,
                                                   newFolderLocation,oldFileName))

                    shutil.copy(oldFileLocation, NewFileLocation)
    
    
    
    