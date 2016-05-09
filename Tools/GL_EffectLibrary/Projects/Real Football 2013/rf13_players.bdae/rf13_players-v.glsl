#if defined(GL_ES)
precision highp float;
precision highp int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif

attribute highp vec4 Vertex;
attribute mediump vec3 Normal;
attribute mediump vec4 texcoord0;
attribute mediump vec4 texcoord1;

varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;
varying mediump vec4 varTexCoord2;
varying mediump vec4 varTexCoord3;
varying mediump vec4 varTexCoord4;
varying mediump vec4 varTexCoord5;
varying mediump vec4 varTexCoord6;
varying highp vec4 varTexCoord7;

attribute vec4 TANGENT;
attribute vec4 BINORMAL;
uniform vec3 light0Pos;
uniform mat4 matWorldViewProjectionT;
uniform mat4 matWorldI;
uniform mat4 matViewIT;
uniform mat4 matWorldT;
uniform vec4 lightMapTexCoord;
uniform vec2 infoTexOffsets;

 // main procedure, the original name was v
void main()
{
	vec3 worldPos;
    worldPos.x = dot(matWorldT[0], Vertex);
    worldPos.y = dot(matWorldT[1], Vertex);
    worldPos.z = dot(matWorldT[2], Vertex);
	
	//compute lightVector
	varTexCoord0.xyz = normalize( light0Pos - worldPos );
	
	//compute eyeVec
	varTexCoord1.xyz = vec3(matViewIT[0].w, matViewIT[1].w, matViewIT[2].w) - worldPos.xyz;
	varTexCoord1.xyz = normalize(varTexCoord1.xyz);
	
    gl_Position.x = dot(matWorldViewProjectionT[0], Vertex);
    gl_Position.y = dot(matWorldViewProjectionT[1], Vertex);
    gl_Position.z = dot(matWorldViewProjectionT[2], Vertex);
    gl_Position.w = dot(matWorldViewProjectionT[3], Vertex);
	
	//copy tex coord
	varTexCoord2.xy = texcoord0.xy;
	
	//copy tangent, binormal and normal
	varTexCoord3.xyz = TANGENT.xyz;
	varTexCoord4.xyz = BINORMAL.xyz;
	varTexCoord5.xyz = Normal.xyz;
	
	//compute lightmap coord
	//Height 73,171 => 1/Height = 0,0136666165
	//Width 116,167 => 1/Width = 0,0086082966
	highp float lmCoefU = (worldPos.x * 0.0086082966) + 0.5;
	highp float lmCoefV = (-worldPos.y * 0.0136666165) + 0.5;
	
	varTexCoord6.x = lightMapTexCoord.x + lmCoefU*(lightMapTexCoord.z - lightMapTexCoord.x);
	varTexCoord6.y = lightMapTexCoord.y + lmCoefV*(lightMapTexCoord.w - lightMapTexCoord.y);
	
	//compute shirt player infos
	varTexCoord7.x = infoTexOffsets.x + texcoord1.x;
	varTexCoord7.y = infoTexOffsets.y + texcoord1.y;

} // main end
