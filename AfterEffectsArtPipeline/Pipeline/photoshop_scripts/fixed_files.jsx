
//This fixes the file naming convention problem we ran into.

function main(input,newFile){
displayDialogs = DialogModes.NO
open(File(input));
var doc = app.activeDocument;
var docSplit = doc.name.split('.');
var lib = doc.library;

    
    for(var j=0; j<doc.artLayers.length; j++) {
        doc.artLayers[j].visible = false;
    };
    cleanedName = docSplit[0].replace("_optimized","");
    cleanedFolderName = cleanedName.replace("WBY_","");
    remoteLocation = "../../newPngsWithName"
    remoteLocation2 = "../../newPngsWithOutName"
    var folder1 = Folder(decodeURI(doc.path) + remoteLocation + '/' + newFile);
    var folder2 = Folder(decodeURI(doc.path) + remoteLocation2 + '/' + newFile);
        //Check if it exist, if not create it.

    if(!folder1.exists) folder1.create();
    if(!folder2.exists) folder2.create();

    // go through each layerset
    for(var k=0; k<doc.artLayers.length; k++) {
        doc.artLayers[k].visible = true;
        if (k>0) doc.artLayers[k-1].visible = false;
        layerName = doc.artLayers[k].name;
        var loopedSavedState = doc.activeHistoryState;
        doc.trim(TrimType.TRANSPARENT);
        var fpath = doc.path; 
        // save to document's folder
        
        if (k<9){
            k = "000" + k
            };
        if (k>9 && k<99){
            k = "00" + k
            };
        if((k>99) && (k<999)){
            k = "0"+ k
            };
        if (layerName.split(" ")){
            layerName = layerName.replace(" ","-")};
        fpath.changePath(decodeURI(doc.path) + remoteLocation + '/' +  newFile + '/' + "_" + k  + "_" + layerName  + '.png');
        savePNG( fpath );
        fpath.changePath(decodeURI(doc.path) + remoteLocation2 + '/' + newFile + '/' + cleanedName + "_" + k  + "_" + layerName  + '.png');
        savePNG( fpath );
        doc.activeHistoryState = loopedSavedState;
        function savePNG( file ) {
            pngSaveOptions = new PNGSaveOptions();
            doc.saveAs( file, pngSaveOptions, true);
            };
        };
        doc.close(SaveOptions.DONOTSAVECHANGES);
        var idquit = charIDToTypeID( "quit" );
        executeAction( idquit, undefined, DialogModes.ALL );
        //create an path for the function to open after the files are created   
    }

