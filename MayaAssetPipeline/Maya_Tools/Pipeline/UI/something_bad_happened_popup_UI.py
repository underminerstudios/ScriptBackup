# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'C:\Maya_Tools\Pipeline\UI\..\media\something_bad_happened_popup_UI.ui'
#
# Created: Wed May 06 22:23:26 2015
#      by: pyside-uic 0.2.14 running on PySide 1.2.0
#
# WARNING! All changes made in this file will be lost!

from PySide import QtCore, QtGui


class Ui_error_popup(object):
    def setupUi(self, error_popup):
        error_popup.setObjectName("error_popup")
        error_popup.resize(487, 163)
        self.verticalLayout = QtGui.QVBoxLayout(error_popup)
        self.verticalLayout.setObjectName("verticalLayout")
        self.file_hz = QtGui.QHBoxLayout()
        self.file_hz.setObjectName("file_hz")
        spacerItem = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.file_hz.addItem(spacerItem)
        self.file_error = QtGui.QLabel(error_popup)
        font = QtGui.QFont()
        font.setPointSize(20)
        font.setUnderline(True)
        self.file_error.setFont(font)
        self.file_error.setObjectName("file_error")
        self.file_hz.addWidget(self.file_error)
        spacerItem1 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.file_hz.addItem(spacerItem1)
        self.verticalLayout.addLayout(self.file_hz)
        self.error_hz = QtGui.QHBoxLayout()
        self.error_hz.setObjectName("error_hz")
        self.whats_wrong_scroll_box = QtGui.QScrollArea(error_popup)
        self.whats_wrong_scroll_box.setWidgetResizable(True)
        self.whats_wrong_scroll_box.setObjectName("whats_wrong_scroll_box")
        self.scrollAreaWidgetContents = QtGui.QWidget()
        self.scrollAreaWidgetContents.setGeometry(QtCore.QRect(0, 0, 465, 69))
        self.scrollAreaWidgetContents.setObjectName("scrollAreaWidgetContents")
        self.horizontalLayout_2 = QtGui.QHBoxLayout(self.scrollAreaWidgetContents)
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.whatsbroken = QtGui.QPushButton(self.scrollAreaWidgetContents)
        self.whatsbroken.setObjectName("whatsbroken")
        self.horizontalLayout.addWidget(self.whatsbroken)
        self.why = QtGui.QPushButton(self.scrollAreaWidgetContents)
        self.why.setObjectName("why")
        self.horizontalLayout.addWidget(self.why)
        spacerItem2 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem2)
        self.fix_me = QtGui.QPushButton(self.scrollAreaWidgetContents)
        self.fix_me.setObjectName("fix_me")
        self.horizontalLayout.addWidget(self.fix_me)
        self.horizontalLayout_2.addLayout(self.horizontalLayout)
        self.whats_wrong_scroll_box.setWidget(self.scrollAreaWidgetContents)
        self.error_hz.addWidget(self.whats_wrong_scroll_box)
        self.verticalLayout.addLayout(self.error_hz)
        self.use_hz = QtGui.QHBoxLayout()
        self.use_hz.setObjectName("use_hz")
        spacerItem3 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.use_hz.addItem(spacerItem3)
        self.user_cancel = QtGui.QPushButton(error_popup)
        self.user_cancel.setObjectName("user_cancel")
        self.use_hz.addWidget(self.user_cancel)
        self.verticalLayout.addLayout(self.use_hz)

        self.retranslateUi(error_popup)
        QtCore.QMetaObject.connectSlotsByName(error_popup)

    def retranslateUi(self, error_popup):
        error_popup.setWindowTitle(QtGui.QApplication.translate("error_popup", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.file_error.setText(QtGui.QApplication.translate("error_popup", "The following errors have been found!", None, QtGui.QApplication.UnicodeUTF8))
        self.whatsbroken.setText(QtGui.QApplication.translate("error_popup", "whats broken", None, QtGui.QApplication.UnicodeUTF8))
        self.why.setText(QtGui.QApplication.translate("error_popup", "why", None, QtGui.QApplication.UnicodeUTF8))
        self.fix_me.setText(QtGui.QApplication.translate("error_popup", "fix_me", None, QtGui.QApplication.UnicodeUTF8))
        self.user_cancel.setText(QtGui.QApplication.translate("error_popup", "Cancel", None, QtGui.QApplication.UnicodeUTF8))

