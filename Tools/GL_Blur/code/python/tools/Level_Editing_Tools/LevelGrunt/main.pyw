##
#   :namespace  levelgruntdialog
#
#   :remarks    
#   
#   :author     [author::email]
#   :author     [author::company]
#   :date       01/23/13
#

# make sure this is being run as the main process
if ( __name__ in ( '__main__', '__builtin__' ) ):
	# since this file is being executed in the main scope, we need to register the tool package to the sys.path
	import blurdev
	blurdev.registerScriptPath( __file__ )
	
	# depending on our environment, Python initializes the script differently for scope, so try both methods:
	# importing from a sub-module
	try:
		from levelgruntdialog import LevelGruntDialog
	
	# importing from the main package
	except:
		from LevelGrunt.levelgruntdialog import LevelGruntDialog
	
	blurdev.launch( LevelGruntDialog )