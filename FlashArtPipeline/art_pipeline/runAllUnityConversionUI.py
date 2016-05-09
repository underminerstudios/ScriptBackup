<<<<<<< HEAD
#!/usr/bin/python

import sys
import os
import subprocess

def loadUI():
        #Converts the UI via pyside so it updates everytime there is a change
        UIFilePathLocation = os.path.join(os.path.split(os.path.realpath(__file__))[0],"UI","Raw")

        pyside_uic = os.path.join(UIFilePathLocation,"pyside-uic.exe")        
        
        UIFileName = os.path.join(UIFilePathLocation,"UnityConversion.ui")
        
        UIPythonFileName = os.path.join(UIFilePathLocation,"UnityConversionUI.py")
        
        os.system("%s %s -o %s"%(pyside_uic,UIFileName,UIPythonFileName))
        



loadUI()
#loads the ui and starts the Unity conversion pipeline.
subprocess.call(os.path.join(os.path.dirname(__file__),'UI',"UnityConversionUI.py"),shell=True)
=======
#!/usr/bin/python

import sys
import os
import subprocess

def loadUI():
        #Converts the UI via pyside so it updates everytime there is a change
        UIFilePathLocation = os.path.join(os.path.split(os.path.realpath(__file__))[0],"UI","Raw")

        pyside_uic = os.path.join(UIFilePathLocation,"pyside-uic.exe")        
        
        UIFileName = os.path.join(UIFilePathLocation,"UnityConversion.ui")
        
        UIPythonFileName = os.path.join(UIFilePathLocation,"UnityConversionUI.py")
        
        os.system("%s %s -o %s"%(pyside_uic,UIFileName,UIPythonFileName))
        

loadUI()
#loads the ui and starts the Unity conversion pipeline.
subprocess.call(os.path.join(os.path.dirname(__file__),'UI',"UnityConversionUI.py"),shell=True)
>>>>>>> branch 'master' of ssh://root@timcoolmode.ddns.net:9002/Externals/Desktop/F/GITRepos/code/FlashArtPipeline.git
