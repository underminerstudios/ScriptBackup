/*
Little script for everyone to enjoy
*/


var doc = fl.getDocumentDOM();
var docSplit = doc.name.split('.');
var timeline = doc.getTimeline();
var lib = doc.library;

// prepare layers
for(var i=0; i<doc.layers.length; i++) {
		doc.layers[i].visible = false;
}


// go through each layers
for(var i=0; i<doc.layers.length; i++) {
	doc.layers[i].visible = true;
	if (i>0) doc.layers[i-1].visible = false;

	var fpath = doc.path; // save to document's folder
	fpath.changePath( docSplit[0] + '_' + doc.layers[i].name + '.png');
	savePNG( fpath );
}

/**
	* Save PNG file
	* @param file File object
*/
function savePNG( file ) {
	// export SAVE-FOR-WEB options
	var exp = new ExportOptionsPNG24();
	exp.transparency = true;

	// export as SAVE-FOR-WEB
	doc.exportFile( file, ExportType.PNG24, exp);

}
