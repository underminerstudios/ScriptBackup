#if defined(GL_ES)
precision mediump float;
precision mediump int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif


varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;



struct a2v {
    vec2 _texCoord1;
    vec4 _normal;
    vec4 _binormal;
    vec4 _tangent;
};

struct v2f {
    vec2 _texCoord;
};

uniform vec3 Color;
uniform sampler2D RandomPatternSampler;
uniform sampler2D TextureAlphaSampler;

 // main procedure, the original name was af
void main()
{

    vec4 _RandomPattern1;
    vec2 _MathVecConstuct_4421;
    vec4 _TextureAlpha1;
    float _input3;
    vec4 _ret;

    _RandomPattern1 = texture2D(RandomPatternSampler, varTexCoord0.xy);
    _TextureAlpha1 = texture2D(TextureAlphaSampler, varTexCoord1.xy);
    _input3 = _RandomPattern1.x*_TextureAlpha1.w;
    _ret = vec4(Color.x, Color.y, Color.z, 1.00000000E+000);
    _ret.w = _input3;
    gl_FragColor = _ret;
    return;
} // main end
