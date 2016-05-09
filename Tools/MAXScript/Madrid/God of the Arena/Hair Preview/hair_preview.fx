
/*** Generated through Lumonix shaderFX  by: norman.schaar in 3dsmax at: 27/05/2013 16:24:19  ***/ 

// This FX shader was built to support 3ds Max's standard shader compiler. 


float3 tintColor
<
	string UIName = "tintColor";
	string UIType = "ColorSwatch";
> = {0.72549f, 0.54902f, 0.223529f};
 
texture diffuseMap
<
	string Name = "ro_base01_hair01_df.tga";
	string UIName = "diffuseMap";
	string ResourceType = "2D";
>;
 
sampler2D diffuseMapSampler = sampler_state
{
	Texture = <diffuseMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
texture normalMap
<
	string Name = "ro_base01_hair01_nm.tga";
	string UIName = "normalMap";
	string ResourceType = "2D";
>;
 
sampler2D normalMapSampler = sampler_state
{
	Texture = <normalMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
float4x4 world : World < string UIType = "None"; >;  
texture barlaPalette
<
	string Name = "Fx_BARLA_01_basicGroundBounce.tga";
	string UIName = "barlaPalette";
	string ResourceType = "2D";
>;
 
sampler2D barlaPaletteSampler = sampler_state
{
	Texture = <barlaPalette>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
float diffuseIntensity
<
	string UIType = "FloatSpinner";
	float UIMin = -999.0;
	float UIMax = 999.0;
	float UIStep = 0.1;
	string UIName = "diffuseIntensity";
> = 1.0;
 
float3 LightAmbient
<
	string UIName = "LightAmbient";
	string UIType = "ColorSwatch";
> = {0.0f, 0.0f, 0.0f};
 
float4x4 viewInv : ViewInverse < string UIType = "None"; >;  
texture specPalette
<
	string Name = "Fx_SPEC_hair_01.tga";
	string UIName = "specPalette";
	string ResourceType = "2D";
>;
 
sampler2D specPaletteSampler = sampler_state
{
	Texture = <specPalette>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
float specularIntensity
<
	string UIType = "FloatSpinner";
	float UIMin = -999.0;
	float UIMax = 999.0;
	float UIStep = 0.1;
	string UIName = "specularIntensity";
> = 1.0;
 

// this function does the different types of light attenuation 
float attenuation_func(int lightattenType, float4 lightAttenuation, float3 lightVec) 
{ 
	float att = 1.0; 
	return att; 
} 
	 
// this function does the different types of cone angle 
float coneangle_func(int lightconeType, float lightHotspot, float lightFalloff, float3 lightVec, float3 lightDir) 
{ 
	float cone = 1.0; 
	return cone; 
} 

/************** light info **************/ 

float3 light1Dir : Direction 
< 
	string UIName = "Light 1 Direction"; 
	string Object = "TargetLight"; 
	string Space = "World"; 
		int refID = 1; 
> = {100.0f, 100.0f, 100.0f}; 

float3 light1Pos : POSITION 
< 
	string UIName = "Light 1 Position"; 
	string Object = "PointLight"; 
	string Space = "World"; 
		int refID = 1; 
> = {100.0f, 100.0f, 100.0f}; 

float4 light1Color : LIGHTCOLOR <int LightRef = 1; string UIWidget = "None"; > = { 1.0f, 1.0f, 1.0f, 1.0f}; 
float4 light1Attenuation : LightAttenuation <int LightRef = 1; string UIWidget = "None"; > = { 20.0f, 30.0f, 0.0f, 100.0f}; 
float light1Hotspot : LightHotSpot <int LightRef = 1; string UIWidget = "None"; > = { 43.0f }; 
float light1Falloff : LightFallOff <int LightRef = 1; string UIWidget = "None"; > = { 45.0f }; 

#define light1Type 1
#define light1attenType 0
#define light1coneType 0
#define light1CastShadows false

//---------------------------------- 

float4x4 wvp : WorldViewProjection < string UIType = "None"; >;  
float4x4 worldI : WorldInverse < string UIType = "None"; >;  
// create the light vector 
float3 lightVec_func(float3 worldSpacePos, float3 lightVector, float3x3 objTangentXf, int lightType) 
{ 
	float3 lightVec = mul(objTangentXf, (mul((lightVector - worldSpacePos), worldI).xyz)); 
	return lightVec; 
} 

// input from application 
	struct a2v { 
	float4 position		: POSITION; 

	float2 texCoord		: TEXCOORD0; 
	float4 tangent		: TANGENT; 
	float4 binormal		: BINORMAL; 
	float4 normal		: NORMAL; 

}; 

// output to fragment program 
struct v2f { 
        float4 position    		: POSITION; 

	float2 texCoord			: TEXCOORD0; 
        float3 lightVec    		: TEXCOORD1; 
        float3 eyeVec	    	: TEXCOORD2; 

}; 

// Ambient Pass Vertex Shader: 
v2f av(a2v In, uniform float3 lightPos, uniform int lightType, uniform float3 lightDir) 
{ 
	v2f Out = (v2f)0; 
	Out.position = mul(In.position, wvp);				//transform vert position to homogeneous clip space 

	In.texCoord += float2(0.0,1.0);		//this fixes Max's V texcoord which is off by one 
	Out.texCoord = In.texCoord;						//pass through texture coordinates from channel 1 
	//this code was added by the Light Vector Node 
	float3x3 objTangentXf;								//build object to tangent space transform matrix 
	#ifdef YUP 
	objTangentXf[0] = In.tangent.xyz; 
	objTangentXf[1] = -In.binormal.xyz; 
	#else 
	objTangentXf[0] = In.binormal.xyz; 
	objTangentXf[1] = -In.tangent.xyz; 
	#endif 
	objTangentXf[2] = In.normal.xyz; 
	float3 wsLPos = mul(In.position, world).xyz;			//put the vert position in world space 
	float3 wsLVec = lightPos - wsLPos;    //cast a ray to the light 
	float3 osLVec = mul(wsLVec, worldI).xyz;  //transform the world space light vector to object space 
	Out.lightVec = mul(objTangentXf, osLVec);			//tangent space light vector passed out 
	//these three lines were added by the Eye Vector Node 
	float4 osIPos = mul(viewInv[3], worldI);			//put world space eye position in object space 
	float3 osIVec = osIPos.xyz - In.position.xyz;		//object space eye vector 
	Out.eyeVec = mul(objTangentXf, osIVec);				//tangent space eye vector passed out 

	return Out; 
} 

// Ambient Pass Pixel Shader: 
float4 af(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 

	float4 diffuseMap = tex2D(diffuseMapSampler, In.texCoord.xy);
	float3 MathVecConstuct_156 = float3(diffuseMap.r, diffuseMap.r, diffuseMap.r);
	float UIConst_4389 = 0.5; 
	float4 normalMap = tex2D(normalMapSampler, In.texCoord.xy);
	float UIConst_4703 = 2.0; 
	float UIConst_9884 = -1.0; 
	float3 MathOperator_9453 = (normalMap.rgb * UIConst_4703) + UIConst_9884;
	float3 L = normalize(In.lightVec.xyz);	//normalized light vector 
	float3 MathNormalize_1332 = normalize(L);		//Normalize 
	float MathDotProduct_1233 = saturate(dot(MathOperator_9453,MathNormalize_1332)); 		//clamped dot product 
	float UIConst_1244 = 1.0; 
	float UIConst_4928 = 0.5; 
	float UIConst_8856 = 0.5; 
	float2 MathVecConstuct_7475 = float2(((MathDotProduct_1233 + UIConst_1244) * UIConst_4928), UIConst_8856);
	float4 barlaPalette = tex2D(barlaPaletteSampler, MathVecConstuct_7475.xy);
	float UIConst_2714 = 0.5; 
	float3 V = normalize(In.eyeVec.xyz);		//normalized eye vector 
	float3 MathNormalize_1959 = normalize((L + V));		//Normalize 
	float MathDotProduct_6155 = saturate(dot(MathOperator_9453,MathNormalize_1959)); 		//clamped dot product 
	float UIConst_1627 = 0.5; 
	float2 MathVecConstuct_7366 = float2(MathDotProduct_6155, UIConst_1627);
	float4 specPalette = tex2D(specPaletteSampler, MathVecConstuct_7366.xy);
	float3 input1 = ((((tintColor.rgb * MathVecConstuct_156) * UIConst_4389) * ((((barlaPalette.rgb * diffuseIntensity) + LightAmbient.rgb) * UIConst_2714) + UIConst_2714)) + (((specPalette.rgb * specularIntensity) * diffuseMap.g) * lightColor.rgb)); 
	float input3 = diffuseMap.b; 

	float4 ret =  float4(input1, 1); 
	ret.a = input3 ; 
	return ret; 
} 

technique Complete  
{  
	pass ambient  
    {		 
		VertexShader = compile vs_2_0 av(light1Pos,  light1Type, light1Dir); 
		ZEnable = true; 
		ZWriteEnable = true; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		AlphaBlendEnable = true; 
		SrcBlend = SrcAlpha; 
		DestBlend = InvSrcAlpha; 
		AlphaTestEnable = FALSE; 
		PixelShader = compile ps_2_0 af(light1Dir, light1Color, light1Attenuation, light1Hotspot, light1Falloff, light1Type, light1attenType, light1coneType, light1CastShadows, 1); 
	}  

}    