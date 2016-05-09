
var doc = app.activeDocument;
var docSplit = doc.name.split('.');
var lib = doc.library;
//image sizes ... this can be modified to make more sizes.  Also uncomment and it will do the other 2 sizes. 
//(I recommend that if we were to look back at doing HD or SD assets that the sizes are pushed up a bit.  Somewhere in the 50% *should* work)
var imageSizes = [
[88.4,88.4]
//,
//[32.979,32.979],
//[25.53,25.53],
];
// image types that makes the folders and matches with the image size above
var currentImageType = [
['Retina']
];
//tells the system the remote location of the image outputs
var remoteLocation = '../../../../Output/Stills'
//removes the Source folder?
	try
	{
		var layerRef = app.activeDocument.layerSets.getByName("SOURCE");
		layerRef.remove();
	}
	catch(err) 
	{
		app.preferences.rulerUnits = Units.PERCENT;
	}
	//turns off all layers
	for(var j=0; j<doc.layerSets.length; j++) {
		doc.layerSets[j].visible = false;
	};
    
	// go through each layerset
	for(var k=0; k<doc.layerSets.length; k++) {
		//turns off layerset K
		doc.layerSets[k].visible = true;
		// if K is greater than 0 it turns off K-1
		if (k>0) doc.layerSets[k-1].visible = false;
		// makes the layer name the name of the folder K
		layerName = doc.layerSets[k].name;
		//save history
		var savedState = doc.activeHistoryState;
		//loops through the image sizes made above.
		for (var m = 0; m < imageSizes.length; m++) {
			//trims transparent
			doc.trim(TrimType.TRANSPARENT);
			//saves history for the loop
			var loopedSavedState = doc.activeHistoryState;
			//changes size of the file
			app.preferences.rulerUnits = Units.PERCENT;
			var currentImageSize = imageSizes[m];
	        var currentImageWidth = currentImageSize[0];
	        var currentImageHeight = currentImageSize[1];
			doc.resizeImage(currentImageWidth, currentImageHeight);
			//loops through all the layers in the folder and rasterizes the layer if it needs it also applys a unsharpen mask to the layers.
			for(var n=0; n<doc.layerSets[k].artLayers.length; n++) {
			    if (doc.layerSets[k].artLayers[n].visible == true) {
					doc.activeLayer = doc.layerSets[k].artLayers[n];
                    if (doc.activeLayer.kind.NORMAL != true){
                       doc.activeLayer.rasterize(RasterizeType.ENTIRELAYER);
                       };
					//doc.activeLayer.applyUnSharpMask(50, 1.1, 1);
				};
			};
        var folder1 = Folder(decodeURI(doc.path) + remoteLocation + '/' + currentImageType[m] + '/' + docSplit[0]);
		         //Check if it exist, if not create it.
        if(!folder1.exists) folder1.create();
			var fpath = doc.path; 
				// save to document's folder
		fpath.changePath(decodeURI(doc.path) + remoteLocation + '/' + currentImageType[m] + '/' + docSplit[0] + '/' + layerName  + '.tif');
		//saves a file
		saveTIFF( fpath);
		//continues to the top of the loop and reverts the history to the top of the loop after the trim transpanent... runs the transparent again but eh... doesn't kill it
		doc.activeHistoryState = loopedSavedState;
		};
		//undoes all the stuff in the layerset that was done. then moves on.
        doc.activeHistoryState = savedState;
		};
		//create an path for the function to open after the files are created	
     function saveTIFF( file ) {
	// save file
		tiffSaveOptions = new TiffSaveOptions();
		tiffSaveOptions.transparency = true;
		tiffSaveOptions.alphaChannels = false;
		tiffSaveOptions.layers = false
		doc.saveAs( file, tiffSaveOptions, true);
		}
doc.close(SaveOptions.DONOTSAVECHANGES);


