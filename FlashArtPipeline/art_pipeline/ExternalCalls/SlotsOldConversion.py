import os
import json
import tkMessageBox
import shutil
from ExternalCalls import GeneralConversionCalls


class MoveSlotsOldConversion(object):

    def __init__(self, prodLocation, bingoAssetsFolder, roomNumber):
        """Old naming convention setup.  Moves the art from the artist folders to the final folders with the final naming convention.  
        Actual work done with intermediateFunctions class"""
        
        #gets all the information needed
        self.prodLocation = prodLocation
        self.bingoAssetsFolder = bingoAssetsFolder
        self.roomNumber = roomNumber
            
            
    def runMovement(self):
        """Makes the correct names and moves all the art.  Returns any issues for users to look at"""
        
        #make the naming convention names
        gameName = os.path.split(self.prodLocation)[-1]
        GameFileNameSWF = gameName.lower() + "_v2a.swf"
        CityFileNamePNG = self.roomNumber + ".png"
        GameFileNameNASWF = gameName.lower() + ".swf"
        
        #does the setup for the heavy lifting makeStuff function
        runit = GeneralConversionCalls.intermediateFunctions(self.prodLocation, 
                                                             self.bingoAssetsFolder, self.roomNumber,True)
        #it's as follows.  Old location,new location,old file ends with, new file file name, possible error.
        cityBackground = runit.makeStuff("cityBackgrounds", "slotsSplashScreen", 
                                        "splash.swf", GameFileNameSWF, "City Backgrounds")
        slotsBonusWheel =runit.makeStuff("slotsBigWheel", "slotsBonusWheel", 
                                         "Wheel.swf", GameFileNameNASWF , "Slots Bonus Wheel")
        featuredPostCardsLarge = runit.makeStuff(os.path.join("lobby2","featuredPostCardsLarge"), 
                                                "slotsPostcard", "tall.swf", GameFileNameNASWF, 
                                                "Featured Post Cards Large")
        cityPostCard = runit.makeStuff("cityPostcards", "slotsPostcard", "small.swf", GameFileNameNASWF, 
                                      "City Post Card")
        cityUnlocked = runit.makeStuff("facebook", "OpenGraph", "roomUnlocked.png", 
                                      "unlocked_city_" + CityFileNamePNG, "City Unlocked")
        bonusRound = runit.makeStuff("facebook", "OpenGraph", "freespinbonus.png", 
                                    "slots_bonus_round_" + CityFileNamePNG , "Bonus Round")
        pickGame = runit.makeStuff("facebook", "OpenGraph", "scatter.png", 
                                  "pickGame_" + CityFileNamePNG , "Pick Game")
        cityPostcard2 = runit.makeStuff(os.path.join("lobby2","cityPostcards"), 
                                       "slotsPostcard", "map.swf", GameFileNameNASWF, "Lobby Post Card")
        featuredIcons = runit.makeStuff(os.path.join("lobby2","featuredIcons"), 
                                       "slotsDockIcon", "Dock.swf", GameFileNameNASWF, "Featured Icons")
        slotsScatter = runit.makeStuff("cityPostcards", "slotsPostcard", 
                                      "Popups.swf", GameFileNameSWF, "Slots Scatter")
        slotsSymbols = runit.makeStuff("slotsSymbols", "", "Symbols.swf", GameFileNameSWF, "Slots Symbols")
        cityTitle = runit.makeStuff("cityTitles", "slotsTitle", "cityName.swf", 
                                   GameFileNameNASWF, "City Title")
        slotsUI = runit.makeStuff("slotsUI", "", "Game.swf", GameFileNameSWF, "Slots UI")
        
        #make a list of the returns
        whatsBroken = [cityBackground,slotsBonusWheel,featuredPostCardsLarge,bonusRound,pickGame,cityUnlocked,
                       cityPostCard,cityPostcard2,slotsScatter,featuredIcons,slotsSymbols,cityTitle,slotsUI]
        
        #send the list to the what's broken which will return a problem if there is one. and if not it will return nothing
        whatsBroken = runit.getThebroken(whatsBroken)
        
        return whatsBroken