#if defined(GL_ES)
precision mediump float;
precision mediump int;
precision mediump sampler2D;
precision lowp samplerCube;
#endif

varying mediump vec4 varTexCoord0;
varying mediump vec4 varTexCoord1;
varying mediump vec4 varTexCoord2;

uniform sampler2D LogoTextureSampler;
uniform sampler2D WaveTextureSampler;
uniform sampler2D LightMapTexSampler;
uniform vec3 TeamColor;

 // main procedure, the original name was af
void main()
{
    vec4 LogoTexture1;
    vec3 LERP_TeamColor_Logo;
    vec4 WaveTexture1;
    vec4 LightMapTex1;
    vec3 input1;

    LogoTexture1 = texture2D(LogoTextureSampler, varTexCoord0.xy);
    LERP_TeamColor_Logo = TeamColor + LogoTexture1.w*(LogoTexture1.xyz - TeamColor);
	
    WaveTexture1 = texture2D(WaveTextureSampler, varTexCoord2.xy);
    LightMapTex1 = texture2D(LightMapTexSampler, varTexCoord1.xy);
    input1 = LERP_TeamColor_Logo*WaveTexture1.xyz*(LightMapTex1.xyz*1.5);
    gl_FragColor = vec4(input1.x, input1.y, input1.z, 1.0);

} // main end
