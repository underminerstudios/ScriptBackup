theFile = pathConfig.removePathLeaf(getSourceFileName()) + "\\paths.txt"
thePropLibrary = (pathconfig.normalizepath (getINIsetting "$userscripts\\GLL_Launcher\\profile.ini" "Depot" "Path")) + "\\MAXScript\\Madrid\\Universal MaxScripts\\Prop Library\\PropLibrary.ms"
GLOBAL GLB_GL_PROP_LIBRARY_PATHS = (dotnetClass "System.IO.File").ReadAllLines theFile
filein thePropLibrary