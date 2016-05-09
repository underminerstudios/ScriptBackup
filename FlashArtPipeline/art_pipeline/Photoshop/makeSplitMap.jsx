

// This is totally unable to run unless it goes through the pipeline.  The pipeline will prepend a location.
// You can put this in if you would like var inputs = [file_location]
// For memory management it shuts down after running once.

////////
///////
// This script chops up the map pieces and puts them into a self made atlas.
////////
///////

main(inputs[0]);
﻿﻿function main(file_to_run) {
    //this runs everything
    var startTypeUnits = app.preferences.typeUnits
    var startDisplayDialogs = app.displayDialogs
    var startRulerUnits = app.preferences.rulerUnits
    app.preferences.rulerUnits = Units.PIXELS
    app.preferences.typeUnits = TypeUnits.PIXELS
    app.displayDialogs = DialogModes.NO
    var docs = app.documents;

    //make sure we close all the files open
    for(var i = docs.length - 1; i >= 0; i--){
          docs[i].close();
};
    //open the file and make a copy in the new folder location and if the folder doesn't exist make it
	open(File(file_to_run));
	var doc = app.activeDocument;
	var lib = doc.library;
    var doc = app.activeDocument;
    var docSplit = doc.name.split('.');
    var docSplit = docSplit[0].split('/');
    var docSplit = docSplit[docSplit.length-1]
    var new_remote_locationSplit = file_to_run.split("/")
    var new_remote_location = ""
    for (var j = 0;  j<= new_remote_locationSplit.length - 2; j++){
            new_remote_location += new_remote_locationSplit[j] + "/"
        }
	var lib = doc.library;
    var folder1 = Folder(new_remote_location + '../../PSDs/');
                 //Check if it exist, if not create it.
    if(!folder1.exists) folder1.create();
    
    //Get the size of the file
    var sizeX = doc.width.value
    var sizeY = doc.height.value
    
    //make the file a bit larger so we can make sure the map sections don't have bad edges
    doc.resizeCanvas(sizeX,sizeY+10)
    
    //get the new doc size
    var sizeX = doc.width.value
    var sizeY = doc.height.value
    
    // fill in the top
    var shapeRef = Array(Array(0,5), Array(0 ,10), Array(sizeX,10), Array(sizeX,5 ))
    doc.selection.select(shapeRef);
    doc.selection.copy()
    doc.paste()
    for(var n=0; n<doc.layers.length; n++)
        if (doc.layers[n].name == "Layer 1"){
                doc.layers[n].resize (100, 200 , AnchorPosition.BOTTOMCENTER )
                doc.layers[n].merge()
            }

    var shapeRef = Array(Array(0,sizeY-5), Array(0 ,sizeY- 10), Array(sizeX,sizeY-10), Array(sizeX,sizeY-5 ))
    doc.selection.select(shapeRef);
        
    doc.selection.copy()
    doc.paste()
    for(var n=0; n<doc.layers.length; n++)
        if (doc.layers[n].name == "Layer 1"){
                doc.layers [n].resize (100, 200 , AnchorPosition.TOPCENTER )
                doc.layers[n].merge()
            }
    //we lose that 10 px we just made but it's ok we only needed it for the quality of the art.
    doc.resizeImage (1956, 512)

    //get the size again once we have resized it to the new size
    var sizeX = doc.width.value
    var sizeY = doc.height.value
    
    //make a selection that is correct for the first cut
    var shapeRef = Array(Array(sizeX/2,sizeY), Array(sizeX,sizeY), Array(sizeX,0), Array(sizeX/2,0))
    doc.selection.select(shapeRef);
    
    doc.selection.cut()
    doc.paste()

    //after cutting it in half move the art so we can rescale the canvas
    for(var n=0; n<doc.layers.length; n++)
        if (doc.layers[n].name == "Layer 1"){
                doc.layers[n].translate (-sizeX/4, 0)
            }

        //rescale the canvas
        doc.resizeCanvas(1024,1024,AnchorPosition.BOTTOMLEFT)

    //move the art to it's correct location flatten it and make a png out of it.
    for(var n=0; n<doc.layers.length; n++)
        if (doc.layers[n].name == "Layer 0"){
                doc.layers[n].translate ( 46  , -sizeY)
            }
        var PSDLocation = decodeURI(doc.path) + "../../../PSDs/" + doc.name.split('.')[0]
        file = new File(PSDLocation)
        photoshop_save_options = new PhotoshopSaveOptions();
        photoshop_save_options.alphaChannels = true;
        photoshop_save_options.layers = true;
        doc.saveAs(file, photoshop_save_options, true);
        save_png( file_to_run);
   


    /**
        * Save PNG file
        * @param file File object
    */
    
    //close the file and don't save changes. Then kill photoshop totally. 
	doc.close(SaveOptions.DONOTSAVECHANGES);
    var idquit = charIDToTypeID( "quit" );
    executeAction( idquit, undefined, DialogModes.ALL );
    };

function save_png( file ) {
    //make the png
        var options = new ExportOptionsSaveForWeb();
        options.format = SaveDocumentType.PNG;
        options.PNG8 = false;
        options.transparency = false;
        options.optimized = false;
        var doc = app.activeDocument;
        doc.exportDocument(File(file),ExportType.SAVEFORWEB, options);
    };