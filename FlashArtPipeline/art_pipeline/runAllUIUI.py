#!/usr/bin/python

import sys
import os
import subprocess

def loadUI():
        
        UIFilePathLocation = os.path.join(os.path.split(os.path.realpath(__file__))[0],"UI","Raw")

        pyside_uic = os.path.join(UIFilePathLocation,"pyside-uic.exe")        
        
        UIFileName = os.path.join(UIFilePathLocation,"UITeam_UI.ui")
        
        UIPythonFileName = os.path.join(UIFilePathLocation,"UITeam_UI.py")
        
        os.system("%s %s -o %s"%(pyside_uic,UIFileName,UIPythonFileName))
        

loadUI()

print os.path.join(os.path.dirname(__file__),'UI',"QTUI.py")
subprocess.call(os.path.join(os.path.dirname(__file__),'UI',"UITeam_UI.py"),shell=True)
