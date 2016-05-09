
	Rollout unwrapAtlaser "unwrap Atlaser" 
	--definicio plugin
	(
		
		-- LOCAL VARIABLES  ini ------------------------------------------------------------------------------------------------
		local buttonDim = 100
		local buttonDimQuads = 22
		local atlasResArray = #(2048,1024,512,256)
		local varTop
		local varBottom
		local varLeft
		local varRight
		local varDimX
		local varDimY
		local varCenter
		-- LOCAL VARIABLES  end ------------------------------------------------------------------------------------------------
		
		
		-- FILTERS ini --------------------------------------------------------------------------------------------------------------
		-- FILTERS end --------------------------------------------------------------------------------------------------------------
		
		
		-- UI ini ---------------------------------------------------------------------------------------------------------------------
			--label lb_note "Base size is 1024x1024" enabled:false
			
			--dropdownlist dd_objects "Atlas Resolution:" items:#("2048 x 2048","1024 x 1024","512 x 512","256 x 256") selection:2 width:102 offset:[2,0]
			label AtlInfo_lb " Atlas information:" align:#left style_sunkenedge:true width:115 height:17 offset:[-5,0]
			
			spinner AtlasPiecesX_sp "Cells X:" range:[1,64,4] type:#integer align:#left
			spinner AtlasPiecesY_sp "Cells Y:" range:[1,64,4] type:#integer align:#left
			
			label empty1_lb "" align:#left
			
			label reposit_lb " Reposition:" align:#left style_sunkenedge:true width:115 height:17 offset:[-5,0]
			
			spinner PositionX_sp "Pos X:" range:[1,4,1] type:#integer align:#left
			spinner PositionY_sp "Pos Y:" range:[1,4,1] type:#integer align:#left
			
			button Reposition_bt "Reposition" width:110 align:#center
			
			label empty2_lb "" align:#left
			
			label Qrepos_lb " Quick 4x4 Repos.:" align:#left style_sunkenedge:true width:115 height:17 offset:[-5,0]
			
			button rep_1x1 "1-1" width:22 height:22 across:4  offset:[2,0] 
			button rep_2x1 "2-1" width:22 height:22 offset:[2,0]
			button rep_3x1 "3-1" width:22 height:22 offset:[2,0]
			button rep_4x1 "4-1" width:22 height:22 offset:[2,0]
			button rep_1x2 "1-2" width:22 height:22 across:4  offset:[2,0]
			button rep_2x2 "2-2" width:22 height:22 offset:[2,0]
			button rep_3x2 "3-2" width:22 height:22 offset:[2,0]
			button rep_4x2 "4-2" width:22 height:22 offset:[2,0]
			button rep_1x3 "1-3" width:22 height:22 across:4  offset:[2,0]
			button rep_2x3 "2-3" width:22 height:22 offset:[2,0]
			button rep_3x3 "3-3" width:22 height:22 offset:[2,0]
			button rep_4x3 "4-3" width:22 height:22 offset:[2,0]
			button rep_1x4 "1-4" width:22 height:22 across:4  offset:[2,0]
			button rep_2x4 "2-4" width:22 height:22 offset:[2,0]
			button rep_3x4 "3-4" width:22 height:22 offset:[2,0]
			button rep_4x4 "4-4" width:22 height:22 offset:[2,0]
			
			
			label author1_lb "Created by: M. Martí " enabled:false align:#center
			label author2_lb "(Gameloft - 2010 - v2.0)" enabled:false align:#center
		-- UI end ---------------------------------------------------------------------------------------------------------------------
		
		
		-- FUNCTIONS ini --------------------------------------------------------------------------------------------------------
		
		fn pixelToAbsolute _pxValue=
		(
			_atlasResolution = atlasResArray[dd_objects.selection]
			_absoluteValue = _pxValue/_atlasResolution
			return _absoluteValue
		)--end fn	
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		fn checkFaceModeSelected =
		(
			
			if(subobjectLevel == 3 or subobjectLevel == "3" )then
			(
				return true
			)else(
				messageBox("Please select some FACES first.")
				return false
			)
		)--end fn	
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn align_uv_edge_to_axis =
		(
			local obj = selection[1];
			if classof (modPanel.getCurrentObject()) == Unwrap_UVW then
			(
				local _mode = obj.modifiers[#unwrap_uvw].unwrap2.getTVSubObjectMode();
				if (_mode == 2)then
				(
					local _array = obj.modifiers[#unwrap_uvw].unwrap2.getSelectedEdges();
					
					if (_array.numberSet == 1)then(
						
						local _edge = (_array as array)[1] as integer;
						--get the transformation info
						obj.modifiers[#unwrap_uvw].unwrap2.edgeToVertSelect();
						_points = obj.modifiers[#unwrap_uvw].unwrap.getSelectedVertices() as array;
						local ptA = obj.modifiers[#unwrap_uvw].getVertexPosition 1 _points[1];
						local ptB = obj.modifiers[#unwrap_uvw].getVertexPosition 1 _points[2];
						
						local dx = ptB.x - ptA.x;
						local dy = ptB.y - ptA.y;
						
						local _a_abs = mod ((atan2 dy dx)+4*360) 360;--the angle in closed 360 degrees
						local _a_off = (mod _a_abs 90);--angle offset
						
						if (_a_off > 45)then
						(
							_a_off = -(90 - _a_off);
						)--end if
						
						obj.modifiers[#unwrap_uvw].unwrap2.selectElement();
						obj.modifiers[#unwrap_uvw].unwrap2.RotateSelected (-_a_off  * PI/180) [(ptA.x + dx/2),(ptA.y + dy/2),0]
						obj.modifiers[#unwrap_uvw].unwrap6.selectEdgesByNode #{_edge} $;
						
					)else(
						messageBox("select just 1 edge!");
					)-- end if
				)--end if
			)--end if
		)--end fn	
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn alignTo _uvBase _pos = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				_absoluteWidth = rV - lV
				_absoluteHeight = tV - bV
				
				_centerPivotPoint = _uvBase.getSelCenter()
				
				if(_pos == "TOP")then
				(
					_movingOffsetX = 0
					_movingOffsetY = 1-tV
				)else if(_pos == "BOTTOM")then
				(
					_movingOffsetX = 0
					_movingOffsetY = 0-bV
				)else if(_pos == "CENTER")then
				(
					_movingOffsetX = 0.5-_centerPivotPoint[1]
					_movingOffsetY = 0.5-_centerPivotPoint[2]
				)else if(_pos == "RIGHT")then
				(
					_movingOffsetX = 1-rV
					_movingOffsetY = 0
				)else if(_pos == "LEFT")then
				(
					_movingOffsetX = 0-lV
					_movingOffsetY = 0
				)else(
					_movingOffsetX = _pos.x
					_movingOffsetY = _pos.y
				)
				
				_uvBase.unwrap2.MoveSelected [_movingOffsetX,_movingOffsetY,0]
				
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn posToAreaGetted _uvBase = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				_centerPivotPoint = _uvBase.getSelCenter()
				
				
				_movingOffsetX = varLeft - lV
				_movingOffsetY = varBottom - bV
				
				--_movingOffsetX = bV-varBottom
				--_movingOffsetY = lV-varLeft
								
				--if(_pos == "CENTER")then
				--(
				--	_movingOffsetX = 0.5-_centerPivotPoint[1]
			--		_movingOffsetY = 0.5-_centerPivotPoint[2]
				--)
				
				_uvBase.unwrap2.MoveSelected [_movingOffsetX,_movingOffsetY,0]
				
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn regularScaleFaceShellBy _uvBase _numRatio _regular = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_objMesh = $
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				_absoluteWidth = rV - lV
				_absoluteHeight = tV - bV
				
				_centerPivotPoint = _uvBase.getSelCenter()
				
				_atlasResolution = 256 -- <-- 
				
				_actualPixelWidth = _absoluteWidth *  _atlasResolution
				_actualPixelHeight = _absoluteHeight * _atlasResolution
				
				_scaleTransformWidth = _numRatio/_actualPixelWidth
				_scaleTransformHeight = _numRatio/_actualPixelHeight
				
				if (_regular == true)then
				(
					if(_scaleTransformWidth<_scaleTransformHeight) then
					(
						_globalScaleFactor = _scaleTransformWidth
					)else(
						_globalScaleFactor = _scaleTransformHeight
					)
					_uvBase.unwrap2.ScaleSelectedXY _globalScaleFactor _globalScaleFactor _centerPivotPoint
				)else(
					_uvBase.unwrap2.ScaleSelectedXY _scaleTransformWidth _scaleTransformHeight _centerPivotPoint
				)
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
				
		fn irregularScaleFaceShellBy _uvBase _numRatioX _numRatioY = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_objMesh = $
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				_absoluteWidth = rV - lV
				_absoluteHeight = tV - bV
				
				_centerPivotPoint = _uvBase.getSelCenter()
				
				_atlasResolution = atlasResArray[dd_objects.selection]
				
				_actualPixelWidth = _absoluteWidth *  _atlasResolution
				_actualPixelHeight = _absoluteHeight * _atlasResolution
				
				_scaleTransformWidth = _numRatioX/_actualPixelWidth
				_scaleTransformHeight = _numRatioY/_actualPixelHeight
				
				_uvBase.unwrap2.ScaleSelectedXY _scaleTransformWidth _scaleTransformHeight _centerPivotPoint
				
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		fn getArea _uvBase = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_objMesh = $
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						varTop = _currentVertex[2]
						varLeft = _currentVertex[1]
						varBottom = _currentVertex[2]
						varRight = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > varTop)then
						(
							varTop = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < varLeft)then
						(
							varLeft = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < varBottom)then
						(
							varBottom = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > varRight)then
						(
							varRight = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				varDimX = varRight - varLeft
				varDimY = varTop - varBottom
				
				varCenter = _uvBase.getSelCenter()
				
				--_atlasResolution = atlasResArray[dd_objects.selection]
				
				--_actualPixelWidth = _absoluteWidth *  _atlasResolution
				--_actualPixelHeight = _absoluteHeight * _atlasResolution
				
				--_scaleTransformWidth = _numRatio/_actualPixelWidth
				--_scaleTransformHeight = _numRatio/_actualPixelHeight

				--_uvBase.unwrap2.ScaleSelectedXY _scaleTransformWidth _scaleTransformHeight _centerPivotPoint

			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn setArea _uvBase = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_objMesh = $
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				if(varDimX != undefined and varDimY != undefined)then
				(
					--escalem segons les dimensions en pixels capturades al previameny
					_atlasResolution = atlasResArray[dd_objects.selection]
					varDimPixelX =  varDimX *  _atlasResolution
					varDimPixelY =  varDimY *  _atlasResolution
					irregularScaleFaceShellBy _uvBase varDimPixelX varDimPixelY
					
					--posicionem
					posToAreaGetted _uvBase
					
				)else(
					messageBox ("ERROR: No area 'getted' to set")
				)
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn percentScaleFaceShellBy _uvBase _numRatio = 
		(
			--TODO
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				_absoluteWidth = rV - lV
				_absoluteHeight = tV - bV
				
				--_centerPivotPoint = _uvBase.getSelCenter()
				_centerPivotPoint = point3 0 0 0 
				_percent = _numRatio*0.01
				_uvBase.unwrap2.ScaleSelectedXY _percent _percent _centerPivotPoint
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn percentIrregScaleFaceShellBy _uvBase _numRatioX _numRatioY = 
		(
			--TODO
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				_absoluteWidth = rV - lV
				_absoluteHeight = tV - bV
				
				--_centerPivotPoint = _uvBase.getSelCenter()
				_centerPivotPoint = point3 0 0 0
				_percentX = _numRatioX*0.01
				_percentY = _numRatioY*0.01
				_uvBase.unwrap2.ScaleSelectedXY _percentX _percentY _centerPivotPoint
			)--end if
		)--end fn
		
		-- = = = = = = = = = = = = = = = = = = = = = = = =
		
		fn scaleByThreshold _uvBase = 
		(
			--pasamos las caras a vertices:
			_uvBase.faceToVertSelect()
			_array = _uvBase.getSelectedVertices()
			
			if(_array.count > 2) then
			(				
				contador = 0
				tV
				lV
				bV
				rV
				
				for i in _array do
				(
					contador = contador + 1
					_currentVertex = _uvBase.getVertexPosition 1 i					
					
					if(contador == 1)then
					(
						tV = _currentVertex[2]
						lV = _currentVertex[1]
						bV = _currentVertex[2]
						rV = _currentVertex[1]
					)else(
						--top				
						if(_currentVertex[2] > tV)then
						(
							tV = _currentVertex[2]
						)
						--left
						if(_currentVertex[1] < lV)then
						(
							lV = _currentVertex[1]
						)
						--bottom
						if(_currentVertex[2] < bV)then
						(
							bV = _currentVertex[2]
						)
						--right
						if(_currentVertex[1] > rV)then
						(
							rV = _currentVertex[1]
						)
					)--end if
				)--end for
				
				--calculem les dimensions en pixels...
				_absoluteWidth = rV - lV
				_absoluteHeight = tV - bV
				
				_centerPivotPoint = _uvBase.getSelCenter()
				
				_atlasResolution = atlasResArray[dd_objects.selection]
				
				_actualPixelWidth = _absoluteWidth *  _atlasResolution
				_actualPixelHeight = _absoluteHeight * _atlasResolution
				
				_thresh = et_pxThreshold.text as float
						
				_scaleTransformWidth = (_actualPixelWidth-_thresh)/_actualPixelWidth
				_scaleTransformHeight = (_actualPixelHeight-_thresh)/_actualPixelHeight
				
				_uvBase.unwrap2.ScaleSelectedXY _scaleTransformWidth _scaleTransformHeight _centerPivotPoint
			)--end if
		)--end fn
		
		
		-- FUNCTIONS end --------------------------------------------------------------------------------------------------------

		
		-- UI PROG ini ---------------------------------------------------------------------------------------------------------------
		on AtlasPiecesX_sp changed value do
		(
			if(PositionX_sp.value > value)then
			(
				PositionX_sp.value = value
			)
			PositionX_sp.range.y = value
		)
		
		on AtlasPiecesY_sp changed value do
		(
			if(PositionY_sp.value > value)then
			(
				PositionY_sp.value = value
			)
			PositionY_sp.range.y = value
		)
		
		on Reposition_bt pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				
				perc = 100.0 / AtlasPiecesX_sp.value
				
				percentScaleFaceShellBy _uvBase perc
				
				stepX = 1.0 / AtlasPiecesX_sp.value
				stepY = 1.0 / AtlasPiecesY_sp.value
				
				px = PositionX_sp.value
				py = PositionY_sp.value
				
				xxx = stepX * (px-1.0)
				yyy = stepY * (AtlasPiecesY_sp.value - (py-1.0)) - stepY
				
				_pos = point2 xxx yyy
				alignTo _uvBase _pos
			)
		)
		
		on rep_1x1 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" -- <-- centered before move
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0 0.75
				alignTo _uvBase _pos
			)
		)
		
		on rep_1x2 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0 0.5
				alignTo _uvBase _pos
			)
		)
		
		on rep_1x3 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0 0.25
				alignTo _uvBase _pos
			)
		)
		
		on rep_1x4 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0 0
				alignTo _uvBase _pos
			)
		)
		
		on rep_2x1 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.25 0.75
				alignTo _uvBase _pos
			)
		)
		
		on rep_2x2 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.25 0.5
				alignTo _uvBase _pos
			)
		)
		
		on rep_2x3 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.25 0.25
				alignTo _uvBase _pos
			)
		)
		
		on rep_2x4 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.25 0
				alignTo _uvBase _pos
			)
		)
		
		on rep_3x1 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.5 0.75
				alignTo _uvBase _pos
			)
		)
		
		on rep_3x2 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.5 0.5
				alignTo _uvBase _pos
			)
		)
		
		on rep_3x3 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.5 0.25
				alignTo _uvBase _pos
			)
		)
		
		on rep_3x4 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.5 0
				alignTo _uvBase _pos
			)
		)
		
		on rep_4x1 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.75 0.75
				alignTo _uvBase _pos
			)
		)
		
		on rep_4x2 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.75 0.5
				alignTo _uvBase _pos
			)
		)
		
		on rep_4x3 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.75 0.25
				alignTo _uvBase _pos
			)
		)
		
		on rep_4x4 pressed do
		(
			if(checkFaceModeSelected() == true)then
			(
				_uvBase =  $.modifiers[#unwrap_uvw]
				regularScaleFaceShellBy _uvBase 256 false
				alignTo _uvBase "CENTER" 
				percentScaleFaceShellBy _uvBase 25
				_pos = point2 0.75 0
				alignTo _uvBase _pos
			)
		)
		
		-- UI PROG end ---------------------------------------------------------------------------------------------------------------
	)--end rollout
	
	CreateDialog unwrapAtlaser "Unwrap Atlaser" width:130 height:370 --bgcolor:(color 255 255 255 )
