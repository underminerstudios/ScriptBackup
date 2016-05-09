import urllib2
import csv, os
from StringIO import StringIO

class Import_the_Url_Data(object):

    def __init__(self):
        pass

    def pull_the_info(self):

        # google Docs location
        url = 'https://docs.google.com/spreadsheets/d/1mXM_qBHrbBE9JLe9-ZuzTFQczTzXjsX624JNm7cBSwc/export?format=csv&id=1mXM_qBHrbBE9JLe9-ZuzTFQczTzXjsX624JNm7cBSwc&gid=0'
        
        platform = os.name
        
        if platform == 'nt':
            home_location = os.path.expanduser("~")
        else:
            home_location = os.getenv("HOME")
            
        folderLocation = os.path.join(home_location, "GafMedia")
        
        self.make_folder(folderLocation)

        file_save_location = os.path.join(folderLocation,"AllStudios.csv")

        try:
            response = urllib2.urlopen(url)
            csv_info = response.read()
        
            try:
                if not os.path.exists(os.path.split(file_save_location)[0]):
                    os.makedirs(os.path.split(file_save_location)[0])
                
                with open(file_save_location, 'wb') as csv_file:
                    csv_writer = csv.writer(csv_file, delimiter=' ', quotechar='|')
                    csv_writer.writerow(csv_info)
                csv_file.close()
        
            except:
        
                file_save_location = StringIO(csv_info, delimiter=' ', quotechar='|')
        
        except:
        
            try:
                csv_file = open(file_save_location)
        
            except:
                file_save_location = "Please check your internet connection or download the spreadsheet and put it in your home directory at home/wild_blue_temp/GameSheet - Manafest.csv"
        
        return file_save_location




    def make_data(self, file_save_location):

        with open(file_save_location, 'rb') as csv_file:
            open_csv_file = list(csv.reader(csv_file, delimiter=' ', quotechar='|'))
            for row in open_csv_file:
                list_of_things = ''.join(row)
    
            per_line_splits = list_of_things.split('\n')
    
            types_of_infos = per_line_splits[0]
            types_of_infos = types_of_infos.split(',')
    
    
            index_of_shot_number = types_of_infos.index('Company name')
    
            everything = {}
    
            for per_line_split in range(1, len(per_line_splits)):
    
                split_per_line_split = per_line_splits[per_line_split].split(',')
                per_line_with_value = dict(zip(types_of_infos, split_per_line_split))
                try:
                    everything.update({split_per_line_split[index_of_shot_number]:per_line_with_value})
                except:
                    pass

        return everything
    
    def make_folder(self,folderLocation):
        if not(os.path.exists(folderLocation)):
            os.makedirs(folderLocation)
        elif os.path.exists(folderLocation):
            pass


get_doc = Import_the_Url_Data()
file_save_local = get_doc.pull_the_info()
everything = get_doc.make_data(file_save_local)