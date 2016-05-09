##
#	\namespace	Grayscaler.main
#
#	\remarks	
#	
#	\author		beta@blur.com
#	\author		Blur Studio
#	\date		01/10/11
#


# make sure this is being run as the main process
if (__name__ in ('__main__', '__builtin__')):
	# since this file is being executed in the main scope, we need to register the tool package to the sys.path
	import blurdev
	blurdev.registerScriptPath(__file__)
	# depending on our environment, Python initializes the script differently for scope, so try both methods
	# importing from a sub-module
	try:
		from mpdialog import MpDialog
	# importing from the main package
	except:
		from MapProcessor.mpdialog import MpDialog
	blurdev.launch(MpDialog)
