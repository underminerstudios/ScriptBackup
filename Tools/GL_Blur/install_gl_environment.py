#-------------------------------------------------------------------------------
# Name:        Install Common Environment
# Purpose:      to help user conform to GL pipeline
#
#
# Author:      Anisim.Kalugin
#
# Created:     1/14/2013
# Licence:     GPL
#-------------------------------------------------------------------------------
#!/usr/bin/env python
import os, shutil, ctypes



def main():
	blur_path = "C:/blur/"
	blur_common = blur_path + "common/"
	svnToolsDir = (str(os.getcwd()) + "/")
	py26_blurdev = "C:/Python26/Lib/site-packages/blurdev/"
	max_path = "C:/Program Files/Autodesk/3ds Max 2012/"
	max_path_startup = max_path + "Scripts/Startup/"
	gl_common  = svnToolsDir + "code/common/"

	# set up bur common directory and copy stuff over
	if os.path.exists(blur_common) == False:
		os.makedirs (blur_common)
		src = gl_common + "user_environments.xml",
		dst = blur_common + "user_environments.xml"
		print ('Copying over user environment: ' + src + ' to ' + dst)
		shutil.copy(src, dst)

	#set up blur setting via setting ini file
	if os.path.exists(py26_blurdev + "resource/") == True:
		shutil.copy(gl_common + "gl_fix/settings.ini", py26_blurdev + "resource/settings.ini")
	else:
		MessageBox = ctypes.windll.user32.MessageBoxA
		MessageBox(None, ('Folder doesnt exist: \n %s \n Make sure \"blurdev\" exists in the Python26 directory' %py26_blurdev ), 'I/O Problem', 0)

	#copy over libraries into max
	if os.path.exists(max_path_startup) == True:
		shutil.copy(gl_common + "Get_Gameloft_Blur_Lib.ms", max_path_startup + "Get_Gameloft_Blur_Lib.ms")
	else:
		MessageBox = ctypes.windll.user32.MessageBoxA
		MessageBox(None, ('Folder doesnt exist: \n %s \n Make sure \"blurdev\" exists in the Python26 directory' %py26_blurdev ), 'I/O Problem', 0)

	#copy over the MaxColorPicker
	if os.path.exists (max_path + "stdplugs/") == True:
		print ('copy files')
		shutil.copy(svnToolsDir + "code/cpp/MaxColorPicker/bin/MaxColorPicker.dlx", max_path + "stdplugs/MaxColorPicker.dlx")
	else:
		MessageBox = ctypes.windll.user32.MessageBoxA
		MessageBox(None, ('Folder doesnt exist: \n %s \n' % (max_path + "stdplugs/") ), 'I/O Problem', 0)



if __name__ == '__main__':	
	main()
