import sys
import os
import re
from PySide.QtGui import *
from PySide.QtCore import *

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from UI.Raw.UnityConversion import Ui_ArtTools
from Main.Core import worker



class QTUIProject(QDialog,Ui_ArtTools):
    
    def __init__(self):
        """Makes the ui for the unity conversion"""
        
        #pulls in the ui file and q dialogue as the super classes
        super(QTUIProject, self).__init__()
        #starts the ui
        self.setupUi(self)
        #assignes the events below to buttons
        self.assignWidgets()
        #shows the UI
        self.show()
        #says what the product backlog name for json should be
        self.ProdJsonName = "Prod Backlog Folder"
        self.BingoBlitzUnityArtName = "Bingo Blitz Unity Art Folder"
        
    def assignWidgets(self):
        """Connects the signals and slots"""
        self.buttonBox.accepted.connect(self.runAll)
        self.buttonBox.rejected.connect(self.exitSystem)
        self.ProdBacklogTrunkButton.clicked.connect(self.ProdBacklogTrunkButtonPushed)
        self.UnityArtButton.clicked.connect(self.BingoArtButtonPushed)

       
    def runAll(self):
        """Based on the current tab it will each section."""                
        if self.TopTab.currentIndex() == 0:
            #Bingo Map Get parts
            BingoAllChecked = self.BingoAll.checkState()
            
            #convert everything?
            if BingoAllChecked.name == "Checked":
                BingoAllChecked = True
            else:
                BingoAllChecked = False
            
            #starts up core.worker.makeallmap.  Feeds it the map type and if the all check mark is checked
            bingo = worker()
            bingo.MakeAllMap("Bingo",BingoAllChecked)
             
        elif self.TopTab.currentIndex() == 1:
            #Bingo Map Conversion, Makes atlases etc
            BingoAtlasAllChecked = self.BingoAtlasAll.checkState()
            
            #convert everything?
            if BingoAtlasAllChecked.name == "Checked":
                BingoAtlasAllChecked = True
            else:
                BingoAtlasAllChecked = False
                        
            slots = worker()
            slots.makeAllMapAtlases("Bingo",BingoAtlasAllChecked)
            
        elif self.TopTab.currentIndex() == 2:
            #Slots Map get parts
            SlotsAllChecked = self.SlotsAll.checkState()
            
            #convert everything?
            if SlotsAllChecked.name == "Checked":
                SlotsAllChecked = True
            else:
                SlotsAllChecked = False
                        
            slots = worker()
            slots.MakeAllMap("Slots",SlotsAllChecked)
            
        elif self.TopTab.currentIndex() == 3:
            #Slots Map Conversion
            SlotsAtlasAllChecked = self.SlotsAtlasAll.checkState()
            
            #convert everything?
            if SlotsAtlasAllChecked.name == "Checked":
                SlotsAtlasAllChecked = True
            else:
                SlotsAtlasAllChecked = False
                        
            slots = worker()
            slots.makeAllMapAtlases("Slots",SlotsAtlasAllChecked)
            
        elif self.TopTab.currentIndex() == 4:
            
            #setup the json files
            self.setup() 
            
    def setup(self):
        """Gets the json locations from the UI and feeds it to the run setup witch makes the json file"""
        ProdBacklogFolderLocation = str(self.ProdBacklogTrunkFolderLocation.text())
        BingoUnityArtLocation = str(self.UnityArtLocation.text())

        # if both are there and are real folders then make the json and tell the user it's all good
        if os.path.isdir(ProdBacklogFolderLocation) and os.path.isdir(BingoUnityArtLocation):
            SetupSetup = worker()
            SetupSetup.run_setup(self.ProdJsonName,ProdBacklogFolderLocation,self.UnityArtName,BingoUnityArtLocation)
            self.makeWarningPopup("Setup Finished!")
            
        else:
            #someone didn't select the folders tell them to select them.
            self.makeWarningPopup("Please Select a Prod Backlog and Bingo Unity Art Folder!")
                
            
    def NotWorking(self,doesWork):
        """if there ever is a time that we run the art and something goes wrong we have a popup for it"""
        if doesWork == False:
            self.makeWarningPopup("Looks like the setup was not correct please Run it again!")
        else:
            self.makeWarningPopup("Finished!")
        
    def exitSystem(self):
        """Kills the application"""
        sys.exit()
        
        
    def ProdBacklogTrunkButtonPushed(self):
        """ Makes prod backlog popup and tells users to select the prod backlog"""
        ProdFolderToExport = QFileDialog.getExistingDirectory(self, 
                                                              "Select your Prod Backlog Trunk folder",
                                                              "/home")
        self.ProdBacklogTrunkFolderLocation.setText(ProdFolderToExport)
        
    def BingoArtButtonPushed(self):
        """Makes Bingo art popup and tells users to select the bingo art location"""
        BingoArt = QFileDialog.getExistingDirectory(self, 
                                                              "Select your Bingo Blitz Unity Art folder",
                                                              "/home")
        self.BingoBlitzUnityArtLocation.setText(BingoArt)
    
    def makeWarningPopup(self,warning):
        """Makes warning popups for things that break"""
        mBox = QMessageBox()
        mBox.setText(warning)
        mBox.exec_()
        
   

if __name__ == "__main__":
    app = QApplication(sys.argv)
    mainWin = QTUIProject()
    ret = app.exec_()

    sys.exit(ret)