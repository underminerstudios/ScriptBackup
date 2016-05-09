#!/usr/bin/python

import sys
import os
import subprocess

def loadUI():
        
        UIFilePathLocation = os.path.join(os.path.split(os.path.realpath(__file__))[0],"UI","Raw")

        pyside_uic = os.path.join(UIFilePathLocation,"pyside-uic.exe")        
        
        UIFileName = os.path.join(UIFilePathLocation,"Artist_UI.ui")
        
        UIPythonFileName = os.path.join(UIFilePathLocation,"Artist_UI.py")
        
        os.system("%s %s -o %s"%(pyside_uic,UIFileName,UIPythonFileName))
        

loadUI()

subprocess.call(os.path.join(os.path.dirname(__file__),'UI',"ArtistsUI.py"),shell=True)
