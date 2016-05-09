// Takes the first comment and copies it down the line.


var mySelectedItems = [];
for (var i = 1; i <= app.project.numItems; i++){
  if (app.project.item(i).selected)
    for (var j= 1; j<=app.project.item(i).numLayers; j++){
        if (app.project.item(i).layer(j).selected)
        mySelectedItems[mySelectedItems.length] = app.project.item(i).layer(j);
        }
}
var comment = mySelectedItems[0].comment

for (var i = 1; i < mySelectedItems.length; i++){
  var mySelection = mySelectedItems[i];
  mySelection.comment = comment
  
  
}