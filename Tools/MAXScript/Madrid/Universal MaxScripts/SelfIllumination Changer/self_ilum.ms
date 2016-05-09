try(destroyDialog DLG_SELFILLUM_CHANGE)catch()
rollout DLG_SELFILLUM_CHANGE "Change selfIllumAmount"
(
	spinner sp_selfilum "Self Illum:" range:[0,100,0] type:#integer
	button btn_apply "Apply" width:100
	
	on btn_apply pressed do
	(
		for n in selection do
		(
			local theMaterial = n.material

			if classof theMaterial == multimaterial do
			(
				for i=1 to theMaterial.materialList.count do
				(
					if (classof theMaterial.materialList[i]) == Standardmaterial do
					(
						theMaterial.materialList[i].selfIllumAmount = 100
					)
				)
			)
			
			if classof theMaterial == Standardmaterial do
			(
				NewMaterial.selfIllumAmount = 100
			)
		)
	)
	
)
createDialog DLG_SELFILLUM_CHANGE
