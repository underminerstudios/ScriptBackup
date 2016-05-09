// -*- mode:c++; -*-

uniform highp mat4 worldview;
uniform highp mat4 worldviewt;
uniform highp mat4 projection;

uniform lowp vec3 LightDirOs;

// globals
uniform highp vec4 IRON_CloudFogParams; // separated from fog color. (clouds may have different params)

attribute highp vec3 position;
attribute lowp vec2 texcoord0; // for billboard generate
attribute lowp vec2 texcoord1; // atlas
attribute mediump vec2 texcoord2; // size
attribute highp vec3 texcoord3; // lighting group center


varying lowp vec2 varyingTexcoord0;
varying lowp vec3 varyingNormal;
varying lowp vec3 varyingLightDir;
varying lowp float varyingFogFactor;


void main ()
{
	highp vec4 center = worldview*vec4(position, 1.0);
	highp vec4 p = center;
#define Up vec3(0.0, 1.0, 0.0)	
#define	Right vec3(1.0, 0.0, 0.0)
	// size in channel 2  (use atlas)
	mediump float BillboardSizeW = texcoord2.x;
	mediump float BillboardSizeH = -texcoord2.y;
	p.xyz += Up*(-texcoord0.y-0.5)*BillboardSizeH; // put to center
	p.xyz += Right*(texcoord0.x-0.5)*BillboardSizeW;
	gl_Position = projection*p;

    // Atlased texture
	varyingTexcoord0 = texcoord1;

    // Lighting
	highp vec3 groupCenter = texcoord3;
	groupCenter = (worldview*vec4(groupCenter, 1.0)).xyz; // to view
	varyingNormal = normalize(p.xyz-groupCenter);
	varyingLightDir = (worldview*vec4(LightDirOs, 0.0)).xyz;

	// Fog
	lowp float depth = dot(worldviewt[2], vec4(position, 1.0)); // col major here
	varyingFogFactor = clamp((depth-IRON_CloudFogParams[0])/(IRON_CloudFogParams[1]-IRON_CloudFogParams[0]), 
							 IRON_CloudFogParams[2], IRON_CloudFogParams[3]);
}

