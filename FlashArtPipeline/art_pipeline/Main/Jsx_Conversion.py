import subprocess,os,shutil,time,sys
from time import sleep
reload(sys)
import types
sys.setdefaultencoding("utf-8")

class JsxConverter(object):
        
    def __init__(self):
        """This takes the old java script file and gets it ready for automation into the program that will run it.
        It prepends the file with the correct convention for that program and puts it into the temp location"""
        pass
    
    def makeJavascriptConversion(self,temp_location,program,javascript,fileToConvert):
        
        """Converts the file. Moves it to the new temp location. Returns the new file to run"""
        
        #planning to do a mac verson soon
        if os.name == "nt":
            
            # if it's flash do this one. make the temp file and fix the file names that are going in, prepend that data and return the javascript location to run
            if (program == "Flash"):
                Tempjavascript = self.prependAndRenameJSFile(temp_location,javascript,".jsfl")
                fileToConvert = self.fixFileName(fileToConvert,"Flash")
                self.Prepend(fileToConvert, Tempjavascript)
                return Tempjavascript
            
            # does the photoshop conversion.  Makes a new jsx file in the temp folder.  Fixes the art names. returns the location of the script
            if (program == "Photoshop"):
                Tempjavascript = self.prependAndRenameJSFile(temp_location,javascript,".jsx")
                fileToConvert = self.fixFileName(fileToConvert, "Photoshop")
                self.Prepend(fileToConvert, Tempjavascript)
                return Tempjavascript
            
    def prependAndRenameJSFile(self,temp_location,javascript, extension):
        
        """Puts temp in the file name moves it to the new location removes any contenters that might be there"""
        
        Tempjavascript = os.path.split(javascript)[1].split(".")[0] + "_temp" + extension
        Tempjavascript = os.path.join(temp_location,Tempjavascript)
        javascript = os.path.realpath(javascript)
        if os.path.exists(Tempjavascript):
            os.remove(Tempjavascript)
        shutil.copy2(javascript,Tempjavascript)
        return Tempjavascript
        
    def Prepend(self,endingFiles,Tempjavascript):
        """Prepends the file with the correct name"""
        prepend = 'inputs = %s'%(str(endingFiles))
        self._filePrepender(Tempjavascript, prepend)
        
             
    def fixFileName(self,filesToConvert,DCC):
        """Depending on the program we change the name accordingly"""
        endingFiles = []
        
        #if it's multiple files do this
        if not(isinstance(filesToConvert, types.StringTypes)):
            
            #loop through each file and do the conversion on it
            for fileToConvert in filesToConvert:
                fileToConvert = self._fixFileNameGuts(fileToConvert,DCC)
                endingFiles.append(str(fileToConvert))
                
        #single file do this
        else:
            fileToConvert = self._fixFileNameGuts(filesToConvert,DCC)
            
            #gives the string fake list brackets used for putting into the jsx... goofy but needed
            endingFiles = '["%s"]'%(fileToConvert)
        
        return endingFiles
    
    def _fixFileNameGuts(self,fileToConvert,DCC):
        
        """This does all the actual conversion and if the type is flash it does the super special 'flash is a special snowflake' conversion"""
        
        fileToConvert = fileToConvert.replace("\\","/")
                
        try:
            fileToConvert = fileToConvert.replace("%"," ")
        except:
            pass
        
        if DCC == "Flash":
            fileToConvert = fileToConvert.replace(":","|")
            fileToConvert = "file:///" + fileToConvert

    
    def _filePrepender(self,fileName,WhateToPrepend):
        
        """Prepends the file with the correct information. Must read it into the utf8 file space then back"""
        
        with open(fileName, "r+") as fileToFix:
            fileInfo = fileToFix.read()
            fileInfo = fileInfo.encode('utf8','replace')
            fileToFix.seek(0,0)
            fileToFix.write(WhateToPrepend.rstrip("\r\n") + "\n" + fileInfo)