--
--	\Title 		Vertex Colorist
--	
--	\Description	Génère des couleurs de vertex sur un des objets de maillage en utilisant une image bitmap et le canal UV2
--	\Description	
--	\Description	Generates vertex colors on a mesh object(s) using a bitmap and uv channel 2. 
--	
--	\Author		anisim.kalugin@gameloft.com - Gameloft - 8/17/2012
try(destroydialog dlg_vcolorist) catch()
dlg_vcolorist
(
	GL_Import_Lib #("GL_Get_GLBlurMXS")
	local working_dir = getFilenamePath (getThisScriptFilename())
	-- Get_GLBlurMXS_Lib() function gets installed at startup
	local glblurMSX_tools = (GL_Get_GLBlurMXS working_dir ) + "scripts\\"
	--RUN THE TOOL FROM glblurMSX_tools
	filein (glblurMSX_tools +  "VertexColorist.ms")
)
