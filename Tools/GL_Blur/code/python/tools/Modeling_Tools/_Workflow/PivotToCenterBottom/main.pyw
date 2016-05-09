##
#   :namespace  pivottocenterbottomdialog
#
#   :remarks    Places pivot on the center bottom of the bounding box.
#   
#   :author     [author::anisim.kalugin@gameloft.com]
#   :author     [author::anisim.kalugin]
#   :date       07/22/13
#
from Py3dsMax import mxs # import max module
from  glmax.max3d import 	GLMax
glm = GLMax()

def pivottocenterbottomExecute():
	oSel = mxs.selection
	for obj in oSel:
		if mxs.superClassOf(obj) == mxs.GeometryClass:
			obj.pivot = mxs.point3(obj.center.x, obj.center.y, obj.min.z)
	mxs.completeRedraw()

# make sure this is being run as the main process
if ( __name__ in ( '__main__', '__builtin__' ) ):
	pivottocenterbottomExecute()