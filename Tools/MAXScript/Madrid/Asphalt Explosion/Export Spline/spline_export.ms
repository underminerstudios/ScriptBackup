-- showProperties selection[1]

fn spline_export theObject PathWidth numSamples tension bias outputpath=
(
	local splineNum = theObject.numSplines
	if splineNum == 1 then
	(
		local knotNum = numKnots theObject 1
		local theText = #()
		append theText ("<?xml version=" + "\"" + "1.0" + "\"" + "?>")
		append theText ("<root>")
		append theText ("	<folder name=" + "\"" + "import" + "\"" + ">")
		append theText ("		<entity name=" + "\"" + theObject.name + "\"" + " template=" + "\"" + "ChunkLaneDef" + "\"" + ">")
		append theText ("			<transform pos=" + "\"" + (theObject.pos.x as string) +  "," + (theObject.pos.y as string) + "," + (theObject.pos.z as string) + "\"" + " rot=" + "\"" + "0,0,0,1" + "\"" + " euler=" + "\"" + "0,0,0" + "\"" + " />")
		append theText ("			<param name=" + "\"" + "PathWidth" + "\"" + ">")
		append theText ("				<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("					<data val=" + "\"" + PathWidth as string + "\"" +"/>")
		append theText ("				</val>")
		append theText ("			</param>")
		append theText ("			<param name=" + "\"" + "Points" + "\"" + ">")
		append theText ("				<val components=" + "\"" + knotNum as string + "\"" + ">")
		for i=1 to knotNum do
		(
		local thePos = getKnotPoint theObject 1 i
		local NodeName = "Node"
		if (i - 1) <= 9 then (NodeName += "0" + (i-1) as string) else (NodeName += (i-1) as string)
		append theText ("					<!--idx " + (i - 1) as string + "-->")
		append theText ("					<data name=" + "\"" + NodeName + "\"" + ">")
		append theText ("						<entity name=" + "\"" + NodeName + "\"" + " template=" + "\"" + "PathPoint" + "\"" + ">")
		append theText ("							<transform pos=" + "\"" + ((thePos.x - theObject.pos.x) as string) + "," + ((thePos.y - theObject.pos.y)as string) + ","  + ((thePos.z - theObject.pos.z)as string) + "\"" + " rot=" + "\"" + "0,0,0,0" + "\"" + " euler=" + "\"" + "0,0,-90.0" + "\"" + "/>")
		append theText ("							<param name=" + "\"" + "NodeWidth" + "\"" + ">")
		append theText ("								<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("									<data val=" + "\"" + "0" + "\"" + "/>")
		append theText ("								</val>")
		append theText ("							</param>")
		append theText ("							<param name=" + "\"" + "LineShift" + "\"" + ">")
		append theText ("								<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("									<data val=" + "\"" + "0" + "\"" + "/>")
		append theText ("								</val>")
		append theText ("							</param>")
		append theText ("						</entity>")
		append theText ("					</data>")
		)
		append theText ("				</val>")
		append theText ("			</param>")
		append theText ("			<param name=" + "\"" + "InterpType" + "\"" + ">")
		append theText ("				<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("					<data val=" + "\"" + "Spline" + "\"" + " />")
		append theText ("				</val>")
		append theText ("			</param>")
		append theText ("			<param name=" + "\"" + "NumSamples" + "\"" + ">")
		append theText ("				<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("					<data val=" + "\"" + numSamples as string + "\"" + " />")
		append theText ("				</val>")
		append theText ("			</param>")
		append theText ("			<param name=" + "\"" + "Tension" + "\"" + ">")
		append theText ("				<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("					<data val=" + "\"" + tension as string + "\"" + " />")
		append theText ("				</val>")
		append theText ("			</param>")
		append theText ("			<param name=" + "\"" + "Bias" + "\"" + ">")
		append theText ("				<val components=" + "\"" + "1" + "\"" + ">")
		append theText ("					<data val=" + "\"" + bias as string + "\"" + " />")
		append theText ("				</val>")
		append theText ("			</param>")
		append theText ("		</entity>")
		append theText ("	</folder>")
		append theText ("</root>")
		(dotNetClass "System.IO.File").WriteAllLines (outputpath + "\\" + theObject.name + ".eclara") theText
	)
	else
	(
		messagebox "ERROR: Can't export Editable Spline with multiple sub-splines."
	)
)



try(destroyDialog DLG_SPLINE_EXPORT)catch()
rollout DLG_SPLINE_EXPORT "Spline Export"
(
	spinner sp_pathwidth "Path Width:" type:#float range:[0.0,10000.0,1.0] fieldWidth:40
	spinner sp_samples "Samples per Segment:" type:#integer range:[0,10,10] fieldWidth:40
	spinner sp_tension "Spline Tension:" type:#float range:[-100.0,100.0,0.0] fieldWidth:40
	spinner sp_bias "Spline Bias:" type:#float range:[-100.0,100.0,0.0] fieldWidth:40
	button btn_export "Export" Width:150 height:40
	
	on btn_export pressed do
	(
		local outputpath = getSavePath caption:"SavePath" initialDir:"C:\\"
		if outputpath != undefined do
		(
		spline_export selection[1] sp_pathwidth.value sp_samples.value sp_tension.value sp_bias.value outputpath
		)
	)
)
createDialog DLG_SPLINE_EXPORT Width:180