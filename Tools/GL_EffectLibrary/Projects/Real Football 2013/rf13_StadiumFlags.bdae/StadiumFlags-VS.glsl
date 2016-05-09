#if defined(GL_ES)
precision highp float;
precision highp int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif

attribute highp vec4 Vertex;
attribute mediump vec4 texcoord0;
attribute mediump vec4 texcoord1;
varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;
varying mediump vec4 varTexCoord2;

uniform mat4 matWorldViewProjectionT;
uniform vec4 LogoTileOffset;
uniform float Time;

 // main procedure, the original name was av
void main()
{
	vec4 outVertex;
	
	float TimeMod = mod(Time*2.08333001E-001,30.0) * 0.2;

    outVertex.x = dot(matWorldViewProjectionT[0], Vertex);
    outVertex.y = dot(matWorldViewProjectionT[1], Vertex);
    outVertex.z = dot(matWorldViewProjectionT[2], Vertex);
    outVertex.w = dot(matWorldViewProjectionT[3], Vertex);
	
    varTexCoord0.xy = (texcoord0.xy * LogoTileOffset.xy + LogoTileOffset.zw).xy;
    varTexCoord1.xy = texcoord1.xy;
	varTexCoord2.xy = (texcoord0.xy + TimeMod).xy;
    gl_Position = outVertex;

} // main end
