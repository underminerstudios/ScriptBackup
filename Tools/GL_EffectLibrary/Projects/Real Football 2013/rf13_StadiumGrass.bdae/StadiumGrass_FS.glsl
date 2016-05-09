#if defined(GL_ES)
precision mediump float;
precision mediump int;
precision mediump sampler2D;
precision lowp samplerCube;
#endif


varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;
varying mediump vec4 varTexCoord2;
varying mediump vec4 varTexCoord3;


struct a2v {
    vec2 _texCoord11;
    vec2 _texCoord2;
    vec4 _tangent;
    vec4 _binormal;
    vec4 _normal;
};

struct v2f {
    vec2 _texCoord1;
    vec2 _texCoord;
    vec3 _eyeVec;
};

vec4 _ret_0;
float _x0046;
float _TMP47;
float _b0052;
float _TMP53;
float _x0054;
float _b0058;
vec3 _a0060;
vec3 _b0060;
uniform float LightmapIntensity;
uniform sampler2D LightMapSampler;
uniform sampler2D DiffusemapSampler;
uniform float FresnelIntensity;
uniform float PatternMaskStrength;
uniform float FresnelMultiply;
uniform sampler2D DetailmapSampler;

 // main procedure, the original name was af
void main()
{

    vec4 _LightMap1;
    vec4 _Diffusemap1;
    vec3 _MathLerp_2302;
    vec4 _Detailmap1;
    vec3 _input1;
    vec4 _ret;

    _LightMap1 = texture2D(LightMapSampler, varTexCoord0.xy);
    _Diffusemap1 = texture2D(DiffusemapSampler, varTexCoord1.xy);
    _x0046 = dot(varTexCoord2.xyz, vec3( 0.00000000E+000, 0.00000000E+000, 1.00000000E+000));
    _b0052 = min(1.00000000E+000, _x0046);
    _TMP47 = max(0.00000000E+000, _b0052);
    _x0054 = _LightMap1.w*PatternMaskStrength + _TMP47*FresnelMultiply;
    _b0058 = min(1.00000000E+000, _x0054);
    _TMP53 = max(0.00000000E+000, _b0058);
    _a0060 = _Diffusemap1.xyz*FresnelIntensity;
    _b0060 = _Diffusemap1.xyz - _LightMap1.w;
    _MathLerp_2302 = _a0060 + _TMP53*(_b0060 - _a0060);
    _Detailmap1 = texture2D(DetailmapSampler, varTexCoord3.xy);
    _input1 = (LightmapIntensity*_LightMap1.xyz)*((_MathLerp_2302*_Detailmap1.xyz)*2.00000000E+000);
    _ret = vec4(_input1.x, _input1.y, _input1.z, 1.00000000E+000);
    _ret_0 = _ret;
    gl_FragColor = _ret;
    return;
} // main end
