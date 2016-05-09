macroscript MeshCheck
	category:"GL Scripts"
	buttonText:"Mesh Check"
	toolTip:"Mesh Check"
	Icon:#("GL_MeshCheck",1)

(
	global  mesh_check, draw_line,  edgeToVerts,  before_draw_line,  BackFace,  faceToVerts,  doubleFaceFn,  FNrefind

	global obj, obj_mesh,    old_obj = undefined,   obj_Pcount,  old_obj_Pcount
	global  tot_vert_array=#(),  OEvert_array=#(),  DFvert_array=#(),   tot_color=#(),  MEvert_array=#(),  rstDDvert=#()
	struct CountMesh (Oedge=0, ddfaces=0, GME=0, rstDDvert=0)
	CoMesh=CountMesh()
	MC_bitmap1 = (getDir #maxroot)+  "UI\\Icons\\" + "GL_MeshCheck.tif"


	fn make_spline  Mvert_array  Mcolor = (
		if Mvert_array.count  == 0 do return 0

		fn drawLineBetweenTwoPoints pointA pointB =
		(
			ss = SplineShape pos:pointA
			addNewSpline ss
			addKnot ss 1 #corner #line PointA
			addKnot ss 1 #corner #line PointB
			updateShape ss
			return ss
		)
		
		--newSpline = drawLineBetweenTwoPoints [10,20,30] [100,200,10]
		
		newSpline=#()
		for i in 1 to Mvert_array.count do (
			SA= obj_mesh.verts[(Mvert_array[i] as array)[1]].pos
			SB= obj_mesh.verts[(Mvert_array[i] as array)[2]].pos
			newSpline[i] = drawLineBetweenTwoPoints SA SB
		)


		for i in 2 to newSpline.count do (
			aaWeld=addAndWeld newSpline[1] newSpline[i] 0
		)
		
		
		select newSpline[1]
		max modify mode
		subobjectLevel = 1
		for i in 1 to (numSplines newSpline[1]) do (
			nk=numknots newSpline[1] i
			setKnotSelection newSpline[1] i (#{1..nk} as array)
		)
		splineOps.startBreak  newSpline[1]
		newSpline[1].wirecolor = Mcolor
		try(
			newSpline[1].steps = 6
			newSpline[1].render_displayRenderMesh = ON
			newSpline[1].render_thickness = 0.05
			newSpline[1].render_auto_smooth = OFF
		)catch()
		newSpline[1].material=StandardMaterial selfIllumAmount:100 diffuse:Mcolor
		max create mode
	)

	
	fn print_color_text  = (
		if obj==undefined   do (
			CoMesh.Oedge =0;  CoMesh.ddfaces =0;    CoMesh.GME =0;     CoMesh.rstDDvert =0;
		)

		if mesh_check.OE_ch.checked == ON  and  CoMesh.Oedge > 0  then  (
			mesh_check.OE_text.visible=ON;		mesh_check.OE_text.caption="";		mesh_check.OE_text.caption = (CoMesh.Oedge as string)
		)else ( mesh_check.OE_text.visible=OFF )
		
		if mesh_check.DF_ch.checked == ON  and  CoMesh.ddfaces > 0  then  (
			mesh_check.DF_text.visible=ON
			mesh_check.DF_text.caption="";		mesh_check.DF_text.caption = (CoMesh.ddfaces  as string)
		)else ( mesh_check.DF_text.visible=OFF )

		if mesh_check.ME_ch.checked == ON and CoMesh.GME > 0   then  (
			mesh_check.ME_text.visible=ON
			mesh_check.ME_text.caption = "";		mesh_check.ME_text.caption = (CoMesh.GME as string)
		)else ( mesh_check.ME_text.visible=OFF )

		if mesh_check.IV_ch.checked == ON  and CoMesh.rstDDvert > 0    then  (
			mesh_check.IV_text.visible=ON
			mesh_check.IV_text.caption="";		mesh_check.IV_text.caption =  (CoMesh.rstDDvert as string)
		)else (mesh_check.IV_text.visible=OFF)

	)

	
	---positions : [0,0,0] 같은 point3 의 배열이 들어와야됨
	--- 나중에 struct 로 sort해서 return 함
	fn qsort_ReturnStruct  positions = (
		
		fn compareFN v1 v2 valArray: =
		(
			local v1i = valArray[v1]
			local v2i = valArray[v2]
			local d = (length v1i)-(length v2i)
			case of
			(
				(d < 0.): -1
				(d > 0.): 1
				default: 0
			)
		)
		
		--positions=for i=1 to 10 collect (random [0,0,0] [100,100,0])
		indexArray = for i = 1 to positions.count collect i
		qsort indexArray compareFN valArray:positions
		
		struct  Tresult  (Tpositions=#(), number=#())
		TR = Tresult()
		for i = 1 to positions.count do (
		--	print positions[indexArray[i]]
			TR.Tpositions[i] =positions[indexArray[i]]
			TR.number[i] = indexArray[i]
		)
		return TR
	)


	--- multi / Isolat vertex Finding... !!
	fn MI_vert = (
		global FNrefind
		global FNfinDDvert
		global Fvertpos=#(),  Fvertpos_bak=#(),  Vcount,  Tvp
		
		
		Fvertpos=for i in 1 to obj_mesh.verts.count collect (
			obj_mesh.verts[i].pos
		)

		Tvp=qsort_ReturnStruct   Fvertpos

		fn FNrefind  i = (
			if Fvertpos_bak[i] != 0 and  Fvertpos_bak[i] == Tvp.Tpositions[i+Vcount]  do ( Fvertpos_bak[i+Vcount] = 0;   Vcount+=1;   FNrefind i  )	--여기서 재귀적 호출
			return Vcount
		)
		
		mesh_check.mc_prog.color = (color 0 255 255)
		resultDDvert=#()
		Fvertpos_bak = copy Tvp.Tpositions #nomap
		if Tvp.Tpositions[1] == [0,0,0] do return #()		--- 재귀적 호출을 잘못하면 다운됨...이 옵션을 체크후에 오브젝트 생성시
		for i in 1 to Tvp.Tpositions.count do (
			Vcount=1
			Vcount=FNrefind i
		
			if Vcount > 1 do append resultDDvert Tvp.number[i]
			mesh_check.mc_prog.value =  (i/Tvp.Tpositions.count as float) * 100
		)

		join  resultDDvert  ((meshop.getIsoVerts obj_mesh) as array)
		
		return resultDDvert
	)


	---스크립트 레퍼런스에 있는내용을 따옴
	fn edgeVerts  theObj  theEdge = 
	( 
		local theFace = ((theEdge-1)/3)+1 
		local theVerts = getFace theObj theFace 
		case ((mod (theEdge-1) 3) as integer) of 
		(
			0: #(theVerts.x, theVerts.y)
			1: #(theVerts.y, theVerts.z)
			2: #(theVerts.z, theVerts.x)
		) 
	) 


	fn getMultEdge = (
		global FNrefind
		global VEdges_bak=#(),	VEdges=#(), Vcount=0,	T=#()
		
		
		VEdges=for i in 1 to obj_mesh.edges.count collect (
			Varray = edgeVerts obj_mesh  i 
			if Varray.count == 2 do (
				A = obj_mesh.verts[Varray[1]].pos 
				B = obj_mesh.verts[Varray[2]].pos 
				Vcc=(A+B)/2.0
			)
			if Varray.count == 1 do Vcc = obj_mesh.verts[Varray[1]].pos
		
			Vcc
		)


		T=qsort_ReturnStruct   VEdges

		fn FNrefind  i = (
			if VEdges_bak[i] != 0 and  VEdges_bak[i] == T.Tpositions[i+Vcount]  do ( VEdges_bak[i+Vcount] = 0;   Vcount+=1;   FNrefind i  )	--여기서 재귀적 호출
			return Vcount
		)
		
		mesh_check.mc_prog.color = yellow
		resultEdge=#()
		VEdges_bak = copy T.Tpositions #nomap
		if T.Tpositions[1] == [0,0,0] do return #()		--- 재귀적 호출을 잘못하면 다운됨...이 옵션을 체크후에 오브젝트 생성시
		for i in 1 to T.Tpositions.count do (
			Vcount=1
			Vcount=FNrefind i

			if Vcount > 2 do append resultEdge T.number[i]
			if keyboard.escPressed == ON do DestroyDialog  mesh_check
			mesh_check.mc_prog.value =  (i/T.Tpositions.count as float) * 100
		)
		return  resultEdge
	)


	fn getViewDirectionRay =
	(
		local coordSysTM = Inverse(getViewTM())
		local viewDir = -coordSysTM.row3
		local viewPt = coordSysTM.row4
		return ray viewPt viewDir
	)


	fn  GetBackFaces = (
		backF=#()
		dirRay=getViewDirectionRay()
		for v = obj_mesh.numfaces to 1 by -1 do 
		(
			if NOT (dot (getFaceNormal obj_mesh v) dirRay.dir) <= -0.0 do append  backF  v
		)
		return backF
	)


	fn ifDelete = (
		if  obj != undefined  and  obj.isdeleted == ON do (
			tot_vert_array=#();  OEvert_array=#();  DFvert_array=#();   MEvert_array=#()
			obj =	 undefined
			obj_mesh = undefined
			mesh_check.la_text1.text = ""
		)
	)


	--- 오브젝트를 선택했을때...
	fn MC_select = (
		if selection.count == 1 and (superclassof $) == GeometryClass  then (
			if  old_obj  !=  obj do (
				tot_vert_array=#();  OEvert_array=#();  DFvert_array=#();   MEvert_array=#()
			)
			
			obj = $
			obj_mesh = snapshotasmesh $
			obj_Pcount = obj_mesh.faces.count
			mesh_check.la_text1.text = $.name

			if old_obj  !=  obj  or  obj_Pcount  !=  old_obj_Pcount   do (
				if  mesh_check.OE_ch.checked == ON  do (
					Oedge=meshop.getOpenEdges obj_mesh
					CoMesh.Oedge = (Oedge as array).count
					OEvert_array=edgeToVerts Oedge
				)
		
				if mesh_check.DF_ch.checked == ON  do (
					ddfaces=doubleFaceFn()
					CoMesh.ddfaces = ddfaces.count
					DFvert_array=faceToVerts  ddfaces
				)
				if mesh_check.ME_ch.checked == ON  do (
					GME=getMultEdge()
					CoMesh.GME = GME.count
					MEvert_array=edgeToVerts GME
				)
				if mesh_check.IV_ch.checked == ON do (
					rstDDvert = MI_vert()
					CoMesh.rstDDvert = rstDDvert.count
				)
			)
		
			if  old_obj  !=  obj  or  obj_Pcount  !=  old_obj_Pcount  do  ( old_obj = obj;	  old_obj_Pcount = obj_Pcount   )
		)
		else ( 
		--	mesh_check.la_text1.text = "";          obj = undefined;   obj_mesh = undefined   
		)

		print_color_text()
	)



	fn doubleFaceFn = (
		global  FNrefind
		global dfT
		global  theVertList=#(),  theVertPos=#(),  VertPosAverage=#(),  VertPosAverage_copy=#(),  Vnum_array=#()

	--	if obj != undefined and  (isdeleted obj) == ON do obj = undefined
	--	if obj == undefined do return
		
		theVertList=for i in 1 to obj_mesh.faces.count collect ( 
			--- meshop.getVertsUsingFace 보다 훨빠름
			gf_temp=getFace  obj_mesh  i
			#(gf_temp.x, gf_temp.y, gf_temp.z)
		)
		
		for i in 1 to theVertList.count do (
			append theVertPos #()
			for j in 1 to theVertList[i].count do (
				theVertPos[i][j]=obj_mesh.verts[theVertList[i][j]].pos
			)
		)
		
		for i in 1 to theVertPos.count do (
			if theVertPos[i].count == 3 do  VertPosAverage[i]=(theVertPos[i][1] + theVertPos[i][2] + theVertPos[i][3]) /3.0
			if theVertPos[i].count == 2 do  VertPosAverage[i]=(theVertPos[i][1] + theVertPos[i][2]) /2.0
		)

		dfT=qsort_ReturnStruct   VertPosAverage
		
		----- VertPosAverage 에서 중복되는 2개 이상 중복되는 faces를 Vnum_array 에 넣는다
		fn FNrefind  i = (
			if VertPosAverage_copy[i] != 0 and  VertPosAverage_copy[i] == dfT.Tpositions[i+Vcount]  do ( VertPosAverage_copy[i+Vcount] = 0;   Vcount+=1;   FNrefind i  )	--여기서 재귀적 호출
			return Vcount
		)

		mesh_check.mc_prog.color = RED
		Vnum_array=#();   VertPosAverage_copy=#()
		VertPosAverage_copy = copy  dfT.Tpositions #nomap
		if dfT.Tpositions[1] == [0,0,0] do return #()		--- 재귀적 호출을 잘못하면 다운됨...이 옵션을 체크후에 오브젝트 생성시
		for i in 1 to dfT.Tpositions.count do (
			Vcount=1
			Vcount=FNrefind i
		
			if Vcount > 1 do append Vnum_array dfT.number[i]
			if keyboard.escPressed == ON do DestroyDialog  mesh_check
			mesh_check.mc_prog.value =  (i/dfT.Tpositions.count as float) * 100
		)

	---  old 방식 지울것...!!
	--	for i in 1 to VertPosAverage.count do (
	--		Vnum=0
	--		VertPosAverage_copy[i] = ""
	--		if (Ftemp=finditem  VertPosAverage_copy  VertPosAverage[i]) > 0  do  ( append Vnum_array Ftemp	)
	--	)

		return  Vnum_array   ---return faces
	)


	fn draw_point  point_array = (
		gw.setTransform (matrix3 1)

		for i in 1 to  point_array.count do (
			vertpos=obj_mesh.verts[point_array[i]].pos
			pp=gw.wTransPoint vertpos
			gw.wMarker pp #circle color:(color 0 255 255)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)


	fn before_draw_line = (
		gw.setTransform (matrix3 1)
		
		tot_vert_array=OEvert_array + DFvert_array + MEvert_array

		MC=mesh_check
		if  MC.OE_ch.checked == ON  or  MC.DF_ch.checked == ON  or   MC.ME_ch.checked == ON or  MC.IV_ch.checked == ON  do (
			if  obj_mesh != undefined    and   obj.isdeleted == OFF  and  (superclassof obj) == GeometryClass  then (
				if mesh_check.BF_cb.checked == ON do (
					--- 뒤면을(backfaces)  감지하여 읽어들인다..
					BackFace=GetBackFaces()
					BackVerts=faceToVerts BackFace
					for i in 1 to tot_vert_array.count do (
						for j in 1 to BackVerts.count do (
							bitSub=(tot_vert_array[i] - BackVerts[j])
							if bitSub.isEmpty == ON do tot_vert_array[i]=#{}
						)
					)
				)

				for i in 1 to tot_vert_array.count do (
					if tot_vert_array[i].isEmpty == ON do continue
					if 1  <= i and  OEvert_array.count  >= i  then   gw.setColor #line green
					else if (OEvert_array.count + DFvert_array.count)  >= i then  gw.setColor #line red
					else if (OEvert_array.count + DFvert_array.count + MEvert_array.count)  >= i then  gw.setColor #line yellow

					draw_line  obj  obj_mesh  (tot_vert_array[i] as array)
				)

				if MC.IV_ch.checked == ON  do  draw_point  rstDDvert
					-- Update the viewports 
				gw.enlargeUpdateRect #whole 
				gw.updateScreen()
			)
		)
	)


	fn draw_line obj  obj_mesh  two_array = (
		pp=#()
		
		for i in 1 to two_array.count do (
	--		vertpos=obj_mesh.verts[two_array[i]].pos * obj.transform    --절대좌표를 월드좌표로 변환함  ($.mesh 로 했을때는 반드시 이런식으로 해야됨)
			vertpos=obj_mesh.verts[two_array[i]].pos    --절대좌표를 월드좌표로 변환함 ( snapshotasmesh 사용)
			append  pp  (gw.wTransPoint  vertpos)
		)	

		--- pp.count 항상 2가 들어감
		gw.wPolyline pp false 
		if mesh_check.singleLine_print.checked == OFF do (
			for i  in 1 to pp.count do pp[i]=pp[i]+[0, 1, 1]
			gw.wPolyline pp  false 		-- 두번째 라인을 그림...--;
		)

	)


	-- #(#{2, 4}, #{1..2}, #{1, 3}....  )  이런식으로 return 됨
	fn edgeToVerts edgeArray = (
			
		edgeArray=edgeArray as array
		Evert_array=#();			Evert_array_S=#()

		for i in 1 to edgeArray.count do (
			ppp = (meshop.getVertsUsingEdge obj_mesh edgeArray[i])
			ppp_S= ppp as string
			cc=0
			if (finditem  Evert_array_S  ppp_S) == 0 do (
				append  Evert_array  ppp
				append  Evert_array_S  ppp_S
			)
		)
		return Evert_array
	)


	fn faceToVerts faces  = (
		faceArray=faces as array
		face_array=#();	face_array_S=#();   tot_ppp=#()

		for i in 1 to faceArray.count do (
			ppp = (getface  obj_mesh  faceArray[i])
			pop=#(ppp.x) + #(ppp.y) + #(ppp.z)
			Tppp=#();		append  Tppp  pop[1];   append  Tppp  pop[2]
			append  tot_ppp (Tppp as bitarray)

			Tppp=#();		append  Tppp  pop[2];   append  Tppp  pop[3]
			append  tot_ppp (Tppp as bitarray)
			
			Tppp=#();		append  Tppp  pop[1];   append  Tppp  pop[3]
			append  tot_ppp (Tppp as bitarray)
		)
		return tot_ppp
	)


	-----roll --------------
	rollout mesh_check "Mesh Check" height:200 width:160
	(       
		label la_text1 ""
		bitmap  the_bmp  bitmap:(bitmap 30 80 color:(color 150 150 150) )  pos:[117, 29]
		checkbox OE_ch ""  pos:[13,33]  width:12
		checkbox DF_ch ""  pos:[13,53]  width:12
		checkbox ME_ch ""  pos:[13,73]  width:12
		checkbox IV_ch ""  pos:[13,93]  width:12
		checkbutton BF_cb "BackFace" tooltip:"BackFace" pos:[8,124]
		button Update_btn  "Update" pos:[80,124] width:70
		hyperLink OE_text ""  address:"OE" color:(color 0 255 0)  pos:[130,35]   enabled:OFF
		hyperLink DF_text ""  address:"DF" color:RED  			pos:[130,53]
		hyperLink ME_text ""  address:"ME"   color:Yellow		pos:[130,75]  
		hyperLink IV_text ""   address:"IV"  color:(color 0 255 255)	pos:[130,95]  
		progressBar mc_prog pos:[10,170]  height:6
		button makeSp_btn "MS"  pos:[10,180] width:20 height:15 tooltip:"Make Splines"
		checkbox singleLine_print ""  pos:[50,180]  width:12

		on singleLine_print changed chk do (
			completeRedraw()
		)

		on makeSp_btn pressed do (
			make_spline OEvert_array GREEN
			make_spline DFvert_array RED
			make_spline MEvert_array YELLOW
		)

		on Update_btn pressed do (
			ifDelete()
			if obj != undefined do select  obj
			old_obj = undefined
			MC_select()
			completeRedraw()
		)

		on IV_ch changed val do (
			if IV_ch.checked == ON and  obj_mesh != undefined  do (
				rstDDvert = MI_vert()
				draw_point  rstDDvert
				CoMesh.rstDDvert = rstDDvert.count;	  print_color_text()
			)
			if IV_ch.checked == OFF do (
				rstDDvert=#()
				completeRedraw()
				print_color_text()
			)		
		)

		on ME_ch changed val do (
			if ME_ch.checked == ON and  obj_mesh != undefined  do (
				MEvert_array=#()
				GME=getMultEdge()
				MEvert_array=edgeToVerts GME
				before_draw_line()
				CoMesh.GME = GME.count;		 print_color_text()
			)
			if ME_ch.checked == OFF do (
				MEvert_array=#()
				completeRedraw()
				print_color_text()
			)
		)

		on BF_cb changed btn do (
			completeRedraw()
			MC_select()
		)

		on OE_ch changed val do (
			if OE_ch.checked == ON do (
				if obj_mesh != undefined do (
					OEvert_array=#()
					Oedge=meshop.getOpenEdges obj_mesh
					setEdgeSelection obj_mesh Oedge	-- editable mesh 일때만 선택된다.
	--				getEdgeSelection obj_mesh
					OEvert_array=edgeToVerts Oedge
					before_draw_line()
					CoMesh.Oedge = (Oedge as array).count;	print_color_text() 		
				)
			)

			if OE_ch.checked == OFF do (
				OEvert_array=#()
				completeRedraw()
				print_color_text()
			)
		)
		
		on DF_ch changed val do (
			if DF_ch.checked == ON  and  obj_mesh != undefined do (
				DFvert_array=#()
				ddfaces=doubleFaceFn()
				DFvert_array=faceToVerts  ddfaces
	--			print  vert_array
				before_draw_line()
				CoMesh.ddfaces = ddfaces.count;		 print_color_text()
			)		

			if DF_ch.checked == OFF do (
				DFvert_array=#()
				completeRedraw()
				print_color_text()
			)
		)

		
		on mesh_check open do (
			if heapSize < 25000000 do heapSize+=5000000

			ifDelete()
			MC_select()
			callbacks.addscript  #selectionSetChanged  "MC_select()"  id:#MC_select  persistent:false
			registerRedrawViewsCallback  before_draw_line 
		)
		on mesh_check close do (
			unregisterRedrawViewsCallback  before_draw_line
			callbacks.removescripts id:#MC_select
			completeRedraw()
		)
	) 
	createdialog mesh_check   bitmap:(openbitmap MC_bitmap1)
)