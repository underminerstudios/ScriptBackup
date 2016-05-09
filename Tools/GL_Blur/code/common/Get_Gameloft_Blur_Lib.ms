
global GL_BLUR_MXS_LIB = "S:/code/maxscript/lib/"

function GL_Import_Lib _array =
(
	for _lib in _array do
	(
		fileIn (GL_BLUR_MXS_LIB + _lib + ".ms" )
	)
)