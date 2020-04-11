#ifndef BIOUM_SHADOW_CASTER_PASS_INCLUDE
#define BIOUM_SHADOW_CASTER_PASS_INCLUDE

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

    #if defined(_SHADOWS_CLIP) || defined(_SHADOWS_DITHER)
        o.baseUV = TransformBaseUV(v.baseUV);
    #endif

    return o;
}

void ShadowCasterFrag(v2f i)
{
    UNITY_SETUP_INSTANCE_ID(i);
    #if defined(_SHADOWS_CLIP) || defined(_SHADOWS_DITHER)
        half4 baseMap = GetBase(i.baseUV);

        #if defined(_SHADOWS_CLIP)
            clip(baseMap.a - 0.5);
        #elif defined(_SHADOWS_DITHER)
            float dither = InterleavedGradientNoise(i.positionCS.xy, 0);
            clip(baseMap.a - dither);
        #endif
    #endif
}

#endif