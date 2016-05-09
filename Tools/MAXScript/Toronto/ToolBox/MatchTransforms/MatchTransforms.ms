	(
	Clearlistener ()
	GC ()
	rollout MatchObjectsRollout "Bake Objects Alignment"
	(
		Local animatedNode 
		button animatedObject_btn "Please Select animated Object"
		group "Bake Timeline"
		(
		Spinner TimeStart_spn "start:" align: #left across: 2 range:[-32000,32000,0] type:#Integer
		Spinner TimeEnd_spn "end:" range:[-32000,32000,1] type:#Integer
		)
		button Start_btn "Start"
		
		on animatedObject_btn pressed do
		(
			if ( selection.count == 1 ) then 
			(
				animatedObject_btn.text = selection[1].name
				animatedNode = selection[1]
			)
			else
			(
				MessageBox "Please only select 1 object to match other obejcts to"
			)
		)
		
		on Start_btn pressed do
		(
			undo on
			(
				if (TimeStart_spn.value > TimeEnd_spn.value ) then 
				(
					MessageBox "Your Start frame is greater then your end Frame."
				)
				else
				(
					if (animatedNode  != undefined) and (isvalidnode animatedNode ) then
					(				
						if Selection.count > 0 then
						(
							try
							(
								with animate on 
								( 
									Sel = Selection as array
									for obj in Sel do 
									(
										--All other Keys
										for i = TimeStart_spn.value to (TimeEnd_spn.value) do 
										(
											SliderTime  =i as time
											obj.transform = animatedNode.transform
										)
									)
								)
								MessageBox "Animations Baked"
							)
							catch ()
						)
						else
						(
							MessageBox "please Select objects to match to: " + animatedObject_btn.text
						)
					)
					else
					(
						MessageBox "please Select a valid object to match to. "
					)
				)
			)				
		)
	)
	createDialog MatchObjectsRollout
)