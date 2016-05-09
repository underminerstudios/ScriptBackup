import tkFileDialog,Tkinter,sys
from Tkinter import *


# class that creates the buttons for tkinter to run.  Makes a os specific directory popup and checks for a valid input.
class Command:
	def __init__(self, title, complaint_message):
		self.title = title
		self.complaint_message = complaint_message
		
	def button(self):
		while True:
			def quit(root):
				root
				root.destroy()
			root = Tkinter.Tk()
			root.withdraw()
			firstFile = tkFileDialog.askdirectory(parent = root, title = self.title)
			if firstFile == '': 
				print self.complaint_message
				print "Exiting Now\n\n"
				sys.exit()
			else:
				#tells the system to run UI
				return firstFile 
				break