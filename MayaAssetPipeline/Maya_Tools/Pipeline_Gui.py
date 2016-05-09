from PySide import QtCore, QtGui
from shiboken import wrapInstance
import maya.OpenMayaUI as omui

from media.ui_converter import convert_ui
import os

class Converter(object):
    def __init__(self):
        # all the relative folders for our project
        self.directory_of_ui    = os.path.dirname(os.path.realpath(__file__))
        self.directory_of_root  = os.path.join(self.directory_of_ui,'../')
        self.directory_of_media = os.path.join(self.directory_of_ui,'../media')
        self.directory_of_submodules = os.path.join(self.directory_of_ui,'../submodules')
        self.directory_of_main = os.path.join(self.directory_of_ui,'../main')
        self.directory_of_games_2d = os.path.join(self.directory_of_ui,'../submodules/games_2d')
        self.directory_of_games_3d = os.path.join(self.directory_of_ui,'../submodules/games_3d')
        
    def convert_ui(self):
        
        files_in_dir = os.listdir(self.directory_of_media)
        
        for file_in_dir in range(0,len(files_in_dir)):
            
            #keep getting an index out of range on this when I try to eval it to false. have to do a full if else
            # to get it to work... booooo
            if not(os.path.splitext(files_in_dir[file_in_dir])[1] == '.ui'):
                print 'bob'
            else:
                pass
            '''
            else:
                files_in_dir.pop(file_in_dir)
            '''
            
        ui_to_convert = convert_ui()    
              
        for file_to_convert in files_in_dir:
            file_name = os.path.splitext(file_to_convert)[0]
            input_name  = os.path.join(self.directory_of_media,file_to_convert)
            output_name = os.path.join(self.directory_of_ui,file_name,'.py') 
            make_convert = ui_to_convert(input_name,output_name)
            make_convert.convert()

import UI.main_ui
reload (UI.main_ui)
import UI.main_ui as master_ui


def maya_main():
    maya_main_window_pointer = omui.MQtUtil.mainWindow()
    return wrapInstance(long(maya_main_window_pointer), QtGui.QWidget)
 
class Main_ui_controller(QtGui.QDialog):
 
    def __init__(self, parent=None):
 
        super(Main_ui_controller, self).__init__(parent)
        self.setWindowFlags(QtCore.Qt.Tool)
        self.myui =  master_ui.Ui_MainWindow()
        self.myui.setupUi(self)
 
 

        self.ui.pushButton.clicked.connect(self.someFunc)




    def someFunc(self):
        print 'Hello {0} !'


clean_convert = Converter()
clean_convert.convert_ui()

main_ui = Main_ui_controller(parent=maya_main())
main_ui.show()
