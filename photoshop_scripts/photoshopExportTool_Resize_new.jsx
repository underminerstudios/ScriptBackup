﻿function main(file_to_run,new_file) {
      var docs = app.documents;

    for(var i = docs.length - 1; i >= 0; i--){
          docs[i].close();
};
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



    app.preferences.rulerUnits = Units.PERCENT;
    doc.resizeImage(33.34, 33.34);
    file = new File(new_file)
    photoshop_save_options = new PhotoshopSaveOptions();
    photoshop_save_options.alphaChannels = true;
    photoshop_save_options.layers = true;
    doc.saveAs(file, photoshop_save_options, true);

    
	doc.close(SaveOptions.DONOTSAVECHANGES);	
    var idquit = charIDToTypeID( "quit" );
    executeAction( idquit, undefined, DialogModes.ALL );
    };