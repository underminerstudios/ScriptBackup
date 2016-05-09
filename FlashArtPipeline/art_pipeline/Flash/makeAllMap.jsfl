

//Minified version of json exporter.
"object"!=typeof JSON&&(JSON={}),function(){"use strict";function f(t){return 10>t?"0"+t:t}function this_value(){return this.valueOf()}function quote(t){return rx_escapable.lastIndex=0,rx_escapable.test(t)?'"'+t.replace(rx_escapable,function(t){var e=meta[t];return"string"==typeof e?e:"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+t+'"'}function str(t,e){var r,n,o,u,f,a=gap,i=e[t];switch(i&&"object"==typeof i&&"function"==typeof i.toJSON&&(i=i.toJSON(t)),"function"==typeof rep&&(i=rep.call(e,t,i)),typeof i){case"string":return quote(i);case"number":return isFinite(i)?String(i):"null";case"boolean":case"null":return String(i);case"object":if(!i)return"null";if(gap+=indent,f=[],"[object Array]"===Object.prototype.toString.apply(i)){for(u=i.length,r=0;u>r;r+=1)f[r]=str(r,i)||"null";return o=0===f.length?"[]":gap?"[\n"+gap+f.join(",\n"+gap)+"\n"+a+"]":"["+f.join(",")+"]",gap=a,o}if(rep&&"object"==typeof rep)for(u=rep.length,r=0;u>r;r+=1)"string"==typeof rep[r]&&(n=rep[r],o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));else for(n in i)Object.prototype.hasOwnProperty.call(i,n)&&(o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));return o=0===f.length?"{}":gap?"{\n"+gap+f.join(",\n"+gap)+"\n"+a+"}":"{"+f.join(",")+"}",gap=a,o}}var rx_one=/^[\],:{}\s]*$/,rx_two=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,rx_three=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,rx_four=/(?:^|:|,)(?:\s*\[)+/g,rx_escapable=/[\\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,rx_dangerous=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;"function"!=typeof Date.prototype.toJSON&&(Date.prototype.toJSON=function(){return isFinite(this.valueOf())?this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z":null},Boolean.prototype.toJSON=this_value,Number.prototype.toJSON=this_value,String.prototype.toJSON=this_value);var gap,indent,meta,rep;"function"!=typeof JSON.stringify&&(meta={"\b":"\\b"," ":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},JSON.stringify=function(t,e,r){var n;if(gap="",indent="","number"==typeof r)for(n=0;r>n;n+=1)indent+=" ";else"string"==typeof r&&(indent=r);if(rep=e,e&&"function"!=typeof e&&("object"!=typeof e||"number"!=typeof e.length))throw new Error("JSON.stringify");return str("",{"":t})}),"function"!=typeof JSON.parse&&(JSON.parse=function(text,reviver){function walk(t,e){var r,n,o=t[e];if(o&&"object"==typeof o)for(r in o)Object.prototype.hasOwnProperty.call(o,r)&&(n=walk(o,r),void 0!==n?o[r]=n:delete o[r]);return reviver.call(t,e,o)}var j;if(text=String(text),rx_dangerous.lastIndex=0,rx_dangerous.test(text)&&(text=text.replace(rx_dangerous,function(t){return"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})),rx_one.test(text.replace(rx_two,"@").replace(rx_three,"]").replace(rx_four,"")))return j=eval("("+text+")"),"function"==typeof reviver?walk({"":j},""):j;throw new SyntaxError("JSON.parse")})}();


//For each file export the following
for (i in inputs){

	//This is the scale we chose
	var outputScaleFactor = 1.861818181
	MapJsonData(inputs[i],outputScaleFactor)
	makeAssetPngs(inputs[i],outputScaleFactor)
	makeMapPngs(inputs[i])
	try{
	fl.closeDocument(fl.documents[0], false);
	}
	catch(e){}
}


	
function MapJsonData(fileToOpen,outputScaleFactor){
	//Makes the map json data
	fl.openDocument(fileToOpen)

	
	
	var doc = fl.getDocumentDOM()
	var documentWidth = doc.width
	var documentHeight = doc.height

	//Scales the art to what we want
	doc.width= documentWidth*outputScaleFactor;
	doc.height= documentHeight*outputScaleFactor;

	//Select everything and scale the art from the top left corner
	document.selectAll()
	document.scaleSelection(outputScaleFactor,outputScaleFactor,"top left")
		
	//get all the paths of everything
	var LayerObjects = doc.getTimeline().layers;
	var pngFileName = fl.getDocumentDOM().pathURI
	var jsonFileName = fl.getDocumentDOM().pathURI

	var roads = []
	var roadID = []
	var roadName = []
	var roadPosition = []
	var roadScale = []
	var cities = []
	var cityID = []
	var cityName = []
	var cityPosition = []
	var cityScale = []
	var unlock = []
	var unlockPosition = []
	var items = []
	var itemsPosition = []
	var bonus = []
	var bonusPosition = []
	var level = []
	var levelPosition = []
	var construction = []
	var constructionPosition = []

	//go through everything and get the information on the objects
	for (var i in LayerObjects){
		var StuffOnTimeline = LayerObjects[i].frames[0].elements
		for (var j in StuffOnTimeline){
			var elementName = StuffOnTimeline[j].name
			elementNameSplit = elementName.split("_")
			
			//get the library name of the object
			var getParentObj = StuffOnTimeline[j].libraryItem

				//if it's a road then change it's screen space to bottom center and push all it's info
				if (elementName.substring(0,4)=="road"){
					roads.push(elementName)
					roadID.push(parseInt(elementNameSplit[1]))
					roadName.push(StuffOnTimeline[j].libraryItem.name)
					roadPosition.push([(StuffOnTimeline[j].transformX - 1049)/100,(StuffOnTimeline[j].transformY-540)/100])
					roadScale.push([StuffOnTimeline[j].scaleX,StuffOnTimeline[j].scaleY])	
				}

				//if it's a city then get it's info and push it up. Also get all the children's locations
				else if (elementName.substring(0,4)=="city"){
					fl.trace(elementName)
					if (StuffOnTimeline[j].libraryItem.name !=="construction site bingo"){
						cities.push(elementName)
						cityID.push(parseInt(elementNameSplit[1]))
						cityName.push(StuffOnTimeline[j].libraryItem.name)
						cityPosition.push([StuffOnTimeline[j].transformX,StuffOnTimeline[j].transformX])
						cityScale.push([StuffOnTimeline[j].scaleX,StuffOnTimeline[j].scaleY])
						
						var getChildObj = getParentObj.timeline
						
						var childrenLayer = getChildObj.layers
						for (var l in childrenLayer){
							var children = childrenLayer[l].frames[0].elements
							for (var k in children){
								fl.trace(children[k].name)
								if (children[k].name.substring(0,4)=="unlo"){
									unlock.push(children[k].name)
									unlockPosition.push([children[k].transformX,children[k].transformY])
									
								}
								else if (children[k].name.substring(0,4)=="item"){
									items.push(children[k].name)
									itemsPosition.push([children[k].transformX,children[k].transformY])
									
								}
								else if (children[k].name.substring(0,4)=="bonu"){
									bonus.push(children[k].name)
									bonusPosition.push([children[k].transformX,children[k].transformY])
									
								}
								else if (children[k].name.substring(0,4)=="leve"){
									level.push(children[k].name)
									levelPosition.push([children[k].transformX,children[k].transformY])
								}
							}
						}
					}
					//If it's a construction site then get it's location too
					else if(StuffOnTimeline[j].libraryItem.name =="construction site bingo"){
						construction.push(elementName)
						constructionPosition.push([StuffOnTimeline[j].transformX,StuffOnTimeline[j].transformY,0])
						}
					
					
							
						}
					}
				}

		//makes a dict for all the information.
		var mapData = {}
		mapData["Roads"] = roads
		mapData["RoadID"] = roadID
		mapData["RoadName"] = roadName
		mapData["RoadPosition"] = roadPosition
		mapData["RoadScale"] = roadScale
		mapData["Cities"] = cities
		mapData["CityID"] = cityID
		mapData["CityName"] = cityName
		mapData["CityPosition"] = cityPosition
		mapData["CityScale"] = cityScale
		mapData["Unlock"] = unlock
		mapData["UnlockPosition"] = unlockPosition
		mapData["Items"] = items
		mapData["ItemsPosition"] = itemsPosition
		mapData["Bonus"] = bonus
		mapData["BonusPosition"] = bonusPosition
		mapData["Level"] = level
		mapData["LevelPosition"] = levelPosition
		mapData["Construction"] = construction
		mapData["ConstructionPosition"] = constructionPosition
		var JsonInfo = JSON.stringify(makeJson(mapData),null,'\t')
		makeJSONfile(JsonInfo,jsonFileName)

};
	
//
//Make JSON DATA//
//

function makeJson(mapData){
//This is a fun concept. It allows you to not know how many of each object there is but push them into the correct location 
//once they are stringified below.  Pretty cool!
	var Json = {
		'version' : '1.0',
		'cities' : [],
		'roads'  : [],
		'construction' : []
	}

	for (var w in mapData["CityID"]){

		Json.cities.push(CityMaker(mapData,w))
	};
	for (var x in mapData["RoadID"]){
		Json.roads.push(RoadMaker(mapData,x))
	};
	for(var y in mapData["Construction"]){
		Json.construction.push(ConstructionMaker(mapData,y))
	};
	return Json
};

function RoadMaker(mapData,x){
//Make the roads info
	var road = {"id": mapData["RoadID"][x],"name": mapData["RoadName"][x],"position": [mapData["RoadPosition"][x][0],mapData["RoadPosition"][x][1],0],"scale": [mapData["RoadScale"][x][0],mapData["RoadScale"][x][1],0]}
	return road
};


function CityMaker(mapData,w){
//Make the city info
	var city = {"id": mapData["CityID"][w],"name": mapData["CityName"][w],"position": [mapData["CityPosition"][w][0],mapData["CityPosition"][w][1],0],"scale": [mapData["CityScale"][w][0],mapData["CityScale"][w][1],0],"unlock": {"position": [mapData["UnlockPosition"][w][0],mapData["UnlockPosition"][w][1],0]},"items": {"position": [mapData["ItemsPosition"][w][0],mapData["ItemsPosition"][w][1],0]},"bonus": {"position": [mapData["BonusPosition"][w][0],mapData["BonusPosition"][w][1],0]}}
	return city
};

function ConstructionMaker(mapData,y){
//Make the construction information
	var construction = {"constructionName": mapData["Construction"][y],"constructionLocation": mapData["ConstructionPosition"][y]}
	return construction
}


function makeJSONfile(JsonInfo,jsonFileName){
//Make the actual json from the output.  Fun thats how flash does it... JOKE
	var jsonFileNameSplit = jsonFileName.split(".")[0]
	var jsonFileName = jsonFileNameSplit + "_data" + ".json"
	var jsonFileName = jsonFileName.replace("_v2","")
	fl.outputPanel.clear();
	fl.outputPanel.trace(JsonInfo)
	fl.outputPanel.save(jsonFileName)
	fl.outputPanel.clear();
}; 



function makeAssetPngs(fileToOpen,outputScaleFactor)
{

//Lets get all the objects minus map objects prepare them for outputing with the object name coming from the element name not the 
//library name

	fl.openDocument(fileToOpen)
	// Clear the output panel 
	var doc = fl.getDocumentDOM()
		
	var LayerObjects = doc.getTimeline().layers;
	var pngFileName = fl.getDocumentDOM().pathURI
	var pngFileName = pngFileName.replace("_v2","")

	for (var i in LayerObjects){
		var StuffOnTimeline = LayerObjects[i].frames[0].elements
		for (var j in StuffOnTimeline){
			var elementName = StuffOnTimeline[j].name
			elementNameSplit = elementName.split("_")
			var getParentObj = StuffOnTimeline[j].libraryItem

				if (elementName.substring(0,4)=="road"){
					exportItemAsPng(getParentObj, outputScaleFactor,pngFileName,true,elementName)

				}
				else if (elementName.substring(0,4)=="city"){
					exportItemAsPng(getParentObj, outputScaleFactor,pngFileName,true,elementName)
				}
		}
	}

}

function makeMapPngs(fileToOpen){
//Get the map pngs and prepare them for output

fl.openDocument(fileToOpen)
	// Clear the output panel 
	var doc = fl.getDocumentDOM()
		
	var LayerObjects = doc.getTimeline().layers;
	var pngFileName = fl.getDocumentDOM().pathURI
	var pngFileName = pngFileName.replace("_v2","")
	for (var i in LayerObjects){
		if (LayerObjects[i].name.substring(0,2)=="pg" || LayerObjects[i].name.substring(0,2)=="pa"){
			for (x in LayerObjects){
				LayerObjects[x].visible = false
			}
			LayerObjects[i].visible = true
			outputScaleFactor = 1
			exportItemAsPng("getParentObj", outputScaleFactor,pngFileName,false,"")
			}
		}
	};

function exportItemAsPng(item,scaleFactor,pngFileName,notMap,elementName){
//Export the pngs with the correct name
	if (notMap){
		var pngFileName = pngFileName.split(".")[0];
		var pngFileName = pngFileName + "_" + elementName + ".png"
		var newDoc = fl.createDocument();
		var newDom = fl.getDocumentDOM();
	    newDoc.addItem({x:0.0, y:0.0}, item);
	    newDom.library.selectItem(item.name, false);
	    newDoc.scaleSelection(scaleFactor, scaleFactor);
	}
	else{
		var pngFileName = pngFileName.split(".")[0];
		var pngFileName = pngFileName + "_" + "bg" + ".png"
		var newDoc = fl.getDocumentDOM();
		newDoc.scaleSelection(scaleFactor, scaleFactor);

	}
    // verify that the path exists
    // this will still fail if the library item is more than one folder deep
    FLfile.createFolder(pngFileName.substring(0, pngFileName.lastIndexOf("/")));
    

    newDoc.exportPNG(pngFileName, true, false);
    try{
    	newDoc.deleteSelection();
    }
    catch(e){
    }
    //As we go along close each file
    newDoc.scaleSelection(1, 1);
    try{
    	fl.closeDocument(fl.documents[1], false);
    }
    catch(e){
    }

}
