import os
import subprocess
import fnmatch

class Sound_Converter(object):
    
    
    def __init__(self):
        """This will find all of the mp3 files and see if we have wav files.  If we don't print out the list. It also will convert files from mp3 to wav"""
        pass
    
    
    def get_all_the_source_sounds(self,location):
        """Find all the mp3 files and all the wav files"""
        
        all_of_wav = []
        all_of_mp3 = []
        for root,dirnames, filenames in os.walk(location):
            for filename in fnmatch.filter(filenames, "*.mp3"):
                all_of_mp3.append(os.path.join(root,filename))
            for filename in fnmatch.filter(filenames, "*.wav"):
                all_of_wav.append(os.path.join(root,filename))
                
        return all_of_mp3,all_of_wav
    
    
    def convert_the_sounds(self,file_to_convert):
        """checks the type of file and appends to the converted and non converted"""
        
        #if it's a wav tell people were not going to convert it
        if (os.path.splitext(file_to_convert)) == ".wav":
            
            not_converted = "Not_Converted - %s"%(file_to_convert)
            return not_converted  
        
        #if it's converted then tell people it's a file that needs to be converted
        elif (os.path.splitext(file_to_convert)) == ".mp3":
            
            converted = "Converted - %s"%(file_to_convert)
            self.file_conversion_of_sounds(file_to_convert)
            return converted
    
    
    
    def file_conversion_of_sounds(self):
        """find the files that are not converted and convert them"""
        remoteLocation = "C:\Wav"
        homeFolder = "C:\Sounds"
        for root,dirname,filenames in os.walk(homeFolder):
            for filename in filenames:
                if filename.endswith(".mp3"):
                    whatsTheSplit = os.path.split(root)
                    whatsThePath = whatsTheSplit[-1]
                    whatsTheParent = os.path.split(whatsTheSplit[0])[-1]
                    if whatsThePath.lower() == "source":
                        pass
                    elif whatsThePath.lower() == "Sounds":
                        pass
                    else:
                        file_to_convert = os.path.join(root,filename)
                        newFileName = filename.split(".")[0] + ".wav"
                        newPath = os.path.join(remoteLocation,whatsTheParent,
                                                      whatsThePath)
                        outputFileName = os.path.join(remoteLocation,whatsTheParent,
                                                      whatsThePath,newFileName)
                        if not(os.path.exists(newPath)):
                            os.makedirs(newPath)
                        self.convertSounds(file_to_convert,outputFileName)
                    
        
    def convertSounds(self,file_to_convert,outputFileName):
        """Does the actual conversion of the sounds using sox"""
        if os.path.exists(outputFileName):
            os.remove(outputFileName)
        program = r"C:\Program Files (x86)\sox-14-4-2\sox.exe"
        subprocess.call([program, file_to_convert, outputFileName])
        
    
    def runAll(self):
        """call this to start the process"""
        self.file_conversion_of_sounds()
