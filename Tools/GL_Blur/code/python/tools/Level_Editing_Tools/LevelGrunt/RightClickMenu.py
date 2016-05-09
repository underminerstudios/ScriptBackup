class HogRightClickMenu ( QMenu ):
	def __init__( self, parent, item ):#
		QMenu.__init__( self, parent )
		#self.addAction( 'Create Group...' ).triggered.connect()
		self.addAction( 'Rename' )
		self.addSeparator()
		self.addAction("Load as Reference");