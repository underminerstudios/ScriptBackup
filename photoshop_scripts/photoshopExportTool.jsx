function main(file_to_run,new_file) {
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

    try{
        var layerRef = app.activeDocument.layerSets.getByName("temp- delete");
        layerRef.remove();
    }
    catch(err){
        app.preferences.rulerUnits = Units.PERCENT;
    }
    try{
        var layerRef = app.activeDocument.layerSets.getByName("ALL LAYERS");
        layerRef.remove();
    }
    catch(err){
        app.preferences.rulerUnits = Units.PERCENT;
    }
    try{
        var layerRef = app.activeDocument.layerSets.getByName("NoFx");
        layerRef.remove();
    }
    catch(err){
        app.preferences.rulerUnits = Units.PERCENT;
    }
    app.preferences.rulerUnits = Units.PERCENT;
    doc.resizeImage(48, 48);

    file = new File(new_file)
    photoshop_save_options = new PhotoshopSaveOptions();
    photoshop_save_options.alphaChannels = true;
    photoshop_save_options.layers = true;
    doc.saveAs(file, photoshop_save_options, true);

    
	doc.close(SaveOptions.DONOTSAVECHANGES);	
    open(File(new_file));
    var doc = app.activeDocument;
    var docSplit = doc.name.split('.');
    var docSplit = docSplit[0].split('/');
    var docSplit = docSplit[docSplit.length-1]
	var lib = doc.library;
    var folder1 = Folder(new_remote_location + '../../../6_textures/' + docSplit);
                 //Check if it exist, if not create it.
    if(!folder1.exists) folder1.create();
    

		// 2. Save the history state.


    // turn off all layers
    for(var n=0; n<doc.layers.length; n++) {
        if (doc.layers[n].visible = true){
        doc.layers[n].visible = false;
        }
        };
    
        for(var n=0; n<doc.layers.length; n++) {
                var savedState = doc.activeHistoryState;
                doc.layers[n].visible = true;
                if (n>0) doc.layers[n-1].visible = false;
                doc.activeLayer = doc.layers[n];
                var layerName = doc.layers[n].name
                var layerName = layerName.replace(' ','_')
                try{
                    doc.trim(TrimType.TRANSPARENT);
                }
                catch(err){
                    doc.trim(TrimType.TOPLEFT)
                }
                var fpath = doc.path; 
                // save to document's folder
                fpath.changePath(new_remote_location + '../../../6_textures/' + docSplit + '/' + layerName  + '.png');
                save_png( fpath);
                doc.activeHistoryState = savedState;
                };


    /**
        * Save PNG file
        * @param file File object
    */
    function save_png( file ) {
        file = new File(file)
        png_save_options = new PNGSaveOptions();
        doc.saveAs( file, png_save_options, true);
    };
    
	doc.close(SaveOptions.DONOTSAVECHANGES);
    var idquit = charIDToTypeID( "quit" );
    executeAction( idquit, undefined, DialogModes.ALL );
    };