/*
Gameloft Live XML Edit
This script will allow the artist to change the values in the Gameloft Live's XML easily.
The script will attempt to find the XML in the proper folder. If it's not found the user will be prompted for a XML file.
*/
-- by Norman Schaar - norman.schaar@gameloft.com



--kill or launch a dialog
fn KillAndLaunchDialog theRollout kill launch=
(
	if kill do try (	DestroyDialog theRollout; ) catch();
	if launch do createDialog theRollout	
)

--Write to XML function
fn write_to_XML theXML =
(
	--Load the xml assemply
	dotNet.loadAssembly "system.xml"
	--Create an xml document object.
	xmlDoc=dotNetObject "system.xml.xmlDocument"
		
	--Load the XML file.
	xmlDoc.load theXML
	--Check to make sure the xmlDoc has a root element. 
	docEle=xmlDoc.documentElement
	itemIter = (xmldoc.selectnodes "//environment/AvatarSlot")

	--First AvatarSlot
	FirstAvatarSlot = itemIter.itemOf[0]

	--The children
	AvatarSlotChildNodes = FirstAvatarSlot.ChildNodes
	--Here we loop through the children
	for i=0 to AvatarSlotChildNodes.count-1 do
	(
		--The Avatar Ambient Child
		if (AvatarSlotChildNodes.ItemOf[i]).name == "AvatarAmbient" do
		(
			-- Get the Fog Attributes
			AvatarSlotAvatarAmbient= (AvatarSlotChildNodes.ItemOf[i]).attributes
			--The Fog Attribute items
			for j=0 to AvatarSlotAvatarAmbient.count-1 do
			(
				if (AvatarSlotAvatarAmbient.itemOf[j]).name == "r" do
				(
					(AvatarSlotAvatarAmbient.itemOf[j]).InnerText = (GLL_XML_edit.cp_av_amb.color.r as integer) as string
				)
				if (AvatarSlotAvatarAmbient.itemOf[j]).name == "g" do
				(
					(AvatarSlotAvatarAmbient.itemOf[j]).InnerText = (GLL_XML_edit.cp_av_amb.color.g as integer) as string
				)
				if (AvatarSlotAvatarAmbient.itemOf[j]).name == "b" do
				(
					(AvatarSlotAvatarAmbient.itemOf[j]).InnerText = (GLL_XML_edit.cp_av_amb.color.b as integer) as string
				)
			)
		)
		--The Fog Child
		if (AvatarSlotChildNodes.ItemOf[i]).name == "Fog" do
		(
			-- Get the Fog Attributes
			AvatarSlotFog= (AvatarSlotChildNodes.ItemOf[i]).attributes
			--The Fog Attribute items
			for j=0 to AvatarSlotFog.count-1 do
			(
				if (AvatarSlotFog.itemOf[j]).name == "a" do
				(
					(AvatarSlotFog.itemOf[j]).InnerText = (GLL_XML_edit.cp_fog.color.a as integer) as string
				)
				if (AvatarSlotFog.itemOf[j]).name == "r" do
				(
					(AvatarSlotFog.itemOf[j]).InnerText = (GLL_XML_edit.cp_fog.color.r as integer) as string
				)
				if (AvatarSlotFog.itemOf[j]).name == "g" do
				(
					(AvatarSlotFog.itemOf[j]).InnerText = (GLL_XML_edit.cp_fog.color.g as integer) as string
				)
				if (AvatarSlotFog.itemOf[j]).name == "b" do
				(
					(AvatarSlotFog.itemOf[j]).InnerText = (GLL_XML_edit.cp_fog.color.b as integer) as string
				)
			)
		)
		--The Lumminance Child
		if (AvatarSlotChildNodes.ItemOf[i]).name == "Luminance" do
		(
			-- Get the Luminance Attributes
			AvatarSlotLuminance= (AvatarSlotChildNodes.ItemOf[i]).attributes
			--The Luminance Attribute items
			for j=0 to AvatarSlotLuminance.count-1 do
			(
				if (AvatarSlotLuminance.itemOf[j]).name == "r" do
				(
					(AvatarSlotLuminance.itemOf[j]).InnerText = GLL_XML_edit.edtxt_lum_r.text
				)
				if (AvatarSlotLuminance.itemOf[j]).name == "g" do
				(
					(AvatarSlotLuminance.itemOf[j]).InnerText = GLL_XML_edit.edtxt_lum_g.text
				)
				if (AvatarSlotLuminance.itemOf[j]).name == "b" do
				(
					(AvatarSlotLuminance.itemOf[j]).InnerText = GLL_XML_edit.edtxt_lum_b.text
				)
			)
		)
		--The Gamma Child
		if (AvatarSlotChildNodes.ItemOf[i]).name == "Gamma" do
		(
			-- Get the Gamma Attributes
			AvatarSlotGamma= (AvatarSlotChildNodes.ItemOf[i]).attributes
			--The Gamma Attribute items
			for j=0 to AvatarSlotGamma.count-1 do
			(
				if (AvatarSlotGamma.itemOf[j]).name == "r" do
				(
					(AvatarSlotGamma.itemOf[j]).InnerText = GLL_XML_edit.edtxt_gamma_r.text
				)
				if (AvatarSlotGamma.itemOf[j]).name == "g" do
				(
					(AvatarSlotGamma.itemOf[j]).InnerText = GLL_XML_edit.edtxt_gamma_g.text
				)
				if (AvatarSlotGamma.itemOf[j]).name == "b" do
				(
					(AvatarSlotGamma.itemOf[j]).InnerText = GLL_XML_edit.edtxt_gamma_b.text
				)
			)
		)
	)
	xmlDoc.save theXML
)


KillAndLaunchDialog GLL_XML_edit true false

rollout GLL_XML_edit "Gameloft Live XML Edit" width:200 height:450
(
	colorpicker cp_av_amb "Avatar Ambient RGB:" color:[255,255,255] modal:true align:#right
	colorpicker cp_fog "Fog ARGB:" color:[255,255,255,0] modal:true alpha:true align:#right
	
	--Lumminace
	label lbl_lum_r "Lumminace R:" pos:[8,64]
	slider sl_lum_r ticks:0 range:[0,2,1] pos:[8,80] width:192
	edittext edtxt_lum_r pos:[135,64] width:50 text:"1"
	
	
	label lbl_lum_g "Lumminace G:" pos:[8,104]
	slider sl_lum_g ticks:0 range:[0,2,1] pos:[8,120] width:192
	edittext edtxt_lum_g pos:[135,104] width:50 text:"1"
	
	label lbl_lum_b "Lumminace B:" pos:[8,144]
	slider sl_lum_b ticks:0 range:[0,2,1] pos:[8,160] width:192
	edittext edtxt_lum_b pos:[135,144] width:50 text:"1"
	
	colorpicker cp_lum color:[0,0,0] modal:true enabled:false pos:[4,190] width:184
	
	--Gamma
	label lbl_gamma_r "Gamma R:" pos:[8,224]
	slider sl_gamma_r ticks:0 range:[-1,1,0] pos:[8,240] width:192
	edittext edtxt_gamma_r pos:[135,224] width:50 text:"0"
	
	label lbl_gamma_g "Gamma G:" pos:[8,264]
	slider sl_gamma_g ticks:0 range:[-1,1,0] pos:[8,280] width:192
	edittext edtxt_gamma_g pos:[135,264] width:50 text:"0"
	
	label lbl_gamma_b "Gamma B:" pos:[8,304]
	slider sl_gamma_b ticks:0 range:[-1,1,0] pos:[8,320] width:192
	edittext edtxt_gamma_b pos:[135,304] width:50 text:"0"
	
	colorpicker cp_gamma color:[0,0,0] modal:true enabled:false pos:[4,350] width:184
	
	label lbl_file_selected "No file selected!" align:#left pos:[8,380]
	
	button btn_save "Save" enabled:false width:184 height:40 pos:[8,401]

	
	--Luminance R
	on sl_lum_r changed arg do
	(
		edtxt_lum_r.text = (arg as string)
		--Load de LumCP
		cp_lum.color = color (arg*127.5) (sl_lum_g.value*127.5) (sl_lum_b.value*127.5)
	)
	
	on edtxt_lum_r changed arg do
	(
		if (arg as float) == undefined then
		(
			messagebox "value needs to be a number"
		)
		else
		(
			if (arg as float) > 2 do (edtxt_lum_r.text = "2")
			if (arg as float) < 0 do (edtxt_lum_r.text = "0")
			sl_lum_r.value = (edtxt_lum_r.text as float)
			--Load de LumCP
			cp_lum.color = color ((edtxt_lum_r.text as float)*127.5) (sl_lum_g.value*127.5) (sl_lum_b.value*127.5)
		)
	)
	
	--Lumminace G
	on sl_lum_g changed arg do
	(
		edtxt_lum_g.text = (arg as string) 
		--Load de LumCP
		cp_lum.color = color (sl_lum_r.value*127.5) (arg*127.5) (sl_lum_b.value*127.5)
	)
	
	on edtxt_lum_g changed arg do
	(
		if (arg as float) == undefined then
		(
			messagebox "value needs to be a number"
		)
		else
		(
			if (arg as float) > 2 do (edtxt_lum_g.text = "2")
			if (arg as float) < 0 do (edtxt_lum_g.text = "0")
			sl_lum_g.value = (edtxt_lum_g.text as float)
			--Load de LumCP
			cp_lum.color = color (sl_lum_r.value*127.5) ((edtxt_lum_g.text as float)*127.5) (sl_lum_b.value*127.5)
		)
	)
	
	--Lumminace B
	on sl_lum_b changed arg do
	(
		edtxt_lum_b.text = (arg as string) 
		--Load de LumCP
		cp_lum.color = color (sl_lum_r.value*127.5) (sl_lum_g.value*127.5) (arg*127.5)
	)
	
	on edtxt_lum_b changed arg do
	(
		if (arg as float) == undefined then
		(
			messagebox "value needs to be a number"
		)
		else
		(
			if (arg as float) > 2 do (edtxt_lum_b.text = "2")
			if (arg as float) < 0 do (edtxt_lum_b.text = "0")
			sl_lum_b.value = (edtxt_lum_b.text as float)
			--Load de LumCP
			cp_lum.color = color (sl_lum_r.value*127.5) (sl_lum_g.value*127.5) ((edtxt_lum_b.text as float)*127.5)
		)
	)
	
	
	--Gamma R
	on sl_gamma_r changed arg do
	(
		edtxt_gamma_r.text = (arg as string)
		--Load de Gamma CP
		cp_gamma.color = color ((arg+1)*127.5) ((sl_gamma_g.value+1)*127.5) ((sl_gamma_b.value+1)*127.5)
	)
	
	on edtxt_gamma_r changed arg do
	(
		if (arg as float) == undefined then
		(
			messagebox "value needs to be a number"
		)
		else
		(
			if (arg as float) > 1 do (edtxt_gamma_r.text = "1")
			if (arg as float) < -1 do (edtxt_gamma_r.text = "-1")
			sl_gamma_r.value = (edtxt_gamma_r.text as float)
			--Load de Gamma CP
			cp_gamma.color = color (((edtxt_gamma_r.text as float)+1)*127.5) ((sl_gamma_g.value+1)*127.5) ((sl_gamma_b.value+1)*127.5)
		)
	)
	
	--Gamma G
	on sl_gamma_g changed arg do
	(
		edtxt_gamma_g.text = (arg as string) 
		--Load de Gamma CP
		cp_gamma.color = color ((sl_gamma_r.value+1)*127.5) ((arg+1)*127.5) ((sl_gamma_b.value+1)*127.5)
	)
	
	on edtxt_gamma_g changed arg do
	(
		if (arg as float) == undefined then
		(
			messagebox "value needs to be a number"
		)
		else
		(
			if (arg as float) > 1 do (edtxt_gamma_g.text = "1")
			if (arg as float) < -1 do (edtxt_gamma_g.text = "-1")
			sl_gamma_g.value = (edtxt_gamma_g.text as float)
			--Load de Gamma CP
			cp_gamma.color = color ((sl_gamma_r.value+1)*127.5) (((edtxt_gamma_g.text as float)+1)*127.5) ((sl_gamma_b.value+1)*127.5)
		)
	)
	
	--Gamma B
	on sl_gamma_b changed arg do
	(
		edtxt_gamma_b.text = (arg as string)
		--Load de Gamma CP
		cp_gamma.color = color ((sl_gamma_r.value+1)*127.5) ((sl_gamma_g.value+1)*127.5) ((arg+1)*127.5)
	)
	
	on edtxt_gamma_b changed arg do
	(
		if (arg as float) == undefined then
		(
			messagebox "value needs to be a number"
		)
		else
		(
			if (arg as float) > 1 do (edtxt_gamma_b.text = "1")
			if (arg as float) < -1 do (edtxt_gamma_b.text = "-1")
			sl_gamma_b.value = (edtxt_gamma_b.text as float)
			--Load de Gamma CP
			cp_gamma.color = color ((sl_gamma_r.value+1)*127.5) ((sl_gamma_g.value+1)*127.5) (((edtxt_gamma_b.text as float)+1)*127.5)
		)
	)
	
	--On Open Dialog

	on GLL_XML_edit open do
	(
		--Read XML function
		fn read_XML theXML =
		(
			--Load the xml assemply
			dotNet.loadAssembly "system.xml"
			--Create an xml document object.
			xmlDoc=dotNetObject "system.xml.xmlDocument"
				
			--Load the XML file.
			xmlDoc.load theXML
			--Check to make sure the xmlDoc has a root element. 
			docEle=xmlDoc.documentElement
			itemIter = (xmldoc.selectnodes "//environment/AvatarSlot")
			--First AvatarSlot
			FirstAvatarSlot = itemIter.itemOf[0]
			--The children
			AvatarSlotChildNodes = FirstAvatarSlot.ChildNodes
			--Here we loop through the children
			for i=0 to AvatarSlotChildNodes.count-1 do
			(
				--The Avatar Ambient Child
				if (AvatarSlotChildNodes.ItemOf[i]).name == "AvatarAmbient" do
				(
					-- Get the Fog Attributes
					AvatarSlotAvatarAmbient= (AvatarSlotChildNodes.ItemOf[i]).attributes
					--The Fog Attribute items
					for j=0 to AvatarSlotAvatarAmbient.count-1 do
					(
						if (AvatarSlotAvatarAmbient.itemOf[j]).name == "r" do
						(
							GLL_XML_edit.cp_av_amb.color.r = (AvatarSlotAvatarAmbient.itemOf[j]).value as float
						)
						if (AvatarSlotAvatarAmbient.itemOf[j]).name == "g" do
						(
							GLL_XML_edit.cp_av_amb.color.g = (AvatarSlotAvatarAmbient.itemOf[j]).value as float
						)
						if (AvatarSlotAvatarAmbient.itemOf[j]).name == "b" do
						(
							GLL_XML_edit.cp_av_amb.color.b = (AvatarSlotAvatarAmbient.itemOf[j]).value as float
						)
					)
				)
				--The Fog Child
				if (AvatarSlotChildNodes.ItemOf[i]).name == "Fog" do
				(
					-- Get the Fog Attributes
					AvatarSlotFog= (AvatarSlotChildNodes.ItemOf[i]).attributes
					--The Fog Attribute items
					for j=0 to AvatarSlotFog.count-1 do
					(
						if (AvatarSlotFog.itemOf[j]).name == "a" do
						(
							GLL_XML_edit.cp_fog.color.a = (AvatarSlotFog.itemOf[j]).value as float
						)
						if (AvatarSlotFog.itemOf[j]).name == "r" do
						(
							GLL_XML_edit.cp_fog.color.r = (AvatarSlotFog.itemOf[j]).value as float
						)
						if (AvatarSlotFog.itemOf[j]).name == "g" do
						(
							GLL_XML_edit.cp_fog.color.g = (AvatarSlotFog.itemOf[j]).value as float
						)
						if (AvatarSlotFog.itemOf[j]).name == "b" do
						(
							GLL_XML_edit.cp_fog.color.b = (AvatarSlotFog.itemOf[j]).value as float
						)
					)
				)
				--The Lumminance Child
				if (AvatarSlotChildNodes.ItemOf[i]).name == "Luminance" do
				(
					-- Get the Luminance Attributes
					AvatarSlotLuminance= (AvatarSlotChildNodes.ItemOf[i]).attributes
					--The Luminance Attribute items
					for j=0 to AvatarSlotLuminance.count-1 do
					(
						if (AvatarSlotLuminance.itemOf[j]).name == "r" do
						(
							GLL_XML_edit.edtxt_lum_r.text = (AvatarSlotLuminance.itemOf[j]).value
							GLL_XML_edit.sl_lum_r.value = (AvatarSlotLuminance.itemOf[j]).value as float
						)
						if (AvatarSlotLuminance.itemOf[j]).name == "g" do
						(
							GLL_XML_edit.edtxt_lum_g.text = (AvatarSlotLuminance.itemOf[j]).value
							GLL_XML_edit.sl_lum_g.value = (AvatarSlotLuminance.itemOf[j]).value as float
						)
						if (AvatarSlotLuminance.itemOf[j]).name == "b" do
						(
							GLL_XML_edit.edtxt_lum_b.text = (AvatarSlotLuminance.itemOf[j]).value
							GLL_XML_edit.sl_lum_b.value = (AvatarSlotLuminance.itemOf[j]).value as float
						)
					)
				)
				--The Gamma Child
				if (AvatarSlotChildNodes.ItemOf[i]).name == "Gamma" do
				(
					-- Get the Gamma Attributes
					AvatarSlotGamma= (AvatarSlotChildNodes.ItemOf[i]).attributes
					--The Gamma Attribute items
					for j=0 to AvatarSlotGamma.count-1 do
					(
						if (AvatarSlotGamma.itemOf[j]).name == "r" do
						(
							GLL_XML_edit.edtxt_gamma_r.text = (AvatarSlotGamma.itemOf[j]).value
							GLL_XML_edit.sl_gamma_r.value = (AvatarSlotGamma.itemOf[j]).value as float
						)
						if (AvatarSlotGamma.itemOf[j]).name == "g" do
						(
							GLL_XML_edit.edtxt_gamma_g.text = (AvatarSlotGamma.itemOf[j]).value
							GLL_XML_edit.sl_gamma_g.value = (AvatarSlotGamma.itemOf[j]).value as float
						)
						if (AvatarSlotGamma.itemOf[j]).name == "b" do
						(
							GLL_XML_edit.edtxt_gamma_b.text = (AvatarSlotGamma.itemOf[j]).value
							GLL_XML_edit.sl_gamma_b.value = (AvatarSlotGamma.itemOf[j]).value as float
						)
					)
				)
			)
		)

		global GLL_theXML = undefined
		
		thePath = maxfilepath
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		thePath = pathConfig.removePathLeaf(thePath)
		theXML = thePath + "\\data\\3d\\" + getFileNameFile maxfileName + "\\" + getFileNameFile maxfileName + ".xml"
		
		if doesFileExist theXML then
		(
			global GLL_theXML = theXML
			lbl_file_selected.text = getFileNameFile theXML + getFileNameType theXML + " found!"
			btn_save.enabled = true
			read_XML theXML
		)
		else
		(
			--user has to select file
			theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
			theDialog.title = "Choose Gameloft Live XML file" --set the title
			theDialog.Multiselect = false --allow multiple files to be selected
			theDialog.Filter = "XML files (*.xml)|*.xml" --specify the filter
			theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
			result = theDialog.showDialog() --display the dialog, get result into variable
			test = result.ToString() --when closed, convert the result to string
			result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
			result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
			theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
			for f in theFilenames do
			(
				global GLL_theXML = f
				lbl_file_selected.text = getFileNameFile f + getFileNameType f
				read_XML f
				btn_save.enabled = true
			)
			
			if (result.Equals result.Cancel) == true do
			(
				KillAndLaunchDialog GLL_XML_edit true false
			)
		)

		--Load de LumCP
		cp_lum.color = color (sl_lum_r.value*127.5) (sl_lum_g.value*127.5) (sl_lum_b.value*127.5)
		--Load de Gamma CP
		cp_gamma.color = color ((sl_gamma_r.value+1)*127.5) ((sl_gamma_g.value+1)*127.5) ((sl_gamma_b.value+1)*127.5)
	)
	

	on btn_save pressed do
	(
		write_to_XML GLL_theXML
	)
)
createDialog GLL_XML_edit