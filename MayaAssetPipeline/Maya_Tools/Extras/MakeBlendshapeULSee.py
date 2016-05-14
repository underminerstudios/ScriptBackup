import pymel.core as pm
import os

class MakeBlendshapeNames(object):
    
    def __init__(self):
        self.FileNames = ["EyeBlink_L","EyeBlink_R","EyeSquint_L","EyeSquint_R","EyeDown_L",'EyeDown_R',
                     "EyeIn_L","EyeIn_R","EyeOpen_L","EyeOpen_R","EyeOut_L","EyeOut_R","EyeUp_L",
                     "EyeUp_R","BrowsD_L","BrowsD_R","BrowsU_C","BrowsU_L","BrowsU_R","JawFwd","JawLeft",
                     "JawOpen","JawChew","JawRight","MouthLeft","MouthRight","MouthFrown_L","MouthFrown_R",
                     "MouthSmile_L","MouthSmile_R","MouthDimple_L","MouthDimple_R","LipsStretch_L","LipsStretch_R",
                     "LipsUpperClose","LipsLowerClose","LipsUpperUp","LipsLowerDown","LipsUpperOpen","LipsLowerOpen",
                     "LipsFunnel","LipsPucker","ChinLowerRaise","ChinUpperRaise","Sneer","Puff","CheekSquint_L","CheekSquint_R"]

    def MakeFiles(self):
        """Save as loop"""
        for NameOfFile in self.FileNames:
            NameOfFile = NameOfFile + ".ma"
            pm.saveAs(NameOfFile)
            
    def GetTheFiles(self):
        """Need Files? Get your files right here"""

        FinalFileList = []
        FilesToCombine = str(pm.sceneName())
        FileLocation = os.path.split(FilesToCombine)[0]
        FilesToCombine = os.listdir(FileLocation)
         
        for FileToWorkOn in FilesToCombine:
            if FileToWorkOn.endswith(".ma"):
                FileToWorkOn = os.path.join(FileLocation,FileToWorkOn)
                FinalFileList.append(FileToWorkOn)
        return FinalFileList
    
    def CleanFiles(self,FiletoClean):
        """Take Out anything that isn't the model and name it the file name""" 
        pm.openFile(FiletoClean)
        FiletoClean = FiletoClean.split(".")[0]
        pm.saveAs(FiletoClean + "_clean.ma")
        pm.select("Body_Geo")
        pm.select("Tongue_Geo", add= True)
        pm.delete()
        pm.select("Mesh_Group")
        GroupObjects = pm.listRelatives(c=True)
        GroupName = os.path.split(FiletoClean)[-1]
        pm.polyUnite(GroupObjects, n=GroupName)
        pm.select(GroupName)
        pm.runtime.InvertSelection()
        pm.delete()
        pm.saveFile()
        
    def exportCleanFiles(self):
        """Exports clean files to obj"""

        FinalFileList = []
        FilesToCombine = str(pm.sceneName())
        FileLocation = os.path.split(FilesToCombine)[0]
        FilesToCombine = os.listdir(FileLocation)
         
        for FileToWorkOn in FilesToCombine:
            if FileToWorkOn.endswith("clean.ma"):
                FileToWorkOn = os.path.join(FileLocation,FileToWorkOn)
                FinalFileList.append(FileToWorkOn)
        
        for FinalFile in FinalFileList:
            pm.openFile(FinalFile)
            Meshes = pm.ls(type="mesh")
            pm.select(Meshes)
            exportLocation = FinalFile.replace("ma","obj")
            pm.exportSelected(exportLocation,typ="OBJexport")
           
    def CombineFiles(self):
        """Puts all the files togetehr"""
        
        for FileToCombine in self.GetTheFiles():
            if FileToCombine.endswith("clean.ma"):
                pm.importFile(FileToCombine)
                
    def CleanAll(self):
        AllFiles = self.GetTheFiles()
        for FiletoClean in AllFiles:
            self.CleanFiles(FiletoClean)


Make = MakeBlendshapeNames()
Make.CombineFiles()    