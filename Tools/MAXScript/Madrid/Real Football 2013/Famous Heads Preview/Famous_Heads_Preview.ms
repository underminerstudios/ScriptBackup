/*
	RF2013 Famous Heads Preview
	
	This tool allows you to preview and take screenshots of the famous heads for RF2013.
	The data is retrieved from the following CVS file:
	W:\sources\3D\players\Famous_Heads_values.csv
	and the script will only work with the following max file:
	W:\sources\3D\players\RF13_Famous_Heads_Preview.max
	
*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog rf_13_famous_heads_preview)catch()
THE_FILE = pathconfig.normalizepath (maxfilepath + "\\" + maxfilename)
if THE_FILE != "W:\\sources\\3D\\players\\RF13_Famous_Heads_Preview.max" do
(
	messagebox "You need to open the following file for this script to work: W:\sources\3D\players\RF13_Famous_Heads_Preview.max"
)

rollout rf_13_famous_heads_preview "Famous Heads"
(
	dropdownlist ddl_heads "Heads:"
	checkbox cb_screenshots "Save Screenshot"
	local THE_FILE = maxfilepath + "\\Famous_Heads_values.csv"
	local THE_ARRAY = (dotnetClass "System.IO.File").ReadAllLines THE_FILE (dotNetClass "System.Text.Encoding").Default
	
	on rf_13_famous_heads_preview open do
	(
		local heads_array = #()
		for i=4 to THE_ARRAY.count do
		(
			if THE_ARRAY[i]!= "" do
			(
				append heads_array (trimright(substitutestring ((filterstring THE_ARRAY[i] ",")[1]) "\"" ""))
			)
		)
		ddl_heads.items = heads_array
		ATSOps.Visible = true
		ATSOps.Visible = false
	)
	
	on ddl_heads selected arg do
	(
		local THE_LINE = filterstring THE_ARRAY[arg + 3] ","
		local THE_HEAD = $head_standard0
		local THE_MORPHER = $head_standard0.morpher
		
		for i=1 to 18 do
		(
			WM3_MC_SetValue THE_MORPHER i (THE_LINE[i+1] as float)
		)
		
		local layer = LayerManager.getLayerFromName "hairs"
		local theNodes
		layer.nodes &theNodes
		for n in theNodes do
		(
			hide n
			if matchpattern n.name pattern:(execute THE_LINE[20]) do
			(
				unhide n
				local THE_MATERIAL = meditmaterials[2]
				THE_MATERIAL.diffuseMap.filename = "W:\\sources\\3D\\players\\textures\\database\\hair\\" + n.name + ".tga"
				THE_MATERIAL.opacityMap.filename = "W:\\sources\\3D\\players\\textures\\database\\hair\\" + n.name + ".tga"
			)
		)
		
		atsops.refresh()
		atsops.silent = true
		local fileList
				
		-- Get all files 
		atsops.GetFiles &fileList

		for n in fileList do
		(
			if matchpattern n pattern:"W:\\sources\\3D\\players\\textures\\database\\head\\players\\*" do
			(
				atsops.selectfiles #(n)
				atsops.RetargetSelection ("W:\\sources\\3D\\players\\textures\\database\\head\\players\\" + trimright(execute(THE_LINE[1])) + ".tga")
			)
		)
		
		atsops.refresh()
		
		if cb_screenshots.state == true do
		(
			local grab_bmp = gw.getViewportDib()
			local the_bmp = maxfilepath + "\\" + trimright(execute(THE_LINE[1])) + ".tga"
			deleteFile the_bmp
			grab_bmp.filename = the_bmp
			save grab_bmp
		)
	)
)


createDialog rf_13_famous_heads_preview
