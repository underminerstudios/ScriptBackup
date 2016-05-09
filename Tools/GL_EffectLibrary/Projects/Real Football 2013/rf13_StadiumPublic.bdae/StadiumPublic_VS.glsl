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



struct a2v {
    vec4 _position1;
    vec2 _texCoord2;
    vec2 _texCoord11;
    vec4 _normal;
    vec4 _binormal;
    vec4 _tangent;
};

struct v2f {
    vec4 _position;
    vec2 _texCoord;
    vec2 _texCoord1;
};

a2v _TMP2;
v2f _ret_0;
float _c0023;
float _a0023;
float _a0025;
float _x0027;
float _x0031;
float _c0033;
float _a0033;
float _x0037;
vec4 _r0041;
uniform float AnimPeriode;
uniform float Time;
uniform mat4 matWorldViewProjectionT;

 // main procedure, the original name was av
void main()
{

    float _MathMod_7616;
    float _MathRound_113;
    float _MathMod_7285;
    vec2 _MathVecConstuct_3437;

    _a0023 = Time*2.08333001E-001;
    _a0025 = _a0023/3.00000000E+001;
    _x0027 = abs(_a0025);
    _c0023 = fract(_x0027)*abs(3.00000000E+001);
    _MathMod_7616 = _a0023 < 0.00000000E+000 ? -_c0023 : _c0023;
    _x0031 = AnimPeriode*_MathMod_7616*4.00000000E+000;
    _MathRound_113 = floor(_x0031);
    _a0033 = _MathRound_113*2.50000000E-001;
    _x0037 = abs(_a0033);
    _c0033 = fract(_x0037)*abs(1.00000000E+000);
    _MathMod_7285 = _a0033 < 0.00000000E+000 ? -_c0033 : _c0033;
    _MathVecConstuct_3437 = vec2(0.00000000E+000, _MathMod_7285);
    _TMP2._texCoord2.xy = texcoord0.xy + _MathVecConstuct_3437;
    _r0041.x = dot(matWorldViewProjectionT[0], Vertex);
    _r0041.y = dot(matWorldViewProjectionT[1], Vertex);
    _r0041.z = dot(matWorldViewProjectionT[2], Vertex);
    _r0041.w = dot(matWorldViewProjectionT[3], Vertex);
    _ret_0._position = _r0041;
    _ret_0._texCoord = _TMP2._texCoord2;
    _ret_0._texCoord1 = texcoord1.xy;
    varTexCoord1.xy = texcoord1.xy;
    gl_Position = _r0041;
    varTexCoord0.xy = _TMP2._texCoord2;
    return;
} // main end
