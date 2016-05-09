# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'C:\Art_Tools\workspace\art_pipeline\UI\Raw\Main_UI.ui'
#
# Created: Wed Nov 04 17:26:17 2015
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
        self.label_3 = QtGui.QLabel(self.FolderSetup)
        self.label_3.setObjectName("label_3")
        self.verticalLayout_2.addWidget(self.label_3)
        self.horizontalLayout_3 = QtGui.QHBoxLayout()
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        self.GameName = QtGui.QLabel(self.FolderSetup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.GameName.setFont(font)
        self.GameName.setObjectName("GameName")
        self.horizontalLayout_3.addWidget(self.GameName)
        self.GameNameInput = QtGui.QLineEdit(self.FolderSetup)
        self.GameNameInput.setObjectName("GameNameInput")
        self.horizontalLayout_3.addWidget(self.GameNameInput)
        self.verticalLayout_2.addLayout(self.horizontalLayout_3)
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.GameType = QtGui.QLabel(self.FolderSetup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.GameType.setFont(font)
        self.GameType.setObjectName("GameType")
        self.horizontalLayout_2.addWidget(self.GameType)
        self.GameTypeComboBox = QtGui.QComboBox(self.FolderSetup)
        self.GameTypeComboBox.setObjectName("GameTypeComboBox")
        self.GameTypeComboBox.addItem("")
        self.GameTypeComboBox.addItem("")
        self.GameTypeComboBox.addItem("")
        self.GameTypeComboBox.addItem("")
        self.GameTypeComboBox.addItem("")
        self.GameTypeComboBox.addItem("")
        self.horizontalLayout_2.addWidget(self.GameTypeComboBox)
        self.verticalLayout_2.addLayout(self.horizontalLayout_2)
        self.horizontalLayout_5 = QtGui.QHBoxLayout()
        self.horizontalLayout_5.setObjectName("horizontalLayout_5")
        self.NumberOfPicks = QtGui.QLabel(self.FolderSetup)
        self.NumberOfPicks.setEnabled(True)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.NumberOfPicks.setFont(font)
        self.NumberOfPicks.setObjectName("NumberOfPicks")
        self.horizontalLayout_5.addWidget(self.NumberOfPicks)
        self.NumberOfPicksInput = QtGui.QLineEdit(self.FolderSetup)
        self.NumberOfPicksInput.setEnabled(True)
        self.NumberOfPicksInput.setObjectName("NumberOfPicksInput")
        self.horizontalLayout_5.addWidget(self.NumberOfPicksInput)
        self.verticalLayout_2.addLayout(self.horizontalLayout_5)
        self.horizontalLayout_10 = QtGui.QHBoxLayout()
        self.horizontalLayout_10.setObjectName("horizontalLayout_10")
        spacerItem = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_10.addItem(spacerItem)
        self.RotelleCheckBox = QtGui.QCheckBox(self.FolderSetup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.RotelleCheckBox.setFont(font)
        self.RotelleCheckBox.setObjectName("RotelleCheckBox")
        self.horizontalLayout_10.addWidget(self.RotelleCheckBox)
        self.verticalLayout_2.addLayout(self.horizontalLayout_10)
        spacerItem1 = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_2.addItem(spacerItem1)
        self.TopTab.addTab(self.FolderSetup, "")
        self.ArtExport = QtGui.QWidget()
        self.ArtExport.setObjectName("ArtExport")
        self.verticalLayout_3 = QtGui.QVBoxLayout(self.ArtExport)
        self.verticalLayout_3.setObjectName("verticalLayout_3")
        self.label_2 = QtGui.QLabel(self.ArtExport)
        self.label_2.setObjectName("label_2")
        self.verticalLayout_3.addWidget(self.label_2)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.GameFolder = QtGui.QLabel(self.ArtExport)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.GameFolder.setFont(font)
        self.GameFolder.setObjectName("GameFolder")
        self.horizontalLayout.addWidget(self.GameFolder)
        self.GameFolderLocation = QtGui.QLineEdit(self.ArtExport)
        self.GameFolderLocation.setObjectName("GameFolderLocation")
        self.horizontalLayout.addWidget(self.GameFolderLocation)
        self.GameFolderFinder = QtGui.QToolButton(self.ArtExport)
        self.GameFolderFinder.setObjectName("GameFolderFinder")
        self.horizontalLayout.addWidget(self.GameFolderFinder)
        self.verticalLayout_3.addLayout(self.horizontalLayout)
        self.horizontalLayout_7 = QtGui.QHBoxLayout()
        self.horizontalLayout_7.setObjectName("horizontalLayout_7")
        self.RoomNumberLabel = QtGui.QLabel(self.ArtExport)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.RoomNumberLabel.setFont(font)
        self.RoomNumberLabel.setObjectName("RoomNumberLabel")
        self.horizontalLayout_7.addWidget(self.RoomNumberLabel)
        self.RoomNumber = QtGui.QLineEdit(self.ArtExport)
        self.RoomNumber.setObjectName("RoomNumber")
        self.horizontalLayout_7.addWidget(self.RoomNumber)
        self.verticalLayout_3.addLayout(self.horizontalLayout_7)
        self.horizontalLayout_9 = QtGui.QHBoxLayout()
        self.horizontalLayout_9.setObjectName("horizontalLayout_9")
        spacerItem2 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_9.addItem(spacerItem2)
        self.OldNamingConvention = QtGui.QCheckBox(self.ArtExport)
        self.OldNamingConvention.setObjectName("OldNamingConvention")
        self.horizontalLayout_9.addWidget(self.OldNamingConvention)
        self.verticalLayout_3.addLayout(self.horizontalLayout_9)
        spacerItem3 = QtGui.QSpacerItem(20, 166, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_3.addItem(spacerItem3)
        self.TopTab.addTab(self.ArtExport, "")
        self.tab = QtGui.QWidget()
        self.tab.setObjectName("tab")
        self.verticalLayout_5 = QtGui.QVBoxLayout(self.tab)
        self.verticalLayout_5.setObjectName("verticalLayout_5")
        self.ArtRepo_2 = QtGui.QLabel(self.tab)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.ArtRepo_2.setFont(font)
        self.ArtRepo_2.setObjectName("ArtRepo_2")
        self.verticalLayout_5.addWidget(self.ArtRepo_2)
        self.horizontalLayout_8 = QtGui.QHBoxLayout()
        self.horizontalLayout_8.setObjectName("horizontalLayout_8")
        self.ArtRepo_3 = QtGui.QLabel(self.tab)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.ArtRepo_3.setFont(font)
        self.ArtRepo_3.setObjectName("ArtRepo_3")
        self.horizontalLayout_8.addWidget(self.ArtRepo_3)
        self.ArtRepoLocation_2 = QtGui.QLineEdit(self.tab)
        self.ArtRepoLocation_2.setObjectName("ArtRepoLocation_2")
        self.horizontalLayout_8.addWidget(self.ArtRepoLocation_2)
        self.ArtRepoFolder_2 = QtGui.QToolButton(self.tab)
        self.ArtRepoFolder_2.setObjectName("ArtRepoFolder_2")
        self.horizontalLayout_8.addWidget(self.ArtRepoFolder_2)
        self.verticalLayout_5.addLayout(self.horizontalLayout_8)
        spacerItem4 = QtGui.QSpacerItem(20, 147, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_5.addItem(spacerItem4)
        self.TopTab.addTab(self.tab, "")
        self.Setup = QtGui.QWidget()
        self.Setup.setObjectName("Setup")
        self.verticalLayout_4 = QtGui.QVBoxLayout(self.Setup)
        self.verticalLayout_4.setObjectName("verticalLayout_4")
        self.label_4 = QtGui.QLabel(self.Setup)
        self.label_4.setObjectName("label_4")
        self.verticalLayout_4.addWidget(self.label_4)
        self.horizontalLayout_4 = QtGui.QHBoxLayout()
        self.horizontalLayout_4.setObjectName("horizontalLayout_4")
        self.ArtRepo = QtGui.QLabel(self.Setup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.ArtRepo.setFont(font)
        self.ArtRepo.setObjectName("ArtRepo")
        self.horizontalLayout_4.addWidget(self.ArtRepo)
        self.ArtRepoLocation = QtGui.QLineEdit(self.Setup)
        self.ArtRepoLocation.setObjectName("ArtRepoLocation")
        self.horizontalLayout_4.addWidget(self.ArtRepoLocation)
        self.ArtRepoFolder = QtGui.QToolButton(self.Setup)
        self.ArtRepoFolder.setObjectName("ArtRepoFolder")
        self.horizontalLayout_4.addWidget(self.ArtRepoFolder)
        self.verticalLayout_4.addLayout(self.horizontalLayout_4)
        self.horizontalLayout_6 = QtGui.QHBoxLayout()
        self.horizontalLayout_6.setObjectName("horizontalLayout_6")
        self.SlotsFolderLabel = QtGui.QLabel(self.Setup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.SlotsFolderLabel.setFont(font)
        self.SlotsFolderLabel.setObjectName("SlotsFolderLabel")
        self.horizontalLayout_6.addWidget(self.SlotsFolderLabel)
        self.SlotsFolderLocation = QtGui.QLineEdit(self.Setup)
        self.SlotsFolderLocation.setObjectName("SlotsFolderLocation")
        self.horizontalLayout_6.addWidget(self.SlotsFolderLocation)
        self.SlotsFolder = QtGui.QToolButton(self.Setup)
        self.SlotsFolder.setObjectName("SlotsFolder")
        self.horizontalLayout_6.addWidget(self.SlotsFolder)
        self.verticalLayout_4.addLayout(self.horizontalLayout_6)
        self.pushButton = QtGui.QPushButton(self.Setup)
        self.pushButton.setObjectName("pushButton")
        self.verticalLayout_4.addWidget(self.pushButton)
        spacerItem5 = QtGui.QSpacerItem(20, 166, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_4.addItem(spacerItem5)
        self.TopTab.addTab(self.Setup, "")
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
        self.label_3.setText(QtGui.QApplication.translate("ArtTools", "Make A New Level Based off of Template", None, QtGui.QApplication.UnicodeUTF8))
        self.GameName.setText(QtGui.QApplication.translate("ArtTools", "Game Name", None, QtGui.QApplication.UnicodeUTF8))
        self.GameNameInput.setText(QtGui.QApplication.translate("ArtTools", "Example: Lucky Lotus", None, QtGui.QApplication.UnicodeUTF8))
        self.GameType.setText(QtGui.QApplication.translate("ArtTools", "Game Type", None, QtGui.QApplication.UnicodeUTF8))
        self.GameTypeComboBox.setItemText(0, QtGui.QApplication.translate("ArtTools", "Type?", None, QtGui.QApplication.UnicodeUTF8))
        self.GameTypeComboBox.setItemText(1, QtGui.QApplication.translate("ArtTools", "Theamed", None, QtGui.QApplication.UnicodeUTF8))
        self.GameTypeComboBox.setItemText(2, QtGui.QApplication.translate("ArtTools", "Pick till you poop", None, QtGui.QApplication.UnicodeUTF8))
        self.GameTypeComboBox.setItemText(3, QtGui.QApplication.translate("ArtTools", "Fixed Pick", None, QtGui.QApplication.UnicodeUTF8))
        self.GameTypeComboBox.setItemText(4, QtGui.QApplication.translate("ArtTools", "Free Spin", None, QtGui.QApplication.UnicodeUTF8))
        self.GameTypeComboBox.setItemText(5, QtGui.QApplication.translate("ArtTools", "Modified", None, QtGui.QApplication.UnicodeUTF8))
        self.NumberOfPicks.setText(QtGui.QApplication.translate("ArtTools", "Number of Picks", None, QtGui.QApplication.UnicodeUTF8))
        self.NumberOfPicksInput.setText(QtGui.QApplication.translate("ArtTools", "Leave Alone if not needed.", None, QtGui.QApplication.UnicodeUTF8))
        self.RotelleCheckBox.setText(QtGui.QApplication.translate("ArtTools", "Rotelle", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.FolderSetup), QtGui.QApplication.translate("ArtTools", "Cheese Burger", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setText(QtGui.QApplication.translate("ArtTools", "Convert Art to work in Art World OR Non Rotelle Conversion for Producers", None, QtGui.QApplication.UnicodeUTF8))
        self.GameFolder.setText(QtGui.QApplication.translate("ArtTools", "Game Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.GameFolderFinder.setText(QtGui.QApplication.translate("ArtTools", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.RoomNumberLabel.setText(QtGui.QApplication.translate("ArtTools", "Room Number", None, QtGui.QApplication.UnicodeUTF8))
        self.RoomNumber.setText(QtGui.QApplication.translate("ArtTools", "Room Number", None, QtGui.QApplication.UnicodeUTF8))
        self.OldNamingConvention.setText(QtGui.QApplication.translate("ArtTools", "Old Naming Convention", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.ArtExport), QtGui.QApplication.translate("ArtTools", "French Fries", None, QtGui.QApplication.UnicodeUTF8))
        self.ArtRepo_2.setText(QtGui.QApplication.translate("ArtTools", "Convert Art to a Rotelle Game", None, QtGui.QApplication.UnicodeUTF8))
        self.ArtRepo_3.setText(QtGui.QApplication.translate("ArtTools", "Game Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.ArtRepoFolder_2.setText(QtGui.QApplication.translate("ArtTools", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.tab), QtGui.QApplication.translate("ArtTools", "Apple Pie Maker", None, QtGui.QApplication.UnicodeUTF8))
        self.label_4.setText(QtGui.QApplication.translate("ArtTools", "Tell us where your stuff lives!", None, QtGui.QApplication.UnicodeUTF8))
        self.ArtRepo.setText(QtGui.QApplication.translate("ArtTools", "Bingo Assets / Art Playground", None, QtGui.QApplication.UnicodeUTF8))
        self.ArtRepoFolder.setText(QtGui.QApplication.translate("ArtTools", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsFolderLabel.setText(QtGui.QApplication.translate("ArtTools", "Slots Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsFolder.setText(QtGui.QApplication.translate("ArtTools", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton.setText(QtGui.QApplication.translate("ArtTools", "PushButton", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.Setup), QtGui.QApplication.translate("ArtTools", "Setup", None, QtGui.QApplication.UnicodeUTF8))
