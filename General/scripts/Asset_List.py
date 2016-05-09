import win32com.client as win32
import os
import collections

 

# Asks the user for the location of the root folder and places the input into the variable out files
while True:
   OutputFiles = raw_input('What is the parent location of all  the output files?\n')
   if OutputFiles == '':
      print "\n \nNot a valid location \n Please choose a valid location.\n"
   else :
      break


if (__name__ == '__main__'):


# uses the OS pack and gets all the psd files in the folder and gets the final path togher for later use
      print "Stills"
      for root, dirs, files in os.walk(OutputFiles):
            for thisFile in files:
               if (thisFile.lower().endswith('.png')):
                  print thisFile
      print "\n \nAnimated"
      for root, dirs, files in os.walk(OutputFiles):
            for thisFile in files:
               if (thisFile.lower().endswith('.swf')):
                  print  thisFile

raw_input('Press any key to continue.')
