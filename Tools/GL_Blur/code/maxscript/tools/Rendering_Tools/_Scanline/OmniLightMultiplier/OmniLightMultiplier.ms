--	\Title 		Omni Light Multiplier
--	
--	\Description	Les augmentations et les diminutions lumières multiplicateurs sur les lumières omnidirectionnelles standard.
--	\Description	
--	\Description	Increases and decreases lights multiplier on standard omni lights.
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 7/7/2012
(
	try (DestroyDialog dlg_omni_II )catch
	rollout dlg_omni_II "Standard Light Reducer"
	(
		spinner spn_Value "By % :: " range:[1,1000,50] type:#integer
		button btn_IncreasL "Increase" across:2
		button btn_DecreaseL "Decrease"
		
		on btn_IncreasL pressed do
		(
			print "Test"
			oMult =  (spn_Value.value + .01)
			print (oMult)
			undo on
			(
				for i in selection where hasProperty i "Multiplier" do i.Multiplier = ( (oMult*i.Multiplier/100) +  i.Multiplier )
			)
		)
		
		on btn_DecreaseL pressed do
		(
			local oMult =  (spn_Value.value * .01)
			undo on
			(
				for i in selection where hasProperty i "Multiplier" do i.Multiplier = i.Multiplier * oMult
			)
		)
		
	)
	createDialog dlg_omni_II 150 60
)