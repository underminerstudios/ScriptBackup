/*
This is a dialog that has two buttons.
"Save" will save the transformation values of the currently selected object.
"Done" will place a dummy with the transformation values of the currently selected object. The selected object will then get the transform values that were stored with the "Save" button.

Example use:
- Select the parent dummy of a layer.
- Click "Save"
- Move the dummy to a new position.
- Click "Done"
(The dummy will move back to it's original position and a new dummy will be created and added to the dummy's original layer)

Details:
-You can provide the name of the new dummy in the dialog's text field.
-If a dummy with the same name is found in the layer, it will be replaced.

*/
-- by Norman Schaar - norman.schaar@gameloft.com


--Function to kill or launch a dialog
fn KillAndLaunchDialog theRollout kill launch=
(
	if kill do try (	DestroyDialog theRollout; ) catch();
	if launch do createDialog theRollout	
)

--Function that will find a node in the layers
fn findthenode theNode =
(
	for i=0 to (LayerManager.count - 1) do
	(
		(LayerManager.getLayer i).nodes &thenodes
		for n in thenodes do
		(
			if n == theNode do
			(
				return i
			)
		)
	)
)


--Close the Dialog in case it was already opened in order to avoid duplicate instances of the dialog
KillAndLaunchDialog DummyTransformSaveDoneDialog true false


--Defining the dialog
rollout DummyTransformSaveDoneDialog "Save/Done Dummy" width:100 height:95
(
	button btn_Save "Save" pos:[0,0] width:50 height:50
	button btn_Done "Done" pos:[50,0] width:50 height:50
	label lbl_name "New Dummy Name:" pos:[5,51]
	edittext edtxt_name text:"Pos02" width:100 height:20 pos:[-2,71]
	
	--On Save pressed
	on btn_save pressed do
	(
		if (selection).count != 0 then
		(
			--Store the transform values of the selected object in a global variable
			global DummyTransformSaveDoneDialog_dummy_transform = ((selection)[1]).transform
		)
		else
		(
			messagebox "You need to select something..."
		)
	)
	
	-- On "Done" pressed
	on btn_done pressed do
	(
		if DummyTransformSaveDoneDialog_dummy_transform != undefined then
		(
			--Save the current transform of the dummy
			CurrentTransform = ((selection)[1]).transform
			--Move it back to its orignial transform values
			((selection)[1]).transform = DummyTransformSaveDoneDialog_dummy_transform
			
			--Create dummy
			newDummy = Dummy()
			--Give it the transform values we saved just now
			newDummy.transform = CurrentTransform
			--Check if there are dummies with the existing name, if so delete them.
			(LayerManager.getLayer (findthenode (selection)[1])).nodes &thenodes
			for n in thenodes do
			(
				if n.name == edtxt_name.text AND (n.baseObject as string) == "Dummy" do
				(
					delete n
				)
			)
			--Change the new of the new dummy
			newDummy.name = edtxt_name.text
			--Move the dummy to the current layer
			(LayerManager.getLayer (findthenode (selection)[1])).addnode newDummy
			--Select New Dummy
			select newDummy
			--Clear the variable
			global DummyTransformSaveDoneDialog_dummy_transform = undefined
		)
		else
		(
			messagebox "You need to save a transform value first!"
		)
	)
	
	--Clear the global variable on dialog open and close
	on DummyTransformSaveDoneDialog open do
	(
		global DummyTransformSaveDoneDialog_dummy_transform = undefined
	)
	
	on DummyTransformSaveDoneDialog close do
	(
		global DummyTransformSaveDoneDialog_dummy_transform = undefined
	)
)
--Open the dialog
createDialog DummyTransformSaveDoneDialog