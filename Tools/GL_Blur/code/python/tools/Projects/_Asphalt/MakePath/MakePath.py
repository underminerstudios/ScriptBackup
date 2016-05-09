#-------------------------------------------------------------------------------
# Name:        makedirectories
# Purpose:
#
# Author:      alexander.halchuk
#
# Created:     26/04/2013
# Copyright:   (c) alexander.halchuk 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import os
import sys



def main(argv):


    outputpath = argv[0]
    if not os.path.exists(outputpath):
        os.makedirs(outputpath)

if __name__ == '__main__':
	main(sys.argv[1:])

