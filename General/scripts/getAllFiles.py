import os
import shutil

folder = "I:\\GDrive\\"

possibleFolders = os.listdir(folder)

areRealFolders = []

for fileFolder in possibleFolders:
    if not(fileFolder.endswith(".zip")):
        areRealFolders.append(fileFolder)


        
for areRealFolder in areRealFolders:
    try:
        newFolder = os.path.join(folder, areRealFolder,"Takeout","Drive","INTEL - WBY - ART")
        filesInDir = os.listdir(newFolder)
        
        for fileInDir in filesInDir:
            finalFolder = os.path.join(newFolder,fileInDir)
            if not(os.path.exists(fileFolder)):
                shutil.move(finalFolder, "I:\\GDrive\\Drive")
            elif os.path.exists(fileFolder):
                files = os.listdir
                
    except:
        pass

