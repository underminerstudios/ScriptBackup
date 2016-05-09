##
#   :namespace  sandboxdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       08/14/13
#

# we import from blurdev.gui vs. QtGui becuase there are some additional management features for running the Dialog in multiple environments
from blurdev.gui import Dialog
from blurdev import prefs
from PyQt4.QtCore import  Qt, QRect 
from PyQt4.QtGui import QColor 
from PyQt4 import  QtCore, QtGui
from Py3dsMax import mxs # import max module
import PyQt4, os, ast, blurdev
import AnimationTagger.adddialog as AD
from UI.loaduistyle import LoadStyle
ui = LoadStyle()

atfFile =  mxs.maxFilePath + mxs.maxFileName[0:-3] + 'atf'
class AnimTaggerTableModel (QtCore.QAbstractTableModel):
	def __init__(self, tableData = [[]], headers = [], parent = None):
		QtCore.QAbstractTableModel.__init__(self, parent)
		self.__tableData = tableData
		self.__headers = headers
				
	def rowCount(self, parent):
		return len(self.__tableData)	

	def columnCount(self, parent):
#		print len(self.__tableData[0][0])	
		return 3	
		
	def flags(self, index):
		return QtCore.Qt.ItemIsEditable | QtCore.Qt.ItemIsEnabled  | QtCore.Qt.ItemIsSelectable

	def data(self, index, role):
		''''''
		if role == QtCore.Qt.BackgroundRole:
			row = index.row()
			column = index.column()
#			value = self.__tableData[row][column + 1]
			if column == 1:
				return self.__tableData[row][column + 2]
			if column == 2:
				return self.__tableData[row][column + 2]

#
		if role == QtCore.Qt.EditRole:
			row = index.row()
			column = index.column()
			return self.__tableData[row][column]
			
		if role == QtCore.Qt.DisplayRole:
			row = index.row()
			column = index.column()

			value = self.__tableData[row][column]

			return value
		
	def setData(self, index, value, role = QtCore.Qt.EditRole):
		
		if role == QtCore.Qt.EditRole:
			row = index.row()
			column = index.column()
			value = value.toString()
			if column == 1 or column == 2:
				if value.toInt()[1] == True and value != '':
					self.__tableData[row][column] = value
					self.dataChanged.emit(index, index)
					return True
			else:
				if value != '':
					self.__tableData[row][column] = value
					self.dataChanged.emit(index, index)
					return True
		return False

		
	def headerData(self, section, orientation, role):
		if role == QtCore.Qt.DisplayRole:
			if orientation == QtCore.Qt.Horizontal:
				if section < len(self.__headers):
					return self.__headers[section]
				else:
					return "Temp"
			else:
				return QtCore.QString("T%1").arg(section)
				
	def setColor(self, selected, color, role = QtCore.Qt.EditRole):
		for node in selected:
			newData = [str(node[1]),str(node[2]),str(node[3])]
			for item in self.__tableData:
				orgData = [str(item[0]),str(item[1]),str(item[2])]
				if orgData == newData:
					col = node[0][1]
					if col == 1:
						item[3] = color
					if col == 2:
						item[4] = color
	#========================================================#
	#INSERT|REMOVE ROWS
	#========================================================#		


	def getBackroundColor (self, selected, role = QtCore.Qt.EditRole):

		for item in self.__tableData:
			orgData = [str(item[0]),str(item[1]),str(item[2])]
			if orgData == selected:
				return item 
		
	def insertRows(self, position, rows, list, parent = QtCore.QModelIndex()):
		'''Insert Rows'''
		self.beginInsertRows(parent, position, position + rows - 1)
		
		for i in range(rows):
			self.__tableData.insert(position, list)
			
		self.endInsertRows()
		
		return True

	def getModelData (self, parent = QtCore.QModelIndex()):
		data = []
		for item in self.__tableData:

			tagDict 			= {'name': None,'start': None, 'end': None, 'color0': None , 'color1': None }
			tagDict['name'] 	= str(item[0] )
			tagDict['start'] 	= str(item[1] )
			tagDict['end'] 		= str(item[2] )
			Qcolor0 			= item[3] 
			Qcolor1 			= item[4] 
			

			if Qcolor0 != None:
				tagDict['color0'] = str(str(Qcolor0.red()) + "," + str(Qcolor0.green()) + "," + str(Qcolor0.blue()))
			if Qcolor1 != None:
				tagDict['color1'] = str(str(Qcolor1.red()) + "," + str(Qcolor1.green()) + "," + str(Qcolor1.blue()))
			print tagDict
			data.append(tagDict)
		return data
		
#	def returnData(self, index, parent = QtCore.QModelIndex()):
#		return self.__tableData[index.row()]
		
	def removeRow(self, position, rows=1, parent=QtCore.QModelIndex()):
		self.beginRemoveRows(parent, position, position + rows - 1)
		self.__tableData = self.__tableData[:position] + self.__tableData[position + rows:]
		self.endRemoveRows()
		self.dirty = True
		return True
		
	def removeRows(self, selected, parent = QtCore.QModelIndex()):
		'''Some weird behavoir with when using QAbstractTableModel and Proxy Model'''
		newModel = []
		toDelete = []
		for item in self.__tableData:
			newModel.append(item) 
		
		for index in selected:
			newData = [str(index[0]),str(index[1]),str(index[2])]
			for item in newModel:
				orgData = [str(item[0]),str(item[1]),str(item[2])]
				if orgData == newData:
					newModel.remove( item)

		self.beginRemoveRows(parent, 0, len(self.__tableData) )
		self.__tableData = []
		self.endRemoveRows()
		
		for i in range(0, len(newModel)):
			self.beginInsertRows(parent, i, i )
			self.__tableData.insert(0, newModel[i])
			self.endInsertRows()
			
	def insertColumns(self, position, columns, parent = QtCore.QModelIndex()):
		'''Insert Rows'''
		self.beginInsertColumns(parent, position, position + columns - 1)
		
		rowCount = len(self.__tableData)
		
		for i in range(columns):
			for j in range(rowCount):
				self.__tableData[j].insert(position, "test")
			
		self.endInsertColumns()
		return True

class AnimationTaggerDialog( Dialog ):
#	_instance = False
	def __init__( self, parent = None ):
		super(AnimationTaggerDialog,self).__init__( parent )
		blurdev.gui.loadUi( __file__, self )
		self.setStyleSheet(ui.getZStyleSheet())
		tableData = self.getAnimationTagData( atfFile )
		headers = ['Name','Start','End']
		self._proxyModel = QtGui.QSortFilterProxyModel()
		self.model = AnimTaggerTableModel(tableData, headers)
		self._proxyModel.setSourceModel(self.model)
		self._proxyModel.setDynamicSortFilter(True)
		self._proxyModel.setFilterCaseSensitivity(QtCore.Qt.CaseInsensitive)
		
		self.tableView.setModel(self._proxyModel)

		self.connect()


	def connect (self):

		self.tableView.setColumnWidth(0,120)
		self.tableView.setColumnWidth(1,55)
		self.tableView.setColumnWidth(2,40)
		self.tableView.setContextMenuPolicy(Qt.CustomContextMenu)
		self.tableView.customContextMenuRequested.connect(self.setAnimationTimeline)
		
		self.ui_btn_color1.clicked.connect(self.setCellBackgroundColorBtn )
		self.ui_btn_color2.clicked.connect(self.setCellBackgroundColorBtn )
		self.ui_btn_color3.clicked.connect(self.setCellBackgroundColorBtn )
		self.ui_btn_color4.clicked.connect(self.setCellBackgroundColorBtn )
		self.ui_btn_color5.clicked.connect(self.setCellBackgroundColorBtn )
		self.ui_btn_color6.clicked.connect(self.clearCellBackgroundColorBtn )
		self.ui_btn_add.clicked.connect(self.addAnimationTagBtn )
		self.ui_btn_delete.clicked.connect(self.deleteTagBtn )
		self.ui_bnt_clear.clicked.connect(self.clearFilterBtn )
		self.ui_le_filter.textChanged.connect(self.on_le_TextChanged)
		
	def setAnimationTimeline(self):
		r"""
			\remarks    [virtual]   Sets the timeline and the position of the animation
									marker of a given int variable from the table
		"""	
		rowID = self.tableView.selectedIndexes()
		if len(rowID) > 0:
			rowID = rowID[0]
			colID = rowID.column()
			if rowID != -1:
				startFrame = int(rowID.sibling(rowID.row(),1).data(0).toString())
				endFrame = int(rowID.sibling(rowID.row(),2).data(0).toString() )
				mxs.animationRange = mxs.interval( startFrame, endFrame)
				if colID == 1:
					mxs.sliderTime = startFrame
				if colID == 2:
					mxs.sliderTime = endFrame
	
	def clearFilterBtn(self):
		self.ui_le_filter.setText("")
		
		
	def deleteTagBtn(self):
		r"""
			\remarks    Strange behavoir when using QModels with Proxy models
						Had to did in to the table and get the data. Then compare
						the proxy data to qmodel data. Finally delete the correct 
						data.
		"""		
		selTable = self.tableView.selectedIndexes()
		selected = []
		for i in selTable:
			dat= [(i.sibling(i.row(),0).data(0).toString()),\
					(i.sibling(i.row(),1).data(0).toString()),\
					(i.sibling(i.row(),2).data(0).toString())]
			selected.append(dat)
		self.model.removeRows(selected)

			
		
	def addAnimationTagBtn(self):
		r"""
			\remarks    [virtual]   Adds an item to give index
		"""
		addDialog = AD.AddDialog( self )
		parentDialogGeo = self.geometry()
		settingsDialogGeo = addDialog.geometry()
		
		# set up a new position of the add/edit dialog box
		parentDialogGeo.setX(parentDialogGeo.x() + 15)
		parentDialogGeo.setY(parentDialogGeo.y() + 150)
		parentDialogGeo.setWidth(settingsDialogGeo.width())
		parentDialogGeo.setHeight(settingsDialogGeo.height())
		
		indicies = self.tableView.selectedIndexes()
		if len(indicies) > 0:
			rowID = indicies[0].row()
			if rowID != -1:
				#Get the background color to pass to the add dialog box
				selected = [str(indicies[0].sibling(rowID,0).data(0).toString()),\
							str(indicies[0].sibling(rowID,1).data(0).toString()),\
							str(indicies[0].sibling(rowID,2).data(0).toString())]
				rowModelData = self.model.getBackroundColor( selected )
			Qclr0 = rowModelData [3]
			Qclr1 = rowModelData [4]
			print Qclr1
			if Qclr0 != None:
				rgb0 =  (Qclr0.red(), Qclr0.green(), Qclr0.blue())
				
				if rgb0 == (0,0,0):
					addDialog.ui_btn_colorStart.setCurrentIndex(0)
				if rgb0 == (255, 100, 100):
					addDialog.ui_btn_colorStart.setCurrentIndex(1)
				if rgb0 == (0, 170, 255):
					addDialog.ui_btn_colorStart.setCurrentIndex(2)
				if rgb0 == (70, 190, 70):
					addDialog.ui_btn_colorStart.setCurrentIndex(3)
				if rgb0 == (200, 150, 70):
					addDialog.ui_btn_colorStart.setCurrentIndex(4)
				if rgb0 == (253, 242, 120):
					addDialog.ui_btn_colorStart.setCurrentIndex(5)
			if Qclr1 != None:
				rgb1 =  (Qclr1.red(), Qclr1.green(), Qclr1.blue())
				if rgb1 == (0,0,0):
					addDialog.ui_btn_colorEnd.setCurrentIndex(0)
				if rgb1 == (255, 100, 100):
					addDialog.ui_btn_colorEnd.setCurrentIndex(1)
				if rgb1 == (0, 170, 255):
					addDialog.ui_btn_colorEnd.setCurrentIndex(2)
				if rgb1 == (70, 190, 70):
					addDialog.ui_btn_colorEnd.setCurrentIndex(3)
				if rgb1 == (200, 150, 70):
					addDialog.ui_btn_colorEnd.setCurrentIndex(4)
				if rgb1 == (253, 242, 120):
					addDialog.ui_btn_colorEnd.setCurrentIndex(5)
					
		animRange = mxs.animationRange
		addDialog.ui_sb_start.setValue(animRange.start)
		addDialog.ui_sb_end.setValue(animRange.end)

		addDialog.setGeometry( parentDialogGeo )
		addDialog.exec_()
		data = addDialog.getValues()

		if data != None:
			self.model.insertRows(0 , 1, data)


	def clearCellBackgroundColorBtn(self):
		''''''	
		indicies = self.tableView.selectedIndexes()
		selected = []
		for i in indicies:
			dat= [[i.row(), i.column()], (i.sibling(i.row(),0).data(0).toString()),\
					(i.sibling(i.row(),1).data(0).toString()),\
					(i.sibling(i.row(),2).data(0).toString())]
			selected.append(dat)
		
		self.model.setColor(selected, None	)
		
	def setCellBackgroundColorBtn(self):
		r"""
			\remarks    [virtual]   Opens a color dialog and sets the color of the button
		"""
		indicies = self.tableView.selectedIndexes()
		selected = []
		for i in indicies:
			dat= [[i.row(), i.column()], (i.sibling(i.row(),0).data(0).toString()),\
					(i.sibling(i.row(),1).data(0).toString()),\
					(i.sibling(i.row(),2).data(0).toString())]
			selected.append(dat)
		senderBTN = self.sender()
		tkns = str(senderBTN.styleSheet()[21:-2]).split(',')
		color = QColor(int(tkns[0]), int(tkns[1]), int(tkns[2]))
		
		self.model.setColor(selected, color)
		self.tableView.clearSelection()

		

	def on_le_TextChanged(self, text):
		self._proxyModel.setFilterRegExp(text)
		
	def saveCurrentDataModel(self):
		r"""
			\remarks    [virtual]   Saves the current state of the table model
		"""	
		tagList = self.model.getModelData()
		self.saveAnimationTagFile(atfFile, tagList )
		
	def saveAnimationTagFile (self, atfFile, tagList):
		r"""
			\remarks    [virtual]   Saves the atf file
		"""	
		file = open(atfFile, 'w')
		for item in  tagList:
			file.write(str(item) + "\n")
		file.close	
		
		
	def getAnimationTagData(self, path):
		'''Gets the animation tag data'''
		srcData = []
#		print path
		if os.path.isfile(path) == True:
			file = open(path, 'r')
			for line in file:	
				itemDict = ast.literal_eval(line)
				name = itemDict['name']
				start = itemDict['start']
				end = itemDict['end']
				color0 = None
				color1 = None
				
				if itemDict['color0'] != None:
					tokens = itemDict['color0'].split(',')
					color0 = QColor(int(tokens[0]), int(tokens[1]), int(tokens[2]))
					
				if itemDict['color1'] != None:
					tokens = itemDict['color1'].split(',')
					color1 = QColor(int(tokens[0]), int(tokens[1]), int(tokens[2]))
				srcData.append([name, start, end, color0, color1 ])

			file.close
		return srcData

	def closeEvent( self, event ):
		self.recordSettings()
		super(AnimationTaggerDialog,self).closeEvent( event )
		self.saveCurrentDataModel()
		
	def recordSettings( self ):
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/AnimationTagger', shared=True )
		# record the geometry
		pref.recordProperty( 'geom', self.geometry() )
		pref.recordProperty( 'dlgOpen', False)
		pref.save()
		
	def restoreSettings( self ):
		from blurdev import prefs
		# To make a tool save to the local settings remove the shared option.
		pref = prefs.find( 'tools/AnimationTagger', shared=True )
		pref.recordProperty( 'dlgOpen', True)
		pref.save()
		# reload the geometry
		
		geom = pref.restoreProperty( 'geom', QRect() )
		if ( geom and not geom.isNull() ):
			self.setGeometry( geom )
		
	def showEvent ( self, event):
		# restore settings from last session
		self.restoreSettings()


def __main__(  ):
	dialog = AnimationTaggerDialog()
	dialog.show()
	return True
#__main__()

	