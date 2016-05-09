import sys
import os
import re
from PySide.QtGui import *
from PySide.QtCore import *

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from UI.Raw.Producer_UI import Ui_ArtTools
from Main.Core import worker
from Main import Core



class QTUIProject(QDialog,Ui_ArtTools):
    
    def __init__(self):
        """This makes the ui for the producers so they can move the art from one location to the next."""
        super(QTUIProject, self).__init__()
        self.setupUi(self)
        self.assignWidgets()
        self.show()
        
    def assignWidgets(self):
        """Signals and slots getting connected"""
        self.buttonBox.accepted.connect(self.runAll)
        self.buttonBox.rejected.connect(self.exitSystem)
        self.BingoAssetsFolder.clicked.connect(self.BingoAssetsFolderPushed)
        self.SlotsGameFolderFinder.clicked.connect(self.SlotsGameFolderPushed)
        self.BingoGameFolderFinder.clicked.connect(self.bingoGameFolderPushed)
       
    def runAll(self):
        
        """If the user is on the slots page it will move the art from the artist's locations to the new slots location. bingo will move art to the bingo locations"""
        SlotsFolderName = str(self.SlotsGameFolderLocation.text())
        SlotsRoomNumber = str(self.SlotsRoomNumber.text())
        BingoFolderName = str(self.BingoGameFolderLocation.text())
        BingoRoomNumber = str(self.BingoRoomNumber.text())
                
        if self.TopTab.currentIndex() == 0:
            #Slots Art Movement
            self.exportAndCheck(SlotsFolderName,SlotsRoomNumber,"Slots")
        elif self.TopTab.currentIndex() == 1:
            #Bingo Art Movement
            self.exportAndCheck(BingoFolderName,BingoRoomNumber,"Bingo")
            
        elif self.TopTab.currentIndex() == 2:
            self.setup()
            
    def exportAndCheck(self,GameFolderLocationInfo,RoomNumber,conversionType):
        
        """runs the check on the art. Moves the art from one location to the other base on a naming convention dictated by the user choice"""
        if not(os.path.isdir(GameFolderLocationInfo)):
            self.makeWarningPopup("Please Select A Game Folder!")
        elif RoomNumber == "" or RoomNumber == "Room Number": 
            self.makeWarningPopup("Please Put in a Room Number!")
        elif conversionType == "Slots":
            NamingConventnion = self.NamingConventnion.currentIndex()
            if NamingConventnion == 0:
                self.makeWarningPopup("Please Select a naming convention")
            elif NamingConventnion == 1:
                conversionType = "SlotsOld"
                self.differentNamingConventinon(GameFolderLocationInfo, 
                                                RoomNumber, conversionType)
            elif NamingConventnion == 2:
                conversionType = "SlotsNew"
                self.differentNamingConventinon(GameFolderLocationInfo, 
                                                RoomNumber, conversionType)
            elif NamingConventnion == 3:
                conversionType = "Rotelle"
                self.differentNamingConventinon(GameFolderLocationInfo, 
                                                RoomNumber, conversionType)
            elif NamingConventnion == 4:
                conversionType = "RotelleConversion"
                self.differentNamingConventinon(GameFolderLocationInfo, 
                                                RoomNumber, conversionType)
        elif conversionType == "Bingo":
            self.differentNamingConventinon(GameFolderLocationInfo, RoomNumber, conversionType)
                
     
    def differentNamingConventinon(self,GameFolderLocationInfo,RoomNumber,conversionType):
        """This does the setup for moving the art and telling users if their setup doesn't work"""
        
        RunTheCreation = Core.worker()
        BrokenStuff = RunTheCreation.getFolderAndMoveStuff(GameFolderLocationInfo, RoomNumber, conversionType)
        if not(BrokenStuff == ""):
            self.makeWarningPopup(BrokenStuff)
        elif BrokenStuff == False:
            self.makeWarningPopup("Please Run Setup")
            self.TopTab.setCurrentIndex(3)
        else:
            self.makeWarningPopup("Looking Good!")
            sys.exit()       
            
    def setup(self):
        """This runs the setup for the json files"""
        #Setup
        
        SlotsAssetsFolder = str(self.BingoAssetsFolderLocation.text())
        SlotsName = "Bingo Assets Folder"

        if os.path.isdir(SlotsAssetsFolder):
            SetupSetup = Core.worker()
            SetupSetup.run_setup(SlotsName,SlotsAssetsFolder)
            self.makeWarningPopup("Setup Finished!")
        else:
            self.makeWarningPopup("Please Select a folder!")
                
            
    def NotWorking(self,doesWork):
        """Something goes wrong catch system"""
        if doesWork == False:
            self.makeWarningPopup("Looks like the setup was not correct please Run it again!")
        else:
            self.makeWarningPopup("Finished!")
        
    def exitSystem(self):
        """Kills the script when it's done"""
        sys.exit()
        
        
    def BingoAssetsFolderPushed(self):
        """This is for the bingo assets folder"""
        BingoAssetsFolderToExport = QFileDialog.getExistingDirectory(self, 
                                                              "Select your Bingo Assets folder",
                                                              "/home")
        self.BingoAssetsFolderLocation.setText(BingoAssetsFolderToExport)
        
    def SlotsGameFolderPushed(self):
        
        """DIrectory of the art that will be converted"""
        SlotFolderToExport = QFileDialog.getExistingDirectory(self, 
                                                              "Directory Of the Game You Want Converted",
                                                              "/home")
        self.SlotsGameFolderLocation.setText(SlotFolderToExport)
        
    def bingoGameFolderPushed(self):
        """Directory of the bingo art you want converted"""
        bingoFolderToExport = QFileDialog.getExistingDirectory(self, 
                                                              "Directory Of the Game You Want Converted",
                                                              "/home")
        self.BingoGameFolderLocation.setText(bingoFolderToExport)
       
       
    def pickNumber(self):
        """What is the pick number for the game?"""
        #this will get all the info from the pick Number
        
        pass
    
    def makeWarningPopup(self,warning):
        """Makes a warning popup"""
        mBox = QMessageBox()
        mBox.setText(warning)
        mBox.exec_()
   

if __name__ == "__main__":
    app = QApplication(sys.argv)
    mainWin = QTUIProject()
    ret = app.exec_()

    sys.exit(ret)