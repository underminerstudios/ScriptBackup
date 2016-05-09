input = ["file:///C|/PRODBKLG/trunk/Shapes1.fla"]

//minified version of the json library
"object"!=typeof JSON&&(JSON={}),function(){"use strict";function f(t){return 10>t?"0"+t:t}function this_value(){return this.valueOf()}function quote(t){return rx_escapable.lastIndex=0,rx_escapable.test(t)?'"'+t.replace(rx_escapable,function(t){var e=meta[t];return"string"==typeof e?e:"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+t+'"'}function str(t,e){var r,n,o,u,f,a=gap,i=e[t];switch(i&&"object"==typeof i&&"function"==typeof i.toJSON&&(i=i.toJSON(t)),"function"==typeof rep&&(i=rep.call(e,t,i)),typeof i){case"string":return quote(i);case"number":return isFinite(i)?String(i):"null";case"boolean":case"null":return String(i);case"object":if(!i)return"null";if(gap+=indent,f=[],"[object Array]"===Object.prototype.toString.apply(i)){for(u=i.length,r=0;u>r;r+=1)f[r]=str(r,i)||"null";return o=0===f.length?"[]":gap?"[\n"+gap+f.join(",\n"+gap)+"\n"+a+"]":"["+f.join(",")+"]",gap=a,o}if(rep&&"object"==typeof rep)for(u=rep.length,r=0;u>r;r+=1)"string"==typeof rep[r]&&(n=rep[r],o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));else for(n in i)Object.prototype.hasOwnProperty.call(i,n)&&(o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));return o=0===f.length?"{}":gap?"{\n"+gap+f.join(",\n"+gap)+"\n"+a+"}":"{"+f.join(",")+"}",gap=a,o}}var rx_one=/^[\],:{}\s]*$/,rx_two=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,rx_three=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,rx_four=/(?:^|:|,)(?:\s*\[)+/g,rx_escapable=/[\\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,rx_dangerous=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;"function"!=typeof Date.prototype.toJSON&&(Date.prototype.toJSON=function(){return isFinite(this.valueOf())?this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z":null},Boolean.prototype.toJSON=this_value,Number.prototype.toJSON=this_value,String.prototype.toJSON=this_value);var gap,indent,meta,rep;"function"!=typeof JSON.stringify&&(meta={"\b":"\\b"," ":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},JSON.stringify=function(t,e,r){var n;if(gap="",indent="","number"==typeof r)for(n=0;r>n;n+=1)indent+=" ";else"string"==typeof r&&(indent=r);if(rep=e,e&&"function"!=typeof e&&("object"!=typeof e||"number"!=typeof e.length))throw new Error("JSON.stringify");return str("",{"":t})}),"function"!=typeof JSON.parse&&(JSON.parse=function(text,reviver){function walk(t,e){var r,n,o=t[e];if(o&&"object"==typeof o)for(r in o)Object.prototype.hasOwnProperty.call(o,r)&&(n=walk(o,r),void 0!==n?o[r]=n:delete o[r]);return reviver.call(t,e,o)}var j;if(text=String(text),rx_dangerous.lastIndex=0,rx_dangerous.test(text)&&(text=text.replace(rx_dangerous,function(t){return"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})),rx_one.test(text.replace(rx_two,"@").replace(rx_three,"]").replace(rx_four,"")))return j=eval("("+text+")"),"function"==typeof reviver?walk({"":j},""):j;throw new SyntaxError("JSON.parse")})}();


//sets up the output scale factor based on the rest of the game.
var outputScaleFactor = 1.861818181
for (i in inputs){
	makePngs(input[i],outputScaleFactor)
	try{
	fl.closeDocument(fl.documents[0], false);
	}
	catch(e){}

}

//this will make a json file so that we can keep data about multiple colors etc

function makeJSONfile(){
	var jsonFileName = fl.getDocumentDOM().pathURI
	var jsonFileNameSplit = jsonFileName.split(".")[0]
	var jsonFileName = jsonFileNameSplit + "_data.json"
	var jsonFileName = jsonFileName.replace("_v2","")
	fl.outputPanel.trace(JsonInfo)
	fl.outputPanel.save(jsonFileName)
	fl.outputPanel.clear();
}; 



function makePngs(fileToOpen,outputScaleFactor){

//get all the objects we need to make pngs with

	fl.openDocument(fileToOpen)
	var doc = fl.getDocumentDOM()
		
	var LayerObjects = doc.getTimeline().layers;
	var pngFileName = fl.getDocumentDOM().pathURI
	for (var i in LayerObjects){
		var StuffOnTimeline = LayerObjects[i].frames[0].elements
		for (var j in StuffOnTimeline){
			var elementName = StuffOnTimeline[j].name
			fl.trace(elementName)
			var elementNameSplit = elementName.split("_")
			var getParentObj = StuffOnTimeline[j].libraryItem
			exportItemAsPng(getParentObj,elementName,outputScaleFactor,pngFileName)
			
		}
	}
}


function exportItemAsPng(item,pngName,scaleFactor,pngFileName){

//export files as pngs with the scale above.
	try{
		var pngFileName = pngFileName.split(".")[0];
		var pngFileName = pngFileName + "_" + pngName + ".png"
		var newDoc = fl.createDocument();
		var newDom = fl.getDocumentDOM();
	    newDoc.addItem({x:0.0, y:0.0}, item);
	    newDom.library.selectItem(item.name, false);
		fl.trace(scaleFactor)
	    newDoc.scaleSelection(scaleFactor, scaleFactor);
	    FLfile.createFolder(pngFileName.substring(0, pngFileName.lastIndexOf("/")));

	    newDoc.exportPNG(pngFileName, true, false);	
	    

	    try{
    	newDoc.deleteSelection();
	    }
	    catch(e){
	    }
	    newDoc.scaleSelection(1, 1);
	    // close the documents as they are made
	    try{
	    	fl.closeDocument(fl.documents[1], false);
	    }
    catch(e){
    }
 
}
