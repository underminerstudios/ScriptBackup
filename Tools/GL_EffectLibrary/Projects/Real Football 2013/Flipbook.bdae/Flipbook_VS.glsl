#if defined(GL_ES)
precision highp float;
precision highp int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif


attribute highp vec4 Vertex;
attribute mediump vec4 texcoord0;
varying mediump vec4 varTexCoord0;



struct a2v {
    vec4 _position1;
    vec2 _texCoord1;
    vec4 _normal;
    vec4 _binormal;
    vec4 _tangent;
};

struct v2f {
    vec4 _position;
    vec2 _texCoord;
};

v2f _ret_0;
float _x0023;
float _c0025;
float _x0029;
float _c0033;
float _x0037;
vec4 _r0041;
uniform float UIConst_608;
uniform float UIConst_116;
uniform float FramesPerSecond;
uniform float Time;
uniform mat4 matWorldViewProjectionT;

 // main procedure, the original name was av
void main()
{

    vec2 _ScaleCoordinates;
    float _speed;
    float _index;
    float _rowCount;
    vec2 _offsetVector;
    vec2 _MathVecConstuct_2074;
    float _MathMod_1510;
    float _MathMod_4511;
    vec2 _MathVecConstuct_5573;

    _ScaleCoordinates = vec2(1.00000000E+000/UIConst_608, 1.00000000E+000/UIConst_116);
    _speed = FramesPerSecond*Time*2.08333001E-001;
    _index = floor(_speed);
    _x0023 = _speed/UIConst_608;
    _rowCount = floor(_x0023);
    _offsetVector = vec2(_index, _rowCount);
    _MathVecConstuct_2074 = _ScaleCoordinates*(_offsetVector + texcoord0.xy);
    _x0029 = abs(_MathVecConstuct_2074.x);
    _c0025 = fract(_x0029)*abs(1.00000000E+000);
    _MathMod_1510 = _MathVecConstuct_2074.x < 0.00000000E+000 ? -_c0025 : _c0025;
    _x0037 = abs(_MathVecConstuct_2074.y);
    _c0033 = fract(_x0037)*abs(1.00000000E+000);
    _MathMod_4511 = _MathVecConstuct_2074.y < 0.00000000E+000 ? -_c0033 : _c0033;
    _MathVecConstuct_5573 = vec2(_MathMod_1510, _MathMod_4511);
    _r0041.x = dot(matWorldViewProjectionT[0], Vertex);
    _r0041.y = dot(matWorldViewProjectionT[1], Vertex);
    _r0041.z = dot(matWorldViewProjectionT[2], Vertex);
    _r0041.w = dot(matWorldViewProjectionT[3], Vertex);
    _ret_0._position = _r0041;
    _ret_0._texCoord = _MathVecConstuct_5573;
    gl_Position = _r0041;
    varTexCoord0.xy = _MathVecConstuct_5573;
    return;
} // main end
