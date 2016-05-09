#target photoshop
var iniPath = $.getenv("APPDATA")  +  "\\Adobe\\DH5_make_PSD.ini"
var _file = new File(iniPath);
var startUpPath = getIniData ( _file )

var dlg = new Window('dialog', 'My first script!',[100,100,405,160]);
dlg.browseBtn   = dlg.add('button', [270,3,300,28], '..', {name:'ok'});
dlg.pathEt         = dlg.add('edittext', [3,3,270,28], startUpPath);
dlg.makeBtn   = dlg.add('button', [200,30,300,53], 'Make Base PSD', {name:'ok'});

dlg.browseBtn.onClick = getFolder ;
dlg.makeBtn.onClick = makePSD;

dlg.center();
dlg.show();

function setIniData (_file, _string){
    _file.open('w');
    _file.writeln(_string);
    _file.close();
}

function getIniData ( _file ){
    var _path = "C:\\Temp"
    if (!_file.exists) {
        setIniData (_file, _path)
    }
    else {
        _file.open('r');
        _path = "";
        while(!_file.eof){
            _path += _file.readln();
        }
    _file.close();
    }
    return _path
}

function getFolder(){
    // Get the folder where all the tgas are located
    var inputFolder = Folder.selectDialog("Select a folder to process", dlg.pathEt.text ,true);
    if (inputFolder != null){
        var str=inputFolder.absoluteURI;     
        str = str.substr(0, 2) + ":" + str.substr(2);
        var n= str.substr(1);        
        dlg.pathEt.text = n
    }
    inputFolder = null;
    str = null;
    n = null;
}
function setRGBChannels (){//function from listener
    var idslct = charIDToTypeID( "slct" );
    var desc34 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
    var ref24 = new ActionReference();
    var idChnl = charIDToTypeID( "Chnl" );
    var idChnl = charIDToTypeID( "Chnl" );
    var idRGB = charIDToTypeID( "RGB " );
    ref24.putEnumerated( idChnl, idChnl, idRGB );
    desc34.putReference( idnull, ref24 );
    executeAction( idslct, desc34, DialogModes.NO );
    }
function setAlphaChannel( alphaChannelName ){//function from listener
        var idslct = charIDToTypeID( "slct" );
        var desc22 = new ActionDescriptor();
        var idnull = charIDToTypeID( "null" );
        var ref15 = new ActionReference();
        var idChnl = charIDToTypeID( "Chnl" );
        ref15.putName( idChnl, alphaChannelName );
        desc22.putReference( idnull, ref15 );
        executeAction( idslct, desc22, DialogModes.NO );
    }
function addHueSaturationAdjustment(){//function from listener
    var idMk = charIDToTypeID( "Mk  " );
    var desc55 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref35 = new ActionReference();
        var idAdjL = charIDToTypeID( "AdjL" );
        ref35.putClass( idAdjL );
    desc55.putReference( idnull, ref35 );
    var idUsng = charIDToTypeID( "Usng" );
        var desc56 = new ActionDescriptor();
        var idGrup = charIDToTypeID( "Grup" );
        desc56.putBoolean( idGrup, true );
        var idType = charIDToTypeID( "Type" );
            var desc57 = new ActionDescriptor();
            var idpresetKind = stringIDToTypeID( "presetKind" );
            var idpresetKindType = stringIDToTypeID( "presetKindType" );
            var idpresetKindDefault = stringIDToTypeID( "presetKindDefault" );
            desc57.putEnumerated( idpresetKind, idpresetKindType, idpresetKindDefault );
            var idClrz = charIDToTypeID( "Clrz" );
            desc57.putBoolean( idClrz, false );
        var idHStr = charIDToTypeID( "HStr" );
        desc56.putObject( idType, idHStr, desc57 );
    var idAdjL = charIDToTypeID( "AdjL" );
    desc55.putObject( idUsng, idAdjL, desc56 );
return executeAction( idMk, desc55, DialogModes.NO );
}
function addCurveAdjustment(){
var idMk = charIDToTypeID( "Mk  " );
    var desc23 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref7 = new ActionReference();
        var idAdjL = charIDToTypeID( "AdjL" );
        ref7.putClass( idAdjL );
    desc23.putReference( idnull, ref7 );
    var idUsng = charIDToTypeID( "Usng" );
        var desc24 = new ActionDescriptor();
        var idGrup = charIDToTypeID( "Grup" );
        desc24.putBoolean( idGrup, true );
        var idType = charIDToTypeID( "Type" );
            var desc25 = new ActionDescriptor();
            var idpresetKind = stringIDToTypeID( "presetKind" );
            var idpresetKindType = stringIDToTypeID( "presetKindType" );
            var idpresetKindDefault = stringIDToTypeID( "presetKindDefault" );
            desc25.putEnumerated( idpresetKind, idpresetKindType, idpresetKindDefault );
        var idCrvs = charIDToTypeID( "Crvs" );
        desc24.putObject( idType, idCrvs, desc25 );
    var idAdjL = charIDToTypeID( "AdjL" );
    desc23.putObject( idUsng, idAdjL, desc24 );
executeAction( idMk, desc23, DialogModes.NO );
}
function maskSelectedLayer(){//function from listener
    var idMk = charIDToTypeID( "Mk  " );
    var desc128 = new ActionDescriptor();
    var idNw = charIDToTypeID( "Nw  " );
    var idChnl = charIDToTypeID( "Chnl" );
    desc128.putClass( idNw, idChnl );
    var idAt = charIDToTypeID( "At  " );
    var ref85 = new ActionReference();
    var idChnl = charIDToTypeID( "Chnl" );
    var idChnl = charIDToTypeID( "Chnl" );
    var idMsk = charIDToTypeID( "Msk " );
    ref85.putEnumerated( idChnl, idChnl, idMsk );
    desc128.putReference( idAt, ref85 );
    var idUsng = charIDToTypeID( "Usng" );
    var idUsrM = charIDToTypeID( "UsrM" );
    var idRvlS = charIDToTypeID( "RvlS" );
    desc128.putEnumerated( idUsng, idUsrM, idRvlS );
    executeAction( idMk, desc128, DialogModes.NO );
}

function moveLayerSet( fromLayer, toLayer ){// layerSet objects
    var desc = new ActionDescriptor();
        var sourceRef = new ActionReference();
        sourceRef.putName( charIDToTypeID( "Lyr " ), fromLayer.name );
    desc.putReference( charIDToTypeID( "null" ), sourceRef );
            var indexRef = new ActionReference();
            indexRef.putName( charIDToTypeID("Lyr "), toLayer.name );
            var layerIndex = executeActionGet(indexRef).getInteger(stringIDToTypeID('itemIndex'));
        var destinationRef = new ActionReference();
        destinationRef.putIndex( charIDToTypeID( "Lyr " ), layerIndex-1 );
    desc.putReference( charIDToTypeID( "T   " ), destinationRef );
    desc.putBoolean( charIDToTypeID( "Adjs" ), false );
    desc.putInteger( charIDToTypeID( "Vrsn" ), 5 );
    executeAction( charIDToTypeID( "move" ), desc, DialogModes.NO );
}
function hideLayers() { //function from listener
    var idHd = charIDToTypeID( "Hd  " );
    var desc159 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
    var list13 = new ActionList();
    var ref93 = new ActionReference();
    var idLyr = charIDToTypeID( "Lyr " );
    var idOrdn = charIDToTypeID( "Ordn" );
    var idTrgt = charIDToTypeID( "Trgt" );
    ref93.putEnumerated( idLyr, idOrdn, idTrgt );
    list13.putReference( ref93 );
    desc159.putList( idnull, list13 );
    executeAction( idHd, desc159, DialogModes.NO );
}
function setGreenChannel(){
var idslct = charIDToTypeID( "slct" );
    var desc13 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref2 = new ActionReference();
        var idChnl = charIDToTypeID( "Chnl" );
        var idChnl = charIDToTypeID( "Chnl" );
        var idGrn = charIDToTypeID( "Grn " );
        ref2.putEnumerated( idChnl, idChnl, idGrn );
    desc13.putReference( idnull, ref2 );
executeAction( idslct, desc13, DialogModes.NO );
}
function makePSD(){
    var inputFolder = Folder(dlg.pathEt.text);
    var files = inputFolder.getFiles("*.TGA");

    if (files.length != 0 ){

        var fileList = inputFolder.getFiles("*.TGA");
        var psdSize = 512  
        var tkns=String(inputFolder).split("/");
        var psdFileName = tkns[tkns.length - 2]
        var imageArr = new Array();
        var dfImg = null 
        var aoImg = null 
        var nmImg = null 
        var cmImg = null 
        var hmImg = null 
        var curImg = null 

        for(var i=0; i<fileList.length; i++) {
        var filePath = String(fileList[i])
        var tkns=filePath.split("/");
        var count = tkns.length;
        var tgaFileName = tkns[count-1]

        // work only on images that have a cetian ending
        var imtkns= tgaFileName.split("_");
        if (imtkns.length > 1) {
            var imgType =  imtkns[imtkns.length -1].toLowerCase();
            if (imgType == "cavity.tga"){
                cmImg = new File(filePath);
            }
            if (imgType == "heights.tga"){
                hmImg = new File(filePath);
            }
            if (imgType == "normals.tga"){
                nmImg = new File(filePath);
            }
            if (imgType == "occlusion.tga"){
                aoImg = new File(filePath);
            }
            if (imgType == "vcols.tga"){
                dfImg = new File(filePath);
            }
            if (imgType == "curvature.tga"){
                curImg = new File(filePath);
            }
            }
        }
        //create a new psd document if diffuse exists .     
        if (dfImg != null){
            var difSrc = app.open(dfImg)
            var xRes = difSrc.width;
            var yRes = difSrc.height;

            difSrc.selection.selectAll();

            var diffChannels = difSrc.channels;
            if (diffChannels.length > 3){
                //Copy the alpha channel
                var alphaChannelName = diffChannels[3].name;
                setAlphaChannel( alphaChannelName );

                var alphaChannelCopy = charIDToTypeID( "copy" );
                executeAction( alphaChannelCopy, undefined, DialogModes.NO );
            }

            app.preferences.rulerUnits = Units.PIXELS;
            var psdDoc = app.documents.add(Number(xRes), Number(yRes), difSrc.resolution, psdFileName);
            var layerRef = app.activeDocument.layers[0];
            psdDoc.selection.selectAll();
            var fillColor = new SolidColor();
            fillColor.rgb.red  = 128;
            fillColor.rgb.green  = 128;
            fillColor.rgb.blue  = 128;
            psdDoc.selection.fill(fillColor)
            fillColor = null

            //paste the Alpha mask from the diffuse
            var selAlpha = psdDoc.channels.add();
            setAlphaChannel( selAlpha.name );
            psdDoc.paste();

            //Make the main group
            var globalGroup = psdDoc.layerSets.add();
            psdDoc.selection.load(selAlpha, SelectionType.REPLACE, false);
            maskSelectedLayer()
            globalGroup.name= psdFileName;
            psdDoc.selection.deselect();
            
            
            //Get the diffuse image
            app.activeDocument = difSrc;
            setRGBChannels ();
            difSrc.selection.copy(); 
            app.activeDocument.close();
            app.activeDocument = psdDoc;
            setRGBChannels ();
            layerRef = psdDoc.paste();
            layerRef.name = "diffuse"


             if (aoImg != null){
                //Get the Ambient Occlusion image
                var aoSrc = app.open(aoImg);
                aoSrc.selection.selectAll();
                aoSrc.selection.copy(); 
                app.activeDocument.close();
                app.activeDocument = psdDoc;
                layerRef = psdDoc.paste();
                layerRef.name = "ao";
                layerRef.blendMode = BlendMode.MULTIPLY;
                var adjRef = addHueSaturationAdjustment();
                adjRef.name = "HS_AO";
            }
            if (cmImg != null){
                //Get the Cavity image
                var cmSrc = app.open(cmImg);
                cmSrc.selection.selectAll();
                cmSrc.selection.copy(); 
                app.activeDocument.close();
                app.activeDocument = psdDoc;
                layerRef = psdDoc.paste();
                layerRef.name = "cavity";
                layerRef.blendMode = BlendMode.MULTIPLY
                adjRef = addHueSaturationAdjustment();
                adjRef.name = "HS_CM";
            }
            if (curImg != null){
                //Get the Curvature image
                var curSrc = app.open(curImg);
                setGreenChannel();
                curSrc.selection.selectAll();
                curSrc.selection.copy(); 
                app.activeDocument.close();
                app.activeDocument = psdDoc;
                layerRef = psdDoc.paste();
                layerRef.name = "curvature-G";
                layerRef.blendMode = BlendMode.MULTIPLY;
                adjRef = addCurveAdjustment();
                //adjRef.name = "CR_CU"
            }
            // set the normals group
            var normalsGroup = psdDoc.layerSets.add();
            normalsGroup.name= "normals";
            moveLayerSet( normalsGroup, globalGroup )
            hideLayers();
            
            if (hmImg != null){
                //Get the Height image
                var hmSrc = app.open(hmImg);
                hmSrc.selection.selectAll();
                hmSrc.selection.copy(); 
                app.activeDocument.close();
                app.activeDocument = psdDoc;
                layerRef = psdDoc.paste();
                layerRef.name = "height";
            }
            
            if (nmImg != null){
                //Get the Normals image
                var nmSrc = app.open(nmImg);
                nmSrc.selection.selectAll();
                nmSrc.selection.copy(); 
                app.activeDocument.close();
                app.activeDocument = psdDoc;
                layerRef = psdDoc.paste();
                layerRef.name = "normals";
            }
            
            dfImg = null ;
            aoImg = null ;
            nmImg = null ;
            cmImg= null ;
            hmImg= null ;
            curImg = null;
            pasteDoc = null;
            layerRef = null
            adjRef = null
            aoSrc = null
            cmSrc= null
            hmSrc = null
            nmSrc = null
            globalGroup = null
            normalsGroup = null
        }
        setIniData (_file, dlg.pathEt.text)
        dlg.close();
    }
}