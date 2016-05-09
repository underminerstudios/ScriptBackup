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
varying mediump vec4 varTexCoord4;
varying mediump vec4 varTexCoord5;
varying mediump vec4 varTexCoord6;
varying highp vec4 varTexCoord7;

uniform vec3 AmbientColor_Node;
uniform sampler2D NormalMapSampler;
uniform mat4 matViewI;
uniform sampler2D SphereMapSampler;
uniform float SphereMapIntensity;
uniform sampler2D DiffuseMapSampler;
uniform float DiffuseMapIntensity;
uniform vec3 SpecularColor_Node;
uniform float Glossiness_Node;
uniform vec4 light0Color;
uniform sampler2D lightMapSampler;
uniform sampler2D playerInfosTex;

 // main procedure, the original name was f
void main()
{
	vec4 normalMap;
	vec4 sphereMap;
	vec4 diffuseMap;
	vec4 lightMap;
	vec4 playerInfos;
	vec3 tgSpaceNormal;
	
	vec3 sphereDiffValue;
	vec3 colorValue;
	vec3 specularColor;
    vec3 light0;
	vec3 halfVector;
	
	vec2 sphereUVs;
	
	float NdotL1;
	float NdotH1;
	
    normalMap = texture2D(NormalMapSampler, varTexCoord2.xy);
    normalMap.xyz = normalMap.xyz*2.0 - 1.0;
	
	lightMap = texture2D(lightMapSampler,varTexCoord6.xy);
	playerInfos = texture2D(playerInfosTex, varTexCoord7.xy);
	
    tgSpaceNormal = varTexCoord5.xyz*normalMap.z + normalMap.x*varTexCoord3.xyz + normalMap.y*-varTexCoord4.xyz;
	tgSpaceNormal = normalize(tgSpaceNormal);
	
	vec4 homogTgsNormal = vec4(tgSpaceNormal,0.0);
	
    sphereUVs.x = dot(matViewI[0], homogTgsNormal);
    sphereUVs.y = dot(matViewI[1], homogTgsNormal);
    sphereUVs = (sphereUVs * vec2( 0.5,-0.5) + vec2( 0.5,0.5));
	
	float invAlpha = 1.0 - playerInfos.a;
	diffuseMap = texture2D(DiffuseMapSampler, varTexCoord2.xy);
	diffuseMap.xyz = ((playerInfos.a * playerInfos.xyz) + (diffuseMap.xyz * invAlpha));
    sphereMap = texture2D(SphereMapSampler, sphereUVs); //will be slow as we compute uvs in fragment shaders
	
	//according to catalin and the fact that GPu has out-of-order execution, we process all code not using sphereMap before
    specularColor = SpecularColor_Node.xyz*diffuseMap.www;
    NdotL1 = clamp(dot(tgSpaceNormal, varTexCoord0.xyz), 0.0, 1.0);

    halfVector = varTexCoord0.xyz + varTexCoord1.xyz;
	halfVector = normalize(halfVector);
	
    NdotH1 = clamp(dot(tgSpaceNormal, halfVector), 0.0, 1.0);
    light0 = pow(NdotH1, Glossiness_Node) * specularColor;
	
	//compute ambient and diffuse value using sphereMap
  	sphereDiffValue = (sphereMap.xyz*SphereMapIntensity) * (diffuseMap.xyz*DiffuseMapIntensity);
    colorValue = AmbientColor_Node.xyz*sphereDiffValue;
    
	lightMap.xyz = (lightMap.xyz + 1.1)*0.5;
    light0 = light0 + sphereDiffValue*NdotL1;
    light0 = light0*light0Color.xyz;
	
	gl_FragColor = vec4((colorValue + light0)*lightMap.xyz, 1.0);
	//gl_FragColor = vec4(colorValue + light0, 1.0);

} // main end
