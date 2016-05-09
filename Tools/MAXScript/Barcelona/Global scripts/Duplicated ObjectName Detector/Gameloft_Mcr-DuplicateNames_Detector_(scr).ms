	rollout main "Find duplicate object names:" width:320
	(
		group "Process:"
		(
			button detectar_bt "Find" enabled:true width:100
		)
		
		group "Progress:"
		(
			label text_lb "" align:#left
			progressBar prog "Progress:"
		)
		
		label author_lb "Created by: Marc Martí (Gameloft - 2010)" enabled:false
		
		on detectar_bt pressed do
		(
			--creamos el fichero
	  		nomFitxer = "C:\\svn\GameloftScript_duplicatedNames.txt"
			out_file = createfile nomFitxer
			format "Duplicated Names: \n" to:out_file
			
			--
			--dupliquem l'array d'objectes
			--
			
			objPerMirar = #()
			objectestotals = objects.count
						
			for o in objects do
			(
				objPerMirar = append objPerMirar o 
			)
			
			objectesDupli = false
			
			--for i = objPerMirar.count to 1 by -1 do
			while objPerMirar.count > 1 do
			(
				obj = objPerMirar[objPerMirar.count]
				indicesDeIguales = #()
								
				prog.color = green
				--calcul barra
				resto = objectestotals - objPerMirar.count
				index = objectestotals - resto
				
				prog.value = 100.*index/objectestotals
				
				
				if(obj == undefined)then
				(
					messageBox("EXIT")
					exit
				)
				
				for j=1 to (objPerMirar.count-1)do
				(
					
					objCompara = objPerMirar[j]
					
					text_lb.caption = obj.name+" & "+objCompara.name as string
					
					if(obj.name == objCompara.name)then
					(
						objectesDupli = true
						format "- %" obj.name to:out_file
						indicesDeIguales = append indicesDeIguales j
					)
					
				)
				if(indicesDeIguales.count > 0) then
				(
					--marquem el que hem agafat com a motiu de comparació..
					objPerMirar[objPerMirar.count] = 0
					--i els seus iguals	
					for n=1 to indicesDeIguales.count do
					(
						indice = indicesDeIguales[n]
						objPerMirar[indice] = 0
					)
									
				)else(
					--marquem el que hem agafat com a motiu de comparació
					objPerMirar[objPerMirar.count] = 0
				)
				for o=objPerMirar.count to 1 by -1 do
				(
					if(objPerMirar[o]==0)then
					(
						--eliminem
						deleteItem objPerMirar o
					)
				)
			)
			
			if(objectesDupli==false)then
			(
				messageBox( "There are NO objects with duplicated names.")
			)
			
			text_lb.caption = ""
			prog.value = 0
			
			close out_file
			
			if(objectesDupli!=false)then
			(
				edit nomFitxer
			)
			
		)
	)
	createdialog main
