import os
import json
import tkMessageBox
import shutil
from ExternalCalls import GeneralConversionCalls


class MoveBingo(object):
    """Moves all the bingo art from one location to the correct final location with the correct naming convetnion"""

    def __init__(self, prodLocation, AssetsFolder, roomNumber):
        """Set up the location of the origonal art. The final art location and naming of assets"""
        
        #all information we get from the ui
        self.prodLocation = prodLocation
        self.bingoAssetsFolder = AssetsFolder
        self.roomNumber = roomNumber
        self.gameName = os.path.split(self.prodLocation)[-1]
        
        self.runit = GeneralConversionCalls.intermediateFunctions(self.prodLocation, self.bingoAssetsFolder, self.roomNumber,False)
        
        # lets make game specific naming conventions
        self.GameFileNameSWF = self.gameName.lower() + "_v2a.swf"
        self.GameFileNamePNG = self.gameName.lower() + "_v2a.png"
        self.CityFileNamePNG = self.roomNumber + ".png"
        self.CityFileNameSWF = self.roomNumber + ".swf"
        self.GameFileNameNASWF = self.gameName.lower() + ".swf"
            
            
    def runMovement(self): 
        """Worker function call this if you want to move the art from one point to another"""    
       
        # move the files below to their final locations with the correct naming convention
        TallPostcard = self.runit.makeStuff(os.path.join("lobby2","featuredPostcardsLarge"), "cityPostcards", "tall.swf", self.GameFileNameNASWF, "Tall Postcard",True)
        SmallPostcard = self.runit.makeStuff("cityPostcards","cityPostcards", "small.swf", self.GameFileNameNASWF, "Small Postcard",True)
        LargePostcard = self.runit.makeStuff(os.path.join("lobby2","featuredPostcardsLarge"), "cityPostcards", "map.swf", self.GameFileNameNASWF, "Large Postcard",True)
        CityBackground = self.runit.makeStuff("cityBackgrounds", "cityBackground", "background", self.GameFileNameNASWF, "City Background", False)
        CityTitle = self.runit.makeStuff("cityTitles", "cityTitle", "title", self.GameFileNameNASWF, "City Title", False)
        FeaturedIcons = self.runit.makeStuff(os.path.join("lobby2","featuredIcons"), "cityFeaturedDock", "dockicon", self.GameFileNameNASWF, "Featured Icon", False)
        
        #Returns what might be broken
        whatsBroken = [TallPostcard,SmallPostcard,LargePostcard,CityBackground,CityTitle,FeaturedIcons]

        self.runit.getThebroken(whatsBroken)

        return whatsBroken
              
           
    