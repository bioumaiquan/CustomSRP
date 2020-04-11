#ifndef BIOUM_SHADOW_CASTER_PASS_INCLUDE
#define BIOUM_SHADOW_CASTER_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseMap_ST)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct appdata 
{
    float3 positionOS : POSITION;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f ShadowCasterVert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
    o.positionCS = TransformWorldToHClip(positionWS);

    #if UNITY_REVERSED_Z
        o.positionCS.z = min(o.positionCS.z, o.positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        o.positionCS.z = max(o.positionCS.z, o.positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    #if defined(_ALPHA_TEST)
        float4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
        o.baseUV = v.baseUV * mainTexST.xy + mainTexST.zw;
    #endif

    return o;
}

void ShadowCasterFrag(v2f i)
{
    UNITY_SETUP_INSTANCE_ID(i);
    #if defined(_ALPHA_TEST)
        half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.baseUV);
        half4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
        baseMap *= baseColor;
        clip(baseMap.a - 0.5);
    #endif
}

#endif