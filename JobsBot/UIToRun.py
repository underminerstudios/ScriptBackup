import sys,tkFileDialog,Tkinter,os,time
from Tkinter import *
#change this to the code folder that unzipped with the rest of the scripts
sys.path.append('C:\Users\Alex Porter\Desktop\Scripts\Code')
import run

#user interface class for tkinter mostly self explanitory with defs below
class UserInterface:
    def __init__(self, master):
        frame = Frame(master)
        frame.pack()

        self.GetWebInfoButton = Button(frame, 
                             text      =  "Get Web Info",
                             command   =  self.GetWebInfo)
        self.GetWebInfoButton.pack(side=LEFT)
        self.GetJobInfo = Button(frame, 
                             text      =  "Get Job Info",
                             command   =  self.GetJobInfo)
        self.GetJobInfo.pack(side=LEFT)
        self.OpenJobs = Button(frame, 
                             text      =  "Open Jobs",
                             command   =  self.OpenJobInfo)
        self.OpenJobs.pack(side=LEFT)
        
        
    def GetWebInfo(self):
        getItGoing = run.makeThingsGo()
        getItGoing.GetWebsitesAndPeople()
        
    def GetJobInfo(self):
        getItGoing = run.makeThingsGo()
        getItGoing.getWebsites()
        
    def OpenJobInfo(self):
        filesToOpen = self.button("Open Job Txts", [('TXT', '*.txt')], "Need to select something", False)
        getItGoing = run.makeThingsGo()
        getItGoing.openBookMarks(filesToOpen)
        
    def button(self, title, file_types, complaint_message, multiple):
        #this is the buttons. for tkinter
        while True:
            def quit(root):
                root
                root.destroy()
            root = Tkinter.Tk()
            root.withdraw()
            firstFile = tkFileDialog.askopenfilenames(parent=root, filetypes=file_types, title=title, multiple=multiple)
            splitter = firstFile[0]
            user_selections = "".join(list(firstFile))
            user_selections = user_selections.split(splitter)
            selections = []
            
            #the first object in the array always produces a useless unicode string...
            for x in range(1,len(user_selections)):
                selections.append(splitter + user_selections[x])
                
            if firstFile == '':
                print self.complaint_message
                print "Exiting Now\n\n"
                sys.exit()
            else:
                # tells the system to run UI
                return selections
                break

#runs tkinter and killes the script when the main loop finishes
root = Tk()
app = UserInterface(root)
root.mainloop()
sys.exit()
