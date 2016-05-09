/*
	Qualified Normals
	Switch on and off Quality Normals for 3dsMax 2011 Hotfix 4 and 3dsMax 2012
*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog QualifiedNormals)catch()
rollout QualifiedNormals "Qualified Normals"
(
	radiobuttons rb_normals "Normal Type:" labels:#("Default","Qualified") columns:1
	label lbl_warning "These changes require 3dsMax" align:#left
	label lbl_warning2 "to be restarted." align:#left
	
	on qualifiedNormals open do
	(
		local theStatus = getInisetting (getMAXIniFile()) "ViewportNormalMapping" "ViewportNormalMappingType"
		if theStatus == "Qualified" then
		(
			rb_normals.state = 2
		)
		else
		(
			rb_normals.state = 1
		)
	)
	
	on rb_normals changed theState do
	(
		if theState == 1 then
		(
			setINIsetting (getMAXINIFile()) "ViewportNormalMapping" "ViewportNormalMappingType" "Legacy"
		)
		else
		(
			setINIsetting (getMAXINIFile()) "ViewportNormalMapping" "ViewportNormalMappingType" "Qualified"
		)
	)
	
)
createDialog QualifiedNormals width:180

