-- Displays a list of Material names that have duplicate Material ID's assigned to them in the material editor.
(
	lists = #()
	noIDSet = #()
	for i = 1 to sceneMaterials.count do
	(
		effectId = sceneMaterials[i].effectsChannel
		if effectId > 0 then
		(
			if lists[effectId] == undefined then
			(
				lists[effectId] = #()
			)
			append lists[effectId] sceneMaterials[i]
		) 
		else
		(
			append noIDSet sceneMaterials[i]
		)
	)
	
	
	if lists.count > 0 then
	(
		message = "The following materials share Material ID's:\n"
		for i = 1 to lists.count do
		(
			if lists[i] != undefined then
			(
				tmp = lists[i]
				if tmp.count > 1 then
				(
					message = message + "\nMat ID: " + i as string + "  -  "
					for j = 1 to tmp.count do
					(
						message = message + tmp[j].name
						if j < tmp.count then
						(
							message = message + ", "
						)
					)
				)
			)
			
			
		)
		
		if noIDSet.count > 0 then
		(
			message = message + "\n\nThe following materials don't have a material ID set.\n"
			for i = 1 to noIDSet.count do
			(
				message = message + " " + noIDSet[i].name
				if i < noIDSet.count then
				(
					message = message + ", "
				)
			)
		)
		messageBox message
	)
	""
)
