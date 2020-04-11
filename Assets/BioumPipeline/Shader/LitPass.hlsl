#ifndef BIOUM_LIT_PASS_INCLUDE
#define BIOUM_LIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Shadows.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half, _Metallic)
    UNITY_DEFINE_INSTANCED_PROP(half, _Smoothness)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct appdata 
{
    float3 positionOS : POSITION;
    half3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    half3 normalWS : NORMAL;
    float2 baseUV : TEXCOORD1;
    half3 viewDirWS : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f LitVert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
    o.positionCS = TransformWorldToHClip(o.positionWS);
    o.normalWS = TransformObjectToWorldNormal(v.normalOS);
    o.viewDirWS = SafeNormalize(_WorldSpaceCameraPos - o.positionWS);

    float4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
    o.baseUV = v.baseUV * mainTexST.xy + mainTexST.zw;
    return o;
}

half4 LitFrag(v2f i) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(i);

    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.baseUV);
    #if defined(_ALPHA_TEST)
        clip(baseMap.a - 0.5);
    #endif
    half4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
    baseMap *= baseColor;

    Surface surface;
    surface.position = i.positionWS;
    surface.normal = normalize(i.normalWS);
    surface.color = baseMap.rgb;
    surface.alpha = baseMap.a;
    surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
    surface.smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);
    surface.viewDirection = i.viewDirWS;
    surface.depth = -TransformWorldToView(i.positionWS).z;
    surface.dither = InterleavedGradientNoise(i.positionCS.xy, 0);

    BRDF brdf = GetBRDF(surface);
    #if defined(_PREMULTIPLY_ALPHA)
        brdf.diffuse *= surface.alpha;
    #endif
    //half3 color = GetLambertLighting(surface);
    half3 color = GetPbrLighting(surface, brdf);

    return half4(color, surface.alpha);
}


#endif