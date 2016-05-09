#if defined(GL_ES)
precision highp float;
precision highp int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif


attribute highp vec4 Vertex;
attribute mediump vec4 texcoord0;
varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;



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

a2v _TMP2;
v2f _ret_0;
float _c0023;
float _a0023;
float _a0025;
float _x0027;
float _x0033;
vec4 _r0035;
uniform mediump float RandomTiles;
uniform float FramesPerSecond;
uniform float Time;
uniform mat4 matWorldViewProjectionT;

 // main procedure, the original name was av
void main()
{

    vec2 _ScaleCoordinates;
    float _MathMod_48;
    float _speed;
    float _index;
    float _rowCount;
    vec2 _offsetVector;

	float oneOnRandomTiles = 1.00000000E+000/RandomTiles;
    _ScaleCoordinates = vec2( oneOnRandomTiles,  oneOnRandomTiles);
    _a0023 = Time*2.08333001E-001;
    _a0025 = _a0023/3.00000000E+001;
    _x0027 = abs(_a0025);
    _c0023 = fract(_x0027)*abs(3.00000000E+001);
    _MathMod_48 = _a0023 < 0.00000000E+000 ? -_c0023 : _c0023;
    _speed = FramesPerSecond*_MathMod_48;
    _index = floor(_speed);
    _x0033 = _speed/RandomTiles;
    _rowCount = floor(_x0033);
    _offsetVector = vec2(_index, _rowCount);
    
    varTexCoord1.xy = (_offsetVector + texcoord0.xy);
    _TMP2._texCoord1.xy = _ScaleCoordinates*varTexCoord1.xy;
    
    _r0035.x = dot(matWorldViewProjectionT[0], Vertex);
    _r0035.y = dot(matWorldViewProjectionT[1], Vertex);
    _r0035.z = dot(matWorldViewProjectionT[2], Vertex);
    _r0035.w = dot(matWorldViewProjectionT[3], Vertex);
    _ret_0._position = _r0035;
    _ret_0._texCoord = _TMP2._texCoord1;
    gl_Position = _r0035;
    varTexCoord0.xy = _TMP2._texCoord1;
    
    return;
} // main end
