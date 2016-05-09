// -*- mode:c++; -*-

varying lowp vec2 varyingTexcoord0;
varying lowp vec3 varyingNormal;
varying lowp vec3 varyingLightDir;
varying lowp float varyingFogFactor;

uniform lowp sampler2D texture0;

uniform lowp vec3 IRON_CloudLightAmbColor;
uniform mediump vec4 LightColorMultiplied;



void main()
{
	lowp vec4 base = texture2D(texture0, varyingTexcoord0);
	lowp float t = dot(varyingNormal, varyingLightDir);
	mediump vec3 final = (IRON_CloudLightAmbColor+LightColorMultiplied.rgb*t)*base.rgb;
	gl_FragColor = vec4(final, base.a*varyingFogFactor);
}
