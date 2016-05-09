#-------------------------------------------------------------------------------
# Name:        MC4 Tools Installer
# Purpose:
#
# Author:      Anisim.Kalugin
# Edited:      Alexander Halchuk
#
# Created:     09/01/2013
# Copyright:   (c) Anisim.Kalugin 2013
# Licence:     GPL
#-------------------------------------------------------------------------------
#!/usr/bin/env python
import os
import shutil
import errno
import sys
from distutils import dir_util




def copyTree(src, dst):
	try:
		shutil.copytree(src, dst)
	except OSError as exc: # python >2.5
		if exc.errno == errno.ENOTDIR:
			shutil.copy(src, dst)
		else: raise

def main():
	maxPath = "C:\\Program Files\\Autodesk\\3ds Max 2012\\"
	MaxGLTools = maxPath + "Gameloft\\"
	ExtraLibPath = ("S:\\code\\common\\install\\Lib\\")
	SitePackagesPath = ("C:\\Python26\\Lib\\site-packages\\")
	#svnToolsDir = (str(os.getcwd()) + "\\")
	svnToolsDir = ("S:\\code\\maxscript\\tools\\Projects\\_Asphalt\\")


	maxPath = "C:\\Program Files\\Autodesk\\3ds Max 2012\\"
	MaxGLTools = maxPath + "Gameloft\\"
	#svnToolsDir = (str(os.getcwd()) + "\\")
	#work on MC4 Tools
	maxMC4 = maxPath + "Scripts\\Gameloft\\A9_Tools\\"
	svnMC4 = svnToolsDir + "A9_Tools\\"

	if (os.path.exists(maxMC4)) == True:
		print ("Directory exists: Deleting Old Tools in 3DSMax scripts.")
		shutil.rmtree(maxMC4)
	print ("Copying A9 Tools Tree to Max")
	copyTree(svnMC4, maxMC4)

	print ("Copying Additional Packages to Python Directory")
	dir_util.copy_tree(ExtraLibPath ,SitePackagesPath)
	
	#clean up A9_Tools Dir
	print ("Cleaning up A9 Tools directory")
	os.remove(maxMC4 + "\\A9_Tools_Guide.odt")
	os.remove(maxMC4 + "\\A9_IrradianceBatch.odt")
	os.remove(maxMC4 + "\\A9_Tools_Macro.ms")
	os.remove(maxMC4 + "\\Lib\\MaxColorPicker.dlx")

	print ("Moving macros to Max Startup")
	shutil.copyfile("S:\\code\\maxscript\\tools\\Projects\\_Asphalt\\A9_Tools\\A9_Tools_Macro.ms" , maxPath + "Scripts\\Startup\\A9_Tools_Macro.ms")
	userFileDest = os.path.expanduser("~") + "\\AppData\\Local\\Autodesk\\3dsMax\\2012 - 64bit\\enu\\plugcfg\\"
	shutil.copyfile("S:\\code\\common\\install\\Game_Loft_Tools.ini" , userFileDest + "Game_Loft_Tools.ini")

if __name__ == '__main__':
    main()
