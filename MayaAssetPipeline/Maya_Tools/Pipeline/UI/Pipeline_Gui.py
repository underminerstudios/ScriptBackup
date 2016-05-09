import os

from PySide import QtCore, QtGui
from shiboken import wrapInstance

import Pipeline.UI.main_ui as master_ui
import maya.OpenMayaUI as omui
from Pipeline.media.UI_Converter import Convert_Ui
import Pipeline


class Converter(object):
    def __init__(self):
        # all the relative folders for our project
        self.directory_of_ui    = os.path.dirname(os.path.realpath(__file__))
        self.directory_of_root  = os.path.join(self.directory_of_ui,'..')
        self.directory_of_media = os.path.join(self.directory_of_ui,'..','media')
        self.directory_of_submodules = os.path.join(self.directory_of_ui,'..','submodules')
        self.directory_of_main = os.path.join(self.directory_of_ui,'..','main')
        self.directory_of_games_2d = os.path.join(self.directory_of_ui,'..','submodules','games_2d')
        self.directory_of_games_3d = os.path.join(self.directory_of_ui,'..','submodules','games_3d')
        
    def convert_ui(self):
        
        files_in_dir = os.listdir(self.directory_of_media)
        files_to_convert = []
        
        for file_in_dir in range(0,len(files_in_dir)):
            
            if os.path.splitext(files_in_dir[file_in_dir])[1] == '.ui':
                files_to_convert+=[files_in_dir[file_in_dir]]
              
              
        for file_to_convert in files_to_convert:
            file_name = os.path.splitext(file_to_convert)[0]
            input_name  = os.path.join(self.directory_of_media,file_to_convert)
            output_name = os.path.join(self.directory_of_ui,file_name+'.py')
             
            make_convert = Convert_Ui()
            make_convert.convert(input_name,output_name)

lets_convert_this = Converter()
lets_convert_this.convert_ui()

reload (Pipeline.UI.main_ui)


def maya_main():
    maya_main_window_pointer = omui.MQtUtil.mainWindow()
    return wrapInstance(long(maya_main_window_pointer), QtGui.QWidget)
 
class Main_ui_controller(QtGui.QMainWindow):
 
    def __init__(self, parent=None):
 
        super(Main_ui_controller, self).__init__(parent)
        self.setWindowFlags(QtCore.Qt.Tool)
        self.myui =  master_ui.Ui_MainWindow()
        self.myui.setupUi(self)
 
 

        #self.ui.pushButton.clicked.connect(self.someFunc)


    def set_up_art(self):
        pass

    def push_import_button(self):
        pass




main_ui = Main_ui_controller(parent=maya_main())
main_ui.show()
