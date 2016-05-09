(
--fn align_uv_edge_to_axis =(
	print("align uv shell to axis");
	undo on(
		local uv = modPanel.getCurrentObject();
		--local objs = modPanel.getCurrentObject();
		if classof (uv) == Unwrap_UVW then(
			local _mode = uv.unwrap2.getTVSubObjectMode();
			if (_mode == 2)then
			(
					local _array = uv.unwrap2.getSelectedEdges();
					for zz in _array do
					(
						print zz
						_edge = zz
						(--only 1 edge selected!!!
						--calculate the angle difference between 2 deltas
						function get2VertsAngleDiff dx dy= 
						(
							local _a_abs = mod ((atan2 dy dx)+4*360) 360;--the angle in closed 360 degrees
							local _a_off = (mod _a_abs 90);--angle offset
							if (_a_off > 45)then
							(
								_a_off = -(90 - _a_off);
							)
							return _a_off;
						)
						
						local _edge = zz as integer--(_array as array)[1] as integer;
						uv.unwrap2.selectEdges #{zz};
						--$.modifiers[#unwrap_uvw].unwrap.selectEdges #{658}
						
						--get the transformation info
						uv.unwrap2.edgeToVertSelect();
						_points = uv.unwrap.getSelectedVertices() as array;
						local ptA = uv.getVertexPosition 1 _points[1];
						local ptB = uv.getVertexPosition 1 _points[2];
						local dx = ptB.x - ptA.x;
						local dy = ptB.y - ptA.y;
						
						local a_off = get2VertsAngleDiff dx dy;
	
						uv.unwrap2.selectElement();
						uv.unwrap2.RotateSelected (-a_off  * PI/180) [(ptA.x + dx/2),(ptA.y + dy/2),0]
						uv.unwrap2.selectEdges #{_edge};
	
						local ptA = uv.getVertexPosition 1 _points[1];
						local ptB = uv.getVertexPosition 1 _points[2];
						local dx = ptB.x - ptA.x;
						local dy = ptB.y - ptA.y;
						local a_off = get2VertsAngleDiff dx dy;
						
						if (a_off != 0)then
						(
							--stupid angle snap is on
							print("shut off the angle snap..");
							max angle snap toggle ;--shut it up
							uv.unwrap2.selectElement();
							uv.unwrap2.RotateSelected (-a_off  * PI/180) [(ptA.x + dx/2),(ptA.y + dy/2),0]
							uv.unwrap2.selectEdges #{_edge};
						)
					)
				)
				if (_array.numberSet == 0)then
				(
					print ("Select at least one edge")
				)
			)
		)
	)
)