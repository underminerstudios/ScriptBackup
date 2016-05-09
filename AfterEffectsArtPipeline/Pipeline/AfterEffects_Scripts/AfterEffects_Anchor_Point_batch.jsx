﻿
"object"!=typeof JSON&&(JSON={}),function(){"use strict";function f(t){return 10>t?"0"+t:t}function this_value(){return this.valueOf()}function quote(t){return rx_escapable.lastIndex=0,rx_escapable.test(t)?'"'+t.replace(rx_escapable,function(t){var e=meta[t];return"string"==typeof e?e:"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+t+'"'}function str(t,e){var r,n,o,u,f,a=gap,i=e[t];switch(i&&"object"==typeof i&&"function"==typeof i.toJSON&&(i=i.toJSON(t)),"function"==typeof rep&&(i=rep.call(e,t,i)),typeof i){case"string":return quote(i);case"number":return isFinite(i)?String(i):"null";case"boolean":case"null":return String(i);case"object":if(!i)return"null";if(gap+=indent,f=[],"[object Array]"===Object.prototype.toString.apply(i)){for(u=i.length,r=0;u>r;r+=1)f[r]=str(r,i)||"null";return o=0===f.length?"[]":gap?"[\n"+gap+f.join(",\n"+gap)+"\n"+a+"]":"["+f.join(",")+"]",gap=a,o}if(rep&&"object"==typeof rep)for(u=rep.length,r=0;u>r;r+=1)"string"==typeof rep[r]&&(n=rep[r],o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));else for(n in i)Object.prototype.hasOwnProperty.call(i,n)&&(o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));return o=0===f.length?"{}":gap?"{\n"+gap+f.join(",\n"+gap)+"\n"+a+"}":"{"+f.join(",")+"}",gap=a,o}}var rx_one=/^[\],:{}\s]*$/,rx_two=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,rx_three=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,rx_four=/(?:^|:|,)(?:\s*\[)+/g,rx_escapable=/[\\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,rx_dangerous=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;"function"!=typeof Date.prototype.toJSON&&(Date.prototype.toJSON=function(){return isFinite(this.valueOf())?this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z":null},Boolean.prototype.toJSON=this_value,Number.prototype.toJSON=this_value,String.prototype.toJSON=this_value);var gap,indent,meta,rep;"function"!=typeof JSON.stringify&&(meta={"\b":"\\b"," ":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},JSON.stringify=function(t,e,r){var n;if(gap="",indent="","number"==typeof r)for(n=0;r>n;n+=1)indent+=" ";else"string"==typeof r&&(indent=r);if(rep=e,e&&"function"!=typeof e&&("object"!=typeof e||"number"!=typeof e.length))throw new Error("JSON.stringify");return str("",{"":t})}),"function"!=typeof JSON.parse&&(JSON.parse=function(text,reviver){function walk(t,e){var r,n,o=t[e];if(o&&"object"==typeof o)for(r in o)Object.prototype.hasOwnProperty.call(o,r)&&(n=walk(o,r),void 0!==n?o[r]=n:delete o[r]);return reviver.call(t,e,o)}var j;if(text=String(text),rx_dangerous.lastIndex=0,rx_dangerous.test(text)&&(text=text.replace(rx_dangerous,function(t){return"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})),rx_one.test(text.replace(rx_two,"@").replace(rx_three,"]").replace(rx_four,"")))return j=eval("("+text+")"),"function"==typeof reviver?walk({"":j},""):j;throw new SyntaxError("JSON.parse")})}();


app.beginSuppressDialogs(); 
var piviot_points = get_piviot_points(DocToOpen[1],DocToOpen[2]);

run_psd_to_png();

fix_center_piviot(DocToOpen[2],piviot_points);

function get_piviot_points(file_to_open,all_comps){ 
    var open_file = file_to_open.split(".")
    
    app.open(File(file_to_open))
    
    app.project.activeItem.time = 0
    var piviot_points = []
    for (var i = 1; i <= app.project.numItems; i++){
        for (var j = 0; j <= all_comps.length; j ++){
            var bob = app.project.item(i)
            if (app.project.item(i) instanceof CompItem){
                    if (app.project.item(i).id == all_comps[j]){
                        for(var l_num = 1; l_num <= app.project.item(i).numLayers; l_num++) {
                            var comp = app.project.item(i).name
                            var layer = app.project.item(i).layer(l_num);
                            if(!layer.enabled) {
                              continue;
                            };
                            var comp = app.project.item(i).name
                            var layer_name = layer.name
                            var anchor_point = layer.Transform["Anchor Point"].value
                            piviot_points.push([
                                comp,
                                layer_name,
                                anchor_point
                                ]);
                      };
                  };
                };      
            };
        };
    return piviot_points
};



function run_psd_to_png(){
  var issues = []
    for (var i = 1; i <= app.project.numItems; i++){
        try{
            var is_psd_split = app.project.item(i).name.split(".");     
            var is_psd = is_psd_split[is_psd_split.length-1];

            }
        catch (e){
            break;
            };
        if (is_psd == "png"){
            var layer_split = app.project.item(i).name.split("/");
            try{
                var file_name_split = layer_split[0].split(' ')
                var file_name = file_name_split.join('_') + '.png'
            }
            catch(e){
                var file_name = layer_split[0]+".png"
            }
            
            var current_file = String(app.project.item(i).file)
            var folder_name_split = current_file.split("/")
            var full_name = folder_name_split[folder_name_split.length -1].split(".")
                try{
                    var remote_location = "Art/6_textures"
                    var full_folder_path = decodeURI (doc.path)  + '/' + remote_location + "/" + full_name[0]
                    var replacement_file = full_folder_path + "/" + file_name
                    app.project.item(i).replace(File(replacement_file));
                }
                catch(e){
                    issues.push(app.project.item(i).name)
                };
            }
        }
    try{
        makeJSONfile (issues, file_name)
        }
    catch(e){
        var bob = ""
        };
};



function makeJSONfile(issues,file_name){
    json_file_name = object_name + '.json';
    var Json_File = new File(Folder.desktop.absoluteURI + "/" + json_file_name);
    if (Json_File.open("w")){
      Json_File.encoding = "UTF-8";
        Json_File.write(JSON.stringify(issues,null,'\t'));
        };
      Json_File.close();
 }; 



function fix_center_piviot(all_comps,piviot_points){ 

    for (var i = 1; i <= app.project.numItems; i++){
        for (var j = 0; j <= all_comps.length; j ++){
            var bob = app.project.item(i)
            if (app.project.item(i) instanceof CompItem){
                    if (app.project.item(i).id == all_comps[j]){
                        for(var l_num = 1; l_num <= app.project.item(i).numLayers; l_num++) {
                            var comp = app.project.item(i).name
                            var layer = app.project.item(i).layer(l_num);
                            var comp = app.project.item(i).name
                            var layer_name = layer.name
                            for (var k= 1;k <= piviot_points.length;k++){
                           
                                var piviot_point_array = piviot_points[k];
                                
                                try{
                                    
                                    var piviot_point_name = piviot_point_array[1];
                                    var piviot_point_location = piviot_point_array[2];
                                    
                                    var piviot_point_x = piviot_point_location[0];
                                    var piviot_point_y = piviot_point_location[1];
                                    var piviot_point_z = piviot_point_location[2];
                                    

                                    }
                                catch(e){
                                    };
                                if (layer.name == piviot_point_name){
                                    var anchor_point_pre = layer.Transform["Anchor Point"].value
                                    layer.anchorPoint.setValue([piviot_point_x,piviot_point_y,piviot_point_z])
                                    var anchor_point_post = layer.Transform["Anchor Point"].value
                            };
                      };
                  };
                };      
            };
        };
};
};
