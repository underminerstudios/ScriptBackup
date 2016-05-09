--
--	\Title			UVW  Unwrapper	
--	
--	\Description	Déballe objet et définir automatiquement des images dans l'éditeur UV. Fonctionne avec shaders GLSL Gameloft
--	\Description	
--	\Description	Unwraps object and automatically set images in the uv editor. Works with Gameloft GLSL shaders
--	
--	\author		anisim.kalugin@gameloft.com - Gameloft - 01/23/2013


fn GL_Get_DiffuseSampler _material =
(
	local diff_tests = #("DiffuseMap", "Diffuse", "FalloffSampler","DiffuseSampler" )
	local _count = 1
	local gl_shader_sampler = undefined

	while gl_shader_sampler == undefined do
	(
		gl_shader_sampler = _material.params.GetEffectParamByName diff_tests[_count]
		_count = _count + 1
	)
	return (gl_shader_sampler.texturePath)
)

fn GL_Apply_UVW _texture _channel:1 =
(
	--APPY UV MODIFIER TO OBJECT
	local uv = modPanel.getCurrentObject() 
	if ( classof uv == Unwrap_UVW ) then 
	(
		uv.edit() 
	)
	if ( classof uv != Unwrap_UVW ) then
	(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		uv = modPanel.getCurrentObject() 
		uv.unwrap.setMapChannel _channel
		uv.unwrap4.setThickOpenEdges off
		uv.unwrap2.setFreeFormMode on
		uv.settvsubobjectmode 3
		uv.unwrap.edit ()
	)
	if (_texture != undefined ) then 
	(
		--SEE IF AN IMAGE EXISTS IN THE UV MAP NODES
		--IF FOUND SET IT TO THE UV
		local uv_node_count = abs(uv.numberMaps())
		for zz = 1 to uv_node_count do 
		(
			local _bitmap = uv.texMapList[zz]
			if (classof _bitmap == Bitmaptexture) then 
			(
				local uv_image_name = filenameFromPath ( _bitmap.filename)
				local shader_image_name = filenameFromPath ( _texture)
				if ( ( shader_image_name == uv_image_name ) == true ) then
				(
					uv.SetCurrentMap zz
					uv.unwrap.DisplayMap on
				)
			)
		)
	)
)

fn GL_UVW_Unwrap =
(
	oSel = selection as array	
	if oSel.count == 1 then 
	(
		local uv_texture = undefined
		local obj = oSel[1]
		local _material  = oSel[1].material
		
		if ( classof obj != Editable_Poly ) then
		(
			convertTo obj PolyMeshObject
		)	
		--FIND THE IMAGE BASED ON THREE DIFFERENT TYPE OF MATERIALS USED IN OUR PIPELINE
		if (classof _material == Multimaterial ) then
		(
			if ( subObjectLevel == 4 or subObjectLevel == 5 ) then
			(
				local prime_faceID = (polyop.getFaceSelection obj ) as array
				--WORKS ON SELECTED FACES. 
				--USES THE FIRST SELECTED FACE TO GET THE IMAGE 
				if ( prime_faceID.count != 0 ) then
				(
					mat_ID = polyop.getFaceMatID obj prime_faceID[1] --First selected face
					if ( classof _material[mat_ID] == Standardmaterial ) then 
					(
						if (_material[mat_ID].diffusemap != undefined ) then 
						(
							uv_texture = _material[mat_ID].diffusemap.filename
						)
					)
					-- find out what the name of the GLSL diffuse name is and get the image path
					if ( classof _material[mat_ID] == GL_Effect_Inst ) then
					(
						uv_texture = GL_Get_DiffuseSampler _material[mat_ID]
					)
				)
				else
				(
					subObjectLevel = 0
					break();
					if ( classof _material[1] == Standardmaterial ) then 
					(
						uv_texture = _material[1].diffusemap.filename
					)
					-- find out what the name of the GLSL diffuse name is and get the image path
					if ( classof _material[1] == GL_Effect_Inst ) then
					(
						uv_texture = GL_Get_DiffuseSampler _material[1]
					)
				)
			)
			else
			(
				
				if ( classof _material[1] == Standardmaterial ) then 
				(
					uv_texture = _material[1].diffusemap.filename
				)
				-- find out what the name of the GLSL diffuse name is and get the image path
				if ( classof _material[1] == GL_Effect_Inst ) then
				(
					uv_texture = GL_Get_DiffuseSampler _material[1]
				)
				
			)
		)	
		if (classof _material == Standardmaterial ) then
		(
			if (_material.diffusemap != undefined ) then 
			(
				uv_texture = _material.diffusemap.filename
			)
			if ( subObjectLevel == 4 or subObjectLevel == 5 ) then
			(
				local prime_faceID = (polyop.getFaceSelection obj ) as array
				if ( prime_faceID.count == 0 ) then
				(
					subObjectLevel = 0
				)
			)
		)
		if (classof _material == GL_Effect_Inst ) then
		(
			uv_texture = GL_Get_DiffuseSampler _material
			if ( subObjectLevel == 4 or subObjectLevel == 5 ) then
			(
				local prime_faceID = (polyop.getFaceSelection obj ) as array
				if ( prime_faceID.count == 0 ) then
				(
					subObjectLevel = 0
				)
			)
		)
		GL_Apply_UVW uv_texture _channel:1
	)
	else
	(
		uv_texture = undefined
		GL_Apply_UVW uv_texture _channel:1
	)
)

GL_UVW_Unwrap ()