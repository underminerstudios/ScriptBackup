# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'C:\Art_Tools\workspace\art_pipeline\UI\Raw\UnityConversion.ui'
#
# Created: Sat Nov 21 04:40:56 2015
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
        self.SlotsGameName = QtGui.QLabel(self.FolderSetup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.SlotsGameName.setFont(font)
        self.SlotsGameName.setObjectName("SlotsGameName")
        self.horizontalLayout.addWidget(self.SlotsGameName)
        self.BingoMapNumber = QtGui.QSpinBox(self.FolderSetup)
        self.BingoMapNumber.setObjectName("BingoMapNumber")
        self.horizontalLayout.addWidget(self.BingoMapNumber)
        spacerItem = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem)
        self.verticalLayout_2.addLayout(self.horizontalLayout)
        spacerItem1 = QtGui.QSpacerItem(20, 138, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_2.addItem(spacerItem1)
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        spacerItem2 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_2.addItem(spacerItem2)
        self.BingoAll = QtGui.QCheckBox(self.FolderSetup)
        self.BingoAll.setObjectName("BingoAll")
        self.horizontalLayout_2.addWidget(self.BingoAll)
        self.verticalLayout_2.addLayout(self.horizontalLayout_2)
        self.TopTab.addTab(self.FolderSetup, "")
        self.tab_2 = QtGui.QWidget()
        self.tab_2.setObjectName("tab_2")
        self.verticalLayout_5 = QtGui.QVBoxLayout(self.tab_2)
        self.verticalLayout_5.setObjectName("verticalLayout_5")
        self.horizontalLayout_5 = QtGui.QHBoxLayout()
        self.horizontalLayout_5.setObjectName("horizontalLayout_5")
        self.SlotsGameName_3 = QtGui.QLabel(self.tab_2)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.SlotsGameName_3.setFont(font)
        self.SlotsGameName_3.setObjectName("SlotsGameName_3")
        self.horizontalLayout_5.addWidget(self.SlotsGameName_3)
        self.BingoMapAtlasNumber = QtGui.QSpinBox(self.tab_2)
        self.BingoMapAtlasNumber.setObjectName("BingoMapAtlasNumber")
        self.horizontalLayout_5.addWidget(self.BingoMapAtlasNumber)
        spacerItem3 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_5.addItem(spacerItem3)
        self.verticalLayout_5.addLayout(self.horizontalLayout_5)
        spacerItem4 = QtGui.QSpacerItem(20, 138, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_5.addItem(spacerItem4)
        self.horizontalLayout_7 = QtGui.QHBoxLayout()
        self.horizontalLayout_7.setObjectName("horizontalLayout_7")
        spacerItem5 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_7.addItem(spacerItem5)
        self.BingoAtlasAll = QtGui.QCheckBox(self.tab_2)
        self.BingoAtlasAll.setObjectName("BingoAtlasAll")
        self.horizontalLayout_7.addWidget(self.BingoAtlasAll)
        self.verticalLayout_5.addLayout(self.horizontalLayout_7)
        self.TopTab.addTab(self.tab_2, "")
        self.tab = QtGui.QWidget()
        self.tab.setObjectName("tab")
        self.verticalLayout_3 = QtGui.QVBoxLayout(self.tab)
        self.verticalLayout_3.setObjectName("verticalLayout_3")
        self.horizontalLayout_3 = QtGui.QHBoxLayout()
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        self.SlotsGameName_2 = QtGui.QLabel(self.tab)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.SlotsGameName_2.setFont(font)
        self.SlotsGameName_2.setObjectName("SlotsGameName_2")
        self.horizontalLayout_3.addWidget(self.SlotsGameName_2)
        self.SlotsMapNumber = QtGui.QSpinBox(self.tab)
        self.SlotsMapNumber.setObjectName("SlotsMapNumber")
        self.horizontalLayout_3.addWidget(self.SlotsMapNumber)
        spacerItem6 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_3.addItem(spacerItem6)
        self.verticalLayout_3.addLayout(self.horizontalLayout_3)
        spacerItem7 = QtGui.QSpacerItem(20, 138, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_3.addItem(spacerItem7)
        self.horizontalLayout_4 = QtGui.QHBoxLayout()
        self.horizontalLayout_4.setObjectName("horizontalLayout_4")
        spacerItem8 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_4.addItem(spacerItem8)
        self.SlotsAll = QtGui.QCheckBox(self.tab)
        self.SlotsAll.setObjectName("SlotsAll")
        self.horizontalLayout_4.addWidget(self.SlotsAll)
        self.verticalLayout_3.addLayout(self.horizontalLayout_4)
        self.TopTab.addTab(self.tab, "")
        self.tab_3 = QtGui.QWidget()
        self.tab_3.setObjectName("tab_3")
        self.verticalLayout_6 = QtGui.QVBoxLayout(self.tab_3)
        self.verticalLayout_6.setObjectName("verticalLayout_6")
        self.horizontalLayout_9 = QtGui.QHBoxLayout()
        self.horizontalLayout_9.setObjectName("horizontalLayout_9")
        self.SlotsGameName_4 = QtGui.QLabel(self.tab_3)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.SlotsGameName_4.setFont(font)
        self.SlotsGameName_4.setObjectName("SlotsGameName_4")
        self.horizontalLayout_9.addWidget(self.SlotsGameName_4)
        self.SlotsMapAtlasNumber = QtGui.QSpinBox(self.tab_3)
        self.SlotsMapAtlasNumber.setObjectName("SlotsMapAtlasNumber")
        self.horizontalLayout_9.addWidget(self.SlotsMapAtlasNumber)
        spacerItem9 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_9.addItem(spacerItem9)
        self.verticalLayout_6.addLayout(self.horizontalLayout_9)
        spacerItem10 = QtGui.QSpacerItem(20, 138, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_6.addItem(spacerItem10)
        self.horizontalLayout_8 = QtGui.QHBoxLayout()
        self.horizontalLayout_8.setObjectName("horizontalLayout_8")
        spacerItem11 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_8.addItem(spacerItem11)
        self.SlotsAtlasAll = QtGui.QCheckBox(self.tab_3)
        self.SlotsAtlasAll.setObjectName("SlotsAtlasAll")
        self.horizontalLayout_8.addWidget(self.SlotsAtlasAll)
        self.verticalLayout_6.addLayout(self.horizontalLayout_8)
        self.TopTab.addTab(self.tab_3, "")
        self.Setup = QtGui.QWidget()
        self.Setup.setObjectName("Setup")
        self.verticalLayout_4 = QtGui.QVBoxLayout(self.Setup)
        self.verticalLayout_4.setObjectName("verticalLayout_4")
        self.label_4 = QtGui.QLabel(self.Setup)
        self.label_4.setObjectName("label_4")
        self.verticalLayout_4.addWidget(self.label_4)
        self.horizontalLayout_6 = QtGui.QHBoxLayout()
        self.horizontalLayout_6.setObjectName("horizontalLayout_6")
        self.ProdBacklogTrunkLabel = QtGui.QLabel(self.Setup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.ProdBacklogTrunkLabel.setFont(font)
        self.ProdBacklogTrunkLabel.setObjectName("ProdBacklogTrunkLabel")
        self.horizontalLayout_6.addWidget(self.ProdBacklogTrunkLabel)
        self.ProdBacklogTrunkFolderLocation = QtGui.QLineEdit(self.Setup)
        self.ProdBacklogTrunkFolderLocation.setObjectName("ProdBacklogTrunkFolderLocation")
        self.horizontalLayout_6.addWidget(self.ProdBacklogTrunkFolderLocation)
        self.ProdBacklogTrunkButton = QtGui.QToolButton(self.Setup)
        self.ProdBacklogTrunkButton.setObjectName("ProdBacklogTrunkButton")
        self.horizontalLayout_6.addWidget(self.ProdBacklogTrunkButton)
        self.verticalLayout_4.addLayout(self.horizontalLayout_6)
        self.horizontalLayout_10 = QtGui.QHBoxLayout()
        self.horizontalLayout_10.setObjectName("horizontalLayout_10")
        self.ProdBacklogTrunkLabel_2 = QtGui.QLabel(self.Setup)
        font = QtGui.QFont()
        font.setPointSize(20)
        self.ProdBacklogTrunkLabel_2.setFont(font)
        self.ProdBacklogTrunkLabel_2.setObjectName("ProdBacklogTrunkLabel_2")
        self.horizontalLayout_10.addWidget(self.ProdBacklogTrunkLabel_2)
        self.BingoBlitzUnityArtLocation = QtGui.QLineEdit(self.Setup)
        self.BingoBlitzUnityArtLocation.setObjectName("BingoBlitzUnityArtLocation")
        self.horizontalLayout_10.addWidget(self.BingoBlitzUnityArtLocation)
        self.BingoBlitzUnityArtButton = QtGui.QToolButton(self.Setup)
        self.BingoBlitzUnityArtButton.setObjectName("BingoBlitzUnityArtButton")
        self.horizontalLayout_10.addWidget(self.BingoBlitzUnityArtButton)
        self.verticalLayout_4.addLayout(self.horizontalLayout_10)
        spacerItem12 = QtGui.QSpacerItem(20, 166, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_4.addItem(spacerItem12)
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
        self.SlotsGameName.setText(QtGui.QApplication.translate("ArtTools", "Level", None, QtGui.QApplication.UnicodeUTF8))
        self.BingoAll.setText(QtGui.QApplication.translate("ArtTools", "All", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.FolderSetup), QtGui.QApplication.translate("ArtTools", "Bingo Map Conversion", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsGameName_3.setText(QtGui.QApplication.translate("ArtTools", "Level", None, QtGui.QApplication.UnicodeUTF8))
        self.BingoAtlasAll.setText(QtGui.QApplication.translate("ArtTools", "All", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.tab_2), QtGui.QApplication.translate("ArtTools", "Bingo Atlas Conversion", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsGameName_2.setText(QtGui.QApplication.translate("ArtTools", "Level", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsAll.setText(QtGui.QApplication.translate("ArtTools", "All", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.tab), QtGui.QApplication.translate("ArtTools", "Slots Map Conversion", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsGameName_4.setText(QtGui.QApplication.translate("ArtTools", "Level", None, QtGui.QApplication.UnicodeUTF8))
        self.SlotsAtlasAll.setText(QtGui.QApplication.translate("ArtTools", "All", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.tab_3), QtGui.QApplication.translate("ArtTools", "Slots Atlas Conversion", None, QtGui.QApplication.UnicodeUTF8))
        self.label_4.setText(QtGui.QApplication.translate("ArtTools", "Tell us where your stuff lives!", None, QtGui.QApplication.UnicodeUTF8))
        self.ProdBacklogTrunkLabel.setText(QtGui.QApplication.translate("ArtTools", "Prod BacklogTrunk", None, QtGui.QApplication.UnicodeUTF8))
        self.ProdBacklogTrunkButton.setText(QtGui.QApplication.translate("ArtTools", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.ProdBacklogTrunkLabel_2.setText(QtGui.QApplication.translate("ArtTools", "Bingo Blitz Unity Art Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.BingoBlitzUnityArtButton.setText(QtGui.QApplication.translate("ArtTools", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.TopTab.setTabText(self.TopTab.indexOf(self.Setup), QtGui.QApplication.translate("ArtTools", "Unity Setup", None, QtGui.QApplication.UnicodeUTF8))

