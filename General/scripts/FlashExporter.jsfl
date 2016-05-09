var ROOT = "C:/script_test/";
//var ROOT = "/Export"

var doc = fl.getDocumentDOM();
var timeline = doc.getTimeline();
var lib = doc.library;
var docSplit = doc.name.split('.');


for(var i=0; i<timeline.layers.length; i++) {
		timeline.layers[i].visible = false;
}
for(var i=0; i<timeline.layers.length; i++) {
	timeline.layers[i].visible = true;
	if (i>0) timeline.layers[i-1].visible = false;

	var frameArray = timeline.layers[i].frames;
	var n = frameArray.length;
	
	
		for(var j=0;j<n; j++) {
			// set current frame
			timeline.currentFrame = j;
				if (j <= 8){
							var tileName = docSplit[0] + '_' + timeline.layers[i].name + '_' + '000' + (j+1) + '.png';
					doc.exportPNG("file:///" + ROOT + tileName, false, true);
					}
				else if (j >= 9 &&  j <= 98){ 
							var tileName = docSplit[0] + '_' + timeline.layers[i].name + '_' + '00' + (j+1) + '.png';
					doc.exportPNG("file:///" + ROOT + tileName, false, true);
					}
				else if ( j >= 99 && j <= 998 ){ 
							var tileName = docSplit[0] + '_' + timeline.layers[i].name + '_' + '0' + (j+1) + '.png';
					doc.exportPNG("file:///" + ROOT + tileName, false, true);
					}
				else if ( j >= 999 && j <= 9998 ){ 
							var tileName = docSplit[0] + '_' + timeline.layers[i].name + '_' + (j+1) + '.png';
					doc.exportPNG("file:///" + ROOT + tileName, false, true);
					}
		}
}