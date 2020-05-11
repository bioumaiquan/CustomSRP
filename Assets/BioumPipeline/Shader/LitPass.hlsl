#ifndef BIOUM_LIT_PASS_INCLUDE
#define BIOUM_LIT_PASS_INCLUDE

#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Shadows.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/GI.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"
#include "../ShaderLibrary/Fog.hlsl"

struct appdata 
{
    float3 positionOS : POSITION;
    half3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;
    GI_ATTRIBUTE_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    half3 normalWS : NORMAL;
    float2 baseUV : TEXCOORD1;
    half3 viewDirWS : TEXCOORD2;
    float fogFactor : TEXCOORD3;
    GI_VARYINGS_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f LitVert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);
    TRANSFER_GI_DATA(v, o);

    o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
    o.positionCS = TransformWorldToHClip(o.positionWS);
    o.normalWS = TransformObjectToWorldNormal(v.normalOS);
    o.viewDirWS = SafeNormalize(_WorldSpaceCameraPos - o.positionWS);
    o.fogFactor = ComputeFogFactor(o.positionWS, 1);

    o.baseUV = TransformBaseUV(v.baseUV);
    return o;
}

half4 LitFrag(v2f i) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(i);
	ClipLOD(i.positionCS.xy, unity_LODFade.x);

    half4 baseMap = GetBase(i.baseUV);
    #if defined(_ALPHA_TEST)
        half cutoff = GetCutoff(i.baseUV);
        clip(baseMap.a - cutoff);
    #endif

    Surface surface;
    surface.position = i.positionWS;
    surface.normal = normalize(i.normalWS);
    surface.color = baseMap.rgb;
    surface.alpha = baseMap.a;
    surface.metallic = GetMetallic(i.baseUV);
    surface.smoothness = GetSmoothness(i.baseUV);
    surface.viewDirection = i.viewDirWS;
    surface.depth = -TransformWorldToView(i.positionWS).z;
    surface.dither = InterleavedGradientNoise(i.positionCS.xy, 0);
    surface.fresnelStrength = GetFresnel(i.baseUV);

    BRDF brdf = GetBRDF(surface);
    #if defined(_PREMULTIPLY_ALPHA)
        brdf.diffuse *= surface.alpha;
    #endif
    GI gi = GetGI(GI_FRAGMENT_DATA(i), surface, brdf);
    //half3 color = GetLambertLighting(surface);
    half3 color = GetPbrLighting(surface, brdf, gi);
    color += GetEmission(i.baseUV);

    i.fogFactor = ComputeFogFactor(i.positionWS, 1);
    color = MixFogColor(color, i.fogFactor, surface.viewDirection);

    return half4(color, surface.alpha);
}


#endif