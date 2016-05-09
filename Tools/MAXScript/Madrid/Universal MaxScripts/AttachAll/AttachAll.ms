/*
	Cluster Attach Algorithm vy Tyson Ibele
	http://forums.cgsociety.org/showthread.php?t=922140
*/

fn clusterAttach objArr =
(
	j = 1
	local count = objArr.count

	undo off
	(
		while objArr.count > 1 do
		(				
			if classof objArr[j] != Editable_Poly then converttopoly objArr[j]
			
			polyop.attach objArr[j] objArr[j+1]
			deleteItem objArr (j+1)
			
			j += 1
			
			if (j + 1) > objArr.count then j = 1
		)
	)
	return objArr[1]
)

clusterAttach (for o in selection collect o)