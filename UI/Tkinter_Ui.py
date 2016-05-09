import Tkinter, tkFileDialog, sys, os, subprocess
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from Asset_Renamer_Exporter.Asset_Renamer_Exporter import Asset_Rename_Exporter
from External_Calls import Doc_Getter
from External_Calls.Doc_Getter import Import_the_Url_Data
from Tkinter import *
import tkMessageBox



# user interface class for tkinter mostly self explanitory with defs below
class UserInterface:
    def __init__(self, master):

        frame = Frame(master)
        frame.pack()

        self.photoshop_namer = Button(frame,
                           text="Photoshop Renamer and Exporter",
                           command=self.photoshop_renamer_and_export)
        self.photoshop_namer.pack(side=LEFT)
        self.ae_exporter_select = Button(frame,
                          text="AE Exporter - Select Files",
                          command=self.ae_exporter)
        self.ae_exporter_select.pack(side=LEFT)
        self.ae_anchor_select = Button(frame,
                          text="Fix Anchor Point AE",
                          command=self.ae_anchor_point_fix)
        self.ae_anchor_select.pack(side=LEFT),
        self.template_maker = Button(frame,
                          text="Template_Maker",
                          command=self.template_make)
        self.template_maker.pack(side=LEFT)
        self.nullpng_maker = Button(frame,
                          text="Null Png Maker",
                          command=self.null_png_make)
        self.nullpng_maker.pack(side=LEFT)
        self.resize_maker = Button(frame,
                          text="Resize all the PSDS",
                          command=self.resize_make)
        self.resize_maker.pack(side=LEFT)
        self.make_linear = Button(frame,
                          text="Linear Dodge Checker",
                          command=self.linear_dodge_checker)
        self.make_linear.pack(side=LEFT)
        self.makeJpegButton = Button(frame,
                          text="Make Jpegs",
                          command=self.makeJpegs)
        self.makeJpegButton.pack(side=LEFT)
        


    def photoshop_renamer_and_export(self):
      self.run_everything_art(False)
      
    def makeJpegs(self):
        #Makes all the jpegs from psds. Automated
        asset_to_convert = self.button('Select The Photoshop File(s) that you want turned into Jpegs', [('PSD', '*.psd')], "Seems like something happened. Please Try again!", 1)
        
        string_of_files = ''.join(asset_to_convert)
        seperator = string_of_files[:4]
        string_of_files = string_of_files.split(seperator)
        asset_rename = Asset_Rename_Exporter()

        asset_rename.makeScreenShots(string_of_files,seperator)
        root.destroy()


    def run_everything_art(self,do_both):
        #runs photoshop pipeline Exports pngs to folders for artists to use
        assets_to_rename = self.button('Select The Photoshop File(s) You Would Like Converted', [('PSD', '*.psd')], "Seems like something happened. Please Try again!", 1)
        get_doc = Import_the_Url_Data()
        file_save_local = get_doc.pull_the_info()
        everything = get_doc.make_data(file_save_local)
        asset_rename = Asset_Rename_Exporter()

        files_to_convert = {}
        files_to_not_convert = []
        file_name_to_run = []
        
        assets_to_rename = ''.join(assets_to_rename)
        assets_to_rename = assets_to_rename.split(" ")

        for file_name in assets_to_rename:
          
          new_file_name = os.path.split(file_name)
          new_file_name = new_file_name[-1].split('_')
          if new_file_name[0] == 'WBY':
            new_file_name.pop(0)
            if new_file_name[-1] == "optimized":
                new_file_name.pop(-1)
          new_file_name = '_'.join(new_file_name)
          new_file_name = new_file_name.split(".")[0]

          lets_test = asset_rename.check_photoshop_names(file_name, new_file_name, everything)

          try:
              lets_test.split('broken')
              files_to_not_convert.append(lets_test)
          except:
              files_to_convert.update(lets_test[0])
              file_name_to_run.append(lets_test[1])


        if files_to_not_convert:
          tkMessageBox.showerror('These Files are not correct Please use other ones', files_to_not_convert)
        
        print file_name 
        folder_name = os.path.split(file_name)[0]
        print folder_name

        run = 0
        for file_to_convert in files_to_convert:
          run+=1
          asset_rename.exchange_photoshop_names_plus_export(os.path.join(folder_name,"WBY_" + file_to_convert + ".psd"), files_to_convert[file_to_convert],do_both)

        root.destroy()
        



    def resize_make(self):
      for root,dirs,files in os.walk("K:\\HD"):
        for file_to_work_on in files:
          if file_to_work_on.endswith('.psd'):
            asset_rename = Asset_Rename_Exporter()
            file_to_work_on = os.path.join(root,file_to_work_on)
            asset_rename.make_resized_art(file_to_work_on)




    def ae_exporter(self):
        #exports the AE file's json and XMLs
        assets_to_rename = self.button('What Ae Files do you want to convert', [('After Effects Files', '*.aep')], "Seems like something happened. Please Try again!", 1)

        get_doc = Import_the_Url_Data()
        file_save_local = get_doc.pull_the_info()
        everything = get_doc.make_data(file_save_local)
        asset_rename = Asset_Rename_Exporter()

        string_of_files = ''.join(assets_to_rename)

        string_of_files = string_of_files.split(' ')

        files_to_not_convert = {}
        files_to_convert = {}
        file_name_to_run = []

        for file_name in string_of_files:
            folder_of_art = os.path.split(file_name)[0]
            new_file_name = os.path.split(file_name)[-1]
            new_file_name = os.path.splitext(file_name)[0]
            new_file_name += "_CONVERTED.aep"
            new_file_name = os.path.join(folder_of_art, new_file_name)
            lets_test = asset_rename.check_ae_names(file_name, new_file_name, everything)

            try:
                lets_test.split(' ')
                files_to_not_convert.append(lets_test)
            except:
                files_to_convert.update(lets_test[0])
                file_name_to_run.append(lets_test[1])


        if files_to_not_convert:
            tkMessageBox.showerror('These Files are not correct Please use other ones', '%s') % (files_to_not_convert)

        run = 0
        for file_to_convert in files_to_convert:
          run+=1
          asset_rename.exchange_ae_names_plus_comp_test(file_name_to_run[run-1], files_to_convert[file_to_convert], everything)

        root.destroy()
        
        
    def ae_anchor_point_fix(self):
        #exports the AE file's json and XMLs
        assets_to_rename = self.button('What Ae Files do you want to fix', [('After Effects Files', '*.aep')], "Seems like something happened. Please Try again!", 1)

        get_doc = Import_the_Url_Data()
        file_save_local = get_doc.pull_the_info()
        everything = get_doc.make_data(file_save_local)
        asset_rename = Asset_Rename_Exporter()

        string_of_files = ''.join(assets_to_rename)

        string_of_files = string_of_files.split(' ')

        files_to_not_convert = {}
        files_to_convert = {}
        file_name_to_run = []

        for file_name in string_of_files:
            folder_of_art = os.path.split(file_name)[0]
            new_file_name = os.path.split(file_name)[-1]
            new_file_name = os.path.splitext(file_name)[0]
            new_file_name += "_CONVERTED.aep"
            new_file_name = os.path.join(folder_of_art, new_file_name)
            lets_test = asset_rename.check_ae_names(file_name, new_file_name, everything)

            try:
                lets_test.split(' ')
                files_to_not_convert.append(lets_test)
            except:
                files_to_convert.update(lets_test[0])
                file_name_to_run.append(lets_test[1])


        if files_to_not_convert:
            tkMessageBox.showerror('These Files are not correct Please use other ones', '%s') % (files_to_not_convert)

        run = 0
        for file_to_convert in files_to_convert:
          run+=1
          asset_rename.anchor_point_fix(file_name_to_run[run-1], files_to_convert[file_to_convert],everything)

        root.destroy()




    def template_make(self):
      # tool that makes all the panels into a txt file
      asset_rename = Asset_Rename_Exporter()
      get_doc = Import_the_Url_Data()
      file_save_local = get_doc.pull_the_info()
      everything = get_doc.make_data(file_save_local)
      folder = asset_rename._make_temp()
      file_to_use = os.path.join(folder, "Panel Names.txt")
      target = open(file_to_use, 'w+')

      make_list = []
      for key in everything.keys():
          make_list.append(everything[key]["Comicbook Panel"])
      make_list.sort()

      for list_item in make_list:
          target.write(str(list_item))
          target.write("\n    Movement:\n")
          target.write("    Camera Movement:\n")
          target.write("    Parallax:\n")
            
            
            
    def null_png_make(self):
      #need null pngs?... now youz got em!
      assets_to_rename = self.button('select a NULL.png in the wby_pipeline -> Textures folder', [('Pngs', '*.png')], "Something went wrong run again!", 1)
      asset_rename = Asset_Rename_Exporter()
      null_png = ''.join(assets_to_rename)
      asset_rename.populate_null_pngs(null_png)
      root.destroy()
      
    #def make_ae_file(self):
    
    def linear_dodge_checker(self):
                #runs photoshop pipeline Exports pngs to folders for artists to use
        asset_to_convert = self.button('Select The Photoshop File(s) that you want checked', [('PSD', '*.psd')], "Seems like something happened. Please Try again!", 1)
        string_of_files = ''.join(asset_to_convert)
        string_of_files = string_of_files.split(' ')
        asset_rename = Asset_Rename_Exporter()
        asset_rename.run_check_for_linear_dodge(string_of_files)
        root.destroy()
    


    def button(self, title, file_types, complaint_message, multiple):
      #this is the buttons. for tkinter
      while True:
          def quit(root):
              root
              root.destroy()
          root = Tkinter.Tk()
          root.withdraw()
          firstFile = tkFileDialog.askopenfilenames(parent=root, filetypes=file_types, title=title, multiple=multiple)
          user_selections = list(firstFile)
          if firstFile == '':
                  print self.complaint_message
                  print "Exiting Now\n\n"
                  sys.exit()
          else:
              # tells the system to run UI
              return user_selections
              break


root = Tk()
app = UserInterface(root)
root.mainloop()
sys.exit()
