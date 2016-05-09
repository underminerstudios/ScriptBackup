# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'C:\Art_Tools\workspace\art_pipeline\UI\Raw\UITeam_UI.ui'
#
# Created: Tue Dec 01 10:24:39 2015
#      by: pyside-uic 0.2.15 running on PySide 1.2.2
#
# WARNING! All changes made in this file will be lost!

from PySide import QtCore, QtGui

class Ui_ArtTools(object):
    def setupUi(self, ArtTools):
        ArtTools.setObjectName("ArtTools")
        ArtTools.resize(500, 300)
        ArtTools.setMinimumSize(QtCore.QSize(500, 300))
        ArtTools.setMaximumSize(QtCore.QSize(500, 300))
        self.verticalLayout = QtGui.QVBoxLayout(ArtTools)
        self.verticalLayout.setObjectName("verticalLayout")
        self.TopTab = QtGui.QTabWidget(ArtTools)
        self.TopTab.setStyleSheet("")
        self.TopTab.setObjectName("TopTab")
        self.FolderSetup = QtGui.QWidget()
        self.FolderSetup.setObjectName("FolderSetup")
        self.verticalLayout_2 = QtGui.QVBoxLayout(self.FolderSetup)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.FilesButton = QtGui.QPushButton(self.FolderSetup)
        self.FilesButton.setObjectName("FilesButton")
        self.horizontalLayout.addWidget(self.FilesButton)
        self.FileFolder = QtGui.QLineEdit(self.FolderSetup)
        self.FileFolder.setObjectName("FileFolder")
        self.horizontalLayout.addWidget(self.FileFolder)
        spacerItem = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem)
        self.verticalLayout_2.addLayout(self.horizontalLayout)
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.OutputButton = QtGui.QPushButton(self.FolderSetup)
        self.OutputButton.setObjectName("OutputButton")
        self.horizontalLayout_2.addWidget(self.OutputButton)
        self.OutputFolder = QtGui.QLineEdit(self.FolderSetup)
        self.OutputFolder.setObjectName("OutputFolder")
        self.horizontalLayout_2.addWidget(self.OutputFolder)
        spacerItem1 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_2.addItem(spacerItem1)
        self.verticalLayout_2.addLayout(self.horizontalLayout_2)
        spacerItem2 = QtGui.QSpacerItem(20, 141, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_2.addItem(spacerItem2)
        self.TopTab.addTab(self.FolderSetup, "")
        self.verticalLayout.addWidget(self.TopTab)
        self.buttonBox = QtGui.QDialogButtonBox(ArtTools)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName("buttonBox")
        self.verticalLayout.addWidget(self.buttonBox)

        self.retranslateUi(ArtTools)
        self.TopTab.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(ArtTools)

    def retranslateUi(self, ArtTools):
        ArtTools.setWindowTitle(QtGui.QApplication.translate("ArtTools", "Dialog", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setToolTip(QtGui.QApplication.translate("ArtTools", "<html><head/><body><p><br/></p></body></html>", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setWhatsThis(QtGui.QApplication.translate("ArtTools", "<html><head/><body><p><br/></p></body></html>", None, QtGui.QApplication.UnicodeUTF8))
        self.FilesButton.setText(QtGui.QApplication.translate("ArtTools", "Files Folder or File", None, QtGui.QApplication.UnicodeUTF8))
        self.OutputButton.setText(QtGui.QApplication.translate("ArtTools", "Output Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.FolderSetup), QtGui.QApplication.translate("ArtTools", "UI Conversion", None, QtGui.QApplication.UnicodeUTF8))

