	oSel = selection as array 
	for zz in oSel do
	(

		vari = (getTransformLockFlags zz) as array

		if vari.count > 0 then
		(
			setTransformLockFlags zz #none
		)
		else
		(
			setTransformLockFlags zz #all
		)
	)