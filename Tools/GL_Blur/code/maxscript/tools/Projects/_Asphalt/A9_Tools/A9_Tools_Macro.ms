macroScript A9_Tools
category:"GL"
buttonText:"A9 Tools"
(
Tools_Path = (Getdir #scripts) + "/Gameloft/A9_Tools/"
fileIn (Tools_Path + "A9_Tools.ms")
)

macroScript A9_VCPicker
category:"Gameloft Tools"
buttonText:"A9 VC Picker"
(
		
fn App_Vertex_Color oColor = 
(
	max modify mode
	if selection.count > 1 then (
		print "Script only works on a single object"
		)-- end selection count test
	else 
		(
		s = $
		if s != undefined then 
		(
			oObjLevel = subobjectLevel
			if Classof s != Editable_Poly  then 
			(
				convertTo s PolyMeshObject
				subobjectLevel = oObjLevel
				
			)
			oSelLevel = s.GetMeshSelLevel()
			if oSelLevel == #Face then(
				selVerts = s.GetSelection #Face
				for i in selVerts do (
						polyop.SetFaceColor s 0 i (oColor)
					)--end i loop
				)--end if decision on SetfaceColor
			if oSelLevel != #Face then(
				s.ConvertSelection oSelLevel  #Vertex	
				selVerts = s.GetSelection #Vertex
				for i in selVerts do (
						polyop.setvertcolor s 0 i (oColor)
					)--end i loop
				)
			subobjectLevel = oObjLevel 
			s.showVertexColors = true
			s.vertexColorType = #color
		)

		redrawViews()
		)--end if decision
	
)--end fn

fn ColorPick oColor=
(
		colorF3 = oColor 
		if colorF3  !=  [-1,-1,-1] then 
		(
			if ( colorF3[1] != 0 or colorF3[2] != 0 or colorF3[3] != 0 ) then
			(
				_color = (255.0 * colorF3) as color
				
				App_Vertex_Color ( _color )
			)
		)
)
_color = spColorPick()

ColorPick ( _color )

)