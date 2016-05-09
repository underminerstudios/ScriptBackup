
var file_to_replace_folder = "K:/inbox/Art/6_textures"


for (var i = 1; i <= app.project.numItems; i++){
    try{
        var is_psd_split = app.project.item(i).name.split(".");     
        var is_psd = is_psd_split[is_psd_split.length-1];

        }
    catch (e){
        break;
        };
    if (is_psd == 'psd'){
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
            var full_folder_path = file_to_replace_folder + "/" + full_name[0]
            $.writeln(file_name)
            var replacement_file = full_folder_path + "/" + file_name
            app.project.item(i).replace(File(replacement_file));
            }
            catch(e){
                var boo = ""
            };
        }
    }
    