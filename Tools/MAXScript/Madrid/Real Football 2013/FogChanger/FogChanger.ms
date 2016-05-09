/*
	Fog Changer
	
	This script will allow you to change the "FogStartEnd" and the "FogColor" parameters of all the GL_EFFECT materials in the scene effectivly changing the fog in the scene.

*/
-- by Norman Schaar - norman.schaar@gameloft.com


try(destroyDialog change_fog)catch()
rollout change_fog "Change Fog"
(
	colorpicker FogColor "Fog Color:" color:[255,255,255] modal:false alpha:false
	spinner fog_intensity "Fog Intensity" range:[0.0,1.0,1.0] type:#float scale:0.01
	spinner fog_start "Fog Start:" range:[-9999,9999,1]
	spinner fog_end "Fog End:" range:[1,9999,500]
	
	on fog_start changed val do
	(
		for n in scenematerials do
		(
			if classof n == Multimaterial then
			(
				for m in n.materialList do
				(
					try((m.params.GetEffectParamByName "FogStartEnd").value = #(val, fog_end.value))catch()
				)
			)
			else
			(
				try((n.params.GetEffectParamByName "FogStartEnd").value = #(val, fog_end.value))catch()
			)
		)
	)
	
	on fog_end changed val do
	(
		for n in scenematerials do
		(
			if classof n == Multimaterial then
			(
				for m in n.materialList do
				(
					try((m.params.GetEffectParamByName "FogStartEnd").value = #(fog_start.value, val))catch()
				)
			)
			else
			(
				try((n.params.GetEffectParamByName "FogStartEnd").value = #(fog_start.value, val))catch()
			)
		)
	)
	
	on FogColor changed arg do
	(
		for n in scenematerials do
		(
			if classof n == Multimaterial then
			(
				for m in n.materialList do
				(
					try((m.params.GetEffectParamByName "FogColor").value = #((arg.r/255),(arg.g/255),(arg.b/255),fog_intensity.value))catch()
				)
			)
			else
			(
				try((n.params.GetEffectParamByName "FogColor").value = #((arg.r/255),(arg.g/255),(arg.b/255),fog_intensity.value))catch()
			)
		)
	)
	
	on fog_intensity changed val do
	(
		for n in scenematerials do
		(
			if classof n == Multimaterial then
			(
				for m in n.materialList do
				(
					try((m.params.GetEffectParamByName "FogColor").value = #((FogColor.color.r/255),(FogColor.color.g/255),(FogColor.color.b/255),val))catch()
				)
			)
			else
			(
				try((n.params.GetEffectParamByName "FogColor").value = #((FogColor.color.r/255),(FogColor.color.g/255),(FogColor.color.b/255),val))catch()
			)
		)
	)
)
createDialog change_fog
