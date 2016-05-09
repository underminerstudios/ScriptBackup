
# Recursively scans a folder (psdRoot) for Photoshop PSD files.
# For each, exports various 24-bit PNG textures based on layer
# groups found in the PSD.
# Requires the Win32 Extensions:
# http://python.net/crew/mhammond/win32/
# This is an add on script to the one created by Adam Pletcher 
# posted on his blog Tech Art Tiki
# The added functionality increases the export types to to include 
# many more options, ability for user input to change the folder root, almost all file outputs from photoshop, and the 
# ability to change the output location.
# the origonal script can be found http://techarttiki.blogspot.com/2008/08/photoshop-scripting-with-python.html
 
import win32com.client as win32
import os
import collections


# This is where we get the dictonary that holds all the export types.  It's ordered so that we can iterate through later
exportFileType = collections.OrderedDict([  
      ('1' , '.PSD'),
      ('2' , '.BMP'),
      ('3' , '.GIF'),
      ('4' , '.EPS'),
      ('5' , '.JPEG'),
      ('6' , '.PDF'),
      ('7' , '.RAW'),
      ('8' , '.PXR'),
      ('9' , '.SGI'),
      ('10' , '.TGA'),
      ('11' , '.TIF'),
      ('12' , '.IFF'),
      ('13' , '.PNG (24)'),
      ('14' , '.PNG (24 Save for web)'),
      ('15' , '.PNG (8)'),
      ])


# Asks the user for the location of the root folder and places the input into the variable psRoot
while True:
   psdRoot = raw_input('What is the parent location of all  the psds that you are attempting to export?\n')
   if psdRoot == '':
      print "\n \nNot a valid location please choose \n Please choose a valid location.\n"
   else :
      break
psOutLocation = '0'   
wantACopy = False
# Asks the user if they want to change the file location (this is stored in psdOut which is used later in the location change check).  
#If they do it will ask where they would like it exported out to.  VERY usefull if you are using a game engine that requires all the
# Textures to be in one location.  The location psOutLocation is used later to iterate over the location in 
while True:
   psdOut = raw_input('Do you want to change the location of the output?\n 1 for "yes" 0 for "no"\n')
   if psdOut == '1':
      while True:
         psOutLocation = raw_input('What is the location that you would like to export out to? \n')
         if psOutLocation == '':
            print "\n \nNot a valid location please choose \n Please choose a valid location.\n"

         else :
            wantACopy = True
            break
      break
   if psdOut == '0':
      break
   else :
      print "\n \nNot a valid selection please choose \n Please choose 1 or 0.\n"


invalidInput = True

# Warns people to wait because photoshop is loading... which TAKES FOREVER at times.

print 'Do not press enter again.  Loading photoshop.  This could take quite some time.  \n  When photoshop has loaded come back to this screen. \n'       

if (__name__ == '__main__'):
   # COM dispatch for Photoshop
   psApp = win32.Dispatch('Photoshop.Application')

 
   # Photoshop actually exposes several different COM interfaces,
   # including one specifically for classes defining export options.

# This is the KEY to the entire thing.  It finds out what output the user wants and catches the value in exportType for later use.  Also it error checks.

while invalidInput :
   invalidInput = False
   print 'Export types are as follows:\n'  + '\n'.join([(key + ': ' + value) for key,value in exportFileType.items()])
   exportType = raw_input('What export type would you like?\n')
   if exportType == "1":
      options = win32.Dispatch("Photoshop.PhotoshopSaveOptions")
      extension = '.psd'
   elif exportType == "2":
      options = win32.Dispatch("Photoshop.BMPSaveOptions")
      extension = '.bmp'
   elif exportType == "3":
      options = win32.Dispatch("Photoshop.GIFSaveOptions")
      extension = '.gif'  
   elif exportType == "4":
      options = win32.Dispatch("Photoshop.EPSSaveOptions")
      extension = '.EPS'
   elif exportType == "5":
      options = win32.Dispatch("Photoshop.JPEGSaveOptions")
      extension = '.jpeg'
   elif exportType == "6":
      options = win32.Dispatch("Photoshop.PDFSaveOptions")
      extension = '.PDF'
   elif exportType == "7":
      options = win32.Dispatch("Photoshop.RAWSaveOptions")
      extension = '.raw'
   elif exportType == "8":
      options = win32.Dispatch("Photoshop.PixarSaveOptions")
      extension = '.pxr'
   elif exportType == "9":
      options = win32.Dispatch("Photoshop.SGIRGBSaveOptions")
      extension = '.sgi'
   elif exportType == "10":
      options = win32.Dispatch("Photoshop.TargaSaveOptions")
      extension = '.tga'
   elif exportType == "11":
      options = win32.Dispatch("Photoshop.TiffSaveOptions")
      extension = '.tif'
   elif exportType == "12":
      options = win32.Dispatch("Photoshop.ALIASPIXSaveOptions")
      extension = '.iff'
   elif exportType == "13":
      options = win32.Dispatch("Photoshop.PNGSaveOptions")
      extension = '.png'
   elif exportType == "14":
      options = win32.Dispatch('Photoshop.ExportOptionsSaveForWeb')
      options.Format = 13   # PNG
      options.PNG8 = False  # Sets it to PNG-24 bit
      extension = '.png'
   elif exportType == "15":
      options = win32.Dispatch('Photoshop.ExportOptionsSaveForWeb')
      options.Format = 13   # PNG
      extension = '.png'
   else:
      invalidInput = True
      print '\n \n \n \n \n \n \n This is not a vilid input select one from the list below.'

print '\n\n\n\n\n Note if there is nothing exported out of a file no notification will be displayed! \n \n \n'

# gets the psd files into a open dict
 
psdFiles = []

# uses the OS pack and gets all the psd files in the folder and gets the final path togher for later use
 
for root, dirs, files in os.walk(psdRoot):
      for thisFile in files:
         if (thisFile.lower().endswith('.psd')):
            fullFilename = os.path.join(root, thisFile)
            psdFiles.append(fullFilename)
 
   # Loop through PSDs we found gets the layer sets in the file and puts them into the variable layerSets
for psdFile in psdFiles:
      doc = psApp.Open(psdFile)
      layerSets = doc.LayerSets
 
      if (len(layerSets) > 0):
         # First hide all root-level layers

         
         for layerSet in layerSets:
            layerSet.Visible = False
            
         
         for layerSet in layerSets:
            lsName = layerSet.Name.lower()
 
            for i in lsName:
               layerSet.Visible = True  # make visible again

               # Make our export filename also checks aginst the psdOut from earlier.  If the user wanted to change the directory it will take the 
               # location that the user inputed above and save out to that location. or if they didn't it will just export out to the origonal folder

               if psdOut == '1' :
                  copyFile = os.path.basename(psdFile)
                  finishedFile = os.path.join(psOutLocation , os.path.splitext(copyFile)[0] + lsName + extension.lower())
               else :
                  finishedFile = os.path.splitext(psdFile)[0] + lsName + extension.lower()


 
                  # If file exists but older than PSD, delete it.


                  if (os.path.exists(finishedFile)):
                        psdTime = os.stat(psdFile)[8]
                        exportTime = os.stat(finishedFile)[8]

                        if (psdTime > exportTime):
                           os.remove(finishedFile)

                  if (not os.path.exists(finishedFile)):
                        doc = psApp.Open(psdFile)
                        doc.SaveAs(finishedFile, options, True)
                        print 'exporting:', finishedFile
                     
               # Make LayerSet invisible again
               layerSet.Visible = False
 
         # Close PSD without saving
         doc.Close(2)
print '\n \n \nExporting is Finished!'
raw_input('Press any key to continue.')
