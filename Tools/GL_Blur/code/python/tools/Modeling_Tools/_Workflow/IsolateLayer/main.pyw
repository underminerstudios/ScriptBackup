##
#   :namespace  isolatelayerdialog
#
#   :remarks    Isolates layers based on selected objects
#   
#   :author     [author::anisim.kalugin@gameloft.com]
#   :author     [author::anisim.kalugin]
#   :date       07/22/13
#
from Py3dsMax import mxs # import max module
from  glmax.max3d import 	GLMax
glm = GLMax()

def isolatelayerExecute():
	glm.isolateLayersBySelected()
	mxs.completeRedraw()

# make sure this is being run as the main process
if ( __name__ in ( '__main__', '__builtin__' ) ):
	isolatelayerExecute()