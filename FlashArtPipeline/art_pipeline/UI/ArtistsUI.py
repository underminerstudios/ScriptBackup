import sys
import os
import re
from PySide.QtGui import *
from PySide.QtCore import *

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from UI.Raw.Artist_UI import Ui_ArtTools
from Main.Core import worker
from Main import Core
from ExternalCalls import SlotsNewConversion


class QTUIProject(QDialog,Ui_ArtTools):
    
    def __init__(self):
        """This makes the artists ui.  Lots of fun stuff in here."""
        super(QTUIProject, self).__init__()
        self.setupUi(self)
        self.assignWidgets()
        self.show()
        self.SlotsJsonName = "Slots Assets Folder"
        self.BingoJsonName = "Bingo Assets Folder"
        
    def assignWidgets(self):
        
        """Connects all the signals and slots"""
        self.buttonBox.accepted.connect(self.runAll)
        self.buttonBox.rejected.connect(self.exitSystem)
        self.SlotsFolder.clicked.connect(self.SlotsFolderPushed)
        self.BingoFolder.clicked.connect(self.BingoFolderPushed)
       
    def runAll(self):
        
        """When someone hits ok based on the page number they are on it will do what's on that page"""
        worker = Core.worker()
        SlotsGameNameInput = str(self.SlotsGameNameInput.text())
        GameType = self.GameTypeComboBox.currentIndex()
        
        #if someone presses the check box then it becomes a rotelle game
        Rotelle = self.RotelleCheckBox.checkState()
        if Rotelle.name == "Checked":
            Rotelle = True
        else:
            Rotelle = False
    
        #makes a slots room based on the type selected
        if self.TopTab.currentIndex() == 0:
            self.slotsRoomCreation(SlotsGameNameInput, GameType, worker, Rotelle)
                    
        #creates a bingo
        if self.TopTab.currentIndex() == 1:
            self.bingoRoomCreation(worker)
                
        #checks the artwork 
        elif self.TopTab.currentIndex() == 2:
            self.checkArt()

        #sets up the folders etc
        elif self.TopTab.currentIndex() == 3:
            self.setup()  
            
            
    def slotsRoomCreation(self,SlotsGameNameInput,GameType,worker,Rotelle):
        """Bingo room creation"""
        
        # if they don't put something in the game location the it just stops here
        if SlotsGameNameInput == "Example: LuckyLotus" or SlotsGameNameInput == "":
            self.makeWarningPopup("Please Put In A Game Name.")
        elif not(SlotsGameNameInput == "Example: LuckyLotus") or SlotsGameNameInput =="":
            GameType = self.GameTypeComboBox.currentIndex()
            
            # makes the user select a game type
            if  GameType == 0:
                self.makeWarningPopup("Please select a game type")
                
                # if there needs to be a nubmer of picks tell the user if they didnt put anyin
            elif GameType == 2 or GameType == 3:
                NumberOfPicks = str(self.NumberOfPicksInput.text())
                if  NumberOfPicks == "" or NumberOfPicks == "Leave Alone if not needed.":
                    self.makeWarningPopup("Pick till you poop and Fixed Pick require a pick number!")
                else:
                    doesWork = worker.setupSlotsRoom(SlotsGameNameInput, self.GameTypeComboBox.currentIndex(),
                                                   Rotelle,NumberOfPicks)
                    self.NotWorking(doesWork)
                    
            #other than thatset up eerything
            else:
                doesWork = worker.setupSlotsRoom(SlotsGameNameInput, self.GameTypeComboBox.currentIndex(),
                                               Rotelle)
                self.NotWorking(doesWork)
    
    def bingoRoomCreation(self):
        # Bingo room creation
        SlotsGameNameInput = str(self.BingoGameInput.text())
        
        if SlotsGameNameInput == "Example: TheDrumStickRedemption" or SlotsGameNameInput == "":
            self.makeWarningPopup("Please Put In A Game Name.")
        elif not(SlotsGameNameInput == "Example: TheDrumStickRedemption") or SlotsGameNameInput =="":
            pass
            #self.NotWorking(doesWork)
                
            
    def checkArt(self):
        """Checks the artwork"""
        Test = self.test.checkState()
        if Test.name == "Checked":
            Test = True
        else:
            Test = False
         # Test art
        BingoTestFolder = self.ArtRepoLocation.text()
        SlotsTestFolder = str(self.SlotsFolderLocation.text())
        if os.path.isdir(BingoTestFolder) and SlotsTestFolder == "":
            CheckConversion = SlotsNewConversion.MoveThings()
            BrokenFiles = CheckConversion.runMovement()
            self.makeWarningPopup("%s")%(BrokenFiles)
        
        elif os.path.isdir(SlotsTestFolder) and BingoTestFolder == "":
            CheckConversion = SlotsNewConversion.MoveThings
            BrokenFiles = CheckConversion.runMovement()
            self.makeWarningPopup("%s")%(BrokenFiles)
        else:    
            self.makeWarningPopup("Please select a folder or make sure only one folder is selected for Slots or Bingo!")       
            
    def setup(self):
        """Runs the setup file"""
        BingoAssetsFolder = str(self.BingoFolderLocation.text())
        SlotsAssetsFolder = str(self.SlotsFolderLocation.text())
        
        
        if os.path.isdir(SlotsAssetsFolder) and BingoAssetsFolder == "":
            SetupSetup = Core.worker()
            SetupSetup.run_setup(self.SlotsJsonName,SlotsAssetsFolder)
            self.makeWarningPopup("Setup Finished!")
        
        elif os.path.isdir(BingoAssetsFolder) and SlotsAssetsFolder == "":
            SetupSetup = Core.worker()
            SetupSetup.run_setup(self.BingoJsonName,BingoAssetsFolder)
            self.makeWarningPopup("Setup Finished!")
            
        elif os.path.isdir(BingoAssetsFolder) and os.path.isdir(SlotsAssetsFolder):    
            SetupSetup = Core.worker()
            SetupSetup.run_setup(self.BingoJsonName,
                                 BingoAssetsFolder,self.SlotsJsonName,SlotsAssetsFolder)
            self.makeWarningPopup("Setup Finished!")
            
        else:
            self.makeWarningPopup("Please Select a folder!")
                
            
    def NotWorking(self,doesWork):
        """If the user did somethingwrong with a setup lets tell them and make a popup"""
        if doesWork == False:
            self.makeWarningPopup("Looks like the setup was not correct please Run it again!")
        else:
            self.makeWarningPopup("Finished!")
        
    def exitSystem(self):
        """End of everything"""
        sys.exit()
        
    def SlotsFolderPushed(self):
        """Get the slots folder and place it's text for the user to see"""
        
        SlotFolderToExport = QFileDialog.getExistingDirectory(self, 
                                                              "Select your Slots parent folder",
                                                              "/home")
        self.SlotsFolderLocation.setText(SlotFolderToExport)
        
    def BingoFolderPushed(self):
        """Get the bingo folder and place it's text for the user to see"""
        BingoFolderToExport = QFileDialog.getExistingDirectory(self, 
                                                              "Select your Bingo Parent folder",
                                                              "/home")
        self.BingoFolderLocation.setText(BingoFolderToExport)
       
    def pickNumber(self):
        """this is for the pick number"""
        #this will get all the info from the pick Number
        
        pass
    
    def makeWarningPopup(self,warning):
        """Need a warning dialogue?"""
        mBox = QMessageBox()
        mBox.setText(warning)
        mBox.exec_()
   

if __name__ == "__main__":
    app = QApplication(sys.argv)
    mainWin = QTUIProject()
    ret = app.exec_()

    sys.exit(ret)