#if defined(GL_ES)
precision mediump float;
precision mediump int;
precision lowp sampler2D;
precision lowp samplerCube;
#endif


varying mediump vec4 varTexCoord0;



struct a2v {
    vec2 _texCoord1;
    vec4 _normal;
    vec4 _binormal;
    vec4 _tangent;
};

struct v2f {
    vec2 _texCoord;
};

vec4 _ret_0;
uniform sampler2D TextureAtlasSampler;

 // main procedure, the original name was af
void main()
{

    vec4 _TextureAtlas1;
    vec4 _ret;

    _TextureAtlas1 = texture2D(TextureAtlasSampler, varTexCoord0.xy);
    _ret = vec4(_TextureAtlas1.x, _TextureAtlas1.y, _TextureAtlas1.z, 1.00000000E+000);
    _ret_0 = _ret;
    gl_FragColor = _ret;
    return;
} // main end
