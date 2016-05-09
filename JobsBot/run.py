import urllib
import putInFolders
from docGetter import Import_the_Url_Data
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from bot import Bot
from time import sleep
from bs4 import BeautifulSoup
import os
from urllib2 import urlopen
import re
import csv
import shutil
from distutils.command.clean import clean
from selenium.webdriver.common.keys import Keys

class makeThingsGo:
    
    def __init__(self):
        self.userName = "timcoolmode@timcoolmode.com"
        self.password = "Anything1"
        self.bot = Bot(0, 0)
        self.jobList = ("Technical Artist","Technical Director")
    
    
    def GetWebsitesAndPeople(self):
        getSpreadsheetData = Import_the_Url_Data()
        file_save_location = getSpreadsheetData.pull_the_info()
        AllData = getSpreadsheetData.make_data(file_save_location)
        keys = AllData.iterkeys()
        thefolder = os.path.split(file_save_location)[0]
        endFileName = os.path.join(thefolder,"googleDriveUpload.csv")
        if os.path.exists(endFileName):
            os.remove(endFileName)
        k = 0
        for key in keys:
            if k == 0:
                k += 1
                
                self.driver.get("https://www.linkedin.com/")
                self.driver.find_element_by_partial_link_text("Sign").click()
                
                self.typer(self.userName)
                
                rmb = Bot(0,0)
                rmb.key_board("tab")
                
                self.typer(self.password)
                
                rmb.key_board("tab")
                rmb.key_board("tab")
                rmb.key_board("enter")
                
                sleep(3)

                self.findElementsByXPath("main-search-box", key)
                
                rmb.key_board("enter")
                
                
                sleep(3)
                try:
                    ListOfCompaies = self.driver.find_elements_by_partial_link_text(key[0:2])
                except:
                    broken = key
                    return broken
                
                for ListOfCompaie in ListOfCompaies:
                    ListOfCompaie.click()
                    KeepGoing =self.runSecond(key,endFileName)
                    if not(KeepGoing == "Done"):
                        self.driver.back()
                        sleep(0.5)
                    #self._findNewElements()
                
            elif k > 0:

                sleep(3)
    
                self.clearElementsByXPath("main-search-box")
                sleep(3)
                self.typer(key)
                rmb.key_board("enter")
                
                try:
                    self.driver.find_element_by_partial_link_text("Companies").click()
                    sleep(3)
                except:
                    pass
                try:
                    ListOfCompanies = self.driver.find_element_by_partial_link_text(key[0:2])
                    #self._findNewElements()
                    self.runSecond(key,endFileName)
                except:
                    myfile = open(endFileName, 'a+')
                    wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
                    wr.writerow(key)
                            
    def runSecond(self,key,endFileName):

        self.driver.current_url
        html = self.driver.page_source
        soup = BeautifulSoup(html,"html.parser")
        
        industry = soup.find("li",{"class": "industry"}).p.contents
        industry = industry[0]
        
        if not(str(industry).startswith("Com")) or not(str(industry).startswith("Gam")) or not(str(industry).startswith("Ani")) or not(str(industry).startswith("Med")) or not(str(industry).startswith("Ent")):
            pass
        else:
            
            #this is all placed in order that it is found on linkedin
            try:
                website = soup.find(string=re.compile("http://"))
            except:
                website = " "
                
                
            try:
                industry = soup.find("li",{"class": "industry"}).p.contents
                industry = str(industry)
            except:
                industry = " "
                
                
            try:
                studiotype  = soup.find("li",{"class": "type"}).p.contents
                studiotype = str(studiotype).replace("\\n", "")
            except:
                studiotype = " "
            
            #address is like 30 things sooooo....here we go
            try:
                streetAddress = soup.find("span",{"class": "street-address"}).string
            except:
                streetAddress = " "
                
                
            try:
                region = soup.find("abbr",{"class": "region"}).string
            except:
                region = " "
            try:
                postalCode = soup.find("span",{"class": "postal-code"}).string
            except:
                postalCode = " "
            try:
                countryName = soup.find("span",{"class": "country-name"}).string
            except:
                countryName = " "
            try:
                headquarters  = [streetAddress,region,postalCode,countryName]
            except:
                headquarters = " "
            try:
                headquarters = " ".join(headquarters)
            except:
                headquarters = " "
    
            
            
            #rest of the info
            try:
                employees = soup.find("li",{"class": "company-size"}).p.contents
                employees = employees[0].replace("\n","")
            except:
                employees = ""
                
                
            try:
                founded = soup.find("li",{"class": "founded"}).p.contents
                founded = str(founded)
            except:
                founded = ""
                
            allInfo = [key,website,industry,studiotype,headquarters,employees,founded]
            
            
            
            myfile = open(endFileName, 'a+')
            wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
            wr.writerow(allInfo)
            return "Done"
    
    def getWebsites(self):
        """
        self.doEntertainment()
        self.doIndeed()
        self.doGamasutra()
        self.doMonster()
        self.doGameJob()
        self.doLinkedIn()
        self.doGlassDoor()
        """
        self.doCreativeHeads()
        

        
    def doEntertainment(self):
        self.driver = webdriver.Chrome()
        endFile,contents = self.opener("Entertainment.txt")
        self.driver.get("http://www.entertainmentcareers.net/sbjobs/")
        self.driver.find_element_by_partial_link_text("New Jobs").click()
        self.mainSelectionMovement("Next",endFile,contents)
        self.driver.close()
            
    def doIndeed(self):
        
        endFile,contents = self.opener("Indeed.txt")
        for job in self.jobList:
            self.driver = webdriver.Chrome()
            self.driver.get("http://www.indeed.com/")
            self.typer(job)
            rmb = Bot(0,0)
            rmb.key_board("tab")
            rmb.key_board("del")
            rmb.key_board("enter")
            
            self.mainSelectionMovement("Next", endFile,contents)
            try:
                self.driver.close()
            except:
                pass
                 
    def doGamasutra(self):
        self.driver = webdriver.Chrome()
        endFile,contents = self.opener("Gamasutra.txt")
        self.driver.get("http://www.gamasutra.com")
        self.driver.find_element_by_partial_link_text("Latest Jobs").click()
        GottaClear = self.driver.find_element_by_name("city_state_zip")
        GottaClear.clear()
        GottaClear.send_keys(Keys.ENTER)
        self.mainSelectionMovement(">", endFile,contents)
        self.driver.close()
        
    def doMonster(self):
        
        endFile,contents = self.opener("Monster.txt")
        for job in self.jobList:
            self.driver = webdriver.Chrome()
            self.driver.get("https://login.monster.com/Login/SignIn?re=swoop&ch=MONS&intcid=skr_swoop_h1&r=http%3A%2F%2Fhome.monster.com%2F")
            SearchBox = self.driver.find_element_by_id("ctl00__powerSearchControl__ptbJobTitle")
            SearchBox.send_keys(job)
            SearchBox.send_keys(Keys.ENTER)
            self.mainSelectionMovement("Monster", endFile,contents)
            self.driver.close()
            
    def doGameJob(self):
        
        endFile,contents = self.opener("GameJob.txt")
        for job in self.jobList:
            self.driver = webdriver.Chrome()
            self.driver.get("http://www.gamejobhunter.com/")
            self.clearElementsByXPath("keywords")
            SearchBox = self.findElementsByXPath("keywords", job)
            SearchBox.send_keys(Keys.ENTER)
            self.mainSelectionMovement("Next", endFile,contents)
            self.driver.close()
        
    def doLinkedIn(self):
        
        endFile,contents = self.opener("linkedIn.txt")
        loop = 0
        for job in self.jobList:
            self.driver = webdriver.Chrome()
            loop += 1
            if not(loop > 1):
                self.driver.get("https://www.linkedin.com/")
                self.driver.find_element_by_partial_link_text("Sign").click()
                self.driver.find_element_by_partial_link_text("Sign").click()
                self.findElementsByXPath("session_key-login", self.userName)
                self.findElementsByXPath("session_password-login", self.password)
                self.findElementsByXPath("btn-primary", self.password).click()
                sleep(1)
            else:
                pass
            self.driver.find_element_by_partial_link_text("Job").click()
            SearchBox = self.findElementsByXPath("main-search-box", job)
            SearchBox.send_keys(Keys.ENTER)
            self.mainSelectionMovement("linkedIn", endFile,contents)
            self.driver.close()
            
    def doGlassDoor(self):
        
        endFile = self.opener("GlassDoor.txt")
        for job in self.jobList:
            self.driver = webdriver.Chrome()
            self.driver.get("https://www.glassdoor.com/index.htm")
            SearchBox = self.driver.find_element_by_xpath('//*[@name="sc.keyword"]')
            SearchBox.click()
            SearchBox.send_keys(job)
            location = self.driver.find_element_by_xpath('//*[@placeholder="City, State, or Zip"]')
            location.clear()
            location.send_keys(Keys.ENTER)
            self.mainSelectionMovement("glassdoor", endFile)
            self.driver.close()
        
    def doCreativeHeads(self):
        
        endFile,contents = self.opener("CreativeHeads.txt")
        for job in self.jobList:
            self.driver = webdriver.Chrome()
            self.driver.get("https://www.creativeheads.net/")
            SearchBox = self.driver.find_element_by_id("txtKeyword")
            SearchBox.click()
            SearchBox.send_keys(job)
            SearchBox.send_keys(Keys.ENTER)
            self.mainSelectionMovement("Next", endFile,contents)
            self.driver.close()
    
    def opener(self,endFile):
        tempLocation = self._make_temp()
        endFile = os.path.join(tempLocation,endFile)
        OldFileName = endFile.split(".")[0]
        OldFileName = OldFileName + "_Old.txt"
            
        if os.path.exists(OldFileName) and os.path.exists(endFile):
            OrigonalFile = open(endFile)
            with open(OldFileName, "a+") as BigFile:
                BigFile.write(OrigonalFile.read())
                
            contents = self.getContents(OldFileName) 
            
        elif not(os.path.exists(OldFileName)) and os.path.exists(endFile):
            contents = self.getContents(endFile)         
            shutil.move(endFile, OldFileName)
        
        elif os.path.exists(OldFileName) and not(os.path.exists(endFile)):
            contents = self.getContents(OldFileName)
            
        else:
            contents = ""
            
        return endFile,contents
    
    def getContents(self,FileToGetContents):
        with open(FileToGetContents) as f:
            contents = f.readlines()
        return contents
            
    def mainSelectionMovement(self,nextPage,endFile,contents):
        #Moves on to the next page
        rmb = Bot(0,0)
        Breaker = True
        Ranger = range(1,100)
        
        iteration = 0
        while Breaker == True:
            
            try:
                body = self.driver.find_element_by_tag_name("body")
                links = self._loopThroughTitles(contents)
                
                iteration += 1
                if nextPage == "range":
                    
                    goOnToTheNextPage = self.driver.find_element_by_partial_link_text(Ranger[iteration])
                    self.writeToFile(links,endFile)
                    goOnToTheNextPage.click()
                elif nextPage == "linkedIn":
                    self.writeToFile(links,endFile)
                    self.driver.find_element_by_xpath('//*[@title="Next Page"]').click()
                elif nextPage == "glassdoor":
                    goOnToTheNextPage = self.driver.find_elements_by_class_name('next')
                    bob = []
                    for ii in goOnToTheNextPage:
                        bob.append(ii.get_attribute('href'))
                    self.writeToFile(links, endFile)
                    goOnToTheNextPage.click()
                elif nextPage == "Monster":
                    goOnToTheNextPage =self.driver.find_element_by_class_name("next")
                    self.writeToFile(links, endFile)
                    goOnToTheNextPage.click()
                else: 
                    goOnToTheNextPage = self.driver.find_element_by_partial_link_text(nextPage)
                    self.writeToFile(links,endFile)
                    if iteration == 2:
                        sleep(1)
                        rmb.left_click()
                    goOnToTheNextPage.click()
            except:
                links = self._loopThroughTitles(contents)
                self.writeToFile(links,endFile)
                Breaker = False
            
    def openBookMarks(self,BookMarkFiles):
        self.driver = webdriver.Chrome()
        for BookMarkFile in BookMarkFiles:
            with open(BookMarkFile) as f:
                contents = f.readlines()
                contents = list(set(contents))
                for content in contents:
                    body = self.driver.find_element_by_tag_name("body")
                    body.send_keys(Keys.CONTROL + 't')
                    self.driver.switch_to_window(self.driver.window_handles[-1])
                    self.driver.get(content)
            
        
    def writeToFile(self,links,endFile):
        with open(endFile, 'a+') as fileToWorkOn:
            for link in links:
                #doing this so I don't have to check if it's only one object
                link = str(link)
                fileToWorkOn.write("%s \n"%link)
               
                
    def _loopThroughTitles(self,contents):
        titles = ["technical artist","Technical artist",'TECHNICAL ARTIST',"Technical Artist","Technical Director","Technical director","technical director",
                  'TECHNICAL DIRECTOR']
        
        linkLocations = []
        contents = ([s.replace(' \n', '') for s in contents])
        for title in titles:
            try:
                links = self.driver.find_elements_by_partial_link_text(title)
                for link in links:
                    possibleLink = str(link.get_attribute("href"))
                    if possibleLink in contents:
                        pass
                    elif not(possibleLink in contents):
                        linkLocations.append(possibleLink)
            except:
                pass
        
        return linkLocations
    
    def GetJobInfo(self,place,soup):
        
        WordsToTry = ["Job","job","JOB","career","Car","CAR","con","CON","Con"]
        titles = ["tec","Tec",'TEC']
        
        for wordToTry in WordsToTry:
            try:
                self.driver.find_element_by_partial_link_text(wordToTry).click()
                if wordToTry == "Job" or wordToTry == "job" or wordToTry == "JOB":
                    for title in titles:
                        try:
                            soup.find(string=re.compile(title))
                            
                        except:
                            pass
                        
            except:
                pass
        
        
    def getContact(self):
        self.driver.get("http://www.seismicgames.com/")
        self.driver.find_element_by_partial_link_text("Contact").click()
        pass
    
    
    def _make_temp(self):
        """Makes the tmp folder location.  Pretty awesome thing is it also feeds back the location to all the scripts. No hard coding here. ***Does not delete the folder***"""
        
        if (os.name == 'nt'):
            location_of_home = os.path.expanduser("~")
                
        temp_location = os.path.join(location_of_home, "workStuff")
        
        self._makeFolders(temp_location)
        
        #nice return for every other script to use. What's the location we need to write to? Boom!
        return temp_location
    
    def _makeFolders(self,folderToMake):
        """make folder helper function"""
        if not(os.path.exists(folderToMake)):
            os.makedirs(folderToMake)
    
    def findElementsByXPath(self,whatToLookFor,key):
        ids = self.driver.find_elements_by_xpath('//*[@id]')
        for ii in ids:
            bob = ii.get_attribute('id')
            if bob == whatToLookFor:
                ii.send_keys(key)
                return ii
            
    def findElementsByXPathClick(self,whatToLookFor):
        ids = self.driver.find_elements_by_xpath('//*[@id]')
        for ii in ids:
            bob = ii.get_attribute('title')
            if bob == whatToLookFor:
                ii.click()
                
    def clearElementsByXPath(self,whatToLookFor):
        ids = self.driver.find_elements_by_xpath('//*[@id]')
        for ii in ids:
            bob = ii.get_attribute('id')
            if bob == whatToLookFor:
                ii.clear()
                
    def _findNewElements(self):
        ids = self.driver.find_elements_by_xpath('//*[@id]')
        for ii in ids:
            theIds = ii.get_attribute('class')
            print theIds
    
    
    def typer(self,whatToType):
        rmb = Bot(0, 0)
        letters = list(whatToType)
        for letter in letters:
            rmb.key_board(letter)
            
            
    def crapTonOfBackSpaces(self):
        list = []
        for x in range(0,30):
            list.append("\b")
        "''".join(list)
        return list
    