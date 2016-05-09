#!/usr/bin/env python

import _winreg, os, os.path, re, sys, string
import pdb, subprocess 
from optparse import OptionParser

VERSION = 0.1

class ConverterError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

def ReplaceIdentifier( identifier, repl, string ):
    # Note : Using (\b|\W) instead of r"\b" at the end of pattern to handle case where identifier contains array brackets.
    return re.subn( r"\b" + identifier + r"(\b|\W)", repl + r"\1", string )

class Cg2GLSLES:
    """
    Convert a Cg file to GLSL ES based on the result of the Cg2GLSL from cgc.
    On error, a ConverterError is raised. 
    """
    _verbose = False
    _keepCgcComent = False
    _useAlphaTest = False
    
    _InFilename = ""
    _OutFilename = ""
    _cgcpath = ""
    _profile = ""
    _entry = ""
    _defines = ""
    _result = ""
    
    _shaderSemantics = dict()
    _shaderVarTypes = dict()
    _shaderVarNameInGLSL = dict()
    
    _semanticToGlitchUniform    = dict()
    _GLSLBuiltin2GLSLES   = dict()
    _GLSLBuiltin2GLSLESVertex = dict()
    _GLSLBuiltin2GLSLESFragment = dict()
    
    #_GLSL_ES_VarType = [ "bool", "int", "float", "vec2", "vec3", "vec4", "ivec2", \
    #                     "ivec3", "ivec4", "bvec2", "bvec3", "bvec4", "mat2", \
    #                     "mat3", "mat4", "sampler2D", "samplerCube" ]
    
    #---- Constructor ----------------------------------------------------------
    def __init__(self):
        # Map some semantic to Glitch standard names (when needed)
        # Here we change all the matrices to request the transposed as CGC's way
        # to do the matrix mutliplication break us
        self._semanticToGlitchUniform["worldmatrix"]            = ("matWorldT",                "mat4")
        self._semanticToGlitchUniform["World"]                  = ("matWorldT",                "mat4")
        self._semanticToGlitchUniform["matworld"]               = ("matWorldT",                "mat4")
        self._semanticToGlitchUniform["world"]                  = ("matWorldT",                "mat4")
        self._semanticToGlitchUniform["worldi"]                 = ("matWorldIT",               "mat4")
        self._semanticToGlitchUniform["worldinv"]               = ("matWorldIT",               "mat4")
        self._semanticToGlitchUniform["worldinverse"]           = ("matWorldIT",               "mat4")
        self._semanticToGlitchUniform["matmodelit"]             = ("matWorldI",                "mat4")
        self._semanticToGlitchUniform["matworldit"]             = ("matWorldI",                "mat4")
        self._semanticToGlitchUniform["medelit"]                = ("matWorldI",                "mat4")
        self._semanticToGlitchUniform["modelinversetransposed"] = ("matWorldI",                "mat4")
        self._semanticToGlitchUniform["worldit"]                = ("matWorldI",                "mat4")
        self._semanticToGlitchUniform["worldinversetranspose"]  = ("matWorldI",                "mat4")
        self._semanticToGlitchUniform["matview"]                = ("matViewT",                 "mat4")
        self._semanticToGlitchUniform["matviewi"]               = ("matViewIT",                "mat4")
        self._semanticToGlitchUniform["matviewinv"]             = ("matViewIT",                "mat4")
        self._semanticToGlitchUniform["matviewinverse"]         = ("matViewIT",                "mat4")
        self._semanticToGlitchUniform["matviewit"]              = ("matViewI",                 "mat4")
        self._semanticToGlitchUniform["matviewinversetranspose"]= ("matViewI",                 "mat4")
        self._semanticToGlitchUniform["view"]                   = ("matViewT",                 "mat4")
        self._semanticToGlitchUniform["viewi"]                  = ("matViewIT",                "mat4")
        self._semanticToGlitchUniform["viewinv"]                = ("matViewIT",                "mat4")
        self._semanticToGlitchUniform["viewinverse"]            = ("matViewIT",                "mat4")
        self._semanticToGlitchUniform["viewit"]                 = ("matViewI",                 "mat4")
        self._semanticToGlitchUniform["viewinversetranspose"]   = ("matViewI",                 "mat4")
        self._semanticToGlitchUniform["worldview"]              = ("matWorldViewT",            "mat4")
        self._semanticToGlitchUniform["worldviewinv"]           = ("matWorldViewIT",           "mat4")
        self._semanticToGlitchUniform["worldviewinverse"]       = ("matWorldViewIT",           "mat4")
        self._semanticToGlitchUniform["worldviewinversetranspose"] = ("matWorldViewI",         "mat4")
        self._semanticToGlitchUniform["worldviewprojection"]    = ("matWorldViewProjectionT",  "mat4")
        self._semanticToGlitchUniform["wvp"]                    = ("matWorldViewProjectionT",  "mat4")
        self._semanticToGlitchUniform["viewprojection"]         = ("matViewProjectionT",       "mat4")
        self._semanticToGlitchUniform["matviewprojection"]      = ("matViewProjectionT",       "mat4")
        self._semanticToGlitchUniform["viewprojectiontransposed"] = ("matViewProjection",      "mat4")
        self._semanticToGlitchUniform["matviewprojectiont"]     = ("matViewProjection",        "mat4")

        # Map between GLSL's built-in to GLSL|ES Vertex attributes
        self._GLSLBuiltin2GLSLESVertex["gl_Vertex"]                   = ("Vertex",                "attribute", "vec4", "highp")
        self._GLSLBuiltin2GLSLESVertex["gl_Normal"]                   = ("Normal",                "attribute", "vec3", "mediump")
        self._GLSLBuiltin2GLSLESVertex["gl_Color"]                    = ("Color",                 "attribute", "vec4", "lowp")
        self._GLSLBuiltin2GLSLESVertex["gl_SecondaryColor"]           = ("SecondaryColor",        "attribute", "vec4", "lowp")
        for i in range(7):
            self._GLSLBuiltin2GLSLESVertex["gl_MultiTexCoord"+str(i)] = ("texcoord" + str(i),     "attribute", "vec4", "mediump")
            
        # Map between GLSL's built-in to GLSL|ES fragment input
        self._GLSLBuiltin2GLSLESFragment["gl_Color"]              = ("varFrontColor",         "varying", "vec4", "lowp", "varBackColor" )

        # Map between GLSL's built-in to GLSL|ES Varying data
        self._GLSLBuiltin2GLSLES["gl_FrontColor"]               = ("varFrontColor",         "varying", "vec4", "lowp")
        self._GLSLBuiltin2GLSLES["gl_BackColor"]                = ("varBackColor",          "varying", "vec4", "lowp")
        self._GLSLBuiltin2GLSLES["gl_FrontSecondaryColor"]      = ("varFrontSecondaryColor","varying", "vec4", "lowp")
        self._GLSLBuiltin2GLSLES["gl_BackSecondaryColor"]       = ("varBackSecondaryColor", "varying", "vec4", "lowp")
        self._GLSLBuiltin2GLSLES["gl_FogFragCoord"]             = ("varFogFragColor",       "varying", "vec4", "mediump")
        for i in range(24):
            self._GLSLBuiltin2GLSLES["gl_TexCoord\\["+str(i)+"\\]"] = ("varTexCoord"+str(i),    "varying", "vec4", "mediump")

    #---- Setters --------------------------------------------------------------
    def beVerbose(self):
        self._verbose = True

    def keepCgcComment(self):
        self._keepCgcComent = True

    def setShaderEntyPoint(self, entry):
        self._entry = entry

    def setVertexConvert(self):
        self._profile = "glslv"

    def setFragmentConvert(self):
        self._profile = "glslf"

    def setInputFile(self, inputFile):
        # Test if we can open the input file in read mode
        try:
            InFile = open(inputFile, 'r')
        except:
            raise ConverterError("Error, the input file '" + inputFile + "' can't be opened for reading...\n")
        InFile.close()
        self._InFilename = inputFile

    def setOutputFile(self, outputFile):
        # Test if we can open the output file in write mode
        try:
            OutFile = open(outputFile, 'w')
        except:
            raise ConverterError("Error, the output file '" + outputFile + "' can't be opened for writing...\n")
        OutFile.close()
        self._OutFilename = outputFile
    
    def setCgcPath(self, cgcpath):
        if not os.path.exists(cgcpath):
            raise ConverterError("Error, can't locate the cgc executable, make sure to run Glitch's setup.exe...\n")
        self._cgcpath = cgcpath

    def setCgcDefines(self, defineList):
        for define in defineList:
            self._defines += " -D"+define
            
    def UseAlphaTest(self, alpha):
        self._useAlphaTest = alpha

    #---- Converter Methods-----------------------------------------------------
    def convert(self):
        self._cgcConvert()
        self._ExtractCgcInformation()
        self._FixCgcVarNames()
        
        self._GLSL2GLSLES()
        
        return self._result

    def writeToOutputFile(self):
        file = open(self._OutFilename, 'w')
        file.write(self._result)
        file.close()

    #---- Private methods ------------------------------------------------------
    def _cgcConvert(self):
        if len(self._cgcpath) == 0:
            raise ConverterError("Error, missing cgc path (need to call 'setCgcPath') ...\n")
        if len(self._InFilename) == 0:
            raise ConverterError("Error, missing input Cg file (need to call 'setInputFile')...\n")
        if len(self._entry) == 0:
            raise ConverterError("Error, missing shader entry point (need to call 'setShaderEntyPoint')...\n")
        if len(self._profile) == 0:
            raise ConverterError("Error, missing shader type (need to call 'setVertexConvert' or 'setFragmentConvert')...\n")
            
        cmd = self._cgcpath + " " + self._InFilename + " -entry " + self._entry + " -profile " + self._profile + self._defines
        self._result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.read()
        
        # cgc output the file name at the begining, so we remove the first line
        self._result = string.join(self._result.split("\n")[1:], "\n")
        #print self._result

    def _ExtractCgcInformation(self):
        #Check for lines like : //var float4x4 wvp : WorldViewProjection : _wvp[0], 4 : -1 : 1
        varCheck = re.compile("\/\/var (\w+\d*x?\d*) (\w+)(\[\d+\])?(\.\w+)? : (\w*) : ([\w_\[\]\d]+)(\._\w+)?(,\s)?(\d*) : (-?\w*\d*) : (-?\w*\d*)")
        for line in self._result.split("\n"):
            result = varCheck.match(line)
            if result != None:
                # Find the variable type
                self._shaderVarTypes[result.group(2)] = result.group(1)
                if self._verbose:
                    print "Var : " + result.group(1) + " " + result.group(2),

                # Find the variable sematic if avaliable
                if len(result.group(5)) > 0:
                    self._shaderSemantics[result.group(2)] = result.group(5)
                    if self._verbose:
                        print " : " + result.group(5),

                # Find the variable name used in the GLSL output code (if used)
                if len(result.group(6)) > 0:
                    self._shaderVarNameInGLSL[result.group(2)] = result.group(6)
                    if self._verbose:
                        print " --> " + result.group(6),
                
                if self._verbose:
                    print ""

    def _GLSL2GLSLES(self):
        headerToAdd = ""
        functionsToAdd = ""
        
        # Fix the GLSL built-in Vertex input and varying
        for item in self._GLSLBuiltin2GLSLES:
            self._result, replaceCount = ReplaceIdentifier( item, self._GLSLBuiltin2GLSLES[item][0], self._result )
            if replaceCount > 0:
                headerToAdd += self._GLSLBuiltin2GLSLES[item][1] + " " + self._GLSLBuiltin2GLSLES[item][3] + " " + self._GLSLBuiltin2GLSLES[item][2] + " " + self._GLSLBuiltin2GLSLES[item][0] + ";\n"
                
                if item == "gl_BackColor":
                    print "WARNING : gl_BackColor used, but won't work as the fragment shader will only look for the front color."
                # DEACTIVATED : check for frontcolor is too slow in the fragment shader
                #if we don't have a Backcolor but we have a front color, add it
                # as a copy of the front
#                if item == "gl_FrontColor" and self._profile == "glslv" and self._result.find("gl_BackColor") == -1:
#                    headerToAdd += self._GLSLBuiltin2GLSLES[item][1] + " " + self._GLSLBuiltin2GLSLES[item][3] + " " + self._GLSLBuiltin2GLSLES[item][2] + " varBackColor;\n"
#                    
#                    # Locate the line where we affect the front color and add a 
#                    # second for the back color
#                    lines = self._result.split("\n")
#                    lineNb = 0
#                    lineEnd = len(lines)
#                    while lineNb < lineEnd:
#                        line =  lines[lineNb]
#                        if line.find(self._GLSLBuiltin2GLSLES[item][0]) != -1:
#                            newLine = line.replace(self._GLSLBuiltin2GLSLES[item][0], "varBackColor")
#                            oldLines = lines
#                            lines = oldLines[:lineNb]
#                            lines.append(newLine)
#                            lines.extend(oldLines[lineNb:])
#                            lineEnd += 1
#                            lineNb += 1
#                        lineNb += 1
#                    self._result = "\n".join(lines)
                    
        # Fix the GLSL built-in Vertex vars
        if self._profile == "glslv":
            for item in self._GLSLBuiltin2GLSLESVertex:
                self._result, replaceCount = ReplaceIdentifier( item, self._GLSLBuiltin2GLSLESVertex[item][0], self._result )
                if replaceCount > 0:
                    headerToAdd += self._GLSLBuiltin2GLSLESVertex[item][1] + " " + self._GLSLBuiltin2GLSLESVertex[item][3] + " " + self._GLSLBuiltin2GLSLESVertex[item][2] + " " + self._GLSLBuiltin2GLSLESVertex[item][0] + ";\n"
        
        # Fix the GLSL built-in fragment vars
        if self._profile == "glslf":
            
            for item in self._GLSLBuiltin2GLSLESFragment:
                self._result, replaceCount = ReplaceIdentifier( item, self._GLSLBuiltin2GLSLESFragment[item][0], self._result )
                if replaceCount > 0:
                     # DEACTIVATED : check for frontcolor is too slow in the fragment shader
#                    # GL_COLOR is a special one...  we have to find the right face...
#                    if item == "gl_Color":
#                        functionsToAdd += self._GLSLBuiltin2GLSLESFragment[item][3] + " vec4 getColor()\n{\n\treturn ( gl_FrontFacing ? "+self._GLSLBuiltin2GLSLESFragment[item][0]+" : "+self._GLSLBuiltin2GLSLESFragment[item][4]+" );\n}\n"
#                        headerToAdd += self._GLSLBuiltin2GLSLESFragment[item][1] + " " + self._GLSLBuiltin2GLSLESFragment[item][3] + " " + self._GLSLBuiltin2GLSLESFragment[item][2] + " " + self._GLSLBuiltin2GLSLESFragment[item][0] + ";\n"
#                        headerToAdd += self._GLSLBuiltin2GLSLESFragment[item][1] + " " + self._GLSLBuiltin2GLSLESFragment[item][3] + " " + self._GLSLBuiltin2GLSLESFragment[item][2] + " " + self._GLSLBuiltin2GLSLESFragment[item][4] + ";\n"
#                        self._result = self._result.replace(item, "getColor()")
#                    else:
                    headerToAdd += self._GLSLBuiltin2GLSLESFragment[item][1] + " " + self._GLSLBuiltin2GLSLESFragment[item][3] + " " + self._GLSLBuiltin2GLSLESFragment[item][2] + " " + self._GLSLBuiltin2GLSLESFragment[item][0] + ";\n"
        
        data = self._result.replace("\r", "")
        lineList = data.split("\n")
        endOfCgcComments = 0
        for line in lineList:
            if len(line) == 0 or line[0] != "/" or line[1] != "/":
                break
            endOfCgcComments = endOfCgcComments + 1
        
        commentBlock = "\n".join(lineList[0:endOfCgcComments])
        codeBlock = "\n".join(lineList[endOfCgcComments:])
        
        # Fix the "vec4 matrix[4];" -> "mat4 matrix;"
        codeBlock = re.sub("vec4 (\S+)\[4\];", "mat4 \g<1>;", codeBlock)
        
        # Check for unsupported GLSL built-ins
        if self._profile == "glslf":
            if codeBlock.find("gl_FragDepth") != -1:
                print "WARNING : gl_FragDepth is present (and can't be emulated) in GLSL ES"
                codeBlock.repalce("gl_FragDepth","//gl_FragDepth")
            if codeBlock.find("gl_FogFragCoord") != -1:
                print "WARNING : gl_FogFragCoord is present (and can't be emulated) in GLSL ES"
                codeBlock.repalce("gl_FogFragCoord","//gl_FogFragCoord")
            
            # Add Alpha test if requested
            if self._useAlphaTest:
                varCheck = re.compile(".*gl_FragColor\s*=\s*(.*);")
                
                headerToAdd += "uniform mediump float AlphaRef;\n"
        
                # Locate the line where we affect the front color and add a 
                # second for the back color
                print self._result
                lines = codeBlock.split("\n")
                lineNb = 0
                lineEnd = len(lines)
                while lineNb < lineEnd:
                    line =  lines[lineNb]
                    result = varCheck.match(line)
                    print result
                    if result != None:
                        newLine = "\n    if( ("+result.group(1) + ").a < AlphaRef)\n        discard;\n"
                        print newLine
                        oldLines = lines
                        lines = oldLines[:lineNb]
                        lines.append(newLine)
                        lines.extend(oldLines[lineNb:])
                        print lines
                        lineEnd += 1
                        lineNb += 1
                    lineNb += 1
                codeBlock = "\n".join(lines)
                print self._result
            
        
        header = headerToAdd.split("\n")
        header.sort()
        headerToAdd = "\n".join(header) + "\n\n" + functionsToAdd
        
        precisionQualifiers = "#if defined(GL_ES)\n"
        # Try to fix all variables to have a default precision qualifier
        if self._profile == "glslv":
            precisionQualifiers += "precision highp float;\n"
            precisionQualifiers += "precision highp int;\n"
            precisionQualifiers += "precision lowp sampler2D;\n"
            precisionQualifiers += "precision lowp samplerCube;\n"
        elif self._profile == "glslf":

            precisionQualifiers += "precision mediump float;\n"
            precisionQualifiers += "precision mediump int;\n"
            precisionQualifiers += "precision lowp sampler2D;\n"
            precisionQualifiers += "precision lowp samplerCube;\n"
        precisionQualifiers += "#endif\n"
        
        if self._keepCgcComent:
            self._result = commentBlock + "\n"
        else:
            self._result = ""
        self._result += precisionQualifiers + "\n" + headerToAdd + "\n" + codeBlock
    
    
    def _FixCgcVarNames(self):
        """
        Remove the _ added to each variable by cgc and fix some names based on the sementics :)
        """
        removeBrackets = re.compile("\[\d+\]")
        for varname in self._shaderVarNameInGLSL:
            nameInCg = removeBrackets.sub("",self._shaderVarNameInGLSL[varname])
            goodname = varname
            if varname in self._shaderSemantics:
                sem = self._shaderSemantics[varname]
                if str(sem).lower() in self._semanticToGlitchUniform:
                    goodname = self._semanticToGlitchUniform[str(sem).lower()][0]
            
            if self._verbose:
                print "Change : " + nameInCg + " to " + goodname
            
            self._result, replaceCount = ReplaceIdentifier( nameInCg, goodname, self._result )

    

if __name__ == '__main__':
    parser = OptionParser(version="%prog "+str(VERSION))
    parser.add_option("-i",  dest="input", help="Input Cg file", default="")
    parser.add_option("-o",  dest="output", help="Output GLSL ES file", default="output.glsl")
    parser.add_option("-e",  dest="entry", help="Entry point for the shader", default="")
    parser.add_option("-d",  dest="defines", help="defines for the shader conversion (semi-clolon separated)", default="")
    parser.set_defaults(type="x")
    parser.add_option("-v",  help="Convert a vertex program", action="store_const", dest="type", const="v")
    parser.add_option("-f",  help="Convert a fragment(pixel) program", action="store_const", dest="type", const="f")
    parser.add_option("-k",  help="Keep cgc's comment block", action="store_true", dest="keepComment", default=False)
    parser.add_option("-a",  help="Add AlphaTest to the shader", action="store_true", dest="useAlphaTest", default=False)
    parser.add_option("--verbose",  help="make lots of noise", action="store_true", dest="verbose", default=False)
    (options, args) = parser.parse_args(sys.argv)
    
    if len(args) != 1:
        print "Error : unknown arguments ( ",
        first = True
        for arg in args[1:]:
            if not first:
                print ", ",
            else:
                first = False
            print arg,
        print " ) will be ignored."
        
    
    try:
        converter = Cg2GLSLES()
        
        if options.verbose:
            converter.beVerbose()

        if options.keepComment:
            converter.keepCgcComment()
            
        converter.UseAlphaTest(options.useAlphaTest)
    
        if options.type == "v":
            converter.setVertexConvert()
        elif options.type == "f":
            converter.setFragmentConvert()
        else:
            raise ConverterError("Error : you must specify if you want to convert a vertex or a fragment program (-v or -f)\n")

        if options.entry == "":
            raise ConverterError("Error : you must specify the shader entry point (-e entrypoint)\n")
        converter.setShaderEntyPoint(options.entry)
        
        if options.input == "":
            raise ConverterError("Error : you must specify an input file (-i filename)\n")
        else:
            converter.setInputFile(options.input)
        converter.setOutputFile(options.output)

        if len(options.defines) > 0:
            converter.setCgcDefines(options.defines.split(";"))
        
        converter.setCgcPath( os.path.join(os.path.dirname( __file__ ), "cgc", "cgc.exe") )
        
        result = converter.convert()
        if options.verbose:
            print result
            
        converter.writeToOutputFile()
        
    except ConverterError, error:
        sys.stderr.write(error.value)
        sys.exit(1)
        
        