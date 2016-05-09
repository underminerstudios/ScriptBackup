import os,shutil
from dircache import listdir

# put in your local folder that you want to put the files in
for root,dirs,files in os.walk(r"F:\WBYPipelineArt\wby_pipeline\Textures"):
            
            #if you need some other file put in then say so here
    file_to_check_for = "Null.png"
    for dir in dirs:
        file_foler = os.path.join(root,dir)
        files_in_dir = listdir(file_foler)
        if not(file_to_check_for in files_in_dir):
            # this is the location of some png you need.  If you want to copy a different one then just say so... just reemmber that you need to change the file_to_check variable too!
            shutil.copy(r"F:\WBYPipelineArt\wby_pipeline\Textures\001_001_001\Null.png",(os.path.join(file_foler,file_to_check_for)))
