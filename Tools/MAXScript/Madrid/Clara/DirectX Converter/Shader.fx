
/*** Generated through Lumonix shaderFX  by: pedro.fernandez in 3dsmax at: 15/10/2012 15:00:19  ***/ 

// This FX shader was built to support 3ds Max's standard shader compiler. 


texture DiffuseMap
<
	string Name = "SteelBeam_D.tga";
	string UIName = "DiffuseMap";
	string ResourceType = "2D";
>;
 
sampler2D DiffuseMapSampler = sampler_state
{
	Texture = <DiffuseMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
int texcoord0 : Texcoord 
<
	int Texcoord = 0;
	int MapChannel = 1;
	string UIType = "None"; 
>;

int texcoord1 : Texcoord 
<
	int Texcoord = 1;
	int MapChannel = 2;
	string UIType = "None"; 
>;

texture LightMap
<
	string Name = "blank_lm.tga";
	string UIName = "LightMap";
	string ResourceType = "2D";
>;
 
sampler2D LightMapSampler = sampler_state
{
	Texture = <LightMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
texture SpecularMap
<
	string Name = "SteelBeam_S.tga";
	string UIName = "SpecularMap";
	string ResourceType = "2D";
>;
 
sampler2D SpecularMapSampler = sampler_state
{
	Texture = <SpecularMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
texture NormalMap : NormalMap
<
	string Name = "SteelBeam_N.tga";
	string UIName = "NormalMap";
	string ResourceType = "2D";
>;
 
sampler2D NormalMapSampler = sampler_state
{
	Texture = <NormalMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 

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
float4x4 worldIT : WorldInverseTranspose < string UIType = "None"; >;  
float4x4 viewInv : ViewInverse < string UIType = "None"; >;  
float4x4 world : World < string UIType = "None"; >;  
// create the light vector 
float3 lightVec_func(float3 worldSpacePos, float3 lightVector, float3x3 objTangentXf, int lightType) 
{ 
	float3 lightVec = mul(objTangentXf, (mul((lightVector - worldSpacePos), worldI).xyz)); 
	return lightVec; 
} 



// input from application 
	struct a2v { 
	float4 position		: POSITION; 
	float4 tangent		: TANGENT; 
	float4 binormal		: BINORMAL; 
	float4 normal		: NORMAL; 

	float2 texCoord		: TEXCOORD0; 
	float2 texCoord1	: TEXCOORD1; 

}; 

// output to fragment program 
struct v2f { 
        float4 position    		: POSITION; 
        float3 lightVec    		: TEXCOORD0; 
        float3 eyeVec	    	: TEXCOORD1; 

	float2 texCoord			: TEXCOORD2; 
	float2 texCoord1		: TEXCOORD3; 

}; 

//Ambient and Self-Illum Pass Vertex Shader
v2f av(a2v In, uniform float3 lightPos, uniform int lightType, uniform float3 lightDir) 
{ 
    v2f Out = (v2f)0; 
	Out.position = mul(In.position, wvp);				//transform vert position to homogeneous clip space 

	Out.texCoord = In.texCoord;						//pass through texture coordinates from channel 1 
	Out.texCoord1 = In.texCoord1;						//pass through texture coordinates from channel 2 

	return Out; 
} 

//Ambient and Self-Illum Pass Pixel Shader
float4 af(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 

	float4 DiffuseMap = tex2D(DiffuseMapSampler, In.texCoord.xy);
	float4 LightMap = tex2D(LightMapSampler, In.texCoord1.xy);
	float3 input1 = (DiffuseMap.rgb * LightMap.rgb); 
	float input7 = DiffuseMap.a; 

	float4 ret =  float4(0,0,0,1); 
	ret = float4(input1, 1); 
	ret.a = input7; 
	return ret; 
} 

//Diffuse and Specular Pass Vertex Shader
v2f v(a2v In, uniform float3 lightPos, uniform int lightType, uniform float3 lightDir) 
{ 
    v2f Out = (v2f)0; 
	float3x3 objTangentXf;								//build object to tangent space transform matrix 
	objTangentXf[0] = In.binormal.xyz; 
	objTangentXf[1] = -In.tangent.xyz; 
	objTangentXf[2] = In.normal.xyz; 
	float3 worldSpacePos = mul(In.position, world).xyz;	//world space position 
	Out.lightVec = lightVec_func(worldSpacePos, lightPos, objTangentXf, lightType); 
	float4 osIPos = mul(viewInv[3], worldI);			//put world space eye position in object space 
	float3 osIVec = osIPos.xyz - In.position.xyz;		//object space eye vector 
	Out.eyeVec = mul(objTangentXf, osIVec);				//tangent space eye vector passed out 
	Out.position = mul(In.position, wvp);				//transform vert position to homogeneous clip space 

	Out.texCoord = In.texCoord;						//pass through texture coordinates from channel 1 

	return Out; 
} 

//Diffuse and Specular Pass Pixel Shader
float4 f(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 
	float3 ret = float3(0,0,0); 
	float3 V = normalize(In.eyeVec);		//creating the eye vector  
	float3 L = normalize(In.lightVec);		//creating the light vector  

	float4 DiffuseMap = tex2D(DiffuseMapSampler, In.texCoord.xy);
	float input7 = DiffuseMap.a; 


	float4 SpecularMap = tex2D(SpecularMapSampler, In.texCoord.xy);
	float input4 = SpecularMap.r; 


	float4 NormalMap = tex2D(NormalMapSampler, In.texCoord.xy);
	NormalMap.xyz = NormalMap.xyz * 2 - 1;		//expand to -1 to 1 range 
	NormalMap.rgb = normalize(NormalMap.rgb); 		//normalized the normal vector 
	float3 input8 = NormalMap.rgb; 

	float3 N = input8;						//using the Normal socket  
	float3 diffuseColor = float3(0.0, 0.0, 0.0);			//the Diffuse Color socket is empty so we're using black
	float NdotL = dot(N, L);				//calculate the diffuse  
	float diffuse = saturate(NdotL);		//clamp to zero  
	float specularColor = input4; 		//the Specular Color socket was empty - using Specular Level instead
	float glossiness = 20;					//the Glossiness socket was empty - using default value 
	float3 H = normalize(L + V);			//Compute the half angle  
	float NdotH = saturate(dot(N,H));		//Compute NdotH  
	specularColor *= pow(NdotH, glossiness);//Raise to glossiness power and compute final specular color  
	ret += specularColor + diffuseColor;	//add specular and diffuse color together
	ret *= lightColor;						//multiply by the color of the light 
	float attenuation = attenuation_func(lightattenType, lightAttenuation, In.lightVec); 					//calculate the light attenuation  
	float coneangle = coneangle_func(lightconeType, lightHotspot, lightFalloff, In.lightVec, lightDir); 	//calculate the light's cone angle 
	ret *= attenuation * coneangle;			//multiply by the light decay  
	float Opacity = input7;					//bring in the value from the opacity socket 
	float4 done = float4(ret, Opacity);		//create the final ouput value  
	return done; 
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

	pass light1  
    {		 
		VertexShader = compile vs_2_0 v(light1Pos,  light1Type, light1Dir); 
		ZEnable = true; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		AlphaBlendEnable = true; 
		ZWriteEnable = true; 
		SrcBlend = SrcAlpha; 
		DestBlend = One; 
		ZFunc = LessEqual; 
		AlphaTestEnable = FALSE; 
		PixelShader = compile ps_2_0 f(light1Dir, light1Color, light1Attenuation, light1Hotspot, light1Falloff, light1Type, light1attenType, light1coneType, light1CastShadows, 1); 
	}  
}    