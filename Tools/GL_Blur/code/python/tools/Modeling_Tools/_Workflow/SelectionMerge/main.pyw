##
#   :namespace  mergeselectiondialog
#
#   :remarks    Merges selected object in to one
#   
#   :author     [author::anisim.kalugin@gameloft.com]
#   :author     [author::anisim.kalugin]
#   :date       07/22/13
#
from Py3dsMax import mxs # import max module
from  glmax.max3d import 	GLMax
glm = GLMax()

def mergeselectionExecute():
	oSel = mxs.selection
	mergedObj = glm.snapshotObjectMerge(oSel)
	mxs.delete(oSel)
	mergedObj.pivot = mergedObj.center
	mxs.select(mergedObj)
	mxs.completeRedraw()

# make sure this is being run as the main process
if ( __name__ in ( '__main__', '__builtin__' ) ):
	mergeselectionExecute()