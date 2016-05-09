#if defined(GL_ES)
precision mediump float;
precision mediump int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif


varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;



struct a2v {
    vec2 _texCoord2;
    vec2 _texCoord11;
    vec4 _normal;
    vec4 _binormal;
    vec4 _tangent;
};

struct v2f {
    vec2 _texCoord;
    vec2 _texCoord1;
};

vec4 _ret_0;
float _t0032;
vec3 _b0032;
float _TMP35;
float _x0036;
float _b0040;
uniform sampler2D TextureAtlasSampler;
uniform vec3 TeamColor;
uniform sampler2D LightMapSampler;
uniform float LightmapIntensity;

 // main procedure, the original name was af
void main()
{

    vec4 _TextureAtlas1;
    vec3 _MathLerp_7859;
    vec4 _LightMap1;
    vec3 _input1;
    vec4 _ret;

    _TextureAtlas1 = texture2D(TextureAtlasSampler, varTexCoord0.xy);
    _b0032 = _TextureAtlas1.xyz*TeamColor.xyz;
    _t0032 = (_TextureAtlas1.w - 5.00000000E-001)*2.00000000E+000;
    _MathLerp_7859 = _TextureAtlas1.xyz + _t0032*(_b0032 - _TextureAtlas1.xyz);
    _LightMap1 = texture2D(LightMapSampler, varTexCoord1.xy);
    _input1 = _MathLerp_7859*_LightMap1.xyz*(_LightMap1.xyz + LightmapIntensity);
    _x0036 = _TextureAtlas1.w*2.00000000E+000;
    _b0040 = min(1.00000000E+000, _x0036);
    _TMP35 = max(0.00000000E+000, _b0040);
    _ret = vec4(_input1.x, _input1.y, _input1.z, 1.00000000E+000);
    _ret.w = _TMP35;
    _ret_0 = _ret;
    gl_FragColor = _ret;
    return;
} // main end
