import os
from ExternalCalls import GeneralConversionCalls

class MoveSlotsNewConversion(object):

    def __init__(self, prodLocation, bingoAssetsFolder, roomNumber,rotelle):
        """If the game follows the new naming convention then use this class"""
        self.prodLocation = prodLocation
        self.bingoAssetsFolder = bingoAssetsFolder
        self.roomNumber = roomNumber
        self.runRotelle = rotelle
            
            
    def runMovement(self):
        """Moves all the art from the artist folder to the new folder with correct naming convention"""
        
        #makes the different naming conventions that we use.
        gameName = os.path.split(self.prodLocation)[-1]
        GameFileNameSWF = gameName.lower() + "_v2a.swf"
        CityFileNamePNG = self.roomNumber + ".png"
        GameFileNameNASWF = gameName.lower() + ".swf"
        
        #get from the UI the location of the game art and the room number. From the Json file get the location of the bingo assets folder. The true says we are a slots game
        runit = GeneralConversionCalls.intermediateFunctions(self.prodLocation, self.bingoAssetsFolder, self.roomNumber,True)
        
        #########
        #Achievements 
        ########
        ### cant do yet
        
        ############
        #City Backgrounds
        ##############
        cityBackground = runit.makeStuff("cityBackgrounds", "", 
                                        "cityBackgrounds.swf", GameFileNameSWF, "City Backgrounds")
        
        
        #############
        #City Title
        #############
        
        cityTitle = runit.makeStuff("cityTitles", "cityTitle", "cityTitle.swf", 
                                   GameFileNameNASWF, "City Title")
        
        ############
        #Etc
        ############
       
        featuredIcons = runit.makeStuff(os.path.join("lobby2","featuredIcons"), 
                                       "etc", "featuredIcon.swf", GameFileNameNASWF, "Featured Icons")
        
        #frame will need to be added when I can get data for that
        
        ############
        #Facebook
        ############
        
        cityUnlocked = runit.makeStuff("facebook", "", "unlockedCity.png", 
                                      "unlocked_city_" + CityFileNamePNG, "Unlocked City")
        bonusRound = runit.makeStuff("facebook", "", "slots_bonus_round.png", 
                                    "slots_bonus_round_" + CityFileNamePNG , "Bonus Round")
        pickGame = runit.makeStuff("facebook", "", "pickGame.png", 
                                  "pickGame_" + CityFileNamePNG , "Pick Game")
        
        ############
        #postcards
        ###########
        
        featuredPostCardsLarge = runit.makeStuff(os.path.join("lobby2","featuredPostCardsLarge"), 
                                                "postcards", "featuredPostCardLarge.swf", GameFileNameNASWF, 
                                                "Featured Post Cards Large")
        cityPostCard = runit.makeStuff("cityPostcards", "postcards", "cityPostCard.swf", GameFileNameNASWF, 
                                      "City Post Card")
        cityPostcard2 = runit.makeStuff(os.path.join("lobby2","cityPostcards"), 
                                       "postcards", "lobby2.swf", GameFileNameNASWF, "Lobby Post Card")

        
        
        ############
        #scatter
        ############
        slotsScatter = runit.makeStuff("slotsScatter", "scatter", 
                                      "bonusgame.swf", GameFileNameSWF, "Slots Scatter")
        


        
        #######
        #Rotelle Conversion
        #######
        
        
        #Origonally we had games that were part of the first iteration of the engine that needed conversion.  That conversion has taken place so we can just move the art.
        #UI was not updated because some of the games that werent converted might need to be converted so it all just goes to this but I can put it back in if we need it.
        if self.runRotelle == "New" or self.runRotelle == "Old":
            
            extras = runit.makeStuff(os.path.join("rotelle",gameName,"dev"), "etc", "extras.swf", gameName.lower()+"_extras.swf", "Extras")
            slotsSymbols = runit.makeStuff(os.path.join("rotelle",gameName,"dev"), "slotsSymbols", "symbols.swf", gameName.lower()+"_"+"symbols.swf", "Slots Symbols")
            slotsUI = runit.makeStuff(os.path.join("rotelle",gameName,"dev"), "slotsUI", "ui.swf", gameName.lower()+"_ui.swf", "Slots UI")
            slotsBonusWheel = runit.makeStuff(os.path.join("rotelle",gameName,"dev"), "slotsBigWheel", "bigwheel.swf",gameName.lower()+"_bigwheel.swf", "Slots Big Wheel")
            slotsScatter = runit.makeStuff(os.path.join("rotelle",gameName,"dev"), "scatter", "bonusgame.swf", GameFileNameSWF, "Slots Scatter")
        
        #not a rotelle game just the old style
        elif self.runRotelle == False:
            slotsSymbols = runit.makeStuff("slotsSymbols", "", "symbols.swf", GameFileNameSWF, "Slots Symbols")
            slotsUI = runit.makeStuff("slotsUI", "", "ui.swf", GameFileNameSWF, "Slots UI")
            slotsBonusWheel = runit.makeStuff("slotsBigWheel", "slotsBigWheel", 
                                         "bigwheel.swf", GameFileNameNASWF , "Slots Big Wheel")
            slotsScatter = runit.makeStuff("slotsScatter", "scatter", 
                                      "bonusgame.swf", GameFileNameSWF, "Slots Scatter")
            
       
        ######
        #All the stuff
        #######
        
        #we have a list here that gets filled with each of the possible converted art work.  If there is an issue it will pop up to the user.
        whatsBroken = [cityBackground,slotsBonusWheel,featuredPostCardsLarge,bonusRound,pickGame,cityUnlocked,
               cityPostCard,cityPostcard2,slotsScatter,featuredIcons,slotsSymbols,cityTitle,slotsUI]
        
        #rotelle games have an extra file called extras add that to the list.
        if self.runRotelle == "New" or self.runRotelle == "Old":
            whatsBroken.append(extras)
        
        # goes through the list and finds out what is actually broken and prepaires it for display.
        whatsBroken = runit.getThebroken(whatsBroken)

        #returns above for display.
        return whatsBroken
           
           
           

