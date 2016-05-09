	-- check selection
	if ((selection as Array).count == 0) do
	(
		messageBox ("0 objects selected")
		return 0
	)

	-- query destination filename
	ini = getMAXIniFile()
	lastpath = GetINISetting ini "Gameloft" "Collision_Last_Path"
	--path = getSavePath caption:"Choose scene directory" initialDir:""
	filename = getSaveFileName types:"ShapeDef(*.shapedef)|*.shapedef|*.*|" filename:(lastpath + "\\shape.shapedef")
	
	if filename == undefined do
	(
		return 0
	)
	
	-- store last path for usability
	lastpath = getFilenamePath filename
	setINISetting ini "Gameloft" "Collision_Last_Path" lastpath
	
	-- create file stream
	fs = openFile filename mode:"wb"
	if (fs == undefined) do
	(
		messageBox ("Can't write file")
		return 0
	)
	
	-- change display type to get rid of m suffixes (36.0m)
	units.DisplayType = #Generic
	units.MetricType = #meters

	-- create root element	
	format "<def>\n" to:fs
	
	-- store all nodes
	for o in selection do
	(
		format "<shape" to:fs
		-- add attributes
		format " name=\"%\"" o.name to:fs
		
		q = o.transform.rotation
		p = o.transform.pos
		m = q as matrix3
		s = o.scale
		
		if (classOf(o.baseObject) == Box) then
		(
			format " type=\"box\"" to:fs
			format " length=\"%\"" o.length to:fs
			format " width=\"%\"" o.width to:fs
			format " height=\"%\"" o.height to:fs
			
			p = p + ([0,0,o.height/2] * m)
		)
		else if (classOf(o.baseObject) == Sphere) then
		(
			format " type=\"sphere\"" to:fs
			format " radius=\"%\"" o.radius to:fs
		)
		else if (classOf(o.baseObject) == Cylinder) then
		(
			format " type=\"cylinder\"" to:fs
			format " radius=\"%\"" o.radius to:fs
			format " height=\"%\"" o.height to:fs
			p = p + ([0,0,o.height/2] * m)
		)
		else if (classOf(o.baseObject) == Capsule) then
		(
			h = o.height
			if (o.heighttype == 0) do
			(
				h = h - o.radius * 2
			)
			format " type=\"capsule\"" to:fs
			format " radius=\"%\"" o.radius to:fs
			format " height=\"%\"" h to:fs
			p = p + ([0,0,h/2 + o.radius] * m)
		)
		else if (classof(o.baseObject) == Editable_Poly) then
		(
			format " type=\"convex hull\"" to:fs
		)
		else
		(
			format " type=\"undefined\"" to:fs
			messageBox("Unsupported type: " + o.name);
		)
		
		format " position=\"% % %\"" p.x p.y p.z to:fs
		format " rotation=\"% % % %\"" q.x q.y q.z q.w to:fs
		format " scale=\"% % %\"" s.x s.y s.z to:fs

		format ">\n" to:fs
		if (classof(o.baseObject) == Editable_Poly) do
		(
			-- add vertices
			format "<vertices" to:fs
			format " count=\"%\">" (polyop.getNumVerts o) to:fs 
			for i=1 to (polyop.getNumVerts o) do
			(
				v = polyop.getVert o i
				format " % % %" v.x v.y v.z to:fs
			)
			format "</vertices>\n" to:fs
			
			-- add polygons
			numPolys = (polyop.getNumFaces o)
			for i=1 to numPolys do
			(
				format "<poly" to:fs
				indices = (polyop.getFaceVerts o i)
				format " count=\"%\">" indices.count to:fs 
				for j=1 to indices.count do
				(
					format " %" (indices[j]-1) to:fs
				)
				format "</poly>\n" to:fs
			)
		)
		format "</shape>\n" to:fs
	)	
	
	-- close root element
	format "</def>\n" to:fs
	
	-- close file stream
	close fs
	
	--units.DisplayType = #Metric
	units.MetricType = #meters
	
	messageBox ("Done!")
