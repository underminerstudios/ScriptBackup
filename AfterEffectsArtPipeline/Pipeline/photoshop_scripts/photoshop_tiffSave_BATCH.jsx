
﻿function main(file_to_run,new_file) {
    var docs = app.documents;
    displayDialogs = DialogModes.NO
    
    open(File(file_to_run));
    var doc = app.activeDocument;
    var lib = doc.library;
    var fpath = doc.path; 
    fpath.changePath(decodeURI(new_file));
    saveTiff( fpath );
    function saveTiff( file ) {
        tiffSaveOptions = new TiffSaveOptions();
        doc.saveAs( file, tiffSaveOptions, true);
        };
        doc.close(SaveOptions.DONOTSAVECHANGES);
        var idquit = charIDToTypeID( "quit" );
        executeAction( idquit, undefined, DialogModes.ALL );
        };