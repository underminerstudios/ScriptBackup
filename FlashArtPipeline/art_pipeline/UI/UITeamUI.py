import sys
import os
from PySide.QtGui import *
from PySide.QtCore import *

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from UI.Raw.UITeam_UI import Ui_ArtTools
from Main.Core import worker


class QTUIProject(QDialog,Ui_ArtTools):
    
    def __init__(self):
        """This makes the ui for the ui team. (yes there was a whiteboarding for them... everyone else didn't care what I did)"""
        super(QTUIProject, self).__init__()
        self.setupUi(self)
        self.assignWidgets()
        self.show()
        self.SlotsJsonName = "Slots Assets Folder"
        self.BingoJsonName = "Bingo Assets Folder"
        
    def assignWidgets(self):
        """Connects signals and and slots"""
        self.buttonBox.accepted.connect(self.runAll)
        self.buttonBox.rejected.connect(self.exitSystem)
        self.FilesButton.clicked.connect(self.FileToRun)
        self.OutputButton.clicked.connect(self.OutPutLocation)
       
    def runAll(self):
        """when the user selects the correct files to run and the correct output folder it will run the conversion."""
        
        worker = worker()
        if self.FileFolder.text() == "":
            self.makeWarningPopup("Please Select a file or Files to run") 
        elif self.OutputFolder.text() == "":
            self.makeWarningPopup("Please select an output folder")
        else:
            TheFiles = self.FileFolder.text()
            TheOutPutFolder = self.OutputFolder.text()
            
        runArt = worker.MakeUITeamConversion(self,TheFiles,TheOutPutFolder)
                    
        
    def exitSystem(self):
        """Kill it all"""
        sys.exit()
        
    def FileToRun(self):
        """Popup for the files to run"""
        FileOrFilesToRun = QFileDialog.getExistingDirectory(self, 
                                                              "Select your file or files you wish to run",
                                                              "/home")
        self.FileFolder.setText(FileOrFilesToRun)
        
    def OutPutLocation(self):
        """Popup for the output folder"""
        
        OutPutFolderLocation = QFileDialog.getExistingDirectory(self, 
                                                              "Select where you want the files",
                                                              "/home")
        self.OutputFolder.setText(OutPutFolderLocation)
       
    
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