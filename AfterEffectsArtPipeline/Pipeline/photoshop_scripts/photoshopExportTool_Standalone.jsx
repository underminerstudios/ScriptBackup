var doc = app.activeDocument;
var docSplit = doc.name.split('.');
var lib = doc.library;
var location = decodeURI(doc.path)


var doc = app.activeDocument;
var docSplit = doc.name.split('.');
var docSplit = docSplit[0].split('/');
var docSplit = docSplit[docSplit.length-1]
var lib = doc.library;
var folder1 = Folder(location + "/" + docSplit);
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
            fpath.changePath(folder1 + '/' + layerName  + '.png');
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
