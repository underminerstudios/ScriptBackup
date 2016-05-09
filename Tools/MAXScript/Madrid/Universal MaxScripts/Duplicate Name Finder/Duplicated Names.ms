/*
	Duplicate Name Finder
	
	This script will list all the duplicate names in the scene

*/
-- by Norman Schaar - norman.schaar@gameloft.com

try(destroyDialog DLG_DUPLICATED_NAMES)catch()
rollout DLG_DUPLICATED_NAMES "Duplicated Names"
(
	local theArray = #()
	local theDuplicates = #()
	dotNetControl lv "ListView" width:200 height:400 align:#center pos:[0,0]
	
	on DLG_DUPLICATED_NAMES open do
	(
		lv.View = (dotNetClass "System.Windows.Forms.View").Details  
		lv.Columns.add "Names" 180
		for o in objects where (appendifunique theArray o.name) == false do (appendifunique theDuplicates o.name)
		for n in theDuplicates do (lv.items.add (dotNetObject "System.Windows.Forms.ListViewItem" n))
	)
)
createDialog DLG_DUPLICATED_NAMES width:200 height:400