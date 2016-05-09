/*
ae after effects xml export script 
get composition duration
get x and y location from compositions

*/
// minified version of the JSON library
"object"!=typeof JSON&&(JSON={}),function(){"use strict";function f(t){return 10>t?"0"+t:t}function this_value(){return this.valueOf()}function quote(t){return rx_escapable.lastIndex=0,rx_escapable.test(t)?'"'+t.replace(rx_escapable,function(t){var e=meta[t];return"string"==typeof e?e:"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+t+'"'}function str(t,e){var r,n,o,u,f,a=gap,i=e[t];switch(i&&"object"==typeof i&&"function"==typeof i.toJSON&&(i=i.toJSON(t)),"function"==typeof rep&&(i=rep.call(e,t,i)),typeof i){case"string":return quote(i);case"number":return isFinite(i)?String(i):"null";case"boolean":case"null":return String(i);case"object":if(!i)return"null";if(gap+=indent,f=[],"[object Array]"===Object.prototype.toString.apply(i)){for(u=i.length,r=0;u>r;r+=1)f[r]=str(r,i)||"null";return o=0===f.length?"[]":gap?"[\n"+gap+f.join(",\n"+gap)+"\n"+a+"]":"["+f.join(",")+"]",gap=a,o}if(rep&&"object"==typeof rep)for(u=rep.length,r=0;u>r;r+=1)"string"==typeof rep[r]&&(n=rep[r],o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));else for(n in i)Object.prototype.hasOwnProperty.call(i,n)&&(o=str(n,i),o&&f.push(quote(n)+(gap?": ":":")+o));return o=0===f.length?"{}":gap?"{\n"+gap+f.join(",\n"+gap)+"\n"+a+"}":"{"+f.join(",")+"}",gap=a,o}}var rx_one=/^[\],:{}\s]*$/,rx_two=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,rx_three=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,rx_four=/(?:^|:|,)(?:\s*\[)+/g,rx_escapable=/[\\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,rx_dangerous=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;"function"!=typeof Date.prototype.toJSON&&(Date.prototype.toJSON=function(){return isFinite(this.valueOf())?this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z":null},Boolean.prototype.toJSON=this_value,Number.prototype.toJSON=this_value,String.prototype.toJSON=this_value);var gap,indent,meta,rep;"function"!=typeof JSON.stringify&&(meta={"\b":"\\b"," ":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},JSON.stringify=function(t,e,r){var n;if(gap="",indent="","number"==typeof r)for(n=0;r>n;n+=1)indent+=" ";else"string"==typeof r&&(indent=r);if(rep=e,e&&"function"!=typeof e&&("object"!=typeof e||"number"!=typeof e.length))throw new Error("JSON.stringify");return str("",{"":t})}),"function"!=typeof JSON.parse&&(JSON.parse=function(text,reviver){function walk(t,e){var r,n,o=t[e];if(o&&"object"==typeof o)for(r in o)Object.prototype.hasOwnProperty.call(o,r)&&(n=walk(o,r),void 0!==n?o[r]=n:delete o[r]);return reviver.call(t,e,o)}var j;if(text=String(text),rx_dangerous.lastIndex=0,rx_dangerous.test(text)&&(text=text.replace(rx_dangerous,function(t){return"\\u"+("0000"+t.charCodeAt(0).toString(16)).slice(-4)})),rx_one.test(text.replace(rx_two,"@").replace(rx_three,"]").replace(rx_four,"")))return j=eval("("+text+")"),"function"==typeof reviver?walk({"":j},""):j;throw new SyntaxError("JSON.parse")})}();

main(DocToOpen[1],DocToOpen[2])

app.project.activeItem.time = 0

function main(file_to_open,id_of_items){ 
app.beginSuppressDialogs();   
app.open(File(file_to_open))


var setTo = file_to_open.toString()
var split_string = setTo.split("_");
var tail_to_split = split_string[split_string.length-1].split(".");
var comp_to_look_for = split_string[split_string.length-2] + "_" + tail_to_split[0] 

for (var i = 1; i <= app.project.numItems; i++){
    if (app.project.item(i) instanceof CompItem){
            if (app.project.item(i).name == comp_to_look_for){
                app.project.item(i).time = 0;
                };
            
    };
};

for (var z = 0; z < id_of_items.length; z++){
        
        for (var y = 1; y < app.project.numItems; y ++){
            
          if (app.project.item(y).id == id_of_items[z]){
                    var item_to_use = app.project.item(y)
                    run_all(item_to_use);
                    break;
                    };
                };
        };
        
};



function run_all(item_to_use){
   
var fileName;
var frameDuration;
 
var MAIN_STEAM = 1;
var SUB_STEAM = 2;

var outputString          = '';
var subSteam              = '';
var usedCompositionIds    =  new Array();
var usedCompositions      =  new Array();
var json_info             = [];

var animation_start_time  = get_composition_info(item_to_use);


exportAnimation(animation_start_time,item_to_use);
 
  function get_composition_info(item_to_use)
    {
        

        proj = app.project
        var bob = item_to_use.name
        if (!(item_to_use instanceof CompItem)) {
                alert("Please select composition for import");
                return;
            };
        else{
          var animation_start_time = (item_to_use.time*item_to_use.frameRate);
        }
        return animation_start_time
    }

    function exportAnimation(animation_start_time,item_to_use) {

            if (!(item_to_use instanceof CompItem)) {
                alert("Please select composition for import");
                return;
            }
    
            fileName = item_to_use.name + '.xml';
            frameDuration = item_to_use.frameDuration;
            

            output('<?xml version="1.0" encoding="utf-8"?>', MAIN_STEAM);
            output('<after_affect_animation_doc>', MAIN_STEAM);
            exportLayers(item_to_use, MAIN_STEAM,item_to_use);
           
            
            
            
            output('<sub_items>', MAIN_STEAM);
            
            while(usedCompositions.length > 0) {
                comp = usedCompositions.pop();
                exportLayers(comp, MAIN_STEAM,item_to_use);
            }
            
            var i = usedCompositions.length;
            while (i--) {
               exportLayers(usedCompositions[i], MAIN_STEAM,item_to_use);
            }
            
            var totalFrames = Math.floor(item_to_use.duration.toFixed(2) / frameDuration);
            
            output('</sub_items>', MAIN_STEAM);
            
            output('<meta frameDuration="' + frameDuration 
                            + '" frameStart="' + animation_start_time
                            + '" totalFrames="' + totalFrames 
                            + '" duration="' + item_to_use.duration.toFixed(2)
                           
                            + '"/>', MAIN_STEAM);
            output('</after_affect_animation_doc>', MAIN_STEAM);    
              
            writeFile();
         
         }
        

      function exportLayers(composition, steam, item_to_use) {
           
            
          output('<composition w="' + composition.width + 
                                            '" h="' + composition.height + 
                                            '" id="' + composition.id + 
                                            '" >', steam);
          
            for(var l_num = 1; l_num <= composition.numLayers; l_num++) {
                
                  var layer = composition.layer(l_num);
                  if(!layer.enabled) {
                    continue;
                  }

                  
                  var parentName = "none";
                     
                  if(layer.parent != null) {
                      parentName = layer.parent.index;
                  }

              
                  var blending = string_of_enum(BlendingMode, layer.blendingMode)




                   if(layer.source instanceof FootageItem) {
                    
                     var layerSourceName = layer.source.name.replace(/^.*[\\\/]/, '');
                     var color = "";
                     var sourceType = "";

                      if(layer.source.mainSource instanceof SolidSource) {
                        sourceType = "SolidSource";
                       color = layer.source.mainSource.color.join(); 
                      }

                      if(layer.source.mainSource instanceof FileSource) {
                        sourceType = "FileSource";
                      }

                     
                      output('  <layer name="' + layer.name + 
                                             '" type="' + layer.source.typeName + 
                                             '" sourceType="' + sourceType + 
                                             '" parent="' +  parentName + 
                                             '" index="' + layer.index + 
                                             '" source="' + layerSourceName + 
                                             '" w="' + layer.width + 
                                             '" h="' + layer.height + 
                                             '" inPoint="' + layer.inPoint + 
                                             '" outPoint="' + layer.outPoint + 
                                             '" blending="' + blending + 
                                             '" color="' + color + 
                                             '">', steam);
                   } else if (layer.source instanceof CompItem) {
                
                        output('  <layer name="' + layer.name + 
                                             '" type="' + layer.source.typeName + 
                                             '" id="'     + layer.source.id + 
                                             '" parent="' +  parentName + 
                                             '" index="' + layer.index + 
                                             '" w="' + layer.width + 
                                             '" h="' + layer.height + 
                                             '" inPoint="' + layer.inPoint + 
                                             '" outPoint="' + layer.outPoint + 
                                             '" blending="' + blending + 
                                             '">', steam);

                          
                           
                          if(!contains(usedCompositionIds, layer.source.id)) {
                                usedCompositions.push(layer.source);
                                usedCompositionIds.push(layer.source.id);
                          }

                   } else {
                        alert("Object Type not supported: ");
                        continue;
                   }
               
               
              

               
                  var properties =  new Array();
                  properties[0] = layer.Transform["Position"];
                  properties[1] = layer.Transform["Scale"];
                  properties[2] = layer.Transform["Rotation"];
                  properties[3] = layer.Transform["Opacity"];
                  properties[4] = layer.Transform["Anchor Point"];
                  properties[5] = layer.comment
                  exportProperties(composition, properties, steam);
                  
                  exportExtra(layer);

               

                  output('  </layer>', steam);
           }
            makeJSONfile(json_info,item_to_use); 
          var numFrames = Math.floor(composition.duration.toFixed(2) / frameDuration);
          output('   <meta duration="' + composition.duration.toFixed(2)
                                    + '" totalFrames="' + numFrames 
                                    + '"/>', steam);
       
            output('</composition>', steam);
              
      }

        function exportProperties(composition,  properties, steam) {
        var numFrames = Math.floor(composition.duration.toFixed(2) / frameDuration);
        var i = 0;
        var l = numFrames;
        for (; i<l; ++i) {
               //time print disabled
          var time = i * frameDuration;

          output('            <keyframe frame="' + i + '">', steam);
          // build properties list
          var x = 0;
          var y = properties.length;
          var source = [];
          var sourceCount = 0;
          var currentContainer;
          for (; x<y; ++x) {
            if (properties[x].valueAtTime != undefined) {
              var parentName;
              if (properties[x].parentProperty != undefined) {
                parentName = properties[x].parentProperty.name;
              }
              else {
                parentName = "Undefined Property";
              }
              if (source[parentName] == undefined) {
                source[parentName] = {};
                source[parentName].name = properties[x].name;
                source[parentName].values = [];
              }
              source[parentName].values.push(properties[x]);
            }
          }
          // build xml
          for (var pn in source) {
            output('             <source name="' + pn + '">', steam);
            var x = 0;
            var y = source[pn].values.length;
            for (; x<y; ++x) {
              exportProperty(source[pn].values[x], time, steam)
            }
            output('            </source>', steam);
          }
          output('           </keyframe>', steam);
        }

      }
      

      function exportExtra(layer){
        var layer_comment = layer.comment;
        var layer_split_name = layer_comment.split(" ")
        if (layer_split_name.length == 2){
            var is_anchor = "True";
            };
        else{
            var is_anchor = "False"
          }
        var parallax_bucket = layer_split_name[0];
        var layer_name = layer.name
        var layer_index = layer.index
        if (layer.height > 0){
          var sound = "False"
        }
        if (layer.height == 0){
          var sound = "True"
        }

        json_info.push( {
          layerName:layer_name,
          layerIndex:layer_index,
          anchor:is_anchor,
          parallaxBucket:parallax_bucket,
          isSound:sound
        });
    };

        function makeJSONfile(json_info,item_to_use){
        
        json_file_name = item_to_use.name + '.json';
        var Json_File = new File(Folder.desktop.absoluteURI + "/" + json_file_name);
        if (Json_File.open("w")){
          Json_File.encoding = "UTF-8";
            Json_File.write(JSON.stringify(json_info,null,'\t'));
            };
          Json_File.close();
        };


        function exportProperty(prop, time, steam) {
        var val = prop.valueAtTime(time, true);
        if (val.length > 1) {
          exportMultiValue(prop, val, steam);
        }
        else {
          exportSingleValue(prop, val, steam);
        }
      }

      function exportSingleValue(prop, val, steam) {
        output('      <property name="' + prop.name + '" val="' + val + '"/>', steam);
      }
      
      function exportMultiValue(prop, val,  steam) {
        var str = '     <property name="' + prop.name + '"';
        
        var i = 0;
        var l = val.length;
        for (; i<l; ++i) {
                 var name;
                switch (i) {
                    case 0:
                        name = "x";
                        break;
                    case 1:
                        name = "y";
                        break;
                    case 2:
                        name = "z";
                        break;
                }
                str += '  ' +name + '="' + val[i] + '"';
        }
        
        str += '/>';
        output(str, steam);
      }
      
      function outputObject(obj) {
        var out = "";
        for (var s in obj) {
          out += s + "\n";
        }
        alert(out);
      }
     
        function output(value, steam) {
            if(steam == MAIN_STEAM) {
                outputString += value + "\r";
            } else {
                 subSteam += value + "\r";
            }
      }
      
      function writeFile() {
        output('</composition>');
        var file = new File(Folder.desktop.absoluteURI + "/" + fileName);
        file.open("w","TEXT","????");
        file.write(outputString);
        file.close();
      }

        function string_of_enum(en,  value)  {
            for (var k in en) {
                if (en[k] == value) {
                    return k;
                }
            } 
            return null;
        }

        function contains(a, obj) {
            var i = a.length;
            while (i--) {
               if (a[i] === obj) {
                   return true;
               }
            }
            return false;
        }
};