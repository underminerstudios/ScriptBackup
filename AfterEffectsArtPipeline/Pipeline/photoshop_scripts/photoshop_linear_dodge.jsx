var DocToOpen = ["filler","F:/Inbox/WBY_006_019_006.psd","F:/Exported/006_005_018.psd"]
main(DocToOpen[1],DocToOpen[2]);
﻿function main(file_to_run,new_file) {
      var docs = app.documents;
    displayDialogs = DialogModes.NO
    
	open(File(file_to_run));
	var doc = app.activeDocument;
	var docSplit = doc.name.split('.');
	var lib = doc.library;
    
    var remote_location = DocToOpen[2].split('/')
    
    new_remote_location = []
    for (var i = 0; i<=remote_location.length-2;i++){
        if (i >0){
        new_remote_location+=('/' + remote_location[i]);
        };
        else{
            new_remote_location+=remote_location[i];
            };
    };
	
    var doc = app.activeDocument;
    var docSplit = doc.name.split('.');
    var docSplit = docSplit[0].split('/');
    var docSplit = docSplit[docSplit.length-1]
	var lib = doc.library;
    var folder1 = Folder(new_remote_location + '../linear_dodge/');
    if(!folder1.exists) folder1.create();
    

    
        for(var n=0; n<doc.layers.length; n++) {
                doc.activeLayer = doc.layers[n];
                var layerName = doc.layers[n].name
                var layerName = layerName.replace(' ','_')
                var fpath = doc.path; 
                // save to document's folder
                \
                };

    function move_file(){
        
        file = new File(new_file)
        photoshop_save_options = new PhotoshopSaveOptions();
        photoshop_save_options.alphaChannels = true;
        photoshop_save_options.layers = true;
        doc.saveAs(file, photoshop_save_options, true);
};
        
	doc.close(SaveOptions.DONOTSAVECHANGES);
    var idquit = charIDToTypeID( "quit" );
    executeAction( idquit, undefined, DialogModes.ALL );
    };