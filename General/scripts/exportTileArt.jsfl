//var ROOT = "C|/Users/slee/Desktop/jacob/USSports/tiles/";
var ROOT = "C:/script_test/";
//var ROOT = "C:/Users/slee/Desktop/Dan/Pirate Plunder/tiles/";
//var ROOT = "C:/Users/slee/Desktop/CASINO/temp/";

var doc = fl.getDocumentDOM();
var timeline = doc.getTimeline();
var lib = doc.library;

//lib.editItem("mcPaytable");
timeline = doc.getTimeline();


for(var i = 0; i < 16; i++)
{
	// set current frame
	timeline.currentFrame = i;
	
	var tileName = "tile" + (i + 1) + ".png";
	
	doc.exportPNG("file:///" + ROOT + tileName, false, true);
}