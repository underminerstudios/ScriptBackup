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
varying highp vec4 varTexCoord3;



struct a2v {
    vec4 _position1;
    vec2 _texCoord11;
    vec2 _texCoord2;
    vec4 _tangent;
    vec4 _binormal;
    vec4 _normal;
};

struct v2f {
    vec4 _position;
    vec2 _texCoord1;
    vec2 _texCoord;
    vec3 _eyeVec;
};

v2f _ret_0;
vec4 _r0027;
vec4 _r0037;
vec4 _v0037;
vec3 _r0047;
attribute vec4 TANGENT;
attribute vec4 BINORMAL;
uniform mat4 matViewIT;
uniform mat4 matWorldViewProjectionT;
uniform mat4 matWorldIT;
uniform float DetailTile;

 // main procedure, the original name was av
void main()
{

    vec3 _osIVec;

    _r0027.x = dot(matWorldViewProjectionT[0], Vertex);
    _r0027.y = dot(matWorldViewProjectionT[1], Vertex);
    _r0027.z = dot(matWorldViewProjectionT[2], Vertex);
    _r0027.w = dot(matWorldViewProjectionT[3], Vertex);
    _v0037 = vec4(matViewIT[0].w, matViewIT[1].w, matViewIT[2].w, matViewIT[3].w);
    _r0037.x = dot(matWorldIT[0], _v0037);
    _r0037.y = dot(matWorldIT[1], _v0037);
    _r0037.z = dot(matWorldIT[2], _v0037);
    _osIVec = _r0037.xyz - Vertex.xyz;
    _r0047.x = dot(TANGENT.xyz, _osIVec);
    _r0047.y = dot(BINORMAL.xyz, _osIVec);
    _r0047.z = dot(Normal, _osIVec);
	_r0047 = normalize(_r0047);
    _ret_0._position = _r0027;
    _ret_0._texCoord1 = texcoord1.xy;
    _ret_0._texCoord = texcoord0.xy;
    _ret_0._eyeVec = _r0047;
    varTexCoord1.xy = texcoord0.xy;
    gl_Position = _r0027;
    varTexCoord2.xyz = _r0047;
    varTexCoord0.xy = texcoord1.xy;
	varTexCoord3.xy = (texcoord0.xy*DetailTile).xy;
    return;
} // main end
