#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      alexander.halchuk
#
# Created:     09/04/2013
# Copyright:   (c) alexander.halchuk 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import sys
import subprocess
import os
import datetime
from PIL import Image

def main():

    if os.path.isfile('S:\\code\\python\\tools\\Projects\\_Asphalt\\TexConvert\\ddsexport'):
        compresstga()
        compressdds()
        deleteTextureList()

    else:
        print "No DDS File to Export"

def compressdds():
    #Import Texture List from 3dsMax
    #MaxTexArray = str(sys.argv[1])

    #print '3dsMax Texture Array:' , MaxTexArray
    bitarray = open('S:\\code\\python\\tools\\Projects\\_Asphalt\\TexConvert\\ddsexport')

    for line in bitarray:
        val = line.rsplit(',')
        if os.path.isfile(val[0]):
            val[1] = val[1].rstrip('\n')
            compresscmd = ("T:\\libraries\\glitch\\tools\\TextureConverter\\bin\\linux64\\nvcompress.exe -bc3" + " " + val[0] + " " + val[1])
            if os.path.isfile(val[1]):
                imodified = os.path.getmtime(val[0])
                omodified = os.path.getmtime(val[1])
                if imodified >= omodified:
                    subprocess.call(compresscmd)
            else:
                    subprocess.call(compresscmd)
    bitarray.close()

def compresstga():
    bitarray = open('S:\\code\\python\\tools\\Projects\\_Asphalt\\TexConvert\\ddsexport')

    for line in bitarray:
        val = line.rsplit(',')
        tga = val[1].rsplit('.')
        tga[0] = tga[0] + ".tga"
        if os.path.isfile(val[0]):
            compresstgacmd = ("T:\\libraries\\glitch\\tools\\TextureConverter\\bin\\linux\\minmagick\\convert.exe " + val[0] + " " + tga[0])
            if os.path.isfile(tga[0]):
                    imodified = os.path.getmtime(val[0])
                    omodified = os.path.getmtime(tga[0])
                    if imodified >= omodified:
                        if os.path.isfile(tga[0]):
                            os.remove(tga[0])
                        subprocess.call(compresstgacmd)
            else:
                        if os.path.isfile(tga[0]):
                            os.remove(tga[0])
                        subprocess.call(compresstgacmd)
    bitarray.close()

def deleteTextureList():
    if os.path.isfile('S:\\code\\python\\tools\\Projects\\_Asphalt\\TexConvert\\ddsexport'):
        os.remove('S:\\code\\python\\tools\\Projects\\_Asphalt\\TexConvert\\ddsexport')

if __name__ == '__main__':
    main()
