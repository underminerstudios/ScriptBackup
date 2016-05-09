import maya.cmds as cmds


def textureFixer():
    '''
    fixes all the files that have been moved from a local directory to the server's render directory.  Outputs the files that have been changed.
    '''
    all_files = cmds.ls(type="file")
    
    # This location is the images location. Change to whatever your need is
    location_of_source_images =  'sourceimages/'
    
    for fixing_file in all_files:
        
        origonal_texture_name = '%s.fileTextureName' % (fixing_file)
        full_file_path = cmds.getAttr(origonal_texture_name)
        
        split_texture_name = full_file_path.split('/')[-1]
        fixed_file_name = location_of_source_images + split_texture_name
        cmds.setAttr(origonal_texture_name, fixed_file_name, type="string" )
        
        #makes a path that we can check against since since full_file_path will give us the entire path of the file
        path_to_check = full_file_path.split('/')[-2] + '/'+ split_texture_name
        
        #tells people what we fixed and what the new name is
        if not (path_to_check == fixed_file_name):
            print "modified %s from %s to %s" % ( fixing_file, full_file_path, fixed_file_name)
        