try(destroydialog DLG_edittext)catch()
rollout DLG_edittext "Tutorials and Guides"
(
	local theDepotPath = getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path"
	local bmpImageFile = (theDepotPath +"\\MAXScript\\Barcelona\\Tutorials\\Tutorial Index\\infoHelp.bmp" as string)
	local bmpImage = openBitmap bmpImageFile
	
	group "IMPORTANT:"
	(
		bitmap bm_info "Info" tooltip:"lalala" bitmap:bmpImage
		label lb_note "To see the tutorials you should click the Info button."
	)
	
	group "Add tutorial:"
	(	
		dropdownlist dd_tutorialType "Tutorial topic" items:#("", "Modelling", "Texturing", "Other", "Utilities")
		label lb_note1 "Tutorial URL: ---> (http://www.google.com)" align:#left
		edittext et_url "" text:"" fieldWidth:290 align:#center offset:[-2,0]
		label lb_note2 "Link description:" align:#left
		edittext et_desc "" text:"" fieldWidth:290 align:#center offset:[-2,0]
		button bt_addLink "Add tutorial link" width:100
	)
	on bt_addLink pressed do
	(
		if et_url.text!="" and et_desc.text!="" and dd_tutorialType.selected != "" then
		(
			--theFile = (theDepotPath +"\\MAXScript\\Barcelona\\Tutorials\\Tutorial Index\\ReadMe.html" as string)
			theFile = ("\\\\barmaxr01\\GML_Launcher\\ReadMe.html")
			theFile = pathconfig.normalizepath theFile
			htmlFileArray =#()
			htmlFileArray = (dotNetClass "System.IO.File").ReadAllLines theFile
		
			newTextFileArray = #()
			ind = 0
			
			for i in htmlFileArray do
			(
				if i == "<!--Modelling-->" and dd_tutorialType.selected == "Modelling" then
				(
					--añadimos la linea normal
					ind = ind+1
					newTextFileArray[ind] = i
					
					--preparamos la nueva liena
					linkURL = et_url.text
					linkDescription = et_desc.text
					htmlString = ("<a href=\""+linkURL+"\" target=\"_blank\">"+linkDescription+"</a><br>" as string)
					
					--añadimos la nueva linea
					ind = ind+1
					newTextFileArray[ind] = htmlString
					
					et_url.text = ""
					et_desc.text = ""
					
					messageBox("INFO: The link was succesfully added.")
				)
				else if i == "<!--Texturing-->" and dd_tutorialType.selected == "Texturing"  then
				(
					--añadimos la linea normal
					ind = ind+1
					newTextFileArray[ind] = i
					
					--preparamos la nueva liena
					linkURL = et_url.text
					linkDescription = et_desc.text
					htmlString = ("<a href=\""+linkURL+"\" target=\"_blank\">"+linkDescription+"</a><br>" as string)
					
					--añadimos la nueva linea
					ind = ind+1
					newTextFileArray[ind] = htmlString
					
					et_url.text = ""
					et_desc.text = ""
					
					messageBox("INFO: The link was succesfully added.")
				)
				else if i == "<!--Other-->" and dd_tutorialType.selected == "Other"  then
				(
					--añadimos la linea normal
					ind = ind+1
					newTextFileArray[ind] = i
					
					--preparamos la nueva liena
					linkURL = et_url.text
					linkDescription = et_desc.text
					htmlString = ("<a href=\""+linkURL+"\" target=\"_blank\">"+linkDescription+"</a><br>" as string)
					
					--añadimos la nueva linea
					ind = ind+1
					newTextFileArray[ind] = htmlString
					
					et_url.text = ""
					et_desc.text = ""
					
					messageBox("INFO: The link was succesfully added.")
				)
				else if i == "<!--Utils-->" and dd_tutorialType.selected == "Utilities"  then
				(
					--añadimos la linea normal
					ind = ind+1
					newTextFileArray[ind] = i
					
					--preparamos la nueva liena
					linkURL = et_url.text
					linkDescription = et_desc.text
					htmlString = ("<a href=\""+linkURL+"\" target=\"_blank\">"+linkDescription+"</a><br>" as string)
					
					--añadimos la nueva linea
					ind = ind+1
					newTextFileArray[ind] = htmlString
					
					et_url.text = ""
					et_desc.text = ""
					
					messageBox("INFO: The link was succesfully added.")
				)else	(
					--añadimos la linea normal
					ind = ind+1
					newTextFileArray[ind] = i
				)
			)
			
			--theFile = (dotNetClass "System.IO.File").AppendAllLines newTextFileArray
			(dotNetClass "System.IO.File").WriteAllLines theFile newTextFileArray 
		)
	)
)
createDialog DLG_edittext width:320