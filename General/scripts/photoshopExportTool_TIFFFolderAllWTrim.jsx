/*
photoshop export script 
*/

var input = openDialog(); 
for(var i = 0 ;i < input.length; i++) {
	open(input[i]);
	var doc = app.activeDocument;
	var docSplit = doc.name.split('.');
	var lib = doc.library;
	var imageSizes = [
	[88.4,88.4],
	[32.979,32.979],
	[25.53,25.53],
	];
	var currentImageType = [
	['Retina'],
	['HD'],
	['SD'],
	];
	var remoteLocation = '../../../Output/Stills'

	//resize the image to Retna
	for (var m = 0; m < imageSizes.length; m++) {

		app.preferences.rulerUnits = Units.PERCENT;
	    var currentImageSize = imageSizes[m];
	    var currentImageWidth = currentImageSize[0];
	    var currentImageHeight = currentImageSize[1];
	    
	    // 2. Save the history state.
	    var savedState = doc.activeHistoryState;
	    // 3. Resize to the current image size.
	    doc.resizeImage(currentImageWidth, currentImageHeight);
	    for(var j=0; j<doc.layerSets.length; j++) {
			doc.layerSets[j].visible = false;
		};
		var folder1 = Folder(decodeURI(doc.path) + remoteLocation + '/' + currentImageType[m] + '/' + docSplit[0]);
			//Check if it exist, if not create it.
		if(!folder1.exists) folder1.create();
		

		// go through each layerset
		for(var k=0; k<doc.layerSets.length; k++) {
			doc.layerSets[k].visible = true;
			if (k>0) doc.layerSets[k-1].visible = false;
			layerName = doc.layerSets[k].name;
			var loopedSavedState = doc.activeHistoryState;
			doc.trim(TrimType.TRANSPARENT);
			for(var n=0; n<doc.layerSets[k].artLayers.length; n++) {
				if (doc.layerSets[k].artLayers[n].visible == true) {
					doc.activeLayer = doc.layerSets[k].artLayers[n];
					if (doc.activeLayer.kind.NORMAL != true){
					doc.activeLayer.rasterize(RasterizeType.ENTIRELAYER);
					};
				doc.activeLayer.applyUnSharpMask(50, 1.1, 1);
				};
			};
			var fpath = doc.path; 
			// save to document's folder
			fpath.changePath(decodeURI(doc.path) + remoteLocation + '/' + currentImageType[m] + '/' + docSplit[0] + '/' + layerName  + '.tif');
			saveTIFF( fpath );
			doc.activeHistoryState = loopedSavedState;

			//create an path for the function to open after the files are created	
		}

		/**
			* Save PNG file
			* @param file File object
		*/
		function saveTIFF( file ) {
			// export SAVE-FOR-WEB options
			tiffSaveOptions = new TiffSaveOptions();
			tiffSaveOptions.transparency = true;
			tiffSaveOptions.alphaChannels = true;
			tiffSaveOptions.layers = false
			doc.saveAs( file, tiffSaveOptions, true);
		}
		doc.activeHistoryState = savedState;
	}
	doc.close(SaveOptions.DONOTSAVECHANGES);

}