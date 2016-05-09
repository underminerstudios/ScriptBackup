if not doesfileExist ("$userscripts\\UVPipe\\UVPipe.ms") do
(
	filein (pathConfig.removePathLeaf(getSourceFileName()) + "\\UVPipe.mzp")
)
filein ("$userscripts\\UVPipe\\UVPipe.ms")